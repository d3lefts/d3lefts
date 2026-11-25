"""Append an original repair protocol to a selected official sample prompt; no model execution."""
import argparse
from pathlib import Path, PurePosixPath
import stat
import zipfile

LIMIT = 3 * 1024**3
ALLOWED = {'.yaml','.yml','.md','.txt','.py','.json','.safetensors'}


def build(sample, prompt, protocol, output):
    sample, protocol, output = map(Path, (sample, protocol, output))
    if output.exists():
        raise ValueError('refuse overwrite')
    if not sample.is_dir() or sample.is_symlink():
        raise ValueError('sample must be an ordinary directory')
    files = {}
    for p in sorted(sample.rglob('*')):
        if p.is_symlink():
            raise ValueError('symlink')
        if p.is_dir():
            continue
        name = p.relative_to(sample).as_posix()
        if not p.is_file() or p.suffix not in ALLOWED or '\\' in name:
            raise ValueError('unsupported file: '+name)
        if p.suffix == '.py' and not name.startswith('skills/'):
            raise ValueError('Python outside skills')
        files[name] = p
    target = PurePosixPath(prompt)
    if 'agent.yaml' not in files or str(target) not in files or target.suffix not in {'.md','.txt'}:
        raise ValueError('root agent.yaml and selected text prompt required')
    replacement = files[str(target)].read_bytes() + b'\n\n' + protocol.read_bytes() + b'\n'
    if sum(p.stat().st_size for n,p in files.items() if n != str(target)) + len(replacement) >= LIMIT:
        raise ValueError('archive too large')
    with zipfile.ZipFile(output,'x',compression=zipfile.ZIP_DEFLATED) as z:
        for n,p in files.items():
            item = zipfile.ZipInfo(n, date_time=(1980,1,1,0,0,0))
            item.compress_type = zipfile.ZIP_DEFLATED
            item.external_attr = (stat.S_IFREG | 0o644) << 16
            z.writestr(item, replacement if n == str(target) else p.read_bytes())
    with zipfile.ZipFile(output) as z:
        if z.testzip() is not None:
            raise ValueError('CRC failure')
    return output


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('sample'); p.add_argument('prompt'); p.add_argument('output')
    a = p.parse_args()
    print(build(a.sample, a.prompt, Path(__file__).with_name('repair_protocol.md'), a.output))
