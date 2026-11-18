# NIGHTFALL sharp degree-two coefficient: verified five-bit lower bound

2026-11-18. Status: **exact analytic five-bit witness, independent original-law Fraction verifier, Lean source candidate (pinned CI pending).** No global upper bound, no optimal-constant determination, no novelty/priority assertion.

## What is actually proved by the finite witness

For fair signs x0,...,x4 define the **degree-two** multilinear polynomial

 f(x) = x0 + x2 + x3 + x4
       + x0 x1 - x0 x2 + x0 x3
       - x1 x2 - x1 x3 + x1 x4
       + x2 x4 - x3 x4.

Every nonzero Walsh coefficient is +1 or -1 (exactly twelve terms).
The genuine 32-point fair-cube output histogram is

 f(x) = -4: 12 worlds;  f(x) = 0: 8 worlds;  f(x) = 4: 12 worlds.

Hence the half-range (centered essential radius) B = 4, the true
source mean is 0, the variance V = E[f²] = 12, and every original
fair **resampling influence** is

 I_i(f) = E[ (f(X) - f(X_i <- X'_i))² / 2] = 4,
 i=0,...,4.

The same I_i is independently computed by physical input flips
 E[(f(X)-f(flip_i X))²]/4 and by Walsh Parseval
 sum_(S contains i) hat_f(S)² = 4.

Thus the exact ratio V²/(B² M) = 144/(16*4) = **9/4**.
Rescale f/4 to a function with range {-1,0,+1},
variance V=3/4 and all five influences M=1/4.

**Mathematically valid conclusion:** the optimal degree-two universal
constant C2 is at least 9/4, because a fair 5-bit cube is a special
case of arbitrary independent products. The proposed sharp-Q2
coefficient 4 (N-UE2(2,1) at d=2) has NOT been refuted or proved.
The tempting stronger C2=2 is false.

## Scope of separate exhaustive search

Independent integer-valued Bell-type table sweep enumerated ALL
nonzero bipartite matrices with entries in {-1,0,1} of shapes
2x2 (80), 2x3 (728), 3x3 (19,682), totaling 20,490 nonzero
matrices. Their maximum ratio is exactly 2 (e.g. CHSH).
This is NOT exhaustive over real coefficients, arbitrary graphs,
biased/categorical product laws or all five-bit quadratics.
Continuous candidate search identified the non-bipartite five-bit
witness; exact rational recomputation is separate.

The exact five-bit witness is already a higher ratio than CHSH.
No finite search, including a full small-Bell enumeration, proves an
upper bound for all n.

## Chebyshev sharpness distinction

Merged dossier PR #805 verifies classical Chebyshev examples forcing
degree exponent at least 2 in ANY **uniform in d** inequality
V² <= C d^beta B² M with absolute C. It DOES NOT show that the
coefficient d² is attained, or that C2=4 is best at fixed d=2.
In particular, its finite d=2, n=4 Chebyshev witness has ratio
V²/(B² M) = 3/4, not 4. The coefficient-one conjecture remains
an independent optimal-constant question.

The currently kernel-supported arbitrary-product degree-two upper
bound is approximately C2=105.416 (merged PR #776), not C2=4.
Our present verified quantitative interval from the explicit witness
and that upper result is

    9/4 <= C2_opt <= ~105.416,

with no claim that either endpoint on the upper side is best available
in the literature. A recent-date theorem-level prior-art search and
independent referee check are still necessary.

## Certificate and reproducibility

- Python exact Fraction checker: check_q2_sharp_lower_nine_four.py.
  Distinct actual-source table and Walsh calculations, CHSH
  normalization and all signed Bell matrices.
- Lean finite-source certificate candidate:
  research/nightfall/formalization/universal/Q2SharpFiveBitLower.lean.
  Defines the actual original fair product by exact 32-state uniform
  sums; prove mean zero, variance 12, true resampling influence 4,
  range +/-4, and exact 9/4 ratio, plus failure of coefficient two.
- Dedicated strict pinned Lean workflow:
  nightfall-q2-sharp-lower-nine-four-lean.yml. Green CI proves only
  this finite lower bound. Do NOT promote before the named
  #print axioms receipt and exact-head provenance are inspected.
- Credit: classical Fourier analysis and original-source
  Efron–Stein influence; NIGHTFALL AI-assisted candidate search,
  exact independent replay. No priority or external sign-off.

## Decisive follow-up

1. Optimize unbiased five-bit real coefficient quadratic forms around
   the witness; exact-reconstruct any improvement before claiming it.
2. Test highly skew binary and categorical product laws, since a
   fair-cube lower bound need not be worst-case for all product laws.
3. Attack an actual C2<=4 proof, using source-coupled variance
   rather than the invalid total-influence shortcut (CHSH:
   sum_i I_i=2 > d B sqrt(M)=sqrt(2)).
4. If C2<=4 is obtained, Lean-certify native finite original-source
   theorem and transport via merged #776 finite-information pipeline.
   Do not call it sharp unless C2>=4 is independently established.

This result is a **lower-bound construction**, not a breakthrough or
solution of Turturean's all-degree variance-exponent-two question.


## Stronger structural presentation: pure homogeneous quadratic on six fair bits

The previous five-bit polynomial f decomposes as f=f1+f2 into
singleton and pair Walsh sectors. Add a SIXTH independent fair sign z,
and define

  F(x0,...,x4,z)=z f1(x0,...,x4)+f2(x0,...,x4).

F is **homogeneous degree exactly two**. Explicit coefficients are
the eight pair terms of f, plus the four new terms
z*x0+z*x2+z*x3+z*x4. The underlying signed interaction graph is
non-bipartite; this is crucial, since the exhaustive bipartite
subfamily has only reached ratio 2.

The exact identity F(x,z)=f(z*x) follows from the parity of f1/f2.
Since (z,x)->z*x has the same uniform five-bit output law as x,
F has the doubled output histogram:
-4:24 states, 0:16 states, +4:24 states.
Thus B=4,V=12 as before. Its original fair resampling influences
are I_i(F)=I_i(f)=4 for i=0,...,4 and
I_z(F)=Var(f1)=4. Hence M=4 and ratio 9/4 again.

**Corrected mechanism claim:** The lower-bound obstruction does NOT
depend on mixing linear and quadratic Fourier degrees; one more fair
coordinate homogenizes it without changing variance, B or M. The
relevant distinction in this family is **bipartite versus non-bipartite
quadratic coupling**. A general sharp-Q2 proof must address
non-bipartite signed graphs rather than just Littlewood's bipartite
bilinear bound.

The exact Python checker independently enumerates all 64 six-bit
worlds, computes physical source resampling influences, and verifies
the parity homogenization identity on every one of them. A Lean
certificate for the 5-bit model is pending its strict exact-head CI;
the six-bit extension is not a separate kernel theorem yet.


## General reusable operator: fair-cube quadratic homogenization

For any fair-cube quadratic f=c+f1+f2 with degree-one f1 and
homogeneous degree-two f2, introduce one independent fair sign z and set
H(z,x)=z*f1(x)+f2(x). Exact identity:

  H(z,x) = f(z*x)-c.

Consequently **for every such f**:
- H is homogeneous of degree two on n+1 fair signs;
- the centered essential radius B(H)=B(f);
- Var(H)=Var(f);
- for every old coordinate i, Inf_i(H)=Inf_i(f);
- the **new anchor influence** is Inf_z(H)=Var(f1).

Thus the maximal influence changes from M(f) to
max(M(f), Var(f1)). In general this extra anchor influence may be
larger: homogenization is NOT an automatic constant-preserving
equivalence between all mixed and all homogeneous Q2 problems.

For the current explicit five-bit witness Var(f1)=4=M(f), so the
homogenization preserves M exactly and proves the pure homogeneous
six-bit ratio 9/4. This is a mechanism-level explanation of why the
bipartite matrix sweep is insufficient. Any attempt to deduce sharp Q2
from a bipartite Littlewood inequality must account for non-bipartite
signed interaction graphs and the artificial-anchor influence cost.

Audit status: elementary fair-cube Fourier identity, verified for the
specific witness by exact 64-world physical resampling enumeration;
the fully general operator is an author-side mathematical observation,
not a new named Lean declaration or a novelty claim.
