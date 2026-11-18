# Block-spectral-gap influence lift for correlated sources

NIGHTFALL research checkpoint 2026-11-18. **Author-side mathematical theorem; full source-to-influence Lean integration and prior-art priority review remain open.** The premise is the all-degree arbitrary-product theorem in draft #858. No assertion this lift is novel: it is a compositional corollary of product AA and a block Poincare inequality.

## Theorem

Let the finite coordinates [n] be partitioned into nonempty disjoint blocks B_1,...,B_r. Let nu = ⊗_k nu_k, with nu_k an arbitrary law on the full **joint** alphabet of its block (allowing internal dependencies and zero-mass configurations). Let f take values in [-B,B], B>0, and be a polynomial of original-coordinate degree <=d>=1 (indicator-monomial representation). Write

    V=Var_nu f,
    I_i^nu(f)=E_nu Var_nu(f | X_{-i}),
    I_{B_k}^nu(f)=E_nu Var_nu(f | X_{-B_k}).

For every block k, assume a genuine **local single-site Poincare inequality**, for *all* functions g on B_k,

    Var_{nu_k}(g) <= C_k Σ_{i∈B_k} E_{nu_k} Var_{nu_k}(g | X_{B_k\{i}}),

with 0<C_k<∞. Let Lambda=max_k C_k |B_k|.

Then

    max_i I_i^nu(f) >= [sqrt(3/12500)/pi^6] * V^(5/2)/(Lambda*d^6*B^3).

For f∈[0,1] use B=1/2 after centering, yielding the coefficient 8 sqrt(3/12500)/pi^6 divided by Lambda.

### Proof

1. Group all coordinates in B_k into a single supersymbol Y_k. The law of Y=(Y_1,...,Y_r) is independent across supersymbols. Every monomial in at most d original coordinates depends on at most d blocks; hence the regrouped function has Efron–Stein/indicator degree at most d. Range bound and total variance V are unchanged.
2. Apply finite heterogeneous product AA (#858) to the block product: some k satisfies
   I_{B_k}^nu(f) >= [sqrt(3/12500)/pi^6] V^(5/2)/(d^6 B^3).
3. For each fixed outside assignment y_{-B_k}, apply the local Poincare inequality to the block function g(x_{B_k})=f(y_{-B_k},x_{B_k}), and average over y_{-B_k}. Because blocks are independent, the right-hand conditional variances integrate exactly to the true original-coordinate influences I_i^nu(f) for i∈B_k. Therefore
   I_{B_k}^nu(f) <= C_k Σ_{i∈B_k} I_i^nu(f) <= C_k |B_k| max_i I_i^nu(f) <= Lambda max_i I_i^nu(f).
4. Combine. No global density comparison, no latent-variance retention assumption, no global lower atom floor.

### Why local ergodicity matters

If a block is supported on (00,11), single-site heat-bath resampling cannot change the configuration while conditioned on the other coordinate. The local Poincare constant is infinite, and coordinate influences of f(x)=x_1 vanish despite positive variance. This is precisely the earlier correlated counterexample.

### Explicit family with no uniform global density floor

For a correlated pair of fair marginal signs, let

    nu_q(++)=nu_q(--)= (1-q)/2,
    nu_q(+-)=nu_q(-+)= q/2,     0<q<=1/2.

The local single-site Poincare constant is exactly C(q)=1/(2q). To verify, diagonalize variance and the sum of single-site conditional variances on the orthogonal mean-zero basis:
    g_plus=s1+s2   : Var/ΣI = 1/(2q),
    g_minus=s1-s2  : Var/ΣI = 1/(2(1-q)),
    g_product=s1*s2-(1-2q): Var/ΣI=1/2.
All cross terms vanish for both quadratic forms. Therefore max ratio C(q)=1/(2q).

Take ν to be the product of k such pair blocks with q=1/4. Then block size b=2, C=2 and Lambda=4 *for every k*. Relative to the independent uniform product of all 2k marginal bits, the minimum joint density ratio is (2q)^k=2^(-k), tending to zero exponentially. The direct influence bound nevertheless remains dimension-free:
    max_i I_i^nu(f) >= sqrt(3/12500)/(4 pi^6) * V^(5/2)/(d^6 B^3).
The product space of blocks may be arbitrarily large.

## Relationship to latent mixtures

The finite latent-mixture theorem uses (i) a bounded witness-set size (at most m mixture components), and (ii) positive within-component variance fraction κ. The block theorem instead uses (i) independence *across blocks*, and (ii) bounded local Poincare cost C_k|B_k|. Neither theorem implies the other. The latter handles arbitrarily many correlated pairs without a component-count penalty.

## Audit and provenance

check_block_gap.py reproduces the exact correlated-pair Gram matrices over Fraction, verifies the diagonal ratios on a complete basis, checks positive-semidefinite residual for q=1/4, and checks the decaying density floor for k=1..8.

This is a complete author-side proof, not a Lean terminal theorem. To formalize end-to-end: (1) add the block grouping degree-invariance map to the finite heterogeneous product theorem; (2) use the finite conditional-variance identity for the local Poincare lift; (3) combine in a named terminal and check exact compiler axioms. The named scalar inequality and exact example are not enough alone.

Prior-art direction: 'Influences in Mixing Measures' (arXiv:2307.07625) proves related KKL/Talagrand results under correlation decay. These results and spectral-gap literature must be compared before claiming novelty.


## Corollary: block-query simulation needs no local spectral gap

For the same source ν=⊗_kν_k, assume only a maximum block size b, **not** any local Poincaré inequality. Grouping each block into a supersymbol preserves [0,1] range, variance, and degree≤d. Apply the independent-product query simulator at the block level. Every query for a complete supersymbol can be implemented by at most b original-site queries. Consequently an additive-(ε,δ) deterministic classical approximation uses at most

    b * ceil(22000 d^7 ε^-5 δ^-7/2)

individual coordinate queries, for any degree-d bounded acceptance function, regardless of internal block singularities or density-floor failure. For a T-query quantum algorithm take d=max(1,2T).

This is a *query-simulation* theorem; it must not be confused with the direct coordinate-influence lower bound, which **does** require local spectral-gap control. A perfectly locked block (X1=X2) can have zero true one-site influences despite its whole-block influence being positive, but a classical simulator can query both sites together for cost b. This cleanly separates observability by individual coordinate from availability of inexpensive block measurements.

Lean status: finite grouped-degree transport and explicit whole-block decision-tree simulator are not yet linked as a named end-to-end theorem. The argument is author-side.
