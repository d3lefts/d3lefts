# Quadratic influence — end-to-end Lean certificate gate (11 November 2026)

**Target (NOT yet kernel-certified):** For a finite product of independent arbitrary finite categorical laws (zero masses permitted), every bounded scalar real Hoeffding-degree-2 function satisfies

\[
\operatorname{Var}(f)\le 15(1+\sqrt 3)\|f\|_\infty
\sqrt{\sup_i\mathsf{Inf}_i(f)}.
\]

The arbitrary measurable/infinite product extension and Hilbert rank/adaptive prediction conclusions require separate proofs. No globally original priority or non-author referee claim.

## Genuine new kernel certificate, independent of any assumed fourth-moment bound

**Declaration:** `Nightfall.Observability.QuadraticHilbertMany.arbitrary_law_many_hilbert_fourth` in `HilbertManyIncrementMoment.lean`.

With any finite common input alphabet `α`, coordinate-specific nonnegative normalized real masses `p n a`, actual centered vector-valued increments `Y n a : K → ℝ` with finite arbitrary output dimension `K`, and `\sum_k(Y n a k)^2≤c^2`, the theorem constructs the n-fold product sample space, its product mass, its increment sum and moments and proves for **every n**:

\[
\mathbb{E}\|\sum_{j<n}Y_j\|^4
\le c^2\sum_{j<n}\mathbb{E}\|Y_j\|^2
  +3\big(\sum_{j<n}\mathbb{E}\|Y_j\|^2\big)^2 .
\]

The proof derives product-mass normalization, centering, the exact second-moment identity and the two-factor Hilbert estimate by induction from the actual tables. It neither assumes the conclusion nor a fourth-moment certificate. Unequal finite input alphabets can be embedded into a common tagged finite alphabet with zero-mass symbols; that embedding is not formalized **in this module**.

**CI receipt:** [GitHub Actions #43062171542](https://github.com/d3lefts/d3lefts/actions/runs/43062171542), PASS for source head `1952573960a4784f1bda87dcf049c5d07354cff6`, pinned Lean 4.35.0 / Mathlib v4.35.0, strict named theorem/axiom checker including the final theorem, standard axioms allowed only `propext`, `Classical.choice`, `Quot.sound`. This certifies the precisely stated finite product many-increment lemma, **not** the arbitrary-law quadratic influence theorem.

**Earlier kernels:** PR #359 supplies the two-increment estimate, scalar coefficient composition under explicitly assumed matching/section/moment certificates, finite quadratic projection. PR #325 supplies an actual finite-product Efron–Stein decomposition/degree bridge; source in the program has a separate pinned CI. Those premises do not magically compose into the full theorem without additional proofs.

## Missing genuine end-to-end proof edges (not assumed away)

1. **Actual matching-to-coupling construction:** from arbitrary bounded degree-two product function build global even/odd parity couplings for every disjoint weighted matching and prove all nonmatched terms cancel, yielding `∑ matched ||h_ij||∞ ≤4B`.
2. **Weighted greedy endpoint assignment:** construct the finite matching and costs `c_i` with `∑c_i≤8B` and assign every nonzero interaction to one endpoint where `||h_ij||∞≤c_i`.
3. **Actual product switching/oscillation:** connect the degree-two `|q'(0)|≤8B` kernel lemma to pointwise coordinate section maxima/minima and then `∑_i E||U_i||≤8B`, including the `7B` additive projection energy budget.
4. **Actual ANOVA/resampling energies:** specialize all component orthogonality and marginal resampling influence identities, and prove that the endpoint-assigned `h_ij(·,X_j)` satisfy the new many-increment theorem's centering/bounds.
5. **Kernel-complete final theorem:** compose 1–4, interpolation and the already compiled coefficient algebra, stating the conclusion directly for arbitrary normalized input laws and `f` with explicit boundedness/degree hypotheses. Audit its printed axioms with the same fail-closed workflow.
6. **Measurable products and adaptive corollaries:** distinct end-to-end Lean development after the finite theorem.

These are separate formal proof obligations, not implicit imports. Green CI for step 0 does not promote step 5.

## Sources

- Analytic reconstruction and independent exact arithmetic: [PR #362](https://github.com/d3lefts/d3lefts/pull/362).
- Existing conditional Lean lemmas and true two-increment arithmetic: [PR #359](https://github.com/d3lefts/d3lefts/pull/359).
- This proof development: [PR #364](https://github.com/d3lefts/d3lefts/pull/364).

**Status:** finite all-n Hilbert fourth-moment subtheorem: kernel-checked. Full arbitrary-law quadratic exponent-two influence theorem: **NOT end-to-end kernel-checked**.
