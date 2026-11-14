# Hereditary Q2 with a locally certified cross-factor perturbation

**NIGHTFALL — 2026-11-13**. Proof status: source-level analytic transfer under the independent-product scalar Q2 theorem; 17,652 additional exact finite falsification assertions. Classical TV stability is inherited. Not a same-pin terminal Lean Q2 proof or a worldwide priority determination.

## Main theorem

Let h be any feasible history consisting of the supplied separator and any set of *individually observed coordinates*. Let nu_h be the associated product reference distribution on the remaining blocks, and let mu_h be the actual conditional distribution. The same positive cross factors remain in the Radon–Nikodym derivative L_h and their local source-certified ranges have not widened. Define R=product_F u_F/ell_F and delta=(sqrt(R)-1)/(sqrt(R)+1). Then

    TV(mu_h,nu_h) <= delta

**uniformly for every h**, including histories chosen by a randomized adaptive policy.

Let f take values in a Hilbert ball of radius B and be algebraic interaction-degree <=2 in the independent residual blocks. With
    V_h=Var_{mu_h}(f);
    I_j^{mu_h}=E_{mu_h}|| f-E_{mu_h}[f|X_{-j}]||^2;
    M_h=max_{j unread} I_j^{mu_h},
the author-side original-product scalar Q2 premise yields the **actual-law approximate structural inequality**

    (max{V_h-4B^2 delta,0})^2 <= C2 B^2 (M_h+4B^2 delta)

for every feasible h. For rank-r Hilbert output replace C2 with C_r=C2/c_r^2.

This is a genuine dependent-source *conditional influence statement* with an additive uncertainty floor. It does **not** imply a positive dimension-free influence bound for every connected Gibbs system.

## Exact proof of source transport

For two laws p,q with TV<=delta on the same support and bounded f, both Var(f) and I_j(f) are infima of squared prediction risk, with predictors respectively constant or measurable in X_{-j}. Radially clipping a predictor into the radius-B Hilbert ball never increases loss. The resulting loss takes values in [0,4B^2]. Hence for any fixed legal predictor, its risks under p and q differ by at most 4B^2 delta; taking infima in both directions yields

    |Var_p(f)-Var_q(f)|<=4B^2 delta
    |I_j^p(f)-I_j^q(f)|<=4B^2 delta.

For the actual and reference conditional sources, the positive cross-factor ranges remain valid after fixing any more individual coordinates; the sharp likelihood-oscillation TV lemma gives the same delta. Under the reference product law, the residual f still has degree <=2: conditioning within a reference block does not couple that block to another; therefore

    Var_{nu_h}(f)^2 <= C2 B^2 max_j I_j^{nu_h}(f).

Substituting both stability estimates completes the inequality. The bound is hereditary **without a union bound or an additional factor counting observation rounds**.

## Source-level verification

The new independent script check_hereditary_q2_exact.py exhaustively enumerates **3,636** conditional histories across **20** rational connected star-plus-path models, testing source normalization, hereditary ratio-TV, both risk infimum stability estimates, and the approximate Q2 inequality with exact rational upper constant 1229. **17,652** exact assertions passed. This is finite falsification, not a proof of universal Q2. Original source script SHA-256: 767ac12353463f5f0f41dfe6a46564e6014172607289c66cf77d4917c96821e0.

The parent note APPROX_SEPARATOR_Q2_20261113.md proves the dimension-free observation cost and the same-oracle Omega(1/eta) connected graph lower bound. It identifies the classical cutset and posterior-perturbation references. The main new mathematical task remains finding a stronger locally summable dependence budget than the global cross-factor oscillation sum Lambda.

**Novelty limit:** TV-stability of optimal prediction risks is elementary. The synthesis with the author-analytic Q2 theorem is useful as a clearly scoped research transfer, not independently verified original theory.