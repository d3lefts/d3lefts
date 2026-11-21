# Proof Passports v2 — source exactness, dependency closure, and epistemic gates

**21 November 2026.** This is an **additive, independently inspectable evidence overlay**, not an upgrade in mathematical theorem validity, an automatic promotion of old certificates, or a change to the 15 active and frozen historical claim identities.

- Machine-readable records: [docs/proof-passport-v2.json](../../../docs/proof-passport-v2.json)
- Fail-closed metadata and Git blob checker: [scripts/check_proof_passport_v2.py](../../../scripts/check_proof_passport_v2.py)
- Exact schema status: `nightfall.proof-passport-overlay.v2`
- Run from the repository root: `python3 scripts/check_proof_passport_v2.py --self-test` (ten mutation controls).
- Separate concurrent work: [PR #981](https://github.com/d3lefts/d3lefts/pull/981) introduces differential checker lineage and staged finite-exhaustion gates; do not represent the checks as integrated until that PR merges and passes.

## Required evidence ladder (no auto-promotion)

1. **Claim identity:** exact quantifiers, domain, model, constants, oracle and source; distinguish original theorem from a weaker equivalent-looking proxy.
2. **Source custody:** immutable commit, exact Git blob, archived input checksum, generator/tool versions and licenses. External URLs alone are `external-reference-only`.
3. **Statement equivalence:** independently match the actual formal declaration and its *transitive* hypotheses to the intended mathematical claim; prevent theorem-shaped axioms, imported target-equivalent assumptions, `sorryAx`, and altered definitions.
4. **Compiler and kernel:** same-pin full closure, named declaration, `#print axioms`, exact-source CI receipt, standard axioms policy, and kernel replay. `lake check` and `lake check --paranoid` are separate jobs; a generic green status is not sufficient.
5. **Independent adversarial audit:** reproduction designed *before* seeing construction, distinct source/checker lineage and environment, exact/interval arithmetic where meaningful, deliberate negative controls, and a named reviewer. A second model using the same derivation is not independent verification.
6. **Prior art and significance:** dated same-hypotheses literature, sharp comparison, tolerance and scope; originality and importance are separate from validity.
7. **Consequential release:** explicit owner authorization to publish, claim priority, use external materials or submit a result. Unapproved publication does not follow from CI.

## Status propagation

A dependency must carry its exact theorem type, imported assumptions, source pin, certificate scope, and failure conditions. If it is refuted, retracted, or its source changes, downstream *mathematical promotion* is quarantined until rebuilt; historical passes are retained as historical facts. The checker enforces missing IDs, cycles, and contradictions for records within this overlay. It **does not** prove semantic equivalence, automatically query GitHub run logs, run Lean, verify external sites, or independently re-evaluate the evidence.

The `scoped-formal-evidence` label means a previously reported named Lean receipt with an exact current source blob, **not** full external certification. The `external-reference-only` label conveys no local theorem verification. Every record has open human statement/prior-art reviews and explicit unfulfilled release authorization.

## Current entries

- Q2 heterogeneous finite (C_2\approx105.416): repository source-pinned, formal finite domain only. No infinite-product upgrade.
- Route 1 polylog-M / Wyner abstract W: source-pinned, successful historical CI runs, original latent-kernel hypothesis retained, imported predecessors credited.
- Tensor-subcube sharp upper bound and exact (3^L) extremizer: distinct source-pinned theorems, all-L scope, no quantum T≥2 simulation.
- **Alpöge submitted RH archive:** https://riemann.rylandgross.com/ — recorded as an external reference only; exact displayed `riemannHypothesis : RiemannHypothesis`, no NIGHTFALL source fingerprint, replay, Dirichlet-GRH import or independent review. External report or site statistics must never be translated to an owned kernel certificate. The site's own local verification panel was pending at inspection, 21 November 2026.

The failed Masullo manuscript is retained as an external **negative-control case** for spectral nuclearity, trace-normalization, cutoff interchange, and proof-completion gates, not an imported lemma or certified RH proof. In particular, biorthogonality alone never certifies uniformly bounded dual vectors or trace-norm convergence.

## Next decisive experiments

Independently replay the 5 pinned NIGHTFALL source declarations under the project lock; inspect their full exact types and dependency closures. Independently formalize or validate the v2 checker against deliberate attacks that preserve source hashes but alter theorem definitions, axioms, or included dependency graphs. For an external proof archive: freeze bytes/checksums and verify *that exact artifact* with independently implemented kernel checkers, audit statement and axiom scopes, then add a new evidence record instead of overwriting the original reference-only snapshot.

**Attribution:** Levent Alpöge for the submitted RH source and Ryland Gross for the public archive and checker; original external mathematicians and credited AI collaborators for imported lemmas; NIGHTFALL authorship only for its separately tracked work. This overlay contains no new proof of RH, GRH or another theorem.
