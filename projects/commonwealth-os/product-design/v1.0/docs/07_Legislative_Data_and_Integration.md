# Legislative ontology, sources and integration architecture

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Sources of truth

Prioritize authoritative enactments, minute/roll-call records and governing documents, then codified text, then verified mirrors. For Huntsville, Legistar is a council file/agenda workflow source and the municipal code library provides consolidated ordinance text; **the latest codified code alone may omit enacted-but-not-codified changes**. The 2026 Huntsville Legistar renewal item provides concrete evidence of the city's legislative tooling (source H1).

For federal layers, GovInfo is a data source for bill/public-law/Code-related packages; ingestion of the *entire applicable federal law* is a research program, not a turnkey API request. Preserve citation granularity and applicability limits.

## Core ontology

`Institution` → `GoverningRuleVersion` → `LegislativeInstrument` → `InstrumentVersion` → `NormativeProvision` → `AmendmentEvent` → `EffectEvent`.

At the opinion side: `QuestionVersion` → `QuestionProvisionMapping` → `ResponseEvent` → `DerivedPosition` → `OverrideEvent`, all in a private data domain. Authorized votes are separate `BallotDefinition`, `EligibilitySnapshot`, `CastBallot`, `TallyCertificate` and `DecisionPassport` events; never join personally identifiable ballots to public profiles.

## Event classification

| Event | Substance handling |
|---|---|
| Introduced | New instrument; ask only if relevant and opted-in |
| Amended | New version; semantic change classification; remap and mark affected positions stale |
| Repealed | Preserve prior historic state, append repeal event; ask distinct repeal question |
| Consolidated/codified | Link old and new identifiers; verify whether normative effect identical |
| Corrected source transcription | Correct data through revision with operator reason, independent review |
| Made effective | Record effective time and legal authority; not merely a passed vote |

## Source ingestion pipeline

1. Fetch via approved endpoint (do not assume a public screen constitutes permission to bulk scrape).
2. Persist immutable bytes, retrieval timestamp, URL, checksum, institution identifier and license/usage terms.
3. Parse and segment instruments. Legal reviewer validates critical attributes: citations, operative clauses, enactment, effective dates.
4. Align versions through IDs and semantic diff; AI may suggest mappings but cannot certify legal equivalence.
5. Reconcile to institution-approved gold corpus, record missing/repealed/out-of-scope exceptions.
6. Trigger question mapping review, provenance updates and user notifications for substantive changes.
7. Maintain backfill, retry, source outage and human correction queues.

## API design (illustrative; no implementation claimed)

- `GET /v1/institutions/{id}/rules/current`
- `GET /v1/instruments?institution_id=&status=&after=`
- `GET /v1/instruments/{id}/versions/{version}`
- `GET /v1/instruments/{id}/diff?from=&to=`
- `GET /v1/me/preferences?jurisdiction=&basis=&state=` (private)
- `POST /v1/me/responses` (idempotent, consent-scoped)
- `POST /v1/decisions/{id}/ballots` (only in independently authorized voting mode)
- `GET /v1/decisions/{id}/passport` (public/private field redaction)

See `../schemas/` for illustrative JSON Schema; these do not substitute for authenticated API contracts, validated laws or database migration specifications.

## Multi-tenancy invariants

All primary keys include or resolve immutable institution scope. No join merges member lists, voter profiles or private responses across tenants. Public government consultation aggregation is a separate and explicit policy-controlled pipeline. Rule version is frozen for each vote and amended only through new authorized snapshots.
