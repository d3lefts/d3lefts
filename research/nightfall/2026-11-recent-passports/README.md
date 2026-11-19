# Recent NIGHTFALL proof passports — 19 November 2026

This is a supplementary source-reconciliation register, **not a rewrite** of the frozen historical registry or the v16 active 15-claim snapshot.

Authoritative machine ledger: [docs/recent-research.json](../../../docs/recent-research.json). Public page: [recent-research.html](../../../docs/recent-research.html).

| Status | Meaning |
| --- | --- |
| Merged / named Lean | Named theorem has a cited pinned certificate and PR is merged; this does not certify novelty or an unrelated larger theorem. |
| PR-head / named Lean | Specific source branch has reported passing pinned named theorem; may not be on main. |
| Paper or exact-test candidate | A research derivation, proposed bound or finite falsifier without the full named Lean certificate. |
| Integration or compiler gate open | Composite claim or build not certified at current exact head. |

- [Finite-product degree-two influence, C₂ ≈ 105.41624](q2-c105.md) — Merged / named Lean; [PR #587](https://github.com/d3lefts/d3lefts/pull/587)
- [Aaronson–Ambainis influence on arbitrary independent products](aa-all-product.md) — Merged / named Lean; [PR #858](https://github.com/d3lefts/d3lefts/pull/858)
- [Original printed AA conjecture as a Lean specialization](aa-printed-cube.md) — Merged / named Lean; [PR #858](https://github.com/d3lefts/d3lefts/pull/858)
- [Distribution-uniform low-degree decision-tree simulation](product-simulation.md) — Merged / named Lean; [PR #858](https://github.com/d3lefts/d3lefts/pull/858)
- [Jensen simulation over finite mixtures of product laws](mixture-jensen.md) — Merged / named Lean; [PR #867](https://github.com/d3lefts/d3lefts/pull/867)
- [Finite complex quantum circuit to product-source simulation](quantum-product-bridge.md) — PR-head / named Lean; [PR #866](https://github.com/d3lefts/d3lefts/pull/866)
- [Normalized quantum circuits over product mixtures and TV neighborhoods](quantum-mixture-tv.md) — Integration or compiler gate open; [PR #878](https://github.com/d3lefts/d3lefts/pull/878)
- [TV-stable mixture simulation change-of-law interface](approx-mixture-tv.md) — Integration or compiler gate open; [PR #880](https://github.com/d3lefts/d3lefts/pull/880)
- [Latent-mixture exponential moment lower bound](latent-mgf.md) — PR-head / named Lean; [PR #869](https://github.com/d3lefts/d3lefts/pull/869)
- [Exponential mixture rank can coexist with easy queries](diagonal-mixture-rank.md) — PR-head / named Lean; [PR #883](https://github.com/d3lefts/d3lefts/pull/883)
- [Gaussian-sign Forrelation product-mixture obstruction](forrelation-mixture.md) — Paper or exact-test candidate; [PR #868](https://github.com/d3lefts/d3lefts/pull/868)
- [Fair-cube cubic exponent-two explicit constant and k-anchor hybrid](fair-cubic.md) — Paper or exact-test candidate; [PR #807](https://github.com/d3lefts/d3lefts/pull/807)
- [Strong simulation: candidate tail improvement and falsified shortcut](strong-simulation-frontier.md) — Paper or exact-test candidate; [PR #881](https://github.com/d3lefts/d3lefts/pull/881)
- [Unified Lean/Lake source graph and receipt custody](lake-and-custody.md) — Integration or compiler gate open; [PR #859](https://github.com/d3lefts/d3lefts/pull/859)
- [Mira Latin-square sampling: independent cycle-type moments and fixed-defect theorem](mira-latin-exact-sampling.md) — **author-side restricted theorem / finite exact replay**, distinct from 25 PR-head finite Lean declarations; full n^25 claim unverified; [draft PR #900](https://github.com/d3lefts/d3lefts/pull/900)
- [Original-product influence pinning decrement](source-pin-decrement.md) — PR-head / named Lean; [PR #861](https://github.com/d3lefts/d3lefts/pull/861)

## Review gate

1. Reproduce original source-head and dependency hashes; report any drift.
2. Inspect *actual theorem statements* rather than inferred descriptions; check source distribution and oracle semantics.
3. Independently reproduce calculations, attack edge cases and preserve counterexamples.
4. Compare dated literature and separate originality from correctness.
5. Do not release new public-preprint claims or merge unreviewed mathematical branches solely because of passport generation.
