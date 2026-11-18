# NIGHTFALL real-row exponent-two bridge: exact singleton-R NO-GO

Version 1.0 • 2026-11-18 • **New falsifier of a proposed auxiliary route**, not a solution of Turturean §9.5 and not a new general-product influence theorem. Structural antecedents (AND/biased tribes, Rubinstein sensitivity versus block sensitivity) are classical; do NOT claim global priority or novelty. Analytic proof is self-contained, exact original-law Fraction checker provided. No Lean theorem or independent human referee claimed.

## Objective and corrected proof-target taxonomy

Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773v1, §9.5 asks:

For all finite **uniform Boolean cubes**, any nonconstant real f admitting a nonnegative full fractional row a^x at each point with sum_i a_i^x<=K, is there an absolute c>0 such that
  max_i Inf_i(f) >= c Var(f)^2/K^2 ?

The full row requirement is **for every pair (x,y)**:
  |f(x)-f(y)| <= sum_(i:x_i!=y_i) a_i^x.
This is not the same as merely bounding singleton coordinate residuals at x.

A proposed stronger arbitrary-product shortcut from PR #808 was
  **(FALSE R-BRIDGE)** V^2 <= C R^2 M
with a universal degree-free constant C, where
  R=esssup_x sum_i |D_i f(x)|,
  D_i f(x) = f(x)-E_[X_i]f(x),
  M=max_i E|D_i f|²,
and all quantities use the original heterogeneous product law.

This new falsifier shows that **NO SUCH C EXISTS, even for Boolean AND on independent biased binary inputs**. Do not use the "bounded pointwise singleton sum" operator of PR #808 to bypass full fractional rows. Crucially, this does **not** contradict the actual full-row conjecture, the universal polynomial-degree exponent-two conjecture, or the sharp degree-two conjecture.

## Exact all-n counterexample

For each integer n>=2, take independent Bernoulli variables X_1,...,X_n with common full-support bias p_n=1-1/n and define f_n(X)=prod_i X_i in {0,1}. Set q_n=p_n^n. The ANOVA/algebraic degree of f_n is n, not fixed degree.

Under the true source law:

- f_n is Bernoulli(q_n), so V_n=Var(f_n)=q_n(1-q_n).
- Given the other n-1 bits, the function is identically zero unless every other bit is one, in which case it equals X_i. Thus I_i(f_n)=p_n^(n-1)*p_n*(1-p_n)=q_n/n. This is the original-law resampling influence, equal to E[(f(X)-f(X^{i<-X_i'}))²]/2.
- If x=(1,...,1), then D_i f_n(x)=1-p_n=1/n for every coordinate, so sum_i |D_i f_n(x)|=1.
- If x has exactly one zero in position i, then D_i f_n(x)=-p_n and every other coordinate residual is zero; sum |D_i|=p_n<1.
- If x has >=2 zeros, all residuals vanish. Every x has positive probability, hence R_n=1 exactly.
- The optimal FULL row cost is K_n=n. At all ones, every singleton change alters f by one, forcing a_i>=1 for every i. The all-ones row a_i=1 is feasible. At any zero-output vertex, put a_i=1 on one zero coordinate and 0 elsewhere; this is a valid full row of cost1. Therefore K=max_x K(x)=n exactly.

Consequently

  V_n²/(R_n² M_n) = n q_n(1-q_n)²
        ~ [e^(-1)(1-e^(-1))²] n
        ~ 0.146995943066 n -> infinity.

**Entirely elementary linear lower bound, no asymptotic numerics needed:**
for n>=2, q_n=(1-1/n)^n is increasing from q_2=1/4, and q_n<=1/2. The monotonicity follows by differentiating x log(1-1/x), whose derivative is u-log(1+u)>=0 for u=1/(x-1)>0. For the upper bound, Bernoulli/binomial gives (n/(n-1))^n=(1+1/(n-1))^n>=1+n/(n-1)>2. Hence

  V_n²/(R_n²M_n) = n q_n(1-q_n)² >= n/16.

For every candidate universal C choose n>16 C. This disproves the R bridge for **original independent product laws**.

But

  V_n²/(K_n² M_n) = q_n(1-q_n)²/n -> 0.

So Turturean's full-row statement survives this example. The direct source-cost difference K_n/R_n=n is unbounded.

## A fair-cube distinction: classical Rubinstein sensitivity-block separation

To ensure the K/R non-equivalence is not merely a biased-law artifact, consider m blocks of 2m unbiased bits each. For a block set h=1 only when its pattern has exactly one of the m designated disjoint adjacent pairs active and all other bits zero. Let f=OR_j h_j on n=2m² fair coordinates.

- At the all-zero input, there are m² disjoint sensitive *two-coordinate* blocks. Every full row must have cost at least m²; assigning weight one to the first coordinate of every pair makes a feasible row of cost exactly m².
- The maximum Boolean sensitivity is exactly 2m: at a positive input, flipping any bit of its unique positive block destroys it; at a negative input, each block contributes at most one sensitive coordinate. For fair binary inputs D_i f=(f(x)-f(x^i))/2. Thus R=max_x sum_i |D_i f(x)|=m.
- Therefore K(f)>=K(0)=m² whereas R(f)=m; K/R>=m, unbounded even on uniform fair products.

This is a classical sensitivity-versus-block-sensitivity mechanism (Rubinstein); NIGHTFALL's contribution here is an explicit *proof-attack application* to the row-versus-singleton surrogate. It does not refute a fair-cube R influence inequality itself, only a proposed constant comparison K<=C R.

The original-law R always satisfies R<=K for a true full row bound on finite positive-support products (conditional expectation averages the row's singleton constraints). On fair signs, R<=K/2. Therefore an R-bridge would IMPLY a full-row bridge with a related constant; the converse does not follow, and the stronger arbitrary-product R-bridge is now disproved.

## Exact checker, test cases, and certification

Reproduce with:
  python3 -I research/nightfall/flagship-influence/check_real_row_R_no_go_exact.py

- Exact Fraction formula replay at n=2,4,8,10,20,50,100,300.
- For n<=8: independently enumerates all full-support source worlds; checks actual conditional expectations, pointwise R, variance, the *separate* independent two-replica resampling influences, and feasible full rows at every point.
- For m=1,2,3: exhaustive fair-cube Rubinstein truth tables (up to 2^18 states) verify maximum sensitivity, exact sensitive blocks and explicit full row at zero.
- CI adds an immutable source SHA and execution receipt. No Lean formalization of all-n divergence or non-author mathematical signoff; analytic formulas remain author-proved, not kernel-certified.

## Corrected roadmap: real-row K first

1. **Keep as flagship:** Prove (or disprove) Turturean's full-row real-valued inequality on finite uniform cubes, and then its *separately defined* original-product generalization. A theorem V²<=C K² M plus degree-d full rows K=O(d²B) yields V²<=C' d⁴ B² M.
2. **Retire:** any unqualified universal bound V²<=C R² M on arbitrary original products. The AND family is a valid strict falsifier for every finite C; adding a hidden bias floor or degree cap changes the statement and must be explicit.
3. **Existing usable representation:** #814 threshold-Gram/PSD original-source matrix with delta^T C delta=V and delta^T J_i delta=I_i, and the *coupled* two-threshold conic inequality; avoid single-cut m^4 loss and false entrywise matrix domination.
4. **Independent audit:** In #814 the sharp constant c is sometimes written as 4 V²<=K²M for Boolean/additive controls, i.e. V²<=K²M/4. Distinguish this scale from Turturean's c in I>=c V²/K². The global real-valued constant is OPEN.
5. **Finite counterexample search:** for proposed full-row c, optimize exact primal/dual full row costs K via rational LP and true original-source resampling influence. Include AND/no-go and Rubinstein as negative controls for the wrong R substitute; do not claim lack of finite counterexamples proves a theorem.
6. **ANOVA formalization debt:** #801 presently proves the standard degree-two Hoeffding condition implies the third-residual condition in pinned Lean, but does not fully supply the converse arbitrary-index decomposition; do not conflate this with the row bridge.
7. **Novelty and publication:** no submission or breakthrough priority. Attribution to classical sensitivity constructions and Turturean 2026 is mandatory. This is a **certified finite falsifier family by exact formula/checker**, not a certificate of the positive K conjecture.

Discovery graph:
Turturean §9.5 -> full pairwise rows K -> tempting singleton R replacement -> biased-AND source law -> exact closed moments, true resampling and per-point residual -> R=1 versus K=n -> divergence n/16 -> retire false operator -> focus coupled real-valued row geometry and cross-threshold covariance.


## v1.1 actual full-row cost search (not an upper-bound proof)

An additional dependency-free exact *rational linear-programming* engine
\`check_real_row_K_exact_lp.py\` now explores the CORRECT conjecture,
not the disproved singleton shortcut.

For every supported original-source word x, it solves:
  min sum_i a_i,
  subject to a_i>=0 and
  sum_(i:x_i!=y_i) a_i >= |f(x)-f(y)|
  for ALL supported y.

It enumerates all basic feasible vertices by exact rational Gaussian
elimination and verifies every candidate's full row feasibility. The
global K is the maximum of the resulting per-point optima. No SciPy
or floating point, and no replacement of true original source laws.
Original resampling influences are independently computed by
conditional squared residuals and fresh-coordinate two-replica means.

Initial preregistered deterministic scope: 9 nonconstant rational
observable tables with 3 independent coordinates, each with positive
heterogeneous rational categorical laws, in alphabets (2,2,2),
(3,2,2) and (2,3,3). Test-only controls include additive fair-sign
f=sum_i(2X_i-1) on 3 bits, where
  V=3, M=1, R=3, K=6,
  V²/(R²M)=1 and V²/(K²M)=1/4 EXACTLY.
This additive example saturates the candidate sharp **full**-row
constant \`4V²<=K²M\`, so any universal c in V²<=cK²M
must be at least 1/4. That is background elementary mathematics,
not a new optimal-constant theorem.

No sampled violation of 4V²<=K²M proves anything about the general
real-row problem. The real test is to derive an all-size *coupled*
threshold inequality, not to expand these tiny LP samples indefinitely.
The R bridge is mathematically refuted, whereas this full K bridge
remains a legitimate conjecture.
