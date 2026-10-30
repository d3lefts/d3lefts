#!/usr/bin/env python3
"""Adversarial test of #91 against separately implemented direct sum oracle."""
import json
from itertools import combinations
from build_difference_sat import CNF
from independent_oracle import classify

def main():
    checked=0;maximal=0
    for N in range(5,13):
        for k in range(2,min(N,5)):
            cnf=CNF().build(N,k)
            for cand in combinations(range(1,N+1),k):
                from_oracle=classify(cand,N)
                valid=not cnf.test(cand)
                expected=from_oracle['saturated']
                assert valid==expected,(N,k,cand,from_oracle,cnf.test(cand)[:3])
                checked+=1;maximal+=valid
    print('PASS small exhaustive canonical assignment',json.dumps({'sets':checked,'saturated':maximal}))
    h=(8,48,68,69,71,75,104,120)
    f=CNF().build(144,8)
    assert not f.test(h);assert classify(h,144)['saturated']
    print('PASS Huber N144: ',len(f.keys)-1,'vars',len(f.clauses),'clauses')
    ten_cases=((16,49,50,56,78,93,104,125,139,149),
               (49,50,56,78,93,104,125,139,149,166))
    model=CNF().build(184,10)
    model9=CNF().build(184,9)
    for A in ten_cases:
        assert len(A)==10 and not model.test(A) and classify(A,184)['saturated']
        print('PASS ten-mark N184:',A)
        for a in A:
            nine=tuple(x for x in A if x!=a)
            cs=classify(nine,184)
            assert cs['sidon'] and cs['holes'] and model9.test(nine)
            print('  deleting',a,'opens',len(cs['holes']),'holes, first:',cs['holes'][:12])
    bad=(49,50,56,78,93,104,125,139,149)
    b=classify(bad,184)
    assert b['holes']==[16,166]
    # Negative mutation: force one chosen mark into an existing pair-sum conflict.
    assert not classify((*bad,16,166),184)['sidon']
    print('PASS 2-hole predecessor and mutation; full model and oracle agree')

if __name__=='__main__':main()
