# DQ2 all-graph scope: quantitative no-go and self-contained spectral-gap audit (v0.1)

**2026-11-17 | Author-side mathematical analysis, independent exact rational replay.** This note augments the signed-graph DQ2 candidate in PR #789 and the prior tree/cyclic work (#786, #788). It does **not** certify originality, Lean formalization, independent external review, or unrestricted dependent-law Q2.

## 1. Universal all-interaction dimension-free Q2 is false, even on paths

For each integer `n>=2`, let `r_n=1-1/n^2` and give `X_1,...,X_n in {-1,+1}` the zero-field open-chain Ising law

`P_n(x)=2^(-n) product_{j=1}^{n-1} (1+r_n*x_j*x_{j+1})`.

This is full support and is exactly the Ising model with finite coupling `J_n=atanh(r_n)` on each path edge. Define the *linear*, hence algebraic degree-at-most-two, test function

`f_n(x)=(1/n)sum_{j=1}^n x_j`, with `|f_n|<=1`.

The independent bond variables `Z_j=X_j X_{j+1}` have mean `r_n`; thus `E X_j=0`, `E[X_i X_j]=r_n^|i-j|`, and

`Var_nu(f_n)=n^(-2)[n+2 sum_{k=1}^{n-1}(n-k)r_n^k] >= 1-1/n`,

using Bernoulli's inequality `(1-1/n^2)^k >= 1-k/n^2 >= 1-1/n`.

With the *native* conditional-resampling influence
`I_i(f)=E Var(f|X_{-i})`, the endpoint sites have
`I_1(f_n)=I_n(f_n)=(1-r_n^2)/n^2`.
For every internal site `1<i<n`, the Markov conditional is
`E[X_i|X_{-i}]=r_n(X_{i-1}+X_{i+1})/(1+r_n^2)`, so
`I_i(f_n)=(1-r_n^2)/(n^2(1+r_n^2))`.
Therefore `M_n=max_i I_i(f_n)=(1-r_n^2)/n^2`, exactly, and

`Var(f_n)^2/(B^2*M_n) >= (n-1)^2/(2/n^2-1/n^4) ~ n^4/2 -> infinity`.

**Theorem (elementary no-go).** No constant independent of both vertex count and interactions can satisfy `Var_nu(f)^2 <= C B^2 max_i I_i^nu(f)` for every full-support zero-field pairwise Ising measure on every graph, even when `f` has algebraic degree one and the graph is a simple path. The interaction budget is essential: here `J_n -> infinity` and the Dobrushin coefficient does not stay uniformly below one. This does **not** rule out a dimension-free bound with a uniform *quantitative* dependence/mixing budget.

### Independent checker

`python3 scripts/check_dq2_all_graphs_no_go_exact.py`

The Python-standard-library checker independently enumerates the full `2^n` state distribution for `n=2,3,4,5,7,9`, groups conditional pairs without using the formula for influences, and checks exact rational equalities for variance, endpoint and internal-site influences. Exact closed-form arithmetic additionally checks `n=12,24,50,100`. These finite tests corroborate but cannot replace the all-n proof above.

## 2. Independent heat-bath Poincare derivation for signed graphs

For *any* full-support finite binary law, define `Q_i h=E[h|X_-i]`, `P=(1/n)sum_i Q_i`, and actual Dobrushin TV coefficients `c_{ij}` for perturbing `j` in the conditional law at `i`. Suppose `max_j sum_{i ne j}c_{ij}<=alpha<1` (column contraction; symmetric Ising makes row and column budgets equal). If two configurations differ only at `j`, a shared random-site heat-bath coupling has expected Hamming distance at most `1-(1-alpha)/n` after one update: updating `j` removes the disagreement and updating `i ne j` introduces one with probability at most `c_{ij}`. For arbitrary configurations, telescope along a Hamming path. Hence

`Lip(P h) <= [1-(1-alpha)/n] Lip(h)`

for the coordinate-Hamming Lipschitz seminorm. Each `Q_i` is a self-adjoint positive semidefinite orthogonal projection in `L2(nu)`; thus `P` is reversible with real nonnegative spectrum. Every nonconstant eigenfunction has positive Lipschitz seminorm (full support) and eigenvalue at most `1-(1-alpha)/n`. Therefore

`Var_nu(h) <= (1/(1-alpha)) sum_i I_i^nu(h)`

since `<h,(Id-P)h>=(1/n)sum_i I_i^nu(h)`. This proves the finite-law Poincare input of PR #789 without depending on a quoted spectral-gap theorem, assuming only its stated Dobrushin column-sum bound. Classical priority remains Wu (2006) and earlier Glauber/path-coupling methods; this is **not** a newly invented spectral-gap result.

For pairwise signed zero-field Ising, the actual `c_{ij}<=tanh|J_ij|` and the interaction matrix is symmetric. In PR #789 the dual conditional-score `U_i=(X_i-E[X_i|X_-i])/Var(X_i|X_-i)` provides `Cov(X_j,U_i)=delta_ij` and a graph-sparse Gram estimate `||Cov(U)||_op<=D`, giving `Cov(X)>=D^-1 Id`; also the true conditional spin variance is at least `v`. The existing **finite product** Q2 theorem with coefficient `K0` then yields

`Var_nu(f)^2 <= [4 K0 A^4 D/v] B^2 max_i I_i^nu(f), A=(1-alpha)^(-1)`

for physical algebraic quadratic f. The signed-Ising bounds `v>=1-alpha^2` and `D<=[1+alpha(1+alpha)^2]/(1-alpha^2)` recover PR #789's explicit coefficient `K0*4[1+alpha(1+alpha)^2]/[(1-alpha)^4(1-alpha^2)^2]`. This is dimension-free across *all graph topologies* as long as `alpha<=alpha_0<1`.

**Scope warning:** The Dobrushin all-graphs positive result and unrestricted all-interactions no-go do not contradict one another. Algebraic quadratic degree is not the noncommuting, residual-defined dependent Hoeffding degree (see merged PR #785). This analysis does not prove a bound independent of the mixing parameters, or solve the unrestricted cubic exponent-two problem.

## 3. Research and certificate gates

- **Mechanism:** replace global density comparison with heat-bath Poincare, linear spin-covariance lower/upper control, and original-site conditional influences.
- **External comparisons:** Wu (2006), arXiv:math/0611635; Diakonikolas–Kane–Stewart–Sun (COLT 2021), arXiv:2102.02171; Koehler–Lifshitz–Minzer–Mossel (STOC 2024), arXiv:2307.07625; Chen–Chen–Zhang (revision 2026-11-12), arXiv:2609.24687. Existing degree-two Ising results mean this cannot be advertised as a first theorem without a statement-level comparison.
- **Verified in this turn:** exact rational independent enumeration and closed-form inequality checks for the no-go family; exact analytic proof of its divergence, and an independently written spectral-gap argument consistent with PR #786.
- **Not verified:** Lean kernel terminal for the all-graph composition; an independent external referee; prior-art novelty; extension to arbitrary phases/strengths. The PR #789 finite signed-model checks are only finite replay.
- **Decisive next test:** translate the heat-bath Poincare and signed dual-score lemmas into named Lean declarations with explicit hypotheses; connect them to the existing source-verified finite Q2 endpoint. Independently rederive the score row bound, including overlapping neighbor and edge cases. Do not promote the proof passport before these gates.

**Discovery graph:** universal all-graph conjecture -> path-Ising obstruction -> uniform mixing-budget necessity -> Dobrushin spectral-gap operator -> dual conditional scores -> restricted quadratic transfer -> exact checker -> Lean/external-audit limitations -> correlated-sensing transfer.
