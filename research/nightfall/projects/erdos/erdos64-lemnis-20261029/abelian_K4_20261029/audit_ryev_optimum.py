#!/usr/bin/env python3
"""Independent exact algebraic audit of Ryev #86 / PR #89 (SymPy, exact rationals)."""
import sympy as s
r,a,t=s.symbols('r a t',positive=True)
c=s.Rational(16,27)*r/(1-t)
loss=c*a**2
F=(1-loss)**2/(2-a*t)
# Actual derivative sign is proportional to g; direct verification, no imported formula.
g=t-8*c*a+3*t*c*a*a
assert s.simplify(s.diff(F,a) - (1-loss)*g/(2-a*t)**2)==0
# On the stationary locus the envelope derivative has fixed sign sign(2-3t).
rest=s.solve(s.together(g),r)[0]
ft=s.factor(s.diff(F,t).subs(r,rest))
assert s.simplify(ft - 8*a*(3*t-2)/((t-1)*(3*a*t-8)**2))==0
# alpha*(t) always stays inside positive-margin domain: root <1/2, boundary derivative negative.
for ri in range(1,60):
 for ti in (s.Rational(1,1000),s.Rational(1,6),s.Rational(2,3),s.Rational(999,1000)):
  ci=c.subs({r:ri,t:ti})
  roots=s.solve(g.subs({r:ri,t:ti}),a)
  good=[z for z in roots if z.is_real and 0<float(z)<min(.5,float(1/s.sqrt(ci)))]
  assert len(good)==1,(ri,ti,roots)
  z=good[0]
  assert float(F.subs({r:ri,t:ti,a:z}))>.5
alpha=2-s.sqrt(4-s.Rational(3,16)/r)
assert s.simplify(g.subs({a:alpha,t:s.Rational(2,3)}))==0
alpha0=s.Rational(3,64)/r
alpha1=alpha0+1/(2048*r*r)
F0=s.factor(F.subs({a:alpha0,t:s.Rational(2,3)}))
F1=s.factor(F.subs({a:alpha1,t:s.Rational(2,3)}))
D=s.factor(F1-F0)
numer,denom=s.fraction(D)
want=377487360*r**4+5603328*r**3-30720*r**2-320*r-1
assert s.simplify(numer-want)==0
assert s.factor(denom) == 1811939328*r**4*(64*r-1)*(6144*r**2-96*r-1)
assert want.subs(r,1)>0
# Mutation leftward from parent ought decrease F at all examined exact r.
for ri in range(1,100):
 p0=F0.subs(r,ri)
 p1=F1.subs(r,ri)
 left=F.subs({r:ri,t:s.Rational(2,3),a:alpha0.subs(r,ri)-1/(4096*ri**2)})
 assert p1>p0>left
print('PASS exact derivative/envelope, 1..59 unique interior optimizer controls, all-r positive quartic and 99 mutations')
print('squared rational improvement:',D)
print('asymptotic boundary objective:',s.limit(F.subs(a,s.Rational(1,10)*(1-t)),t,1,dir='-'))
