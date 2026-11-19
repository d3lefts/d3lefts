#!/usr/bin/env python3
"""Exact rational attack against an OPEN source-coupled linear-degree annealed-Q2 gate.

PASS means the sampled cases do not refute C=1; it does not establish it.
Run: python3 -I research/nightfall/flagship-influence/check_poly_d_proxy_gate_stress.py
"""
from fractions import Fraction as F
from math import comb
from random import Random


def pop(k): return k.bit_count()


def transform(a):
    a = list(a)
    t = 1
    while t < len(a):
        for i in range(0, len(a), 2*t):
            for j in range(t):
                p,q = a[i+j], a[i+j+t]
                a[i+j],a[i+j+t] = p+q,p-q
        t *= 2
    return a


def from_values(vals):
    return transform(vals)


def amp(n,coeff):
    N=1<<n
    ans=0
    for live in range(N):
        h=[v if 1<=pop(s&live)<=2 else 0 for s,v in enumerate(coeff)]
        ans=max(ans,max(map(abs,transform(h))))
    return ans


def score(n,d,coeff):
    assert len(coeff)==1<<n and all(v==0 or pop(s)<=d for s,v in enumerate(coeff))
    m=max(1,(d-1).bit_length())
    U=F(0);Js=[F(0)]*n
    for s,a in enumerate(coeff):
        order=pop(s)
        if not order or not a:continue
        uw,jw=F(0),F(0)
        for k in range(1,m+1):
            t=F(1,2**k)
            uw += (order*t*(1-t)**(order-1) + (comb(order,2)*t*t*(1-t)**(order-2) if order>=2 else 0))/m
            jw += (t*(1-t)**(order-1) + ((order-1)*t*t*(1-t)**(order-2) if order>=2 else 0))/m
        U+=a*a*uw
        for i in range(n):
            if s&(1<<i):Js[i]+=a*a*jw
    if not U:return F(0)
    A=amp(n,coeff)
    return U**2/(d*A*A*max(Js))


def selector(n=6):
    assert n==6
    return from_values([2*((x>>(2+((x&1)+2*((x>>1)&1))))&1)-1 for x in range(1<<n)])


def tribes(n=6):
    return from_values([int(any((x>>(2*b))&3==3 for b in range(n//2))) for x in range(1<<n)])


def cheb(n,d):
    vals=[]
    for x in range(1<<n):
        t=F(2*pop(x)-n,n)
        if d==0: y=F(1)
        elif d==1: y=t
        else:
            u,v=F(1),t
            for k in range(2,d+1):u,v=v,2*t*v-u
            y=v
        vals.append(int(y*n**d))
    return from_values(vals)


if __name__=='__main__':
    n=6;N=1<<n
    families=[('additive',1,[0]+[1 if pop(s)==1 else 0 for s in range(1,N)]),
              ('parity2',2,[1 if s==3 else 0 for s in range(N)]),
              ('parity6',6,[1 if s==63 else 0 for s in range(N)]),
              ('selector',3,selector()),('tribes',6,tribes())]
    families += [(f'chebyshev{d}',d,cheb(n,d)) for d in range(2,7)]
    rng=Random(20261118)
    for j in range(100):
        d=rng.randrange(2,7)
        candidates=[s for s in range(1,N) if pop(s)<=d]
        picked=rng.sample(candidates,rng.randrange(3,min(20,len(candidates))+1))
        a=[0]*N
        for s in picked:a[s]=rng.choice((-3,-2,-1,1,2,3))
        families.append((f'random{j}',d,a))
    best=(F(0),None)
    for name,d,coeff in families:
        r=score(n,d,coeff)
        if r>best[0]:best=(r,name)
        if name in ('additive','parity2','parity6','selector','tribes'):
            print(name,'d=',d,'exact C_required=',r,'decimal=',float(r))
    print('max of',len(families),'models:',best,'~',float(best[0]))
    assert best[0]<=1, 'Exact counterexample to experimental C=1 gate; investigate'
    print('PASS finite attack; linear-degree source-coupled gate remains OPEN')


# v0.3: independent finite-binomial address-selector formulas and structural witnesses.
# The universal proof remains the written algebraic argument, not these finite tests.

def address_closed(k, t):
    assert k >= 1 and F(0) < t <= F(1, 2)
    a = 1-t/F(2)
    u = 1-t
    U = t*a**k + F(k,2)*t*a**(k-1)
    J = t*a**(k-1)/2
    if k >= 2:
        U += F(k*(k-1),8)*t*t*u*a**(k-2)
        J += F(k-1,4)*t*t*u*a**(k-2)
    return U,J

def address_independent(k, t):
    # Re-derive from the full Walsh spectrum of f(address, leaves)=leaf[address].
    # There are 2^k choices of leaf and binom(k,r) Fourier address sets of size r.
    u = F(0)
    j = F(0)
    for r in range(k+1):
        s = r+1
        w = s*t*(1-t)**(s-1)
        v = t*(1-t)**(s-1)
        if s>=2:
            w += F(comb(s,2))*t*t*(1-t)**(s-2)
            v += (s-1)*t*t*(1-t)**(s-2)
        u += F(comb(k,r),2**k)*w
        if r>=1: j += F(comb(k-1,r-1),2**k)*v
    return u,j

def check_address_and_support_classes():
    # Two analytically independent approaches agree exactly at 80 rational sites.
    exact_pairs=0
    for k in range(1,17):
        for scale in range(1,6):
            t=F(1,2**scale)
            U,J=address_closed(k,t)
            assert (U,J)==address_independent(k,t), (k,scale,U,J)
            assert U<=(k+2)*J, (k,scale)
            assert U<=F(3,4) if k>=2 else U<=F(5,8)
            assert U*U <= (k+1)*J, (k,scale)
            exact_pairs+=1

    # Exact-rational dyadic mixtures with exponentially many implicit leaves.
    best=(F(0),0)
    for k in range(1,129):
        m=k.bit_length() # ceil(log2(k+1))
        U=sum((address_closed(k,F(1,2**scale))[0] for scale in range(1,m+1)),F(0))/m
        J=sum((address_closed(k,F(1,2**scale))[1] for scale in range(1,m+1)),F(0))/m
        q=U*U/((k+1)*J)  # upper bound for actual C: A >= 1
        assert U*U<=(k+1)*J, (k,q)
        if q>best[0]: best=(q,k)
    assert best == (F(25,32),1), best

    # Literal exact polynomial identity used in the all-s binomial bound.
    # 3z(z-3)^2 + 10(z-43/20)^2 + 71/40
    # = 48 - 16z - 8z^2 + 3z^3, identically.
    for z in [F(0),F(1,3),F(5,2),F(3),F(13),F(103,7)]:
        lhs=48-16*z-8*z*z+3*z**3
        rhs=3*z*(z-3)**2 + 10*(z-F(43,20))**2+F(71,40)
        assert lhs==rhs and rhs>0

    # Verify the binomial 1-or-2 probability estimate at rational grids.
    for s in range(1,65):
        for scale in range(1,9):
            t=F(1,2**scale)
            w=s*t*(1-t)**(s-1)
            if s>=2: w+=comb(s,2)*t*t*(1-t)**(s-2)
            assert w<=F(3,4), (s,scale,w)

    # Adversarial finite coefficients: source-compatible common-hub,
    # disjoint-monomial and independent-star direct-sum classes.
    n=6; N=1<<n
    cases=[
        ("common-hub",3,{1:4,3:-2,5:3,7:-1,9:2,17:-2,33:1}),
        ("disjoint-monomials",2,{3:2,12:-1,48:3}),
        ("two-independent-stars",3,{1:3,3:-1,5:2,8:-2,24:1,40:-3}),
    ]
    for name,d,terms in cases:
        a=[0]*N
        for s,c in terms.items():a[s]=c
        q=score(n,d,a)
        cap=4 if name=="two-independent-stars" else 1
        assert q<=cap, (name,q,cap)
        print(name,'exact required C=',q,'proven class cap=',cap)
    print('PASS: 80 exact independent address formulas, 128 dyadic all-k cases, '
          'binomial SOS, 512 binomial controls, 3 structural fixtures; '
          'best selector upper ratio=',best)

if __name__=='__main__':
    check_address_and_support_classes()


# v0.4: exact first-chaos source-paired proxy stress and no-loss operators.
def amp_linear(n, coeff):
    N=1<<n
    ans=0
    for live in range(N):
        # All source disagreement sets are supported at each dyadic scale.
        h=[v if pop(s&live)==1 else 0 for s,v in enumerate(coeff)]
        ans=max(ans,max(map(abs,transform(h))))
    return ans

def score_linear(n,d,coeff):
    assert len(coeff)==1<<n
    assert all(not c or pop(s)<=d for s,c in enumerate(coeff))
    m=max(1,(d-1).bit_length())
    U=F(0);Js=[F(0)]*n
    for s,a in enumerate(coeff):
        order=pop(s)
        if not order or not a:continue
        v=F(0)
        for k in range(1,m+1):
            t=F(1,2**k)
            v += t*(1-t)**(order-1)/m
        U+=a*a*order*v
        for i in range(n):
            if s&(1<<i):Js[i]+=a*a*v
    if not U:return F(0)
    A=amp_linear(n,coeff)
    return U*U/(d*A*A*max(Js))

def linear_address_closed(k,t):
    assert 1<=k and F(0)<t<=F(1,2)
    a=1-t/2
    u=1-t
    return t*a**k+F(k,2)*t*u*a**(k-1), t*u*a**(k-1)/2

def linear_address_independent(k,t):
    # Independent: enumerate source Walsh weights at each address order.
    u,j=F(0),F(0)
    for r in range(k+1):
        wt=F(comb(k,r),2**k)
        u += wt*(r+1)*t*(1-t)**r
        if r>=1: j+=F(comb(k-1,r-1),2**k)*t*(1-t)**r
    return u,j

def check_linear_structural_pivot():
    assert 'families' in globals(), 'Run this exact checker as a script'
    best=(F(0),None)
    for name,d,coeff in families:
        ratio=score_linear(n,d,coeff)
        if ratio>best[0]:best=(ratio,name)
        assert ratio<=1, (name,ratio,'candidate LIN-ANNEALED-C=1 falsifier')
    # Distinct source cases in dyadic gate:
    assert score_linear(6,2,[int(i==3) for i in range(1<<6)])==F(1,2)
    linear_pairs=0
    for k in range(1,17):
        for scale in range(1,6):
            t=F(1,2**scale)
            u,j=linear_address_closed(k,t)
            assert (u,j)==linear_address_independent(k,t)
            assert u<=F(1,2) and u<=(k+3)*j
            assert u*u<=(k+1)*j
            linear_pairs+=1
    selector_best=(F(0),0)
    for k in range(1,129):
        m=k.bit_length()
        U=sum((linear_address_closed(k,F(1,2**scale))[0] for scale in range(1,m+1)), F(0))/m
        J=sum((linear_address_closed(k,F(1,2**scale))[1] for scale in range(1,m+1)), F(0))/m
        cap=U*U/((k+1)*J) # A1 >= 1, so true C_needed no larger
        assert cap<=1,(k,cap)
        if cap>selector_best[0]:selector_best=(cap,k)
    # Direct-sum amplitude tensorization with common dyadic distribution:
    a1=[0]*(1<<6); a2=[0]*(1<<6)
    for s,c in {1:3,3:-1,5:2}.items():a1[s]=c
    for s,c in {8:-2,24:1,40:-3}.items():a2[s]=c
    combined=[a+b for a,b in zip(a1,a2)]
    assert amp_linear(6,combined)==amp_linear(6,a1)+amp_linear(6,a2)
    assert score_linear(6,3,combined)<=1
    print('PASS first-chaos: ',len(families),'actual-amplitude exact Walsh models, '
          +str(linear_pairs)+' independent rational selector formulas, 128 implicit '
          'exponential-leaf selectors, direct-sum exact amplitude; '
          'best tested C=',str(best),'selector upper C=',str(selector_best))

if __name__=='__main__':
    check_linear_structural_pivot()


# v0.5: exact NECESSARY COEFFICIENT 2/3 from a three-sign address selector.
# This prevents erroneously promoting the disjoint-monomial C=1/2 to all functions.
def check_linear_two_thirds_lower_bound():
    # a=x0 (address), b=x1 and c=x2 (leaves).
    # f=(b+c)/2 + a*(c-b)/2.  This is exactly b or c according to address.
    co=[F(0)]*8
    for s,v in {2:F(1,2),4:F(1,2),3:F(-1,2),5:F(1,2)}.items():
        co[s]=v
    d=2
    t=F(1,2)
    U=F(0);J=[F(0)]*3
    for s,v in enumerate(co):
        if not s or not v: continue
        w=t*(1-t)**(pop(s)-1)
        U+=pop(s)*v*v*w
        for i in range(3):
            if s>>i&1:J[i]+=v*v*w
    A=amp_linear(3,co)
    r=U*U/(d*A*A*max(J))
    assert (U,J,A,r)==(F(1,2),[F(1,8),F(3,16),F(3,16)],F(1),F(2,3))
    assert r==score_linear(3,2,co)
    print('PASS sharp necessary first-chaos gate coefficient C >= 2/3:',
          'U=',U,'J=',J,'A=',A,'C_needed=',r)

if __name__=='__main__':
    check_linear_two_thirds_lower_bound()
