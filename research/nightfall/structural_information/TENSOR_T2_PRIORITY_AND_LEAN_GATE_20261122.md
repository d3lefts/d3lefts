# NIGHTFALL tensor T2 — global-priority search and Lean certification ledger v2 (2026-11-22)

**Source under audit:** [PR #1016](https://github.com/d3lefts/d3lefts/pull/1016), initial reviewed head `537411f2b1bab7e073f430f06d475325576dd99c`. Its parent [PR #1002](https://github.com/d3lefts/d3lefts/pull/1002) is merged, but its analytic full-circuit claims are not Lean theorem statements. **No new publication, external review, or global-priority claim is authorized by this ledger.**

## Objective, exact scope, and stop criterion

Test whether **every two-query** finite-dimensional quantum algorithm for the correlated oracle with row set `R_L = {tensor_i u_i : u_i in F_2^2 \ {0}}` (`|R_L| = 3^L`) can be approximated on at least `1-delta` of **uniform hidden secrets** by a deterministic **nonadaptive** classical original-row query algorithm using `poly(L, 1/epsilon, 1/delta)` rows. The target is an **acceptance-probability** approximation (not output-state sampling), allows exponential offline computation and nonuniform choice of rows, and is not a polynomial-time classical simulator.

The paper manuscript in #1016 claims the explicit upper
`min(3^L, ceil(2 (2 sqrt(K_L) + 145 sqrt(M))^2 / (epsilon^2 delta)))`
with `M` the maximal nonzero ordered 2-XOR fiber size and
`K_L = 5^4 (1+4*3^6)^4 sum_{j=0}^{min(3,L)} choose(L,j)`.
In particular `O(L^3/(epsilon^2 delta))`. The key remaining gates are source-equivalent all-L primitive-lift counting, the *complete* high-rank operator-energy analysis, independent adversarial review, and a kernel-checked full theorem.

**Stop/demotion rule:** If an operator-energy identity, circuit count or oracle-model equivalence fails, preserve its counterexample and demote the full theorem. Never replace a missing all-L proof with finite enumeration. Do not call a fragment a certified end-to-end simulator.

## Global prior-art search (conducted 2026-11-22)

Scope: public indexed scholarly results on tensor/Segre row families, product-tensor circuits, Fourier influences, quantum-query acceptance approximation, correlated linear-code oracles, uniform-distribution and nonadaptive simulation; targeted October–November 2026 searches included.

| Public dated reference | Actual result / model | Relation to NIGHTFALL |
| --- | --- | --- |
| **Lovitz–Petrov**, *A generalization of Kruskal's theorem on tensor decomposition*, Forum Math. Sigma **11** (2023) e27, Theorem 4 / Corollary 10, [DOI](https://doi.org/10.1017/fms.2023.20), [arXiv](https://arxiv.org/abs/2103.15633) | Splitting theorem for product tensor families over any field; implies at most `|C|-2` varying factors for a minimally dependent product-tensor circuit. | **Direct inherited dependency** for #1016's primitive circuit method. Do NOT claim this theorem or its circuit bound as original. |
| **Bansal–Sinha–de Wolf**, *Influence in Completely Bounded Block-Multilinear Forms and Classical Simulation of Quantum Algorithms*, CCC **2022**, [DOI](https://doi.org/10.4230/LIPIcs.CCC.2022.28) | Almost-everywhere classical simulation for restricted bounded block-multilinear quantum-query representations. | Strong prior art; no exact original-row correlated `R_L` quantitative theorem located in the inspected abstract/model. |
| **Escudero Gutiérrez–Saucedo–Palazuelos**, *Optimal inequalities for completely bounded polynomials and the limitations of quantum query algorithms*, [arXiv:2609.05201](https://arxiv.org/abs/2609.05201) (Sep 2026) | Optimal root-influence inequality and nonadaptive classical approximation for the **disjoint input-block** quantum amplitude model, plus general Fourier growth. | Most important contemporary comparison. Do not transfer its independent-block simulation conclusion to the correlated original-row oracle without a separate reduction. |
| **Girish–Mittal–Nehoran–Raz**, *Distributional Variants of the Aaronson–Ambainis Conjecture*, [arXiv:2609.35327](https://arxiv.org/abs/2609.35327) (Sep 28, 2026) | Establishes equivalences between uniform-, biased-product-, and slice-distribution conjectures. | Clarifies that general polynomial-overhead uniform-input quantum simulation remains conjectural; it does not give the specific tensor-row theorem. |
| **Yaqiao Li et al.**, *Two exact quantum queries use at most six variables*, [arXiv:2610.34079](https://arxiv.org/abs/2610.34079) (Oct/Nov 2026) | Exact computation of **total Boolean functions** with two queries. | Different correctness objective: our claim approximates arbitrary acceptance probability on most secrets of a correlated oracle. |
| **NIGHTFALL merged #977/#978**, Nov 20 2026 | Lean-certified `|R_L cap W| <= (dim W)^log_2 3` and sharp full-space family. | Proven reusable own structural source; source-date and external novelty evaluation remain distinct. |
| **NIGHTFALL merged #980**, Nov 22 2026 | Paper-level polynomial secant quotient-fiber candidate, finite structural checker and Lean six-family *cover*. | Does not independently prove the rank-free quantum theorem. |

**Priority verdict:** This targeted cross-literature search found *no verified public theorem with the same oracle, two-query, rank-free and original-row distributional guarantee*. **Not an exhaustive global proof of originality:** non-indexed preprints, conference proceedings, private manuscripts and human specialist knowledge remain outside the completed search; absence of a match is not a priority certificate. The splitting theorem and general nonadaptive simulation framework must be credited as prior art.

## Independent mathematical and finite checks

**Original checker, independent generator:** `research/nightfall/structural_information/check_tensor_t2_primitive_independent.py`. Enumerates every set of 1–4 distinct tensor rows for all `L<=4`, classifies XOR-nonzero primitive sets using independent binary-mask expansion, and verifies the explicit three-site four-row construction. Exact integer, no floating-point tolerance, no imports from the manuscript's checker.

| L | Number of rows | Max unordered primitive <=4 sets per nonzero frequency | Max unordered four-row primitive sets |
| --- | ---: | ---: | ---: |
| 1 | 3 | 2 | 0 |
| 2 | 9 | 16 | 6 |
| 3 | 27 | 84 | 72 |
| 4 | 81 | 179 | 150 |

**Scope:** The finite tests support the primitive collision classification through `L=4`. They do not prove `K_L=O(L^3)`, check arbitrary quantum circuits, certify the constant 145 or exclude an all-L counterexample. The author manuscript uses Lovitz–Petrov Theorem 4 and a further minimum-cardinality 4-set argument; independently reproduce the latter, especially its `r=4` two-variable rank reduction.

**Scoped Lean file:** `research/nightfall/formalization/structural_information/TensorT2Cancellation.lean`, with a pinned CI workflow. Proves, with explicit exponent-two hypothesis, all six four-path repeated-label XOR cancellations, zero-pair equivalence and overlapping-zero-triple uniqueness. These are actual mathematical subclaims needed for Section 3/4 of the proposed theorem, but **NOT the coefficient bounds**, **NOT the product tensor circuit splitting theorem**, and **NOT a two-query classical simulator**. **Verified:** scoped exact-head Lean compile, `leanchecker` and standard-axiom audit **PASS** in [run #45052357652](https://github.com/d3lefts/d3lefts/actions/runs/45052357652), commit `ed78403581bc311e0c3bfc8abf810eab04d2b546`, source Git blob `ccdf378c38a06f51c7158f4138370dbc55fce778`. All three named terminal axioms are exactly `[propext]`. Exact finite L<=4 checker passed in the same run. Receipt artifact: [14765833389](https://github.com/d3lefts/d3lefts/actions/runs/45052357652/artifacts/14765833389).

## Independent adversarial audit route (predeclared)

1. Reconstruct #1016's all-L product-tensor circuit counting *without* copying its proof. Verify the `r=4` minimal-rank branch and count all assignments, shared rows and edge cases `L=1`, zero labels and zero Fourier fibers. Seek small exact counterexamples first.
2. Independently rederive the Hilbert-space path-frame inequality `Tr(G_light P G P) <= eta`, including all six repeated-label events and the four zero-triple correction groups, with arbitrary high-rank noncommuting effects. Check conjugation and all factors of two.
3. Verify both quantum binary-response/phase oracle representations, including `label=0` sectors, and the claim that conditional Walsh expectation is evaluable from the selected **original** rows.
4. Formalize genuinely representation-faithful terminal statements in Lean, with source SHA, `leanchecker`, no `sorry/admit/axiom`, standard-axiom printout and a final definition-identification review. A Lean theorem with a hard hypothesis does not certify that hypothesis.
5. Obtain a mathematical reviewer independent of authors and a dated model-exact priority review before claiming a novel contribution.

**Cheapest decisive next experiment:** independently audit the `r=4` Lovitz–Petrov-to-free-site inference and full mixed high-rank energy estimate. Expected outcomes: independently derived full proof, a counterexample, or a remaining named lemma. Preserve whichever occurs; do not promote automatically.

**Status as of this ledger:** manuscript candidate; finite enumerations exact through L=4; inherited sharp row theorem Lean certified; new cancellation lemmas **Lean kernel-certified at the exact source**; **complete T=2 theorem not Lean-certified**, human-referee and worldwide-priority gates open.

## Repository state reconciliation — parallel PR hygiene (2026-11-22)

Parallel research administration **closed unmerged** the original [#1016](https://github.com/d3lefts/d3lefts/pull/1016) paper-candidate PR for hygiene, explicitly **without claiming its disproof**. Its source remains preserved on branch `research/tensor-t2-rank-free-primitive-20261122` at head `537411f2b1bab7e073f430f06d475325576dd99c`. The main open audit gate is [issue #1021](https://github.com/d3lefts/d3lefts/issues/1021). This [draft audit PR #1029](https://github.com/d3lefts/d3lefts/pull/1029) remains open and adds **independently source-pinned scoped** Lean/finite certificates, but does not supersede the full paper proof. Do not silently promote either to an unconditional theorem or close #1021 based solely on these scoped successes.
