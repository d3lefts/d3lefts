# NIGHTFALL Q2 fair-cube witness 9/4; biased-product Bernstein sharpness is 4

2026-11-18, v1.1 prior-art/self-correction. **The 9/4 witness is a certified fair-cube lower-bound example, NOT a product-space coefficient record.** Strict pinned Lean source checks passed in run [44342791899](https://github.com/d3lefts/d3lefts/actions/runs/44342791899), receipt 14443254820. The stronger biased-product saturation (C_{2,\mathrm{product}}\ge4) was ALREADY in merged PR #805, as an author-side analytic limit with exact rational regression and CI. No universal coefficient-four UPPER bound, novelty priority, or independent referee certificate is claimed.

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

**Correct classification:** the optimal degree-two FAIR-CUBE coefficient is at least 9/4. This example also supplies the logically weaker product-space lower bound 9/4, **superseded there by the biased Bernstein family in PR #805, which forces product-space coefficient at least 4.** The proposed universal upper inequality with coefficient 4 remains open; if proved, that constant would be sharp. The stronger proposed coefficient 2 is false on the fair cube. The best fair-cube coefficient is unknown from the audited evidence; do not claim this is the global fair-cube record.

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

## Corrected #805 priority: biased Bernstein already forces coefficient 4

**Two different constructions in merged PR #805:**

1. The **fair Chebyshev family** with n=d² demonstrates that no all-degree estimate of the form V²<=C d^beta B²M can have degree power beta<2; it does not establish fixed-d=2 coefficient 4.
2. The separate **biased Bernstein extremizing family** proves, at the author-analytic level, that each fixed degree d requires coefficient at least d². For d=2 this is EXACTLY 4, not 9/4.

Take n even, Xi iid Bernoulli(p) with FULL support 0<p<1, and
  f_n=T_2(2K/n-1)=1-8K(n-K)/n²,  K=sum_i Xi.
All binary words have positive probability, and f_n achieves +1 at K=0,n and -1 at K=n/2, so the **actual half-range B=1 exactly**. Write q=p(1-p), t=1-2p. Exact independent quadratic ANOVA and binomial calculations give

  V_n = 64q/n³ * [(n-1)² t² + 2(n-1)q],
  M_n = 64q/n⁴ * [(n-1)² t² + 4(n-1)q].

M is the original-law coordinate RESAMPLING influence, not flip influence under the fair law. Therefore
  lim_(n even -> infinity) V_n²/(B²M_n)
    = 64q t² = 16t²(1-t²)
    = 4 - 4(2t²-1)².

The limiting expression is at most 4 and **attains exactly 4** when t²=1/2, equivalently p_*=(1+1/sqrt(2))/2=(1+cos(pi/4))/2. This certifies (as an exact analytic calculation, not yet Lean-checked) the lower bound
  C2_product >= 4.

An entirely rational nearby bias p=17/20 gives the exact limiting ratio 2499/625=3.9984, and finite exact ratios:
  n=4:  2.299346590909091 (already stronger than fair 9/4)
  n=10: 3.248410170731707
  n=30: 3.737444163949275
  n=100:3.918938999926561
  n=300:3.971800416765973.

The same T2 symmetric family at fair p=1/2 has limiting ratio zero; small fair-cube coefficient searches miss this effect because the fixed half-range is controlled by extraordinarily rare tails at the biased source. A finite rational n=300 sample approaches but does NOT establish the limit; the limit follows from the closed expressions above.

**Reconciliation:** The currently Lean-certified arbitrary-product quadratic UPPER coefficient is approximately 105.416, not 4. The supported situation is
  4 <= C2_product_opt <= 105.416... (lower analytic, upper Lean)
and independently
  C2_fair_opt >= 9/4 (five-bit witness, Lean-certified).
There is no verified uniform-cube best-constant determination here. The coefficient-four product-space conjecture is an UPPER-bound problem now; a proof of C2_product<=4 would be optimal.

**Certification and independent replay:** Original PR #805 includes BERNSTEIN_SHARP_UE2_CONJECTURE_20261117.md and its exact checker check_ue2_bernstein_saturation.py. This PR adds a separately derived closed-form-versus-binomial-versus-native-ANOVA Fraction checker check_q2_biased_bernstein_priority.py. That CI audit does not certify the universal upper bound. The asymptotic sharpness is supported by explicit exact moment identities, but remains author-analytic rather than a named Lean limit theorem; independent expert review and priority clearance are still open.

## Certificate and reproducibility

- Python exact Fraction checker: check_q2_sharp_lower_nine_four.py.
  Distinct actual-source table and Walsh calculations, CHSH
  normalization and all signed Bell matrices.
- Lean finite-source witness certificate:
  research/nightfall/formalization/universal/Q2SharpFiveBitLower.lean.
  Defines the actual original fair product by exact 32-state uniform
  sums; prove mean zero, variance 12, true resampling influence 4,
  range +/-4, and exact 9/4 ratio, plus failure of coefficient two. The exact-head kernel proof and source-world bijection passed in run 44342791899.
- Dedicated strict pinned Lean workflow:
  nightfall-q2-sharp-lower-nine-four-lean.yml. The named axiom receipt has PASSED for the finite lower bound; this does not prove the proposed universal coefficient-four upper bound.
- Credit: classical Fourier analysis and original-source
  Efron–Stein influence; NIGHTFALL AI-assisted candidate search,
  exact independent replay. No priority or external sign-off.

## Decisive follow-up

1. Optimize unbiased five-bit real coefficient quadratic forms around
   the witness; exact-reconstruct any improvement before claiming it.
2. The highly biased binary near-saturators were ALREADY proved as an author-side lower-bound family in PR #805. Test categorical product laws only for potential upper-bound counterexamples, using original-source normalization and retaining rare-tail range information.
3. Attack the actual SHARP product-space C2<=4 proof, using source-coupled variance
   rather than the invalid total-influence shortcut (CHSH:
   sum_i I_i=2 > d B sqrt(M)=sqrt(2)).
4. If C2<=4 is obtained, Lean-certify native finite original-source theorem and transport via merged #776 finite-information pipeline. The matching C2>=4 bound is already supported by PR #805's biased Bernstein construction; still require an independent audit of that limit before claiming a fully certified sharp theorem.

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


## Exact structural control: small pure homogeneous signed graphs

A second exhaustive *integer* checker enumerates every homogeneous
quadratic on n=3,4,5 uniform fair signs whose off-diagonal Walsh
coefficients belong to {-1,0,+1}. The search sizes and attained maxima
of V²/(B²M) are:

 n=3: 26 nonzero signed graphs; maximum 9/8.
 n=4: 728 nonzero signed graphs; maximum 2.
 n=5: 59,048 nonzero signed graphs; maximum 2.

The separate pure homogeneous six-bit witness attains 9/4. Thus the
strict 2 barrier is first broken here by **six fair coordinates within
this explicitly enumerated integer-coefficient class**. This is NOT
a universal minimal-dimension theorem: arbitrary real coefficients,
categorical laws, and larger n are not exhausted.

Combined with signed bipartite matrices, the repo checks 80,292
nonzero exact integer test objects, plus the explicit five- and
six-bit witnesses. No claim of statistical significance or universal
upper bound follows from exhaustive search of bounded dimensions.
