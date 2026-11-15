#!/usr/bin/env python3
"""Independent exact arithmetic test of normed-space symmetric first-chaos proof.
Not a proof; integer/Rational values throughout. No numpy or randomness.
"""
from fractions import Fraction as Q
from itertools import product
from hashlib import sha256

def norm(x, kind):
    vals = list(map(abs, x))
    return sum(vals) if kind == 'l1' else max(vals)

def add(x, y):
    return tuple(a+b for a,b in zip(x,y))

def scale(t,x):
    return tuple(t*a for a in x)

def exact_moments(vecs, probs, h, kind):
    n=len(vecs); zero=tuple(Q(0) for _ in h)
    # Vi is either 0 or fixed vector; Zi=eps_i Vi has 3-state law
    laws=[]
    for v,p in zip(vecs,probs):
        laws.append(((scale(-1,v),p/2),(zero,1-p),(v,p/2)))
    u=Q(0); g_num=[[Q(0)]*3 for _ in range(n)]
    for inds in product(range(3), repeat=n):
        pr=Q(1); x=h
        for i,k in enumerate(inds):
            z,p=laws[i][k]; pr*=p; x=add(x,z)
        if pr==0: continue
        f=norm(x,kind); u+=pr*f
        for i,k in enumerate(inds): g_num[i][k]+=pr*f
    w1=Q(0)
    for i in range(n):
        w1+=sum((num*num/laws[i][k][1] for k,num in enumerate(g_num[i]) if laws[i][k][1]),Q(0))-u*u
    return u,w1

def deletion(vecs,h,kind):
    n=len(vecs); R=Q(0); rem=[Q(0)]*n
    for eps in product((-1,1),repeat=n):
        x=h
        for i,ei in enumerate(eps):x=add(x,scale(ei,vecs[i]))
        R+=norm(x,kind)/2**n
        for i,ei in enumerate(eps):
            rem[i]+=norm(add(x,scale(-ei,vecs[i])),kind)/2**n
    return R,[R-z for z in rem]

def main():
    vectors=[(Q(1),Q(0)), (Q(0),Q(1)), (Q(1,2),Q(1,2)),
             (Q(1,2),-Q(1,2))]
    shifts=[(Q(0),Q(0)),(Q(1),Q(0)),(Q(1),Q(-1)),(Q(1,2),Q(1,2))]
    activities=[Q(0),Q(1,4),Q(1,2),Q(1)]
    num=0; min_slack=None; dig=sha256(); exact_eq=0
    for kind in ('l1','linf'):
        for n in (1,2,3):
            for vi in product(range(len(vectors)), repeat=n):
                vs=[vectors[k] for k in vi]
                for h in shifts:
                    R,deltas=deletion(vs,h,kind)
                    assert all(0<=d<=norm(v,kind) for d,v in zip(deltas,vs))
                    assert sum(deltas)<=R,(kind,n,vi,h,R,deltas)
                    for ap in product(range(len(activities)),repeat=n):
                        ps=[activities[k] for k in ap]
                        u,w1=exact_moments(vs,ps,h,kind)
                        c=max(map(lambda v:norm(v,kind),vs))
                        slack=norm(h,kind)**2+c*u-w1
                        assert slack>=0,(kind,n,vi,h,ap,u,w1,slack)
                        if slack==0:exact_eq+=1
                        min_slack=slack if min_slack is None else min(min_slack,slack)
                        dig.update(f'{kind}|{n}|{vi}|{h}|{ap}|{u}|{w1}|{slack}\n'.encode()); num+=1
    print('exact_cases',num,'equality_cases',exact_eq,'minimum_slack',min_slack,'sha256',dig.hexdigest())
if __name__=='__main__':main()
