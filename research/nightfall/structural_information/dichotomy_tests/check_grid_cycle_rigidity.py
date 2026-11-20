#!/usr/bin/env python3
"""Exact finite checker: grid-cycle frame rigidity and tree stretch.
Regression/falsifier only; not a proof of the universal theorem.
"""
from itertools import combinations
from random import Random
from collections import Counter
counts=Counter()
def ck(k,v):
    counts[k]+=1
    assert v,(k,counts[k])
def rank(xs):
    piv={}
    for v in xs:
        while v:
            p=v.bit_length()-1
            if p in piv: v^=piv[p]
            else: piv[p]=v;break
    return len(piv)
def xor(xs):
    v=0
    for x in xs:v^=x
    return v
def grid(h,w):
    edges=[]; emap={}
    for y in range(h):
        for x in range(w):
            u=y*w+x
            if x+1<w:
                v=u+1;emap[(u,v)]=len(edges);edges.append((u,v))
            if y+1<h:
                v=u+w;emap[(u,v)]=len(edges);edges.append((u,v))
    R=[(1<<u)^(1<<v) for u,v in edges]
    faces=[]
    for y in range(h-1):
        for x in range(w-1):
            u=y*w+x;v=u+1;z=u+w;t=z+1
            f=0
            for a,b in ((u,v),(v,t),(z,t),(u,z)):f^=1<<emap[(min(a,b),max(a,b))]
            faces.append(f)
    return edges,R,faces
def reachable(xs):
    """All representable XORs and their exact minimal word weights."""
    out={0:0}
    for b in xs:
        for x,k in list(out.items()):
            z=x^b
            if z not in out or k+1<out[z]:out[z]=k+1
    return out
def min_dep(xs):
    if len(xs)==rank(xs):return float('inf')
    for k in range(1,len(xs)+1):
        if any(xor(sub)==0 for sub in combinations(xs,k)):return k
    raise AssertionError('unresolved dependency')
def check_grid(h,w):
    E,R,F=grid(h,w)
    ck('grid_incidence_rank',rank(R)==h*w-1)
    ck('square_cycles_span',rank(F)==len(E)-(h*w-1)==(h-1)*(w-1))
    for face in F:
        ck('face_exact_four',face.bit_count()==4)
        ck('face_is_kernel',xor(R[i] for i in range(len(E)) if face>>i&1)==0)
    return E,R,F
def frame(R,B,ell):
    a=reachable(R);b=reachable(B)
    if not B or any(r not in b for r in R) or any(v not in a for v in B):return None
    c=max(b[r] for r in R);cp=max(a[v] for v in B);dep=min_dep(B)
    if dep>max(ell*c,c*cp+1):
        ck('nonvacuous_rigidity_gate',len(B)==rank(B))
    return c,cp,dep
def exact_tree_stretch(h,w):
    E,R,_=check_grid(h,w)
    trials=0;best=float('inf');n=h*w
    for ids in combinations(range(len(E)),n-1):
        B=[R[i] for i in ids]
        if rank(B)!=n-1:continue
        trials+=1;dist=reachable(B)
        c=max(dist[e] for e in R)
        best=min(best,c)
    return best,trials
def run():
    rng=Random(20261119)
    candidates=0
    for h,w in ((2,2),(2,3),(3,3)):
        E,R,_=check_grid(h,w)
        rk=h*w-1
        for mask in range(1<<len(R)):
            B=[b for i,b in enumerate(R) if mask>>i&1]
            result=frame(R,B,4)
            if result is None:continue
            candidates+=1
            c,cp,dep=result
            ck('original_row_frame_cp1',cp==1)
            ck('spanning_frame_rank',rank(B)==rk)
            if dep>max(4*c,c*cp+1):
                ck('original_row_tree',len(B)==rk)
        # Independently try redundant short-sum generators with reverse cost >1.
        pool=[v for v,k in reachable(R).items() if v and k<=3]
        for trial in range(900):
            B=rng.sample(pool,rng.randrange(1,min(len(pool),10)+1))
            result=frame(R,B,4)
            if result is not None:
                candidates+=1
                ck('short_sum_frame_span',rank(B)==rk)
    cycle6=[(1<<i)^(1<<((i+1)%6)) for i in range(6)]
    ck('first_gate_negative',min_dep(cycle6)==6 and
       frame(cycle6,cycle6,6)==(1,1,6))
    R=[1,2,4];B=[1,2,4,7]
    ck('second_gate_negative',frame(R,B,0)==(1,3,4))
    for h,w in ((2,3),(3,3),(3,4)):
        _,R,_=grid(h,w)
        for k in range(1,5):
            for sub in combinations(R,k):
                ck('short_sum_weight',xor(sub).bit_count()<=2*k)
    ts=[]
    for h,w in ((2,2),(2,3),(3,3)):
        best,num=exact_tree_stretch(h,w)
        ck('published_tree_stretch_small',best==2*(min(h,w)//2)+1)
        ts.append((h,w,best,num))
    print('PASS grid rigidity: candidate frames',candidates)
    print('TREE_STRETCH',ts)
    print('COUNTS',dict(sorted(counts.items())))
if __name__=='__main__':run()
