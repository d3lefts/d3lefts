#!/usr/bin/env python3
"""NIGHTFALL strict named-theorem checker accepting only Lean standard axioms.
Fails closed on unknown axioms, absent output, compiler mismatch or untrusted tokens.
Theorem scope must still be audited from the exact source statement.
"""
import json, sys
from pathlib import Path
STANDARD={'propext','Classical.choice','Quot.sound'}

def dependencies(stdout,name):
    tag=f"'{name}'"
    no=tag+' does not depend on any axioms'
    yes=tag+' depends on axioms:'
    if no in stdout:
        return set()
    if yes not in stdout:
        raise ValueError(f'No named theorem axiom report: {name}')
    after=stdout.split(yes,1)[1]
    if '[' not in after or ']' not in after:
        raise ValueError(f'Malformed axiom report: {name}')
    payload=after.split('[',1)[1].split(']',1)[0]
    return {x.strip() for x in payload.split(',') if x.strip()}

def audit(path):
    r=json.loads(Path(path).read_text())
    assert r['status']=='COMPILED',(path,r['status'],r.get('diagnostics'))
    assert r['version_matches_pin'] is True,(path,r['compiler_version'])
    assert not r['policy_findings'],(path,r['policy_findings'])
    assert r['declarations_requested'],path
    assert not any(d.get('severity')=='error' for d in r.get('diagnostics',[])),path
    for name in r['declarations_requested']:
        deps=dependencies(r['stdout'],name)
        assert deps<=STANDARD,(name,deps-STANDARD)
        print(path,name,'ACCEPT_STANDARD_AXIOMS',sorted(deps))

if __name__=='__main__':
    if len(sys.argv)<2:
        raise SystemExit('usage: check_receipts.py receipt.json [receipt2.json ...]')
    for p in sys.argv[1:]:audit(p)
