#!/usr/bin/env python3
"""Independent Q7 305 candidate verifier, no import of face-join or matching code."""
from __future__ import annotations
import hashlib
import pathlib
import sys
from collections import Counter

def verify(path: pathlib.Path,minimum: int=305):
    data=path.read_bytes()
    pairs=[]
    for ln,line in enumerate(data.decode("ascii").splitlines(),1):
        v,w=map(int,line.split())
        assert 0<=v<w<128 and (v^w).bit_count()==1,(ln,line)
        pairs.append((v,w))
    edges=set(pairs)
    assert len(edges)==len(pairs),"Repeated selected edge"
    assert len(edges)>=minimum,(len(edges),minimum)
    squares=0
    for v in range(128):
        for a in range(7):
            if (v>>a)&1:continue
            for b in range(a+1,7):
                if (v>>b)&1:continue
                va=v|(1<<a);vb=v|(1<<b);vab=va|(1<<b)
                squares+=1
                assert sum(e in edges for e in ((v,va),(v,vb),(va,vab),(vb,vab)))<=3,(v,a,b)
    assert squares==672
    nbs=[set() for _ in range(128)]
    for v,w in edges:
        nbs[v].add(w);nbs[w].add(v)
    two_paths=0
    for v in range(128):
        for w in range(v+1,128):
            if (v^w).bit_count()!=2:continue
            two_paths+=1
            assert len(nbs[v]&nbs[w])<=1,(v,w)
    assert two_paths==1344
    hist=Counter(len(nbs[v]) for v in range(128))
    print({"status":"EXACT_C4_FREE_CANDIDATE","edges":len(edges),
           "vertices":128,"potentialEdges":448,"squares":squares,
           "lengthTwoPairsChecked":two_paths,
           "edgeListSha256":hashlib.sha256(data).hexdigest(),
           "degreeHistogram":dict(sorted(hist.items()))})

if __name__=="__main__":
    try:
        assert len(sys.argv)==2
        verify(pathlib.Path(sys.argv[1]))
    except (ValueError,AssertionError,FileNotFoundError) as e:
        print("CANDIDATE_REJECTED",str(e),file=sys.stderr)
        sys.exit(2)
