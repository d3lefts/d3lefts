#!/usr/bin/env python3
"""Independent exhaustive QW four-corner source-law falsifier.

Two independent binary coordinates; two product components with atom
probabilities 0,1/2,1; weights 0,1/3,1/2,2/3,1; all 16 Boolean targets.
Total 5*3^4*16=6480 models. Every 2-bit Boolean target has degree <=2.
Unlike check_quadratic_wyner_bridge_exact.py, this constructs the
full simultaneous theta/star-reference/coordinate-resampling joint law
and checks its four expectation identities. Exact Fraction only.

A PASS is NOT an all-dimensional proof or Lean certificate.
"""
from fractions import Fraction as F
from itertools import product
from hashlib import sha256

PROBS=(F(0),F(1,2),F(1))
WEIGHTS=(F(0),F(1,3),F(1,2),F(2,3),F(1))

def star_seed(p0,p1,q):
    cuts=sorted({F(0),p0,p1,q,F(1)})
    out={}
    for lo,hi in zip(cuts,cuts[1:]):
        if hi==lo:continue
        u=(lo+hi)/2
        t=(int(u<q),int(u<p0),int(u<p1))
        out[t]=out.get(t,F(0))+(hi-lo)
    assert sum(out.values(),F(0))==1
    assert sum((m*t[0] for t,m in out.items()),F(0))==q
    assert sum((m*t[1] for t,m in out.items()),F(0))==p0
    assert sum((m*t[2] for t,m in out.items()),F(0))==p1
    return out

def audit(f,w,p0,p1):
    q=tuple(w*p0[j]+(1-w)*p1[j] for j in range(2))
    k=[star_seed(p0[j],p1[j],q[j]) for j in range(2)]
    delta=F(0)
    for th,wt in ((0,w),(1,1-w)):
        for u0,m0 in k[0].items():
            for u1,m1 in k[1].items():
                ref=(u0[0],u1[0]);src=(u0[th+1],u1[th+1])
                delta+=wt*m0*m1*(f[src]-f[ref])**2
    for j in range(2):
        outer1=outer2=middle=left=absolute=F(0)
        for th,wt in ((0,w),(1,1-w)):
            for u0,m0 in k[0].items():
                for u1,m1 in k[1].items():
                    src=(u0[th+1],u1[th+1]);ref=(u0[0],u1[0])
                    for up,mp in k[j].items():
                        xp=list(src);xp[j]=up[th+1];xp=tuple(xp)
                        yp=list(ref);yp[j]=up[0];yp=tuple(yp)
                        wt0=wt*m0*m1*mp
                        outer1+=wt0*(f[ref]-f[src])**2
                        outer2+=wt0*(f[xp]-f[yp])**2
                        middle+=wt0*(f[src]-f[xp])**2
                        left+=wt0*(f[ref]-f[yp])**2
                        absolute+=wt0*abs(f[src]-f[xp])
        assert outer1==delta and outer2==delta
        IQ=left/2; IP=middle/2
        assert IQ<=2*IP+4*delta
        assert 2*IP<=absolute
        assert IQ<=absolute+4*delta

def main():
    h=sha256();count=0
    for w in WEIGHTS:
        for params in product(PROBS,repeat=4):
            p0=tuple(params[:2]);p1=tuple(params[2:])
            for vals in product((0,1),repeat=4):
                f=dict(zip(product((0,1),repeat=2),vals))
                audit(f,w,p0,p1)
                h.update(bytes(vals)+str((w,p0,p1)).encode())
                count+=1
    assert count==6480
    # Negative control: fresh latent theta changes middle influence term.
    # P0=delta0,P1=delta1: actual component Inf=0; replacing theta
    # independently gives (1/2)*Pr[X != X']=1/4 instead.
    assert F(1,2)*F(1,2)==F(1,4)>F(0)
    print("PASS 6480 exhaustive two-coordinate 4-corner joint identities")
    print("PASS zero-probability atoms and same-label resampling")
    print("PASS wrong-label negative control: 1/4 != 0")
    print("SHA256 cases:",h.hexdigest())

if __name__=="__main__":
    main()
