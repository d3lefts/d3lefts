#!/usr/bin/env python3
"""Exact finite witness audit for Q3 two-replica reconstruction (not a universal proof)."""
from fractions import Fraction as F
from itertools import product, combinations
from math import prod


def check(laws, f, pure=False):
    n = len(laws)
    assert n in (3, 4)
    omega = list(product(*(range(len(law)) for law in laws)))
    sign = list(product((0, 1), repeat=n))
    subsets = [T for k in range(n+1) for T in combinations(range(n), k)]
    mass = {x: prod(laws[i][x[i]] for i in range(n)) for x in omega}
    fv = {x: f(x) for x in omega}
    R = {x: F(0) for x in omega}
    A = F(0)
    U = F(0)
    J = [F(0) for _ in range(n)]
    for x in omega:
        for z in omega:
            w = mass[x] * mass[z]
            words = {e: fv[tuple(x[i] if e[i] else z[i] for i in range(n))] for e in sign}
            # This Walsh sign convention assigns -1 to e_i=1.
            hat = {T: sum((-1)**sum(e[i] for i in T)*words[e] for e in sign)/2**n for T in subsets}
            for e in sign:
                q = sum((-1)**sum(e[i] for i in T)*hat[T] for T in subsets if len(T)<=2)
                A = max(A, abs(q))
            q_at_x = sum((-1)**len(T)*hat[T] for T in subsets if len(T)<=2)
            R[x] += mass[z] * q_at_x
            U += w*sum(hat[T]**2 for T in subsets if 1<=len(T)<=2)
            for i in range(n):
                J[i] += w*sum(hat[T]**2 for T in subsets if 1<=len(T)<=2 and i in T)

    def noise(t, x):
        return sum(R[y]*prod(t*(y[i]==x[i])+(1-t)*laws[i][y[i]] for i in range(n)) for y in omega)

    for x in omega:
        # Exact inverse: f=(37 T_1 -32 T_3/4 +32 T_1/4 -16 T_0)R/21.
        recovered = (37*noise(F(1),x)-32*noise(F(3,4),x)
                     +32*noise(F(1,4),x)-16*noise(F(0),x))/21
        assert recovered == fv[x], (x,recovered,fv[x])

    B=max(abs(z) for z in fv.values())
    mean=sum(mass[x]*fv[x] for x in omega)
    V=sum(mass[x]*(fv[x]-mean)**2 for x in omega)
    I=[]
    for i in range(n):
        val=sum(mass[x]*laws[i][a]*(fv[x]-fv[tuple(a if j==i else x[j] for j in range(n))])**2/2
                for x in omega for a in range(len(laws[i])))
        I.append(val)
    assert B<=F(39,7)*A
    assert V/2<=U<=F(3,4)*V
    assert all(F(3,8)*I[i]<=J[i]<=I[i]/2 for i in range(n))
    if pure:
        assert U==F(3,4)*V
        assert all(J[i]==F(3,8)*I[i] for i in range(n))
    print('PASS n=',n,'alphabet sizes=',[len(s) for s in laws],
          'B=',B,'A=',A,'V=',V,'U=',U,'M=',max(I),'J=',max(J))


if __name__=='__main__':
    p=[F(1,3),F(2,5),F(3,7),F(1,2)]
    law=[(1-v,v) for v in p]

    def mixed(x):
        z=[x[i]-p[i] for i in range(4)]
        return F(1,2)*z[0]+F(5,3)*z[1]*z[2]-F(3,4)*z[0]*z[1]*z[3]+F(2,3)*z[1]*z[2]*z[3]+F(1,5)*z[2]

    check(law,mixed)
    cat=[(F(2,3),F(1,3)),(F(1,2),F(1,3),F(1,6)),(F(3,5),F(2,5))]

    def cubic(x):
        return (F(x[0]==1)-cat[0][1])*(F(x[1]==2)-cat[1][2])*(F(x[2]==0)-cat[2][0])

    check(cat,cubic,pure=True)
    print('PASS exact source-replica reconstruction / variance-influence sandwich, two heterogeneous cases')
