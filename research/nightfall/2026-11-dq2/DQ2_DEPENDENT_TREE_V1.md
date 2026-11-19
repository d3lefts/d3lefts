# DQ2 v1 — quadratic observability under dependent Ising tree laws

**Status: analytic all-finite-tree proof, independently implemented finite exact tests; NOT Lean-certified, externally refereed, or priority-cleared.**  
Date: 2026-11-17. Research line: NIGHTFALL dependent-coordinate observability.  
Premise: the already existing independent-product, finite, bounded degree-two Q2 inequality. Do not silently replace it with a source-level infinite-product claim or an incompletely integrated Lake build.

## Question and measurable improvement

For a dependent law, can bounded degree-two functions retain
`Var(f)^2 <= K B^2 max_i Inf_i(f)` with `K` independent of the number of original coordinates?

Global bounded-density transfer against the uniform cube costs `((1+r)^2/(1-r))^(n-1)` for an n-spin Ising chain. The construction below has an **n-independent** cost. It is an analytic transfer, not a novelty claim; its numerical coefficient is not asserted optimal.

## Main conditional-on-Q2 theorem (DQ2-TREE)

Let T=(V,E) be a finite tree, with maximum vertex degree <= integer d >= 2. Let the spins `x_v` lie in {-1,+1} and have zero-field homogeneous Ising law
`nu(x) = 2^(-|V|) product_{uv in E}(1+t x_u x_v)`, where `t=tanh(J)`, `r=|t|<1`. Assume `(d-1)r<1`.

Let `f(x)=c + sum_v a_v x_v + sum_{u<v} b_uv x_u x_v` be a real polynomial with `|f(x)|<=B` for every configuration, and let
`Inf_{nu,v}(f)=E_nu Var_nu(f(X)|X_{V\\{v}})`.
Write
`S=1 + d*r/(1-(d-1)*r)`,
`alpha=(1-r)/(1+(d-1)*r)`, and
`v=sech(d*atanh(r))^2`.
If the uniform-product Q2 theorem is `Var_mu(f)^2 <= K0 B^2 max_i Inf_{mu,i}(f)`,
then
`Var_nu(f)^2 <= K0*S^4/(v*alpha) * B^2 * max_i Inf_{nu,i}(f)`.

At r=0 the factor is exactly 1. This is a finite-tree result with an algebraic degree-two assumption, not an assertion about an arbitrary dependent-law analogue of ANOVA degree.

### Proof obligations, with explicit mechanisms

1. **Independent edge bonds.** Choose a root spin uniformly. For each tree edge e, `Y_e=X_u X_v` are independent signs with mean t. Hence `E X_i=0`, `E X_i X_j=t^dist(i,j)`, and `X_iX_j=product_{e in P_ij}Y_e`, where `P_ij` is the unique edge path.

2. **Exact pair-path covariance.** For paths P,Q,
`Cov(X_iX_j,X_kX_l)=t^|P△Q| (1-t^(2|P∩Q|))`.
It is zero for edge-disjoint paths. When P and Q share an edge, their intersection is a path; orient the endpoints of Q consistently with the overlap directed from i to j. That orientation is unique, and
`|P△Q|=dist(i,k)+dist(j,l)`.
Thus each nonzero absolute covariance is <= `r^dist(i,k)*r^dist(j,l)` for one unique ordered endpoint pair (k,l). The `l1` norm of each quadratic covariance row is <= `S_i*S_j <= S^2`, where
`S_i=sum_k r^dist(i,k) <= 1+d*r/(1-(d-1)*r)`.
There is no spurious factor 2 from counting both orientations.

3. **Restricted degree-two variance comparison.** The linear covariance matrix `C_ij=t^dist(i,j)` has absolute row sums <=S, and quadratic centered monomial covariance rows have absolute sums <=S^2. Odd and even sectors are orthogonal under global spin flip. Matrix symmetry and the Schur/Gershgorin operator norm bound give
`Var_nu(f) <= S^2 (sum_i a_i^2 + sum_{i<j} b_ij^2) = S^2 Var_mu(f)`,
where mu is the uniform independent Rademacher product law. Centered quadratic monomials are used on the nu side; centering does not change covariance.

4. **Lower bound on covariance of linear gradients.** The inverse of `C` is the exact tree precision matrix:
`(C^-1)_{ii}=1+deg(i)*t^2/(1-t^2)`,
`(C^-1)_{ij}=-t/(1-t^2)` on edges, zero for all other off-diagonal entries.
This follows by multiplying with `C_ij=t^dist(i,j)` and using the unique neighbor on each i→j path. Its absolute row sum is <= `1+d*r/(1-r)=1/alpha`. Therefore `C>=alpha*I` as quadratic forms, also after deleting any coordinate.

5. **Native conditional influence.** Since the Ising conditional mean is
`E[X_i | X_-i]=tanh(J*sum_{j~i}X_j)`, its conditional variance is >=`v`. For
`g_i=a_i+sum_{j!=i}b_ij X_j`, we have
`Inf_{nu,i}(f)=E[Var(X_i|X_-i)*g_i^2] >= v E[g_i^2]`.
Spin means are zero; by the principal-submatrix covariance lower bound,
`E[g_i^2]>=alpha*(a_i^2+sum_{j!=i}b_ij^2)=alpha*Inf_{mu,i}(f)`.
Consequently `Inf_{nu,i}(f)>=v*alpha*Inf_{mu,i}(f)`.

6. **Composition.** Square Step 3, apply uniform finite Q2, and use Step 5:
`Var_nu(f)^2 <= K0*S^4/(v*alpha)*B^2*max_i Inf_{nu,i}(f)`.

### Chain specialization (d=2)

For the open-boundary homogeneous one-dimensional Ising chain,
`S=(1+r)/(1-r)`, `alpha=(1-r)/(1+r)`,
`v=(1-r^2)^2/(1+r^2)^2`. Thus the multiplier is exactly
`F_chain(r)=(1+r)^3*(1+r^2)^2/(1-r)^7`.
`F_chain(0)=1`, `F_chain(1/3)=50`, `F_chain(1/2)=675`.
For `r=1/3`, the global-density method costs `(8/3)^(n-1)`; this dimension-free coefficient is strictly better by n>=5.

### Independent-block alternative (general coordinate alphabets)

If the original coordinates split into independent blocks of size <=m and each block's coordinate Gibbs-resampling Dirichlet form satisfies `Var(h)<=lambda^-1 sum_{i in block} Inf_i(h)`, any function of block Efron–Stein degree <=2 obeys
`Var(f)^2 <= K0*(m/lambda)*B^2*max_i Inf_i(f)`.
The sum must remain inside the expectation before replacing it by `m*max_i Inf_i(f)`. A pointwise bound using only max influences does *not* generally commute with averaging over outside-block configurations.
For correlated Rademacher dimers the exact local gap is `1-|rho|`, hence the coefficient `2K0/(1-|rho|)` (with product Q2 over dimer blocks).
For degree-one functions on one dimer, the dependence penalty `(1+|rho|)/(1-|rho|)` is sharp.

## Checks and audit limits

- Exact rational chain enumeration: 150 finite polynomial/law test instances, 675 coordinate-influence comparisons, six sharp degree-one witnesses. Code SHA-256 `202d5af7d6f93bf546a5416074885b59cbcdea371707caf034730b5d9c6ac903`; result SHA-256 `5669bd1e36d9badbe8847e473df6dd20279492680d23cf8a417ff398d07d1f3c`.
- Separate SymPy exact enumeration: 742 pair-path covariance entries checked, n=2..6 with both positive and negative interactions. Code SHA-256 `e3fe3db909f2d1492881bd04d812548177c9f6117425bb74666390db2d880af7`; result SHA-256 `3036c5958b56164fad496b99fa9f63a96d222301f292a013439a1ec6111ce9b7`.
- Independent tree-geodesic tester: four tree shapes, eight parameterized tests, including negative case of invalid high-temperature threshold corrected before PASS. Code SHA-256 `1f7ec931bfa02d5ad53bffb64f7ffda6ce549f025d433eb6927cf7de4524e788`; result SHA-256 `22b40d7eea00ed061b5cfafde30edee829105ed2fabb1929fe3718fa4bc956e5`.
- Separate exact symbolic precision-matrix audits: chain, binary tree, star, t=-1/6; all `C*C^-1=I` (same-session audit, not a separate researcher).
- Tests **do not prove all n**. The proof above is analytic and presently lacks independently refereed mathematical review or a named Lean DQ2 terminal.
- The finite Q2 input must remain traceable to its original source and compiler receipt. Its global Lean integration is being tracked separately (e.g. [PR #776](https://github.com/d3lefts/d3lefts/pull/776)); do not promote DQ2 through source-level checker receipts.

## Prior art / limits (not a priority certificate)

- Koehler–Lifshitz–Minzer–Mossel, *Influences in Mixing Measures*, STOC 2024, https://arxiv.org/abs/2307.07625: dependent-law KKL/Talagrand-type results.
- Chen–Chen–Zhang, *Discrete Isoperimetric Inequalities via Curvature*, revised November 2026, https://arxiv.org/abs/2609.24687: Dobrushin and Ising influence/isoperimetric results.
- Il Idrissi et al., *Hoeffding decomposition of functions of random dependent variables* (2025): generalized dependent-input projections, https://www.sciencedirect.com/science/article/pii/S0047259X25000399 .
- NIGHTFALL Q2 prior-art dossier [PR #749](https://github.com/d3lefts/d3lefts/pull/749).

The graph-counting / covariance argument may be elementary or implied by existing functional inequalities. No first-discovery, peer-review, or novelty assertion is made.

## Next decisive experiment / formalization dependency graph

1. Independent proof attack: enumerate trees and pair paths; check unique geodesic-alignment orientation, `l1` row bound, exact precision matrix, and normalization of influences.
2. Lean finite-tree dependency chain: tree edge bond factorization → path covariance identity → row-norm bound → covariance inverse → conditional variance floor → restricted Q2 comparison → existing certified finite-product terminal. Require exact source hashes, standard-axiom audit, full Lake build and named theorem receipt.
3. Test heterogeneous tree couplings with weighted path-summability rather than a global `(d-1)r<1` constraint.
4. Check stronger literature on Ising low-degree polynomial influence before labeling this a novel contribution. A theorem implication from prior work is valuable but not novel.
5. Only then investigate loopy graphs, where independent bond variables and unique tree paths fail.
