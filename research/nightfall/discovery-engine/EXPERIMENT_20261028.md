# NIGHTFALL / Adaptive granularity — experiment log v1.2

**Frozen study:** 2026-10-28 · **Seed:** 1729 · **Case type:** bounded synthetic proxies · **Evidence tier:** exact same-repository atomic checker, external peer review pending.

## Contract and preregistered conditions

Objective: compare fixed coarse representation, event-adaptive boundaries, fully atomic resolution, and a downstream-trained discrete boundary policy, using the same candidate pool and exact-check budget. Report compression, coarse scoring operations, exact atomic decisions, verified gain and negative controls separately.

Train split: 12 seeded cases per domain. Held-out split: 12 different seeded cases per domain. Each case contains eight rounds, each with eight matched candidate proposals. Each policy receives **96 exact oracle calls per domain**. The 19 policy-search options include the atomic identity policy. The selector uses training outcomes only, with coarse-operation cost breaking equal-gain ties. Each held-out case stores original-source SHA-256 and, for source spans, an independent hidden-annotation SHA-256.

Scope: two **proxy** domains. The cyclic integer overlap test is distinct from the continuous EA-36 problem. The synthetic source-span test is distinct from natural-web SourceBound. The exact scorer is a separately structured in-repository implementation, not an independent outside agent.

## Final corrected matched-budget results

| Policy | Cyclic overlap verified gain (sum) | Cyclic coarse scoring ops | Source-span valid selections / 96 | Source coarse scoring ops |
| --- | ---: | ---: | ---: | ---: |
| Atomic identity | 13 | 69,120 | 70 | 3,004 |
| Fixed coarse | 10 | 1,520 | 61 | 10,752 |
| Event-adaptive heuristic | 10 | 32,696 | 70 | 8,471 |
| Trained selection (19-option grid) | 13 | 69,120 | 70 | 3,004 |

**Selected trained parameters:** fine width 1, edge trigger 0, coarse children 1 — **the atomic identity policy**.

The event-adaptive heuristic recovered nine additional valid selections relative to the fixed coarse baseline in synthetic source spans; its coarse scoring count was also smaller. Atomic precision matched the 70 valid selections at still lower source-span coarse-scoring cost. For cyclic overlap, atomic improved the exact finite objective by three additional integer units relative to both coarse policies, at much higher coarse scoring cost. The trained selector, allowed to choose all options, selected atomic.

Consequently, this experiment **does not establish superiority of learned adaptive compression** over the atomic baseline. It does establish a working experimental pipeline, held-out controls, reversible boundaries, and one domain-specific fixed-versus-adaptive improvement under these synthetic costs. None is a novel universal result or a competitive scientific record.

### Measured evidence

- **GitHub Actions workflow:** https://github.com/d3lefts/d3lefts/actions/runs/40775826748
- **Artifact:** `nightfall-granularity-study` (downloadable from that workflow; retention 90 days)
- **Final corrected JSON SHA-256:** `33813484b1dcccfa19e981aea9f164b8a630ee8de399bce5de6f701dbc04bc30`
- **Independent exact code path:** `granularity_oracle.py`
- **Evaluator + policy:** `granularity_study.py`
- **Negative-control tests:** `test_granularity_study.py`
- **Rebuild command:** `python3 research/nightfall/discovery-engine/granularity_study.py --seed 1729 --train 12 --test 12 --output granularity_results.json`
- **Test command:** `python3 -m unittest discover -s research/nightfall/discovery-engine -p 'test_granularity_study.py'`

### Adversarial revisions

1. **V1.0 source-label leakage (demoted):** a source cue was identical to its oracle support label, making the original 96/96 source-span result invalid as transfer evidence.
2. **V1.1 annotation isolation (validated):** separated observable noisy cues from hidden adjudication labels; confirmed that inverting *all* hidden labels changes exact outcomes without changing candidate-selection traces. The restricted 18-option trained selector achieved 70 source selections at 6,137 coarse ops. This result was an incomplete comparison because the atomic option was excluded from training.
3. **V1.2 atomic search inclusion (current):** added atomic to the 19-option trainable policy grid. The selector chose atomic. Both benchmark test suites and the website/browser workflow passed.

### Cost and proof audit

Coarse scoring-operation counts omit hierarchy construction, oracle wall time, training work and other system costs. They measure only the explicitly counted internal scoring operations; **no end-to-end compute-hour speedup is established**. Full raw-source recomputation gates every exact result. Changed hashes, changed trust boundaries, damaged source bytes, invalid study budgets and corrupted input labels are independently tested. External scientific novelty, large continuous-overlap validation, blinded natural-web evidence performance, neural end-to-end policy learning, and general cross-domain transfer are open gates.

### Operator registry / next experiment

Successful structural transition: treating atomic resolution as a *trainable* policy choice exposed the compression/transfer tradeoff and prevented a false positive.

Failure modes: oracle-label leakage; excluding the best simple baseline; cost models that ignore segmentation overhead; combining incompatible domain gains as if numerically commensurate.

**Next decisive experiment:** add honest segmentation/training/oracle wall-time accounting, source evidence with blinded externally annotated labels, and a boundary policy capable of learning from *observable* evidence cues under a matched total compute budget. Prefer replication with multiple frozen seeds and published confidence intervals before promoting any transfer claim.

**Handoff:** best status = bounded synthetic paired comparison with exact atomic replay; no general compression advantage. Reopen a compression-superiority claim only on independently held-out evidence when adaptive achieves higher certified gain per total compute unit than atomic and fixed baselines.
