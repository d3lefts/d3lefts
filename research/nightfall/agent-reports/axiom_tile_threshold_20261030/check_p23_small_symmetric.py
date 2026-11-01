#!/usr/bin/env python3
"""Exhaust symmetric subsets of F3^2 and F5^2, verifying the theorem."""
def check(p):
    q=p*p
    def add(a,b): return ((a%p+b%p)%p)+p*((a//p+b//p)%p)
    def neg(a): return ((-a%p)+p*((-(a//p))%p))
    def sub(a,b): return add(a,neg(b))
    pairs=[]; seen={0}
    for a in range(1,q):
        if a not in seen:
            b=neg(a)
            assert a!=b
            pairs.append((a,b));seen.update((a,b))
    assert len(pairs)==(q-1)//2
    cutoff=p*((p-1)//2)
    count=0
    for mask in range(1<<len(pairs)):
        S=set()
        for i,(a,b) in enumerate(pairs):
            if (mask>>i)&1:S.update((a,b))
        for with_zero in (False,True):
            A=S|({0} if with_zero else set())
            count+=1
            for m in range(q):
                overlap=sum(1 for a in A if sub(a,m) in A)
                reps=sum(1 for a in A if sub(m,a) in A)
                assert overlap==reps
                assert overlap>=len(A)-cutoff
                if len(A)>=cutoff+2:
                    assert any(a!=sub(m,a) and sub(m,a) in A for a in A)
    return count
if __name__=="__main__":
    for p, expected in ((3,32),(5,8192)):
        n=check(p)
        assert n==expected
        print(f"PASS F_{p}^2: {n} symmetric subsets, all target sums")
