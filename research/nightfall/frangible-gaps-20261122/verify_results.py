#!/usr/bin/env python3
"""Replay exact counts and paper's published Table 1 / Table 2 baseline."""
import json, re
from pathlib import Path
p=Path(__file__).parent
expected=json.loads((p/'results.json').read_text())['counts']
old={4:1,6:2,8:2,10:2,12:8,14:58,16:12,18:376,20:1440,22:2622,24:48868,26:7682,28:5664,30:154220,32:833688,34:1075458,36:620632,38:7381190,40:10176048,42:363563276,44:5319950268,46:3066631938}
lower={48:270434770380,50:101263356912,52:25044185400,54:4825134244812,56:951691118548,58:746742641220,60:49521116466230,62:673213740652740,64:869625166376736}
upper={48:279846011304,50:103209363276,52:25280219743,54:5002386935774,56:977942520314,58:766382152147,60:51732686799693,62:706256454940842,64:913579931068704}
def read_log(name):
 lines=(p/name).read_text().strip().splitlines()
 m={}
 for line in lines:
  hit=re.search(r'h=(\d+) omega=(\d+)',line)
  assert hit,line
  h,v=map(int,hit.groups());assert h not in m;m[h]=v
 return m
A=read_log('verifier_surjection.log');B=read_log('verifier_ie.log')
X={int(k):int(v) for k,v in expected.items()}
assert A==B==X,(set(A.items())^set(B.items()))
assert all(X[h]==v for h,v in old.items())
assert all(lower[h]<=X[h]<=upper[h] for h in lower)
assert list(sorted(X))==list(range(4,83,2))
def is_prime(n):
    return n>1 and all(n%d for d in range(2,int(n**0.5)+1))
modpattern={h: v%4 for h,v in X.items() if h>=6}
assert all(r==(2 if h==8 or is_prime(h//2) else 0) for h,r in modpattern.items())
print('OBSERVATION ONLY: modulo-four pattern holds for tested h=6..82; not proved in general')
print('PASS: two distinct integer counters agree for all 40 even h=4..82')
print('PASS: paper exact h=4..46 and Table 2 bounds h=48..64 match')
print('CHECKSUM: h64=',X[64],'h82=',X[82])
