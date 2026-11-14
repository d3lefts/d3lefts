#!/usr/bin/env python3
"""Fail-closed integrity/schema gate for normalized COSTEP/ETEP pairs.

A manifest's declared origin, operator/simulator and `authenticated` flag are
metadata, not proof of authorship or data authenticity. This tool verifies local
content integrity and schema only; source verification must occur externally.
"""
import argparse
import hashlib
import json
from pathlib import Path
from paired_seed_diagnostic import diagnostic

REQUIRED = {'origin','model_revision','operating_mode','seed','fault_id','fault_time_s','columns','sha256','authenticated_by','dataset_id','local_file'}


def validate(manifest_path):
    manifest_path=Path(manifest_path)
    manifest=json.loads(manifest_path.read_text())
    if set(manifest.get('traces',{}))!={'normal','fault'}:
        raise ValueError('exactly two trace records required')
    records=manifest['traces']
    for name,record in records.items():
        missing=REQUIRED-set(record)
        if missing: raise ValueError(f'{name}: missing fields {sorted(missing)}')
        if not isinstance(record['columns'], list) or not record['columns'] or any(not isinstance(c,str) or not c for c in record['columns']):
            raise ValueError(f'{name}: invalid column declaration')
        if record['authenticated_by'] in ('','unknown','none',None):
            raise ValueError('source identity not externally verified')
        localfile=Path(record['local_file'])
        if not localfile.is_absolute():localfile=manifest_path.parent/localfile
        if not localfile.is_file():raise ValueError(f'{name}: missing raw export {localfile}')
        digest=hashlib.sha256(localfile.read_bytes()).hexdigest()
        if digest!=record['sha256']:
            raise ValueError(f'{name}: file SHA256 mismatch')
        record['_absolute_path']=str(localfile)
    a,b=records['normal'],records['fault']
    for key in ('origin','model_revision','operating_mode','seed','fault_time_s','columns','dataset_id'):
        if a[key]!=b[key]:raise ValueError(f'mismatched {key}; cannot treat as paired')
    if a['fault_id']!=0 or b['fault_id']==0:
        raise ValueError('expected fault 0 vs nonzero fault id')
    from paired_seed_diagnostic import read_csv
    actual,_=read_csv(a['_absolute_path'])
    if a['columns']!=actual:
        raise ValueError('declared and actual columns differ')
    result=diagnostic(a['_absolute_path'],b['_absolute_path'],float(a['fault_time_s']))
    # The source references and authenticated_by values are untrusted metadata.
    return {'integrity':'hashes_and_normalized_schema_checked_not_source_authenticity',
            'trace_source_claim': a['origin'],
            'model_revision_claim':a['model_revision'],
            'fault_id_claim':b['fault_id'],
            'source_authentication_asserted_by':a['authenticated_by'],
            'analysis':result}

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest')
    args=parser.parse_args()
    print(json.dumps(validate(args.manifest),indent=2))
