# Quantitative maximal-interaction sensitivity — exact recovery bridge v0.3

Research owner: Devin J. Wright / NIGHTFALL, 2026-11-10.
**Status:** Complete written mathematical argument, exact finite falsification PASS; not yet a kernel-checked *ANOVA* theorem or independent human-review clearance. This is a classical orthogonality/Cauchy mechanism; no first-discovery claim.

## Theorem (highest-order ANOVA energy gives uniform block sensitivity)

Let X=(X_i) be independent random variables with product law mu on an arbitrary finite or countable coordinate set I. Let f take values in a finite palette A contained in a real interval of range R>0, and have finite Hoeffding degree k>=1. Write f=E f + sum_{1<=|T|<=k} f_T in L²(mu). Let S be a finite coordinate set with |S|=k and e_S:=||f_S||²_(L²(mu_S))>0.

Then for mu_(I\S)-almost every complementary configuration z, and for mu_S-almost every base value v, **both** inequalities hold:

    Var_U[f(z,U)] >= e_S,
    P_U(f(z,U) != f(z,v)) >= e_S / R²,          U ~ mu_S.

In particular S is a positive-measure sensitive block at almost every x. In a finite discrete product with strictly positive masses and a pointwise ANOVA decomposition, the assertion holds for EVERY z and v.

The statement remains true for bounded real-valued f with essential range R, with suitable a.e. qualifications. A finite palette is needed by the subsequent exact-recovery block-to-Boolean conversion, not by this energy lemma.

## Proof

Every Hoeffding component f_T depends only on T and is centered in each coordinate i of T. For T != S with |T|<=k, choose i in S\T. The S-coordinate conditional inner product of f_T(z,.) with f_S(.) vanishes: f_T is independent of u_i, while f_S has mean zero in u_i, for every other coordinate value where the component versions are defined.

Finite sums give immediately, for each fixed complementary z,

    <f(z,.),f_S>_(mu_S) = <f_S,f_S>_(mu_S) = e_S.

For countable products, approximate the L² sum by finite partial sums; each section-level inner product converges in L²(mu_(I\S)) by Cauchy–Schwarz in u. Since every partial sum equals the same e_S once the S term is included, the identity persists for almost every z. Also E_(mu_S) f_S=0.

Set phi_z(u)=f(z,u) and m_z=E_U phi_z(U). Then

    e_S = <phi_z-m_z,f_S> <= sqrt(Var_U phi_z) sqrt(e_S).

Since e_S>0, Var_U phi_z >= e_S.

For any base v with a=phi_z(v) in the essential output interval,

    E_U[(phi_z(U)-a)^2]
       = Var_U(phi_z(U)) + (m_z-a)^2
       >= e_S.

But (phi_z(U)-a)^2 <= R² 1{phi_z(U)!=a} almost surely. Therefore

    mu_S{u: phi_z(u)!=phi_z(v)} >= e_S / R².

This is uniform in the base value v for every good complement z. QED.

## Why this strengthens the earlier proof

The v0.2 manuscript had only **positivity** of the resampling witness set. This lemma supplies an explicit, configuration-independent lower bound controlled by the highest-order Hoeffding energy, valid for each selected conditional section. In the adaptive proof the energy is e_(A,S)(a), measurable in the previously observed prefix a; it need not be uniformly bounded below as a ranges over prefixes. Thus the result is a quantitative sensitivity certificate, **not** a dimension-independent runtime bound for finding witnesses.

The null-diagonal counterexample in the adversarial audit has e_S=0 and therefore cannot violate this theorem. Conversely, the lemma forbids any nonzero highest-order interaction from being supported by merely null changing sets.

## Exact independent finite checker

Reproduce from the repo root:

    python3 research/nightfall/formalization/product_space/check_finite_anova_recovery.py

The independent standard-library checker constructs finite Hoeffding terms by weighted conditional averages and signed subset inversion, verifies centering/reconstruction and all prefix-section degrees, then checks Var_U f(z,U)>=e_S and R² P_U(change)>=e_S at every base point for each maximal nonzero S.

Result of local run (Python 3, fractions.Fraction): **PASS, 752 cases**: all 256 Boolean 3-bit functions at fair masses, all 256 at unequal positive masses, plus 240 seeded heterogeneous 2×3×2 ternary-palette functions. Exact rational, no floating-point tolerance. This finite check cannot certify the general theorem.

## Further formalization boundary

The separately checked Lean switching core (#301) and the newly added sectioning/positive-atom source are distinct from the analytic proof above. A full finite ANOVA formalization must construct the projection terms and discharge their orthogonality/centering without introducing the theorem as an assumed hypothesis. The countable-product passage and measurable section choice are not Lean-checked. Do not promote publication/novelty status automatically.
