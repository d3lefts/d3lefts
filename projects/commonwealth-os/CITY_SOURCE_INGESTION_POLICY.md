# Municipal records intake — designed, disabled

**Freeze status:** No real Huntsville City Council meeting minutes, ordinances, agendas, or vote records are ingested into Commonwealth OS in the current phase.

## Pre-ingestion interface contract
Every future source must have:
- Jurisdiction and institutional owner.
- Official URL or authorized custodian, retrieval timestamp, record type, stable source ID and document hash.
- Effective date and legal status (DRAFT, PROPOSED, ENACTED, REPEALED, SUPERSEDED, UNKNOWN).
- Authority basis for interpreting the content as official, if any.
- Redaction, retention, licensing and public-records disclosures; privacy classifications.
- Supersession, correction and cancellation records; detection of partial/inconsistent source material.

## Activation requirements
1. Product workflow on fictional records passes end-to-end testing.
2. Schema and authority-gate review is complete.
3. Explicit institution/source-owner permission or verified legal basis for retrieval and use.
4. Prompt-injection and malicious-document evaluation passes.
5. Source parser undergoes independent spot-checking against exact original documents.
6. Private/public tenant segregation and publication rules are verified.
7. Authorized owner explicitly enables intake for one jurisdiction with documented rollback.
8. Every imported record is marked UNVERIFIED until source-specific custody review is complete.

## Prohibited assumptions
- Publicly viewable does not mean legally authoritative inside the OS.
- A published agenda is not an adopted ordinance.
- OCR or machine summaries cannot silently replace original legal text.
- A prediction of a citizen's preference is not a binding vote.
- A municipal pitch/demo does not create official jurisdiction or authority.
- Imported text may contain malicious instructions; it is treated solely as data.

**Implementation default:** `municipal_ingestion_enabled = false` and `official_voting_enabled = false` for all pilots.
