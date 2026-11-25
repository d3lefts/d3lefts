#!/usr/bin/env python3
"""Export a relocatable pinned Lean/Mathlib workspace through Actions artifacts."""
import hashlib, json, os, pathlib, subprocess, tarfile
from pathlib import Path
out=Path('/tmp/nightfall-workbench-export');out.mkdir(exist_ok=True)
ml=Path('/tmp/mathlib4')
prefix=Path(subprocess.check_output(['lean','--print-prefix'],text=True).strip()).resolve()
version=subprocess.check_output(['lean','--version'],text=True).strip()
lean_commit=os.environ['NIGHTFALL_LEAN_COMMIT']; mathlib_commit=os.environ['NIGHTFALL_MATHLIB_COMMIT']
assert lean_commit[:12] in version
assert subprocess.check_output(['git','-C',str(ml),'rev-parse','HEAD'],text=True).strip()==mathlib_commit
# No rebuild: export already available Mathlib cache and the installed toolchain.
# Keep compiler runtime, all serialized Lean objects and required native libraries.
# Static libraries and generated C/IR are not needed for proof elaboration.
def filter_runtime(t):
    if t.name.endswith(('.a','.o','.bc')): return None
    return t
with subprocess.Popen(['zstd','-3','-T2','-q','-o',str(out/'runtime.tar.zst')],stdin=subprocess.PIPE) as z:
    with tarfile.open(fileobj=z.stdin,mode='w|',dereference=True) as tar:
        for d in ['bin','lib','include','share','src']:
            p=prefix/d
            if p.exists():tar.add(p,arcname='lean/'+d,filter=filter_runtime)
        lib=ml/'.lake/build/lib/lean'
        assert (lib/'Mathlib.olean').is_file()
        tar.add(lib,arcname='mathlib-lib',filter=filter_runtime)
        for p in sorted((ml/'.lake/packages').glob('*/.lake/build/lib/lean')):
            package=p.parents[3].name
            tar.add(p,arcname='packages/'+package,filter=filter_runtime)
        source=Path('research/nightfall/formalization')
        for p in sorted(source.rglob('*.lean')):
            tar.add(p,arcname=str(Path('sources')/p.relative_to(source)))
        closure=source/'aa_product/CLOSURE.txt'
        tar.add(closure,arcname='sources/aa_product/CLOSURE.txt')
    z.stdin.close()
    if z.wait()!=0: raise SystemExit('zstd export failed')
archive=out/'runtime.tar.zst'; max_bytes=64*48*1024**2
if archive.stat().st_size>max_bytes: raise SystemExit('Portable snapshot exceeds approved 3 GiB transfer cap')
subprocess.run(['split','-b','48M','-d','-a','2',str(archive),str(out/'part-')],check=True)
archive.unlink()
parts={}
for p in sorted(out.glob('part-*')):
    with p.open('rb') as f: parts[p.name]=hashlib.file_digest(f,'sha256').hexdigest()
manifest={'schema':1,'lean_version':version,'lean_commit':lean_commit,'mathlib_commit':mathlib_commit,'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip(),'parts':parts,'bytes':sum((out/x).stat().st_size for x in parts)}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps(manifest,indent=2))
