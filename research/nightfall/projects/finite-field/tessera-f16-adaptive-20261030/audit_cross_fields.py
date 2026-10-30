#!/usr/bin/env python3
"""Independent GF9/GF25 quadratic-prime-field full-phase oracle comparisons."""
from itertools import product

def mul(x,y,q,c):
    a,b=x;d,e=y
    return ((a*d+c*b*e)%q,(a*e+b*d)%q)
def power(x,n,q,c):
    z=(1,0)
    while n:
        if n&1:z=mul(z,x,q,c)
        x=mul(x,x,q,c)
        n//=2
    return z

def check(q,c):
    H=range(1,q)
    outputs={power((a,b),q-1,q,c)
             for a in range(q) for b in range(q)}
    assert len(outputs)==q+2
    # Use the original full H, never an altered proper subgroup.
    one={power((1,e),q-1,q,c) for e in H}
    assert len(one)==q-1
    if q==3:
        def row(x,y):
            return power(((1+x)%q,(1+y)%q),q-1,q,c)
        assert len({(row(a,b),row(d,e))
                    for a,b,d,e in product(H,repeat=4)})==16
        assert 2**5>5**2
        print("PASS q3: two fixed full-phase squares encode four phases, not five")
    if q==5:
        assert 4**3>7**2
        print("PASS q5: two full-phase fourth powers cannot encode three phases")

check(3,2)  # t²=2 in F9, irreducible over F3
check(5,3)  # t²=3 in F25, irreducible over F5
