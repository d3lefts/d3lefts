# Commonwealth OS — transactional server demo v0.3

**Status:** working **synthetic-only** proof of architecture, not a voting product, municipal system, election security certification, or legal compliance assessment. Do not enter real users, ballots, ordinances or identities. Bind to localhost only.

## Runtime
Node.js >=22.13; built-in `node:sqlite` (experimental in Node 22), `node:http`, `node:crypto`. No cloud/vendor packages. SQLite is a local functional proof; production migration to Postgres plus HSM/KMS, OIDC/passkeys, role and tenant isolation tests, backups, and operational reviews remains required.

```bash
cd projects/commonwealth-os/apps/server
npm test
npm run seed  # ONE TIME; prints fictional local demo bearer credentials - do not commit them
npm start     # http://127.0.0.1:4180
```

The seed script refuses an existing DB. Data and signing key live under untracked `data/`; delete them to reset locally. Store credentials only in your terminal/session. Never publish a terminal recording containing them.

## API (always synthetic, nonbinding)

All except `GET /healthz` require `Authorization: Bearer <token>` obtained from the local seed script. The API accepts only JSON. No public CORS permission is granted. Every write requires an idempotency `key` (min 8 characters). All commands require the caller's matching institution and `expectedVersion` for optimistic concurrency.

- `POST /api/v1/commands`: `{institutionId,itemId,action,expectedVersion,key,payload}`. Actions: `CREATE`, `REVISE`, `SUBMIT`, `AGENDA`, `BEGIN`, `ATTEND`, `LOCK`, `OPEN`, `CAST`, `CLOSE`, `REVIEW`.
- `POST /api/v1/eligibility`: admin only, `{institutionId,memberId,eligible,key}`. Updates roster epoch and invalidates in-flight locked decision authority.
- `POST /api/v1/policies`: admin only, `{institutionId,policy:{quorum,yesNumerator,yesDenominator,strict},key}`. Appends policy revision and invalidates stale locked decisions.
- `GET /api/v1/me`: authenticated actor metadata.
- `GET /api/v1/institutions/:institutionId/items/:itemId`: scoped public-safe *authenticated* metadata (never exports ballots).
- `GET /api/v1/institutions/:institutionId/items/:itemId/evidence`: admin/clerk/auditor only, signed portability envelope with synthetic record. Never share a real voting record using this prototype.

Example initial `CREATE` (replace token with local fictional actor token):

```bash
curl -s http://127.0.0.1:4180/api/v1/commands -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"institutionId":"union-demo","itemId":"demo-motion","action":"CREATE","expectedVersion":0,"key":"example-command-001","payload":{"body":"Synthetic association procedural motion"}}'
```

## Portable Proof Passport evidence

The server signs each exported evidence snapshot using a locally generated Ed25519 key. All item revisions, signed events, policy versions, attendance, ballots, and review information are included in the **synthetic** package. Independent `verify.mjs` intentionally shares no application-core imports:

```bash
node verify.mjs evidence.json --trusted-key data/signing-key-public.pem
```

Create an externally pinned public key from the local signing key via Node crypto (or another trusted export process). Without `--trusted-key`, the checker reports `SELF_ASSERTED`, **not authenticated provenance**. A signature anchors the current export to a key, but the actual institution must authenticate and govern that key. Neither a signature nor the included record proves real-world identity, legal authority, ballot secrecy or voter intent.

The verifier checks Ed25519 signatures, key fingerprints, signed event and item-revision hash chains, permitted state edges, locked-policy hashes, attendance/roster inclusion, cast-event matching, vote thresholds, and separation of proposer and reviewer. It distinguishes stale authority from changed evidence. It cannot know whether the fictional source authority is lawful.

## Enforcement boundaries / limitations

SQLite transactions (`BEGIN IMMEDIATE`) make commands atomic; unique constraints and immutable update/delete triggers protect revisions, policies, ballots and events from accidental SQL updates. A database administrator can still delete the entire database, drop triggers, alter data, or replace signing keys. A compromised signing key can authenticate fabricated exports. Secure external anchoring, true independent review, replicated custody and key rotation are **not implemented**.

Votes are synthetic, named, and roll-call only. They are neither secret nor suitable for union elections, student elections or municipal elections. Rule/eligibility changes fail closed and require human case disposition; automatic migration of locked decisions is intentionally not implemented. The web UI has **not yet been connected** to these endpoints. No external deployment should be attempted without independent testing and institutional authorization.


## Participation/accountability bridge v1.3 — local synthetic data only

The existing transactional Node server also serves the comprehensive browser at **http://127.0.0.1:4180/demo/**. To test SQLite-backed participation, start with a **new fictional-only database**, run `npm run seed`, then `npm start`. The one-time seeder provisions distinct `student-demo`, `hoa-demo`, `municipal-demo` tenants (the existing `union-demo` remains separate). Copy a fictional member/clerk/admin token into the browser's local-session connection panel. The token is held only in page memory and is cleared from the input. **Do not enter real names, political views or official records.** Existing seeded databases are not automatically given a new HOA tenant; do not delete or overwrite any valuable data.

Authenticated endpoints (same-origin; no CORS grants):
- `GET /api/v1/participation/{UAH|HOA|HSV}` — institution-scoped fictional board and replay status.
- `POST /api/v1/participation/{UAH|HOA|HSV}/commands` — `{key,expectedVersion,command:{type,...}}`; requires a fictional bearer token; server-owned actor/role injection and optimistic concurrency.
- `GET /api/v1/participation/{UAH|HOA|HSV}/dossiers/{id}` — reduced public-view mock dossier, excludes comment bodies and individual survey responses.

Durable commands: CREATE, COMMENT, AMEND, CORRECTION (fictional participants); RESPOND_COMMENT, REVIEW_AMEND, STAGE, MILESTONE, BUDGET (fictional clerk/chair/admin). `ADVISE` and personal questionnaire answers are **never** stored by this backend. A member cannot obtain steward permission by setting a browser dropdown or sending `role: DEMO_STEWARD`. A local SQLite `participation_events` journal replays the pure browser reducer, checks versions/hashes before reads and writes, and retains amended text history; event update/delete triggers reject ordinary modifications. Exact receipt scope is **LOCAL_REPLAY_ONLY**—no external custody, trusted real identity, cryptographic authority or independent government proof.

The browser served by GitHub Pages remains an independently interactive **in-memory** synthetic demo. No public hosting of the Node server is authorized, and actual identity, municipal import and OFFICIAL voting remain absent. Tests: `npm test` in `apps/server` now includes durable-participation API/replay/HTTP checks. This integration is a development milestone, not production completion.
