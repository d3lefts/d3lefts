#!/usr/bin/env python3
"""Finite exact rational replay of DQ2 v3 on cyclic/higher-order spin laws.

Full polynomial-sector PSD, every native gradient PSD, and full-configuration
Poincare PSD. Does not prove the all-n theorem or replace Lean/review.
"""
from fractions import Fraction as Q
from itertools import product, combinations
import json


def mul(xs):
    r=Q(1)
    for x in xs: r*=x
    return r


def pd(A, semidefinite=False):
    """Exact no-pivot LDL positive-definiteness certificate."""
    n=len(A); low=[[Q(0)]*n for _ in range(n)]; d=[Q(0)]*n
    for i in range(n):
        d[i]=A[i][i]-sum(low[i][k]**2*d[k] for k in range(i))
        assert d[i]>0 or (semidefinite and d[i]==0),('LDL negative pivot',i,d[i])
        low[i][i]=Q(1)
        for j in range(i+1,n):
            residual=A[j][i]-sum(low[i][k]*low[j][k]*d[k] for k in range(i))
            if d[i]==0:
                assert residual==0,('zero pivot but nonzero off-diagonal',i,j,residual)
            else:
                low[j][i]=residual/d[i]


def check(label,n,terms):
    xs=list(product((-1,1),repeat=n))
    r={x:mul(1+t*mul(x[i] for i in I) for I,t in terms) for x in xs}
    z=sum(r.values(),Q(0)); p={x:r[x]/z for x in xs}
    assert z>0 and min(p.values())>0
    assert all(p[x]==p[tuple(-a for a in x)] for x in xs)
    def ex(g):return sum((p[x]*g(x) for x in xs),Q(0))
    means=[ex(lambda x,i=i:x[i]) for i in range(n)]
    assert means==[0]*n
    m=[]
    for i in range(n):
        d={}
        for y in product((-1,1),repeat=n-1):
            neg=y[:i]+(-1,)+y[i:];pos=y[:i]+(1,)+y[i:]
            d[y]=(p[pos]-p[neg])/(p[pos]+p[neg])
        m.append(d)
    c=[[Q(0)]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i==j:continue
            k=j if j<i else j-1
            c[i][j]=max(abs(v-m[i][y[:k]+(-y[k],)+y[k+1:]])/2 for y,v in m[i].items())
    delta=max(max(sum(row) for row in c),max(sum(c[i][j] for i in range(n)) for j in range(n)))
    assert delta<1,(label,delta)
    gamma=1-delta;v=1-delta*delta
    assert all(1-b*b>=v for di in m for b in di.values())
    alpha=v*v*gamma/(1+delta)**2; eta=v*alpha; kappa=2/gamma**2
    cov=[[ex(lambda x,i=i,j=j:x[i]*x[j]) for j in range(n)] for i in range(n)]
    pd([[cov[i][j]-(alpha if i==j else Q(0)) for j in range(n)] for i in range(n)])
    pd([[(1/gamma if i==j else Q(0))-cov[i][j] for j in range(n)] for i in range(n)])
    feats=[lambda x,i=i:x[i] for i in range(n)] + [lambda x,i=i,j=j:x[i]*x[j] for i,j in combinations(range(n),2)]
    means=[ex(h) for h in feats];q=len(feats)
    gram=[[ex(lambda x,i=i,j=j:feats[i](x)*feats[j](x))-means[i]*means[j] for j in range(q)] for i in range(q)]
    pd([[(kappa if i==j else Q(0))-gram[i][j] for j in range(q)] for i in range(q)])
    for i in range(n):
        H=[[Q(0)]*n for _ in range(n)]
        for y in product((-1,1),repeat=n-1):
            neg=y[:i]+(-1,)+y[i:];pos=y[:i]+(1,)+y[i:]
            weight=4*p[neg]*p[pos]/(p[neg]+p[pos]);basis=(Q(1),)+tuple(Q(a) for a in y)
            for a in range(n):
                for b in range(n):H[a][b]+=weight*basis[a]*basis[b]
        pd([[H[a][b]-(eta if a==b else Q(0)) for b in range(n)] for a in range(n)])
    # Exact PSD of the full 2^n dimensional Poincare form, constant removed.
    N=len(xs); index={x:i for i,x in enumerate(xs)};weights=[p[x] for x in xs]
    E=[[Q(0)]*N for _ in range(N)]
    for i in range(n):
        for x in xs:
            if x[i]!=-1:continue
            y=x[:i]+(1,)+x[i+1:]
            a=index[x];b=index[y];w=weights[a]*weights[b]/(weights[a]+weights[b])
            E[a][a]+=w;E[b][b]+=w;E[a][b]-=w;E[b][a]-=w
    pd([[E[i][j]-gamma*((weights[i] if i==j else Q(0))-weights[i]*weights[j])
         for j in range(1,N)] for i in range(1,N)],semidefinite=True)
    return {'graph':label,'n':n,'delta':str(delta),'gradient_forms_checked':n,
            'quadratic_sector_dim':q,'all_function_poincare_dim':N-1,
            'multiplier_K_over_K0':str(kappa*kappa/eta)}


def main():
    cases=[
      ('triangle',3,[((0,1),Q(1,7)),((1,2),Q(-1,9)),((0,2),Q(1,11))]),
      ('square',4,[((i,(i+1)%4),Q((-1)**i,13)) for i in range(4)]),
      ('frustrated_K4',4,[((i,j),Q((-1)**(i+j),17)) for i,j in combinations(range(4),2)]),
      ('pure_4body',4,[((0,1,2,3),Q(1,9))]),
      ('square_plus_4body',4,[((i,(i+1)%4),Q(1,23)) for i in range(4)]+[((0,1,2,3),Q(-1,17))]),
      ('bowtie5',5,[((0,1),Q(1,21)),((1,2),Q(-1,23)),((0,2),Q(1,19)),
                      ((2,3),Q(1,21)),((3,4),Q(-1,23)),((2,4),Q(1,19))])
    ]
    result=[check(*x) for x in cases]
    assert sum(1 for x in result if '4body' in x['graph'])==2
    # Explicit obstruction: without spin-flip symmetry, delta=0 does not force v=1.
    assert 4*Q(99,100)*Q(1,100)<1
    print(json.dumps({'status':'PASS','cases':result,'scope':'finite exact PSD audits, not an all-n or Lean proof'},indent=2))

if __name__=='__main__':main()
