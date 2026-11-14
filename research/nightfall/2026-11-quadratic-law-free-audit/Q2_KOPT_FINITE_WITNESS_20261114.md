# Exact actual-source lower bound for the universal Q2 coefficient

Research directed by Devin J. Wright; AI-assisted independent algebraic witness and constrained-optimization audit, 2026-11-14. Status: exact mathematical proof; source-level Lean witness formalization not yet finished. Not a claim of the exact universal optimum.

Define K_opt to be the infimum of constants K such that for every finite independent product p (common finite nonempty alphabet, varying marginals, zero masses allowed) and every real f with pointwise |f|<=B and actual Efron–Stein degree at most two, Var_p(f)^2 <= K B^2 max_i I_i(f).

## Exact three-bit product witness

Let three independent signs X_1,X_2,X_3 have P(X_i=+1)=5/6, P(X_i=-1)=1/6. Set
  f(x) = (x_1*x_2+x_1*x_3+x_2*x_3 - 1)/2.
It is +1 if all three signs coincide, -1 otherwise. |f|<=1 pointwise. As a polynomial in the independent signs it has ordinary degree <=2, hence also degree <=2 in the biased Efron–Stein decomposition (each sign is an affine function of its centered one-site component).

P(f=+1) = (5/6)^3+(1/6)^3 = 7/12. Therefore Var_p(f)=4*(7/12)*(5/12)=35/36.

For each i, the conditional variance with respect to X_i is
  I_i(f) = Var(X_i)/4 * E[(X_j+X_k)^2]
         = (5/9)/4 * (2+2*(2/3)^2)
         = 65/162.
The source influence definition is E[(f-E_i f)^2], not twice that number. Thus
  Var(f)^2/max I_i(f)=(35/36)^2 / (65/162)=245/104=2.355769230769230... .
This is an unconditional EXACT rational lower bound K_opt >=245/104.

## Optimizing the same source family

Let all three independent signs have common mean mu in [-1,1], t=mu^2. The SAME f has
  Var_p(f)=(3/4)*(1+3t)*(1-t),
  I_i(f)=(1-t^2)/2,
  R(t)=Var(f)^2/max_i I_i(f)
      =(9/8)*(1+3t)^2*(1-t)/(1+t).

At t=1 the denominator vanishes; R has zero limit as t->1. Differentiation gives the sign of
  d/dt(log R)=6/(1+3t)-2/(1-t^2)
             =2*(2-3t-3t^2)/((1+3t)*(1-t^2)).
For t in [0,1), unique maximum occurs at t*=(-3+sqrt(33))/6 (positive root of 3t^2+3t-2=0).
Substitution gives
  **R(t*)=(99*sqrt(33)-531)/16 ≈2.3569813754540525.**
This is an exact algebraic LOWER bound for K_opt, but it only optimizes a single symmetric three-bit family: it is not the true universal K_opt.

## New upper bound under certification

Analytic source-only upper candidate
  K_589=[8sqrt(3)+2(1+sqrt(2))*(sqrt(13)-sqrt(3))+8sqrt((5sqrt(5)-11)/6)]^2
     ≈589.975690496716,
derived from already source-certified joint energy a_i^2+s_i<=I_i and local cubic fourth moment at sqrt(s_i), using
  13(a^2+s)-(a+2sqrt(3)*sqrt(s))^2=(2sqrt(3)*a-sqrt(s))^2.
Pinned Lean proof candidate in Q2589ScalarSite and ActualSourceQ2589Terminal. The independently validated mainline fallback remains 736.673.

No assertion that the numerical gap 2.35698–589.976 can be closed within the current three scalar budgets. The actual universal extremizers may have more coordinates/alphabets or nonuniform laws; the 589 site-budget dual is not a proof of global optimality.
