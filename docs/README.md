# NIGHTFALL public research website

Static, dependency-free site for NIGHTFALL’s **original, inspectable research contributions**. The broader public GitHub repository is retained as the attributed historical research archive.

- `index.html` — curated original-findings portfolio and open reviews.
- `agenda.html` and `agenda.js` — separate five-discipline research agenda with ten untested proposals.
- `observatory.html`, `observatory.js`, `observatory.css`, `observatory-data.json` — experimental evidence-graph UI; Gate D release is blocked until independent replication and controlled evaluation.
- Discovery Engine: discovery.html, discovery-core.js, discovery-app.js, discovery.css — executable bounded proxy lab and portable evidence workspace.
- `review.html` — three review assignments for the approved original contributions.
- `evidence.html` — reproducibility archive hashes, evidence-access status, desktop release steps.
- `sitemap.xml` — direct site page discovery.
- `site.css` — responsive layout and accessible typography.
- `site.js` — three-item originality-approved research index and category filtering.
- `favicon.svg` — original geometric identity.
- `.nojekyll` — permit direct static publishing without Jekyll processing.

## Publish through GitHub Pages

On `d3lefts/d3lefts` select **Settings → Pages → Build and deployment → Deploy from a branch → main → /docs → Save**. The expected project URL after GitHub processes the deployment is:

`https://d3lefts.github.io/d3lefts/`

GitHub Actions confirms successful Pages deployments on 2026-10-28. Direct public browser rendering remains an additional check. A separate [static-site verifier](../scripts/check_site.py) automatically checks local links, anchors, researcher-source paths, page metadata, and consistency of the HTML and JavaScript research indexes. Its GitHub Actions workflow runs on updates and pull requests.

## Needed for independent referees

1. **GitHub Issues has been enabled and four external-review invitations are live**: [#1 Erdős](https://github.com/d3lefts/d3lefts/issues/1), [#2 Werner](https://github.com/d3lefts/d3lefts/issues/2), [#3 finite-field](https://github.com/d3lefts/d3lefts/issues/3), [#4 AI safety](https://github.com/d3lefts/d3lefts/issues/4).
2. Mirror the large proof bundles, witness arrays, and exact-checker inputs through [the frozen-release upload task](https://github.com/d3lefts/d3lefts/issues/5). The [evidence page](evidence.html) gives verified SHA-256s, and the [ready-to-paste release description](../research/nightfall/RELEASE_NOTES_FOR_UPLOAD.md) documents claim scope. The current GitHub text mirror remains incomplete.
3. Keep the claim-status ladder and external source dependencies accurate whenever a reviewer reports a counterexample or correction.

The design takes inspiration from editorial research portfolios, while its layout, identity, copy, and review-oriented content are original to NIGHTFALL. All third-party links and mathematical source authors retain their proper attribution.

## Maintenance

Run `python3 scripts/check_site.py`, `node --check docs/site.js`, and `node --check scripts/site_browser_smoke.mjs` at the repository root before updating the live site. The website CI additionally runs headless Chromium checks at mobile and desktop widths, including menu interactions and research filtering. GitHub's workflow [Verify research website](../.github/workflows/verify-site.yml) enforces both on relevant pushes and pull requests. This is **a website-integrity check**, distinct from the mathematics, source SDPs, and external peer review.


## Public originality filter (effective 28 October 2026)

The **site includes only distinct original contributions**: the 131,072-cell exact Erdős upper witness, the concrete 30-point Sidon finite certificate, and the bounded adverse 20-case Proof After Scarcity experiment. These are original *artifacts and measurements*; each has explicit scope, and no worldwide publication-priority claim is implied. See [full originality sweep](../research/nightfall/SITE_ORIGINALITY_AUDIT_20261028.md).

**Excluded from the original-findings catalogue:** standalone AI-safety and Werner atlas pages, untested proposals promoted as results, recycled tensor-network encodings, classical erasure-reliability claims, source-dependent candidate theorems, and broader unreviewed research-manuscript marketing. Earlier public GitHub records remain with source credit and retractions/novelty corrections; the Pages portfolio and source archive intentionally have different inclusion rules.

The [static site verification script](../scripts/check_site.py) maintains a strict allowed-artifact whitelist. Its gate protects presentation consistency; a dated external prior-art comparison is still required before approving new mathematical novelty.

## Agent-first verification

The verification system uses independent agent roles and deterministic outputs rather than human recruitment. The [protocol](../research/nightfall/AGENT_VERIFICATION_PROTOCOL.md), [machine-readable tasks](../research/nightfall/AGENT_TASKS.json), [fresh exact checker](../scripts/verify_erdos_independent.py) and [release-triggered replay workflow](../.github/workflows/verify-frozen-release.yml) are versioned. Machine checks remain scoped to their explicit mathematical assertions; source premises and global analytic lemmas are separate proof gates.

## Future research and safe releases

The [Research Agenda](agenda.html) contains two untested investigations each in Mathematics, Quantum, Super Intelligence, Safety, and Systems. Proposal entries never enlarge the original-findings whitelist. Site changes should be made on topic branches with green PR checks. Workflow concurrency cancels stale checks. A GitHub branch ruleset is required to enforce PR-only merges; see [contributing guide](../CONTRIBUTING.md).

## Observatory scientific preview

The site prototype contains five progressively enhanced investigations: Scope Boundary, Evidence Trace, Transfer Explorer, Failure History, Research Frontier. Its data originates in `research/nightfall/observatory/claims-v1.json` and is copied byte-for-byte to `observatory-data.json` at the scoped release commit. Claims have frozen identity hashes and typed evidence relations enforced by `scripts/verify_observatory.py`.

**Release restraint:** A mechanical integrity pass alone is insufficient. Gate B (independent exact reproduction from complete public artifacts) and Gate C (a frozen matched-budget graph-assisted versus flat-source experiment) remain pending. The Observatory is presently a branch PR preview; the public site stays on Original Findings until release Gate D is satisfied.
