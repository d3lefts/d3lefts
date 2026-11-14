# Hereditary influence and adaptive observability under bounded dependence

**NIGHTFALL research note | 13 November 2026 | Directed by Devin J. Wright; AI-assisted analytical development**

**Status:** An author-side proof *composing* the historically pinned Lean-checked heterogeneous finite-product influence theorem with a classical bounded change-of-measure comparison; exact finite rational adversarial tests. **Not** a newly Lean-compiled correlated-law theorem, externally reviewed theorem, historically novel discovery, or polynomial-time algorithm. A separate correlation/no-go theorem and a stationary multiclass completion theorem are recorded in companion notes.

## A. Objective, sources, and originality threshold

The aim is **to strengthen the scope** of the already formally checked NIGHTFALL finite-product extension of Aaronson–Ambainis, not to reprove or rebrand Turturean's uniform-cube theorem. The strict kernel receipt for the finite scalar input is [PR #317, Lean 4.33.0](../formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md) with the finite heterogeneous-alphabet/ANOVA supplement in PR #325. Its certified coefficient is

\[
c_*=\frac{\sqrt{3/12500}}{\pi^6}\simeq1.6114112254\cdot10^{-5}.
\]

The source theorem, rescaled to |f|<=B, says that on **independent finite heterogeneous product coordinates** with Hoeffding interaction degree <=d,

\[
\max_i I_i^\mu(f)\ge c_*\operatorname{Var}_\mu(f)^{5/2}/(B^3d^6).
\tag{S}
\]

**Imported mechanisms:** Turturean's finite Boolean-cube result and the NIGHTFALL finite transfer; classical Hoeffding–Efron–Stein identities; variational comparisons between probability measures, analogous in spirit to bounded perturbation results in functional inequalities. **New in this research record:** compose the exact finite influence statement with (i) controlled correlation, (ii) *hereditary* conditional ratio preservation, (iii) a correlation-independent *exact* influence-potential drift identity, and (iv) a dimension-free adaptive prediction guarantee. This combination has not undergone an exhaustive historical subsumption check. A PR passing exact test scripts proves no historical originality.

## B. Definitions and finite scope

Let \(\Omega=\prod_{i=1}^n\Omega_i\) be a finite heterogeneous Cartesian space with normalized product reference law \(\mu=\bigotimes_i\mu_i\). Remove \(\mu\)-null atoms from the effective support. Let \(\nu\) be a possibly dependent law with density \(r=d\nu/d\mu\) satisfying

\[
0<\alpha\le r(x)\le\beta<\infty,\qquad R=\beta/\alpha\ge1.
\tag{1}
\]

Let \(d\ge1\), \(B>0\), \(|f(x)|\le B\), and assume f has **Hoeffding degree <=d with respect to the reference product measure \(\mu\)**. There is no assumption that the correlated measure has a standard product ANOVA decomposition. The correct dependent-coordinate heat-bath influence is

\[
I_i^\nu(f)=\mathbb E_\nu\operatorname{Var}_\nu(f\mid X_{-i})
=\inf_{g=g(X_{-i})}\mathbb E_\nu(f-g)^2.
\tag{2}
\]

Revealing coordinate i as a state observation is different from resampling Xi using its independent marginal.

## C. Lemma: variational comparison of risks and heat-bath influences

For any two finite laws with \(a\mu\le\nu\le b\mu\) pointwise (a,b>0),

\[
a\,\operatorname{Var}_\mu(f)\le\operatorname{Var}_\nu(f)
\le b\,\operatorname{Var}_\mu(f),
\tag{3}
\]
\[
a\,I_i^\mu(f)\le I_i^\nu(f)\le b\,I_i^\mu(f)
\qquad\forall i.
\tag{4}
\]

*Proof.* For each constant c, \(\mathbb E_\nu(f-c)^2\ge a\mathbb E_\mu(f-c)^2\). Take infima in c; the upper inequality follows by testing the \(\mu\)-optimal c. Repeat with functions \(g(X_{-i})\) in place of c to obtain (4). No conditional-density squaring or independence for \(\nu\) is needed. QED.

## D. Theorem 1: hereditary correlation-robust influence

Under (1), (S) yields

\[
\boxed{\max_i I_i^\nu(f)
\ge c_*\frac{\alpha}{\beta^{5/2}}
     \frac{\operatorname{Var}_\nu(f)^{5/2}}{B^3d^6}
\ge \frac{c_*}{R^{5/2}}
     \frac{\operatorname{Var}_\nu(f)^{5/2}}{B^3d^6}.}
\tag{5}
\]

Moreover, for *every* set S of observed coordinates and every assignment \(x_S\) having positive \(\nu\)-probability, the same bound with factor \(R^{-5/2}\) holds on the conditional law of the unrevealed coordinates, for the corresponding source section of f.

*Proof.* Equation (4) gives \(\max_iI_i^\nu\ge\alpha\max_iI_i^\mu\), while (3) gives \(V_\mu\ge V_\nu/\beta\). Substitute in (S). Since \(\alpha\le1\) for probability measures, \(\alpha/\beta^{5/2}=\alpha^{-3/2}R^{-5/2}\ge R^{-5/2}\).

For a section \(x_S\), the conditional law \(\nu(\cdot\mid X_S=x_S)\) is absolutely continuous with respect to the *remaining reference product* \(\mu_{-S}\), with density \(r(x_S,\cdot)/Z_S\) and \(Z_S=\mathbb E_{\mu_{-S}}r(x_S,\cdot)\in[\alpha,\beta]\). Its max/min ratio is at most R. The section \(f(x_S,\cdot)\) still has reference-product degree <=d and bound B: freezing input coordinates cannot create higher interaction order. Apply the preceding argument. QED.

**Caution:** the density bound must be justified for the actual input law. A constant R is a strong requirement in high-dimensional interacting models and must not be assumed from small pairwise correlations.

## E. Lemma: exact total-influence drift without independence

For *any* joint law on finite coordinates and any integrable f, let \(T_\nu(f)=\sum_{j=1}^nI_j^\nu(f)\). If coordinate i is revealed, then

\[
\boxed{\mathbb E_{\nu_i}\big[T_{\nu(\cdot\mid X_i)}(f)\big]
=T_\nu(f)-I_i^\nu(f).}
\tag{6}
\]

*Proof.* For each j ≠ i, conditioning on all variables except j *already conditions on Xi*. By disintegration/tower property,
\(\mathbb E_{X_i}I_j^{\nu(\cdot\mid X_i)}(f)=I_j^\nu(f)\).
After revealing i, coordinate i is not counted among the remaining coordinates. Summing proves (6). This does not require coordinate independence or reversibility of a resampling chain. QED.

## F. Correlated total-influence comparison

On a reference degree-d function,

\[
T_\nu(f)\le\beta T_\mu(f)
\le\beta d\operatorname{Var}_\mu(f)
\le Rd\operatorname{Var}_\nu(f).
\tag{7}
\]

Here \(T_\mu\le dV_\mu\) is the classical product ANOVA identity. Each conditioned section has ratio at most R, so \(T_{\nu(\cdot\mid X_S)}\le Rd\,V_{\nu(\cdot\mid X_S)}\) uniformly in every reachable state.

## G. Theorem 2: dimension-independent adaptive observation under controlled correlation

Let \(0<\eta\le B^2\). Suppose the full joint law \(\nu\), source function f, and conditional influence computations are available as ideal information-theoretic primitives. There is a deterministic adaptive policy that reveals at most

\[
\boxed{N\le\min\left\{n,\
\left\lceil \frac{4R^{7/2}d^7 B^3}{c_*\eta^{3/2}}\right\rceil\right\}}
\tag{8}
\]

whole original-state coordinates and produces \(\widehat f=\mathbb E_\nu[f\mid \text{revealed coordinates}]\), with

\[
\boxed{\mathbb E_\nu(f-\widehat f)^2\le\eta.}
\tag{9}
\]

**Proof.** At each transcript H choose an unread coordinate maximizing its current conditional heat-bath influence; break ties by index. Let \(v_t=\mathbb E \operatorname{Var}_\nu(f\mid H_t)\) and \(p_t=\mathbb E T_{\nu(\cdot\mid H_t)}(f)\), with \(L=Rd\) and \(a=c_*R^{-5/2}/(B^3d^6)\). Theorem 1 and Jensen give

\[
p_t-p_{t+1}
=\mathbb E\max_i I_i^{\nu_{H_t}}(f)
\ge a\,\mathbb E\big[\operatorname{Var}_{\nu_{H_t}}(f)^{5/2}\big]
\ge a v_t^{5/2}.
\tag{10}
\]

Also \(p_t\le L v_t\) by (7), and \(v_t\) is nonincreasing by conditional variance. Partition the times for which \(v_t>\eta\) into dyadic levels \(2^j\eta<v_t\le2^{j+1}\eta\). On each nonempty level, the potential at entry is at most \(2^{j+1}L\eta\), whereas each query decreases it by at least \(a(2^j\eta)^{5/2}\). Thus the number of queries spent at that level is no more than \(2L/(a(2^j\eta)^{3/2})\). Sum over j>=0:

\[
\#\{t:v_t>\eta\}\le
\frac{2}{1-2^{-3/2}}\frac{L}{a\eta^{3/2}}
<\frac{4R^{7/2}d^7B^3}{c_*\eta^{3/2}}.
\]

If all n coordinates are already revealed the risk is zero. Otherwise at the printed hard cap the remaining conditional-variance risk is <=η. QED.

**Explicit limitations:** This is a *state-coordinate query* bound; finding the maximizing heat-bath influence, evaluating the conditional mean, authenticating ν, and executing a physical observation channel are not given algorithmic/bit complexity bounds. It is a finite-product theorem, not a new proof of infinite-product measurable selection.

## H. A faster **conditional** quadratic consequence, not an unconditional formal theorem

The newer [source-level Q2 analytic argument](../2026-11-quadratic-law-free-audit/README.md) claims, but has not compiled end-to-end in Lean nor survived external review,

\[
\max_iI_i^\mu(f)\ge\frac{\operatorname{Var}_\mu(f)^2}{C_2 B^2},
\quad C_2=(10+2\sqrt2)^2(1+\sqrt3)^2\simeq1228.3563
\]

for reference-product degree <=2. **If** that premise holds, (3)-(4) give

\[
\max_iI_i^\nu(f)\ge\frac{\operatorname{Var}_\nu(f)^2}{C_2B^2R^2}.
\]

The same argument with \(L=2R\), \(a=1/(C_2B^2R^2)\), and dyadic exponent two gives a geometric coefficient \(2/(1-2^{-1})=4\). The resulting *conditional* dimension-free budget is

\[
\boxed{N_{\mathrm{Q2}}\le \min\{n,\lceil 8 C_2R^3B^2/\eta\rceil\}.}
\tag{11}
\]

This correction is retained explicitly to prevent accidental promotion of an unsupported constant. Equation (11) is dependent on the separate uncompiled Q2 theorem.

## I. Exact falsification and sharp limitations

Replay [check_correlated_transfer.py](check_correlated_transfer.py): all exact-fraction comparisons passed for 82 finite reference perturbations, 1,798 posterior sections, 2,594 full correlation-aware drift identities, 82 TV cases, and a perfectly correlated failure witness. These tests stress the proof hypotheses, not its general validity.

The companion [parity camouflage theorem](PARITY_CAMOUFLAGE_20261113.md) proves that (n-1)-wise independence and perfect low-degree covariance agreement do **not** suffice for a distribution-free bound. In fact, all coordinate heat-bath influences may vanish when the joint law has a parity constraint.

## J. Prior-art boundaries and decisive next step

- **Turturean (2026), A proof of the Aaronson–Ambainis conjecture**, arXiv:2611.09773; the finite influence theorem imports his Boolean cube machinery.
- **Huffstutler–Miloschewsky–Podder (2026), A short proof of the Aaronson–Ambainis Conjecture via the completion framework**, arXiv:2611.12795; its result in terms of classical adversary/completion measures is the more general comparison motivating the new completion work.
- **Blanc–Docter–Strassle–Tan (2026), Proof of the Aaronson–Ambainis Conjecture: An Exposition**, arXiv:2611.11626.
- **Holley–Stroock perturbation principle**, standard comparison machinery for functional inequalities. Thus a bounded change-of-measure transfer alone cannot be advertised as a breakthrough in historical priority.
- **OSSS decision-tree influence** and classical product Efron–Stein calculus; distinct from the correlated conditional variance drift.

The **new research direction** is to replace the potentially exponentially large global ratio R with a **verified conditional channel/Dirichlet comparison** whose cost depends on local geometry, while retaining the hereditary source-degree structure and avoiding the parity obstruction. A claim with controlled local correlation but no global density bound must first survive the parity and tensorized rare-event counterexamples.

**Certification label:** Author-analytic theorem with imported kernel-checked finite source + exact finite falsification. Not end-to-end Lean, not external referee approved, not worldwide novel.