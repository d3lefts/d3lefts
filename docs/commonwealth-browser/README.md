# Commonwealth OS — Comprehensive Synthetic Browser Workspace v1.1

**Scope:** static GitHub Pages browser app, built on the existing ten-check procedural checker. **Not a binding voting system.** This is an independently scoped synthetic browser demo, not the Python app, Node authority server, or an integrated production backend.

## Running

Open `docs/commonwealth-browser/index.html` through a local HTTP server or the repository's GitHub Pages deployment. It loads local ES modules and its only historical data source is `./historical-fixtures.js`, a static synthetic snapshot mirrored from `docs/commonwealth-intelligence-fixtures.js`. No external API requests, storage, real civic identities, DOB or address collection, analytical beacons, or official ballots are added by this feature.

The existing procedural checker and its evidence download/local digest check remain intact. Its digest is not a legal certification, signature or independent source authentication.

## Workspaces added

1. **Chamber:** original procedural-checker fixtures (fictional union, student senate, municipality). This is not the actual university/HOA/municipal participation questionnaire.
2. **Issue questions:** full 72 draft seed questions across UAH, HOA, HSV (24 each), extracted from the 2026-11-15 Commonwealth Civic Pilots research package. User answers exist only in JS memory; Support, Do not support, No preference, Need information, Not applicable and Skip are distinct. Not certified for legal applicability or neutral wording.
3. **Representation:** hypothetical date-effective residence/seat/tenure joins for fictional House/Senate/municipal analogues. Default date begins at **fictional** DOB 2000-05-09. Arbitrary date windows, personally represented/current-seat/research modes, group and issue filters, bounded paginated positions, typed motion/procedural status, explicit voice-vote/missing named-vote gaps.
4. **Direct issue practice:** voluntarily answer exact synthetic civic propositions; show only exact substantive side-by-side member positions, not implied support from cloture/amendments or topic-only links. No politician ranking, grade or electoral prediction.
5. **Public evidence:** per-fixture source custody and partial coverage counts. All rows are `SYNTHETIC_UNVERIFIED`, never authoritative. Data is read-only and solely fictional.
6. **Steward:** transparent authority and real-data release gates, all official and import actions disabled.

## Verification

### Pure tests

```bash
node --test docs/commonwealth-browser/tests/*.test.mjs
```

The historical join core has **12** internally tested examples and the question-bank schema has **one** test (13 new tests). Tests include redistricting-like moves, succession, multi-member Senate seats, source gaps, missing vs explicit NOT_VOTING, voice votes, arbitrary date windows, exact-only issue correspondence and duplicate seat term rejection.

### Browser smoke (author-side)

Chromium was exercised via `page.set_content` and inline script bundling for local assets, due to browser network/file navigation restrictions in the test environment. Desktop 1250px and mobile 390px functional controls, date filters, temporary questionnaire answers, issue selection, and zero horizontal overflow passed. **This is not a full static module/network-loading E2E test**; do not describe it as one. The existing procedural checker is separately covered by its own tests; the new feature does not modify `app.mjs` or `core.mjs`.

## Boundaries

- Sources: no authenticated House, Senate, Huntsville or county information; all corpus records come from `fixture://...` synthetic material.
- The demo resident is invented; no real DOB or residence is collected or inferred.
- The selected date range never proves archive completeness. When a source provides no named vote, none is fabricated.
- User selections are not voter registration, ballots, government instructions or representative endorsements.
- Public official roll calls and personal policy responses remain distinct types and privacy zones.
- Institution activation, independent source custody, legal authority, protected identity/eligibility and penetration testing are pending per `projects/commonwealth-os/REAL_DATA_MIGRATION_GATES.md`.
- Product design source: `projects/commonwealth-os/product-design/v1.1`.

## Implementation files

`workspace.mjs` implements the UI; `history-core.mjs` implements pure matching/semantics; `question-data.mjs` is the unvalidated pilot seed bank; `workspace.css` adds scoped mobile styles; original `app.mjs`, `core.mjs`, `fixtures.mjs` are unchanged. `historical-fixtures.js` is kept byte-for-byte consistent with the existing synthetic civic intelligence fixture snapshot.
## Participation v1.2 — proposal to accountability

[New end-to-end synthetic design and limits](PARTICIPATION_V1_2.md). The browser now supports fictional proposal drafting, transparent deliberation, written amendment review with full revision history, nonbinding advisory responses tied to exact revisions, mandatory rationales for simulated institutional responses, milestone/correction tracking, meeting-agenda examples, and a ceiling-constrained participatory budget planner. It links related fictional topics to the separate dated historical-roll-call workspace while preserving precise status and uncertainty.

All actions remain **local browser state only**. A freely selectable `DEMO_STEWARD` is not an authenticated administrator; no collective ballots, moderation, real government records, cryptographic proof of locally edited proposals, real budgets, or institutional deployment are implemented. The existing ten-check synthetic Proof Passport checker is unchanged and **does not validate locally edited proposals**. Source and mirrored GitHub Pages modules are kept byte-identical and the new pure reducer is separately tested.
