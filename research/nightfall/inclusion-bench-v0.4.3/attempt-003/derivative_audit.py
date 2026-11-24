from fractions import Fraction as Q
from itertools import product
from random import Random
from math import isqrt

rng=Random(20261123)
def ch(a,b): return 1-2*((a&b).bit_count()&1)
def walsh(x): return [sum(v*ch(a,b) for a,v in enumerate(x)) for b in range(len(x))]
def span(vs):
    s={0}
    for v in vs: s|={u^v for u in s}
    return s

def audit(x,y,h,exhaustive_variance=False):
    N=len(x); n=N.bit_length()-1
    d=[y[b]*y[b^h] for b in range(N)]
    q=lambda b:(1-d[b])//2
    q0=q(0); linear=[q(1<<i)^q0 for i in range(n)]
    cols=[sum((q((1<<i)^(1<<j))^q(1<<i)^q(1<<j)^q0)<<j for j in range(n)) for i in range(n)]
    for b in range(N):
        pred=q0
        for i in range(n):
            if b>>i&1:
                pred^=linear[i]
                pred^=(cols[i]&b&((1<<i)-1)).bit_count()&1
        if pred!=q(b): return False
    L=span(cols); D=len(L); t=isqrt(D); assert t*t==D
    W=walsh(d); support={a for a,w in enumerate(W) if w}
    k=min(support); assert support=={k^l for l in L}
    assert all(abs(W[a])*t==N for a in support)
    X=walsh(x); source=Q(sum(d[b]*X[b]*X[b^h] for b in range(N)),N*N)
    assert abs(source)<=1
    A=lambda i,j: Q(W[i^j]*ch(h,j),N)
    total=Q(0); seen=set()
    for u in range(N):
        if u in seen: continue
        I=sorted(u^l for l in L); J=[i^k for i in I]; seen.update(I)
        K=[[D*A(i,j)*x[i]*x[j] for j in J] for i in I]
        mu=sum(map(sum,K),Q(0))/(D*D); total+=mu*D/N
        assert sum(v*v for row in K for v in row)==D**3
        assert sum(sum(row)**2 for row in K)==D**3
        assert sum(sum(K[i][j] for i in range(D))**2 for j in range(D))==D**3
        if exhaustive_variance and D<=4:
            vals=[sum(K[i][j] for i in ii for j in jj)/(t*t) for ii in product(range(D),repeat=t) for jj in product(range(D),repeat=t)]
            assert sum(vals)/len(vals)==mu
            var=sum((v-mu)**2 for v in vals)/len(vals)
            assert var==Q(D+2*(t-1),t*t)-Q(2*t-1,t*t)*mu**2
    assert total==source
    return True

count=0
for x in product((-1,1),repeat=4):
    for y in product((-1,1),repeat=4):
        for h in range(4):
            assert audit(x,y,h,True); count+=1
for r in range(4):
    n=2*r+2; N=1<<n; h=1<<(n-1); m=(1<<r)-1
    q=lambda b: (((b&m)&((b>>r)&m)).bit_count()&1)^((b>>(2*r))&1)
    for _ in range(8):
        base=[rng.choice((-1,1)) for _ in range(N//2)]
        y=[base[b&(h-1)]*(-1 if b&h and q(b) else 1) for b in range(N)]
        x=[rng.choice((-1,1)) for _ in range(N)]
        assert audit(x,y,h,r<=1); count+=1
        # Forrelation embedding: row and column chirps and swap of the two r-bit halves.
        D=1<<(2*r); f=[rng.choice((-1,1)) for _ in range(D)]; g=[rng.choice((-1,1)) for _ in range(D)]
        chirp=lambda v: ch(v&m,v>>r)
        swap=lambda v: ((v&m)<<r)|(v>>r)
        xx=[]
        for b in range(N):
            v=b&(D-1); t=(b>>(2*r))&1; w=(b>>(2*r+1))&1
            xx.append(chirp(v)*(f[v] if not t else (-1)**w*g[swap(v)]))
        F=walsh(xx); d=[y[b]*y[b^h] for b in range(N)]
        actual=Q(sum(d[b]*F[b]*F[b^h] for b in range(N)),N*N)
        expected=Q(sum(f[a]*g[b]*ch(a,b) for a in range(D) for b in range(D)),D*isqrt(D))
        assert actual==expected
print(f'PASS: {count} exact source/block/variance cases; 32 Forrelation embeddings; rank 0 through 6')
