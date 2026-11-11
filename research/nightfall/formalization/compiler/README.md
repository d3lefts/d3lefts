# NIGHTFALL Lean Bridge v2 — proof closure infrastructure

**Date:** 2026-11-11. **Purpose:** make source-specific kernel receipts fail closed and provide exact theorem-type checks, without confusing formalized infrastructure with the original observability theorem.

## Actual upgrades

1. **Fail-closed toolchain:** missing/incorrect \`lean-toolchain\` makes the bridge return \`TOOLCHAIN_MISMATCH\` rather than \`COMPILED\`. A compiler version is not inferred from an unpinned workspace.
2. **Exact theorem contract:** optional \`--contract path.json\` includes a fully written expected Lean proposition for each \`--decl\`. The bridge appends a fresh \`example : <expected_type> := by exact Qualified.name\` to the source prior to compilation. A theorem with a weaker conclusion or additional unproved hypotheses cannot inhabit the contract statement.
3. **Workspace and source provenance:** receipts capture source/contract SHA-256, relative paths and workspace commit. A contract can pin a 40-hex upstream revision. The independent receipt checker verifies current checkout bytes, compiler pin, named axiom reports, and consistency of metadata.
4. **Proof graph:** \`PROOF_GRAPH.json\` explicitly distinguishes scoped kernel lemmas from the unformalized Gaussian, completed-product and adaptive steps. \`scripts/check_proof_graph.py\` blocks cyclic edges, missing dependencies and attempted promotion while open obligations remain.
5. **Pinned reusable environment:** \`.github/actions/setup-nightfall-lean\` verifies official Lean 4.35.0 build commit \`eb6cafb7290e8bd5f2937522d8d804f58f02bafc\`, Mathlib commit \`56a005855ea17e0b0958f73ec801ae140b0a1679\`, and pins the cache key to those revisions. This rollout covers the v2 contract workflow; it does not silently migrate the independently pinned 4.33.0 upstream Turturean build.

## Reproduction

\`\`\`bash
python3 scripts/test_lean_bridge_v2.py
python3 scripts/check_proof_graph.py --self-test research/nightfall/formalization/compiler/PROOF_GRAPH.json
python3 scripts/lean_bridge.py research/nightfall/formalization/compiler/ContractSmoke.lean \
  --workspace /tmp/mathlib4 --timeout 480 --strict \
  --allow-axiom Classical.choice --allow-axiom Quot.sound --allow-axiom propext \
  --decl Nightfall.Certification.additive_symmetry \
  --contract research/nightfall/formalization/compiler/contract-smoke.json \
  --json-out lean-receipts/bridge-v2-contract.json
python3 research/nightfall/formalization/product_space/check_receipts.py lean-receipts/bridge-v2-contract.json
\`\`\`

The smoke theorem is routine commutativity of natural addition. It demonstrates an exact-type contract and is **not an original mathematical result**. The adversarial Python tests mock a compiler only to audit receipt logic; real proof validity comes from the separate pinned Lean job.

## Scientific boundary and intended follow-up

The finite scalar theorem remains pinned in a different upstream Lean 4.33.0 project. Merely installing 4.35.0 does not imply the old proof compiles unchanged. Full multi-module unification must be performed deliberately, with a new kernel receipt at one immutable source revision and a contract containing the **complete** universal observability proposition.

NIGHTFALL's current full Hilbert/measurable/adaptive theorem is still **analytic, not end-to-end Lean checked**. The claim graph may change status only after such a checked declaration, line-by-line contract audit, and separate prior-art assessment. This infrastructure changes no mathematical result and makes no new novelty claim.

Additional boundary: the upstream elan installer is fetched at build time, although the installed Lean and Mathlib commits are checked. This is not a fully hermetic supply-chain provenance guarantee. Full compiler binary attestation and dependency closure would be a future security enhancement.
