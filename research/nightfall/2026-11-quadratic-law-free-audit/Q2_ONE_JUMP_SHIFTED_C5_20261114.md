# Sharp single-increment shifted reverse Khintchine: a genuine positive c/5 case

**14 November 2026.** Analytic theorem, with exact algebra; local symbolic
identity independently checked. Scalar Lean component is in
Q2ShiftedOneJumpC5.lean, **pinned compiler receipt pending**. This is NOT
the general independent-family theorem needed for unrestricted Q2.

## Statement and proof

Let H be any real Hilbert space, h in H deterministic, and Y any centered
Hilbert-valued random vector satisfying ||Y||<=c a.s. No symmetry, finite
alphabet, nonzero atom floor, or dimension restriction. Put W=h+Y,
e=||h||²+E||Y||²=E||W||², u=E||W||.

Jensen gives ||h||=||EW||<=u; pointwise ||W||<=||h||+c<=u+c.
Therefore

    e=E||W||² <= (u+c) E||W||=u(u+c).                 (1)

Let beta=(sqrt(3)-sqrt(2))/2 and kappa=(sqrt(6)-2)/4. The **exact
polynomial identity**

    (sqrt(3)u+beta c)²-u(u+c)=2(u-kappa c)² >= 0    (2)

and (1) imply the **sharp** one-increment bound

    sqrt(e) <= sqrt(3) E||h+Y|| + beta c.

Here beta=0.158918622597891... <1/5, so the conjectured c/5
inequality holds, even strictly more strongly, for **one** increment.

## Sharpness

Choose real H=R, c=1, p=(sqrt(3)-sqrt(2))², and centered Bernoulli Y:

    Y=1 with probability p;
    Y=-p/(1-p) with probability 1-p.
    h=p/(1-p).

Then |Y|<=1 because p<1/2, W=h+Y equals 1/(1-p) with
probability p and 0 otherwise. Thus

    u=p/(1-p),   sqrt(e)=sqrt(p)/(1-p),
    sqrt(e)-sqrt(3)u=beta.

Equality follows from the exact identity at u=kappa. Consequently
no theorem of the proposed form can use beta<0.1589186225... for
all centered single-increment laws.

## Why this is not the missing universal Q2 premise

For W=h+SUM_j Y_j, the crude pathwise bound is
||W||<=||h||+SUM_j c_j. Repeating (1) only yields a correction involving
the **sum of increment radii**, not the common maximum radius c.
The user-requested Q2 owner theorem requires a radius-independent
number of increments and hence a genuine tensorization/anti-concentration
argument. The fourth-moment-only c/5 envelope was already falsified in
PR #539, so this one-jump proof does not repair that failed route.

A falsifiable stronger sufficient route is

    E||h+SUM_j Y_j||² <= 2 (E||h+SUM_jY_j||)²
                       + c E||h+SUM_jY_j||.       (CONJECTURE)

If established for independent centered Hilbert vectors with ||Y_j||<=c,
then c/5 follows by completing the square:
    (sqrt(3)u+c/5)²-(2u²+cu)
      >= (u-c/6)²+(11/900)c²>=0,
using sqrt(3)>=5/3. This **quadratic moment comparison is not proved**;
any counterexample would rule out this route without ruling out c/5.

Research status: sharp one-increment theorem (analytic proof); multi-jump
c/5 and the sufficient quadratic comparison (conjectural); full
source-level Q2 99.263/99.432 (conditional). Novelty/prior art not cleared.
