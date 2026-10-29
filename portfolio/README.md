# NIGHTFALL — unlisted collective research portfolio

**OpenAI Search / Knowledge Graphs work-sample release:** [submission packet, source-backed research statement and claim audit](openai-search-kg/README.md). Prepared for an application; no submission has been made.

**Direct-link working page:** https://d3lefts.github.io/d3lefts/portfolio.html

**Visibility:** Intentionally unlisted in public website navigation, homepage, root README and sitemap. The page has a `noindex, nofollow, noarchive` meta tag. GitHub Pages and the source repository are public. This is *not access control*; never store confidential information here.

**Automatic update boundary:** The page loads `docs/research-registry.js` and projects every canonical Proof Passport claim and its dated history using `docs/portfolio-core.js` and `docs/portfolio.js`. Claims added or revised in that registry appear when the corresponding commit reaches the published site. Displays validity, reproducibility, originality, significance, primary sources and open review obligations verbatim. New numerical candidates remain candidates; corrected or demoted claims remain corrected or demoted. The three long-form project case studies stay editorially curated.

**Maintenance test:** `node scripts/test_portfolio.cjs` checks new claim intake, status demotion, source URL filtering, and unlisted-site boundaries. This test is run by the main website verification workflow.

Three source-backed case studies from the NIGHTFALL research program retained for our collective reference, with a live registry-backed claim ledger, a five-item historical editorial approval index, a source-qualified mechanism map, and explicit external audit gates. See [the cross-session research context checkpoint](RESEARCH_CONTEXT_20261029.md) for scope, provenance, and outstanding ingestion gaps. These case studies can also inform research engineering, applied AI safety, and source-grounded knowledge-system applications when explicitly approved for external presentation. This is a navigation layer over existing work, not a separate claim of scientific novelty, professional deployment, or independent external validation.

| Case study | Public implementation or result | Reproducible evidence | Honest limit |
|---|---|---|---|
| [SourceBound](../research/nightfall/projects/ai-safety-peer-review-2026-10-28/SOURCEBOUND_EVALUATION.md) | Source-constrained assertion admission, version/DOM/span and entity-identity gates | 27 known-fixture regression tests; 14,000 synthetic pages and 6,000 retained fixture assertions | No held-out natural-web extraction accuracy or measured downstream reasoning lift |
| [Proof After Scarcity](../research/nightfall/projects/pas-overview.md) | Distinguishes bibliographic links from dependency claims in a finite research graph; reports negative prioritization result | Outcome-aware retrospective 20-case assessment: 8/20 versus 11/20 baseline | Not a prospective evidence-ranking success; full graph preregistration still incomplete |
| [Runnable evidence retrieval](../docs/portfolio-search-core.js) | Deterministic source-scoped lookup, cited claim statements, typed edges, and abstention | [Standalone regression tests](../scripts/test_portfolio_search.cjs) plus browser UI checks | Six manually curated records, no learned model or realistic retrieval benchmark |
| [Erdős overlap](../research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md) | Integer-convolution and exact-rational finite optimization certificate | [Public release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28), hash-verified CI replay | Not global optimum or an accepted 131,072-cell Arena entry |

**Supporting tools:** the [bounded research toolchain](../docs/exact-research.html) has independent finite checkers, corrupted-input controls, web-browser smoke workflows and reproducibility CI, with each method's scope documented.

**Research judgment / negative result:** [Proof After Scarcity](../research/nightfall/projects/pas-overview.md) published a retrospective adverse result of 8/20 against 11/20 for simple baselines, with explicit post-hoc selection caveats.

## Reproduction starting points

From the [repository root](../):

```sh
python3 scripts/check_site.py
node scripts/test_adversary.cjs
node scripts/test_companion_handoff.cjs
node scripts/test_portfolio.cjs
node scripts/test_portfolio_search.cjs
```

For the large overlap witness, [download and verify the public curated release](../research/nightfall/RELEASE.md) before running its independent mathematical checker. The SourceBound code and fixture runner are supplied as a [separately frozen release archive](https://github.com/d3lefts/d3lefts/releases/tag/ai-safety-review-2026-10-28).

## Attribution and evidence policy

Program directed by Devin J. Wright with AI-assisted research, implementation and adversarial analysis. Individual sources retain their own authors and licensing terms. The public archive labels arithmetic reproduction, logical proof status, external review, publication priority and competition standing separately. Metrics in this portfolio are copied from scoped evidence records; none represents a measured production ML model outcome.

**Career-positioning gap to close:** a prospectively frozen, independently annotated natural-web SourceBound evaluation with a matched-recall baseline, effect sizes, cluster intervals, failure examples, per-task logs, latency and environment pinning. No success is presumed.
