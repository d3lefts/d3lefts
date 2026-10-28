# NIGHTFALL public research website

Static, dependency-free site for the NIGHTFALL PHASESHIFT research archive.

- `index.html` — editorial research portfolio, filterable source index, open review invitations.
- `review.html` — four independent audit briefs, status disclaimers, and structured GitHub reporting forms.
- `evidence.html` — reproducibility archive hashes, evidence-access status, desktop release steps.
- `ai-safety.html` — September theorem/evidence series, with SourceBound evaluated separately.
- `sitemap.xml` — direct site page discovery.
- `site.css` — responsive layout and accessible typography.
- `site.js` — original source links and category filtering.
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

Run `python3 scripts/check_site.py` and `node --check docs/site.js` at the repository root before updating the live site. GitHub's workflow [Verify research website](../.github/workflows/verify-site.yml) enforces both on relevant pushes and pull requests. This is **a website-integrity check**, distinct from the mathematics, source SDPs, and external peer review.

## Agent-first verification

The verification system uses independent agent roles and deterministic outputs rather than human recruitment. The [protocol](../research/nightfall/AGENT_VERIFICATION_PROTOCOL.md), [machine-readable tasks](../research/nightfall/AGENT_TASKS.json), [fresh exact checker](../scripts/verify_erdos_independent.py) and [release-triggered replay workflow](../.github/workflows/verify-frozen-release.yml) are versioned. Machine checks remain scoped to their explicit mathematical assertions; source premises and global analytic lemmas are separate proof gates.
