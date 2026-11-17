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


## Guided civic experience (fictional, frontend-only)

The browser entry now begins with a role-specific interactive demonstration: **Resident** (sample answer and explicitly invented viewpoint positions), **Representative** (illustrative accountability path), and **Developer** (read-only Commonwealth Connect *concept*, not a live MCP endpoint). All three share a five-step fictional source-to-follow-through explainer. The original Chamber, participation, questionnaires, historical intelligence, and independent procedural checker remain available below unchanged.

- `experience-core.mjs`: fixed sample case and pure validation helpers; `experience.mjs`: progressive enhancement and ephemeral page-memory controls; `experience.css`: scoped civic presentation.
- `tests/experience-core.test.mjs`: roles/choices, arithmetic, gap states, no-persistence and entrypoint tests. The files are mirrored byte-for-byte under `docs/commonwealth-browser/`.
- **Trust boundary:** no real participants, municipal records, polls, ballots, sampling, political profiles, endpoint, source authentication or decision authority. Invented viewpoint counts do not represent real-world agreement or feed existing proposals. The page does not implement an MCP server; all links refer to the existing synthetic workbench.
