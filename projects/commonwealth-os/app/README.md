# Commonwealth OS — Runnable Legislative Workspace v0.1

**Status: Implemented fictional-only prototype.** Not a city election platform, identity provider, legal certification system, municipal source importer, or deployed service.

Implements the [Commonwealth OS synthetic workflow v1.1](https://github.com/d3lefts/d3lefts/tree/main/projects/commonwealth-os/workflow) through a server-authoritative Python FastAPI backend and a mobile-first HTML/CSS/JavaScript client.

## Run locally

From the repository root (or this standalone ZIP root):

```sh
python3 -m venv .venv
. .venv/bin/activate
pip install -r app/requirements.txt
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Open **http://127.0.0.1:8000** in a browser. The server creates `app/commonwealth-demo.sqlite3` on first run, with three completely fictional independent institutional tenants. To reset, stop the server and delete the SQLite database plus its WAL/SHM companion files. For a custom DB location, set `CW_DB_PATH`.

To run tests:

```sh
python -m pytest -q app/tests/test_app.py workflow/test_workflow.py
node --check app/static/app.js
```

## Screens and workflow

- **Home:** institutional role, pending procedural work, revision and audit summary.
- **Bills:** immutable legislative text revisions, exact motion digest, amendments and event history.
- **Session:** agenda, quorum and meeting state, motion lock and debate progression.
- **Vote:** eligible DEMO members only; once per member, exact frozen version, server-side tally.
- **Records:** append-only event root, internally replayed Proof Passport, two-reviewer **fictional public preview**.
- **Assistant:** deterministic, rule-based contract explainer; not a connected AI model and has no official authority.

The onboarding screen intentionally allows anyone to switch among fictional institutional roles: Author → Clerk → Presider → Members 1–3 → Clerk → Reviewers 1–2. This is **role simulation**, not authentication. It demonstrates the independent organizational duties. No real-world institution has approved any workflow or rule.

## Run the complete demonstration

1. Enter as `author` in `Fictional Student Senate`; optionally amend the draft, then **Submit for review**.
2. Switch to `clerk` and **Place on agenda**.
3. Switch to `presider` and **Open deliberation**, **Lock exact motion**, **Open demo ballot**.
4. Switch to `member1`, `member2`, `member3` and cast fictional votes; duplicate and stale votes are rejected.
5. Switch to `presider`, **Close demo ballot**.
6. Switch to `clerk`, **Certify demo result**, and **Prepare public preview**.
7. Switch to `reviewer1`, approve first review; then to `reviewer2`, approve second review.
8. Switch to `auditor` and open **Records → Proof Passport** to download machine-readable evidence with internal replay result.

The same engine runs fictional university, HOA and municipal environments using tenant-isolated data. **No Huntsville City Council records have been imported.** The municipal environment is explicitly invented and neither authorized nor endorsed by Huntsville.

## Architecture

```text
responsive static UI (no CDN, no framework runtime)
          ↓ JSON / same-origin demo cookie
FastAPI commands, internal role lookup, invariant/error checks
          ↓ BEGIN IMMEDIATE + optimistic version + idempotency
SQLite state snapshots and command receipts
          ↓ exact contract functions
workflow/workflow_model.py
          ↓ independent internal evidence replay
workflow/independent_checker.py
          ↓ sanitized published-only projection
fictional public preview endpoint
```

Accepted actions are applied through the actual v1.1 contract functions, not a copied JavaScript voting engine. `expected_version` and `command_id` prevent stale updates and make command retries idempotent. Role selection credentials are server-created sandbox sessions, not legal eligibility assertions. Mutation endpoints reject unexpected fields including `mode: OFFICIAL` and require a same-origin action header. UI strings are escaped before insertion.

### API endpoints

`GET /healthz`, `GET /api/demo/tenants`, `GET /api/demo/actors`, `POST /api/demo/login`, `POST /api/demo/logout`, `GET /api/me`, `GET /api/items`, `GET /api/items/{id}`, `POST /api/items/{id}/commands`, `GET /api/items/{id}/passport`, `GET /api/public/decisions`, `GET /api/public/decisions/{tenant}/{item_id}`.

There is intentionally no endpoint to enable real votes or import city materials.

## Assurance scope and limitations

**Verified internally:** Reference model existing unit tests + HTTP integration suite, 38 tests total, SQLite persistence, replay evidence, branch mismatch and stale version detection, role and tenant boundaries, duplicate votes, and public preview redaction. Desktop/mobile visual smoke tested against mocked HTTP responses; the normal browser network path could not be exercised in the sandbox environment.

**Not established:** True user identity, secure election-grade ballots, vote secrecy from a server operator, digital signing or external anchoring of event logs, permissions beyond role-simulator fixtures, legal authority, independent security or accessibility audit, compliant public-records processing, production concurrency/fault injection, municipal deployment, authenticated voter profiles, or AI model integration.

This demonstration is only an initial vertical slice against the v1.1 contract. The production architecture in `../IMPLEMENTATION_AND_RELEASE.md` remains binding as a research plan, not a statement of completed implementation.

## Development notes

- Python FastAPI / Pydantic / SQLite and vanilla JS/CSS; dependencies pinned by compatible major ranges, not lockfile.
- No remote assets or API requests from the browser.
- Database seeded with fictional, fully synthetic institutional data.
- Before real users: replace role simulator with verified IdP, segregate private ballot data more strongly, independently authenticate rules and membership, establish protected event-anchor/key service, add authorization migrations, use managed Postgres, secure cookies with HTTPS, threat modeling, WCAG checks, and incident/recovery exercises.
