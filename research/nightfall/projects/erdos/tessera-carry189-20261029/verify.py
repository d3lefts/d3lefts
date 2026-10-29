#!/usr/bin/env python3
"""Exact Singer modular-collision conservation and integer carry audit.
Standard library only. Records finite witnesses and explicit negative controls.
"""
from collections import defaultdict
from math import ceil
from hashlib import sha256

SOURCES={
 31:(0,1,3,8,12,18),
 57:(0,7,16,21,22,24,34,53),
 651:(21,72,81,86,88,105,197,217,247,278,316,334,357,360,
      368,405,430,434,440,462,483,498,525,537,538,584)
}
PREFIX={31:(1,2,4),57:(1,2,4,8,13),651:(1,2,4,8,13)}
H={31:3,57:9,651:80}

def modular_perfect(D,v):
    differences=set()
    for x in D:
        for y in D:
            if x==y:continue
            delta=(x-y)%v
            assert delta not in differences
            differences.add(delta)
    assert len(D)*(len(D)-1)==v-1
    assert len(differences)==v-1

def integer_sidon(S):
    sums=set()
    for i,x in enumerate(S):
        for y in S[i:]:
            if x+y in sums:return False
            sums.add(x+y)
    return True

def carry_profile(Q,v,a,T,lookup):
    residue=(a-T)%v
    if residue in Q:return None
    hist=[0,0,0]
    for x in Q:
        y,z=lookup[(residue-x)%v]
        assert (x+y-z)%v==residue
        assert z!=x and z!=y
        carry=x+y-z-(a-T)
        assert carry in (0,v,2*v)
        hist[carry//v]+=1
    assert sum(hist)==len(Q)
    return hist

def all_integer_collisions(A,Q,T):
    values=A+tuple(T+x for x in Q);m=len(A)
    representations=defaultdict(list)
    for i,x in enumerate(values):
        for j in range(i,len(values)):
            representations[x+values[j]].append((i,j))
    labels=defaultdict(int);hyperedges=set()
    for reps in representations.values():
        for i,(x,y) in enumerate(reps):
            for a,b in reps[i+1:]:
                def kind(s,t):
                    return 'AA' if t<m else 'AB' if s<m else 'BB'
                label='-'.join(sorted((kind(x,y),kind(a,b))))
                labels[label]+=1
                e=frozenset(t-m for t in (x,y,a,b) if t>=m)
                assert e
                hyperedges.add(e)
    assert set(labels)<= {'AB-BB','AB-AB'}
    return dict(labels),hyperedges

def greedy_repair(A,Q,T,hyperedges):
    removed=set()
    for edge in sorted(hyperedges,key=lambda e:(len(e),tuple(sorted(e)))):
        if not edge & removed:removed.add(min(edge))
    survivors=sorted(A+tuple(T+x for i,x in enumerate(Q)
                             if i not in removed))
    assert integer_sidon(survivors)
    return removed,survivors

def best_cut(v,D,A,h):
    assert integer_sidon(list(A))
    N=max(A)
    assert 0<h<v and v-h>2*N and 2*(h+N+1)<v
    valid=0;invalid=0;best=None
    for cut in range(v):
        Q=tuple(sorted((d+cut)%v for d in D))
        lookup={}
        for y in Q:
            for z in Q:
                if y!=z:
                    delta=(y-z)%v
                    assert delta not in lookup
                    lookup[delta]=(y,z)
        for T in range(v-h,v-(h+1)//2+1):
            hist=[]
            for a in A:
                carry=carry_profile(Q,v,a,T,lookup)
                if carry is None:
                    invalid+=1
                    break
                hist.append(carry)
            if len(hist)!=len(A):continue
            valid+=1
            cost=sum(z[0] for z in hist)
            if best is None or cost<best[0]:
                best=(cost,cut,T,hist,Q)
    return valid,invalid,best

def run():
    for v,D in SOURCES.items():
        modular_perfect(D,v)
        A=PREFIX[v];K=len(D)
        valid,invalid,best=best_cut(v,D,A,H[v])
        score,cut,T,carry,Q=best
        assert all(sum(row)==K for row in carry)
        assert sum(sum(row) for row in carry)==len(A)*K
        labels,hyperedges=all_integer_collisions(A,Q,T)
        R,final=greedy_repair(A,Q,T,hyperedges)
        assert score==0
        assert not integer_sidon(list(A)+[T+x for x in Q]), "AB/AB omission control"
        if v==31:
            assert (valid,invalid,cut,T,len(hyperedges),len(R),len(final))==(30,32,0,28,3,2,7)
        if v==57:
            assert (valid,invalid,cut,T,len(hyperedges),len(R),len(final))==(130,155,1,52,8,5,8)
        if v==651:
            assert (valid,invalid,cut,T,len(hyperedges),len(R),len(final))==(21771,4920,0,575,10,8,23)
        print("PASS",v,K,"prefix",len(A),"cyclic-events",len(A)*K,
              "integer-carry0",score,"tested",valid,"rejected",invalid,
              "cut",cut,"T",T,"AB/AB",labels.get("AB-AB",0),
              "repair",len(R),"size",len(final),"max",max(final))
    v=651;D=SOURCES[v];A=(1,23,70,150,200)
    valid,invalid,best=best_cut(v,D,A,80)
    score,cut,T,carry,Q=best
    labels,edges=all_integer_collisions(A,Q,T)
    R,final=greedy_repair(A,Q,T,edges)
    wrapped=set();collisions=0
    for i,x in enumerate(final):
        for y in final[i:]:
            residue=(x+y)%v
            if residue in wrapped:collisions+=1
            else:wrapped.add(residue)
    assert (valid,invalid,score,cut,T,len(R),len(final),collisions)==(
        21771,4920,0,0,583,8,23,26)
    assert sorted(R)==[6,8,9,11,13,14,18,23]
    assert len(final)*(len(final)+1)//2==276
    source_hash=sha256(('\n'.join(map(str,Q))+'\n').encode()).hexdigest()
    witness_hash=sha256(('\n'.join(map(str,final))+'\n').encode()).hexdigest()
    assert source_hash=='2867af0c52dde5eda18654f69ac00f55cc3e241d7abba9f4cdf123f5b922f74c'
    assert witness_hash=='feb60c46538147823f59d57f0cc868c40a1b7deab3256ede8a9e2f02c57980dd'
    assert not integer_sidon(list(A)+[T+x for x in Q])
    print("PASS witness SHA256",witness_hash)
    print("PASS adverse prefix",A,"cyclic-events",len(A)*len(D),
          "carry0",score,"AB/AB",labels.get("AB-AB",0),
          "repaired",len(final),"wrapped-sum-collisions",collisions)
    print("PASS negative controls: ignoring AB/AB fails; integer repairs lose modular closure")

if __name__=="__main__":run()
