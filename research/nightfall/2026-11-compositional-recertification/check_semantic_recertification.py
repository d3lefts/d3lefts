#!/usr/bin/env python3
"""NIGHTFALL v0.2 smoke checker: source-semantic exact and fractional certificate costs.
Python standard library. This independently executable subset of the full v0.2 audit
does not establish physical safety, Lean certification, or theorem originality.
"""
from itertools import product, combinations
from fractions import Fraction as F
import json

def unsafe(k,q):
    return [frozenset(i for i,b in enumerate(x) if b)
            for x in product((0,1),repeat=k) if sum(x)>=q]

def exact_cover(faults,costs):
    n=len(costs)
    best=None
    for bits in product((0,1),repeat=n):
        s={i for i,b in enumerate(bits) if b}
        if all(s&f for f in faults):
            cost=sum(costs[i] for i in s)
            if best is None or cost<best: best=cost
    return best

def noisy_primal_dual(k,q):
    # Every q-subset of k is minimally unsafe, with unit c/d cost.
    fs=list(combinations(range(k),q))
    x=[F(1,q)]*k
    assert all(sum(x[i] for i in f)>=1 for f in fs)
    y=F(1,len([f for f in fs if 0 in f]))
    assert all(sum(y for f in fs if i in f)<=1 for i in range(k))
    assert sum(x)==len(fs)*y==F(k,q)
    return str(sum(x))

def gate_eval(t,x):
    if isinstance(t,int):return bool(x[t])
    q,children=t
    return sum(gate_eval(child,x) for child in children)>=q

def tree_price(t,c,cache):
    if isinstance(t,int):return 0 if t in cache else c[t]
    q,children=t
    return sum(sorted(tree_price(child,c,cache) for child in children)[:len(children)-q+1])

def tree_brute(t,c,cache):
    n=len(c)
    alts=[]
    for x in product((0,1),repeat=n):
        if all(x[i]==0 for i in cache) and gate_eval(t,x):
            alts.append({i for i,b in enumerate(x) if b and i not in cache})
    free=[i for i in range(n) if i not in cache]
    best=None
    for bits in product((0,1),repeat=len(free)):
        selected={i for i,b in zip(free,bits) if b}
        if all(selected&f for f in alts):
            cost=sum(c[i] for i in selected)
            if best is None or cost<best:best=cost
    return best

def run():
    gates=0
    for k in range(2,10):
        for q in range(1,k+1):
            fs=unsafe(k,q)
            assert exact_cover(fs,[1]*k)==k-q+1
            assert noisy_primal_dual(k,q)==str(F(k,q))
            gates+=1
    examples=[
        ((2,(0,1,2)), {0:1,1:1,2:1},set()),
        ((2,(0,1,2)), {0:1,1:1,2:1},{0}),
        ((2,(0,1,2)), {0:1,1:1,2:1},{0,1}),
        ((1,((2,(0,1)),(2,(2,3)))), {0:2,1:3,2:5,3:7},set()),
        ((2,((1,(0,1)),2,3)), {0:2,1:3,2:5,3:7},{0})
    ]
    for t,c,cache in examples:
        assert tree_price(t,c,cache)==tree_brute(t,c,cache)
    shared=(1,(0,0))
    assert tree_price(shared,{0:1},set())==2
    assert tree_brute(shared,{0:1},set())==1
    out={'status':'PASS','threshold_families':gates,'tree_cases':len(examples),
         'shared_input_counterexample':True,'noisy_fractional_example_2_of_3':'3/2',
         'status_limit':'Finite state/LP checks only; no physical deployment, Lean proof or external referee.'}
    print(json.dumps(out,sort_keys=True,indent=2))
    return out

if __name__=='__main__':run()
