# Democratic Assurance Passport — OS integration contract v1.1

## Typed objects and scope
A DAP is a signed **manifest of claims and evidence references**, not a certificate that society is legitimate. It binds `tenant_id`, `jurisdiction_id`, `decision_id`, `proposal_digest`, `rule_digest`, `election_id`, `election_proof_digest`, `authority_epoch`, `challenge_epoch`, `effect_scope_digest`, an auditable expiry and approved executor. Public evidence must not carry ballots or identifiable civic AI conversations.

Claims have five disjoint types: `HUMAN_AGENCY_EMPIRICAL`, `POLITICAL_EQUALITY_EMPIRICAL`, `ELECTION_PROTOCOL_CHECK`, `LEGAL_HUMAN_ATTESTATION`, `EFFECT_GUARD_CHECK`. Only the middle election, legal-source and effect claims can be machine checked against their narrow verifiers; empirical claims require documented study designs, uncertainty intervals, missingness and sampling populations. No `TRUE` summary exists without a declared typed scope.

## State transitions

```text
DRAFT -> SPONSORED -> PROCEDURAL_REVIEW -> PUBLISHED -> DELIBERATING -> FROZEN
FROZEN -> VOTING -> CLOSED -> TALLY_VERIFIED -> LEGAL_CERTIFIED -> EFFECTIVE
Any nonfinal state -> REJECTED/WITHDRAWN/INVALIDATED (where lawful)
STAYED/CONTESTED -> effect-blocking overlay; the valid historical tally is never silently changed
EFFECT_REQUESTED -> GUARDED_COMMITTED | GUARDED_REJECTED | NEEDS_HUMAN_REVIEW
```

## Conditional invariant

For fully mediated effects under truthful current evidence and a linearizable trusted sink:

```text
CommittedEffect(x,t) => ExistsPassport(p) and
  Bound(p,x) and VerifiedElection(p) and LegalCurrentAuthority(p,t) and
  NoEffectiveStay(p,t) and AuthorizedScopeAndBudget(p,x,t).
```

**Never infer:** independently secure election cryptography; legality from a JSON pass; informedness from click-through; election secrets from signed receipts; physical effect mediation from application-side gate calls. The effect adapter must own the side effect and reject any API bypass. External systems without complete mediation are outside the certificate's scope.

## Semantic recertification and privacy

Original DAP v0.3 CR1: if retained authenticated transcript `T` satisfies `T(b)=T(b') => F_new(b)=F_new(b')` for all admissible finite ballot worlds, new-rule decision information is recoverable without new ballot disclosures. This **does not** establish that a new legal rule applies retroactively. CR2 minimum additional **nonadaptive universal** evidence cost is a lawful set cover on the equal-transcript/opposite-decision pairs. The privacy-permitted query set may be empty, making certification impossible. CR3 gives a necessary permutation-invariance condition for a declared anonymity group. CR4 demonstrates that individually private logs may jointly reveal private information.

Only retain public *aggregate/proof data* needed for the election; private identity and credential issuer data must be separately access-controlled and subject to privacy threat evaluation. Never publish a voter-specific cross-service correlation key.

## Claims must travel with provenance

`claim = (predicate, scope, assumptions, evidence_sha256, checker_version, result, expiry, dependencies, reviewer, limitations, status)`. Statuses include `DESIGN`, `MODEL_TESTED`, `EXTERNALLY_ASSESSED`, `LEGALLY_AUTHORIZED`, `DEPLOYED`, `FAILED`, `SUPERSEDED`. These are different facets, not a single increasing ladder.

## Independent check requirements

1. Freeze input bytes, canonicalization, tool versions and source custody.
2. Use a separate proof verifier rather than trusting app API output.
3. Verify source completeness, updated rule applicability and appeal/stay precedence; unknown blocks.
4. Challenge cross-tenant replay, text swapping, quorum manipulation, eligibility linkage, revoked keys, stale snapshots, simultaneous budget spending and direct external-API bypass.
5. Report actual effect inventory, residual unmediated paths and user accessibility failures.
6. Only after review attach a scoped release receipt; a passing unit test never constitutes institutional or election certification.

## Integrations
Election adapter: `create`, `freeze`, `credential`, `cast`, `close`, `publish_proof`, `independently_verify`. Public API emits references and proofs, not raw secret ballots.
Legal adapter: authenticated governing sources, effective interval, institution power and designated reviewer signature. Human review for legal ambiguity and retroactivity.
Effect adapter: `prepare(effect_digest, current_epochs)`, atomically `commit` with authorization or reject. It must not have an unguarded alternative.
AI: evidence-linked, optional, strictly advisory and never in possession of election keys or effect credentials.