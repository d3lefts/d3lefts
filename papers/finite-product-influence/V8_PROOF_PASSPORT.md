# NIGHTFALL v8 — Mathematical proof passport

**Manuscript:** *Bias-Free Aaronson--Ambainis on All Product Spaces: Quadratic Influence and Rank-Optimal Observation*, v8, November 11, 2026.
**Author:** Devin J. Wright / NIGHTFALL.
**Status:** Specialist-review analytic manuscript; no external non-author specialist referee, global-priority certificate or full-chain Lean verification. This is not an arXiv publication.

## Contributions and exact proof dependencies

1. **General product-law influence (unchanged from v7):** max resampling influence >= c_prod V^(5/2)/d^6, with the explicit c_prod in the manuscript. Uses David Turturean's Boolean antipodal and weighted certificate architecture, two-sample orientation over arbitrary products, localized weight removal and an analytic finite-to-measurable transfer. This coefficient is analytic, not the coefficient of the weaker pinned finite Lean theorem.
2. **Improved quadratic all-alphabet scalar inequality:** V² <= K B² M, K=(10+2√2)²(1+√3)²=432+160√2+216√3+80√6=1228.356323837... . V7 had K0=225(1+√3)²=1679.4228... . Mechanism: at s=√2−1, for two noise evaluations r(0)=0 and |r(t)|<=2B, r'(0)=(r(s)−s²r(1))/(s(1−s)), so osc(P_<=1 f)<=4(1+√2)B and sum_i ||h_i||_2<=2(1+√2)B. Replace only v7's 7B first-order budget; matching mass 4B, pointwise section budget 8B, greedy endpoint cover 8B and independent Hilbert fourth moment are unchanged. No assertion of an optimal numerical constant.
3. **Rank-r Hilbert and adaptive observation:** V(F)² <=3K r B² M(F). Conditional after each transcript, unobserved inputs remain independent. The exact order-weighted posterior energy decrement is I_i; using p<=2v and reciprocal telescoping gives <=ceil(12K r B²/eta) whole-symbol adaptive observations for risk tau_r+eta (finite product, known law). Matching-order rank dependence is inherited from v7's elementary degree-one witness. Runtime and tree representation size not bounded.
4. **Binary-only Grothendieck comparator:** for *globally* bounded quadratic f on the full Boolean cube and any joint law, sum sqrt(I_i) <=4K_G^R B. Product law adds Efron--Stein, giving V²<=16(K_G^R)² B² M; a nonproduct law needs a heat-bath Poincare gap. Signed Hilbert compression gives V(F)²<=48(K_G^R)²rB²M and adaptive product-law depth <=ceil(192(K_G^R)²rB²/eta). Using classical Krivine KG upper bound gives scalar coefficient <51 and rank-adaptive <610. This mechanism uses classical Grothendieck (Pisier/Krivine) and quadratic polarization, **not claimed novel**. Full-cube bound is explicitly required under zero-support joint laws.
5. **Fixed-set quadratic spectral regime:** if delta2 is the sum of squared degree-two Hoeffding components and eta>delta2, choose the q largest singleton energies with q<=ceil((3+2√2)B²/(eta−delta2)). This gives risk <=eta. It does *not* imply any alphabet-uniform nonadaptive guarantee below the quadratic energy floor.
6. **Unrestricted cubic influence exponent two:** still OPEN. Earlier top-cubic-cover results from PR #335 use a different conditional scope; no fresh novelty claim. PR #380 refutes naive independent fourth-moment transplantation, not the cubic conjecture. PR #381's sharp projection norm is a separate unrefereed candidate, not imported as a v8 theorem.

## Independent exact checks (not proof of universal claims)

- Replayed the original v7 checker: 1,638 heterogeneous posterior reveals and 384 rank lower-bound cases, digest 5fc2d5221f4a27ad606beb948c27f278b4645761ac6b3bbeac4df0850703454b.
- Replayed the v8 readiness checker: 225 direct additive projection models, digest ff4a16cab0ccfa8f82ebf1eb0a40d5a38bfc2e6d5cca8259ce1e8257317a4e56. Its original 10B check is weaker than the v8 analytic inequality.
- New independent `check_v8_exact.py`: 225 heterogeneous exact rational models evaluating the product noise kernel at sqrt(2)−1 in Q(sqrt2), 225 fixed-budget examples, 1,620 direct exact polynomial-polarization checks, and exact radical interval arithmetic for all v8 coefficients. Audit digest a3f067713ce7f87beb67accd506bbf610adeca2db1a84645f4a8806c4473cd5e.
- LaTeX twice under pdfTeX: 32 pages, no unresolved references or overfull lines. Source hash manifest in `SOURCE_SHA256SUMS_v8`.

## Prior art and originality controls

Original Boolean all-degree result and underpinning weighted proof: David Turturean, arXiv:2611.09773 (Nov 2026). Prior completely bounded and quadratic Grothendieck literature: Aaronson–Ambainis–Iraids–Kokainis–Smotrovs (CCC 2016), Briët–Escudero Gutiérrez–Gribling (Quantum 2024), Escudero Gutiérrez and coauthors; classical real Grothendieck bound from Krivine/Pisier. Girish–Mittal–Nehoran–Raz treats fixed Bernoulli biases via existing equivalence. The exact categorical bilinear prior-art subsumption question remains open; no worldwide priority is certified.

## Independent adversarial audit required

1. Reproduce all-degree two-draw/Fubini/projection argument with its precise product sigma-algebra and arbitrary index-set assumptions.
2. Independently verify matching parity cancellation against *all* off-matching edges, bounded scalar and Hilbert oscillation steps, and actual independent section fourth moments.
3. Derive the v8 additive range inequality without importing the transcript; try small arbitrary-alphabet counterexamples and degenerate marginal cases.
4. Recheck binary Grothendieck dualization, global support condition, rank sign compression, correlated Poincare normalization, and posterior stability.
5. Check adaptive potential recurrence and fixed-rank projection in arbitrary finite laws, including hard stopping and output norm.
6. Complete dated categorical Grothendieck comparison and obtain a non-author proof review.

**Stop rule:** compilation, exact finite checks and Lean sublemmas never promote the analytic manuscript to end-to-end certified theorem, externally validated novelty or publication eligibility without an independent referee and owner authorization.

## Dated supplement — v9.2 custody and 12 November theorem boundaries

This original v8 passport and its source hashes remain intact. The later [v9.2 PDF](NIGHTFALL_Beyond_Boolean_Cube_v9_2.pdf) proposes the same scalar constant C₂=(10+2√2)²(1+√3)²≈1228.356, analytic rank bound 3C₂rB² and hard adaptive budget ⌈12C₂rB²/η⌉. These are not new end-to-end Lean-certified claims. A 12 November [AI-assisted internal audit](V9_2_INTERNAL_REVIEW_20261112.md) found no error in selected main arguments but flagged a Corollary 6.2 scalar-specialization reference/constant mismatch and the lack of original v9.2 LaTeX source. External non-author review remains absent.

PR [#407](https://github.com/d3lefts/d3lefts/pull/407) and [#408](https://github.com/d3lefts/d3lefts/pull/408) add finite source-level Lean bridges for actual quadratic row / Efron–Stein pair/rectangle steps. [#408's eight named strict receipts](../../research/nightfall/formalization/product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md) explicitly do not compile terminal global parity from the same bounded function. The source registry currently has 67 scoped modules, not a 67-theorem end-to-end proof.

Turturean's uniform-cube result covers every degree with exponent 5/2; the v9.2 exponent 2 is quantitatively stronger at degree two, but binary quadratic exponent-two already follows via classical Grothendieck. The [dated comparison](../../research/nightfall/2026-11-information-cost-dissertation/CHAPTER2_TURTUREAN_SCOPE_AUDIT_20261112.md) reviews the fixed-common-bias equivalence and naive-reduction obstacles; full categorical/one-hot bilinear priority remains open. The [new four-cost passport](../../research/nightfall/2026-11-active-passports/information-costs-identification.md) documents a different oracle-model analysis, not a v8 corollary.
