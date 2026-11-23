# Latent-Averaged Wyner Simulation: degree-preserving QW+ and all-degree extension
NIGHTFALL mathematical upgrade v0.3, 2026-11-22 CT. Paper level only.

**Certification gate:** new source-level result is NOT yet Lean compiled, independently mathematically refereed, or globally priority-cleared. Already certified #776 and #970/#976 are input dependencies, not a certificate of the new composition. The older QW v0.1–v0.2 manuscript is retained for provenance but its numerical bound is superseded by QW+ below.

## Result (quantifiers and constants)

For every finite alphabet A, finite coordinate index I, arbitrary probability law ν on A^I, bounded f:A^I→[0,1] of indicator-monomial degree at most d≥1, every s>C_W(ν) in **nats**, 0<τ≤1/4, ε>0 and integer q≥1, propose a deterministic original-coordinate tree t of depth at most q such that

\[
\Pr_\nu(|f-t|>\varepsilon)\le
\frac{36K_d^3\tau^{-3/2}+2^{21}d^4K_d s\tau^{-3}}{q}
+\frac{\tau}{\varepsilon^2},\qquad K_d=\pi^2d^2/2.
\tag{LA-W}
\]

For **degree ≤2**, the independently certified original-product Q2 theorem with
\(C_2=(2(1+\sqrt2)\sqrt3+11901/6250)^2\)
improves the seed charge:

\[
\boxed{\Pr_\nu(|f-t|>\varepsilon)\le
\frac{4\pi^2C_2\tau^{-2}+2^{26}\pi^2s\tau^{-3}}q
+\frac{\tau}{\varepsilon^2}.}
\tag{QW+}
\]

For d=2 the best resulting *paper* upper bound replaces the seed charge with
\(\min(4\pi^2C_2\tau^{-2},\,288\pi^6\tau^{-3/2})\), retaining
\(2^{26}\pi^2s\tau^{-3}\). Choosing between the trees is a mathematical upper-bound envelope, not a query lower bound or efficient construction.

## Proof: project the latent label before rigidity

Fix a finite product-mixture representation ν=Σθ πθ Pθ of Wyner cost I(Θ;X)<s, available through certified general-to-finite #976. At any positive-mass original-coordinate query history, freeze queried coordinates in g, retain product posterior components Pθ and normalize π. The already certified finite maximal-star coupling #970 gives **independent seeds** U_i with component decoders Xθ,i(U_i), exact component law Pθ and a reference R(U). Define

\[
\Delta=\mathbb E_{\theta,U}[g(X_\theta(U))-g(R(U))]^2,\qquad
H(u)=\sum_\theta\pi_\theta g(X_\theta(u)).
\]

The Key Lemma on the original degree-d g and existing row certificate K_d proves
\(\Delta\le 2K_dw_0+128d^2\eta\)
provided every unqueried coordinate j has
\(\beta_j(\eta)=\sum_\theta\pi_\theta{\bf 1}_{\mathrm{TV}(P_{\theta j},Q_j)>\eta}\le w_0\).

**Structural operator:** Each map u↦g(Xθ(u)) is a coordinatewise pullback on the seed product, so has *degree at most d* and values in [0,1]. Their convex label average H also has *degree d and values [0,1]*, with no added label coordinate. This is the crucial difference from #939 and the original #970 degree-(d+1) lift.

By exact finite ANOVA, writing F(θ,u)=g(Xθ(u)), we have
\[
\operatorname{Var}_{\theta,U}F=\operatorname{Var}_U H+
\mathbb E_U\operatorname{Var}_\theta(F(\theta,U)\mid U).
\]
At each seed u, H(u) minimizes label-averaged squared error, hence
\[
\mathbb E_U\operatorname{Var}_\theta(F(\theta,U)\mid U)
\le\mathbb E_{\theta,U}(F(\theta,U)-g(R(U)))^2=\Delta.
\tag{*}
\]
There is **no comparison of reference variance** and no factor-four original/reference influence transfer; old QW used both and therefore paid τ^-6 instead of τ^-3.

Choose η=τ/(512d²), w0=τ/(8K_d). Then the Key Lemma gives Δ≤τ/2, so at every active node of mixture variance >τ, the seed-product variance of H satisfies
\(\operatorname{Var}_\kappa H>\tau/2\).
If some unqueried coordinate violates the small-information condition, the existing nats KL≥TV² charge gives
\[
I(\Theta;X_j\mid\text{history})\ge
\eta^2w_0=\tau^3/(2^{21}d^4K_d)=g_b.
\]
This is **actual conditional source information**, not H(Θ) nor log M.

Otherwise apply independent product inequalities to H:

**Quadratic d=2.** Source #776 says
\((\operatorname{Var}_\kappa H)^2\le C_2\max_j\operatorname{Inf}_{\kappa,j}(H)\).
Therefore some j has seed influence >τ²/(4C2). Jensen for the same latent label on both j-resampled seed copies, followed by the already certified true component seed pushforward, gives
\[
\operatorname{Inf}_{\kappa,j}(H)\le
\sum_\theta\pi_\theta\operatorname{Inf}_{\kappa,j}(g\circ X_\theta)
=\sum_\theta\pi_\theta\operatorname{Inf}_{P_\theta,j}(g).
\]
Because g takes values in [0,1], the certified source inequality 2 Inf≤L yields original-coordinate posterior increment
\(\sum_\theta\pi_\theta L_{P_\theta,j}(g)>\tau^2/(2C_2)=g_a^{Q2}\).

**All d≥1.** Turturean's certified product mean-increment bound,
\(\operatorname{Var}_\kappa(H)^3\le144K_d^4L_{\kappa,j}(H)^2\),
and pointwise triangle/Jensen with exact component seed pushforward give
\(L_{\kappa,j}(H)\le\sum_\theta\pi_\theta L_{P_\theta,j}(g)\).
Since VarH>τ/2 and \(144/36^2=1/9<1/8\), the original posterior increment exceeds
\(g_a^{MI}=\tau^{3/2}/(36K_d^2)\).
If j was already queried, g and therefore H are invariant on j, making both seed influence and mean increment zero; therefore both selected queries are original **unqueried** coordinates.

The exact Wyner remaining-information/potential tree on main (#970) charges expected original-query count by
\(K_d/g_a+s/g_b\).
Truncating after q queries and returning conditional expectations on low-variance leaves gives failure bound
\((K_d/g_a+s/g_b)/q+\tau/\varepsilon^2\). Substitution yields (LA-W) and (QW+). **This completes the author-side paper proof, not the Lean kernel proof.**

## Same-model comparison with #939

On exactly the same d=2, ν, s>C_W(ν) in nats, τ, q, ε model, #939's *paper-only* degree-three-lift, Wyner-normalized bound has seed coefficient
\(48\pi^4(2^2)(3^4)\) times τ^-3/2 and information coefficient
\((525.6\pi^4)^3(2^6)(3^{12})\) times s τ^-9/2.
The **new all-degree mean-increment seed** at d=2 has coefficient \(36(2\pi^2)^3=288\pi^6\) and the *same* τ^-3/2 exponent; its exact coefficient ratio is
\(\pi^2/54<1\). Its information coefficient is only \(2^{26}\pi^2\), with exponent τ^-3 rather than τ^-9/2. Thus on 0<τ≤1/4, s≥0 the new **paper estimate** beats both #939 paper terms simultaneously. Quadratic Q2 further improves the seed coefficient for most practical τ. This supersedes the old v0.2 nonuniform comparison **conditional on full theorem validity**.

## Independent exact and Lean evidence ledger

- Independent exact-rational coupling verifier: check_qw_seed_average_exact.py enumerates 490 finite heterogeneous Bernoulli product mixtures, including 0/1 masses, tests Var_mix=Var_seed H+Var_label|seed exactly, loss≤Delta, and 1,310 influence/mean-increment Jensen inequalities. Executed locally before source commit with 490/490 passing; GitHub exact-head CI is separately required.
- Added Lean sources QuadraticWynerLabelProjection.lean (source-independent weighted variance/Jensen) and QuadraticWynerSeedAverage.lean (source-native degree/mean/variance survival); they are **not kernel-certified merely by being uploaded**.
- Still missing: strict Lean build/repair of those modules; genuine seed-source Jensen pinfl/pincr pushforwards including zero atoms; the **unconditional** posterior good-query dichotomy using exact τ,η,w0,K,C2; its integration with the compiled original-coordinate Wyner DTree and general-latent infimum; full named final #print axioms, leanchecker and exact-head CI.
- Adversarial review must target the degree predicate under arbitrary posterior restrictions, the conditional-variance normalization, seed resampling joint law, information source units, and the assumption that every unqueried posterior seed law is a product (it is, conditional on fixed original history and latent component).
- Global priority remains unverified. Published antecedents Turturean (November 2026), Girish–Mittal–Nehoran–Raz (September 2026), Aaronson–Ambainis (2014), OSSS (2005), Wyner (1975), and NIGHTFALL #939 are expressly credited.

**No merge, site claim promotion, or submission until the new fully quantified terminal—not merely conditional lemmas—is kernel checked and audited.**
