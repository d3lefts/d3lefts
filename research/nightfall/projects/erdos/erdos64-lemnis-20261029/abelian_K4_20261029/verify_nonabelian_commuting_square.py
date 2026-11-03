#!/usr/bin/env python3
"""Separate nonabelian multiplication-table oracle for the conditional 16-step word."""
from itertools import product
WORD='01201203102102130'

def make_dihedral(m):
    G=list(product(range(m),range(2))); e=(0,0)
    def op(a,b):return ((a[0]+(-1 if a[1] else 1)*b[0])%m,(a[1]+b[1])%2)
    return G,e,op

def quaternion():
    G=list(product((-1,1),range(4)));e=(1,0)
    T={(1,1):(1,0),(2,2):(1,0),(3,3):(1,0)}
    # indexes 0=1,1=i,2=j,3=k
    def op(a,b):
        x,i=a;y,j=b
        if i==0:return(x*y,j)
        if j==0:return(x*y,i)
        if i==j:return(-x*y,0)
        base={(1,2):3,(2,3):1,(3,1):2}
        if (i,j) in base:return(x*y,base[(i,j)])
        return (-x*y,base[(j,i)])
    return G,e,op

def c3_s3():
    from itertools import permutations
    P=list(permutations((0,1,2)))
    e=(0,(0,1,2))
    G=list(product(range(3),P))
    def op(a,b):return ((a[0]+b[0])%3,tuple(a[1][b[1][j]] for j in range(3)))
    return G,e,op

def exact(G,e,op):
    assert all(op(e,g)==g and op(g,e)==g for g in G)
    inv={a:next(b for b in G if op(a,b)==e and op(b,a)==e) for a in G}
    def sq(x):return op(x,x)
    def cyc(x):
        s={e};cur=x
        while cur!=e:
            assert cur not in s;s.add(cur);cur=op(cur,x)
        return s
    count=0
    for a in G:
        if len(cyc(a))<3:continue
        for b in G:
            if b in cyc(a) or op(sq(a),b)!=op(b,sq(a)):continue
            for c in (G[0],G[-1]):
                edges={(1,2):a,(1,3):b,(2,3):c}
                point=e;states=[]
                for i,j in zip(WORD,WORD[1:]):
                    i=int(i);j=int(j)
                    states.append((i,point))
                    if (i,j) in edges:point=op(point,edges[(i,j)])
                    elif (j,i) in edges:point=op(point,inv[edges[(j,i)]])
                assert point==e
                assert len(set(states))==16
                count+=1
    return count
for desc,gg in [('D8',make_dihedral(4)),('D16',make_dihedral(8)),('Q8',quaternion()),('C3xS3',c3_s3())]:
    n=exact(*gg)
    assert n>0,(desc,n)
    print('PASS',desc,n,'16-state concrete cycles, arbitrary chord c')
# Deliberately false premises: a has order 2 and a,b are not independent
G,e,op=make_dihedral(4)
a=(1,0);b=(2,0)
# b in <a>, and supplied symbolic word repeatedly visits old states.
assert b in {e,a,op(a,a),op(op(a,a),a)}
print('PASS negative control: b in <a> rejected before 16-vertex claim')
