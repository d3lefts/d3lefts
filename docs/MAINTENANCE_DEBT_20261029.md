# NIGHTFALL website maintenance debt — 29 October 2026

**Status:** live product maintenance register; structural changes require the usual automated browser, scientific evidence, mobile, theme, and reduced-motion checks.

## Verified cleanups in this pass

| Surface | Before | After | Reason |
|---|---:|---:|---|
| Homepage-linked stylesheets | 8 | 7 | Retired `home-focus.css` had only six live rule groups after homepage streamlining; those rules now live in `home-rhythm.css`. |
| Homepage stylesheet source bytes (uncompressed) | 202,923 | 197,727 | One eliminated request, 5,196 fewer uncompressed CSS source bytes. Not a measured network or render-speed improvement. |
| `home-rhythm.css` | 8,022 | 6,721 | Removed rules for deleted jump directory, long findings gallery, instrumentation bridge, review disclosures, and related retired panels; preserved active Hero, Sidon, and finite-result styles. |
| `home-system.js` | 3,188 | 2,415 | Removed hydration branches for a discontinued findings gallery and evidence-history widget. Exact Sidon witness and four source-linked research programs remain canonical. |
| Homepage JavaScript requests | 7 | 7 | Preserved registry, finite checker, theme, shared navigation, and the two scroll cinematics rather than inventing an unsafe bundle. |

Figures compare the pre-cleanup checkpoint at commit `526a8984` to its matching maintenance branch. Concurrent cosmetic changes on `main` may change the absolute totals in the final deployed asset set; the difference attributable to this cleanup remains one stylesheet request and 5,196 uncompressed CSS bytes. Figures are static source counts at this dated checkpoint. They **do not** establish faster page load, Core Web Vitals improvements, smaller compressed transfers, or increased research credibility. Claim content and scientific status are outside this maintenance change.

The new `scripts/test_home_maintenance.cjs` is wired into the normal website verification. It checks asset counts and existence, canonical claim hydration, preserved navigation landmarks, and retirement of stale homepage CSS selectors. It supplements rather than replaces real-browser testing.

## Shared-architecture pass (29 October, follow-up)

This pass separates **global chrome**, **agenda-specific presentation**, and **canonical claim records**, while leaving color tokens, animation code, scientific status, and publication decisions unchanged.

- **Global script:** `site.js` now owns mobile navigation and specialist-page return/three-destination navigation only. The defunct three-card research catalogue/filter and its duplicated scientific descriptions have been removed. Safe saved claim IDs and obligation indices still control return links; malformed and unrecognized state falls back to the normal guided journey.
- **Style ownership:** Research proposal rows, status labels, responsive proposal grids and agenda-specific panels now belong to `agenda-catalog.css`, loaded only by `agenda.html`. The owning page retains its visual treatment. Other pages no longer download these agenda rules as part of `site.css`.
- **Source identities:** Six curated Proof Passport references on `research.html` now carry explicit `data-claim-id` values. `research.js` reads those IDs and consults `NightfallRegistry` for scope, links and evidence labels. This repairs missing passport cross-links caused by earlier dossier title changes, without relying on exact heading strings.
- **Regression gate:** `scripts/test_shared_architecture.cjs` verifies stylistic ownership, all six canonical IDs, absence of shadow catalogues, navigation classes, safe saved-state handling, return-link idempotence, and app-workbench isolation. The broad browser suite remains the final integration gate.

These are source and structural improvements, not measured Web Vitals gains. The shared `ethereal-theme.css` and `two-skies.css` remain intentionally in place: the dual-sky palette and cross-page theme overrides are coupled to the site’s visual verification, so speculative large-scale pruning would be a higher-risk change.

## Remaining debt, in priority order

1. **Further shared-style ownership (medium).** `site.css` was ~67 KB, `ethereal-theme.css` ~49 KB and `two-skies.css` ~37 KB at the baseline; many old homepage layout selectors are still defined inside these global stylesheets. Delete them only after identifying all owning pages and checking computed styles in both themes and at narrow widths. Do not bulk-purge CSS based solely on selector text.
2. **Navigation controller coverage (medium).** The return rail and three-destination path now share one lifecycle, route classification, and idempotent mount. Extend real-browser keyboard, hash-link, stale-storage, and tool-workbench coverage before further reduction.
3. **Provenance convergence (medium).** The dead catalogue was removed and six library-to-passport links now use stable source identities. The 33-doc editorial selection ledger, six-passport registry, and five-finding publication decisions remain intentionally separate in scope. Audit correspondence periodically, without collapsing their independent evidence thresholds.
4. **Page delivery measurement (medium).** Capture actual first-load requests, transfer sizes, long-task counts, cumulative layout shift, and scroll animation costs before introducing bundlers, minifiers, or lazy-loading core checkers. Preserve the dependency-free static deployment unless measurement supports the change.
5. **CI cost and coverage (lower).** Several workflows repeat browser checks and candidate evidence audits. Measure job duration and identify safe sharing/caching opportunities without weakening independent arithmetic and release-scope checks.

## Change-control policy

- Cosmetic work and parallel research PRs remain independently mergeable; theme tokens, cinematics, mathematical witness data, and claim statuses are intentionally untouched here.
- Do not equate fixture passes with independent scientific review.
- New homepage panels must justify their added network request and demonstrate why the material cannot live in Constellation, Independent Review, or the research library.
- The maintenance gate is a minimum asset budget, not a prohibition on necessary dependencies: raise it only with a tested explanation and a source-linked review.
