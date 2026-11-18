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


## v1.2 new exact search operator: static Hamming-mask dual packings

For a fixed original source word x and every nonempty coordinate subset
S, define the **exact Hamming-signature maximum**

  b_x(S) = max{|f(x)-f(y)| :
                {i:x_i != y_i}=S},

with empty maximum zero. The true pointwise full row LP is EXACTLY

  K_x = min{sum_i a_i : a_i>=0,
            sum_(i in S) a_i>=b_x(S) for all nonempty S}.

Proof: every original pair constraint with the same difference mask S
has identical left side; retaining the maximum right side is exact.
Thus alphabet growth changes the b_x(S) values but NOT the packing
constraint geometry, which depends only on coordinate count n.

Finite LP duality gives an exact homogeneous fractional packing formula:

  K_x=max{sum_(nonempty S)lambda_S b_x(S):
         lambda_S>=0, sum_(S contains i)lambda_S<=1 for all i}.

Every extreme point has at most n positive lambda_S because there are
only n budget constraints. Exact Fraction Gaussian elimination can
therefore enumerate all vertices by selecting <=n supported masks
and equally many tight coordinate constraints; no solver floating
tolerance. Our stand-alone enumerator certifies exactly
  n=2: 5 vertices; n=3: 16 vertices; n=4: 95 vertices.
The cardinalities and rational feasibility are independently
recomputed on each exact-head run; denominators for n=4 are only
1,2,3. For each search champion, a separately enumerated PRIMAL
basic feasible row solves the true row LP and equals the dual optimum,
and a two-replica full-state check independently matches actual
source-resampling influence.

This produces a reusable source-independent **FULL ROW evaluation
operator**, unlike the false singleton R surrogate and unlike
threshold-by-threshold cutoff. It does not prove the real-row
inequality or constitute a new theoretical complexity claim.

## Preregistered exact-head adversarial findings (2026-11-18)

Script: check_real_row_K_adversarial_exact.py (Python stdlib/Fraction).

Deterministic seeds, initial data include fair additive equality
and highly biased categorical AND. Positive original categorical
weights are mutated across [1,2,3,7,31,127], and integer output
values are varied. Objective functions are kept separate:

  S_K = 4 V²/(K² M)  [SHARP full row conjecture <=1]
  S_R = V²/(d R² M) [unproved UNIT-coefficient weighted-R conjecture <=1]

Here d is **actually recomputed** as the maximum nonzero anchored
categorical Mobius interaction degree, not the ambient site count.
Each run checks 4948 exact rational candidate evaluations across
four heterogeneous product shapes:
  (2,2,2)      8 words, 16 full-row dual vertices, 1528 evaluations;
  (2,2,3)     12 words, 16 vertices, 1528 evaluations;
  (2,3,3)     18 words, 16 vertices, 1528 evaluations;
  (2,2,2,2)   16 words, 95 vertices, 364 evaluations.

**RESULT**: In each searched family, maximal S_K=1 and maximal
S_R=1. Both are ATTAINED by fair additive component controls; no
violation was found by the deterministic hill-climb. These are
finite, nonexhaustive, sometimes repeated evaluations, NOT a proof.
Any strict S_K>1 or S_R>1 automatically fails CI and reports the
complete source-rational witness with objective score and inputs.

For champions, exact independent source conditional residual
versus fresh-coordinate two-replica influence equality passed, as
did the distinct primal/dual full row cost check. There was NO
integer/rationalization error because every search operation uses
Fraction arithmetic from the outset.

**Exact-head receipt:** GitHub Actions
https://github.com/d3lefts/d3lefts/actions/runs/44357834056
on head e4e6537b0bf6783a8c1d451c5aafcb5b68278eaf
completed successfully; immutable source/artifact ID 14453982467.

## What the weighted R search DOES and DOES NOT establish

The biased AND family has *algebraic degree d=n* and exact
  V²/(d R² M)=q_n(1-q_n)² -> e^-1(1-e^-1)²>0.
Therefore for ANY beta<1 and any fixed C there are original
independent product laws violating V²<=C d^beta R² M:
the degree penalty power must be at least 1. This shows the proposed
linear d penalty is **necessary** at the scale of polynomial exponents,
but its **sufficiency is open**; small rational tests cannot prove it.

The additive fair degree-one function f=sum_i (2X_i-1) has R=n,
V=n, M=1, and V²/(dR²M)=1. Thus any possible unit-penalty bound must
have coefficient c>=1. No claim of optimum c or dimension-free
proof is made.

If the conjectured weighted R inequality
  V²<=c d R² M
were eventually established with universal c, combining it with
PR #808's **author-side** source Bernstein row bound
  R<=4 d² B
would give
  V²<=16 c d^5 B² M,
an all-degree polynomial-d exponent-two inequality (stronger
degree exponent than N-UE2(6)). This is a CONDITIONAL implication,
NOT a theorem now, and the established failure of the d^0 R bridge
must remain attached.

**Stop rule:** Do not confuse no counterexample in 4948 tests with
a general real-row K theorem, a valid weighted-R theorem, or
certified polynomial-in-degree AA progress. Prioritize an adversarial
proof of the coupled threshold-PSD conic gate in #814, with exact
rational LP oracle and explicit R-weighted attack as a backup.


## v1.3 structured high-degree bias-tuned test + final exact-head gate

Added 21 independent exact rational **symmetric Chebyshev**
degree d=2,...,8 source families with n=12d inputs each,
using p=1/2, a rational near-Bernstein bias, or p=1-1/n.
For t_k=T_d((2k-n)/n) the TRUE original-law singleton residual cost
is exactly

  R=max_(0<=k<=n) [
      k(1-p)|t_k-t_(k-1)|
      +(n-k)p|t_(k+1)-t_k|
    ],

with zero boundary terms. This max explicitly includes the
exponentially rare full-support tail source words rather than
substituting a typical derivative. V and M come from exact binomial
and conditional-variance sums. All exact 21 tests satisfy the
candidate unit-weighted R inequality; the largest observed
  V²/(dR²M)=637563/14739136≈0.043256
at d=2,n=24,p=17/20. These results are stress tests,
not an all-degree theorem.

**FINAL exact-head source run:** GitHub Actions
https://github.com/d3lefts/d3lefts/actions/runs/44358693159
commit f41aec0c146e37437e703bb1ff7baf89fceb7694,
SUCCESS. All-n biased-AND closed formulas and physical finite tables,
fair Rubinstein sensitivity/row separation, nine independent original-
categorical full-row primal LP tests, all 4948 exact rational active
search evaluations, and all 21 high-degree Chebyshev families passed.
Immutable receipt artifact **14451593452**.

The test maxima equal one only because the search includes and
correctly reproduces additive fair equality controls. This does not
prove the K-sharp or unit-weighted-R conjectures. The R degree-free
inequality remains disproved; the degree-weighted R and the real K
bridge remain open. CI failures carry the exact counterexample
values and source probabilities for any strict detected violation.
