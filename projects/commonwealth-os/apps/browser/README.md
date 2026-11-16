# Commonwealth OS browser demonstrator (synthetic-only)

No dependencies, no package installation, no production backend, no credentials.

## Run
From `projects/commonwealth-os/apps/browser`:

```bash
npm test
npm run serve
```

Visit http://localhost:4173/ . The server is intended for **local development only**.
The standalone ES-module application uses plain browser APIs. Exporting a file digest requires a secure context (localhost/HTTPS).

## Architecture
- `core.mjs`: pure 10-check procedural evidence evaluator. Tri-valued: PASS / FAIL / UNKNOWN; any FAIL rejects; otherwise UNKNOWN yields indeterminate.
- `fixtures.mjs`: fictional union, student-senate and municipality authorities, motions, voters and scenarios. All are nonbinding.
- `app.mjs`: accessible, responsive inspection UI with scenario switching and evidence JSON export.
- `tests/core.test.mjs`: deterministic positive, negative, unknown, threshold and cross-profile isolation tests.

This **does not implement real electronic voting**: everything happens client-side, fixtures are untrusted, and a browser can tamper with them. SHA-256 is integrity metadata for exported bytes, **not** a signature, independent verification, or source authentication. Evidence status is *SUPPORTED_IN_SIMULATION*, never *certified*.

## Production transition (not implemented)
1. Server API, PostgreSQL transactional store, mandatory tenant isolation / database RLS, server-owned roster and attendance, OIDC/passkeys and RBAC/ABAC.
2. Signed authoritative append-only event journal, immutable rule/motion revisions, concurrency/idempotency controls and secure ballot handling.
3. Separate standalone verifier implementation and adversarial provenance tests; custodian validation for legal rule bindings.
4. Authorized partner review, privacy and accessibility evaluation, publication controls, and security audit.
5. Only then consider an institution-specific approval for consequential decisions. Official voting and municipal source ingestion remain DISABLED.

See `../../architecture/BROWSER_FOUNDATION_v0_2.md` for design boundaries.

## Comprehensive static browser workspace v1.1

This canonical source app now mirrors `docs/commonwealth-browser/` byte-for-byte for `index.html`, the original checker, and the new comprehensive workspace assets. The existing 10-check procedural evidence core and export/verification remain unchanged.

The additional `workspace.mjs` UI provides the three full 24-question **unvalidated** research instruments, opt-in browser-memory-only responses, a fictional birth-to-present representation timeline (with arbitrary intervals and nonpersonal research modes), exact recorded motion/term/seat joins, source-coverage gaps, public evidence records and non-operational steward gates. The purely synthetic `historical-fixtures.js` is a local copy of `docs/commonwealth-intelligence-fixtures.js` so development and public preview resolve relative paths within their own directories.

Run tests with `npm test` from this directory. See [Product Design v1.1](../../product-design/v1.1/README.md) and the [web workbench handoff](../../../../docs/commonwealth-browser/README.md).

**Not implemented:** real record import, historical geography authentication, real DOB/address profile, persistent personal civic data, legal authority, secure ballot custody or a production frontend/backend. A simulated recorded official is not a real elected official.

## Participation v1.2 — proposal to accountability

[New end-to-end synthetic design and limits](PARTICIPATION_V1_2.md). The browser now supports fictional proposal drafting, transparent deliberation, written amendment review with full revision history, nonbinding advisory responses tied to exact revisions, mandatory rationales for simulated institutional responses, milestone/correction tracking, meeting-agenda examples, and a ceiling-constrained participatory budget planner. It links related fictional topics to the separate dated historical-roll-call workspace while preserving precise status and uncertainty.

All actions remain **local browser state only**. A freely selectable `DEMO_STEWARD` is not an authenticated administrator; no collective ballots, moderation, real government records, cryptographic proof of locally edited proposals, real budgets, or institutional deployment are implemented. The existing ten-check synthetic Proof Passport checker is unchanged and **does not validate locally edited proposals**. Source and mirrored GitHub Pages modules are kept byte-identical and the new pure reducer is separately tested.


## Optional localhost-backed synthetic participation (v1.3)

The public GitHub Pages browser remains fully in-memory and requires no account. To exercise **durable fictional** proposals, amendments, discussion, reasoned decisions, corrections and steward-reviewed budget slates, start the existing Node demo service in `../server` (Node >=22.13): `npm run seed` once on a fresh fictional database, then `npm start`. Open **http://127.0.0.1:4180/demo/**, select **Connect local demo**, and paste one fictional token printed by the seed script.

The server serves the same comprehensive browser assets from its **localhost-only** origin; this is not a public remote API. It uses the existing role/tenant-scoped token and SQLite transaction infrastructure, optimistic state versions and idempotency keys, plus an immutable-append event journal whose consistency is checked by replay. Individual advisory/issue-question responses are **never sent** to that server: they remain in page memory. The client sends fictional proposals, comment text and amendment reasons to the local SQLite store when connected—do not enter real information. A `DEMO_STEWARD` UI switch never grants server permissions.

What stays outside scope: distributed collaboration, production identity, remote-hosting/CORS, public political-profile storage, authenticated House/Senate votes, lawful legislative/election authority, external evidence anchors, independent security audit and municipal import. Static GitHub Pages cannot connect to localhost with these tokens. See `../server/README.md` and `docs/commonwealth-browser/README.md` for the technical boundaries.
