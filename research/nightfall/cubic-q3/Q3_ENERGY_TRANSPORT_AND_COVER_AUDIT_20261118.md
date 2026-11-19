# Q3 conditional-energy transport and high-cover stress test (2026-11-18)

**Status:** author-side elementary exact theorem plus analytic adversarial examples and `Fraction` tests. Not a proof of unrestricted Q3, not a Lean or external mathematical certificate, and not a novelty/priority claim. Classical ingredients: Hilbert Cauchy–Schwarz, Popoviciu, resampling Efron–Stein identities, ANOVA orthogonality.

## Objective and baseline

Investigate whether the product-law degree-three `Var(f)^2 <= C B^2 max_i Inf_i(f)` problem can be closed by charging fluctuations of conditional section energy to original-law selector influences. Compare the shared rare core of PR #380, a categorical selector with no scalar-energy fluctuation, and a connected, high-fractional-cover cubic. PRs #803, #807, and #809 contain distinct open gates. No global inequality is certified by this audit.

Original laws are finite independent product laws; `Inf_j(f) = (1/2) E (f(X)-f(X^{(j)}))^2`, where the replacement at coordinate j is drawn from its *original* law. Put `B = (ess sup f - ess inf f)/2`, not an arbitrary supremum around zero.

## Theorem: source-consistent vector energy transport (sharp factor 4)

Partition coordinates into an arbitrary-law anchor block `X=(X_i)_{i in I}` and a controller block `W=(W_j)_{j in J}`. Suppose a bounded function has the form

`f(X,W) = c(W) + sum_i u_i(X_i,W)`

where, for every `W` in support, `E_{X_i} u_i(X_i,W)=0`, and `f` has centered essential radius `B`. Define `H_i=L^2_0(mu_i)`, `s_i(w)=||u_i(.,w)||_(H_i)`, and the **coordinate-resolved section-energy measure** `q(w)=(s_i(w)^2)_i`.

Independence of the anchors makes the essential oscillation of their sum additive. Popoviciu therefore gives **pointwise** `sum_i s_i(w) <= B`, so `||u(w)||_(directsum H_i) <= B`.

For each controller coordinate `j`, let `W^{(j)}` denote original-law resampling of that coordinate, and define

`T_j(q) = (1/2) E [||q(W)-q(W^{(j)})||_1^2]`.

Then, with no degree, alphabet, atom-mass, or controller-independence-within-a-section assumptions beyond the original product structure,

**`T_j(q) <= 4 B^2 Inf_j(f)`.**

**Proof.** For each paired `w,w'`, with `a_i=u_i(.,w)` and `b_i=u_i(.,w')`, Hilbert Cauchy–Schwarz yields

`||q(w)-q(w')||_1 <= sum_i (||a_i||+||b_i||)||a_i-b_i||`

`<= (||a||+||b||) ||a-b|| <= 2B ||a-b||`.

The `X_i` sections are centered and orthogonal, hence

`||a-b||^2 = E_X [ (sum_i (a_i(X_i)-b_i(X_i)))^2 ]`

`<= E_X [(f(X,w)-f(X,w'))^2]`, because the controller-only component `c(w)-c(w')` is orthogonal to the centered anchor sum. Square, multiply by `1/2` and average over coupled original-law `W,W^{(j)}` to obtain the bound.

**Factor 4 is optimal even at degree two.** For independent fair signs `X,W` take `f=X u(W)`, `u(+1)=1`, `u(-1)=1-epsilon`, `0<epsilon<1`. Here `B=1`, `Inf_W(f)=epsilon^2/4`, and `T_W(q)=(2epsilon-epsilon^2)^2/4`. Thus `T_W(q)/(B^2 Inf_W(f))=(2-epsilon)^2 ->4` as `epsilon ->0`.

This is a simple sharp Lipschitz consequence, not a claimed new mathematical discovery. The utility is that it measures **migration between anchor coordinates**, which scalar conditional energy cannot detect.

## Fixture 1: a categorical selector with zero scalar-energy fluctuation

For independent fair `X_1,...,X_n,Z` and `Y` uniform on `{1,...,n}`, let

`f=Z [X_Y - (1/n) sum_i X_i]`.

This is a pure original-law ANOVA degree-three function: the `Y`-dependent coefficients have zero `Y` mean, and each term is centered in its `X_i` and `Z` coordinate. Exact identities for every n>=2:

- `B=2(n-1)/n`, `V=(n-1)/n`, `Inf_(X_i)=(n-1)/n^2`, `Inf_Y=Inf_Z=V=M`.
- For anchors `X_i`, `q_i(Y,Z)=(1_{Y=i}-1/n)^2` and `sum_i q_i(Y,Z)=V` **pointwise**. Therefore `Var_(Y,Z)(sum_i q_i)=0`.
- Nevertheless `T_Y(q)=2(1-1/n)(1-2/n)^2`, tending to `2` while scalar energy has zero variance.
- `sum_i sqrt(E q_i)=sqrt(n-1)`, so a naive interchange between pointwise `ell_1` and averaged `ell_2` diverges.

**Conclusion:** a repair that only charges fluctuations of `sum_i q_i(W)` misses selector relocation even in a bounded degree-three product source. This does *not* refute any specified aggregate tail estimate.

## Fixture 2: the PR #380 shared rare core

Take independent `A~Bernoulli(p)` and fair `X_0,Z_1,...,Z_m`, with

`f=X_0 (A-p) (sum_j Z_j)/m`.

It is a pure cubic with `B=1-p` (for p<=1/2), `V=M=p(1-p)/m`. With the single fair anchor `X_0`, `q(A,Z)=[(A-p)^2 (sum_j Z_j)^2/m^2]`. Let `v=p(1-p)` and `t=(1-p)^3+p^3`. Direct resampling gives

`T_A(q)=(v*t-v^2)(3m^2-2m)/m^4 <=4 B^2 Inf_A(f)`.

For `p=m^-2`, the ratio `T_A(q)/(B^2 Inf_A(f))` is asymptotically `3/m`, although the *different*, invalid independent-increment fourth-moment step in #380 fails by a factor `~3m`. This demonstrates that the transported energy is not the same moment quantity as the obstructed fourth-moment comparison.

## Fixture 3: connected high-cover cubic with arbitrarily weak or strong coupling

Let `k>=3`, `m>=2`, `0<p<=1/2`, and `epsilon>=0`. Use independent `A_j~Bernoulli(p)`, fair `Z_j`, fair `X_(j,t)` for `j` cyclic mod k and `t=1,...,m`. Define

`F_(k,m,p,epsilon) = (1/m) sum_(j=1)^k Z_j(A_j-p) [sum_(t=1)^m X_(j,t) + epsilon X_(j+1,1)]`.

This is a bounded pure degree-three original-law ANOVA polynomial. Put `v=p(1-p)`. Exact computations (orthogonality across distinct `Z_j` and the independence of `X`):

- `B=k(1-p)(m+epsilon)/m`, with extrema attained by all `A=1`, all `X=1`, and all `Z=+1/-1`.
- `V=k v(m+epsilon^2)/m^2`.
- `M=v(m+epsilon^2)/m^2`. The maximal sites are `A_j` and `Z_j`.
- `R=V^2/(B^2 M)=p(m+epsilon^2)/[(1-p)(m+epsilon)^2]`, **independent of k**.
- If `epsilon=0`, the active hypergraph has k disjoint components, each with fractional cover 1, so `Theta=1`.
- If `epsilon>0`, every neighboring block shares an `X` vertex, so the whole hypergraph is connected. The k disjoint support edges `{Z_j,A_j,X_(j,2)}` imply `tau*>=k` by a fractional matching; assigning cover weight 1 to each `Z_j` proves `tau*<=k`. Consequently **`tau*=k` exactly**, including when epsilon is arbitrarily small.

With k=12,m=3,p=1/25, the sharp per-component cover jumps 1->12 at epsilon=0+, while the actual influence ratio approaches `1/72` continuously; at epsilon=1 the ratio equals `1/96`. In particular a positive high-cover threshold is not a robust measure of proximity to Q3 failure. Robust scoring would need to assess the *ANOVA energy* of the coupling and its effect on `B` and `M`, not just the nonzero support pattern; no replacement score is proved here.

## Reproducibility and limitations

Run `python3 -I research/nightfall/cubic-q3/check_q3_energy_transport.py`. The standard-library `Fraction` checker exhaustively enumerates selector configurations for n=2,...,6 and shared-core cases m<=8, checks 64 seeded heterogeneous binary/ternary two-control models, tests the asymptotic sharp-factor family, and verifies symbolic formulas for stitched k=3,10,12. Finite replay is not a proof for all n; the exact algebraic formulas above supply the analytic claims.

No step closes the global arbitrary-law Q3 inequality, the proposed aggregate tail bound, or the coupled mean-Q2 gate #803. The vector transport inequality holds for **any degree**, so it cannot alone force a low-degree influence lower bound. A decisive next gate is a **degree-two controller theorem** converting the controller-wise transport costs (and available anchor influences) into a bound for `sum_i E s_i(W)^2`, with explicit treatment of overlapping selectors. Test source consistency and weighted support perturbations; a scalar-energy-only charge is insufficient.