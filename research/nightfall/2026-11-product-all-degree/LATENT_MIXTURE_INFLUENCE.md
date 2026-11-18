# Latent-product influence amplification without a global density floor

NIGHTFALL 2026-11-18. **Author-side theorem and exact-rational examples; no original-priority or Lean-kernel claim for the full theorem.** Depends on finite product-space Aaronson–Ambainis from [PR #858](https://github.com/d3lefts/d3lefts/pull/858). Differentiates product-reference query simulation from *true correlated-law* heat-bath influences.

## Statement (finite index, arbitrary categorical alphabets)

Let nu = sum_{theta=1}^m w_theta mu_theta be a finite mixture of m probability **products** over the same coordinate space, with w_theta>=0 and sum w_theta=1, where μθ may have zero-mass atoms. Let f be a common polynomial/indicator-monomial function of coordinate degree<=d>=1, with |f|<=B (B>0), and define

- V = Var_nu(f);
- V_theta = Var_{mu_theta}(f);
- W = sum_theta w_theta V_theta;
- I_i^rho(f) = E_rho Var_rho(f | X_{-i}), the genuine conditional-resampling heat-bath influence.

If W>=κ V for 0<κ<=1, then

    max_i I_i^nu(f) >= (sqrt(3/12500)/pi^6) * (κ^(5/2)/m) * V^(5/2)/(d^6 B^3).

If instead f∈[0,1], center at 1/2 and replace the prefactor by c=8 sqrt(3/12500)/pi^6.

More generally, if there exists a set S of r coordinates such that, for every θ with positive variance, some i∈S is a product-law AA witness for μθ, replace m by r. This may allow arbitrarily many latent components.

### Proof with explicit certificates

For each i, apply conditional-variance monotonicity. Conditional on X_{−i}, the conditional law of Xi under ν is itself a posterior mixture of the μθ,i, with weights proportional to wθ μθ,−i(X−i). Variance of a mixture is at least the weighted mean of its component variances. Integrating,

    I_i^nu(f) >= sum_theta w_theta I_i^{mu_theta}(f).           (1)

No measure equivalence or density lower bound is used.

For every θ with Vθ>0, product AA gives an index iθ with I_{iθ}^{μθ}(f)>=c_B Vθ^(5/2)/d^6 where c_B=sqrt(3/12500)/(pi^6 B^3). If Vθ=0, choose any index and the same inequality holds trivially. Denote S={iθ: θ=1..m}, |S|<=m, or use the hypothesized common witness set.

Sum (1) over i∈S, ignoring nonnegative terms:

    |S| max_i I_i^nu(f) >= sum_{i∈S} I_i^nu(f)
                            >= c_B/d^6 sum_theta w_theta Vθ^(5/2).

By Jensen's inequality for the convex function t↦t^(5/2) on t>=0 and the convex weights wθ,

    sum_theta w_theta Vθ^(5/2) >= (sum_theta w_theta Vθ)^(5/2)
                                 = W^(5/2) >= κ^(5/2) V^(5/2).

Combine the inequalities to obtain the result. Finite mixture weights may vanish. If no coordinates exist, all functions are constant and V=0, so the nontrivial case is empty.

Total variance identity:

    V = W + Var_w(E_{μθ} f).

Thus κ measures the fraction of variance retained *within* latent components. Common component means imply κ=1. This assumption is indispensable for this method: perfect-redundancy mixtures can have W=0 and all true conditional influences zero despite V>0.

### No global density floor: explicit correlated family

Let X0=Θ be a fair latent tag, and conditional on Θ=0 let X1,...,XN be iid Bernoulli(1/4), while conditional on Θ=1 let them be iid Bernoulli(3/4). This is a two-component mixture of product distributions on (N+1) bits. The coordinate marginals are fair. Relative to the product of these marginals, the minimum density is 2^(−N), which tends to zero exponentially as N increases. The joint ν nevertheless has full support for every finite N. Take f=1[X1 != X2], a degree-two function. Its mean in both product components is 3/8, so W=V=15/64. The true correlated-law influences of coordinates 1 and 2 are exactly 3/16 (since the tag is revealed among the conditioning coordinates), while all remaining coordinates have influence zero. Thus a dimension-independent influence survives even though there is no dimension-independent global positive density floor.

### Counterexample to dropping variance retention

For ν(00)=ν(11)=(1−q)/2, ν(01)=ν(10)=q/2, f(x)=x1, V=1/4, max true conditional influence=q(1−q)→0. One may express this as a mixture of two degenerate product components with W=0 when q=0, and arbitrarily small W near q=0. A bounded D∞ upper density alone is insufficient.

## Independent tests / novelty

Run check_latent_mixture_influence.py: exact Fraction verification of the mixture-conditional influence dominance, component-variance decomposition, and explicit two-tag example at N=2,4,8; exact ratio minima and influence values. These are spot tests, not a formal certificate. The proof relies on standard mixture conditional-variance and Jensen arguments plus the already checked product inequality, so **the mechanism is a useful structural corollary, not a verified novel breakthrough**.

Literature comparison (2026-11-18): Turturean's arXiv:2611.09773 supplies fair-cube AA; NIGHTFALL #858 supplies arbitrary-product theorem. Standard Gibbs variance tensorization and Dobrushin/spectral independence can give correlated Poincare inequalities, but alone yield an n-dependent maximum-influence bound, not the stated degree-dependent uniform result. Further priority review is needed.

## Lean integration plan (no hidden completion claim)

Formalize the exact conditional-mixture Jensen identity first, then lift #858's finite heterogeneous theorem through m witnesses and finite Jensen. The separate simulator integration remains tracked in SimulationDrift.lean (capped expected-potential drift) and RenyiTransferEvent.lean (finite D∞ event transfer), not yet a named full query tree theorem.
