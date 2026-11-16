# Historical Representation & Recorded Roll-Call Contract v0.3

**Scope:** Commonwealth OS simulated Living Voter feature. **Status:** Implemented and internally tested with fictional data only. No actual public records or live personal data have been ingested. 15 November 2026.

## User-visible requirement

A user must be able to inspect every **available individually recorded decision** by the officials who occupied the user's geographically applicable representative seats during a selected historical interval. The default begins on the user's birth date. A manual date range may precede birth. The interface must distinguish two semantics:

- **Represented during residence** (default): only a vote cast at a time when a documented residential jurisdiction and effective district assignment place the user within the relevant constituency. A period with no verified residence mapping yields no claim of representation.
- **History of current seats** (optional): earlier votes cast by holders of the office/seat associated with the user's current jurisdiction, **without claiming those people represented this user then**. For offices that did not exist in earlier periods, no historical service is invented.

The result must display the date, level/chamber, named official, precise seat, service term, motion identifier, exact question/action type, recorded position, and canonical source custody status. An aggregate party or issue-level opinion cannot substitute for a named roll-call entry.

## Historical joins and boundary rules

For each date `t` and group `g`, a named vote is attributable to the user's **actual past representatives** only if:

`KnownResidence(user,t) ∧ SeatAssigned(user,g,t) ∧ OfficialServed(official,seat,t) ∧ RecordedMotionAt(rollcall,g,t)`.

All date intervals for residence, district assignment and official term are **half-open**: `[start, until)`. Election dates, terms, resignations, appointments, redistricting and user moves therefore affect which people are eligible for the historical join. A two-member Senate representation or at-large multi-member council is modeled by explicit *simultaneous seat assignments*, not by accidentally merging seat IDs.

`person_id` is stable across elected terms; `term_id` is stable per tenure. A public record's roll-call key includes institution/chamber, session or meeting, and named roll-call identifier. Record chronology and legislative procedure are distinct from the final enactment status.

An **absent member position** must be `NO_INDIVIDUAL_RECORD` / `NOT_IN_SOURCE`; it must never silently become `NAY`, `ABSTAIN`, or `NOT_VOTING`. An explicit source value of `NOT_VOTING` remains distinct.

`YEA` on a procedural motion, amendment, cloture vote, or motion to table is **not evidence of support for the entire bill**. The UI displays the exact voted proposition and action type. No candidate/official rating, recommendation, or overall political alignment score is generated.

## Provenance and completeness

A complete archive is a **coverage claim that must be established per source and time interval**. Missing, unpublished, non-roll-call, voice, secret-ballot, disputed, or unreadable records remain identified as gaps. "No known roll-call event" is never "no vote happened". The synthetic preview never advertises complete coverage.

For each future real-record import, the canonical envelope must include:

- `source_authority`, `source_document_uri`, `retrieved_at`, `original_bytes_sha256`, `parsed_snapshot_sha256`, `retrieval_job_id`, `license` and `source_custody_review`.
- `chamber`, `jurisdiction`, `session/meeting_id`, `rollcall_id`, `motion_type`, `motion_text/version`, `voted_at`, `effective/legal_status`, `amendment_target`, `recorded_result`.
- An immutable per-official `member_position` based only on the source, `official_identifier_crosswalk` and authenticated service terms.
- Historical district geometry, effective dates and residence-to-seat mapping evidence. Addresses and protected birth dates must be held privately and separately from the public roll-call corpus.
- Confidence **not** expressed as silently authoritative: `SOURCE_NOT_RECEIVED`, `SOURCE_UNVERIFIED`, `SOURCE_VERIFIED`, `PARTIAL_POSITIONS`, `RECONCILIATION_CONFLICT`, `SUPERSEDED`, etc. Conflicting records remain quarantined pending custodian review.

### Future US federal sources (verified references; not yet connected)

- [U.S. House Clerk's roll-call XML](https://xml.house.gov/) includes individual House roll calls from **1990 onward**.
- [U.S. Senate roll-call XML and archive](https://www.senate.gov/general/XML.htm) and [finding congressional votes](https://www.senate.gov/legislative/HowTo/how_to_votes.htm) include individual Senate roll calls from **1989 onward**.
- [Congress.gov API](https://api.congress.gov/) supplies member histories, bill information and House vote/member endpoints, with the House vote API marked beta. Use the original chamber's record as the roll-call custody source and Congress.gov for cross-reference where appropriate.

Not all votes are named roll calls. The Senate's historical guidance explains that voice/division votes do not identify individual member positions. They cannot be converted into individual history by an AI model.

State, county, city, school board and HOA source records require separate custodial adapters and completeness assessments. Publicly viewable council minutes are not, by themselves, proof of every official's individual vote on every issue.

## Synthetic v0.3 implementation

`app/history.py` exposes a pure, validated `report` function and API router, **read-only** and independent of fictional legislative tally state. `app/data/history_synthetic.json` contains 7 groups, 21 mock service terms, a fictitious resident birth date and two successive residences, dated district changes, and 38 mock chamber roll calls. The fixture is deliberately not linked to real places, people, elections, bills or source URLs. `build_history_fixture.py` deterministically regenerates it.

API (requires an existing demo session; future live identity/consent is NOT implemented):

```
GET /api/history/catalogue
GET /api/history/representation?mode=PERSONAL_HISTORY&group=US_SENATE&from=2010-01-01&to=2026-11-15&page=1&page_size=20
```

`mode=PERSONAL_HISTORY` is default; `CURRENT_SEATS` is optional. `from` defaults to the fixture DOB; `to` defaults to the current date in the project demo time zone (America/New_York). Dates outside the historical interval, unknown group names, invalid date syntax, future end dates and invalid pagination are rejected. Pagination is deterministic and bounded at 100 member-position rows per page. Responses include time-bound service rosters and an explicit completeness warning. Individual responses are not used to produce binding or implicit political preferences.

**Privacy:** No real DOB, address, GPS position, or electoral registration is inferred or collected. A production app should calculate the birth-date default inside an authenticated private profile service, avoid logging exact birth dates in URLs, and keep source-based public vote records separate from private user location history.

## Verification receipt (author-side)

- 79 local Python tests passed across existing contract/HTTP and historical features.
- A separate brute-force oracle tests all seven groups, both interpretation modes, and seven date windows by reconstructing matches without calling the main join helper.
- Mobile and desktop Chromium interaction checked with real FastAPI responses forwarded through a Python bridge; direct browser-to-localhost networking remained unavailable in the execution environment.
- Formal proofs, audited GIS district topology, identity verification, source-custody attestation, external security audit and real-record integration remain **NOT ESTABLISHED**.

## Pilot release gate

This feature is synthetic-only until the institution's authority, source-custody, identity, privacy/consent, historical district, scope, retention, and independent verification gates in `REAL_DATA_MIGRATION_GATES.md` pass. Import real data into a new staging namespace; do not overwrite the synthetic fixture. Never merge data from a synthetic tenant into a real institutional tenant.
