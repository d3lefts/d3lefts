# Commonwealth OS — synthetic legislative backend 0.4

**Status: implemented and internally tested. No legal or security assurance for real decisions.** All modules run locally on entirely imaginary institutions, source documents, identities, and named demonstration roll calls. No official mode exists; no real identities or ballots should enter the backend.

## Get started

Requires Node.js >=22.13 (built-in experimental `node:sqlite`); no npm runtime dependency.

```bash
cd projects/commonwealth-os/apps/server
npm test
npm run seed  # prints fictional tokens, once, after ensuring database does not exist
npm start     # binds 127.0.0.1:4180 only
```

The `COMMONWEALTH_DB` and `COMMONWEALTH_KEY` environment variables set local data and signing-key paths. Do not put their values into version control. Signing keys are created at file mode 0600, but that **does not** establish production key custody.

## Implemented backend scope

- `src/store.mjs`: transactional synthetically authorized commands, immutable proposal revisions, event journal, votes, idempotency, version lock, role/eligibility checks.
- `src/extended-store.mjs`: synthetic institution grant/provenance journal, source-document versioning, source attachment, cancellation, two-person publication review, immutable correction history, SQLite migration version 4, restriction to synthetic-only source URLs.
- `src/policy.mjs`: BigInt rational quorum/approval rules with basis DECISIVE / CAST / PRESENT / ELIGIBLE. Abstentions are counted according to the explicitly configured basis; no assumption about legal voting procedures.
- `verify-v2.mjs`: **independently authored implementation** of signed evidence replay and authority reconstruction. Requires separately trusted Ed25519 public key. Checks historical event-author roles, voter eligibility, epochs, source dependencies, exact threshold, distinct reviewers, and linked evidence records. A correctly signed export is not an official decision.
- `src/recertification.mjs`: institution- and source-scoped impact analysis with UNCHANGED / RECHECK_REQUIRED / UNKNOWN output.
- `adapters/mock-identity.mjs`: standalone synthetic signed identity assertion contract; it is not a production OIDC implementation and does not bypass Store authentication.
- `src/http.mjs`: authenticated JSON API, LOCAL ONLY. `POST /api/v1/commands`, `/api/v1/policies`, `/api/v1/eligibility`, `/api/v1/sources`, `/api/v1/actors/revoke`, `/api/v1/recertify`, and scoped GET item/evidence/public-preview.
- `contracts/`: OpenAPI 3.1 and JSON Schema 2020-12 contracts. External schema validation/interoperability still require review.
- `migrations/postgresql-design-only.sql`: **not implemented/tested** in PostgreSQL. Not authorized as a production migration.

## Lifecycle

`CREATE → REVISE / ATTACH_SOURCE → SUBMIT → AGENDA → BEGIN → ATTEND → LOCK → OPEN → CAST → CLOSE → REVIEW → PREPARE_PUBLICATION → REVIEW_PUBLICATION ×2 → PUBLISH_PREVIEW`.

Alternatively an authorized chair may `VOID` an active item. Published synthetic previews may be `CORRECT_PUBLICATION` into a new immutable version, which requires two new independent reviewers. All transitions are version checked and idempotent. `REVISE` resets a pending review to DRAFT.

## Verification and evidence

The HTTP `/evidence` endpoint is restricted to synthetic institutional auditors, clerks and admins. Its export includes **named synthetic ballots**, so it is never appropriate for confidential real votes. Public previews exclude that data but **do not currently implement arbitrary text redaction**; preview content MUST be fictional.

To check an exported evidence file, explicitly pin the trusted public key from a separate channel:

```bash
node verify-v2.mjs evidence.json --trusted-key independently_pinned_pubkey.pem
```

Without a pin the verifier fails closed. Synthetic signed evidence is checked for internal consistency; external legal authority, identity truth, biometric assurance, ballot secrecy, upstream source custody and real-world effect enforcement are not established.

## Tests

Run `npm test` for existing v0.3/0.3.1 tests, full v0.4 sequence, adversarial tampering re-signed by the trusted key, policy rational boundaries, source supersession, role/tenant and privacy boundaries, signed mock-identity conditions, 8-way race testing, 500 invalid commands, schema shape, API routes, and restart/WAL durability checks.

`docs/REFINEMENT_AND_RELEASE_GATES.md` documents the remaining unproved and institutional obligations. This work does not assert a complete Lean-to-Node refinement proof, production PostgreSQL integration, secure electronic election, external audit, or legally authorized pilot.
