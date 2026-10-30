#!/usr/bin/env python3
"""Independent F9 field representation and exhaustive six-coordinate prefix fibers.

F9 = F3[v]/(v²+v+2), different from primary F3[u]/(u²+1).
Count global sign orbits directly on all 9^6 signals.
"""
import itertools

def sq(z):
    a,b=z%3,z//3
    return (a*a+b*b)%3+3*((2*a*b+2*b*b)%3)

def neg(z):
    return (-z%3)+3*(-(z//3)%3)

def add(a,b):
    return ((a%3+b%3)%3)+3*((a//3+b//3)%3)

def audit():
    assert [z for z in range(9) if sq(z)==1]==[1,2]
    independent=set()
    dependent={}
    count=0
    for x in itertools.product(range(9),repeat=6):
        count+=1
        if all(sq(z)==1 for z in x[:4]):
            canonical=min(x,tuple(neg(z) for z in x))
            independent.add(canonical)
        if all(sq(z)==1 for z in x[:3]):
            canonical=min(x,tuple(neg(z) for z in x))
            reading=sq(add(add(x[0],x[1]),x[2]))
            dependent.setdefault(reading,set()).add(canonical)
    assert count==531441
    assert len(independent)==648
    frequencies={reading:len(v) for reading,v in dependent.items()}
    assert frequencies=={0:729,1:2187},frequencies
    return {"field":"F3[v]/(v²+v+2)","total_signals":count,
            "four_independent_nonzero_prefix_orbits":648,
            "fourth_dependent_prefix_orbits":frequencies,
            "status":"EXACT_INTERNAL_EXHAUSTIVE"}

if __name__=="__main__":
    print("PASS",audit())
