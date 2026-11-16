# Historical legislative intelligence — data, API and provenance contract v1.1

This is an integration target, not a claim that every module or data migration described here is running on current main. It layers over [historical contract v0.3](../../HISTORICAL_REPRESENTATION_CONTRACT_v0_3.md), the [standalone synthetic history engine](../../historical/README.md), and the [no-live-data gates](../../REAL_DATA_MIGRATION_GATES.md).

## Normalized data graph

**Institution → Jurisdiction/office → Seat (effective interval) → District boundary version → Person → Service tenure → Legislative session → Motion question/version → Named roll call → Member position → Reviewed issue correspondence → Display provenance.**

Private user-side data is separate: **User → explicit residence interval (private) → time-aware seat eligibility; optional DOB for default range; private exact-version issue response**. Do not join a real person or address into a public evidence export.

Canonical entity IDs and recommended required attributes:

| Entity | Key and required fields |
|---|---|
| PublicSource | source_id, custodian, original_uri/fixture URI, obtained_at, original_sha256, parse_sha256, license, source_status, source_version, supersedes |
| Jurisdiction | jurisdiction_id, name, type, effective_from, effective_until, source_ref |
| SeatBoundary | seat_id, district_geometry_version, effective_from, effective_until, authenticated scope provenance |
| OfficeTerm | stable person_id, term_id, seat_id, chamber, start and end date, evidence ref; support interruptions and simultaneous seats |
| Motion | chamber, session_or_meeting_id, motion_id, motion_type, exact title/text/version, scheduled/voted_at, action, effective/enactment status, source ref |
| RollCall | rollcall_id, motion_id, rollcall_type RECORDED/VOICE/DIVISION/SECRET/UNKNOWN, result, count basis, source ref |
| MemberPosition | rollcall_id, person_id, term_id if resolved, explicit choice, immutable source record ID, verification status |
| IssueCorrespondence | issue_id, motion_id, relation EXACT_QUESTION/SUBSTANTIVE_REVIEWED/TOPIC_ONLY/UNREVIEWED, conditions, exceptions, reviewer, validity interval, source version |
| PrivateResidence | private_user_id, from/until, opaque geographic match handle, evidence class; no public address |
| ReleaseProjection | revision_id, source completeness summary, redactions, external-publication permission, signoff, correction link |

Separate **valid time** (when facts such as boundaries and terms were true) from **record time** (when sources and corrected assertions entered the system). A later-discovered term correction must not silently rewrite what was known at a previous record snapshot.

## Domain invariants and joins

Use half-open intervals [start, end) consistently in local civil dates with an explicitly recorded jurisdiction time zone for date-only vs timestamped legislative actions. Require date precision before comparing intervals. Do not assign simultaneous exclusive House seats for one historical residence when map evidence contradicts that; permit both Senate seats and explicitly documented multimember or at-large seats.

A roll-call key cannot be only the bill ID: it must include chamber, congress/session/meeting, exact roll-call question and vote time. A YEA vote means assent to the **asked motion**, not necessarily a substantive position on the overarching bill.

Represent SOURCE_MISSING, NOT_INGESTED, NO_INDIVIDUAL_RECORD, UNVERIFIED, CONFLICT, SUPERSEDED separately. An explicit NOT_VOTING is a positive named record, not an invented absence reason. A voice-vote result may be institutionally valid yet cannot establish a named member's vote.

No universal "every vote" claim unless a source- and period-specific completeness certificate justifies it. Publish a coverage matrix showing available records and gaps, not an artificial 100% figure.

## Existing synthetic source surfaces

- The **standalone Python historical service** (historical/README.md) has fixture-only adapters for fictional House, Senate, municipal and issue correspondence; immutable local storage and read-only API. It is not the integrated Python legislative application.
- The synthetic web lab under docs/commonwealth-intelligence.html uses browser-local fixture data and offers civic/roll-call exploration. It is a separate demonstration, not a verified real source.
- The historical representation v0.3 contract describes a richer Python app/history.py experience; that module is missing at the starting main checkpoint after a later change. See [05](05_IMPLEMENTATION_RECONCILIATION_AND_ACCEPTANCE.md).

### Currently implemented standalone history endpoints

GET /api/v1/historical/health  
GET /api/v1/historical/sources  
GET /api/v1/historical/issues  
GET /api/v1/historical/representatives?chamber=HOUSE&district=07&as_of=2025-01-03  
GET /api/v1/historical/votes/{fictional_vote_id}  
GET /api/v1/historical/dashboard?issue_id={fictional_id}&chamber=HOUSE&house_district=07&municipal_ward=02&as_of=2025-12-31&limit=20&offset=0

These endpoints do **not** implement authenticated historical user residence or an unlimited interval query. Their fictional district filters must not be interpreted as real geography. Do not claim a single multi-year personal report is already integrated into the representative app.

### Required integrated private history API

Design targets, **NOT implemented**: GET /v1/me/representation?from={date}&to={date}&mode=PERSONAL_HISTORY|CURRENT_SEATS|RESEARCH&group={group}&cursor={opaque}; GET /v1/me/residence-history; POST /v1/me/residence-history (requires consent and typed authority); GET /v1/rollcalls/{id}/source; GET /v1/history/coverage?group={group}&from={date}&to={date}. Response returns canonical motion question, dated term/seat evidence, source status, positional record and a coverage explanation; never raw DOB/addresses or secret ballot data. Avoid private DOB/residence in query strings and public cache; the user's selected historical interval is not itself proof of DOB.

For real integration, each public source adapter must be staged, source-hash checked, malicious-text isolated and independently reconciled against its custodian. Treat **SOURCE_UNVERIFIED** as not authorized for claims of real legal effect. Supported future sources named in the existing history contract include official U.S. House and Senate roll calls and Congress.gov metadata; none has been imported.

## Replay, correction and custody

No UPDATE/DELETE of verified canonical original records. Corrections append a new version with supersedes, provenance, review and original-byte retention. Independently verify source digests, row cardinalities, term overlap constraints, correct source/parsed date, seat mapping, and named member positions; keep externally attested/independent custody separate from self-signed local demo hashes.

### API acceptance examples

1. A fictional senator's YEA on cloture is displayed as YEA on CLOTURE, not support for final legislation.
2. Successor replacing an official halfway through selected interval does not inherit predecessor's votes.
3. A missing named entry returns NO_INDIVIDUAL_RECORD even if an aggregate passed; explicitly published NOT_VOTING remains as recorded.
4. A user moving between two documented districts sees each period only under its correct representation.
5. An unrecognized historical district returns UNKNOWN_MAPPING, not today's current seat.
6. A deleted/unavailable source creates a coverage gap or supersession state, not a fabricated record.
7. Exact-source signed evidence may verify local consistency but never alone establish source authority, political intent or legal enforceability.
