# Sharp linear adversarial-noise exponent in every fixed dimension

NIGHTFALL research checkpoint, 22 November 2026. **New author-side paper theorem candidate.** This file is not a Lean certificate, an independent non-author review, a dated priority decision, or an authorization to publish. The upper-bound proof below is independent of the topological lower bound's validity; the two-sided corollary explicitly imports the paper-level exact-collision result from merged PR #997 and the geometric inflation from merged PR #1009.

## Cross-instance prior-result reconciliation (same day)

**PR #1011 preceded this manuscript in the same research session.** The parallel instance independently proposed the *same all-dimensional ball upper exponent* by a different proof: singular-value partitioning of small factors across the near-coplanar frame. Its author-side upper proof and additional positive-annulus / known-sphere extensions are separate and need individual review. This PR #1020 contributes an **alternative polynomial evaluation + Mahler-product certificate**, with exact-rational constants and self-contained reconstruction. The common high-level all-n statement must be credited jointly and **must not** be represented as two independent novelty claims. PR #1011's source history includes older #1009 bounds (sigma/(96R)); #1009 on main now has the stronger sigma/(12R) bound. Reconcile those files before any PR #1011 merge, and preserve the two proof lineages.

## Objective, model, and claim

Fix integer n>=2, radius R>0 and noise budget 0<sigma<=R^2/64. Write m=2n-2. We consider normalized deterministic real squared-linear measurements: at stage j an arbitrary globally continuous selector on **all noisy prefixes** chooses row a_j, ||a_j||_2<=1, and observes z_j=(a_j . x)^2+e_j with |e_j|<=sigma. Decoder outputs a class modulo the global sign, with quotient distance d_pm(x,y)=min(||x-y||,||x+y||). Let E_m(n,0,R;sigma) denote the infimum worst-case reconstruction error on the full radius-R ball. Policies are allowed to depend on the declared sigma; decoders may use noncomputable feasible-fiber selection.

**Theorem U (new constructive result; paper proof).** For every fixed n>=2, there is an explicit rational constant C_n>0 and a family of **fixed** (nonadaptive), normalized m=2n-2 row frames depending on sigma such that

\[
E_{2n-2}(n,0,R;\sigma) \le R/2+C_n\sigma/R.
\]

The construction and constants are below. In particular, no adaptive selection is required to achieve the linear noise exponent in any fixed dimension, although the constant C_n depends badly on n and is not optimized.

**Corollary (importing previous paper-level claims; status remains provisional).** The exact separated ball collision of #997 plus the stronger collision inflation in merged #1009 give

\[
\boxed{\frac{\sigma}{12R}\le E_{2n-2}(n,0,R;\sigma)-R/2
       \le C_n\sigma/R.}
\]

Hence, under those source claims, the sharp exponent is one for **every fixed n>=2**: E-R/2=Theta_n(sigma/R). This closes the upper-bound gap posed in #1009/#1001, not the dimension-uniform constant question and not any issue of independent novelty or kernel certification.

## Representation change: the measurement frame is polynomial evaluation

Scale R=1 and put s=sigma/R^2, epsilon=sqrt(s) (so 0<epsilon<=1). Let d=n-1 and m=2d. Choose distinct rational nodes t_i=i/m for i=0,...,m-1. Let

\[
v_i=(1,t_i,\ldots,t_i^{d-1},\epsilon t_i^d)\in\mathbb R^{d+1},
\qquad a_i=v_i/\|v_i\|_2.
\]

Each a_i has norm one, is independent of the noisy transcript, and has a continuous (constant) selector on the entire prefix space. Its dependence on the *known noise budget* s is essential.

For a signal x=(u_0,\ldots,u_{d-1},t), define its degree-at-most-d polynomial
\[
P_x(z)=\sum_{k=0}^{d-1}u_k z^k+\epsilon t z^d.
\]
The noiseless intensity at row i is P_x(t_i)^2/N_i^2, where N_i^2=||v_i||^2<=n for epsilon<=1 and 0<=t_i<1. The Euclidean coefficient norm of P_x is exactly the anisotropic norm
\[
\|x\|_\epsilon=\left(\|u\|_2^2+\epsilon^2t^2\right)^{1/2}.
\]

## Lemma 1: exact interpolation of a noisy collision product

For any two points x,y in the same feasible noisy fiber F_z, let p=(x+y)/2 and q=(x-y)/2. Feasibility gives
\[
\left|\frac{P_x(t_i)^2-P_y(t_i)^2}{N_i^2}\right|\le2s,
\qquad
|P_p(t_i)P_q(t_i)|\le ns/2.
\]

Let H(z)=P_p(z)P_q(z), of degree at most m=2d. Its leading coefficient h_m=epsilon^2 p_d q_d has |h_m|<=s, because ||p||,||q||<=1. Set W(z)=\prod_{i=0}^{m-1}(z-t_i), a monic degree-m polynomial. The difference J=H-h_m W has degree at most m-1 and satisfies J(t_i)=H(t_i).

Let V_{ik}=t_i^k, i,k=0,...,m-1, be the rational invertible Vandermonde matrix, and write
\[
S_m=\sum_{k=0}^{m-1}\sum_{i=0}^{m-1}|(V^{-1})_{ki}|.
\]
Exact interpolation yields
\[
\|J\|_{\mathrm{coeff},1}\le (n/2)S_m\,s.
\]
Also ||W||_(coeff,1)<=\prod_i(1+|t_i|)<=2^m, so
\[
\|H\|_{\mathrm{coeff},2}
\le\|H\|_{\mathrm{coeff},1}
\le s A_n,\qquad A_n=(n/2)S_m+2^m.
\]

**Certificate:** All quantities in V^{-1}, S_m and A_n are exact rational numbers. The companion Python checker independently inverts the Vandermonde matrix over fractions and verifies interpolation on deliberately chosen rational polynomial pairs. It does not prove the analytic lemma by finite testing.

## Lemma 2: dimension-fixed polynomial-product coercivity

For any two real polynomials P,Q of degree at most d,

\[
\|PQ\|_{\mathrm{coeff},2}\ge 4^{-d}
 \|P\|_{\mathrm{coeff},2}\|Q\|_{\mathrm{coeff},2}.
\]

Here is an independent standard analytic proof rather than an appeal to approximate sampling. For a nonzero complex polynomial F of degree e<=d, let M(F) denote its Mahler measure (leading coefficient magnitude times the product of max(1,|root|)). The elementary symmetric-functions bound gives ||F||_2<=||F||_1<=2^e M(F)<=2^d M(F). Jensen's formula and Parseval on the unit circle give M(F)<=||F||_2. Multiplicativity M(PQ)=M(P)M(Q) therefore yields

\[
\|PQ\|_2\ge M(PQ)=M(P)M(Q)\ge4^{-d}\|P\|_2\|Q\|_2.
\]

The zero-polynomial case is trivial. This is a classical, very nonsharp polynomial inequality; no originality is claimed for the lemma.

Combining with Lemma 1, define the fully explicit rational number

\[
M_n=4^d A_n,\qquad K_n=16\max(1,M_n),\qquad C_n=K_n^2.
\]
Then every feasible-fiber pair satisfies the *anisotropic bilinear certificate*
\[
\boxed{\quad\|p\|_\epsilon\,\|q\|_\epsilon\le M_n s.\quad}
\]

## The decoder and its two exhaustive branches

For a nonempty feasible noisy fiber F_z in the unit ball (the actual input is always feasible), use the following noncomputable permitted decoder.

**Away-axis branch.** If there is x in F_z with ||x_W||>K_n epsilon, output [x], where x_W is its first d coordinates. For every y in F_z, sign-flip y if necessary so ||p||_epsilon>=||q||_epsilon. This is legal because the intensity readings and feasibility conditions are sign-invariant. Then x=p+q and the triangle inequality give ||p||_epsilon>=||x||_epsilon/2>K_n epsilon/2. The bilinear certificate implies ||q||_epsilon<2M_n epsilon/K_n. Since epsilon<=1, ||q||<=||q||_epsilon/epsilon<2M_n/K_n. Consequently
\[
d_\pm(x,y)\le\|x-y\|=2\|q\|<4M_n/K_n\le1/4.
\]
Thus the output has worst-case error strictly below 1/2, independent of the chosen feasible representative.

**Near-axis branch.** Otherwise every x in F_z satisfies ||x_W||<=K_n epsilon. Output the fixed sign class [e_n/2]. For any x in F_z,
\[
d_\pm(x,e_n/2)^2=\|x_W\|^2+(|x_n|-1/2)^2
\le K_n^2s+1/4
\]
because |x_n|<=1. Hence
\[
d_\pm(x,e_n/2)\le\sqrt{1/4+K_n^2s}\le1/2+K_n^2s.
\]
The two branches exhaust all feasible fibers. Reintroducing R gives Theorem U with C_n=K_n^2.

## Exact-rational checkpoints (not numerical optimization)

For nodes i/(2n−2), the independently reproduced inverse-Vandermonde L1 sums and resulting coarse constants are:

| n | m | S_m | M_n | K_n |
|---|---:|---:|---:|---:|
| 2 | 2 | 5 | 36 | 576 |
| 3 | 4 | 209 | 5272 | 84352 |
| 4 | 6 | 10625 | 1364096 | 21825536 |
| 5 | 8 | 580865 | 371819136 | 5949106176 |

These intentionally huge constants demonstrate exact explicitness, *not* practical utility. At n=2, the source #1009 fixed-row bound has a much better constant 18. The insight is the structural dimension bridge: **polynomial interpolation plus nonzero-divisor coercivity converts bounded intensity noise into an anisotropic product certificate, which then gives a near-axis/away-axis decoder.**

## Falsification, independent-review plan, and stop rule

- **Claim inputs:** n>=2 fixed; full ball including zero; normalized squared-linear real readings; independent bounded errors of both signs; fixed frame chosen with known sigma; arbitrary decoder output modulo sign; no runtime bound.
- **Proof dependencies:** elementary rational Vandermonde interpolation, classical Mahler measure factorization and Jensen/Parseval, ordinary Euclidean inequalities. The lower half separately imports #997/#1009, whose full topological and geometric proof status is paper-level.
- **Audit B (design before reading the verifier):** independently reconstruct the noisy-product bound at m=2d, challenge the leading-coefficient control, prove or falsify the Mahler inequality including degree drops/zero factors, and seek a feasible fiber where the two-branch decoder violates the claimed radius. Check sign choice and the selector's dependence on sigma.
- **Checker scope:** exact-rational inverses and interpolation identities; independent random polynomial-product probes; direct feasible-fiber adversarial samples. These are falsification tests, not universal proof verification.
- **Novelty gate:** compare the exact adversarial intensity-noise, underdetermined fixed frame, noncomputable decoder model with the 2013 phase-retrieval stability literature, 2026 phase-retrieval condition numbers, and adaptive-continuous work of Ullrich. Generic polynomial coercivity and phase retrieval are prior art; no first-in-field assertion is made here.
- **Next decision:** ask a non-author reviewer to certify the full upper proof and the topological-to-robust lower transfer, and seek a dimension-uniform or polynomial-in-n C_n; do not polish an already proved fixed-n exponent without structurally improving the dependence on n.
- **Status:** author-side paper proof, exact arithmetic and CI to be separately recorded; no Lean theorem or independent specialist review. Preserve all negative controls and superseded v1 constants; do not promote the broader system automatically.

Source links: merged phase-noise inflation [PR #1009](https://github.com/d3lefts/d3lefts/pull/1009), topological ball collision [PR #997](https://github.com/d3lefts/d3lefts/pull/997), and the adjacent robustness charter [PR #1001](https://github.com/d3lefts/d3lefts/pull/1001).
