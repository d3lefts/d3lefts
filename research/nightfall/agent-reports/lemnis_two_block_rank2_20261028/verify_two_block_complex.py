#!/usr/bin/env python3
"""Independent exact complex arithmetic and physical partial traces, no spectral projection imports."""
from itertools import product
from collections import defaultdict
import sympy as s
from fractions import Fraction

I=s.I
Q=s.Rational

def compose(u,v,x,y):
    out=defaultdict(lambda: s.Integer(0))
    for a,c in u.items():
        for b,d in v.items():out[(a,b)]+=c*s.conjugate(d)
    for a,c in x.items():
        for b,d in y.items():out[(a,b)]+=c*s.conjugate(d)
    return dict(out)

def qtraces(C,n,t):
    score=s.Integer(0)
    for mask in range(1<<n):
        erased=[i for i in range(n) if (mask>>i)&1]
        keep=[i for i in range(n) if not (mask>>i)&1]
        reduced=defaultdict(lambda:s.Integer(0))
        for (a,b),v in C.items():
            if all(a[i]==b[i] for i in erased):
                reduced[(tuple(a[i] for i in keep),tuple(b[i] for i in keep))]+=v
        score+=(-t)**len(erased)*sum(v*s.conjugate(v) for v in reduced.values())
    return s.simplify(s.expand(score))

def norm(u):return s.simplify(sum(v*s.conjugate(v) for v in u.values()))

# Complex and noncollinear signals in disjoint local alphabets on all 3 sites.
# Both blocks have dimension 2 per site; this tests more than the singleton theorem.
n=3; d=4
B0=list(product((0,1),repeat=n));B1=list(product((2,3),repeat=n))
u={B0[0]:1+I, B0[3]:2-I, B0[5]:-1}
v={B0[0]:2+I, B0[2]:1-I,B0[5]:2}
x={B1[0]:1-I, B1[3]:2+2*I, B1[6]:1}
y={B1[0]:2, B1[3]:1+I, B1[5]:3-I}
C=compose(u,v,x,y)
A2=norm(u)*norm(v);B2=norm(x)*norm(y)
for t in [Q(0),Q(1,4),Q(1,3),Q(1,2)]:
    exact=qtraces(C,n,t)
    # Prove exact lower bound by comparing floats only AFTER reconstructing rational exact Q.
    ab=s.sqrt(A2*B2)
    theoretical=(1-t)**n*(A2+B2)-2*t**n*ab
    assert s.simplify(s.im(exact))==0
    assert float(s.N(exact-theoretical,40))>-1e-12
    assert float(s.N(exact,40))>=-1e-12
    print('complex d=4 n=3 t=',t,'Q=',exact, 'lower=',str(theoretical))

# Sharp threshold t=1/2 for every n: two disjoint single-symbol blocks.
for n in range(1,5):
    a=(0,)*n;b=(1,)*n
    x={(a,a):s.Integer(1),(b,b):s.Integer((-1)**(n+1))}
    for t in (Q(1,4),Q(1,2),Q(3,4)):
        actual=qtraces(x,n,t)
        predicted=2*((1-t)**n-t**n)
        assert actual==predicted,(n,t,actual,predicted)
        assert (actual<0)==(t>Q(1,2))
    print('sharpness n=',n,'Q(3/4)=',qtraces(x,n,Q(3,4)))
print('PASS: physically independent complex blocks and exact universal-threshold controls')
