# NIGHTFALL public research website

Static, dependency-free site for NIGHTFALL’s **five evidence-scoped original findings, four flagship research programs, and a broader 33-document curated research library**. The repository retains the full attributed historical research archive.

- `index.html` — four flagship research programs with explicit evidence tiers, plus five approved, source-limited original findings and open reviews.
- `desk.html` / `desk.css` / `desk.js` — internal, local-first Research Desk: six registry-driven evidence records, open mathematical obligations, session notes, scoped handoff exports and independent verifier routes; never upgrades theorem status.
- `research.html` / `research.js` — 33 curated, source-linked September–October research lines in Mathematics, Quantum, Safety and Systems, with discipline filters, search, and explicit scope boundaries; broader than the Original Findings whitelist.
- `agenda.html` and `agenda.js` — separate five-discipline research agenda with ten untested proposals.
- Discovery Engine: discovery.html, discovery-core.js, discovery-app.js, discovery.css — executable bounded proxy lab and portable evidence workspace.
- `review.html` — three core reviewer checklists plus two additional source-scoped finite reviews; other flagship theorem candidates retain separate proof gates.
- `evidence.html` — reproducibility archive hashes, evidence-access status, verified public download links and reproducible commands.
- `sitemap.xml` — direct site page discovery.
- `site.css` — responsive layout and accessible typography.
- `site.js` — legacy three-entry inline research index (distinct from the homepage's five approved Original Findings); category filtering. The newer two findings have their own sourced publication page and reviewer invitations.
- `favicon.svg` — original geometric identity.
- `.nojekyll` — permit direct static publishing without Jekyll processing.

## Publish through GitHub Pages

On `d3lefts/d3lefts` select **Settings → Pages → Build and deployment → Deploy from a branch → main → /docs → Save**. The expected project URL after GitHub processes the deployment is:

`https://d3lefts.github.io/d3lefts/`

GitHub Actions confirmed a successful Pages deployment after the curated release on 2026-10-29. Direct public browser rendering remains an additional check. A separate [static-site verifier](../scripts/check_site.py) automatically checks local links, anchors, researcher-source paths, page metadata, and consistency of the HTML and JavaScript research indexes. Its GitHub Actions workflow runs on updates and pull requests.

## Needed for independent referees

1. **GitHub Issues has been enabled and four external-review invitations are live**: [#1 Erdős](https://github.com/d3lefts/d3lefts/issues/1), [#2 Werner](https://github.com/d3lefts/d3lefts/issues/2), [#3 finite-field](https://github.com/d3lefts/d3lefts/issues/3), [#4 AI safety](https://github.com/d3lefts/d3lefts/issues/4).
2. The [two approved curated ZIPs](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28) are public. Run `python3 scripts/download_nightfall_curated_assets.py public-assets` for fresh anonymous downloads with complete manifest checks. The [evidence page](evidence.html) links both assets and the exact replay. Historical master ZIPs remain private; do not ask the owner to upload them.
3. Keep the claim-status ladder and external source dependencies accurate whenever a reviewer reports a counterexample or correction.

The design takes inspiration from editorial research portfolios, while its layout, identity, copy, and review-oriented content are original to NIGHTFALL. All third-party links and mathematical source authors retain their proper attribution.

## Additional exact quantum and finite-field tools

The [Exact Research Tools](exact-research.html) workbench complements Claim Lab's manual records and the owner's exact overlap/Sidon [Referee](referee.html). It supports a bounded four-qutrit integer rank-two witness verifier and exhaustive F25 fourth-power phase-ambiguity enumeration. JSON receipts are local finite calculations, never independent theorem certificates. All arithmetic uses BigInt or exact field operations, with independently expanded physical partial traces and browser adversarial tests.

Run `node scripts/test_research_tools.cjs` for the independent 180-entry tensor/trace comparison and full finite-field controls. Web smoke covers mobile, desktop, exact rank, negative-rank-three input warnings, F25 phase orbits, and receipt export.

## Guided visitor research journey

The [Research Tools](exact-research.html#guided-replay) hub includes a source-backed four-stage walkthrough of the finite 30-point Sidon construction: statement → live Referee run → deliberate adversarial controls → independent Python receipt replay. The domain-specific URL `referee.html?domain=sidon#workbench` opens the finite verifier with its original source fixture; unrecognized `domain` strings have no effect. All steps retain their own evidence limits. This is navigation and transparency, **not** a proof-status promotion or automated cross-tool import.

The [research instrument handoff contract](../research/nightfall/RESEARCH_INSTRUMENT_HANDOFF_20261028.md) records the historical receipt boundary. The subsequently merged Evidence Bridge now stages bounded receipts through preview, explicit consent, and a workspace backup, without mathematical proof-status promotion.

## Maintenance

Run `python3 scripts/check_site.py`, `node --check docs/site.js`, and `node --check scripts/site_browser_smoke.mjs` at the repository root before updating the live site. The website CI additionally runs headless Chromium checks at mobile and desktop widths, including menu interactions and research filtering. GitHub's workflow [Verify research website](../.github/workflows/verify-site.yml) enforces both on relevant pushes and pull requests. This is **a website-integrity check**, distinct from the mathematics, source SDPs, and external peer review.


## Public originality filter (effective 28 October 2026)

The **homepage Original Findings index** includes only distinct original contributions: the 131,072-cell exact Erdős upper witness, the concrete 30-point Sidon finite certificate, and the bounded adverse 20-case Proof After Scarcity experiment. These are original *artifacts and measurements*; each has explicit scope, and no worldwide publication-priority claim is implied. See [full originality sweep](../research/nightfall/SITE_ORIGINALITY_AUDIT_20261028.md).

**Excluded from the original-findings catalogue:** standalone AI-safety and Werner atlas pages, untested proposals promoted as results, recycled tensor-network encodings, classical erasure-reliability claims, source-dependent candidate theorems, and broader unreviewed research-manuscript marketing. Earlier public GitHub records remain with source credit and retractions/novelty corrections. The owner-approved, four-category public research library includes carefully labeled conditional manuscripts, reproducible code, rigorous negative results and empirical studies; inclusion does not upgrade any manuscript to an original certified theorem.

The [static site verification script](../scripts/check_site.py) maintains a strict allowed-artifact whitelist. Its gate protects presentation consistency; a dated external prior-art comparison is still required before approving new mathematical novelty.

## Agent-first verification

The verification system uses independent agent roles and deterministic outputs rather than human recruitment. The [protocol](../research/nightfall/AGENT_VERIFICATION_PROTOCOL.md), [machine-readable tasks](../research/nightfall/AGENT_TASKS.json), [fresh exact checker](../scripts/verify_erdos_independent.py) and [release-triggered replay workflow](../.github/workflows/verify-frozen-release.yml) are versioned. Machine checks remain scoped to their explicit mathematical assertions; source premises and global analytic lemmas are separate proof gates.

## Future research and safe releases

The [Research Agenda](agenda.html) contains two untested investigations each in Mathematics, Quantum, Super Intelligence, Safety, and Systems. Proposal entries never enlarge the original-findings whitelist. Site changes should be made on topic branches with green PR checks. Workflow concurrency cancels stale checks. A GitHub branch ruleset is required to enforce PR-only merges; see [contributing guide](../CONTRIBUTING.md).

## Site-owner polish (October 28, 2026)

The homepage now reflects the owner-approved 32-document research library. Shared navigation is consolidated around Research, Library, Tools, Review, Evidence, and Source archive, with a compact workflow bridge to the existing Research Tools hub. The library supports combinable discipline, evidence-tier, and text filters, plus keyboard shortcuts (/ to focus search, Escape to clear). The Original Findings whitelist remains exactly three. New browser regressions validate current counts, tool discovery, and evidence filters.


## October 28: owner-approved 32-document breadth

Eight overlapping library cards were replaced by distinct source records spanning one-way automata, the degree-restricted UP25 exclusion, first-autocorrelation integer verification, Zerothesis support births, research-methods history, autonomous verification, the PAS 372-family freeze, and a controlled adaptive-granularity experiment. The two added cards cover BB(6) arithmetic return maps and the conditional minimum-overlap fixed-dual lower-bound audit. Full prior Werner-stage reports and AI safety manuscripts remain in GitHub even when their individual promotional cards have been replaced.

The public library preserves **15 Mathematics, 4 Quantum, 6 Safety, 7 Systems** entries; three homepage flagships and the three-entry Original Findings whitelist are unchanged. Source-specific mathematical assumptions, inherited source artefacts, and negative-result limitations remain in each card. See [the editorial change ledger](../research/nightfall/SITE_CURATED_32_EDITORIAL_CHANGELOG_20261028.md).

### Fourth flagship (29 October 2026)

[Axiom's deterministic adaptive finite-field decoder](../research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/README.md) now has a homepage flagship card, a separately scoped Proof Passport and independently reproducible exact finite checker. The improved extension-degree batched decoder needs k+⌈(k−1)/(r−1)⌉ queries and is globally optimal at k+1 for 2≤k≤r and q>2. The adaptive two-round model remains distinct from the conditional random nonadaptive fourth-power lattice-decoding track. Publication priority and external mathematical proof review remain open.

## Finding and evidence-count reconciliation (2026-10-29)

**Publication layers:** 33 library dossiers, six canonical Proof Passports, and five approved *source-scoped* Original Findings. The three legacy inline index rows in `site.js` are a historical subset and must never be interpreted as the complete approved findings count. The other two are described in [`findings-20261029.html`](findings-20261029.html) and reviewed under [`review.html#new-finite-reviews`](review.html#new-finite-reviews). Their publication addendum is [`SITE_ORIGINALITY_ADDENDUM_20261029.md`](../research/nightfall/SITE_ORIGINALITY_ADDENDUM_20261029.md).

The two approved curated binary archives were released and anonymously verified on 2026-10-29. See [`evidence.html`](evidence.html), [the GitHub Release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28), and [`CURATED_PUBLIC_DOWNLOAD_RECEIPT_20261029.json`](../research/nightfall/CURATED_PUBLIC_DOWNLOAD_RECEIPT_20261029.json). Historical master ZIPs stay private and the accepted Arena #2628 payload remains separately unresolved under issue #6. A successful internal arithmetic replay cannot replace outside mathematical peer review.
