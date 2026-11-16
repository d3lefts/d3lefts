# API and acceptance blueprint for Living Voter prepilot v1.2

## Modular-monolith boundaries (v1.1 preserved)
`Question Registry` → `Voluntary Response Service` → `Private Position Ledger` → `Citizen Dashboard Read Model`.
Separate sources `Local Referendum Catalog` and `Congress Official Rollcall Ingestion`. The latter creates public records; only reviewed typed connections may feed a comparison context. `Referendum Journal` remains client-side/local encrypted by default, never written to server participation records or ballot service.

The eventual `Ballot Service` and `DAP` continue as independently reviewed, authorized modules, but are not activated in this POC. A congressional roll call is a historical fact, not a Commonwealth OS balloting transaction.

## Proposed endpoint contracts
- `GET /api/v1/instruments?jurisdiction=&version=`: validated public question bank with scope/version and reviewed mapping status.
- `POST /api/v1/me/preferences` (future only): requires consent token, question version, explicit stance, idempotency; *never a ballot cast*.
- `GET /api/v1/me/preferences`: authenticated, private; no staff/representative access to identifiable views.
- `GET /api/v1/public/congress/members?state=&district=&as_of=`: sourced delegation metadata, explicit user-provided district.
- `GET /api/v1/public/congress/rollcalls?member_id=&from=&to=`: official recorded vote with source/procedure and freshness flags.
- `GET /api/v1/public/referendums?jurisdiction=`: official referendum measures/outcomes, no person-linked votes.
- `GET /api/v1/me/dap` remains for institution-authorized proof records only; no assertion from a survey question.

## POC client-only functions
`submitResponse(question_id, stance)`; `deriveDirectPositionLedger(questions,responses)`; `addSelfReportedReferendumNote()`; `clearPrivateSession()`; `listPublicRecordedLegislatorVotes()`. The prototype must not invoke remote APIs or persist raw political answers automatically.

## Traceable test conditions
- A submitted survey stance shows only as issue preference, not a ballot or representative vote.
- The 24 + max12 and 96-max instruments are separate versioned registry entries and not silently pooled; no full-bank wording invented.
- `No preference`, `Skip`, `Unknown`, and `Not voting` are four different states.
- Missing verified referendum note displays empty state, not a fabricated personal vote.
- Saved referendum selections are plainly marked self-recorded and private.
- House and Senate named votes require chamber roll identifier, member, procedural question, date and official source.
- Distinguish `on passage`, `on amendment`, `cloture`, `nomination`, `motion to proceed`, and other vote subjects.
- A jurisdiction selector alone does not assert voter registration or actual district affiliation.
- A cross-issue comparison requires independently reviewed scope/semantics, and is never represented as numeric political affinity.
- Accessibility and preference deletion behave in offline demo; demo contains only synthetic data and no remote calls.

## Open review gates
The present artifacts do not ingest live congressional roll calls, authenticate residency, integrate a real ballot system, demonstrate secured private storage, independently certify question mapping, or assert IRB-backed human outcomes. Production use needs independent review of these components, including Congress.gov license/rate-limit and official source refresh.
