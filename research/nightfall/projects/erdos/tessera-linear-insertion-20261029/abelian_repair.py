#!/usr/bin/env python3
"""Exact single-element Sidon repair over arbitrary finite abelian groups.

After constructing the O(K^2) difference dictionary, min-plus repair takes O(K)
group/dictionary operations. Optional direct audit costs O(K^2).
"""
from itertools import combinations, product
from collections import deque
from math import gcd

INF=10**9
def add(a,b,mod): return tuple((x+y)%n for x,y,n in zip(a,b,mod))
def sub(a,b,mod): return tuple((x-y)%n for x,y,n in zip(a,b,mod))

def sidon(D,mod):
    sums=set()
    for i,x in enumerate(D):
        for y in D[i:]:
            s=add(x,y,mod)
            if s in sums:return False
            sums.add(s)
    return True

def difference_table(D,mod):
    if not sidon(D,mod):raise ValueError("D must be Sidon")
    lookup={}
    for y in D:
        for z in D:
            if y!=z:
                delta=sub(y,z,mod)
                assert delta not in lookup
                lookup[delta]=(y,z)
    return lookup

def exact_repair(D,a,mod,lookup=None,verify=False):
    D=tuple(D);nD=len(D);source=set(D)
    if a in source:raise ValueError("a already belongs to D")
    if lookup is None:lookup=difference_table(D,mod)
    f={};z_of={}
    for x in D:
        witness=lookup.get(sub(a,x,mod))
        if witness is not None:
            y,z=witness
            assert add(x,y,mod)==add(a,z,mod)
            f[x]=y;z_of[x]=z
    assert all(f[f[x]]==x and z_of[f[x]]==z_of[x] for x in f)
    groups=[];gof={};active=[]
    for x in D:
        if x not in gof:
            P=tuple(sorted({x,f[x]})) if x in f else (x,)
            for y in P:gof[y]=len(groups)
            groups.append(P);active.append(x in f)
    n=len(groups)
    target=[None]*n;bit=[0]*n;thirds=[]
    for i,P in enumerate(groups):
        if active[i]:
            z=z_of[P[0]]
            assert z not in P
            j=gof[z];target[i]=j
            bit[i]=1<<groups[j].index(z)
            thirds.append(z)
    assert len(thirds)==len(set(thirds))
    incoming=[[] for _ in range(n)];degree=[0]*n
    for i,j in enumerate(target):
        if j is not None:
            incoming[j].append(i);degree[j]+=1
    assert max(degree,default=0)<=2
    todo=deque(i for i in range(n) if degree[i]==0);peeled=[]
    while todo:
        i=todo.popleft();peeled.append(i)
        j=target[i]
        if j is not None:
            degree[j]-=1
            if degree[j]==0:todo.append(j)
    cyclic={i for i in range(n) if degree[i]>0}
    cycles=[];seen=set()
    for i in cyclic:
        if i not in seen:
            C=[];j=i
            while j not in seen:
                seen.add(j);C.append(j);j=target[j]
            assert j==i
            cycles.append(C)
    # The sole potential collision 2a=x+y has at most one unordered D pair.
    tw=add(a,a,mod)
    idx={x:i for i,x in enumerate(D)}
    diagonal=next(((x,y) for x in D
                    if (y:=sub(tw,x,mod)) in source and idx[x]<=idx[y]),None)
    # Branching forces deletion of one of those two endpoints, if present.
    forced=diagonal if diagonal else (None,)

    def evaluate(required):
        opts=[];dp=[];pick=[]
        for P in groups:
            allowed=[s for s in range(1<<len(P))
                     if required not in P or s & (1<<P.index(required))]
            opts.append(allowed)
            dp.append([INF]*(1<<len(P)))
            pick.append([{} for _ in range(1<<len(P))])
        def compute(i):
            for s in opts[i]:
                value=s.bit_count();choices={}
                for child in incoming[i]:
                    if child in cyclic:continue
                    possibilities=[(dp[child][t],t) for t in opts[child]
                                   if t or s&bit[child]]
                    if not possibilities:value=INF;break
                    cost,t=min(possibilities)
                    value+=cost;choices[child]=t
                dp[i][s]=value;pick[i][s]=choices
        for i in peeled:compute(i)
        for i in cyclic:compute(i)
        states={};total=0
        def descend(i):
            for child,s in pick[i][states[i]].items():
                assert child not in states
                states[child]=s;descend(child)
        # Tree components terminate at a node with no outgoing arc.
        for root in (i for i in peeled if target[i] is None):
            s=min(opts[root],key=lambda t:dp[root][t])
            states[root]=s;total+=dp[root][s];descend(root)
        # Each remaining component has exactly one directed cycle.
        for C in cycles:
            best=(INF,None)
            for s0 in opts[C[0]]:
                frontier={s0:(dp[C[0]][s0],[s0])}
                for k in range(1,len(C)):
                    previous=C[k-1];node=C[k];new={}
                    for sn in opts[node]:
                        vals=[(val+dp[node][sn],path+[sn])
                              for sp,(val,path) in frontier.items()
                              if sp or sn&bit[previous]]
                        if vals:new[sn]=min(vals)
                    frontier=new
                vals=[pair for s,pair in frontier.items()
                      if s or s0&bit[C[-1]]]
                if vals:
                    candidate=min(vals)
                    if candidate[0]<best[0]:best=candidate
            assert best[1] is not None
            total+=best[0]
            for i,s in zip(C,best[1]):states[i]=s
            for i in C:descend(i)
        assert len(states)==n
        removed=tuple(sorted(x for i,P in enumerate(groups)
                             for j,x in enumerate(P) if states[i]&(1<<j)))
        assert len(removed)==total
        if verify:
            remains=[x for x in D if x not in set(removed)]+[a]
            assert sidon(remains,mod)
        return total,removed

    minimum,R=min((evaluate(mark) for mark in forced),key=lambda item:item[0])
    return minimum,R,{"source_size":nD,"orbits":n,
                       "components":len(cycles),
                       "rooted_trees":sum(t is None for t in target),
                       "diagonal_collision":diagonal is not None}

def brute_force(D,a,mod):
    for k in range(len(D)+1):
        for removed in combinations(D,k):
            S=set(removed)
            if sidon([x for x in D if x not in S]+[a],mod):
                return k,removed
    raise AssertionError("no feasible repair")

def run_audit():
    mods=[(5,),(7,),(8,),(9,),(13,),(3,3),(2,5),(3,4),(4,4),(2,2,3)]
    counts={};diagonal_count=0
    for mod in mods:
        group=list(product(*[range(m) for m in mod]))
        count=0
        for k in range(1,min(5,len(group))+1):
            for D in combinations(group,k):
                if not sidon(D,mod):continue
                lookup=difference_table(D,mod)
                for a in group:
                    if a in D:continue
                    value,R,stats=exact_repair(D,a,mod,lookup,verify=True)
                    assert value==brute_force(D,a,mod)[0],(mod,D,a)
                    diagonal_count+=stats["diagonal_collision"]
                    count+=1
        counts[str(mod)]=count
    assert sum(counts.values())==14509
    assert diagonal_count==7083
    try:
        difference_table(((0,0),(1,0)),(2,3))
        raise AssertionError("Invalid torsion input accepted")
    except ValueError:pass
    print("PASS",sum(counts.values()),"independent exhaustive insertion cases")
    print("PASS",diagonal_count,"cases involving 2a collision")
    print("COUNTS",counts)

if __name__=="__main__":run_audit()
