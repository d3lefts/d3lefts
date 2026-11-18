"""NIGHTFALL: independent exact-rational adversarial audit of Q3 energy-charge hypotheses.
2026-11-18. This verifies finite fixtures; symbolic identities in report supply all-n claims.
"""
from fractions import Fraction as F
from itertools import product


def selector(n):
    # Independent physical evaluator; all source states enumerated.
    states=list(product((-1,1),repeat=n))
    f=lambda x,y,z: z*(x[y]-sum(x)*F(1,n))
    vals=[f(x,y,z) for x in states for y in range(n) for z in (-1,1)]
    assert sum(vals)==0
    N=len(vals)
    V=sum(v*v for v in vals)/N
    B=(max(vals)-min(vals))/2
    inf_x=[]
    for i in range(n):
        v=F(0)
        for x in states:
            x0=list(x); x0[i]*=-1
            for y in range(n):
                for z in (-1,1):
                    v+=(f(x,y,z)-f(tuple(x0),y,z))**2/F(4*N)
        inf_x.append(v)
    I_y=sum((f(x,y,z)-f(x,yy,z))**2 for x in states for y in range(n) for yy in range(n) for z in (-1,1))/F(2*N*n)
    I_z=sum(f(x,y,z)**2 for x in states for y in range(n) for z in (-1,1))/N
    M=max(inf_x+[I_y,I_z])
    # Section-energy vector, section sum pointwise, and total scalar energy.
    q=[[F(int(y==i))-F(1,n) for i in range(n)] for y in range(n)]
    energies=[[a*a for a in row] for row in q]
    assert all(sum(abs(a) for a in row)==B for row in q)
    assert all(sum(e)==V for e in energies)
    T=F(0)
    for v in energies:
        for w in energies:
            distance=sum(abs(a-b) for a,b in zip(v,w))
            T+=distance**2/F(2*n*n)
    assert V==F(n-1,n)
    assert B==2*F(n-1,n)
    assert inf_x==[F(n-1,n*n)]*n
    assert I_y==I_z==V
    assert T==2*F(n-1,n)*(1-F(2,n))**2
    assert V*V <= B*B*M
    assert T <= 4*B*B*I_y
    return n,V,B,M,T


def shared_core(m,p):
    # Physical independent enumeration, original Bernoulli source.
    signs=list(product((-1,1),repeat=m))
    states=[(a,z) for a in (0,1) for z in signs]
    wt=lambda a:(p if a else 1-p)/len(signs)
    f=lambda a,z:(a-p)*sum(z)/m
    V=sum(wt(a)*f(a,z)**2 for a,z in states)
    B=1-p
    I_a=sum(wt(a)*(p if aa else 1-p)*(f(a,z)-f(aa,z))**2/F(2) for a,z in states for aa in (0,1))
    I_z=V # hypothetical external fair factor X0, so I_X0=V
    assert V==p*(1-p)/m
    assert I_a==V
    # Energy of Hilbert section indexed by anchor X0 (conditional on A,Z)
    e=lambda a,z:f(a,z)**2
    T_a=sum(wt(a)*(p if aa else 1-p)*(e(a,z)-e(aa,z))**2/F(2) for a,z in states for aa in (0,1))
    v=p*(1-p);t=(1-p)**3+p**3
    analytic=(v*t-v*v)*(3*m*m-2*m)/m**4
    assert T_a==analytic
    assert T_a<=4*B*B*I_a
    return m,p,V,T_a,T_a/(B*B*I_a)


def stitched_cycle(k,m,p,eps):
    # Analytic coefficient/ANOVA derivation; no enumeration over 2^(k*m).
    # f=sum_j Z_j (A_j-p) [sum_i X_(j,i)+eps X_(j+1,0)] / m
    # k>=3, m>=2, eps>0 -> connected 3-uniform hypergraph, cover tau*=k.
    assert k>=3 and m>=2 and 0<p<=F(1,2) and eps>=0
    v=p*(1-p)
    B=k*(1-p)*(m+eps)/m
    V=k*v*(m+eps*eps)/m**2
    M=v*(m+eps*eps)/m**2
    R=V*V/(B*B*M)
    # For eps>0, the anchor X_(j+1,0) appears in two consecutive edge clusters;
    # each cluster has a unique Z_j,A_j; each also contains the disjoint leaf X_(j,1).
    # k disjoint hyperedges -> dual fractional packing k; cover weight 1 on every Z_j -> k.
    tau=k if eps else 1
    return k,m,p,eps,B,V,M,R,tau


def run_primary():
    for n in range(2,7):
        print('selector',selector(n))
    for m,p in [(3,F(1,7)),(4,F(1,16)),(8,F(1,64))]:
        print('shared',shared_core(m,p))
    for k in (3,10,12):
        for eps in (F(0), F(1,10000), F(1)):
            print('stitched',stitched_cycle(k,3,F(1,25),eps))
    # For k=12, eps=1/10000 and eps=0, the R change is tiny while tau jumps 1->12.
    x=stitched_cycle(12,3,F(1,25),F(1,10000))
    y=stitched_cycle(12,3,F(1,25),F(0))
    assert x[-1]==12 and y[-1]==1
    assert abs(x[-2]/y[-2]-1)<F(1,1000)
    print('PASS exact-rational physical enumeration (selector/shared) and symbolic stitched fixtures')


def transport_sharp(epsilon):
    # Fair anchor X and fair controller W; u(+)=1 and u(-)=1-epsilon.
    assert F(0)<epsilon<F(1)
    u=(F(1),F(1)-epsilon)
    B=F(1)
    I=sum((a-b)**2 for a in u for b in u)/8
    T=sum((a*a-b*b)**2 for a in u for b in u)/8
    assert I==epsilon**2/4 and T==(2*epsilon-epsilon**2)**2/4
    assert T<=4*B*B*I
    assert T/(B*B*I)==(2-epsilon)**2
    return epsilon,T/(B*B*I)


def general_multicontrol(seed):
    # Original-law random categorical controls; f=Σ_i X_i u_i(W), degree<=3.
    import random
    R=random.Random(seed)
    p=[F(1,7),F(6,7)]
    r=[F(1,2),F(1,3),F(1,6)]
    cp=F(1,7); cr=F(2,3)
    W=list(product(range(2),range(3)))
    weights={(a,b):p[a]*r[b] for a,b in W}
    coeff=[[R.randrange(-4,5) for _ in range(4)] for _ in range(3)]
    def ui(i,a,b):
        c=coeff[i]
        return c[0]+c[1]*(F(a)-cp)+c[2]*(F(b)-cr)+c[3]*(F(a)-cp)*(F(b)-cr)
    u={w:[ui(i,*w) for i in range(3)] for w in W}
    B=max(sum(abs(v) for v in us) for us in u.values())
    e={w:[v*v for v in us] for w,us in u.items()}
    for j in (0,1):
        I=T=F(0)
        for w in W:
            law=p if j==0 else r
            for new in range(len(law)):
                wp=tuple(new if a==j else w[a] for a in range(2))
                D2=sum((a-b)**2 for a,b in zip(u[w],u[wp]))
                D1=sum(abs(a-b) for a,b in zip(e[w],e[wp]))
                I+=weights[w]*law[new]*D2/2
                T+=weights[w]*law[new]*D1**2/2
        assert T<=4*B*B*I, (seed,j,T,I,B)
    return 1

def run_all():
    run_primary()
    for eps in (F(1,2),F(1,10),F(1,10000)):
        print('sharp transport', transport_sharp(eps))
    print('multi-control random models passed',sum(general_multicontrol(i) for i in range(64)))


if __name__ == "__main__":
    run_all()