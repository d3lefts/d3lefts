# NIGHTFALL Lean certificates — consolidated audit

**Canonical registry:** [`docs/lean-certificate-provenance.json`](../../../docs/lean-certificate-provenance.json) is the **only manually maintained module inventory**. The individual Lean proofs and historical CI receipts are preserved in place. The audit generates a machine-readable view at runtime rather than another static, conflicting registry.

## One reproducible command

From the repository root:

```sh
python3 tests/test_lean_certificate_registry.py
python3 scripts/lean_certificate_registry.py --audit --json-out lean-receipts/consolidated-source-index.json
```

The first command mutation-tests the integrity gate without pretending to execute Lean. The second enumerates every `.lean` file under `research/nightfall/`, verifies its exact Git blob SHA-1, checks every classification and recorded successful-CI-head pointer, preserves separate custody of off-main historical files, and runs the existing provenance/passport tests. The JSON output records every module, source hash, historical CI run, and **receipt scope**. The new consolidated-registry workflow uploads it as an inspectable artifact.

The original 11 November `main` registry had **59 modules** (48 originality-quarantined, 10 derived transfers, 1 finite construction). Open [PR #391](https://github.com/d3lefts/d3lefts/pull/391) has **63** exact source records and additional genuine quadratic intermediates. The audit reads the current authoritative manifest; it has no fixed source count, so a later merge does not require duplicating the source registry.

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
