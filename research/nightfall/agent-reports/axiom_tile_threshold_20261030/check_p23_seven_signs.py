#!/usr/bin/env python3
"""Exact-field seven-sign certificate for GF(23)[u]/(u^2-5)."""
from itertools import product
p=23
assert pow(5,(p-1)//2,p)==p-1  # 5 is quadratic nonresidue
weights=[(1,0),(2,0),(4,0),(8,0),(0,1),(0,2),(0,4)]
points=set()
for bits in product((0,1),repeat=7):
    x=(4+sum(b*a for b,(a,_) in zip(bits,weights)))%p
    y=(4+sum(b*v for b,(_,v) in zip(bits,weights)))%p
    z=(x,y)
    assert z not in points
    points.add(z)
assert len(points)==128
assert all(((-x)%p,(-y)%p) not in points for x,y in points)
squares=set()
for x,y in points:
    z=((x*x+5*y*y)%p,(2*x*y)%p)
    assert z not in squares
    squares.add(z)
assert len(squares)==128
print("PASS p23 explicit 7-sign GF(23^2) witness: 128 unique squares")
