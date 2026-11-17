#!/usr/bin/env python3
"""Checks frozen synthetic trace receipt, hashes, and generator replay."""
import csv
import hashlib
import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'labs'))
from aurora import FIELDS,simulate
from audit import verify_trace


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    receipt=json.loads((ROOT/'evidence/reference-run.json').read_text(encoding='utf-8'))
    for name,expected in receipt['files_sha256'].items():
        if sha(ROOT/name)!=expected:
            raise AssertionError(f'reference input changed without receipt update: {name}')
    trace=ROOT/'labs/output.csv'
    audit=verify_trace(trace)
    if audit!=receipt['audit']:
        raise AssertionError('audited reference counts differ from receipt')
    with TemporaryDirectory() as work:
        path=Path(work)/'replay.csv'
        with path.open('w',newline='',encoding='utf-8') as fp:
            writer=csv.DictWriter(fp,fieldnames=FIELDS);writer.writeheader()
            writer.writerows(simulate(seed=2026,trials=5000,policy='quorum'))
        if sha(path)!=sha(trace):raise AssertionError('seeded generator did not replay reference bytes')
    print('PASS: reference source hashes, audited counts, and 5000-episode replay are identical')

if __name__=='__main__': main()
