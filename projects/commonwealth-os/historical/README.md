# Historical Legislative Intelligence Engine — synthetic v0.1

Status: **IMPLEMENTED REFERENCE / SYNTHETIC-ONLY / INTERNALLY TESTED**. No real member names, official records, current or historical government data, personal preferences, eligibility, identity, or official votes are in this service. All people, jurisdictions, votes, records, tenures, laws and dates in the datasets are fictional. Not deployed or independently audited.

## Objective and boundaries

Make an independently inspectable, provenance-aware **historical comparison backend** for a future Living Voter dashboard. The engine does not score politicians or infer support from party affiliation. It must distinguish a literal recorded member position, a procedural question, a voice vote, the absence of a recorded position, a missing tenure match, and a user's own future ballot or preference.

`FixtureAdapter` accepts only four bundled files. **There is no HTTP adapter, API import route, real-data schema promotion, or government-network integration.** The current corpus is deliberately *not* a complete voting history. Nothing in it establishes legislative authority, electorate eligibility, or a real legislative outcome. Real adapters require the independent authorization and release gates described by `../REAL_DATA_MIGRATION_GATES.md`.

## Run

From `projects/commonwealth-os` with Python 3.11+:

```sh
python -m pip install -r app/requirements.txt
python -m uvicorn historical.api:app --host 127.0.0.1 --port 8001
python -m pytest -q historical/tests
```

For tests, use `HistoricalEngine('/tmp/fictional-history.sqlite3')` to choose an isolated database. Default database: `historical/historical-synthetic.sqlite3`, override with `CW_HIST_DB_PATH`. This is an **independent service** and does not mutate `app/main.py`, `apps/server`, their authorization logic, or their election state machines.

## Canonical source adapters and immutable models

| Adapter | Data | Fixture provenance |
|---|---|---|
| `house` | District 07 turnover, district 08, recorded passage/amendment positions | `fixture://commonwealth/house/v1` |
| `senate` | Two statewide seats, cloture, passage and nomination; explicit missing recorded position | `fixture://commonwealth/senate/v1` |
| `municipal` | Ward 02 turnover, ward 03, exact recorded and anonymous voice procedure, different amendment | `fixture://commonwealth/municipal/v1` |
| `issues` | Canonical civic propositions, typed source/question correspondences, fictional reviewer assertions | `fixture://commonwealth/issues/v1` |

Every fixture has a SHA-256 content digest. Every question, vote, tenure and correspondence has a canonical JSON SHA-256 digest. SQLite append-only tables and UPDATE/DELETE rejection triggers prevent modification through the normal database connection. Imports are transactional and exact repeat imports are idempotent. A changed fixture under the same source ID fails closed; future corrections need a new version with explicit linking and reviewed migration. This local store is not an externally anchored tamper-proof ledger.

Tenure matching uses **half-open intervals** `[valid_from,valid_to)` against each question's *vote date*, not the current date. In particular, a seat successor never inherits a predecessor's recorded votes. The senate sample contains a member with no individual entry on a recorded rollcall; this is represented as `NO_RECORDED_POSITION`, not `NAY` or `NOT_VOTING`.

Correspondence statuses: `EXACT_QUESTION`, `SUBSTANTIVE_REVIEWED`, `TOPIC_ONLY`, `UNREVIEWED`; no correspondence means no reviewed record in this deliberately small corpus. `EXACT_QUESTION` requires byte-identical normalized fixture proposition and direct passage/motion procedure. Cloture, amendment and nomination are **not** automatically support/oppose equivalents. All mappings include a synthetic reviewer and rationale; production requires source-version-specific independent semantic review and stronger normalization.

## Read-only dashboard API

No authentication or write endpoints are present: all data is public *fictional* reference content.

- `GET /api/v1/historical/health` — explicit synthetic-only switches.
- `GET /api/v1/historical/sources` — fixture provenance digests.
- `GET /api/v1/historical/issues` — civic issues, including one with no mapped record.
- `GET /api/v1/historical/representatives?chamber=HOUSE&district=07&as_of=2025-01-03` — member tenancy on selected date; senate uses `district=ALL`.
- `GET /api/v1/historical/votes/fx-h-vote-001a` — immutable row and source digest.
- `GET /api/v1/historical/dashboard?issue_id=fx-issue-riverfront&house_district=07&municipal_ward=02&as_of=2025-12-31&limit=20&offset=0` — dated evidence, question/procedure, reviewed issue mapping, recorded vote status per corresponding historical seat occupant, coverage caveats, and deterministic pagination.

Every response uses `SYNTHETIC_ONLY` labeling, `Cache-Control: no-store` and a no-external-data posture. It returns no user preference values, no private profiles and no voter eligibility. Each House/Senate/municipal query is fixed to explicitly fictional jurisdictions; passing a real district identifier **does not select a real government source**.

## Proof limits, acceptance and next gates

The internal tests exercise idempotent replay, unique/overlapping tenure rejection, day-boundary successor matching, multi-chamber rollcalls, procedural vs substantive status, voice-vote absence, no-record cases, pagination, invalid inputs, immutable rows, frozen-source conflicts, and rollback on tampering. This is internal testing, **not independent audit**.

Remaining: independent checker with source-different canonicalization, independently controlled content custody/anchors, genuine authenticated source adapters **only after separate approval**, actual completeness auditing, records corrections/supersessions with external source attestations, realistic redistricting/jurisdiction changes, reviewed multi-issue semantics, mobile dashboard integration and deployment security. See `../PREPILOT_LIVING_VOTER_v1_2.md` for the correct distinction between reported legislative member votes, retrospective simulated user choices and eventual legally authorized ballots.
