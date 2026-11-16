# Commonwealth OS — Participation & Accountability v1.2

**Synthetic, static browser demonstration only**; not a real public consultation, deliberation service, election, government record importer or institutional administration system. No real people, ballots, budgets, civic records, addresses or government permissions are used. All locally entered text/choices are held only in browser memory and cleared on refresh. No API, cookies, LocalStorage, server or third-party data calls are introduced.

## Competitor-parity capabilities (within scope of a local demonstration)

- Proposal docket: search/filter, create draft, inspect exact text version and lifecycle status, institution-scoped synthetic UAH/HOA/municipal cases.
- Public deliberation **simulation**: add comments classified as question, support or concern; fictional reviewers can answer each individually with a reason. Unanswered concerns are counted and remain visible; real moderation is still absent. No actual cross-user collaboration or moderation service.
- Amendment review: submit an alternative text and reason; fictional steward may accept or decline with a written explanation. Accepting increments the revision, invalidates prior-revision advisory positions and supersedes competing outstanding amendments.
- Voluntary advisory stance for the **exact displayed revision**, with Unknown ≠ No preference, no ballot/identity/representative claim.
- Decision feedback: a fictional institution must provide a reasoned transition; accepted/declined/review stages never silently disappear. Local demo steward mode does not confer real authority.
- Implementation monitoring: milestones are monotonic, documented, reviewable. Completion requires 100% progress; locally filed corrections remain UNREVIEWED_LOCAL_DEMO.
- Participatory budget planner: within-ceiling/out-of-ceiling project slate, no treasury, fiscal allocation or vote. Three fictional budgets and projects.
- Meetings: one fictional agenda per pilot and an explicit proposed offline accessibility route. No scheduling, RSVP, attendance or actual minutes.
- Public-facing dossier export: scope, version, status, response, milestone and event trace without individually written comment bodies or advisory positions. **No cryptographic signature or independent certification**.

## Commonwealth differentiators retained and connected

The new Participation view links topical issue fixtures to the existing exact historical roll-call Representation timeline and highlights source status in each case. This is a topic link, **not** an exact legal equivalence conclusion. The existing browser's independently scoped ten-check Proof Passport and SHA-256 payload export remain separate and unchanged. Do not claim the validator certified a locally edited proposal. The existing 72 draft institutional questions are preserved with unchanged nonbinding semantics.

## How to run

From `projects/commonwealth-os/apps/browser`, run `npm test` and `npm run serve`, then open `http://localhost:4173/`. The GitHub Pages mirror is `docs/commonwealth-browser/`.

Source: `participation-core.mjs` (pure reducer, fixture data and budget logic), `participation-ui.mjs` (DOM, form and in-memory controls), `participation.css` (responsive styling), and `tests/participation-core.test.mjs` (standalone Node assertions). The global browser page remains `index.html`; original `app.mjs`/`core.mjs` and `workspace.mjs` continue to provide existing workspaces.

## Evidence, exclusions, and defects to test next

Tests of the new reducer include 17 cases for institution separation, version semantics, stale amendments, transitions, budget caps, corrections, and public-export privacy. Separate author-side Chromium interaction tests exercised desktop and mobile layout with synthetic local fixtures and bundled scripts. They **do not verify a deployed browser with real HTTP module fetching**, nor provide independent security, identity, legal, source-authenticity, open-record completeness, moderation, publication, accessibility or election certification.

These demonstrations are **not** functionally equivalent to Decidim/CONSUL live multi-user platforms: no persistence, moderation queue, approval permissions, real budgeting allocation, authentic membership, or operational hosting exists. Future server-side work must implement these with evidence and institutional approval before enabling actual participation. Keep exact source mapping and public-roll-call custody distinct from individual private preference/identity data. UAH → other Huntsville universities → high schools → HOAs → Huntsville council remains the proposed staged research adoption sequence.

## References
- Decidim: https://docs.decidim.org/en/develop/features/components.html
- Decidim accountability: https://docs.decidim.org/en/develop/admin/components/accountability.html
- CONSUL proposals: https://docs.consuldemocracy.org/docs_general/participation-processes/citizen-proposals
- Product Design v1.1: `projects/commonwealth-os/product-design/v1.1/README.md`
