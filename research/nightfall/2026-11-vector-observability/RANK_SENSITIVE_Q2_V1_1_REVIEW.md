# Rank-sensitive source-preserving quadratic observability — v1.1 review checkpoint

**Date:** 13 November 2026. **Programme:** NIGHTFALL / Devin J. Wright. **Status:** author-side analytic result for specialist review, not an independent human proof review, historical novelty verdict, or terminal same-source Lean proof. AI assistance disclosed.

## The theorem and complete proof mechanism

Let `X` have an independent product law on arbitrary (possibly heterogeneous) finite alphabets, with zero-mass atoms removed before supported suprema, and let `f(X)` lie in a fixed real Hilbert space of output dimension `r`, `||f||∞ ≤ B`, with genuine original-law Hoeffding degree ≤2. Write `V=E||f−Ef||²`, `I_i=E||f−E[f|X_{-i}]||²`, `M=max_i I_i`. From the repository's source-preserving finite scalar Q2 argument,

`V² ≤ (C2/c_r²) B² M`,

where `C2=(10+2sqrt(2))²(1+sqrt(3))²≈1228.3563` and `c_r=Gamma(r/2)/(sqrt(pi) Gamma((r+1)/2))`, so `1/c_r²≤pi*r/2`. No factor in n, alphabet size, or minimum positive atom mass.

### Independent mathematical reconstruction

1. **Projection norm recovery:** for uniform theta on the output unit sphere and positive semidefinite A, `E_theta sqrt(theta^T A theta) ≥ c_r sqrt(tr A)`. Diagonalize A; the function of the normalized eigenvalue simplex is concave and therefore bounded below by its convex combination of extreme-point values, all c_r. Rank-one A attains equality.
2. **Transfer both scalar budgets:** each real scalar projection `<theta,f>` obeys the original-source scalar total section norm budget `8B`, first-order energy budget `2(1+sqrt 2)B`, and disjoint matching amplitude budget `4B`. Spherical averaging and step 1 yield corresponding vector budgets each multiplied by `1/c_r` — not by r. This is the critical rank improvement.
3. **Original-source fractional ownership:** choose greedy endpoint costs c_i with total `Σc_i≤8B/c_r` and amplitude `w_ij≤sqrt(c_i²+c_j²)`. Weights `lambda_ij=c_i/sqrt(c_i²+c_j²)` obey `lambda_ij²+lambda_ji²=1` on nonzero pair terms. For each fixed owner i, the original-source Hilbert summands `lambda_ij h_ij(·,X_j)` are independent and centered over **distinct original neighbors**, without asserting global independence across owners.
4. **Markov and moment transfer:** original-coordinate noise `Q_i=Π_{j!=i}(lambda_ij Id+(1-lambda_ij)E_j)` gives the exact source identity `Q_i U_i=h_i+H_i`; Jensen yields `z_i≤u_i+a_i`. Fourth-moment interpolation gives `s_i≤z_i(c_i+sqrt(3M))`; original-source Parseval closes `V≤((10+2sqrt 2)(1+sqrt 3)/c_r)B sqrt M`.
5. **Sharp rank obstruction:** on r fair signs, `f(x)=B/sqrt(r) Σ_j e_j x_j` is degree one, has V=B² and M=B²/r. Therefore any universal output-rank coefficient is at least r.

## Oracle-matched state-read complexity

Greedy whole-coordinate reads using exact conditional influences have risk ≤eta using ≤`min(n,ceil(4(C2/c_r²)B²/eta))` actual state reads. This assumes an exact influence oracle and does **not** make its computational cost free in a general implementation.

A family on 2rm independent fair signs,
`f=(B/(m sqrt(r)))Σ_{ell=1}^r e_ell Σ_{j=1}^m x_{ell,j,1}x_{ell,j,2}`,
has variance B²/m. Every incomplete pair remains fair under any adaptive coordinate-read transcript. At eta=B²/(2m), every possibly randomized policy needs expected ≥rm state reads. The upper and lower have matching order `Theta(r B²/eta)` for that **specific state-coordinate oracle**, not for posterior model evaluations.

## Corrected posterior theorem and sharper evaluation implementation

The posterior theorem now **explicitly assumes the posterior mean has degree at most two** (or, sufficiently, that every posterior-supported model has degree at most two). Also assume independent posterior draws, exact synthetic conditional original-product sampling, model-state independence given evidence, bounded Hilbert-valued model outputs, and rank-r posterior mean.

A four-value cross-replica score is unbiased for the actionable original-law influence. Naive Bernstein does not reduce the posterior-model uncertainty floor. Instead, for every shared synthetic state-resampling pair take two independent model batches of b, average differences within each group, then take half their Hilbert inner product. This gives `Var(H_i)≤(2+4/b)B² I_i + 4B⁴/b²` and, for `b=ceil sqrt(B²/e)`, `Var(H_i)≤6B² I_i+4B² e`.

With `K=(C2/c_r²)B²`, `u=eta/2`, `e=u²/(64K)`, `rho=u²/(32KB²)`, `b=ceil sqrt(B²/e)`, `k=ceil((176B²/(3e))log(2n/rho))`, and `q=min(n,ceil(32K/(3u)))`, relative-plus-additive Bernstein selection yields risk ≤`R_model+eta`, state reads ≤q, model-value evaluations ≤`4nqbk+ceil(2B²/eta)`. The leading evaluation dependence improves from `~O(eta^-5)` to `~O(eta^-4)` for fixed parameters. **This is not a matching model-evaluation lower bound or a polynomial generic runtime theorem.**

Independent approximate posterior Q within total variation delta of P produces original-model squared prediction risk ≤`R_model(P)+(sqrt eta+2B delta)²`, with independent draws required.

## Independent exact finite falsifiers

- Original rank/observation checker: **8,378** exact-rational assertions, including all small observation histories.
- New independently written vector posterior-batch checker: **8,192** exact-rational assertions; the zero-actionable-influence mixture has variance exactly `2/b²` after batching.
- Original scalar Q2 checker: 36 finite source models, exact identities and numerical constant comparisons at 70-digit precision.
- Companion dissertation: 41-page integrated four-part edition, with rank theorem after scalar Q2 and separate priced posterior observer. Standalone paper: 16 pages.
- Release source SHA-256: `7d16d42565abfe274c4fa1b30459bdf7a86f4dad762a79d483905c7651873e68`; release PDF SHA-256 `d7851ec32bdbd6d2decb21f795137f53cbe3fde3a8c93889375b8c69480a52df`; integrated dissertation PDF SHA-256 `608d1cd0d8aeab4c75803dff60fafc5cdfcbb8d3e366cdec4746b49f6992f0bc`; new checker SHA-256 `a4312d4549e575772c67d425a78791a1092010371ea2a04aed9a4b0abf81a568`.

**Binary artifact custody:** The complete PDF/LaTeX, exact checker sources, replay logs, and SHA-256 manifest were generated in the conversation's downloadable archive. **This PR commits only this text note; it does not falsely claim that the binaries or exact checker files have been uploaded to GitHub.**

## Specific prior-art and proof obligations

- Compare rank-r statement to Eskenazis--Ivanisvili (2020), *Polynomial inequalities on the Hamming cube*, and Cordero-Erausquin--Eskenazis (2023), *Talagrand's influence inequality revisited*. Both are serious vector-valued predecessors, but neither abstract supplies the same arbitrary-categorical original-law Q2 formula.
- Compare the scalar source theorem with categorical completely bounded and Banach/Grothendieck factorization, especially whether a direct same-source reduction exists. The categorical address model invalidates a false alphabet-independent root-influence sum shortcut.
- Independently reconstruct projection norm recovery, matching/coupling and local fourth moments; attempt a categorical counterexample. Formalize a single same-source Lean terminal statement rather than promoting separately compiled helpers.
- Price projector discovery, conditional-state simulation, posterior inference, and certificate verification; do not infer a model-evaluation lower bound from the state-read lower.
