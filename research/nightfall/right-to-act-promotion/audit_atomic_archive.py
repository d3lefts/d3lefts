"""Verify the *downloadable tar archive*, including hidden source files.

No import of gate, promotion runner, or primary verifier.
Validates archive content fingerprints against both the published source version
and the latest admitted source version in the trusted state.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import tarfile

def hash_bytes(x):return hashlib.sha256(x).hexdigest()
def canon(x):return json.dumps(x,sort_keys=True,separators=(',',':')).encode()+b'\n'
def hash_json(x):return hash_bytes(canon(x))

def audit(root):
    root=Path(root)
    archive=root/'admitted-snapshots.tar'
    record=json.loads((root/'trusted/published.json').read_text())
    state=json.loads((root/'trusted/state.json').read_text())
    snapshots={}
    with tarfile.open(archive,'r') as tar:
        for entry in tar:
            path=Path(entry.name)
            parts=path.parts
            assert parts and parts[0]=='snapshots' and len(parts)>=1
            assert '..' not in parts and not path.is_absolute()
            assert not (entry.issym() or entry.islnk()),'symlink in source archive'
            if entry.isdir():continue
            assert entry.isfile(),'unsupported snapshot archive entry'
            assert len(parts)>=3,'unexpected archive file path'
            version=parts[1]
            relative=Path(*parts[2:]).as_posix()
            assert version.startswith('v-')
            payload=tar.extractfile(entry).read()
            snapshots.setdefault(version,[]).append([relative,hash_bytes(payload)])
    assert record['version'] in snapshots and state['version'] in snapshots
    fingerprints={key:hash_json(sorted(items)) for key,items in snapshots.items()}
    assert fingerprints[record['version']]==record['source_hash'],'published snapshot hash mismatch'
    assert fingerprints[state['version']]==state['source_hash'],'current snapshot hash mismatch'
    results={'archive_audit':'passed',
             'github_run_id':os.environ.get('GITHUB_RUN_ID','local'),
             'archive_sha256':hash_bytes(archive.read_bytes()),
             'published_source_version':record['version'],
             'published_source_digest':record['source_hash'],
             'current_source_version':state['version'],
             'current_source_digest':state['source_hash'],
             'snapshot_count':len(snapshots),
             'snapshots_file_counts':{k:len(v) for k,v in snapshots.items()},
             'includes_hidden_source_files':any(
                 rel.startswith('.') for items in snapshots.values() for rel,_ in items)}
    (root/'atomic_archive_audit.json').write_bytes(
        json.dumps(results,indent=2,sort_keys=True).encode()+b'\n')
    print(json.dumps(results,indent=2,sort_keys=True))

if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--dir',default='atomic-results')
    args=ap.parse_args();audit(args.dir)
