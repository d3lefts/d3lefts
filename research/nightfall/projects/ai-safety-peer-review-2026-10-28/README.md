# AI Safety: Theorem-and-Evidence Series — public peer-review dossier

**Research lead:** Devin J. Wright · **Freeze:** 2026-10-28 · **Status:** Peer-review candidate; external review requested.  
**Public landing:** https://d3lefts.github.io/d3lefts/ai-safety.html

## Scope and separation

September 2026 agent-safety research is organized as a series on **information sufficiency, permissible enforcement, provenance/history, capability composition, and relative oversight limits**. The October 2026 **SourceBound** implementation is separately evaluated as an auditable *source-assertion* admission boundary, and is not evidence of a universally valid safety theorem. Proofs, exact finite tests, historical benchmark replays, and proposed experiments have distinct labels.

**Review in order:** [theorem series](THEOREM_SERIES.md) → [claims/evidence](EVIDENCE_AND_LIMITATIONS.md) → [independent SourceBound protocol](SOURCEBOUND_EVALUATION.md) → [reviewer assignments](REVIEWER_GUIDE.md) → [frozen release inventory](MANIFEST.md).

## Theory manuscripts (previously public)

- [Agent Safety Under Abstraction](../agent-safety-under-abstraction/README.md): factorization, sound admission and collateral, provenance monoids, memory, closure, composition.
- [Counterfactual Authorization Gap](../../2026-09-counterfactual-authorization/README.md): reference-reach escape and conjunctive capability systems.
- [Three Ceilings on Oversight](../../2026-09-three-ceilings/README.md): observation, computation and authenticated evidence, each relative to the evaluator.
- [SourceBound research record](../sourcebound/CLAIM_EVIDENCE_LEDGER.md): source-linked claims, browser evidence, revision tests.

**The 28 October peer-review ZIP is frozen separately.** This GitHub directory is a *textual public mirror / reviewer index*, not a byte-for-byte upload of the 116-file archive. The complete ZIP includes three newly typeset PDFs, LaTeX, a revised SourceBound runnable implementation, original September PDFs, full logs, and verifier scripts. [Release inventory and SHA-256](MANIFEST.md). Do not treat the absence of unmirrored binaries here as verification.

## Main findings

1. **Observation sufficiency (classical):** a target is decidable from a view exactly when it is constant on each observational equivalence class. Restricted protocols also need an implementable decision rule.
2. **Soundness/collateral:** the maximal sound observer-side admit policy denies every mixed-label observation class; collateral is forced by missing evidence.
3. **Repair:** the least-cost exact refinement for a finite catalogue of additional observables is weighted set cover.
4. **Provenance/history/composition:** provenance summaries depend on the policy, memory may be essential, and joint-view sufficiency differs from decentralized veto enforcement.
5. **Counterfactual capability gap:** reference reach is the union of individual compliant configuration closures, with no recombination across counterfactual worlds.
6. **Relative ceilings:** information, computational and evidentiary authority limits have different assumptions and remedies.

## Verification and exclusions

Frozen local-package reproductions report **27,740 independent finite checks** and **27 SourceBound unit tests**, including the complete bug-fixed replay. These are finite or synthetic regression results, and were not independently rerun by external peer reviewers. The September CaMeL reader-lineage replays are *sensitivity studies*, not proof of an end-to-end exploit or achieved universal soundness. SourceBound's natural-web effectiveness is an **open prospective experiment**.

The earlier counterfactual resource-frontier band was **refuted by a counterexample** and is excluded from claims. The restricted-protocol converse was corrected; see [claim ledger](EVIDENCE_AND_LIMITATIONS.md).

**Attribution:** Devin J. Wright (research lead), with AI-assisted research, synthesis, coding and audits. External sources and contributors retain authorship of prior results; no institutional or referee endorsement is claimed.
