#!/usr/bin/env python3
"""Independent vertex-coordinate Q6 translation group-law / C4 test.

No reuse of C++ edge translation mapping, matching or candidate checker.
"""
from __future__ import annotations
import sys
from pathlib import Path
from collections import Counter

sys.path.insert(0,str(Path(__file__).resolve().parent))
from matching import source_faces, E6, S6

edge_set={tuple(sorted((u,v))) for u,v,d in E6}
assert len(edge_set)==192
squares=[]
for v in range(64):
    for a in range(6):
        if v&(1<<a):continue
        for b in range(a+1,6):
            if v&(1<<b):continue
            va=v|(1<<a);vb=v|(1<<b);vab=va|(1<<b)
            squares.append({tuple(sorted((v,va))),tuple(sorted((v,vb))),
                            tuple(sorted((va,vab))),tuple(sorted((vb,vab)))})
assert len(squares)==240
def tr(e,t):
    a,b=e
    return tuple(sorted((a^t,b^t)))
for t in range(64):
    assert {tr(e,t) for e in edge_set}==edge_set
    for u in range(64):
        # Independent algebraic action (Z/2)^6
        assert all(tr(tr(e,t),u)==tr(e,t^u) for e in edge_set)

faces=source_faces()
assert len(faces)==373
tested=0
for idx in range(0,373,11):
    face=faces[idx]
    baseline={tuple(sorted(E6[e][:2])) for e in face["ids"]}
    assert len(baseline)==face["count"]
    for t in range(64):
        out={tr(e,t) for e in baseline}
        assert len(out)==len(baseline)
        assert all(len(sq&out)<=3 for sq in squares),"Translation created a Q6 four-cycle"
        tested+=1

# Count-preserving adversarial corruption: three-occupied square + an absent
# fourth edge; delete a selected edge outside the square.
face=faces[0]
baseline={tuple(sorted(E6[e][:2])) for e in face["ids"]}
invalid=None
for sq in squares:
    if len(sq&baseline)==3:
        new=next(iter(sq-baseline))
        old=next(e for e in baseline if e not in sq)
        trial=(baseline-{old})|{new}
        if any(len(q&trial)==4 for q in squares):
            invalid=trial
            break
assert invalid is not None and len(invalid)==len(baseline)
assert any(len(sq&invalid)==4 for sq in squares)
print("PASS: 4096 translation group compositions on 192 cube edges; "+
      str(tested)+" independently translated high Q6 faces preserve cardinality/C4; "+
      "count-preserving invalid C4 face rejected.")
