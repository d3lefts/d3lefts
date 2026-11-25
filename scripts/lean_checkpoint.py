#!/usr/bin/env python3
"""Paper-neutral local Lean checkpoint runner. A cache hit is not a theorem receipt."""
import argparse
import fcntl
import hashlib
import json
import os
import re
import shutil
import signal
import subprocess
import tempfile
import time
from pathlib import Path

NAME = re.compile(r"[A-Za-z_][A-Za-z0-9_']*(?:\.[A-Za-z_][A-Za-z0-9_']*)*")
AXIOMS = {"propext", "Classical.choice", "Quot.sound"}


def require(ok, message):
    if not ok:
        raise RuntimeError(message)


def digest(p):
    with Path(p).open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def canonical(x):
    return json.dumps(x, sort_keys=True, separators=(',', ':')).encode()


def key(x):
    return hashlib.sha256(canonical(x)).hexdigest()


def write(p, x):
    p.write_bytes(canonical(x) + b'\n')


def read(p):
    return json.loads(p.read_text())


def module_path(name):
    require(NAME.fullmatch(name), f'invalid module/declaration: {name}')
    return Path(*name.split('.'))


def plan_order(plan, root):
    rows = plan['modules']
    require(isinstance(rows, dict) and rows, 'empty module plan')
    seen, active, ordered = set(), set(), []
    def visit(m):
        module_path(m)
        require(m in rows and m not in active, f'missing or cyclic dependency: {m}')
        if m in seen:
            return
        active.add(m)
        row = rows[m]
        src = (root / row['source']).resolve()
        require(src.is_relative_to(root) and src.is_file() and src.suffix == '.lean', f'invalid source: {m}')
        deps = row['imports']
        require(isinstance(deps, list) and len(set(deps)) == len(deps), f'invalid imports: {m}')
        for d in deps:
            visit(d)
        active.remove(m)
        seen.add(m)
        ordered.append(m)
    terminal = plan['terminal']
    visit(terminal['module'])
    names = terminal['declarations']
    require(names and len(set(names)) == len(names) and all(NAME.fullmatch(n) for n in names), 'invalid terminal names')
    return ordered


def artifact_hashes(folder):
    return {p.name: digest(p) for p in sorted(folder.iterdir()) if p.is_file() and (p.name.endswith('.olean') or '.olean.' in p.name or p.name.endswith('.ilean'))}


def check_entry(folder, identity, basename):
    if not folder.is_dir():
        return False
    meta = read(folder / 'manifest.json')
    require(meta['identity'] == identity, f'cache identity mismatch: {folder}')
    require(meta['artifacts'] == artifact_hashes(folder) and basename + '.olean' in meta['artifacts'], f'cache artifact mismatch: {folder}')
    require(identity['source'] == digest(folder/'source.lean'), f'cache source mismatch: {folder}')
    require(meta['compile_log'] == digest(folder / 'compile.log'), f'cache log mismatch: {folder}')
    status = read(folder/'compile.log.json')
    require(status['exit'] == 0 and status['status'] == 'passed' and meta['compile_status'] == digest(folder/'compile.log.json'), f'cache compile status mismatch: {folder}')
    return True


def rss_mib(pid):
    try:
        fields = dict(line.split(':', 1) for line in Path(f'/proc/{pid}/status').read_text().splitlines() if ':' in line)
        return sum(int(fields.get(n, '0 kB').split()[0]) for n in ('VmRSS', 'VmSwap')) / 1024
    except FileNotFoundError:
        return 0


def memory_pressure():
    # Avoid a global OOM/paging loop before the child RSS poll catches up.
    try:
        c = Path('/sys/fs/cgroup')
        maximum = (c/'memory.max').read_text().strip()
        stats = dict(line.split() for line in (c/'memory.stat').read_text().splitlines())
        return maximum != 'max' and (int(stats['anon']) + int(stats.get('shmem', 0))) > .9 * int(maximum)
    except (OSError, ValueError, KeyError):
        return False


def bounded(argv, env, log, memory, seconds, cwd, output=None):
    require(not output or not output.exists(), 'export destination already exists')
    started = time.monotonic()
    peak = 0
    with log.open('wb') as f, (output or log).open('ab') as out:
        p = subprocess.Popen(argv, env=env, cwd=cwd, stdout=out if output else f, stderr=f if output else subprocess.STDOUT, start_new_session=True)
        reason = None
        try:
            while p.poll() is None:
                peak = max(peak, rss_mib(p.pid))
                pressure = peak > memory or memory_pressure()
                if pressure or time.monotonic() - started > seconds:
                    reason = 'resource-memory' if pressure else 'resource-timeout'
                    try:
                        os.killpg(p.pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass
                    break
                time.sleep(.15)
        finally:
            if p.poll() is None:
                try:
                    os.killpg(p.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
            rc = p.wait()
    result = {'command': list(map(str, argv)), 'exit': rc, 'seconds': round(time.monotonic()-started, 3), 'peak_rss_swap_mib': peak,
              'status': reason or ('passed' if rc == 0 else 'compiler-or-kernel-failure')}
    write(log.with_suffix(log.suffix + '.json'), result)
    require(result['status'] == 'passed', f"{result['status']}: {log}")
    return log.read_text(errors='replace')


def audit(text, names):
    require('sorryAx' not in text, 'sorryAx found')
    for n in names:
        m = re.search(r"'" + re.escape(n) + r"' depends on axioms:\s*\[([^\]]*)\]", text)
        if m:
            require(set(x.strip() for x in m[1].split(',') if x.strip()) <= AXIOMS, f'nonstandard axiom: {n}')
        else:
            require(f"'{n}' does not depend on any axioms" in text, f'missing audit: {n}')


def run(args):
    root = args.root.resolve()
    plan = read(args.plan)
    order = plan_order(plan, root)
    store = args.store.resolve()
    store.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix='lean-run-', dir=store))
    overlay = work / 'lib'
    overlay.mkdir()
    allowed = set(args.build)
    require(allowed <= set(order), 'build allowlist contains non-closure module')
    lock = root / 'docs/lean-compiler-lock.json'
    pin = read(lock)
    runtime = read(args.runtime_manifest)
    require(runtime['lean_commit'] == pin['lean_source_commit'] and runtime['mathlib_commit'] == pin['mathlib_commit'], 'runtime pin mismatch')
    lean, checker = str(args.lean.resolve()), str(args.checker.resolve())
    exporter = str(args.lean.resolve().with_name('leanexport'))
    require(Path(exporter).is_file(), 'pinned leanexport unavailable')
    base = [Path(p).resolve() for p in args.base_path]
    require(all(p.is_dir() for p in base), 'missing runtime library path')
    env = {**os.environ, 'LEAN_PATH': os.pathsep.join(map(str, [overlay, *base])), 'LEAN_NUM_THREADS': '1', 'PATH': str(Path(lean).parent) + os.pathsep + os.environ.get('PATH', '')}
    version = bounded([lean, '--version'], env, work/'version.log', args.memory_mib, 30, work).strip()
    require(pin['lean_source_commit'][:12] in version and pin['toolchain'].split(':v')[-1] in version, 'actual Lean version mismatch')
    runtime_key = key({'snapshot': digest(args.runtime_manifest), 'lock': digest(lock), 'lean': digest(lean), 'checker': digest(checker), 'exporter': digest(exporter), 'version': version, 'cache_schema': 2})
    keys, objects = {}, {}
    source_root = work / 'source'
    source_root.mkdir()
    for name in order:
        row = plan['modules'][name]
        rel = module_path(name)
        src = (root / row['source']).resolve()
        identity = {'runtime': runtime_key, 'module': name, 'source': digest(src), 'imports': {m: {'key': keys[m], 'artifacts': objects[m]} for m in row['imports']}}
        dest = overlay / rel.parent
        dest.mkdir(parents=True, exist_ok=True)
        local = source_root / rel.with_suffix('.lean')
        local.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, local)
        require(digest(local) == identity['source'], 'source changed during copy')
        log = work / (name + '.deps.log')
        deps = bounded([lean, '--deps', str(local.relative_to(source_root))], env, log, args.memory_mib, args.seconds, source_root)
        actual, external = set(), {}
        # Lean --deps emits resolved .olean paths. Fail closed on unknown or ambiguous output.
        for line in deps.splitlines():
            if not line.strip():
                continue
            p = Path(line.strip()).resolve()
            require(p.suffix == '.olean' and p.is_file(), f'unrecognized dependency: {line}')
            if p.is_relative_to(overlay):
                actual.add('.'.join(p.relative_to(overlay).with_suffix('').parts))
            else:
                roots = [*base, Path(lean).parent.parent/'lib/lean']
                parent = next((b for b in roots if p.is_relative_to(b)), None)
                require(parent is not None, f'outside verified runtime: {p}')
                ext = '.'.join(p.relative_to(parent).with_suffix('').parts)
                require(ext not in plan['modules'], f'project object shadowed by runtime: {ext}')
                external[ext] = {f.name: digest(f) for f in sorted(p.parent.glob(p.stem+'.olean*')) if f.is_file()}
        require(actual == set(row['imports']), f'import closure mismatch: {name}: {actual}')
        require('Mathlib' not in external or bool(row.get('umbrella_reason', '').strip()), f'umbrella import requires explicit source-preservation justification: {name}')
        identity['external'] = external
        ident = keys[name] = key(identity)
        target = store / 'objects' / ident
        target.parent.mkdir(exist_ok=True)
        if not target.exists():
            for seed in args.seed_store:
                candidate = seed.resolve() / 'objects' / ident
                if check_entry(candidate, identity, rel.name):
                    imported = Path(tempfile.mkdtemp(prefix='seed-', dir=target.parent))
                    shutil.copytree(candidate, imported, dirs_exist_ok=True)
                    check_entry(imported, identity, rel.name)
                    imported.rename(target)
                    break
        if not check_entry(target, identity, rel.name):
            require(name in allowed, f'cache miss (no cold-build authorization): {name}; key={ident}')
            stage = Path(tempfile.mkdtemp(prefix='pending-', dir=target.parent))
            try:
                output = stage / (rel.name + '.olean')
                log = stage / 'compile.log'
                text = bounded([lean, '-o', str(output), str(local.relative_to(source_root))], env, log, args.memory_mib, args.seconds, source_root)
                require('sorryAx' not in text and not re.search(r'declaration uses.{0,20}sorry', text, re.I), 'sorry in compiler diagnostics')
                require(output.is_file(), 'compiler returned no object')
                require(digest(src) == identity['source'], 'source changed during build')
                shutil.copyfile(local, stage/'source.lean')
                write(stage/'manifest.json', {'identity': identity, 'artifacts': artifact_hashes(stage), 'compile_log': digest(log), 'compile_status': digest(stage/'compile.log.json')})
                stage.rename(target)
            except BaseException:
                print(f'failed module checkpoint preserved: {stage}', flush=True)
                raise
        objects[name] = read(target/'manifest.json')['artifacts']
        for p in check_files(target):
            shutil.copyfile(p, dest/p.name)
        print(f'{name}: exact object {ident}', flush=True)
    term = plan['terminal']
    receipt_identity = {'runtime': runtime_key, 'module_keys': keys, 'objects': objects, 'terminal': term, 'receipt_schema': 1}
    receipt_id = key(receipt_identity)
    final = store/'receipts'/receipt_id
    final.parent.mkdir(exist_ok=True)
    if not final.exists():
        for seed in args.seed_store:
            previous = seed.resolve()/'receipts'/receipt_id
            if previous.is_dir():
                check_receipt(previous, receipt_identity)
                imported = Path(tempfile.mkdtemp(prefix='receipt-', dir=final.parent))
                shutil.copytree(previous, imported, dirs_exist_ok=True)
                check_receipt(imported, receipt_identity)
                imported.rename(final)
                break
    if final.exists():
        check_receipt(final, receipt_identity)
        print(f'reused exact terminal receipt: {final / "receipt.json"}', flush=True)
        shutil.rmtree(work)
        return
    audit_file = work / 'Audit.lean'
    audit_file.write_text('import ' + term['module'] + '\n' + ''.join('#check ' + n + '\n#print axioms ' + n + '\n' for n in term['declarations']))
    audit(bounded([lean, str(audit_file)], env, work/'axioms.log', args.memory_mib, args.seconds, work), term['declarations'])
    export = work/'terminal.ndjson'
    bounded([exporter, term['module'], '--', *term['declarations']], env, work/'export.log', args.memory_mib, args.seconds, work, output=export)
    require(export.stat().st_size > 0, 'empty kernel export')
    bounded([checker, '--from-export', str(export)], env, work/'kernel.log', args.memory_mib, args.seconds, work)
    files = ['Audit.lean', 'terminal.ndjson', 'axioms.log', 'axioms.log.json', 'export.log', 'export.log.json', 'kernel.log', 'kernel.log.json']
    stage = Path(tempfile.mkdtemp(prefix='receipt-', dir=final.parent))
    for file in files:
        shutil.copyfile(work/file, stage/file)
    write(stage/'receipt.json', {'identity': receipt_identity, 'status': 'local-kernel-pass', 'runner': digest(__file__),
                                'files': {file: digest(stage/file) for file in files},
                                'scope': 'named terminal only; statement equivalence and independent review separate'})
    check_receipt(stage, receipt_identity)
    stage.rename(final)
    print(f'local kernel receipt: {final / "receipt.json"}', flush=True)
    shutil.rmtree(work)


def check_receipt(folder, identity):
    meta = read(folder/'receipt.json')
    require(meta['identity'] == identity and meta['status'] == 'local-kernel-pass', 'terminal receipt identity mismatch')
    files = ['Audit.lean', 'terminal.ndjson', 'axioms.log', 'axioms.log.json', 'export.log', 'export.log.json', 'kernel.log', 'kernel.log.json']
    require(meta['files'] == {file: digest(folder/file) for file in files}, 'terminal receipt byte mismatch')
    for phase in ('axioms', 'export', 'kernel'):
        status = read(folder/(phase+'.log.json'))
        require(status['exit'] == 0 and status['status'] == 'passed', f'failed receipt: {phase}')
    require((folder/'terminal.ndjson').stat().st_size > 0, 'empty terminal export')
    audit((folder/'axioms.log').read_text(), identity['terminal']['declarations'])


def check_files(folder):
    return [folder/n for n in read(folder/'manifest.json')['artifacts']]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ('root', 'plan', 'store', 'runtime-manifest', 'lean', 'checker'):
        p.add_argument('--'+name, required=True, type=Path)
    p.add_argument('--base-path', action='append', required=True)
    p.add_argument('--seed-store', action='append', type=Path, default=[], help='restore exact verified module checkpoints from prior session')
    p.add_argument('--build', action='append', default=[], help='explicitly authorize one cache-missing module')
    p.add_argument('--memory-mib', type=int, default=2560)
    p.add_argument('--seconds', type=int, default=300)
    a = p.parse_args()
    require(a.memory_mib > 0 and a.seconds > 0, 'positive resource budgets required')
    a.store.mkdir(parents=True, exist_ok=True)
    with (a.store/'store.lock').open('a') as lease:
        fcntl.flock(lease, fcntl.LOCK_EX)
        run(a)


if __name__ == '__main__':
    main()
