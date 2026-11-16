# Current-main implementation reconciliation and recovery gate — v1.1

This file records a source-backed observation, **not** a claim that full historical functionality is currently present in the Python app. The baseline audited was GitHub main at **c562a76821d95aaa40d3db794b371e5c788f49ad** on November 15, 2026 (U.S. Eastern). Refresh this checkpoint on every future integration.

## Main component inventory

| Component | Source on main at checkpoint | What is verified present | Do not claim |
|---|---|---|---|
| Frozen product design | product-design/v1.0/ and MANIFEST.json | 14 archived design docs and concept prototype | That v1.0 accurately reflects every later implementation |
| Legislative Python demo | app/main.py, app/static/app.js, workflow/ | v0.1-style fictional legislative cycle, version-locked simulated votes and internal replay | That Python main currently includes civic.py, app/history.py or full v0.2/v0.3 screens |
| Historical Python engine | historical/README.md, historical/api.py and fixtures | Independent, read-only, fixture-only House/Senate/municipal history API and synthetic Living Voter frontend | Production official importer, personal birth/residence matching, or one unified app |
| Website civic intelligence | docs/commonwealth-intelligence.html and .js | Browser-local synthetic historical roll calls, correspondence and civic experience | Authenticated profiles, complete official source coverage or server-side custodial history |
| Node transactional demo | apps/server/README.md | Local-only synthetic authenticated-token test server, signed demo evidence and separate verifier | Real institutional IdP, legally binding votes or public deployment |
| Browser procedural demo | apps/browser/README.md | Read-only simulated 10-check evidence UI, no production backend | Same authority contract/API as the Python or Node workbenches |
| Formal assurance | assurance/README.md | Finite abstract claims, pinned Lean declarations and author-side audits with limits | Government legal source verification or fully safe deployed action mediation |

### Material regression / branch-integration gap

Historical representation PR [#629](https://github.com/d3lefts/d3lefts/pull/629), merged as **fe49bedad20d958622c8e96075f5f83faefb3395**, had added app/history.py, app/data/history_synthetic.json, its fixture builder, history tests and Representation UI. Earlier synthetic app PR [#619](https://github.com/d3lefts/d3lefts/pull/619), merged as **71f1f0264350a70c0b9680c844db63b09221255a**, had added civic, authority, attestation, questionnaire fixtures and tests.

A direct comparison of **fe49bedad20d958622c8e96075f5f83faefb3395 → audited main c562a76821d95aaa40d3db794b371e5c788f49ad** shows those Python modules and their tests as **REMOVED**; current app/main.py and app/static/app.js use an earlier v0.1-style API/navigation. The historical v0.3 **contract document remains**, but its specific app implementation no longer satisfies the contract. These observations must block any claim that the integrated Python app still passes the earlier 79-test path. Do not assume deletions were accidental or restore them blindly: later branches may have different architecture decisions and need an explicit reconciliation review.

**Not a total loss:** historical/ is a different maintained synthetic fixture/engine; the website hosts separate synthetic intelligence views. These do not fill the original app v0.3 integration or authenticated birth/residence requirement without adapter work.

## Resolve via controlled technical work

1. Inventory the current main paths and relevant merged PRs; preserve immutable before/after SHAs and branch provenance. Determine why former modules were removed and what replaced them.
2. Agree one canonical product host and one authority contract across Python app, Node server, browser prototype and historical/ (or formally keep independent workbenches with published compatibility adapters). Do not splice in source files without verifying permissions, data boundaries and data model agreement.
3. Establish typed compatibility contract: institutional identity, roles, session/ballot state, history query, issue correspondence, source custody, source-version status, public release, private profile isolation.
4. Reintegrate synthetic historical representation into the chosen Living Voter navigation with birth-date default and any-date range; maintain the separately tested source fixture engine.
5. Reinstate audited v0.2 functions where still desired: questionnaire responses, consent, budget, authority grants and signed receipt verification. Avoid regenerating fake institutional authority as though it were authenticated.
6. Add cross-stack contract tests (same fictional tenure/rollcall data yields matching typed outcomes) and end-to-end browser/server tests using actual UI network requests when network testing is supported.
7. Include adversarial cases for stale authority, source conflicts, malformed dates/intervals, voice-vote gaps, persona privacy, item-mapping invalidity and redistricting.
8. Explicitly hold OFFICIAL voting and real-data connectors disabled. Update current status/gates only after test artifacts are available on the new main commit.

## Merge/readiness acceptance

- No deletion of frozen v1.0 design; no stale manifest checksum.
- Current main exposes the intended Representation screen/API, demonstrated by CI on that head, not a historical PR screenshot.
- Full fake-proposal legislative loop continues to pass after integration.
- Birth-to-present personal history and any-era current-seat/research semantics tested against same source fixture.
- Server privacy tests demonstrate no DOB/address/individual constituent answers in public projections.
- Independent checker and source-provenance rules fail closed on missing/changed evidence.
- Cross-tenant boundaries and revocation under concurrent commands are exercised.
- No deployment/production or official-electoral authority without external approvals.
- A genuine issue is created or existing [P0 issues #623–626](https://github.com/d3lefts/d3lefts/issues?q=is%3Aissue+is%3Aopen+label%3ACommonwealth) are updated to own the work; no ambiguous "complete" status.

## Verification method for this document

The conclusions above were grounded by connected GitHub read: current main files, merged PR #619/#629, compare of historical merge SHA to main, the standalone historical README, the product site source and system status register. **No new CI execution, external security review, actual source ingestion or on-device user study was performed in this documentation update.**
