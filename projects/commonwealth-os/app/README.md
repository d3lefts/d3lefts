# Commonwealth OS — Synthetic Governance Application v0.2

**Research demonstration — NOT a government, election, judicial, or financial platform.**

This extends the existing [Commonwealth OS Synthetic Legislative Workflow v1.1](workflow/README.md) into an integrated, mobile-first, three-institution civic application. All records, authorities, proposals, membership credentials, participants, questionnaire results and budgets used here are **fabricated**. References to UAH or Huntsville appear only in research-draft question sets; no institution has endorsed, authorized or supplied records to this application.

## Run locally

```bash
cd projects/commonwealth-os
python3 -m venv .venv
. .venv/bin/activate
pip install -r app/requirements.txt
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Open http://127.0.0.1:8000. You may choose a **fictional** institution and **fictional** role. This role selector is deliberately insecure and must never be exposed as a real institutional login.

`CW_DB_PATH=/path/to/demo.sqlite3` selects the SQLite file (and associated `.demo-ed25519` signing key). Do not check any generated DB, key, or user data into Git.

Optionally use the local-only container configuration:

```bash
docker compose -f docker-compose.synthetic.yml up --build
```

**The Docker environment is a development sandbox, not a production deployment.** It binds to loopback only.

## Implemented synthetic features

| Feature | Implementation | Boundaries |
|---|---|---|
| Legislative workflow | Exact v1.1 Python reducer for Draft → Amend → Deliberate → Demo Vote → Certify → Reviewed Publish | No OFFICIAL vote, no binding enactment |
| Multi-item docket | Server-created, per-tenant immutable proposal IDs, optimistic transaction versions and command idempotency | Fictional institution membership |
| Identity and authority | Revocable fixture capability grants and procedurally current-rule gate | Fake login/role picker, **not a verified IdP** |
| Evidence custody | Append-only SQLite event table and independent snapshot consistency; replay checker | No trusted external anchor or hardware custody |
| Demonstration signatures | Locally held Ed25519 signer for decision and public-release receipts, offline verification CLI | Local key **is not** an institutionally trusted PKI |
| Questionnaires | Three sets × 24 draft questions with version checking and five-way response controls | Unvalidated source law and neutrality, no binding profile votes |
| Consent and privacy | Fictional opt-in profile, per-role read scopes, withdrawal erasure, aggregated cell suppression under five samples | Not a real privacy certification; no human data |
| Finance and public portal | Generated budget line items, sample sizes/denominators, independently reviewed fictional decision projection | No actual accounting or municipal datasets |
| Source view and assistant | Version hashes, provenance flags, deterministic procedural helper | No retrieved city materials, no connected LLM |
| Mobile UI | Home, Bills, Session, Vote, Records, Issues, Budget, Public, Sources, Authority, Assistant | Real browser/localhost access and WCAG audit still pending |

## Reproducibility checks

```bash
cd projects/commonwealth-os
python -m pytest -q app/tests workflow/test_workflow.py
node --check app/static/app.js
python -m compileall -q app workflow
```

Offline verification of an exported internal demo Proof Passport:

```bash
python -m app.verify_receipt path/to/receipt.json
```

Tests exercise amendment resets, role separation, revocation, tenant isolation, stale-version rejection, question versioning, consent withdrawal across restarts, budget arithmetic, signed synthetic receipts, and forged-evidence rejection. The Chromium smoke harness renders the actual UI and forwards browser API requests to a localhost FastAPI instance through a Python bridge because direct Chromium localhost navigation is restricted in this environment. This does **not** certify browser networking, cookies, TLS, accessibility, or production security.

## Operational boundaries

- Real electronic voting, federal identity, institutional authority, police/city integrations and real municipal data ingestion are **disabled or absent**.
- Consent records are seeded as artificial *simulation artifacts*, not obtained from real people. No real survey results, voting histories or identity profiles exist here.
- The proposal workflow cannot effectuate laws, government expenditures, contracts, or agency actions.
- The actual tenant/rulesets in any future institution must be reviewed and loaded **before** any real pilot.
- No questionnaires may generate legally binding standing votes. Their semantic neutrality, law mapping and inferred voting accuracy remain research questions.
- Public views contain only fictional aggregates and previously approved demo projections, never individual member ballot choices.
- Existing reviewer attestation is a narrow local-signature check, not an independently controlled or externally witnessed proof certificate.

## Next-phase migration gates

See [Real Data Migration Plan](REAL_DATA_MIGRATION_GATES.md). Future migration requires explicit institutional agreement, source provenance, live-identity integration, production persistence, privacy/records review, real rulebooks, independent audit, and an authorized release decision. None has been completed.

## Repository integration

The v0.2 files live under `projects/commonwealth-os/app/` and reuse `projects/commonwealth-os/workflow/` without modification. The existing UAH → other universities → Huntsville City Schools → HOAs → Huntsville City Council rollout remains unchanged. Development with generated fixtures is not permission to initiate any of those pilots.
