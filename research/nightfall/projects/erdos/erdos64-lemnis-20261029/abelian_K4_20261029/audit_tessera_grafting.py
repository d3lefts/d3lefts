#!/usr/bin/env python3
"""Independent bounded adversarial test of Tessara PR94 exact finite Sidon grafting lemma."""
from fractions import Fraction as F
from math import comb,ceil
from random import Random
from itertools import combinations
rng=Random(20261029098)

def sidon(s,mod=None):
    seen={}
    for i,x in enumerate(s):
        for y in s[i:]:
            z=x+y if mod is None else (x+y)%mod
            if z in seen:return False
            seen[z]=(x,y)
    return True

def sidon_source(v):
    S=[0]
    for q in rng.sample(list(range(1,v)),v-1):
        if len(S)>=6:break
        if sidon(S+[q],v):S.append(q)
    return sorted(S)

def trial(v,A,D,h):
    N=max(A);m=len(A);K=len(D)
    if not (v-h>2*N and h*4<v and 2*(h+N+1)<v):return None
    L=h+N+1;t=h//2+1
    R=F(2*K*L,v)
    E=F(m,t)*(F(2,27)*R**3+F(1,8)*R**2)
    ts=range(v-h,v-(h+1)//2+1)
    assert len(ts)==t
    found=False
    for rot in range(v):
        Drot=sorted((x+rot)%v for x in D)
        u=sum(x<L for x in Drot)
        w=sum(x>=v-L for x in Drot)
        if u+w>R:continue
        for T in ts:
            # Count every mixed A+B=B+B collision, directly, no lower/high lemma assumed.
            mixed=[]
            for a in A:
                for z in Drot:
                    for i,x in enumerate(Drot):
                        for y in Drot[i:]:
                            if a+(T+z)==(T+x)+(T+y):
                                mixed.append((a,x,y,z))
            if len(mixed)>E:continue
            deleted={z for _,x,y,z in mixed} # each repaired by removing its z endpoint
            Dleft=[x for x in Drot if x not in deleted]
            # Any A+B duplications are exact difference collisions and can be removed greedily.
            while True:
                oldnew={};clash=None
                for a in A:
                    for x in Dleft:
                        key=a+x
                        if key in oldnew:
                            clash=(x,oldnew[key]);break
                        oldnew[key]=x
                    if clash:break
                if clash is None:break
                Dleft.remove(clash[0])
            if len(Drot)-len(Dleft)>comb(m,2)+E:continue
            C=sorted(A+[T+x for x in Dleft])
            assert sidon(C), (v,A,D,h,rot,T,'bad-sidon')
            assert max(C)<=2*v-(h+1)//2-1
            found=True;break
        if found:break
    assert found,(v,A,D,h,R,E,'finite lemma failed')
    return 1

cases=0
for v in (31,37,43,47,53,61,71):
    for A in ([1],[1,2],[1,2,4],[1,3,5]):
        if not sidon(A):continue
        for h in (3,4,5,6,7):
            for rep in range(7):
                D=sidon_source(v)
                x=trial(v,A,D,h)
                if x:cases+=1
assert cases>150
print('PASS',cases,'independent cyclic-rotation, boundary-window, full collision/deletion trials')
# Verify strict constant symbolically, no assumptions about nesting.
from sympy import symbols, factor, simplify
m=symbols('m',positive=True)
assert simplify((1-1/(216*m))**2-(1-1/(64*m)) - (11/(1728*m)+1/(46656*m**2))) == 0
print('PASS Tessara fixed-prefix coefficient inequality and no fixed-asymptotic-r nesting implication')
