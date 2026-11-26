#!/usr/bin/env python3
"""Exact finite checks for guarded envelope inequalities; not universal proof."""
from fractions import Fraction as Q
from itertools import product, combinations
from random import Random

rng = Random(20261126)

def states(shape):
    return list(product(*(range(q) for q in shape)))

def replace(x, i, a):
    return x[:i] + (a,) + x[i+1:]

def law(shape, fair=False):
    out=[]
    for q in shape:
        v=[1 if fair else rng.randint(1,7) for _ in range(q)]
        out.append(tuple(Q(a,sum(v)) for a in v))
    return out

def mass(x, p):
    a=Q(1)
    for i,t in enumerate(x): a*=p[i][t]
    return a

def oscillations(f, shape):
    return [max(abs(f[x]-f[replace(x,i,a)]) for x in f for a in range(q)) for i,q in enumerate(shape)]

def cost_lower(f, shape):
    # Every feasible FULL row has cost >= each singleton envelope sum and global range.
    return max(max(f.values())-min(f.values()), max(sum(max(abs(f[x]-f[replace(x,i,a)]) for a in range(q)) for i,q in enumerate(shape)) for x in f))

def moments(f, shape, p):
    xs=list(f); w={x:mass(x,p) for x in xs}; mu=sum(w[x]*f[x] for x in xs)
    V=sum(w[x]*(f[x]-mu)**2 for x in xs)
    I=[]
    for i,q in enumerate(shape):
        conditional=sum(w[x]*(f[x]-sum(p[i][a]*f[replace(x,i,a)] for a in range(q)))**2 for x in xs)
        fresh=sum(w[x]*p[i][a]*(f[x]-f[replace(x,i,a)])**2 for x in xs for a in range(q))/2
        assert conditional==fresh
        I.append(fresh)
    assert V<=sum(I)
    return V,I

def average_guards(f,shape,p,S):
    keep=[i for i in range(len(shape)) if i not in S]
    newshape=tuple(shape[i] for i in keep); newp=[p[i] for i in keep]
    g={x:Q(0) for x in states(newshape)}
    for x,v in f.items():
        w=Q(1)
        for i in S: w*=p[i][x[i]]
        g[tuple(x[i] for i in keep)]+=w*v
    return g,newshape,newp,keep

def check(f, shape,p,S,C):
    K=cost_lower(f,shape); V,I=moments(f,shape,p); M=max(I,default=Q(0))
    g,ss,pp,keep=average_guards(f,shape,p,S)
    W,J=moments(g,ss,pp); D=sum(oscillations(g,ss))
    assert V-W<=sum(I[i] for i in S)
    assert all(j<=I[i] for j,i in zip(J,keep))
    assert D<=C*K
    assert 4*W**2<=D**2*M
    assert 4*max(Q(0),V-len(S)*M)**2<=C*C*K*K*M
    assert 4*V<=K*K
    # Verify the closed-form constant without irrational arithmetic:
    # T=V/(K sqrt(M)) <= (C+sqrt(C²+4r))/4 iff 4T²-2CT-r<=0.
    if K and M:
        U=4*V*V-len(S)*K*K*M
        assert U<=0 or U*U<=4*C*C*V*V*K*K*M
    return V,M,K,D

def make_slice(shape,mode):
    # Coordinate reversals allowed; the theorem only requires a suitable orientation per slice.
    n=len(shape); rev=[rng.randrange(2) for _ in shape]
    if mode=='monotone':
        # Positive linear terms and nonnegative weighted threshold ORs: monotone DR.
        terms=[]
        for _ in range(7):
            S=[i for i in range(n) if rng.randrange(2)] or [rng.randrange(n)]
            terms.append((rng.randint(1,7),[(i,rng.randrange(1,shape[i])) for i in S]))
        aa=[rng.randint(0,5) for _ in shape]
        def eval0(x): return sum(a*b for a,b in zip(aa,x))+sum(w*any(x[i]>=t for i,t in S) for w,S in terms)
    else:
        # Arbitrary univariate terms minus positive products of increasing coordinates: DR.
        aa=[[rng.randint(-6,6) for _ in range(q)] for q in shape]
        terms=[(rng.randint(1,5),S) for k in range(2,n+1) for S in combinations(range(n),k) if rng.randrange(2)]
        def eval0(x):
            v=sum(aa[i][a] for i,a in enumerate(x))
            for w,S in terms:
                t=w
                for i in S:t*=x[i]
                v-=t
            return v
    f={x:Q(eval0(tuple(shape[i]-1-a if rev[i] else a for i,a in enumerate(x)))) for x in states(shape)}
    # Independently verify actual oriented decreasing differences, not just the generator label.
    h={x:f[tuple(shape[i]-1-a if rev[i] else a for i,a in enumerate(x))] for x in f}
    for x in h:
        for i,j in combinations(range(n),2):
            if x[i]+1<shape[i] and x[j]+1<shape[j]:
                a=replace(x,i,x[i]+1); b=replace(x,j,x[j]+1); c=replace(a,j,x[j]+1)
                assert h[c]-h[a]-h[b]+h[x]<=0
        if mode=='monotone':
            assert all(h[replace(x,i,x[i]+1)]>=h[x] for i,q in enumerate(shape) if x[i]+1<q)
    return f

def main():
    counts={}
    for mode,shape,C in [('monotone',(2,2,2,2),1),('nonmonotone',(2,2,2,2),2),('monotone',(3,2,4),1),('nonmonotone',(3,2,4),4)]:
        for _ in range(40):check(make_slice(shape,mode),shape,law(shape),(),Q(C))
        counts[f'{mode}:{shape}']=40
    for r in (1,2):
        tail=(2,3,2); shape=(2,)*r+tail
        for _ in range(40):
            f={}
            for z in states((2,)*r):
                h=make_slice(tail,'monotone'); offset=rng.randint(-10,10)
                for x,v in h.items():f[z+x]=v+offset
            check(f,shape,law(shape),tuple(range(r)),Q(1))
        counts[f'guarded:r={r}']=40
    for n in range(1,9):
        shape=(2,)*n; f={x:Q(sum(x)) for x in states(shape)}
        V,M,K,D=check(f,shape,law(shape,True),(),Q(1))
        assert 4*V*V==K*K*M and D==K
    # One guard can hide all variance: averaging must charge the guard influence.
    shape=(2,2); f={x:Q((2*x[0]-1)*(2*x[1]-1)) for x in states(shape)}
    V,M,K,D=check(f,shape,law(shape,True),(0,),Q(0)); assert V==M==1 and D==0
    # Two-address selector: exact formulas, with disjoint alternative contexts.
    # m=2 explicit full table, general m algebra: K=6, D_before=2m²+4, D_after=2.
    m=2; shape=(m,m)+(2,)*(m*m)
    f={x:Q(2*x[2+m*x[0]+x[1]]-1) for x in states(shape)}
    V,M,K,D=check(f,shape,law(shape,True),(0,1),Q(1,3))
    assert V==1 and M==Q(1,2) and K==6 and D==2 and sum(oscillations(f,shape))==2*m*m+4
    # Disjoint composition: exact moments and row lower bound add, max influence does not.
    bshape=(2,2,2)
    u={x:Q(2*x[1+x[0]]-1) for x in states(bshape)}
    v={x:Q(3)*u[x] for x in u}
    shape=bshape+bshape; p=law(shape,True)
    f={x:u[x[:3]]+v[x[3:]] for x in states(shape)}
    V,I=moments(f,shape,p); V1,I1=moments(u,bshape,p[:3]); V2,I2=moments(v,bshape,p[3:])
    assert V==V1+V2 and I==I1+I2 and cost_lower(f,shape)==cost_lower(u,bshape)+cost_lower(v,bshape)
    # Exact family formulas: a bounded global guard count cannot make D/K bounded.
    for r in range(9):
        b=2*r+2
        for m in (2,4,16,64):
            assert Q((b-r)*(2*m*m+4),6*b)>=Q(m*m,6)
    print('PASS',counts,'240 randomized exact cases; 8 sharp additive controls; XOR, selector, disjoint composition and 36 symbolic guard-limit controls; two independent influence formulas per table')

if __name__=='__main__':main()
