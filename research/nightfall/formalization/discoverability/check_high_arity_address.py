#!/usr/bin/env python3
"""Exact heterogeneous-alphabet addressing: N-valued address and N bit sensors.
The target is the data bit selected by the address. Count each sensor as one
query; this is NOT a constant-bit communication bound.
"""
from itertools import product
from functools import lru_cache
import json

def run(N):
    states=tuple((k,b) for k in range(N) for b in product((0,1),repeat=N))
    m=N+1
    def observation(x,i):
        return x[0] if i==0 else x[1][i-1]
    def target(x):
        return x[1][x[0]]
    @lru_cache(None)
    def decision(fiber,used):
        if len({target(states[z]) for z in fiber})<=1:return 0
        return min(1+max(decision(tuple(z for z in fiber if observation(states[z],i)==a),
                           used|(1<<i))
                         for a in {observation(states[z],i) for z in fiber})
                   for i in range(m) if not(used>>i&1))
    D=decision(tuple(range(len(states))),0)
    nonadaptive=m+1
    for mask in range(1<<m):
        groups={}
        valid=True
        for x in states:
            key=tuple(observation(x,i) for i in range(m) if mask>>i&1)
            if key in groups and groups[key]!=target(x):
                valid=False;break
            groups[key]=target(x)
        if valid:nonadaptive=min(nonadaptive,mask.bit_count())
    assert D==2,(N,D)
    assert nonadaptive==N+1,(N,nonadaptive)
    return {"adaptive":D,"nonadaptive":nonadaptive,"states":len(states)}

out={N:run(N) for N in range(2,6)}
print(json.dumps({"status":"PASS","cases":out,
                 "note":"N-ary address counts as one sensor; bit-cost is not constant"},indent=2))
