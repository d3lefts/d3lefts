#!/usr/bin/env python3
"""Independent exact Fraction audit: common categorical sampler + one-query phase oracle.

The absorbing Markov process below is an independent finite calculation of
shared marked-Poisson sampling. No simulated real clocks, logs or floating-point
acceptance tolerance. General quantum hybrid and all-instance theorem remain
external mathematics/Lean obligations.
"""
from fractions import Fraction as F
from itertools import product
from functools import lru_cache
from random import Random
from hashlib import sha256
from pathlib import Path
rng=Random(19112026)
assertions=0
case_count=0
zero_count=0

def ck(cond,msg):
    global assertions
    assert cond,msg
    assertions+=1

def random_prob(k):
    w=[rng.choice([0,0,1,2,4,7]) for _ in range(k)]
    if not sum(w): w[rng.randrange(k)]=1
    return tuple(F(a,sum(w)) for a in w)

def shared_sampler(ps):
    """One finite common Poisson-marked process induces all M output labels.
    State holds already-decided outputs; event types (letter, mask) have rational rates.
    Ignore no-progress self events by renormalizing; all other transitions resolve a new component.
    """
    M=len(ps);k=len(ps[0]);rates=[]
    for a in range(k):
        z=sorted(set([F(0)]+[ps[t][a] for t in range(M)]))
        for i in range(len(z)-1):
            low,high=z[i],z[i+1]
            if high<=low:continue
            mask=tuple(t for t in range(M) if ps[t][a]>=high)
            if mask:rates.append((a,mask,high-low))
    @lru_cache(None)
    def solve(state):
        if -1 not in state:return {state:F(1)}
        moves=[];total=F(0)
        for a,mask,rate in rates:
            nxt=list(state)
            for t in mask:
                if nxt[t]==-1:nxt[t]=a
            nxt=tuple(nxt)
            if nxt!=state:
                moves.append((nxt,rate)); total+=rate
        assert total>0
        out={}
        for nxt,rate in moves:
            for completed,v in solve(nxt).items():
                out[completed]=out.get(completed,F())+(rate/total)*v
        assert sum(out.values(),F())==1
        return out
    out=solve(tuple([-1]*M))
    ck(sum(out.values(),F())==1,'normalization')
    for t in range(M):
        for a in range(k):
            got=sum((v for state,v in out.items() if state[t]==a),F())
            ck(got==ps[t][a],('marginal',t,a,got,ps[t][a]))
    for t in range(M):
        for u in range(t+1,M):
            fail=sum((v for state,v in out.items() if state[t]!=state[u]),F())
            tv=sum((abs(ps[t][a]-ps[u][a]) for a in range(k)),F())/2
            ck(fail<=2*tv/(1+tv),('correlated sampling',t,u,fail,tv))
    return out

def quantum_f(x,k):
    n=len(x)
    # uniform superposition over query indices, 1 phase query of chi_i(x_i),
    # project onto the same uniform vector
    amp=sum((1 if (x[i]+i)%2==0 else -1 for i in range(n)))
    return F(amp*amp,n*n)

for n,k,M,cases in [(2,3,3,24),(3,3,3,8),(2,4,4,8)]:
    words=list(product(range(k),repeat=n))
    for x in words:
        for y in words:
            d=quantum_f(x,k)-quantum_f(y,k)
            rhs=F(16,n)*sum(x[i]!=y[i] for i in range(n))
            ck(d*d<=rhs,('one quantum query hybrid',n,k,x,y))
    for trial in range(cases):
        ps=[[random_prob(k) for t in range(M)] for i in range(n)]
        zero_count+=sum(p==0 for i in range(n) for pp in ps[i] for p in pp)
        couplings=[shared_sampler(ps[i]) for i in range(n)]
        pri=[F(t+1,sum(range(1,M+1))) for t in range(M)]
        # Independent sources per coordinate under each latent component
        for th in range(M):
            for word in words:
                joint=F(1)
                for i in range(n):joint*=ps[i][th][word[i]]
                induced=F(1)
                for i in range(n):
                    induced*=sum((v for yy,v in couplings[i].items() if yy[th]==word[i]),F())
                ck(induced==joint,('conditional joint source',th,word))
        j=F(0);sq=F(0)
        pairmismatch=F(0);pairtv=F(0)
        for theta in range(M):
            for theta2 in range(M):
                a=F(0);b=F(0)
                for seedtuple in product(*[list(cp.items()) for cp in couplings]):
                    mass=F(1);xx=[];yy=[]
                    for state,prob in seedtuple:
                        mass*=prob;xx.append(state[theta]);yy.append(state[theta2])
                    delta=quantum_f(tuple(xx),k)-quantum_f(tuple(yy),k)
                    a+=mass*abs(delta)
                    b+=mass*delta*delta
                j+=pri[theta]*pri[theta2]*a
                sq+=pri[theta]*pri[theta2]*b
                for i in range(n):
                    mismatch=sum((v for zz,v in couplings[i].items() if zz[theta]!=zz[theta2]),F())
                    pairmismatch+=pri[theta]*pri[theta2]*mismatch/n
                    tv=sum((abs(ps[i][theta][a]-ps[i][theta2][a]) for a in range(k)),F())/2
                    pairtv+=pri[theta]*pri[theta2]*tv/n
        ck(j*j<=sq,('Jensen',n,k,M,trial))
        ck(sq<=16*pairmismatch,('one-query coupling square',n,k,M,trial,sq,pairmismatch))
        ck(pairmismatch<=2*pairtv,('shared TV',n,k,M,trial,pairmismatch,pairtv))
        ck(j*j<=32*pairtv,('hidden increment reduction',n,k,M,trial))
        case_count+=1
print(f'PASS {assertions} exact rational assertions; {case_count} categorical latent models; {zero_count} zero-mass atoms.')
print('LIMIT: finite tests do not prove general quantum hybrid, Pinsker, entropy drift or all-M theorem.')
print('SHA256',sha256(Path(__file__).read_bytes()).hexdigest())
