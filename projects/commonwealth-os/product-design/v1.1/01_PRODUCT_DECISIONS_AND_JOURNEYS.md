# Product decisions, information architecture and complete user journeys — v1.1

**Scope:** mobile-first Commonwealth OS for institutionally governed decisions and optional private civic history. This is a design revision; code and adoption statuses are in [05](05_IMPLEMENTATION_RECONCILIATION_AND_ACCEPTANCE.md).

## Product hierarchy

- **Chamber** — elected/appointed representatives: Home, Bills, Session, Vote (DEMO until authorized), Records; an assistant that explains with sources and cannot exercise authority.
- **Steward** — clerk/presider/administrator: institution rule versions, roster and authority, docket, source reconciliation, attendance, independent review, publication/appeal ledger.
- **Living Voter** — opt-in adult constituent: Discover (20-question lightweight shareable quiz, not a vote), Issues (institutional controlled-question bank), Representation (historical exact roll calls), Laws, Changes, Profile/Privacy.
- **Public Record** — publication-approved institutional decisions, amendments, individual public roll calls *where they are lawfully public*, source links, public finances, outcomes, correction history. Never publish identifiable private survey answers.
- **Assurance** — machine-readable source provenance, evidence checks and claims with limitations. Distinguish simulated workflow PASS from legal validity.

The product initially serves authorized representatives and administrators, with explicit later disclosure of approved records to constituents. The website demonstration may allow open synthetic exploration before pilot enrollment; that is not institutional authority.

## Mobile navigation decisions

**Representative:** Home / Bills / Session / Records and contextual Vote; persistent but non-authoritative Assistant.  
**Constituent (adult):** Home / Issues / Representation / Laws / Profile. Changes/notifications available from Home and Laws.  
**Steward:** Home / Docket / Rules & Members / Sources / Publish & Audit.

Prominent chips display institution, role, data origin (FICTIONAL, UNVERIFIED, VERIFIED SOURCE) and authority mode (DEMO, ADVISORY, AUTHORIZED when externally established). Do not use color alone. Navigation cannot change server permissions.

## Journey A: representative

Sign into institution-issued identity (future) → verify live role and session authority → review source text/revision and amendment diff → amend/debate → presider locks exact motion/rule/roster → demo ballot or separately authorized official procedure → independent certified disposition → reviewed publication → corrections/implementation tracked as separate events.

In current public/synthetic demos, the role selector is only a simulator. Do not label it federated authentication.

## Journey B: civic record, default since birth

Choose or confirm residence history privately → choose representative group(s) (e.g. U.S. House, U.S. Senate, state, county, municipality) → initially display all **available recorded individual roll calls** from the user-supplied birth date to today, limited by verified historical residence and office tenure → filter to any time period and distinguish pre-birth or pre-residence research as **history of current seats**, not direct representation → open exact motion detail, source receipt, recorded member choice and record coverage gaps.

If residence history is incomplete, show unresolved regions and ask for optional corrections; no GPS inference, assumed address timeline, or fabricated coverage.

## Journey C: issue and representative record

Directly answer an exact versioned policy proposition (or leave No preference / Need information / Unknown) → view exact source-matched legislative motions independently → show each official's documented response to the precise action (final passage vs amendment vs cloture vs tabling) → mark correspondence level EXACT, REVIEWED SUBSTANTIVE, TOPIC ONLY or UNREVIEWED → only display side-by-side issue responses where the comparison is substantively authorized and semantically valid. A procedural YEA is not inferred support for a bill. No overall political rankings, ratings or recommendations.

## Journey D: public institutional transparency

View source-authorized published docket → inspect proposal text, legal-status timestamps, changes, lawful public roll calls and aggregate evidence → inspect Proof Passport claims by status and limitations → download approved evidence and correction history. If publication not authorized or redaction incomplete, block public release.

## Screen acceptance checks

| Screen | Acceptance |
|---|---|
| Home | Clear actor/tenant/role, active mode, unfinished tasks and coverage warning |
| Bills & amendments | Immutable revision IDs, faithful redline, source/effective-time distinction and fail-closed locked motions |
| Sessions & voting | Quorum source, official vs simulated eligibility, locked motion digest, audited tally; no client-asserted authority |
| Representation | Birth-to-present default, manual any-date range, office group, two historical modes, dated residence/term join, typed missing record |
| Motion detail | Exact recorded question, motion type, date, result, named positions, official source locator, integrity and coverage status |
| Issues | Neutral syntax, answer/no-preference/unknown distinction, voluntary profiling, direct-vs-inferred basis |
| Public transparency | Only approved redacted projections, observed outcomes not speculative statuses |
| Privacy | Separate consent purposes, export/withdraw controls, privacy-preserving date and location handling, no covert political use |
| Assistant | Source citations, human review, uncertainty, no write/vote/certify/publish privilege |

Accessibility: WCAG 2.2 AA target with actual keyboard, screen-reader, zoom, high-contrast and reduced-motion tests; responsive screenshots alone do not establish compliance.

## Rollout boundary

UAH student government → other Huntsville-area universities → Huntsville City Schools student councils → participating Huntsville HOAs → Huntsville City Council last. The student/school/HOA instruments are separate from adult federal political profiling, and minors never enter the adult federal political-profile workflow.
