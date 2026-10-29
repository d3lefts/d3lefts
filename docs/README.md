# NIGHTFALL public research website

Static, dependency-free site for NIGHTFALL’s **three evidence-scoped original findings, three flagship research programs, and a broader 32-document curated research library**. The repository retains the full attributed historical research archive.

- `index.html` — three flagship research programs with explicit evidence tiers, plus the three approved original findings and open reviews.
- `research.html` / `research.js` — 32 curated, source-linked September–October research lines in Mathematics, Quantum, Safety and Systems, with discipline filters, search, and explicit scope boundaries; broader than the Original Findings whitelist.
- `agenda.html` and `agenda.js` — separate five-discipline research agenda with ten untested proposals.
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

## Additional exact quantum and finite-field tools

The [Exact Research Tools](exact-research.html) workbench complements Claim Lab's manual records and the owner's exact overlap/Sidon [Referee](referee.html). It supports a bounded four-qutrit integer rank-two witness verifier and exhaustive F25 fourth-power phase-ambiguity enumeration. JSON receipts are local finite calculations, never independent theorem certificates. All arithmetic uses BigInt or exact field operations, with independently expanded physical partial traces and browser adversarial tests.

Run `node scripts/test_research_tools.cjs` for the independent 180-entry tensor/trace comparison and full finite-field controls. Web smoke covers mobile, desktop, exact rank, negative-rank-three input warnings, F25 phase orbits, and receipt export.

## Guided visitor research journey

The [Research Tools](exact-research.html#guided-replay) hub includes a source-backed four-stage walkthrough of the finite 30-point Sidon construction: statement → live Referee run → deliberate adversarial controls → independent Python receipt replay. The domain-specific URL `referee.html?domain=sidon#workbench` opens the finite verifier with its original source fixture; unrecognized `domain` strings have no effect. All steps retain their own evidence limits. This is navigation and transparency, **not** a proof-status promotion or automated cross-tool import.

The [research instrument handoff contract](../research/nightfall/RESEARCH_INSTRUMENT_HANDOFF_20261028.md) identifies existing receipt formats and defines the release boundary required before a common bridge can link evidence to claims.

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
