# Commonwealth OS — transactional synthetic server (v0.3 + participation v1.3)

**Status:** working **synthetic-only** proof of architecture, not a voting product, municipal system, election security certification, or legal compliance assessment. Do not enter real users, ballots, ordinances or identities. Bind to localhost only.

**New in participation v1.3:** persistent version-fenced event journal, privacy-minimized dossier views, independent local chain continuity checker, and same-origin optional browser adapter. See [PARTICIPATION_LEDGER_V1_3.md](PARTICIPATION_LEDGER_V1_3.md). PostgreSQL and external custody have not been implemented.

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
