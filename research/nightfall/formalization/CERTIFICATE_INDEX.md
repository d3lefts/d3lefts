# NIGHTFALL Lean certificates — consolidated audit

## 18 November 2026 — product-space Aaronson–Ambainis and simulation (PR #858)

This **current active-branch appendix** is scoped to [PR #858](https://github.com/d3lefts/d3lefts/pull/858), not a claim that it has merged into `main`. Each entry identifies the *specific* compiled declaration and its applicable run; a separate paper-level quantum-oracle bridge and novelty review remain outstanding. The earlier dated sections below are historical and should not be read as the latest all-L² status.

| Result | Exact declaration / source | Certified evidence and status |
| --- | --- | --- |
| Finite arbitrary-product AA influence bound (includes zero-mass symbols, no quantitative bias/alphabet dependence) | `Nightfall.ProductSpace.Influence.product_influence` in [ProductInfluence.lean](product_space/ProductInfluence.lean); heterogeneous form `Nightfall.ProductSpace.Heterogeneous.heterogeneous_influence` in [HeterogeneousAlphabets.lean](product_space/HeterogeneousAlphabets.lean) | [Run 44406881226](https://github.com/d3lefts/d3lefts/actions/runs/44406881226), **success** on `d8e201626bf1461bdedc280b1d27c9b731e45e8b`; [artifact 14476363017](https://github.com/d3lefts/d3lefts/actions/runs/44406881226) |
| Arbitrary measurable / infinite-index product AA terminal, a.e.-bounded L² class and iterated-residual degree | `Nightfall.InfinitePiAAProductTerminal.infinitePi_aa_product` in [InfinitePiAAProductTerminal.lean](universal/InfinitePiAAProductTerminal.lean) | [Run 44393215489](https://github.com/d3lefts/d3lefts/actions/runs/44393215489), **success** on `d596301450a51a1de3383933f64bc8b2705c2bab`; artifact `14471730074` |
| Printed cube AA conjecture recovered from product-space chain (not independent of Turturean's vendored lemmas) | `Nightfall.ProductSpace.CubeAA.printedConjecture`, `mainTheorem_of_productSpace`, `explicitBound` in [CubePrintedAA.lean](product_space/CubePrintedAA.lean) | [Run 44406881226](https://github.com/d3lefts/d3lefts/actions/runs/44406881226), **success** on `d8e201626bf1461bdedc280b1d27c9b731e45e8b` |
| Deterministic product-law simulation of bounded low-degree functions, `q ε³ δ^(5/2) ≥ 6√2 π⁶ d⁶` | `Nightfall.ProductSpace.Simulation.simulation_degree` in [ProductSimulation.lean](product_space/ProductSimulation.lean), source commit `771d11af21896aa83f481b332d21d7d706b56927` | [Run 44433153026](https://github.com/d3lefts/d3lefts/actions/runs/44433153026), **pending** at register creation; local strict audit reported, **no completed CI certificate claimed yet** |

**Trust boundary:** Lean directly certifies the *function* simulation theorem on a common finite alphabet with coordinate-dependent product weights; variable finite alphabets are handled by paper-level padding. The step from a T-query quantum oracle to a degree-≤2T symbol-indicator polynomial is still a paper proof, not a Lean theorem. Query complexity does not assert construction-time efficiency. The source receipt JSONs for this checkpoint are currently CI artifacts; a persistent register must contain the **actual downloaded receipts**, with source hashes and audit run IDs, rather than reconstructed or invented receipt records.

Compiling the dedicated 178-module closure is not equivalent to a fresh-clone `lake build` of these roots. The active generator `scripts/generate_nightfall_lake.py` does not yet seed all four result families or resolve hierarchical vendored `AaronsonAmbainis.*` module names. The integrated Lake gate is separate.

---

**Additional strictly compiled Lean support (#520):** [run 43637631337](https://github.com/d3lefts/d3lefts/actions/runs/43637631337) proves arbitrary product sigma-algebra cylinder generation, measurable-event countable coordinate support, and real measurable-observable countable coordinate support. Exact blobs tracked in [unrestricted terminal proof-scope manifest](../../../docs/unrestricted-terminal-proof-scope-20261114.json). The all-L² original-source unconditional Lean endpoint remains OPEN.

## 14 November 2026 supplemental current-source certification

Verified after the prior 98-file custody checkpoint (without changing frozen historical 67-file registry): strict named-source Lean #500 / #501 / #506 and new #512 actual `Measure.infinitePi` centered finite-cylinder variance (run 43635195844, SHA artifact 14130006709); #514 finite changed-law all-degree source-variance terminal (run 43635955108, artifact 14130003076). Strongest merged finite common-alphabet degree-two source bound #498 (run 43633180605) has `C₂≈736.673`, supplanting the previously displayed 1064.958. Separate active PR #507 intends a broader historical source-custody reconciliation; do not infer that this supplemental note is the completed custody migration.

**Analytic arbitrary-index theorem is valid as a standard mathematical proof, but the unconditional kernel endpoint is still OPEN.** Full proof and five named Lean obligations: [Unrestricted Efron–Stein Proof Passport](../2026-11-active-passports/UNRESTRICTED_EFRON_STEIN_PROOF_PASSPORT_20261114.md). This index records successful PR-head receipts, not a global all-`L²` kernel build or new mathematical priority.

---


## Current source-level certificates: 14 November 2026

The 67 historical provenance records remain immutable. Merged PRs #494, #495, #496 and #497 add **14 more exact source-blob custody records**, plus seven previously merged Q2 sharp-source files reconciled at this checkpoint, giving a current pending file count of **98** (historical 67 separate). New current named-declaration evidence lives in [the dated receipt index](../../../docs/current-lean-proof-receipts-20261114.json), with source Git blob IDs, actual pinned runs and immutable artifact digests.

**Strict scope:** Q2 common-alphabet 1064.958 source theorem (run 43627249467); SCIF 18 scoped local and canonical graph declarations (run 43630623548); universal authority exact logic and **conditional** infinite-index transfer (run 43630294034); Bellman model recurrence, not arbitrary adaptive policies (run 43629420558). Exact hybrid assurance cuts PR #493 are **not Lean**: finite-rational replay run 43626344870. Full source SCIF, infinite-product L², actual enforcement and priority remain open.

Run the registry audit below on this exact integration tree to confirm new SHA custody; it is a **source integrity audit**, not a fresh common Lean kernel compilation. Full audit context: [current Proof Passport](../2026-11-active-passports/CURRENT_LEAN_PASSPORT_20261114.md).

---

**Canonical registry:** [`docs/lean-certificate-provenance.json`](../../../docs/lean-certificate-provenance.json) is the **only manually maintained module inventory**. The individual Lean proofs and historical CI receipts are preserved in place. The audit generates a machine-readable view at runtime rather than another static, conflicting registry.

## One reproducible command

From the repository root:

```sh
python3 tests/test_lean_certificate_registry.py
python3 scripts/lean_certificate_registry.py --audit --json-out lean-receipts/consolidated-source-index.json
```

The first command mutation-tests the integrity gate without pretending to execute Lean. The second enumerates every `.lean` file under `research/nightfall/`, verifies its exact Git blob SHA-1, checks every classification and recorded successful-CI-head pointer, preserves separate custody of off-main historical files, and runs the existing provenance/passport tests. The JSON output records every module, source hash, historical CI run, and **receipt scope**. The new consolidated-registry workflow uploads it as an inspectable artifact.

The earlier 11 November checkpoint had **59 modules** (48 originality-quarantined, 10 derived transfers, 1 finite construction). [PR #391](https://github.com/d3lefts/d3lefts/pull/391) **merged on 11 November (Eastern)**, expanding the then-current `main` to **63** exact source records (52 originality-quarantined, 10 derived transfers, 1 finite construction) with additional genuine quadratic intermediates. The audit uses dynamic manifest counts rather than duplicating a frozen 59-versus-63 ledger.

**PR #386 integration checkpoint:** Two additional exact-blob scoped Lean sources (`CubicRankOneTerminal.lean` and `RankOneLeafMoment.lean`) extend the composite current-source inventory to **65** (54 originality-quarantined, 10 derived transfers, 1 finite construction). The paired strict Lean 4.35 named-declaration receipt is [run 43100116278](https://github.com/d3lefts/d3lefts/actions/runs/43100116278). This does **not** supply the missing vector influence or full cubic end-to-end theorem. The prior 63-source index remains a dated historical checkpoint.

## Certification gates

| Gate | Evidence | What it establishes |
| --- | --- | --- |
| **Source custody** | `python3 scripts/lean_certificate_registry.py --audit` | Every current source byte matches one registered Git blob and historical CI pointer; no off-main branch promoted |
| **Named theorem/kernel** | `scripts/lean_bridge.py --strict --decl … --json-out …` followed by `product_space/check_receipts.py` | Precisely named Lean declaration, compiler pin, actual theorem assumptions, allowed axiom dependencies, source and contract hashes |
| **Full theorem / priority** | Complete single-pin compiled final declaration, independent audit, and dated prior-art evaluation | **Not established** by the custody index or the union of scattered green jobs |

Current proofs use both Lean **4.33.0** with Turturean's pinned source and Lean **4.35.0** / Mathlib 4.35.0. Keep their scoped historical receipts separate: a successful source hash match under different pins is **not** a common end-to-end compilation.

For a fresh named proof, run its original exact toolchain and `python3 research/nightfall/formalization/product_space/check_receipts.py RECEIPT.json`. The consolidated command does not invoke Lean.

## Existing evidence, unchanged

- [Historical provenance and originality classification](LEAN_CERTIFICATE_PROVENANCE_20261111.md)
- [Quadratic final theorem dependencies still missing](observability/QUADRATIC_E2E_CERTIFICATION_STATUS.md)
- [Compiler bridge and theorem contract](../../../scripts/lean_bridge.py)
- [Strict receipt/axiom checker](product_space/check_receipts.py)
- [Closed, unmerged F16 adaptive evidence](phase_block/ADAPTIVE_BRANCH_EVIDENCE_20261111.md)

**Fail-closed limits:** No added `.lean` file can escape inventory; changed source bytes, missing CI evidence, invalid classification, promoted worldwide novelty, or mixing off-main files with current modules fails the audit. Success proves **only** current-source integrity and registered scoped provenance; it is not a fresh full-program kernel compilation, universal mathematical theorem, or independent novelty review.

## 12 November 2026 source-bridge checkpoint (not a universal Lean certificate)

The canonical [current-source ledger](../../../docs/lean-certificate-provenance.json) now enumerates **67 individual scoped Lean source records** through #407/#408; the historic 59, 63 and 65 counts above remain dated checkpoints. Source custody and individual receipts do **not** establish one same-pin end-to-end proof.

- PR #407: finite actual quadratic row/section bridge with source-specific Lean receipt.
- PR #408: genuine finite Efron–Stein pair centering/kernel and oriented-rectangle declarations, eight named strict compiled declarations, [run #43167542367](https://github.com/d3lefts/d3lefts/actions/runs/43167542367); terminal source-level global matching parity is still absent. [Proof ledger](product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md).
- Separate finite all-n fourth-moment lemma: pinned Lean 4.35 [run #43062171542](https://github.com/d3lefts/d3lefts/actions/runs/43062171542), not yet composed into the source function theorem.
- The full scalar exponent-two and rank-r adaptive upper bound remain analytic manuscript claims, not kernel-certified. [Updated q2/rank passport](../2026-11-active-passports/quadratic-rank-observability.md).

Do not mix Lean 4.33/Turturean-pinned and Lean 4.35/Mathlib-pinned receipts into a fictional common compilation. The frozen earlier provenance is unchanged.

## 12 November 2026 paper-local conditional-section selector certificate

The previously uncertified finite selector step in the beta-conditioned fixed-observation research programme now has **five strict Lean 4.35.0 named-declaration receipts** in [GitHub Actions run 43284555054](https://github.com/d3lefts/d3lefts/actions/runs/43284555054), source SHA-256 `d3ddb18999cdc0e87e2ef5c131eac821c74a4141cc9a722b10581de5858cdb35`. [Exact source](../../../papers/conditional-section-duality/lean/FixedObservationSelector.lean) and [scope passport](../../../papers/conditional-section-duality/lean/PROOF_PASSPORT.md).

They establish the sharp disjoint-block finite selector inequality and its `beta^2 q R <= d^4 B^2` budget transfer **given an L1 section-budget premise**. The compiler checked the five explicit theorem types under foundational axioms only; an independent finite product checker also passed. The original source's low-degree section L1 bound, ANOVA source-risk identity, largest-`q` selector existence, measurable lift and non-author priority review **remain open**.

**Registry separation:** this new proof is paper-local under `papers/conditional-section-duality/lean/`, not among the existing 67 `research/nightfall/` source modules. Do not inflate the main provenance count or conflate this 4.35 certificate with the separate 4.33 quadratic receipts. Subsequent source-registry import requires explicit SHA and source-head reconciliation.
