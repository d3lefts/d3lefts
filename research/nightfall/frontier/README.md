# NIGHTFALL Frontier — Agent NF research participation pilot

**Checkpoint:** 29 October 2026. **Research owner:** Devin J. Wright. **Demonstration designer:** Vesper / NIGHTFALL. **Status:** working local-first participatory demo, NOT a shared assignment server, autonomous LLM inference, a solver for an open theorem, or evidence of worldwide novelty.

## What it demonstrates

- Agent NF as a **transparent deterministic prioritization operator**, applied locally to **three pinned, real, separately sourced NIGHTFALL research obligations**; no fake user counts, hidden model predictions, invented breakthroughs or external-agent execution.
- A source-scoped dependency path: *open problem → falsifiable subproblem → local claim → exact finite replay / proof attempt → smaller child / publicly reviewed result*.
- Explicit GitHub issue creation handoff: visitors review an issue draft then submit themselves; a browser-local claim is **nonexclusive** and cannot lock a shared issue.
- Real tool handoff to Orchestrator. The specific claim, source, and falsifier prepopulate editable Orchestrator fields with explicit authorization; no background dispatch or status mutation.
- Persistent local child obligations and standalone JSON receipts. The local storage key is `nightfall_frontier_local_v1`, isolated from Claim Lab and all existing owner data.

## Agent NF triage rubric / reproducible decision

Snapshot `2026-10-29`, scores are **editorial heuristics** (not difficulty estimates, model inference or predicted success rates). Four integer ratings 1–5: decidable with exact checker ×2, tractable first experiment ×2, potential research leverage ×1, existing evidence readiness ×1.

| Source obligation | Decisive | Tractable | Leverage | Evidence | Score |
| --- | ---: | ---: | ---: | ---: | ---: |
| Erdős #156, nine-mark saturated Sidon in [1,184] ([#46](https://github.com/d3lefts/d3lefts/issues/46), [Axiom SAT audit](https://github.com/d3lefts/d3lefts/pull/55)) | 5 | 5 | 4 | 5 | **29** |
| Erdős #86, 305 C4-free Q7 edges ([#48](https://github.com/d3lefts/d3lefts/issues/48), [Ryev local obstruction](https://github.com/d3lefts/d3lefts/pull/70)) | 5 | 2 | 5 | 4 | **23** |
| Erdős #36, new lower dual geometry ([#76](https://github.com/d3lefts/d3lefts/issues/76), [fixed-eight-row ceiling](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md)) | 2 | 1 | 5 | 4 | **15** |

The first challenge has independent subproblem branches for positive witness construction, proof-producing SAT-UNSAT, and independent encoding scrutiny. The source explicitly states the N184 k9 decision is **unresolved**. Axiom's nine-mark near-candidate `{49,50,56,78,93,104,125,139,149}` is Sidon yet remains addable at exactly 16 and 166.

## Exact witness decision boundary

The in-browser algorithm computes **all unordered sums with diagonals** and tests all 175 omitted integers for insertability. If all 45 initial sums are unique and all omitted integers are blocked, that is a direct exact **YES certificate for this finite existence question**; independent external replay, priority, and publication reviews remain distinct. A candidate failing the check can be subdivided and logged as a negative attempt. A negative exhaustive answer (UNSAT) **cannot** be inferred from browser failure; it requires a sound complete solver proof.

The exact same generic oracle is tested on:
- The published `N=144, k=8` maximal-Sidon example `{8,48,68,69,71,75,104,120}`.
- The independently recorded `N=10, k=3` complete example `{4,6,7}`.
- The actual `N=184, k=9` near-candidate, with two known surviving addable marks.
- Duplicate marks, non-integer inputs, invalid diagonals, cardinality and out-of-range mutations.

## Reproduce

```sh
node research/nightfall/frontier/test.cjs
node --check docs/frontier.js
node --check docs/frontier-core.js
npm install --no-save --no-package-lock playwright-core@1.56.1
CHROME_BIN="$(command -v google-chrome)" node research/nightfall/frontier/test_browser.mjs
```

The dedicated workflow runs these tests on each changed branch. The site-wide workflow also treats `frontier.html` as a mobile/tablet/desktop route, and the visitor journey continues to test the broader research experience.

## Next stage, if the owner opts to build a public collaboration system

GitHub Pages cannot enforce exclusive assignments, identities, or a global consensus on closed proofs. Before enabling shared multi-user work: implement authenticated claim leases in a server-side queue or GitHub App; issue/PR-backed scoped contribution records; rate limits and abuse controls; source/hash snapshots; independent check/review lane; a dispute and dependency invalidation procedure; explicit license, consent, attribution, and privacy policy; human signoff for theorem resolution. Keep the current no-signup local draft as a useful on-ramp.

**Distinctive principle:** NIGHTFALL exposes *why this bottleneck matters* and makes its hypothesis/refutation/next-lemma graph actionable. It does not pretend that task completion equals theorem acceptance, and it does not try to reproduce Cairn Commons's generalized reputation or coordination backend.
