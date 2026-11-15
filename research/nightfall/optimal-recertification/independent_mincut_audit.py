#!/usr/bin/env python3
"""Independent stdlib-only exact check: two-stage recertification setup mincut.
This checks finite instances; the general result is proved in the companion note.
"""
from itertools import product
from random import Random
from fractions import Fraction

SEED=20261115

def priced_plan(selected, no, costs, ofacs, gfacs):
    price=sum(costs[i] for i in selected)
    price+=sum(w for indices,w in ofacs if any(i in selected for i in indices))
    price+=sum(w for indices,w in gfacs if any(no+i in selected for i in indices))
    return price

def brute_plan(no, ng, edges, costs, ofacs, gfacs):
    best=None
    for flags in product((False,True),repeat=no+ng):
        chosen={i for i,x in enumerate(flags) if x}
        if any(o not in chosen and no+g not in chosen for o,g in edges):
            continue
        val=priced_plan(chosen,no,costs,ofacs,gfacs)
        if best is None or val<best:best=val
    return best

def brute_cut(no,ng,edges,costs,ofacs,gfacs):
    big=sum(costs)+sum(w for _,w in ofacs)+sum(w for _,w in gfacs)+1
    ob=[("o",i) for i in range(no)]
    gu=[("g",i) for i in range(ng)]
    ofs=[("of",i) for i in range(len(ofacs))]
    gfs=[("gf",i) for i in range(len(gfacs))]
    nodes=ob+gu+ofs+gfs
    arcs=[]
    arcs.extend((("s",0),ob[i],costs[i]) for i in range(no))
    arcs.extend((gu[i],("t",0),costs[no+i]) for i in range(ng))
    arcs.extend((ob[i],gu[j],big) for i,j in edges)
    for k,(members,w) in enumerate(ofacs):
        arcs.append((("s",0),ofs[k],w))
        arcs.extend((ofs[k],ob[i],big) for i in members)
    for k,(members,w) in enumerate(gfacs):
        arcs.append((gfs[k],("t",0),w))
        arcs.extend((gu[i],gfs[k],big) for i in members)
    best=None
    for bits in product((0,1),repeat=len(nodes)):
        side=dict(zip(nodes,bits))
        side[("s",0)]=0
        side[("t",0)]=1
        val=sum(c for a,b,c in arcs if side[a]==0 and side[b]==1)
        if best is None or val<best:best=val
    return best

def run():
    r=Random(SEED);cases=0
    for no in range(1,4):
        for ng in range(1,4):
            for _ in range(25):
                edges={(i,j) for i in range(no) for j in range(ng)
                       if r.randrange(2)}
                costs=[r.randrange(1,9) for _ in range(no+ng)]
                ofacs=[({i for i in range(no) if r.randrange(2)},r.randrange(1,9))
                       for _ in range(r.randrange(3))]
                gfacs=[({i for i in range(ng) if r.randrange(2)},r.randrange(1,9))
                       for _ in range(r.randrange(3))]
                a=brute_plan(no,ng,edges,costs,ofacs,gfacs)
                b=brute_cut(no,ng,edges,costs,ofacs,gfacs)
                assert a==b,(no,ng,edges,costs,ofacs,gfacs,a,b)
                cases+=1
    # An exact Bayesian risk non-monotonicity witness.
    prior=Fraction(1,11)
    after=Fraction(1,2)
    assert after>prior and prior<Fraction(1,10)<after
    # Cost-2 mixed observation/version-guard example from the paper.
    assert brute_plan(2,2,{(0,0),(0,1),(1,1)},[1,9,8,1],[],[])==2
    print("PASS",cases,"exact independently enumerated setup-cut equivalences;",
          "Bayesian risk increase",prior,"to",after)
if __name__=="__main__":run()
