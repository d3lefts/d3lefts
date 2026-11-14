# NIGHTFALL — unrestricted infinite-product Efron–Stein: terminal proof and certification ledger

**Research note, 2026-11-14.** Status: **author-analytic derivation, NOT an end-to-end Lean certificate.** A separate actual-source finite-cylinder lemma is staged in Lean in this branch; a current-head compiler/axiom receipt is required. Independent human review and originality have not been established.

## Exact target

Let \(I\) be any index set, possibly uncountable, and \((X_i,\Sigma_i,\mu_i)\) arbitrary probability spaces with product law \(\mu=\operatorname{Measure.infinitePi}(\mu_i)\). Work with a real observable \(f\in L^2(\mu)\) and no interaction-degree restriction.

For finite \(F\subseteq I\), define \(\mathcal G_F=\sigma(X_i:i\in F)\) and \(P_F f=\mathbb E_\mu[f\mid\mathcal G_F]\). Let \(Q_i f=\mathbb E_\mu[f\mid\sigma(X_j:j\ne i)]\), \(I_i(f)=\|f-Q_i f\|_2^2\), and \(V(f)=\|f-\mathbb E_\mu f\|_2^2\). Define the sum over an arbitrary index set to be the extended-real supremum of finite partial sums.

**Unrestricted analytic theorem:**

\[
V(f)\leq\sup_{F\subseteq I,\ F\text{ finite}}\ \sum_{i\in F} I_i(f).
\]

No countability, positive atom floor, finite alphabet, common alphabet, bounded degree, or finite RHS is assumed. This is classical Efron–Stein mathematics, not a proposed new theorem.

## Author-analytic proof

**1. Density of cylinders.** Finite-coordinate measurable rectangles form an algebra generating the product sigma algebra. The functional monotone-class argument in the finite measure space \((\Omega,\mu)\) makes the span of their indicators dense in \(L^2(\mu)\). For each \(\varepsilon>0\), select an \(L^2\) finite cylinder \(g\) on some \(F_0\) such that \(\|f-g\|_2<\varepsilon\). Since \(P_F\) is the orthogonal projection onto the \(\mathcal G_F\)-measurable subspace, for every finite \(F\supseteq F_0\),

\[
\|f-P_Ff\|_2\leq\|f-g\|_2<\varepsilon.
\]

Thus the net \(P_F f\) converges in \(L^2\) to \(f\). This does not require choosing a countable exhaustion of \(I\). Also \(V(P_Ff)\to V(f)\).

**2. Actual-source conditional-expectation commutation.** Independence of product coordinates gives, for each \(i\in F\),

\[
P_F Q_i=P_{F\setminus\{i\}},
\qquad P_{F\setminus\{i\}}P_F=P_{F\setminus\{i\}}.
\]

Consequently,

\[
P_Ff-P_{F\setminus\{i\}}f
  =P_F(f-Q_if)
\]

and contraction of the orthogonal projection implies

\[
\|P_F f-P_{F\setminus\{i\}}f\|_2^2
 \leq \|f-Q_i f\|_2^2=I_i(f).
\]

These commutation equalities are missing genuine-source Lean obligations, not permissibly supplied hypotheses for a completed certificate.

**3. Finite general-alphabet Efron–Stein.** Order \(F\) arbitrarily. The conditional-expectation martingale differences are mutually orthogonal. Each difference is a projection of the corresponding coordinate residual, so Pythagoras and \(L^2\) contraction yield

\[
V(P_F f)
 \leq\sum_{i\in F}\|P_Ff-P_{F\setminus\{i\}}f\|_2^2
 \leq\sum_{i\in F}I_i(f).
\]

This holds for arbitrary measurable coordinate spaces. The existing finite Lean #506 theorem proves an important **finite common alphabet** specialization, not this general-alphabet step.

**4. Directed limit.** Taking the net limit from step 1 and then the supremum over all finite \(F\) gives the claimed inequality. All summands are nonnegative. The argument is fully dimension-independent and all-degree, but the Lean source chain is not yet closed.

## Fail-closed Lean certificate ledger

| Gate | Existing source | Status |
|---|---|---|
| Finite original-source all-degree inequality, finite common alphabet | #506, ActualSourceEfronStein.lean | Pinned Lean PASS on PR head |
| Actual infinitePi finite marginals and cylinder integrals | #501, InfinitePiSourceBridge.lean | Pinned Lean PASS on PR head |
| Centered-square variance of actual finite cylinders, source mean on both sides | This branch, InfinitePiCylinderVarianceBridge.lean | **Lean CI pending** |
| Finite-cylinder density in arbitrary infinitePi \(L^2\) | No merged declaration | **OPEN** |
| Actual-product projection commutation \(P_F Q_i=P_{F\setminus\{i\}}\) | No merged declaration | **OPEN** |
| Finite Efron–Stein with general measurable heterogeneous coordinate spaces | #506 is strictly narrower | **OPEN** |
| Actual-resampling influence contraction for \(P_Ff\) | No merged declaration | **OPEN** |
| One unconditional terminal Lean theorem without external happrox or hfinite assumptions | #495 contains conditional transfer only | **OPEN** |

**Certification rule:** Neither this argument, a bounded finite checker, nor a cylinder-only Lean receipt may be labeled a full unrestricted kernel certificate. The endpoint must quantify the original \(\mu\), \(f\in L^2(\operatorname{Measure.infinitePi}\mu)\) and its actual conditional-resampling influences, and pass named theorem, exact source hash, Mathlib pin, and axiom checks.

## Independent audit and next decisive steps

The finite falsification oracle should use exact rational weights, enumerate finite-coordinate projections, include zero-probability symbols, compare full-space and projected influence, and test that influences outside the cylinder are zero. Such a checker attacks algebraic errors but does not prove density, conditional-expectation commutation, or uncountable-index claims.

The least redundant formal route is: (1) source-generated cylinder \(L^2\) density; (2) the genuine conditional-expectation commuting square, including arbitrary index sets; (3) finite general-alphabet martingale Efron–Stein; (4) actual-source influence contraction; (5) close the unconditional endpoint through the already certified abstract limit argument. Stop promotion if any theorem remains an assumed hypothesis or CI fails. Prefer the simplest non-atomic heterogeneous two-coordinate counterexample before extensive compilation.

## Mechanism, provenance, limitations

- #500: finite arbitrary-degree source-influence law-change identities.
- #501: Mathlib infinitePi finite-marginal, single-coordinate, and cylinder integration identities.
- #506: finite all-degree original-law Efron–Stein theorem.
- #495: abstract infinite-index transfer **conditional on happrox and hfinite**.
- Mathlib: Probability.ProductMeasure and MeasureTheory.Function.ConditionalExpectation.Basic.
- Classical prior art: Efron–Stein, martingale differences, and Hilbert conditional projections.

This proof covers probability laws only; no runtime agent authority, enforcement, or end-to-end physical safety assertion follows. No human peer review or novelty certification is claimed.
