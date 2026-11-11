# Theorem D v2.0 — Complete analytic quadratic closure via finite Rademacher compression

**NIGHTFALL · Devin J. Wright · 11 November 2026 · revision v2.0 of [Theorem D](UNIVERSAL_THEOREM.md)**

**Scientific status:** complete analytic argument for degree-two scalar/Hilbert influence and the rank-linear adaptive corollary. Source full-chain Lean theorem **NOT** certified; specialist non-author review and worldwide priority **NOT** certified. Do not claim otherwise. This revision replaces the continuous spherical/gamma calculation with a finite, elementary sign fourth-moment argument. Earlier original proof records, source hashes, and numerical checks are preserved; they are not superseded as independent review.

## Theorem

Let \((\Omega_i,\mu_i)_{i\in I}\) be arbitrary independent heterogeneous probability spaces, including possibly nonatomic, uncountably many input coordinates and arbitrarily small atom masses. Let \(G\) be strongly measurable with Hoeffding degree at most two, \(\|G\|\le B\) a.s., and values in a real Hilbert subspace of dimension at most \(r\ge1\). Define
\[
V=\mathbb E\|G-\mathbb EG\|^2,\quad I_i=\mathbb E\|G-\mathbb E_iG\|^2,\quad M=\sup_i I_i.
\]
Then
\[
\boxed{V\le15(1+\sqrt3)\sqrt{3r}\,B\sqrt M,\qquad V^2\le675(1+\sqrt3)^2rB^2M\le5043rB^2M.}\tag{1}
\]
(The second comparison is non-strict to cover \(M=0\).)

For any strongly measurable Hilbert output \(F\) bounded by \(B\), of Hoeffding degree at most two, let \(\tau_r\) denote its covariance variance beyond the leading \(r\) real output directions. A deterministic measurable adaptive whole-coordinate policy of hard depth
\[
\boxed{N\le\lceil20172\,rB^2/\eta\rceil}\tag{2}
\]
achieves \(\mathbb E\|F-\mathbb E[F\mid\mathrm{observations}]\|^2\le\tau_r+\eta\). This is observation, not runtime, complexity. The \(r/\eta\) rate is necessary up to a constant, already for bounded additive fair signs. There is no alphabet-uniform fixed nonadaptive observation bound for all degree-two scalar functions.

## I. Three scalar budgets: proved from an actual bounded degree-two function

First take a finite positive-atom product and scalar \(g\colon\prod\Omega_i\to[-B,B]\). Write its actual canonical decomposition \(g=m+\sum_i h_i(X_i)+\sum_{i<j}h_{ij}(X_i,X_j)\), with each component centered in all its own inputs.

**Matching budget.** For any matching \(P\) of coordinate pairs, put \(b_{ij}=\max|h_{ij}|\). Select a point attaining \(b_{ij}\); because the pair kernel is separately centered, averaging its rectangular difference over the other two rectangle corners recovers its value. Thus some rectangle has signed mixed difference \(\Delta_{ij}\ge b_{ij}\). For every matched pair, define an even distribution assigning half mass to the rectangle's two opposite even corners, and an odd distribution assigning half mass to the other two corners. Independently multiply these two-point distributions over disjoint matching blocks and leave unmatched inputs at the same law. All single-coordinate marginals agree under the two global experiments; all distinct blocks are independent in both. Every degree-at-most-two term other than an edge in \(P\) therefore has identical expectations under the experiments. The difference of expectations of \(g\) equals \(\frac12\sum_P\Delta_{ij}\), and is at most \(2B\). Consequently
\[
\sum_{(i,j)\in P}b_{ij}\le4B. \tag{3}
\]

**Additive projection.** At fixed \(x\), the Markov interpolation \(q_x(t)=[\prod_i(\mathbb E_i+t(\mathrm{Id}-\mathbb E_i))g](x)\) lies in \([-B,B]\), \(0\le t\le1\). It has degree at most two in \(t\). The exact interpolation identity \(-2q_x(0)+4q_x(1/2)-q_x(1)=m+\sum_ih_i(x_i)\) bounds the absolute value of the additive projection by \(7B\). Its total range is therefore at most \(14B\); as this is an additive sum, the total range is the sum of the component ranges. Each centered \(h_i\) has \(L^2\) norm at most half its range by Popoviciu. Thus
\[
\sum_i\|h_i\|_{L^2(\mu_i)}\le7B.\tag{4}
\]

**Section oscillation.** At any full input \(x\), choose for each \(i\) a maximizing one-coordinate replacement \(y_i^+\). Independently switch all coordinates to their \(y_i^+\) values with probability \(t\). The resulting expectation is a quadratic polynomial bounded by \(B\) on \([0,1]\), with derivative at zero equal to the sum of all nonnegative one-coordinate gains. The degree-two endpoint Markov inequality bounds that derivative by \(8B\). Repeating for minimizing replacements gives \(\sum_i\operatorname{osc}_i(g;x)\le16B\). Define the actual centered section \(U_i(y;X_{-i})=h_i(y)+\sum_{j\ne i}h_{ij}(y,X_j)\); its \(L^2(\mu_i)\) norm is at most half its coordinate oscillation. Integrating yields
\[
\sum_i\mathbb E\|U_i(\cdot;X_{-i})\|_{L^2(\mu_i)}\le8B.\tag{5}
\]
These are direct consequences of the true decomposition, not supplied matching/oscillation certificates.

## II. New proof representation: finite-sign Hilbert compression

For arbitrary vectors \(w_1,\ldots,w_r\) in **any** real Hilbert space \(\mathcal H\), let \(\epsilon_k\) be independent fair signs and \(W=\sum_k\epsilon_kw_k\). Set \(s=\sum_k\|w_k\|^2\). Exact sign orthogonality gives \(\mathbb E\|W\|^2=s\). Fourth-power expansion gives
\[
\mathbb E\|W\|^4
=\sum_k\|w_k\|^4+2\sum_{j<k}\|w_j\|^2\|w_k\|^2
 +4\sum_{j<k}\langle w_j,w_k\rangle^2
\le3s^2. \tag{6}
\]
Two Cauchy–Schwarz applications imply \(s^{3/2}\le(\mathbb E\|W\|)\sqrt{\mathbb E\|W\|^4}\). Hence
\[
\boxed{\mathbb E_\epsilon\big\|\sum_k\epsilon_kw_k\big\|\ge\sqrt{s/3}.}\tag{7}
\]
This is a *classical finite Khintchine-type consequence*, not individually original. Unlike spherical averaging it works directly in \(\mathcal H=L^2(\mu_i;\mathbb R)\) and involves no continuous output-direction measure.

For \(G\colon\prod\Omega_i\to\mathbb R^r\), put \(g_\epsilon=\langle\epsilon,G\rangle/\sqrt r\). Pointwise \(|g_\epsilon|\le\|G\|\le B\), and its Hoeffding components are exactly the corresponding scalar projections. Apply (3)–(5) to each \(g_\epsilon\); then average over all \(2^r\) signs. For every vector matching edge, choose a point attaining \(b_{ij}=\sup\|h_{ij}\|\) and apply (7) with \(\mathcal H=\mathbb R\). For \(h_i\) and the sections \(U_i\), apply (7) with \(\mathcal H=L^2(\mu_i;\mathbb R)\) to their \(r\) output-coordinate functions. This gives simultaneously
\[
\boxed{\sum_{(i,j)\in P}b_{ij}\le4B\sqrt{3r},\
\sum_i\|h_i\|_2\le7B\sqrt{3r},\
\sum_i\mathbb E\|U_i\|_2\le8B\sqrt{3r}.}\tag{8}
\]
All output interactions may overlap.

## III. Match, assign, take the actual Hilbert fourth moment

Sort positive interaction edges by decreasing \(b_{ij}\), retaining an edge exactly when it is disjoint from those already retained. Give each endpoint of a retained edge cost \(c_i=b_{ij}\), and all unused vertices cost zero. Every interaction edge intersects a retained edge of at least its weight, so it has some endpoint whose cost dominates its weight. Assign the edge to such an endpoint, writing \(S_i\) for the assigned neighbors. From (8),
\[
\sum_i c_i\le8B\sqrt{3r}. \tag{9}
\]

In the actual Hilbert space \(\mathcal H_i=L^2(\mu_i;\mathbb R^r)\), put \(Y_{ij}=h_{ij}(\cdot,X_j)\), \(j\in S_i\), and \(Z_i=\sum_{j\in S_i}Y_{ij}\). The \(Y_{ij}\) depend on distinct independent neighbors and have zero mean **as \(\mathcal H_i\)-valued random variables** by ANOVA degeneracy. Their norms are at most \(c_i\). Write \(s_i=\mathbb E\|Z_i\|^2=\sum_{j\in S_i}\|h_{ij}\|_2^2\le I_i\le M\); summing \(s_i\) counts every pair energy exactly once.

For arbitrary independent centered Hilbert increments bounded by \(c_i\), expanding the fourth power as in (6) (without sign symmetry, using centering and independence) yields the actual bound
\[
\mathbb E\|Z_i\|^4\le c_i^2s_i+3s_i^2. \tag{10}
\]
The *arbitrary finite number of actual product increments* version has a separately scoped Lean 4.35.0 kernel receipt [#43062171542](https://github.com/d3lefts/d3lefts/actions/runs/43062171542). Here the inputs to that lemma are derived from \(h_{ij}\), not assumed.

Hölder interpolation gives \(s_i^{3/2}\le\mathbb E\|Z_i\|\sqrt{\mathbb E\|Z_i\|^4}\), and therefore
\[
s_i\le(c_i+\sqrt{3M})\mathbb E\|Z_i\|. \tag{11}
\]
Conditional expectation of \(U_i\) over only its assigned neighbors is \(h_i+Z_i\). Jensen therefore gives \(\mathbb E\|Z_i\|\le\mathbb E\|U_i\|+\|h_i\|_2\). By (8), \(\sum_i\mathbb E\|Z_i\|\le15B\sqrt{3r}\), while \(\mathbb E\|Z_i\|\le\sqrt{s_i}\le\sqrt M\). Summing (11) and using (9),
\[
\sum_{i<j}\|h_{ij}\|_2^2=\sum_i s_i
\le(8+15\sqrt3)B\sqrt{3rM}.
\]
The additive variance is \(\sum_i\|h_i\|_2^2\le\sqrt M\sum_i\|h_i\|_2\le7B\sqrt{3rM}\). This proves (1) for finite products, **from the actual bounded function**.

## IV. Arbitrary products and actual posterior hard budget

For any strongly measurable \(F\), select its essentially countable active input support. Bounded finite-rectangular conditional expectations \(F_n\) converge to \(F\) in \(L^2\), preserve degree at most two by commutation with coordinate averaging, and satisfy \(I_i(F_n)\le I_i(F)\) for every coordinate. Passing finite-product (1) to the limit gives the identical constant on arbitrary completed products; zero-mass cells are discarded before the finite argument.

Project onto a fixed leading rank-\(r\) covariance subspace \(G=P_rF\). Every reachable adaptive posterior section has the same bound \(B\) and degree ≤2 under its independent residual product. Put \(\kappa=(5043rB^2)^{-1}\), posterior variance \(v\), total resampling influence \(p=\sum_i I_i\), and largest influence \(m=\sup_i I_i\). The ANOVA energy identities give \(v\le p\le2v\); (1) gives \(m\ge\kappa v^2\). A measurable maximal-influence coordinate exists because positive summable countable influence sequences attain their supremum (choose the first maximizer).

Writing \(P_t=\mathbb E p\) and \(M_t=\mathbb E m\) for the actual random transcript, Jensen yields \(M_t\ge\kappa P_t^2/4\). Revealing coordinate \(i\) reduces **expected** total degree-weighted energy by exactly \(I_i\): a Hoeffding component containing \(i\) loses one unit of its degree-weighted energy. Thus \(P_{t+1}=P_t-M_t\le P_t-(\kappa/4)P_t^2\), and reciprocal telescoping gives \(P_N\le4/(\kappa N)\). At \(N=\lceil20172rB^2/\eta\rceil\), projected conditional-mean risk is at most \(\eta\). Orthogonal residual conditional-mean risk is at most the fixed spectral tail \(\tau_r\). This proves (2).

## V. Tight order and fixed-query impossibility

For all \(r,k\), let \(Z_{jt}\) be independent fair signs and set \(F=(\sum_{t=1}^k Z_{1t},\dots,\sum_{t=1}^k Z_{rt})/(k\sqrt r)\). This is bounded by one, degree one, rank \(r\), with variance \(1/k\). Every observed sign lowers optimal squared posterior risk by exactly \(1/(rk^2)\). Reaching \(\eta=1/(2k)\) requires at least \(rk/2=r/(4\eta)\) whole-coordinate queries, proving matching order.

Separately, with uniform \(m\)-valued address \(K\) and independent fair leaves \(Z_j\), the scalar degree-two function \(f(K,Z)=Z_K\) is recovered with two adaptive queries. A fixed observer querying the address and \(q\) leaves has risk \(1-q/m\); one querying \(q\) leaves without the address has risk \(1-q/m^2\). Hence no alphabet-independent finite fixed-query upper bound exists for this class.

## Certification and originality boundaries

The analytic chain (I)–(V) has no assumed matching, Hilbert moment, or posterior drift inequality: each is derived from the stated model. The integer constant is independently checked by [the existing exact Fraction checker](check_rank_linear_exact.py), plus a new 1,032-case **exact** finite-sign/Gram-matrix falsifier. Neither constitutes a kernel proof of (1)–(2).

**Lean scope:** finite Hoeffding decomposition and many-increment Hilbert fourth moment are separately compiled; actual coupling/matching assignment, full scalar theorem, vector rank lift and completed-product posterior theorem are **not** composed in a single Lean declaration. This is an analytic closure, not an end-to-end Lean certificate.

**Prior art:** David Turturean (2026, arXiv:2611.09773), Huffstutler–Miloschewsky–Podder (2026, arXiv:2611.12795), Girish–Mittal–Nehoran–Raz (2026, arXiv:2609.35327), Escudero Gutiérrez (2023, arXiv:2304.06713), Littlewood/Bohnenblust–Hille, Grothendieck, Khintchine, Hoeffding, Markov, and OSSS. The classical sign lemma and scalar analytic mechanisms are not individually original. No validated global priority or independent non-author proof review exists for the full combination. Do not promote without those gates.

**Checks:** run \`python3 research/nightfall/2026-11-quadratic-rank-optimal/check_rank_linear_exact.py\` and \`python3 research/nightfall/2026-11-quadratic-rank-optimal/check_quadratic_finite_sign_lift.py\`. This revision is intended as the final *analytic* proof source, preserving the original PR #362/#364/#368 provenance.
