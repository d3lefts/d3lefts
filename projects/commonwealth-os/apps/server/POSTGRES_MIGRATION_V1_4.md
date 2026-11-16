# Commonwealth v1.4 — PostgreSQL Participation and Recovery

**Research prototype, synthetic-only; no real citizen data, government records, identity verification, official ballots, or institutional approval.**

## Architecture

- PostgreSQL is the sole **durable** state store for synthetic participation events and synthetic actors. The earlier procedural/voting SQLite demo remains separate and is not migrated in this release.
- A command checks the actor under a PostgreSQL `FOR SHARE` row lock and the tenant stream under `FOR UPDATE` **inside the same transaction** before appending events, updating the head, and recording its idempotency result. This fences concurrent commands and eligibility changes.
- Full private commands are AES-256-GCM encrypted before database insertion with a separately held 32-byte `COMMONWEALTH_PG_EVENT_KEY`. Each event uses an independent random 96-bit nonce, and authenticated additional data binds tenant, sequence, previous hash and current event hash. The symmetric key must never enter a database dump.
- The existing v1.3 reducer and privacy-filtered projection execute in a temporary SQLite **memory-only interpreter** to preserve exact transition semantics. SQLite is not the persistent participation store in PostgreSQL mode. This O(stream length) replay is a bounded pilot strategy, not production-scale architecture.
- Actor-specific advisory positions and unpublished comments stay outside public dossiers. Administrative access, small-group inference, consent, retention/deletion and moderation controls remain substantially unresolved. Database/application compromise can still expose or erase data.

## Run on a fresh local PostgreSQL database

Requires Node >=22.13, PostgreSQL 16+, and a database on localhost dedicated to fictional test data.

```bash
cd projects/commonwealth-os/apps/server
npm ci --ignore-scripts
export COMMONWEALTH_PG_URL='postgresql://cwtest:local-password@127.0.0.1:5432/cwtest'
export COMMONWEALTH_PG_EVENT_KEY="$(openssl rand -hex 32)"
npm run seed:pg      # fresh PostgreSQL only; synthetic tokens printed locally once
npm run start:pg     # http://127.0.0.1:4180/browser/
```

Do not save credentials or encryption material in Git or a web browser profile. The complete dependency tree is pinned in `package-lock.json`; CI uses `npm ci`. The service binds to `127.0.0.1` only. The local synthetic bearer tokens authenticate demo roles, not people. GitHub Pages stays an in-memory browser demo.

## Cold migration from v1.3 SQLite

Stop SQLite writers completely. Make and preserve an independent backup of SQLite including its WAL state, then checkpoint/close the source before import. Use an **empty** PostgreSQL destination; do not seed PG first.

```bash
npm run migrate:pg -- /absolute/path/to/stopped-commonwealth.sqlite
npm run start:pg
```

Migration reads SQLite read-only, independently replays the source journal, retains only synthetic actor token hashes, encrypts event payloads, copies the exact sequence, head hash **and prior idempotency receipts**, then replays the target. Mixed old/new writers are forbidden. The source cannot be proved authentic solely from a self-consistent local chain; externally pinned earlier checkpoints would be necessary to detect coherent rewrites.

## Checkpoints: capability versus actual custody

```bash
npm run anchor:pg -- student-demo > synthetic-checkpoint.json
node verify-pg-anchor.mjs synthetic-checkpoint.json trusted-checkpoint-public.pem
node verify-pg-ledger-anchor.mjs synthetic-checkpoint.json trusted-checkpoint-public.pem
```

This emits a local Ed25519-signed `tenant, sequence, headHash, seedHash` receipt. The independent verifier uses a public key pinned outside the signing process. A receipt stored on the same operator's disk is **not an external anchor**. The additional PostgreSQL checker replays ciphertext authentication and the exact hash-chain prefix matched to the pinned record; it does not replay the legal or institutional semantics. No third-party custody, independently controlled transparency log, government trust root, or external submission is configured or claimed. Private keys must remain separate; a leaked signer can fabricate receipts.

## Tests and disaster-recovery rehearsal

The `pg-participation` CI job runs a disposable PostgreSQL 16 service and executes `npm run test:pg`. This covers replay parity with v1.3, a two-client write race, stale sequence and revision rejection, role/tenant isolation, private advisory and unpublished-comment filtering, authenticated encryption and deliberate corruption, locally pinned signature tampering, and same-origin HTTP. The job then creates a `pg_dump` backup, restores it into an isolated second database and checks the recovered sequence, exact head and seed digest.

This is an **author-controlled regression and attack suite**, not a truly independent adversarial review. A CI restore is not an operational off-site recovery exercise; actual backup loss, key loss, full disaster timelines, retention policy and production RTO/RPO remain untested.

## Non-cleared release gates

- Independent security and privacy assessment; opt-in consent, moderation, appeal and retention policy
- Real-world identity and institution authority, no minors or real civic profile collection
- PostgreSQL least-privilege runtime roles and row-level security (the current prototype relies on parameterized tenant checks)
- Off-host immutable backups and an independent checkpoint custodian; independently pinned trust roots
- Key rotation, encrypted backup key management, full disaster response
- Historical source custody and legal precedence certification, production accessibility and real multi-user load tests

No official voting, real institutional import, automated publication, or production deployment is permitted. No technical novelty or patentability claim is made about standard PostgreSQL transactions, AEAD, hash chains, or signed checkpoints.

References: PostgreSQL [row locks](https://www.postgresql.org/docs/current/explicit-locking.html), [transaction isolation](https://www.postgresql.org/docs/current/transaction-iso.html), and [row-level security](https://www.postgresql.org/docs/current/ddl-rowsecurity.html).
