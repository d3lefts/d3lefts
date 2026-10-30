# NIGHTFALL — measured loading performance, 29 October 2026

**Outcome:** Baseline captured and repeatable performance CI installed. An optimization that preloaded the nested light-theme stylesheet was *rejected* after worsening the observed results. No claim of improved loading speed is made.

## Reproduction

- [Baseline run #40983257519](https://github.com/d3lefts/d3lefts/actions/runs/40983257519): source commit `027e346179eae034341dee9e7a8d6ed8a7df2935`, 24 cold-load samples, unmodified design. [Machine-readable artifact](https://github.com/d3lefts/d3lefts/actions/runs/40983257519/artifacts/12946071085).
- [Preload experiment #40983657826](https://github.com/d3lefts/d3lefts/actions/runs/40983657826): source commit `63548b80e2886db5b665b46cd024198273159166`, same 24 scenarios with `rel=preload` for `golden-hour-light.css` on all three primary routes. [Trial artifact](https://github.com/d3lefts/d3lefts/actions/runs/40983657826/artifacts/12945599090).
- Code: `scripts/profile_loading.mjs`. CI: `.github/workflows/profile-loading.yml`. Chrome via pinned `playwright-core@1.56.1` on GitHub-hosted Ubuntu. Raw JSON and terminal log archived for 90 days on each run.

**Lab conditions.** Two independent cold-cache samples per route × viewport × stored visual theme (24 navigation samples per checkpoint). Local HTTP server serves the actual committed `docs/` bytes with `Cache-Control: no-store`. Mobile: 390 × 844, device scale 2, 4× CPU throttle, 110 ms RTT, 1.6 Mbps download. Desktop: 1440 × 900, 1× CPU, loopback no network shaping. Chrome DevTools Protocol records same-origin encoded transfer and response waterfall; PerformanceObserver records FCP, last observed LCP, CLS and long tasks. A scripted 75-frame scroll sample records script/style/layout CPU deltas and frame gaps on the homepage. `FCP` below is the median of two samples, **not** a field percentile.

## Baseline

| Page | Local requests | Local encoded bytes | CSS bytes | CSS share | Mobile New Moon FCP | Mobile NULL FIELD FCP | Desktop New Moon FCP |
|---|---:|---:|---:|---:|---:|---:|---:|
| Homepage | 17 | 357,490 | 254,571 | 71.2% | 2,336 ms | 2,244 ms | 388 ms |
| Constellation | 13 | 299,696 | 223,788 | 74.7% | 1,888 ms | 1,916 ms | 194 ms |
| Independent Review | 9 | 244,973 | 210,766 | 86.0% | 1,538 ms | 1,538 ms | 202 ms |

Largest homepage transfers in this profile: `site.css` (~64.7 KB), `ethereal-theme.css` (~49.3 KB), `two-skies.css` (~45.5 KB), document HTML (~40.5 KB), `research-registry.js` (~33.3 KB), `golden-hour-light.css` (~26.8 KB), and `home-opening-cinema.css` (~25.7 KB).

**Scroll observation:** no frame > 50 ms among the 75 sampled mobile frames under either theme. Sampled New Moon script+style+layout CPU total 14.5 ms; NULL FIELD 16.2 ms. The benchmark scrolls in scripted frame steps; it is no substitute for direct low-end-device touch-scroll testing.

## Falsified preload candidate

Adding an early preload for the secondary light stylesheet preserved request counts and transferred essentially identical bytes. It **did not improve** median FCP. Measured mobile FCP (baseline → trial):

| Page | New Moon | NULL FIELD |
|---|---|---|
| Homepage | 2,336 → 2,556 ms (+220 ms) | 2,244 → 2,342 ms (+98 ms) |
| Constellation | 1,888 → 2,046 ms (+158 ms) | 1,916 → 2,042 ms (+126 ms) |
| Independent Review | 1,538 → 1,718 ms (+180 ms) | 1,538 → 1,712 ms (+174 ms) |

Desktop FCP also rose in all six combinations (34–154 ms). Two repetitions on separate ephemeral CI runners are insufficient to attribute the differences causally to preload versus worker variance, network scheduling or other process noise. **Decision:** revert all three preloads. The site carries no speculative optimization from this experiment.

## Interpretation and remaining work

1. The main structural cost is **shared render-blocking CSS**, accounting for 71–86% of measured same-origin byte transfer. The nested light-theme CSS import and external Google Fonts import deserve separate controlled waterfall and CDN tests before delivery changes.
2. The local server deliberately ships **uncompressed files** and the same-origin byte total excludes third-party font requests. These figures do **not** represent production gzip/Brotli transfer, real-user Core Web Vitals, CDN cache hit rates or geographic latency. Run a production-origin check and field RUM only with explicit scope and privacy controls.
3. No strong animation bottleneck appeared in this synthetic 75-frame sample; preserve both cinematics unless a low-end real-device trace reveals a concrete issue.
4. Future changes must pass the existing cross-theme, responsive, keyboard, evidence-preservation and reduced-motion browser suites. The performance workflow records each changed deployment's actual measured costs instead of enforcing unstable arbitrary FCP thresholds.

**Scientific status:** unrelated to this web performance experiment; no claim evidence, verifier, value, publication decision or originality status was changed.
