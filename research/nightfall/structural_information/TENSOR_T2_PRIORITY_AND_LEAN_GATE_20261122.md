# NIGHTFALL tensor T2 — global-priority search and Lean certification ledger v4 (2026-11-22)

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

## Priority search expansion v3: 2026 fixed-round theorem (critical comparator)

A second broader public search found **Guy Blanc, Jordan Docter, Carmen Strassle and Li-Yang Tan**, [*Quantum Speedups Require Structure or Depth*](https://arxiv.org/abs/2608.19158), arXiv posted **2026-08-19**, FOCS 2026. Its Theorem 1 proves that for a **uniform input to the ordinary independent-coordinate oracle** on `N` bits, a `t`-query `d`-round quantum circuit's acceptance probability is approximable on a `1-delta` fraction of inputs using
`2^{O(d^2)} (t log(1/delta)/epsilon)^{O(d)}` classical queries. For `t=d=2` this is already a dimension-free polynomial bound **in its own distributional model**. Their theorem must be cited as foundational and stronger than claiming a novel generic constant-round simulation result.

**Why #1016 is not logically subsumed by their theorem:** in our model the observable oracle response vector is `x_a=(-1)^{a.s}` for `a in R_L`, with `s` uniform on `F_2^{2^L}`. The `3^L` observable bits are **not independent**. Because `R_L` spans `F_2^{2^L}`, the response distribution is uniform on a linear subcode of **exactly `2^{2^L}`** words among `2^{3^L}` unconstrained response words, with density `2^{2^L-3^L}`. Their independent-oracle `1-delta` statement can put *all* its exceptional inputs in this tiny subcode; conditioning naively requires delta to be exponentially small in `3^L-2^L`, which makes its general simulation bound non-polynomial in `L`. Therefore no black-box transfer of their theorem closes our correlated-code problem. Conversely, there may be other techniques or prior results that do; external priority is not cleared.

**Revised significance/novelty language:** Our candidate is an original-row, nonuniform, nonadaptive simulation on a **correlated linear-code promise distribution**, with explicit `O(L^3/(epsilon^2 delta))` row-query bound, should the complete quantum proof pass. Do **not** claim discovery of fixed-two-query simulation without qualifying the distribution: the general independent-bit version already exists, and may have better constants/asymptotics in its own model. The generic source paper is compulsory prior art and not a minor related-work citation.

**Publication gate added:** assign a reviewer specifically to scrutinize this independent-oracle versus codeword-distribution distinction and whether the FOCS argument has a general code-source extension not captured by its stated Theorem 1.


## New construction and counterexample-audit operator — v4 (2026-11-22)

**Pure-frequency all-k polynomial law:** See [TENSOR_PRIMITIVE_PURE_FIBER_POLYNOMIAL_20261122.md](TENSOR_PRIMITIVE_PURE_FIBER_POLYNOMIAL_20261122.md). Combining the *published* Lovitz–Petrov circuit splitting bound with an exact support decomposition gives a paper-level all-L formula for the number of primitive k-row XOR representations of each pure tensor target, polynomial in L of degree at most k−1. Explicit k=1..4 formula is 1+L+9 C(L,2)+30 C(L,3). Independent exact C++ pair convolution at L=1..7 finds 2,12,61,179,396,742,1247 total primitive representations at original-row targets; four-row counts 0,5,45,150,350,675,1155. This is **not** the arbitrary-frequency multiplicity needed to certify the quantum T2 theorem.

**Exact pair spectrum:** See [TENSOR_PAIR_FIBER_CLASSIFICATION_20261122.md](TENSOR_PAIR_FIBER_CLASSIFICATION_20261122.md). Every nonzero original-row pair XOR frequency has unordered multiplicity either L (if itself an original row), 3 (if a nonrow and the two rows differ at two factors), or 1 (if a nonrow and the two rows differ at ≥3 factors). Frequencies in the classes number 3^L, 2·3^(L−1)·C(L,2), and 3^L·sum_{h≥3}2^(h−1)C(L,h), respectively. The ordered D=R∪{0} pair maximum is M=2L+2 for all L≥1, consistent with earlier NIGHTFALL one-query sources. Proof uses F₂ matrix-rank decomposition plus published tensor circuit splitting. Current C++ checker checks full pair-XOR histograms through L=7. **No end-to-end Lean theorem or independent global novelty finding for the pair spectrum.**

**Quantum high-rank adversary:** [check_tensor_t2_group_energy_exact.py](check_tensor_t2_group_energy_exact.py) tests rank-(3^L) real projective effects, independently constructed dense rational inter-query unitaries, exact Walsh expansion and conditional expectation, each of six repeated-slot grouped energy tails ≤2Mη, and each of four distinct zero-triple group tails ≤20Mη, at L=1,2 and four rational η values. Source-exact CI is included. These finite passes cannot prove arbitrary complex ancillary workspaces or high-dimensional all-L energy inequalities.

**Lean local coefficient attempt and demotion record:** [CI run 45053695789](https://github.com/d3lefts/d3lefts/actions/runs/45053695789) failed because the first primitive-fiber source used noncomputable Finset.toList; all five dependent decision proofs were unprovable as authored, and the resulting compilation output included sorryAx. That failure has **not** been claimed as a certificate. The source was corrected at commit 8bf7a9119bfa0bda28e09eb2d5effd66be1f1c50 to use computable Finset.sort; exact-head kernel replay outcome for that repair must be checked separately. The earlier cancellation-only Lean certificate [run 45052357652](https://github.com/d3lefts/d3lefts/actions/runs/45052357652) remains valid and unaffected.

**Model-exact stop gate:** The rank-free T2 simulator remains a paper candidate in archived #1016 and open review issue #1021. Neither the exact pure-frequency formula, the local Lean coefficient checks nor finite high-rank simulations replace (i) arbitrary-frequency all-depth primitive-lift counting and (ii) complete quantum Hilbert-space energy estimates. No external submission or novel theorem promotion authorized.


## Additional independent fixed-round competitor (v5, 2026-11-22)

**Qipeng Liu and Saachi Mutreja**, [Parallel Quantum Advantage with Limited Adaptivity Requires Structure](https://arxiv.org/abs/2608.20297), posted 20 August 2026. They prove dense-distribution indistinguishability for massively parallel quantum queries and derive constant-round classical simulation over the **uniform full oracle input**; mixed classical/quantum adaptive prefixes are also treated. This independent 2026 paper must be included alongside Blanc–Docter–Strassle–Tan in all fixed-round priority comparisons.

The lower-dimensional tensor code has ambient density 2^(2^L−3^L) inside the 3^L-bit oracle answer cube, hence not a high-density source when L grows. No automatic application of the independent-oracle theorem or its dense-distribution coupling to this code source has been justified here. Its algorithms could nevertheless have an unpublished/specialized extension; worldwide priority is **still open**. Neither paper should be described as solving the same correlated-code statement without verifying the source measure and query algebra.

**Wider literature caution:** The 2026 paper [Beyond Kruskal: Polynomial-Time Tensor Decomposition under the Lovitz–Petrov Condition](https://arxiv.org/abs/2609.13693) is further LP-adjacent work, but concerns decomposition algorithms/uniqueness conditions, not an observed proof of the present primitive XOR-fiber polynomial. This is a limited indexed search, not exhaustive referee priority clearance.
