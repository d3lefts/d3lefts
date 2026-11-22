#!/usr/bin/env python3
"""Exact rational-function check of the Simon degree-4 four-probe certificate.
Verifies determinant and dual weights only; not a proof of orbit completeness.
"""
import sympy as s
z=s.symbols('t')
def ai(c):
    c=s.Integer(c)
    return 1/c**3-4*z/c**2+6*z**2/c-3*z**3
def bi(c):
    c=s.Integer(c)
    return 3/c**2-6*z/c+3*z**2
def ad(c):
    c=s.Integer(c)
    return 1/c**2-4*z/c**2+6*z**2/c-3*z**3
def bd(c):
    c=s.Integer(c)
    return 3/c-6*z/c+3*z**2
M=s.Matrix([
 [ai(1),bi(1),ai(1),bi(1)],
 [ai(2),bi(2),ai(2),bi(2)],
 [ad(2),bd(2),ai(2),bi(2)],
 [ad(4),bd(4),ai(4),bi(4)],
])
N=1/z
functional=s.Matrix([
 3*(N+1)/(N**3*(N-1)),
 3*(N**2-N-1)/(N**2*(N-1)),
 3*(N+1)/(N**3*(N-1)),
 -3*(N+1)/(N**2*(N-1)),
])
weights=s.Matrix([
 z*(27*z**2-7*z+1)/(3*(1-z)**2*(1-3*z)),
 8*z**2*(1-8*z)/((1-z)*(1-2*z)*(1-3*z)),
 -4*z/(1-z),
 32*z/(3*(1-z)),
])
expected=s.Rational(27,2048)*(1-z)*(1-2*z)*(1-3*z)
assert s.factor(M.det()-expected)==0
assert all(s.factor(v)==0 for v in M.T*weights-functional)
print('PASS: determinant =',s.factor(M.det()))
print('PASS: exact dual weights match Simon expectation vector')
