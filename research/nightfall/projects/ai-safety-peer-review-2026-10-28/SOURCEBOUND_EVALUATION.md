# SourceBound — independently evaluated implementation track

**Release reviewed:** bug-fixed SourceBound (October 27, 2026). Its manuscript and implementation are separate from the September mathematical series.

## Publication contract

Candidate triple: subject, relation, object, qualifier, source/page, digest, evidence span, DOM locator, rule version. The candidate generator is separate from the admission gate. Conservative admission requires a source version match, restricted evidence-to-field re-binding, rendering/visibility checks, applicable temporal and same-page consistency checks, and revision-aware reviewed entity joins.

**What an admitted record establishes:** under the correct execution of the specified software and its assumptions, the record matches an auditable restricted source assertion.

**What it does not establish:** world truth, full semantic entailment, source reliability, natural-web recall, or a deployment-wide security guarantee. Agreement between publisher text and publisher metadata is internally consistent evidence, not independent corroboration.

## Reproduced known-fixture evidence

- 14,000 synthetic pages; 6,000 fixture-labeled triples retained; zero extra fixture emissions.
- 27 unit tests in complete bug-fixed replay.
- Independent reviewer-discovered cases led to changed rules and new regressions. Rerunning them is **post-hoc regression evidence**.
- 18 previously observed F4 paraphrases and 6 F5 metadata cases are **seen examples**.
- Field-mutation tests reject subject, relation, object and qualifier substitution under the constrained evidence grammar.
- Source replacement, quarantine and reviewed identity-link revocation have local fixture tests.

No claim of independent held-out natural-web performance follows from these measurements.

## Prospective blind evaluation — preregister before running

**Unit of generalization:** organization website/domain, rather than individual sentence. Freeze collection, sampling, excluded domains, annotation rules, date and deployment environment before tuning.

**System arms, with the same candidate budget:**
- B0: candidate generator alone.
- B1: generator + contextual source admission.
- B2: B1 + rendered-browser witness.
- B3: B2 + metadata consistency + independently evaluated semantic support.

Include an LLM generator as its own baseline and optionally behind the same gates. An independent annotation process must establish current subject ownership, relation, temporal qualifier and source span; stale knowledge-base triples cannot substitute for contemporaneous annotation.

**Primary outcomes:** unsupported published assertion rate and unsupported answer rate **at matched recall**. Separate article-level source support from independently checkable world accuracy.

**Secondary outcomes:** support precision, subject-binding and temporal error, abstention rate, end-to-end answer quality, p50/p95 latency and monetary compute cost. Cluster confidence intervals by domain. Include human adjudication disagreement and a predefined treatment of abstentions.

**Disconfirmation criterion:** if false assertion and answer rates do not improve meaningfully at matched recall, or if gains require unacceptable abstention/compute, the architectural efficacy hypothesis fails for this study.

**Negative controls:** visible syntactically supported lie, CSS-hidden material, structured metadata conflicts, stale officer title, entity switch, same-page conflict, malformed HTML, cross-document reviewed-link invalidation, and mutation of one field without updating the witness.

## Reproduction boundary

The full bug-fixed runner, source, fixtures and detailed logs are in the **separate 116-file frozen ZIP**, which is not a byte-for-byte mirror of this public GitHub folder. The existing public [SourceBound ledger](../sourcebound/CLAIM_EVIDENCE_LEDGER.md) gives additional context.

[Main index](README.md) · [Observed versus open evidence](EVIDENCE_AND_LIMITATIONS.md) · [frozen archive SHA-256](MANIFEST.md).
