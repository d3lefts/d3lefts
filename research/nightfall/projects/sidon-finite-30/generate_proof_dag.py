#!/usr/bin/env python3
"""Build independently verifiable finite proof DAG for 30-element Sidon witness."""
import json
from itertools import combinations
from pathlib import Path
A=[int(x) for x in Path(__file__).with_name('witness_30.txt').read_text().strip().split(',')]
assert len(A)==30 and sorted(set(A))==A
edges=[sum(1<<i for i in e) for e in combinations(range(30),3) if A[e[0]]+A[e[2]]==2*A[e[1]]]
assert len(edges)==28
nodes={}; calls=0
def pack(unhit):
    occupied=0;out=[]
    for mask in unhit:
        if mask&occupied==0: occupied|=mask;out.append(mask)
    return out
def prove(deleted,budget):
    global calls
    calls+=1
    key=f'{deleted}:{budget}'
    if key in nodes:return key
    unhit=[e for e in edges if not(e&deleted)]
    if not unhit:raise AssertionError('Uncovered Sidon-18 deletion case')
    p=pack(unhit)
    if len(p)>budget:
        nodes[key]={'kind':'packing','deleted':deleted,'budget':budget,'packing':p}
        return key
    degrees=[sum(bool(e&(1<<i)) for e in unhit) for i in range(30)]
    chosen=max(unhit,key=lambda e:sum(degrees[i] for i in range(30) if e&(1<<i)))
    children=[prove(deleted|(1<<i),budget-1) for i in range(30) if chosen&(1<<i)]
    assert len(children)==3
    nodes[key]={'kind':'branch','deleted':deleted,'budget':budget,'edge':chosen,'children':children}
    return key
root=prove(0,12)
data={'format':'NIGHTFALL-SIDON-UNSAT-DAG-v1','n':30,'target_deletions':12,'root':root,'nodes':nodes}
out=Path(__file__).with_name('sidon_no_18_proof.json')
out.write_text(json.dumps(data,separators=(',',':'),sort_keys=True)+'\n')
print(json.dumps({'nodes':len(nodes),'calls':calls,'bytes':out.stat().st_size,'max_depth':13,'root':root},indent=2))
