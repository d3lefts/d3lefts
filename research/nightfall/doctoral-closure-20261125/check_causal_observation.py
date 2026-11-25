from fractions import Fraction as F
from functools import lru_cache
from itertools import product


def risk(w, f, cells):
    total=F(0)
    for C in cells:
        m=sum(w[i] for i in C)
        if not m: continue
        mean=sum(w[i]*f[i] for i in C)/m
        total+=sum(w[i]*(f[i]-mean)**2 for i in C)
    return total


def pair_risk(w,f,cells):
    return sum((sum(w[i]*w[j]*(f[i]-f[j])**2 for i in C for j in C)/(2*m)
                for C in cells if (m:=sum(w[i] for i in C))), F(0))


def split(cells,labels):
    groups=[]
    for C in cells:
        d={}
        for i in C: d.setdefault(labels[i],[]).append(i)
        groups.extend(d.values())
    return groups


def split_gain(w,f,cells,labels):
    ans=F(0)
    for C in cells:
        m=sum(w[i] for i in C)
        if not m: continue
        mean=sum(w[i]*f[i] for i in C)/m
        for D in split([C],labels):
            n=sum(w[i] for i in D)
            if n:
                ans+=n*(sum(w[i]*f[i] for i in D)/n-mean)**2
    return ans


def exact_depth(states, release, targets):
    """Causal deterministic worst-case depth; state index is hidden."""
    infinity=len(states)+len(release)+1
    @lru_cache(None)
    def solve(t,S):
        if t==len(targets): return 0
        best=infinity
        if len({targets[t][i] for i in S})==1:
            best=solve(t+1,S)
        for j,r in enumerate(release):
            if r>t: continue
            children={}
            for i in S: children.setdefault(states[i][j],[]).append(i)
            if len(children)>1:
                best=min(best,1+max(solve(t,tuple(D)) for D in children.values()))
        return best
    return solve(0,tuple(range(len(states))))


def main():
    checks=0
    for raw in product(range(3),repeat=4):
        if not sum(raw):continue
        w=tuple(F(v,sum(raw)) for v in raw)
        for f in product((F(0),F(1,2),F(1)),repeat=4):
            for label in product(range(2),repeat=4):
                cells=split([list(range(4))],label)
                assert risk(w,f,cells)==pair_risk(w,f,cells)
                nxt=tuple(i%2 for i in range(4))
                assert risk(w,f,cells)-risk(w,f,split(cells,nxt))==split_gain(w,f,cells,nxt)
                checks+=1
    states=tuple((a,b,2*a+b) for a,b in product(range(2),repeat=2))
    tasks=tuple(tuple(s[j] for s in states) for j in (0,1))
    assert exact_depth(states,(0,1,1),tasks)==2
    assert exact_depth(states,(0,0,0),tasks)==1
    states=tuple((a,b) for a,b in product(range(2),repeat=2))
    repeated=(tuple(s[0] for s in states),)*5
    assert exact_depth(states,(0,0),repeated)==1
    print('exact rational pair-risk/split-gain cases:', checks)
    print('packed future sensor: causal=2, all-released=1; repeated target: shared=1, reset=5')

if __name__=='__main__':main()
