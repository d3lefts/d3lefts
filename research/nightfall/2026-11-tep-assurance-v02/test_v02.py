#!/usr/bin/env python3
"""Purely synthetic adversarial validation tests; no plant safety assertions."""
import copy
import hashlib
import json
import tempfile
from pathlib import Path
from lifecycle import solve,check
from validate_normalized_pair import validate
from original_tep_probe import read_data
D=json.loads(Path(__file__).with_name('lifecycle_cases.json').read_text())
count=0
for ch in ['phantom_controller']:
    sc=copy.deepcopy(D['scenarios'][0]);sc['changes'].append(ch)
    try: solve(D,sc)
    except ValueError: count+=1
    else: raise AssertionError('unknown source accepted')
for malformed in [True,-1,'foo']:
    d=copy.deepcopy(D)
    d['evidence'][0]['new_cost']=malformed
    try:solve(d,d['scenarios'][0])
    except ValueError:count+=1
    else:raise AssertionError('invalid cost type accepted')
for dep in ['unregistered_sensor']:
    d=copy.deepcopy(D);d['evidence'][1]['depends_on'].append(dep)
    try:solve(d,d['scenarios'][0])
    except ValueError:count+=1
    else:raise AssertionError('unregistered evidence dependency accepted')
for wrong in [b'',b'1 2 3\n']:
    try:read_data('d00.dat',wrong)
    except ValueError:count+=1
    else:raise AssertionError('wrong source hash accepted')
with tempfile.TemporaryDirectory() as tmp:
    p=Path(tmp)
    for name in ['n.csv','f.csv']:
        (p/name).write_text((Path(__file__).with_name('examples')/('normal_toy.csv' if name[0]=='n' else 'fault_toy.csv')).read_text())
    def rec(filename,faultid):
        return {'origin':'example_fixture','model_revision':'toy','operating_mode':1,'seed':17,'fault_id':faultid,'fault_time_s':12,
                'columns':['time_s','sensor_A','sensor_B'],
                'sha256':hashlib.sha256((p/filename).read_bytes()).hexdigest(), 'authenticated_by':'synthetic_fixture_author',
                'dataset_id':'toy','local_file':filename}
    m={'traces':{'normal':rec('n.csv',0),'fault':rec('f.csv',1)}}
    path=p/'manifest.json'
    def write():path.write_text(json.dumps(m))
    write()
    # The fixtures in v0.1 may use different column names; derive actual names for this test.
    import csv
    columns=list(next(csv.DictReader((p/'n.csv').open())).keys())
    for v in m['traces'].values():v['columns']=columns
    write()
    assert validate(path)['integrity'].startswith('hashes_');count+=1
    m['traces']['fault']['seed']=18;write()
    try:validate(path)
    except ValueError:count+=1
    else:raise AssertionError('mismatched seed accepted')
    m['traces']['fault']['seed']=17
    m['traces']['fault']['sha256']='0'*64;write()
    try:validate(path)
    except ValueError:count+=1
    else:raise AssertionError('tampered file hash accepted')
    m['traces']['fault']['sha256']=hashlib.sha256((p/'f.csv').read_bytes()).hexdigest()
    m['traces']['fault']['authenticated_by']='unknown';write()
    try:validate(path)
    except ValueError:count+=1
    else:raise AssertionError('unverified source accepted')
print('Synthetic fail-closed tests passed:',count)
