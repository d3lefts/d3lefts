# Proof Passport — F16 cubic phase-block finite witness (11 November 2026)
Status: **Lean kernel-checked finite construction; global priority unverified; general adaptive transfer unrefereed.**

## Exact machine-checked statement
In the concrete 16-element ring representation defined by \(\mathbb F_2[z]/(z^4+z+1)\), represent the subgroup \(\mathbb F_4^\times\) by \(\{1,6,7\}\). For \(i=0,\ldots,80\), write its four ternary digits as four phases in that subgroup, evaluate the three specific mixed linear forms in \[`PhaseBlock.lean`](PhaseBlock.lean), then cube each output. The map from 81 tuples to three output values is injective. Exact Lean theorem: `Nightfall.PhaseBlock.eighty_one_distinct_outputs` (equivalently `block_boolean_certificate`). All values and the 3-by-5 coefficient matrix are literal source definitions, not hidden tables.

## Evidence and certificate
- Pinned original source PR [#243](https://github.com/d3lefts/d3lefts/pull/243), head `d3a3717e846390461c7cf2ec41553189d78267a1`, merged.
- Successful [GitHub Actions run 40995299592](https://github.com/d3lefts/d3lefts/actions/runs/40995299592), official Lean 4.35.0 and `#print axioms` for the named finite certificate.
- `cube_fibers` and `field_inverses` are small algebra checks; the distinct-output result is the construction-specific, independently replayable content.
- The original exact Python scripts independently checked candidate maps; replay those and hash code to avoid compiler-only reliance.

## Mechanism and limits
A concrete coefficient matrix provides a collision-free powered observation code for all four relative phases. This is a **finite witness**, not proof that it is historically first, measurement-optimal in an unrestricted sense, or a fully formal adaptive decoder for all dimensions. The separately observed capacity inequalities `6^3<3^5` and `6^7<1+(16^5-1)/3` hold under their specific counting models, not arbitrary algorithms.

## Prior art and review
Finite-field phase retrieval, complement-property lower bounds, and prior adaptive batch decoders must be checked in the **same powered-query model**, with normalizations and output alphabets matched. No exact same-model historical match was verified in the present targeted search; absence of a search match is not a uniqueness proof. Do not promote the finite theorem to a globally original result until independently compared and externally refereed.

## Independent adversarial audit
Reimplement binary-polynomial multiplication, orbit quotient and all 81 phase tuples separately (not by copying the Lean `mul`), verify injectivity and all `cube_fibers`; search for a smaller block under the same oracle; independently establish or refute the claimed arbitrary-support transfer.

**Provenance:** NIGHTFALL/Devin J. Wright research direction; AI-assisted construction and Lean source, original PR contributors credited in Git history. Distinguish this source-specific matrix from classical finite-field arithmetic.

## Superseding original-work search — 11 November 2026

The **29 October** source `research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/F16_THREE_QUERY_PHASE_BLOCK_20261029.md` already includes the written k5 eight-query optimality theorem. A November independent enumeration replicates the 81/81 injectivity and the six-output alphabet; it is **not a new discovery**. More importantly, 30 October *closed/unmerged* PR 255 (Tessera) and PR 252 (Ryev) preserve a stronger **two adaptive powered queries for three anchored phases** with a separate 27-state Lean Boolean kernel certificate and written exact k4=6, k7=11 whole-signal bounds. See [source-bound off-main evidence](ADAPTIVE_BRANCH_EVIDENCE_20261111.md) and the dedicated [companion site passport](../../../docs/phase-adaptive-branch-proof-passport.html). The full adaptive transfer is NOT end-to-end Lean-certified and the closed branches are NOT part of main's 39-source inventory or an accepted global novelty record.
