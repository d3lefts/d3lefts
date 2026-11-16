# Commonwealth Legal Knowledge Kernel — synthetic v0.1

**Status:** source-grounded formal-claim prototype only. NOT authentic law, a legal opinion, legal authority, a voter service or government approval. Every source and numerical value in the riverfront fixture is fabricated. No public data is fetched.

## What is implemented

- A minimal typed legal/evidence source registry, source-level SHA-256, jurisdiction, legal-effective/publication/observation times, explicit source supersession and grounded reviewed-assumption rules.
- Candidate proof construction with *positive ground Horn rules only*, without AI claims of judicial interpretation.
- An **independently implemented verifier** checking source bytes, matching facts, exact rule premises and conclusions, chronological source applicability and proof snapshot scope.
- Separate statuses `MODEL_VALID`, `INVALID`, `INDETERMINATE`; goal-level `MODEL_DERIVED` never implies legally approved. Missing conclusion `development_approved` is correctly unknown.
- A source-dependency impact checker: a change to Z7 affects the zoning-review conclusion, not the unrelated floodplain-review conclusion.
- Neutral JSON civic dossier with legal derivations, fabricated housing/occupancy/developer facts, unresolved impact questions, and non-storing preference options.

## Reproduce

From `projects/commonwealth-os`:

```bash
python3 -m unittest discover -s legal_kernel/tests -v
python3 -m legal_kernel.dossier > /tmp/commonwealth-riverfront.json
python3 -m legal_kernel.dossier --changed-source Z7
```

Use Python 3.11+; stdlib only. `dossier.build(case)` provides a bounded, stable integration input for the existing browser/Living Voter prototype. This does **not** claim the browser currently consumes it.

## Assumption and certification boundary

All source interpretations are fixture assertions, not machine-extracted legal conclusions. Positive rule application is deductively checked **conditional on truthful source transcription and interpretation**. This does not model binding precedent, statute hierarchy, exceptions and defeaters, fact-finding, contested legal reasoning, authentic source custody, chain-of-trust signatures, private responses, true electoral identity, secret ballots or effect enforcement. There is no external legal review or production authorization.

`legal_at` selects the law's claimed effective time; `known_at` is the evidentiary knowledge cutoff. Superseded and not-yet-known authorities cause a hold, not automatic transfer. Source IDs are immutable; changes append a new source with `supersedes`, not edits. A historical snapshot may remain valid under its original authority even when a later snapshot requires review.

## Next gate

Implement official source adaptors (e.g. legislation, ordinances, court decisions) only after the documented ingestion gate and source-custodian/legal review. Add legal hierarchy, explicit burden/exception semantics, independent interpretation attestation and a signed source trust root before treating proofs as law-facing. Connect this dossier to `Living Voter` and `Chamber` through a read-only endpoint; keep preferences and ballots outside public dossiers. Independently replay semantic/legal source updates against adversarial fixtures.

## Mechanism lineage

Ground Horn derivations, provenance, source versions and invalidation are established ideas; this implementation does not claim novelty. Related Commonwealth work: `../assurance/`, `../workflow/` and `../product-design/`. Credit prior art in the main comparison, including LegalRuleML, Catala, Decidim and CONSUL.
