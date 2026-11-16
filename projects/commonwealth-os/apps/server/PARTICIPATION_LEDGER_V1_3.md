# Commonwealth OS — Durable synthetic participation v1.3

**Research engineering checkpoint, not municipal deployment, not voting infrastructure.** This is an opt-in, localhost-only backend for the existing v1.2 participation journey. It uses the **existing SQLite** transactional server. PostgreSQL migration and an independently operated custodian remain unresolved.

## Reproducible use

```bash
cd projects/commonwealth-os/apps/server
npm test
npm run seed              # first run only; synthetic actor credentials printed locally
npm start
# open http://127.0.0.1:4180/browser/
```

In the browser's Participation workspace, enter one of the locally seeded fictional bearer tokens (not an actual resident credential) and select **Connect to local synthetic ledger**. Token remains in page memory, not LocalStorage/cookies; refresh requires reconnecting. The existing visitor/steward selector remains a *display* mode; the authenticated server actor alone grants permission. Student-demo maps to UAH, union-demo to HOA, municipal-demo to HSV; only the token's institution can be accessed. The static GitHub Pages mirror keeps its original in-memory-only behavior.

The **same server process and SQLite database** now handle the legacy synthetic procedural decision endpoints and the separate participation event streams. No authoritative ballots, real institution identities, real policy enforcement, or external source imports are introduced.

## Event architecture and guarantees

- `participation_events`: tenant-scoped sequential private commands; chained SHA-256 commitments; each includes a random 128-bit nonce, fixture-state digest, and post-state digest. DB update/delete triggers block accidental mutation. A SQLite administrator can drop triggers, replace data, or rewrite the chain; this is not externally anchored.
- `participation_streams`: current sequence and chain head. `participation_requests`: idempotency records with request digests, so identical retries return the original result and conflicting retries fail.
- All commands execute inside the existing `BEGIN IMMEDIATE` transaction with fresh role/eligibility checks. Both `expectedSequence` and `expectedRevision` are required. A stale client is rejected; the browser refreshes the latest view after a conflict.
- Source fixtures are pinned by a `seedHash`. A change to the seed data or state machine can fail replay rather than silently reinterpreting old records; a planned schema/fixture migration must version the replay implementation.
- `transact()` from the browser v1.2 reducer validates and replays non-advisory commands; no new official voting logic is added.
- Private `ADVISE` events do not enter the public proposal state. Member views show only their own exact-revision advisory choices; private comment text and pending amendment text are withheld from other members. Fictional clerks/chairs/auditors can inspect local unmoderated submissions, explicitly *not* a production privacy model.
- `GET /api/v1/participation/:tenant/dossiers/:proposalId` uses the minimized public dossier; includes a locally replayed ledger sequence and head, **never** a claim of signed government evidence, source authenticity, or an established Proof Passport.
- `verify-participation.mjs` is a distinct implementation of a hash-chain continuity checker; it does not import the primary ledger implementation or the reducer. It tests persisted consistency, **not** institutional authority or the correctness of every state transition.

### API

All endpoints below require the same locally seeded synthetic bearer token as the original server:

- `GET /api/v1/participation/:tenant/board` returns tenant-scoped, actor-filtered browser state and integrity metadata.
- `POST /api/v1/participation/commands`: `{institutionId,command,expectedSequence,expectedRevision,key}`. The command is an existing v1.2 reducer command. Server disregards any forged client role and instead checks the actor record.
- `GET /api/v1/participation/:tenant/dossiers/:proposalId` returns a privacy-minimized case export.
- `GET /browser/` serves the existing browser from the same local origin, avoiding CORS and mixed-content credential handling.

Independent local checker, after a seeded test has generated events:

```bash
node verify-participation.mjs data/commonwealth.sqlite student-demo
```

## Tests and limitations

`npm test` includes role and tenant separation, idempotency, comment and stance privacy, amendment revision fencing, restart/replay survival, trigger enforcement, deliberate SQL corruption, and authenticated HTTP serving. The GitHub comprehensive-browser workflow invokes these tests together with the v1.2 mirrored-browser checks.

**Remaining gates:** migration to PostgreSQL with transactional invariants preserved, external anchored checkpoints, independent validator and adversarial security audit, consent/retention/deletion, live moderation and abuse handling, production IdP, automated backup/recovery drills, accurate source-of-law custody, accessibility/usability evaluation, and legal institutional authorization. No user information or ballots should be entered before these gates. This work is not a new patentability claim, a governmental assurance certificate, or a deployment-ready competitor to Decidim/CONSUL.
