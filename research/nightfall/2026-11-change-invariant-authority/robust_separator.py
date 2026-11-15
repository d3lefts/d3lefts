"""Exact robust separator risk certificate (research, not deployed authorization).
All arithmetic is fractions.Fraction; mission-unsafe event fixed within each separator slice.
"""
from fractions import Fraction as F

def rational(x): return F(x)

def check_data(unsafe, safe, lower=None, upper=None):
    a=tuple(map(F,unsafe)); s=tuple(map(F,safe))
    assert len(a)==len(s)>0 and all(x>=0 and y>=0 and x+y>0 for x,y in zip(a,s))
    if lower is not None:
        l=tuple(map(F,lower));u=tuple(map(F,upper))
        assert len(l)==len(u)==len(a) and all(0<l_i<=u_i for l_i,u_i in zip(l,u))
        return a,s,l,u
    return a,s

def robust_unbounded_risk(unsafe,safe):
    a,s=check_data(unsafe,safe)
    return max(x/(x+y) for x,y in zip(a,s))

def robust_threshold_margin(unsafe,safe,lower,upper,delta):
    """Max_lambda [unsafe_mass(lambda) - delta*total_mass(lambda)].
    <= 0 iff all admissible postchange posterior risks <= delta.
    """
    a,s,l,u=check_data(unsafe,safe,lower,upper)
    d=F(delta)
    assert 0<=d<=1
    coeff=[x-d*(x+y) for x,y in zip(a,s)]
    return sum((ui if v>=0 else li)*v for v,li,ui in zip(coeff,l,u))

def robust_interval_risk(unsafe,safe,lower,upper):
    """Exact maximum posterior risk via rational fractional-programming iterations.
    Used for output only; audit uses independently enumerated corners.
    """
    a,s,l,u=check_data(unsafe,safe,lower,upper)
    # max risk among corners can be found via Dinkelbach threshold updates.
    t=sum(li*x for li,x in zip(l,a))/sum(li*(x+y) for li,x,y in zip(l,a,s))
    seen=set()
    while True:
        coeff=[x-t*(x+y) for x,y in zip(a,s)]
        lam=[ui if v>=0 else li for v,li,ui in zip(coeff,l,u)]
        new=sum(v*x for v,x in zip(lam,a))/sum(v*(x+y) for v,x,y in zip(lam,a,s))
        if new==t:return t,tuple(lam)
        assert new>t,(t,new)
        assert new not in seen
        seen.add(new);t=new

def uniform_change_radius(unsafe,safe,rho,delta):
    """Exact symmetric reweight tolerance if lambda_b in [1-k rho_b,1+k rho_b].
    Returns (critical_k, admissible_k_max), inf critical_k means all allowed.
    """
    a,s=check_data(unsafe,safe)
    ro=tuple(map(F,rho)); d=F(delta)
    assert len(ro)==len(a) and all(r>=0 for r in ro) and 0<=d<=1
    T=sum(x+y for x,y in zip(a,s));A=sum(a)
    if A>d*T:return F(0),None  # already unauthorized at k=0
    gap=d*T-A
    exposure=sum(r*abs(x-d*(x+y)) for r,x,y in zip(ro,a,s))
    bound=None if max(ro)==0 else F(1)/max(ro)
    if exposure==0:return None,bound
    return gap/exposure,bound
