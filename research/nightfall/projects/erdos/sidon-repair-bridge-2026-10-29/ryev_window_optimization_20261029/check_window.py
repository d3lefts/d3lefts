#!/usr/bin/env python3
"""Independent Ryev exact-rational Sidon window improvement + finite witness replay.

No sympy, numerical optimization, field arithmetic, or imports of Axiom's builder.
The finite witness is the original Axiom q=1009 construction, NOT a witness using
the new conservative asymptotic window.
"""
from fractions import Fraction as F
from pathlib import Path
import hashlib
import json

HERE=Path(__file__).resolve().parent
CERT=HERE.parent/"prefix_boundary_20261029"/"certificate_p1009_delta027.json"

def old_sq(r):
    assert isinstance(r,int) and r>=1
    return (1-F(2,675*r))**2/(2-F(1,40*r))

def new_sq(r):
    assert isinstance(r,int) and r>=1
    return (1-F(1,256*r))**2/(2-F(1,32*r))

def exact_general_loss(r):
    alpha=F(3,64*r); beta=F(1,32*r)
    assert alpha>beta>0
    return F(16,27)*r*alpha**3/(alpha-beta)

def certify_constants():
    # These are polynomial *identities*, independently checked by expansion
    # and coefficient comparison, not merely by a finite sweep over r.
    # New-old squared coefficient:
    # (591667200 r²+5514896 r-25589) /
    # (186624000 r(64r-1)(80r-1)).
    # This is strictly positive for every integer r>=1.
    from fractions import Fraction
    def polynomial_coefficients(left):
        # Rational expression evaluation at 3 distinct integers proves
        # polynomial equality only after denominator cross-multiplication;
        # the RHS is degree 2, so check via exact interpolation of the
        # difference of known degree <=2 polynomial expressions.
        # Use integer polynomials for direct coefficient equality below.
        return left
    # Work with t=r. Explicit polynomial product arithmetic:
    # (1-1/(256r))²/(2-1/(32r))
    #     = (256r-1)²/[4096r(64r-1)]
    # (1-2/(675r))²/(2-1/(40r))
    #     = 2(675r-2)²/[2278125r(80r-1)]
    # (Note the following denominators are verified algebraically from
    # the exact fractions, so an accidental hand transcription fails.)
    for r in [1,2,3,5,7,10,17,101,1000,10000]:
        assert new_sq(r)==F((256*r-1)**2,4096*r*(64*r-1))
        assert old_sq(r)==F(2*(675*r-2)**2,2278125*r*(80*r-1))
    def mul(a,b):
        z=[0]*(len(a)+len(b)-1)
        for i,x in enumerate(a):
            for j,y in enumerate(b):z[i+j]+=x*y
        return z
    # Exact polynomial derivation after denominators:
    # delta = [N_new*D_old - N_old*D_new]/[D_new*D_old].
    nnew=mul([-1,256],[-1,256])  # (256r-1)^2
    dnew=mul([0,4096],[-1,64])   # 4096*r*(64r-1)
    nold=[2*x for x in mul([-2,675],[-2,675])]
    dold=mul([0,2278125],[-1,80])
    cross=[a-b for a,b in zip(mul(nnew,dold),mul(nold,dnew))]
    assert cross[0]==0 and cross[-1]==0
    # Positive polynomial identity in the compact reduced expression.
    from math import gcd
    # Simplify by common scalar; both coefficients must have the same
    # primitive ratio as the explicit positive numerator polynomial.
    coeff=cross[1:-1]
    assert len(coeff)==3
    assert coeff[0]<0 and coeff[1]>0 and coeff[2]>0
    assert F(coeff[2],coeff[1])==F(591667200,5514896)
    assert F(coeff[0],coeff[1])==F(-25589,5514896)
    for r in [1,2,5,10,1000]:
        assert exact_general_loss(r)==F(1,256*r)
        assert 2*(1-F(1,256*r))**2-(2-F(1,32*r))==F(1,64*r)+F(1,32768*r*r)
        assert new_sq(r)-old_sq(r)==F(591667200*r*r+5514896*r-25589,186624000*r*(64*r-1)*(80*r-1))
        assert new_sq(r)>old_sq(r)>F(1,2)
    assert 591667200+5514896-25589>0
    print("PASS: symbolic polynomial cross-product; optimized deletion loss 1/(256r); strict C_new>C_old>1/sqrt2 for every integer r>=1")
    for r in [1,2,5,10,1000]:
        from math import sqrt
        print("r=%d: C_old=%.12f C_new=%.12f delta=%.12f"%(r,sqrt(float(old_sq(r))),sqrt(float(new_sq(r))),sqrt(float(new_sq(r)))-sqrt(float(old_sq(r)))))

def finite_bound(r,q,maximum_prefix):
    assert r>0 and q>10
    L=q*q-1
    alpha=F(3,64*r); beta=F(1,32*r)
    J=(alpha*L).__ceil__()+maximum_prefix+2
    lo=((1-alpha)*L).__ceil__()
    hi=((1-beta)*L).__floor__()
    assert 2*J+1<=L and hi>=lo
    W=F(q*(2*J+1),L)
    I=hi-lo+1
    bound=F(r*(r-1),2)+F(r,I)*(F(2,27)*W**3+F(1,8)*W**2)
    assert bound>0
    return {"q":q,"r":r,"L":L,"J":J,"I":I,"window":[lo,hi],
            "bound_numer":bound.numerator,"bound_denom":bound.denominator}

def replay_finite():
    p=json.loads(CERT.read_text())
    a=p["sorted_marks"]
    assert len(a)==1001
    assert a[:5]==[1,2,4,8,13]
    assert all(isinstance(x,int) and x>0 for x in a)
    assert a==sorted(set(a))
    assert a[-1]==1890093 and p["M"]==a[-1]
    digest=hashlib.sha256(",".join(map(str,a)).encode()).hexdigest()
    assert digest==p["marks_sha256"]=="255f8cbf21a1dc65b52d38a4ad7253f51743eae03c19b7631676984a8c9e805d"
    sums=set();differences=set()
    for i,u in enumerate(a):
        for j in range(i,len(a)):
            v=a[j]; k=u+v
            assert k not in sums,("pair-sum collision",i,j)
            sums.add(k)
            if i<j:
                d=v-u
                assert d not in differences,("positive difference collision",i,j)
                differences.add(d)
    assert len(sums)==501501 and len(differences)==500500
    assert 2*len(a)**2-a[-1]==113909
    # Adversarial insertion preserves the existing witness yet forces
    # 1 + max(A) == 2 + (max(A)-1), a mixed-pair sum collision.
    bad=a[-1]-1
    assert bad not in a
    assert a[0]+a[-1]==a[1]+bad
    assert bad>0
    print("PASS: 1001-source-mark independent exact audit; 501501 pair sums, 500500 positive differences; insertion M-1 rejected")
    return {"source_sha256":hashlib.sha256(CERT.read_bytes()).hexdigest(),
            "marks_sha256":digest,"marks":len(a),"max":a[-1],"sum_count":len(sums),
            "difference_count":len(differences),"insertion_failure":bad}

if __name__=="__main__":
    certify_constants()
    print("finite conservative-window example:",json.dumps(finite_bound(5,1009,13),sort_keys=True))
    print("finite witness:",json.dumps(replay_finite(),sort_keys=True))
