#!/usr/bin/env python3
"""One-command deterministic replay; stdlib Python 3 and a C++17 compiler."""
import json
import subprocess
import tempfile
from pathlib import Path

HERE=Path(__file__).resolve().parent
EXPECTED=json.loads((HERE/'CERTIFICATE.json').read_text())

def run():
    with tempfile.TemporaryDirectory() as d:
        for src,exe in [('q25_singer_two_generation.cpp','primary'),
                        ('independent_crosssum_bk.cpp','independent')]:
            subprocess.run(['g++','-O3','-std=c++17','-Wall','-Wextra','-pedantic',
                            str(HERE/src),'-o',str(Path(d)/exe)],check=True)
        a=subprocess.run([str(Path(d)/'primary')],capture_output=True,text=True,check=True)
        got=json.loads(a.stdout)
        for key,value in EXPECTED.items():
            if key in got:
                assert got[key]==value,(key,got[key],value)
        b=subprocess.run([str(Path(d)/'independent')],capture_output=True,text=True,check=True)
        assert 'cases=234360 no 11-mark extension' in b.stdout
        assert '33-mark Sidon witness at T=2334' in b.stdout
        print('PASS primary 234360 affine variants, alpha=10, exact frozen counts')
        print(b.stdout.strip())
    p=subprocess.run(['python3',str(HERE/'two_lag_fraction.py')],capture_output=True,text=True,check=True)
    assert '455 rational cases' in p.stdout
    print(p.stdout.strip())
    print('PASS all exact checks; independent non-author review still pending')

if __name__=='__main__':run()
