# NIGHTFALL rainbow influence theorem: fair-cube Q3 and bounded nonfair-coordinate transfer (v1.2)

**2026-11-17/18. Status: author-side analytic theorem with exact finite rational replay, not Lean-certified, not independent external review, not novelty-cleared.** Earlier v1.0 C<3661 obtained by using general Q2 with a fivefold amplitude loss; v1.1 sharpens this **16.6x** by using degree-parity selection *before* quadratic control. No all-product or all-degree total-variance claim.

## Theorem: entire degree-<=3 polynomial, uniform fair cube

For arbitrary n, f:{-1,+1}^n -> R of Fourier degree at most 3, let B=(max_x f(x)-min_x f(x))/2 (half-range), V=Var(f) and M=max_i Inf_i(f), with fair *resampling* influence Inf_i(f)=sum_{S contains i} hat_f(S)^2. Write V_s=sum_{|S|=s} hat_f(S)^2.

**Three simultaneous sector inequalities:**
- V1 <= 3 B sqrt(M).
- V2 <= 2 sqrt(2) B sqrt(M).
- V3 <= 9 B sqrt(M).

Consequently

**Var(f)^2 <= (12+2sqrt(2))^2 B^2 M = (152+48sqrt(2)) B^2 M < 220 B^2 M.**

At B=0 or M=0, all nonconstant coefficients vanish and the inequality holds with equality. This is stronger in variance exponent, and numerically stronger at degree 3, than the all-degree uniform-cube displayed bound of Turturean (arXiv:2611.09773). It is **strictly narrower in degree and source law**, and does not subsume the all-degree theorem.

## Exact norm-one r-color projector

Choose the midpoint m=(max f+min f)/2 and h=f-m, so ||h||∞=B. For r in {2,3}, independently color all coordinates c(i) uniformly in {1,...,r}. Define

R_(r,c) h(x) := (1/2^r) sum_(sigma in {-1,+1}^r) (prod_(a=1)^r sigma_a) h( (sigma_(c(i)) x_i)_i ).

This is a signed average of values of h and hence ||R_(r,c)h||∞<=B. On a Walsh monomial x_S the coefficient is preserved exactly when S contains an **odd** number of variables of each color. Because deg(h)<=3:

- r=2 selects exactly the **rainbow degree-two** monomials (one variable in each of two groups). Neither linear nor cubic monomials survive: the sum of two positive odd integers is even and must be <=3.
- r=3 selects exactly the **rainbow degree-three** monomials (one variable in each of three groups). Neither linear nor quadratic monomials survive.

Both are homogeneous multipartite polynomials in fair signs and their original coordinate influences obey Inf_i(R_(r,c)h)<=Inf_i(f)<=M by Walsh orthogonality.

## Anchored multipartite theorem + averaging (no max/expectation interchange)

The existing author-side anchored multipartite theorem in [PR #804](https://github.com/d3lefts/d3lefts/pull/804), derived from classical sharp vector Khintchine–Kahane, says that any bounded homogeneous r-partite fair-sign polynomial q has

Var(q)^2 <= 2^(r-1) ||q||∞^2 max_i Inf_i(q).

Hence, *for each coloring independently*, Var(R_(r,c)h) <= 2^((r-1)/2) B sqrt(M). Any fixed r-set of Fourier coordinates receives r distinct colors with probability p_r=r!/r^r. By Parseval,

E_c Var(R_(r,c)h) = p_r V_r.

Therefore V_r <= (1/p_r) 2^((r-1)/2) B sqrt(M). At r=2, p2=1/2 yields V2<=2sqrt(2)Bsqrt(M). At r=3, p3=2/9 yields V3<=9Bsqrt(M).

**Critical audit:** we average the variance after obtaining a uniform-in-coloring upper bound; we do NOT infer E[max_i Inf_i] <= max_i E[Inf_i]. That invalid move remains an obstruction under arbitrary-law replica lifts.

## Linear level: exact odd-noise filter

Define h_odd(x)=(h(x)-h(-x))/2 = h1(x)+h3(x), so ||h_odd||∞<=B. The fair-cube heat bath/noise T_t is an L∞ contraction for 0<=t<=1 and T_t h_odd=t h1+t^3 h3. At t=1/2,

**h1 = (8/3) T_(1/2) h_odd - (1/3) h_odd.**

Thus ||h1||∞<=3B. Since h1=sum_i a_i x_i is linear, ||h1||∞=sum_i |a_i| and V1=sum_i a_i^2 <= sqrt(M) sum_i |a_i| <=3B sqrt(M). Summing the orthogonal variances V=V1+V2+V3 yields the C<220 theorem. The coefficient is exact: (3+2sqrt(2)+9)^2=152+48sqrt(2)≈219.882251, strictly less than 220.

## All-degree homogeneous *top-sector* consequence (NOT all-degree mixed)

For a degree-<=d fair-cube f, use d colors and the same signed norm-one character projection. The expected rainbow d-level energy retention is p_d=d!/d^d; the anchored d-partite theorem of #804 gives

**V_d^2 <= 2^(d-1) (d^d/d!)^2 B^2 M**, for any integer d>=1.

At d=1,2,3 the coefficients are 1, 8, 81. This has exponential degree dependence and controls **only the highest Fourier sector**. It does not prove Var(f)^2<=C d^6 B^2 M for unrestricted degree.

## Reproduction and independent criticism gates

- Exact on-repo checker: check_cubic_fair_rainbow.py; 45 seeded Fraction models, exhaustive r-colorings/vertices (up to six fair coordinates), a separate **direct table-value parity projection evaluator** against independent Fourier support calculations, all original flip influences from actual values, and the eight-variable routing stress case with V=1 and M=1/2.
- A CI workflow is provided; its green check, if achieved, proves only these finite replays, **not** the theorem for every n. The analytic argument invokes classical Hilbert-valued Khintchine and previously author-side PR #804, so **no new Lean kernel theorem is claimed**.
- Infinite products of fair-sign coordinates admit an author-side transfer by finite-coordinate conditional expectations (L∞, degree and influence contraction; L² convergence). A named Lean proof for this new cubic result is not yet present.
- Prior art: DFKO (2006/07), O'Donnell–Zhao (2016), Defant–Mastyło–Pérez (2019) give earlier exponential-in-degree influence results. Escudero Gutiérrez (2023) proves degree-independent influence for the distinct completely bounded homogeneous class. These are substantive comparators; **novelty, optimal constants and global priority remain unresolved**.
- The unrestricted arbitrary-bias/categorical Q3 exponent-two theorem remains **OPEN**, as do universal N-UE2(6) and N-UE2(2). Replicated fair orientations produce environment-dependent maxima and cannot be averaged into original-law max influence without a new source-consistent coupled theorem (see [PR #803](https://github.com/d3lefts/d3lefts/pull/803)).

**Discovery graph:** low-degree cube -> exact parity representations -> norm-one r-color projectors -> multipartite Khintchine -> 1/2 and 2/9 Fourier energy survival -> noise-extracted degree-one amplitude -> sector recombination -> cubic exponent-two -> unresolved arbitrary-law transfer.


## v1.2 corollary: arbitrary-law coordinates with bounded total influence (new scope)

Let the original independent product have a block F of fair signs and a disjoint block A of **arbitrary coordinate probability laws and alphabets**, including biased or zero-atom distributions. Suppose f is bounded with original Efron–Stein degree <=3, B half its essential range, and M the maximum **original-law resampling** influence over all coordinates. Set S_A = sum_(j in A) Inf_j(f), interpreted as a finite sum for finite A.

**Hybrid theorem (finite A):**
**Var(f) <= sqrt(220) B sqrt(M) + S_A.**

Proof: set g=E_[X_A] f, an original-product conditional expectation onto the fair block. By independence, g remains bounded in the same essential interval, has fair Fourier degree <=3, and Inf_i(g)<=Inf_i(f) for every fair i (Jensen/contraction). Apply the preceding fair-cube bound to obtain Var(g)<=sqrt(220) B sqrt(M). The law of total variance gives
Var(f)=Var(g)+E_[X_F] Var_[X_A](f | X_F).
For every fixed fair configuration, the ordinary Efron–Stein/Poincare inequality on the **original independent A-law** bounds the conditional variance by the sum of its coordinate resampling influences. After averaging over X_F, the latter sum is exactly S_A. This proves the hybrid inequality. No fake fair law replaces any arbitrary marginal.

**Finite-count consequence (k=|A|):** since S_A<=kM and M<=Var(f)<=B^2 (each coordinate conditional variance <= total variance; Popoviciu), we have
**Var(f)^2 <= (sqrt(220)+k)^2 B^2 M.**
In particular, when all but one input coordinates are fair signs, **Var(f)^2 < 251 B^2 M** even if the remaining coordinate has arbitrary categorical alphabet, bias or zero-probability atoms. For k=2, the coefficient is <284; for k=3, <319. No restriction on the number of fair coordinates. For k growing with dimension, the constant grows: this is **not** a dimension-free all-product cubic theorem.

The hybrid bound remains meaningful with many arbitrary-law coordinates whenever S_A is itself bounded; it is stronger than replacing S_A by kM in that setting. The product decomposition is an exact source-law operator bridge and can be reused with any future fair-subspace influence theorem.

**New independent exact checker:** check_cubic_mixed_anchor.py independently enumerates original resampling influences, conditional fair projection, source-law Poincare remainder, and k=1,2,3 constants for 36 rational models including zero-weight categorical atoms. Exact finite checks are not a universal certificate; a dedicated Lean proof and independent expert review remain open.

**Explicit limit:** Does not establish the universal arbitrary-product cubic inequality with a constant independent of k, does not establish N-UE2(6)/(2), and does not assert priority. The v1.1 fair-cube C<220 and v1.2 mixed-law hybrid are author-side derived from classical tools and the #804 anchored theorem.
