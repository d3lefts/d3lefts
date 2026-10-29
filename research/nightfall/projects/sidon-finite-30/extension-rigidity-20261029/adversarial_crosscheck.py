#!/usr/bin/env python3
"""Adversarial independent direct-vs-incremental weak-Sidon tests and mutation rejection."""
from pathlib import Path
from itertools import combinations
import json, random, tempfile, sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
import verify_independent as v

HERE=Path(__file__).resolve().parent
B=tuple(map(int,(HERE/'witness_30.txt').read_text().strip().split(',')))
old=set(B)
forbidden={b+c-a for a in B for b,c in combinations((z for z in B if z!=a),2)}
sums={a+b for a,b in combinations(B,2)}
diffs={b-a for a,b in combinations(B,2)}
V=set()
for a,b in combinations(B,2):
    for x in (2*a-b,2*b-a):
        if x not in old and x not in forbidden:V.add(x)
    if (a+b)%2==0:
        x=(a+b)//2
        if x not in old and x not in forbidden:V.add(x)
V=sorted(V)
assert len(V)==305
rng=random.Random(20261029)
pairs=[]
for _ in range(45):
    pairs.append(tuple(rng.sample(V,2)))
for _ in range(40):
    x,y=rng.sample(B,2)
    pairs.append((x+y-B[0],2*x-B[1]))
for _ in range(40):
    x=rng.choice(V); b=rng.choice(B)
    pairs.append((x,2*b-x))
for _ in range(40):
    x=rng.choice(V); b=rng.choice(B)
    pairs.append((x,2*x-b))
for _ in range(40):
    pairs.append((rng.randrange(-30000000,30000000),rng.randrange(-30000000,30000000)))
assert len(pairs)==205
for x,y in pairs:
    incremental=v.four_compatible_pair(x,y,old,forbidden,sums,diffs)
    direct=(x not in old and y not in old and x!=y and v.weak_four(B+(x,y)))
    assert incremental==direct,(x,y,incremental,direct)

with tempfile.TemporaryDirectory() as td:
    td=Path(td)
    changed=td/'changed.txt'
    changed.write_text((HERE/'witness_30.txt').read_text().replace('19465109','19465108'))
    try: v.verify(source=changed)
    except AssertionError as e: assert 'hash' in str(e)
    else: raise AssertionError('forged source accepted')
    bad=td/'forged_cert.json'
    c=json.loads((HERE/'portfolio_certificate.json').read_text())
    c['portfolio'][0][0]=123456789
    bad.write_text(json.dumps(c))
    try: v.verify(certificate=bad)
    except AssertionError as e: assert 'invalid 17-point subset' in str(e)
    else: raise AssertionError('forged portfolio accepted')

print(json.dumps({'status':'PASS','direct_weak_sidon_crosschecks':len(pairs),
                  'tampered_source_rejected':True,'tampered_portfolio_rejected':True,
                  'seed':20261029},sort_keys=True))
