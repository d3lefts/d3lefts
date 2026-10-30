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

## Remaining debt, in priority order

1. **Shared-style ownership (high).** `site.css` was ~67 KB, `ethereal-theme.css` ~49 KB and `two-skies.css` ~37 KB at the baseline; many old homepage layout selectors are still defined inside these global stylesheets. Delete them only after identifying all owning pages and checking computed styles in both themes and at narrow widths. Do not bulk-purge CSS based solely on selector text.
2. **Navigation controllers (medium).** `site.js` still creates guided return rails and the three-destination path on specialist pages. Consolidate logic only with deep-link, saved obligation, keyboard, no-script, and independent-review journey tests.
3. **Repeated source catalogues (medium).** The static original-results whitelist, Proof Passport registry, curated research library, and publication ledgers serve distinct evidentiary purposes yet overlap in labels and summaries. Replace duplicated rendering only with a source-verified migration plan; preserve originality and evidence gates.
4. **Page delivery measurement (medium).** Capture actual first-load requests, transfer sizes, long-task counts, cumulative layout shift, and scroll animation costs before introducing bundlers, minifiers, or lazy-loading core checkers. Preserve the dependency-free static deployment unless measurement supports the change.
5. **CI cost and coverage (lower).** Several workflows repeat browser checks and candidate evidence audits. Measure job duration and identify safe sharing/caching opportunities without weakening independent arithmetic and release-scope checks.

## Change-control policy

- Cosmetic work and parallel research PRs remain independently mergeable; theme tokens, cinematics, mathematical witness data, and claim statuses are intentionally untouched here.
- Do not equate fixture passes with independent scientific review.
- New homepage panels must justify their added network request and demonstrate why the material cannot live in Constellation, Independent Review, or the research library.
- The maintenance gate is a minimum asset budget, not a prohibition on necessary dependencies: raise it only with a tested explanation and a source-linked review.
