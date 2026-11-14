#!/usr/bin/env python3
"""Independent exact Bellman audit of full-posterior adaptive observation on weakly coupled star leaves."""
from fractions import Fraction as Q
from functools import lru_cache
from itertools import product
import json

checks=0

def demand(x,tag):
    global checks
    checks+=1
    if not x:raise AssertionError(tag)

def state_law(m,t,z,eps):
    n=2*m
    tab={}
    for x in product((-1,1),repeat=n):
        a=Q(1)
        for j in range(n):a*=(1+z*t*x[j])/2
        for j in range(n-1):a*=(1+eps*x[j]*x[j+1])
        tab[x]=a
    s=sum(tab.values(),Q(0))
    return {x:w/s for x,w in tab.items()}

def optimize(m,t,z,eps,lam):
    table=state_law(m,t,z,eps)
    n=2*m
    worlds=list(table)
    def f(x): return Q(sum(x[2*j]*x[2*j+1] for j in range(m)),m)
    @lru_cache(None)
    def state(obs):
        relevant=[(x,table[x]) for x in worlds if all(v==0 or x[j]==v for j,v in enumerate(obs))]
        denom=sum((v for _,v in relevant),Q(0))
        if denom==0:raise ValueError('impossible history')
        mean=sum((w*f(x) for x,w in relevant),Q(0))/denom
        risk=sum((w*(f(x)-mean)**2 for x,w in relevant),Q(0))/denom
        best=(risk,Q(0),risk) # (costed objective, expected reads, expected risk)
        for i,v in enumerate(obs):
            if v:continue
            children=[]
            for b in (-1,1):
                mass=sum((w for x,w in relevant if x[i]==b),Q(0))
                if not mass:continue
                new=obs[:i]+(b,)+obs[i+1:]
                children.append((mass/denom,state(new)))
            choice=(lam+sum((p*c[0] for p,c in children),Q(0)),
                    Q(1)+sum((p*c[1] for p,c in children),Q(0)),
                    sum((p*c[2] for p,c in children),Q(0)))
            if choice[0]<best[0]:best=choice
        demand(best[0]==best[1]*lam+best[2],'DP accounting')
        return best
    result=state((0,)*n)
    return result,state.cache_info().currsize

def main():
    entries=[]
    for m in (1,2,3):
        for t in (Q(1,4),Q(2,3)):
            v=1-t**4
            eps=v/Q(128*m*m)
            R=((1+eps)/(1-eps))**(2*m-1)
            # Rational upper bound on TV via oscillation and a rational test
            # delta<=v/(64m) from log/tanh calculus, and this sharper rational inequality confirms it for each tested case.
            D=v/Q(64*m)
            demand(((1+D)/(1-D))**2>=R,'claimed D upper from ratio R')
            for z in (-1,1):
                for scale in (Q(1,8),Q(1,2),Q(1),Q(2)):
                    lam=v/Q(m*m)*scale
                    obj,read,risk=optimize(m,t,z,eps,lam)[0]
                    lower=v/Q(m) - v/Q(m*m)*(read+2*m*D)-4*D
                    demand(risk>=lower,'adaptive lower under weak connected perturbation')
                    if risk<=v/Q(2*m):
                        demand(read>=Q(m,4),'connected adaptive Omega(1/eta) lower')
                    entries.append({'m':m,'t':str(t),'z':z,'lambda':str(lam),
                                    'expected_reads':str(read),'risk':str(risk)})
    print(json.dumps({'status':'PASS','checks':checks,'policies':len(entries),
                      'examples':entries[:3],
                      'scope':'exact optimal Bellman over stop/read action space under connected weak-star Ising model'},indent=2))
if __name__=='__main__':main()
