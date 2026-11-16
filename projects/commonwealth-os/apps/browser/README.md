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
