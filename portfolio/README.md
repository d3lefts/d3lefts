# Devin J. Wright — selected AI research and engineering

**Live portfolio:** https://d3lefts.github.io/d3lefts/portfolio.html

Three source-backed case studies from the public NIGHTFALL research program, organized for research engineering, applied AI safety, and source-grounded knowledge-system roles. This is a navigation layer over existing work, not a separate claim of scientific novelty, professional deployment, or independent external validation.

| Case study | Implemented artifact | Evidence | Scope boundary |
|---|---|---|---|
| [SourceBound](../research/nightfall/projects/ai-safety-peer-review-2026-10-28/SOURCEBOUND_EVALUATION.md) | Candidate-to-source assertion admission with field binding, DOM/span witnesses and revision checks | Known-fixture test package: 27 tests, 14,000 synthetic pages, 6,000 retained fixture assertions, zero extra fixture emissions | No domain-held-out natural-web score; world truth is distinct from source support |
| [Erdős overlap](../research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md) | 131,072-cell integer witness, exact-rational score and signed-grid verifier | [Public release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28), hash-verified CI replay | Mathematical construction, not global optimum or a valid 131,072-entry Arena submission; outside referee open |
| [Research toolchain](../docs/exact-research.html) | Static browser research workflow, adversarial controls, finite checkers and CI | Node regression suites, website validator, browser smoke workflows | Local tools and checks are not autonomous discovery or external refereeing |

**Research judgment / negative result:** [Proof After Scarcity](../research/nightfall/projects/pas-overview.md) published a retrospective adverse result of 8/20 against 11/20 for simple baselines, with explicit post-hoc selection caveats.

## Reproduction starting points

From the [repository root](../):

```sh
python3 scripts/check_site.py
node scripts/test_adversary.cjs
node scripts/test_companion_handoff.cjs
```

For the large overlap witness, [download and verify the public curated release](../research/nightfall/RELEASE.md) before running its independent mathematical checker. The SourceBound code and fixture runner are supplied as a [separately frozen release archive](https://github.com/d3lefts/d3lefts/releases/tag/ai-safety-review-2026-10-28).

## Attribution and evidence policy

Program directed by Devin J. Wright with AI-assisted research, implementation and adversarial analysis. Individual sources retain their own authors and licensing terms. The public archive labels arithmetic reproduction, logical proof status, external review, publication priority and competition standing separately. Metrics in this portfolio are copied from scoped evidence records; none represents a measured production ML model outcome.

**Career-positioning gap to close:** a prospectively frozen, independently annotated natural-web SourceBound evaluation with a matched-recall baseline, effect sizes, cluster intervals, failure examples, per-task logs, latency and environment pinning. No success is presumed.
