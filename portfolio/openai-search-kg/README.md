# OpenAI Search — Knowledge Graphs | submission packet

**Target position:** Research Scientist / Research Engineer, Search – Knowledge Graphs, Foundations, San Francisco (confirmed 29 October 2026).  
**Live role/application:** https://jobs.ashbyhq.com/openai/1441816f-6429-426e-8f6d-8e5930a818f9  
**Applicant / research owner:** Devin J. Wright  
**Direct portfolio:** https://d3lefts.github.io/d3lefts/portfolio.html  
**Evidence and code:** https://github.com/d3lefts/d3lefts  
**Status:** Research portfolio prepared for use with an application; no application submitted. The person's employment history, academic credentials, personal contact and eligibility details have not been supplied and must not be inferred.

## The 30-second review

The research focuses on converting uncertain, heterogeneous sources into structured information that retains provenance and can be challenged. The strongest directly related package is SourceBound: an evidence-admission system that binds candidate subject–relation–object assertions to source versions, spans, identities and temporal qualifiers. Its public, bug-fixed frozen package records 27 unit tests and a 14,000-page *synthetic known-fixture* replay with 6,000 retained fixture assertions and zero extra fixture emissions. The result is **not** an independent natural-web precision or scale estimate.

Proof After Scarcity extends the same concern to typed evidence and citation/dependency graphs. Its adverse retrospective comparison—8/20 for the proposed prioritizer against 11/20 for simpler baselines—remains public. Together they motivate explicit source tracking and error-aware evaluation, without claiming current research accuracy gains.

A runnable [knowledge retrieval demonstration](https://d3lefts.github.io/d3lefts/portfolio.html#search-lab) retrieves source-scoped claims from six manually curated canonical Proof Passports, with typed proof-relation labels, citations and abstention on unsupported queries. The demo has executable [Node regression tests](../../scripts/test_portfolio_search.cjs); it is **not** web scraping, neural retrieval, model reasoning or a learned search benchmark.

A separate [exact numerical witness](../../research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md) shows a reproducible style of engineering: archived integer data, exact arithmetic, hash-checked public asset, counterexamples and explicit contest/source provenance boundaries.

## Closest role requirements and evidence

| Posted responsibility | Relevant source-backed work | Boundary |
|---|---|---|
| Extract entities, attributes and relationships from unstructured/semi-structured web sources | [SourceBound protocol](../../research/nightfall/projects/ai-safety-peer-review-2026-10-28/SOURCEBOUND_EVALUATION.md) with candidate triple, source span, DOM, digests, identity and version gates | Restricted known-fixture evaluations; no domain-held-out extraction quality |
| Structure noisy and inconsistent source claims | [PAS](../../research/nightfall/projects/pas-overview.md) distinction between citation edges and logical dependencies; source/version conflict control in SourceBound | No demonstration of production knowledge-graph construction or entity resolution |
| Measure usefulness for retrieval and model reasoning | [Bounded retrieval lab](../../docs/portfolio-search-core.js), [tests](../../scripts/test_portfolio_search.cjs) and explicit abstention | Engineering test only; no representative downstream QA/model outcome measure |
| Move an independent idea through implementation and review | [Referee and artifact verification](../../research/nightfall/RESEARCH_INSTRUMENT_HANDOFF_20261028.md) plus website regressions; [public research archive](../../research/nightfall/README.md) | AI-assisted collaboration with owner review; distinct from independent academic external review |
| Scalable systems and real-world ML benchmarks | No verified equivalent evidence in the shared archive | This is the principal candidacy gap; never claim unmeasured web-scale throughput or model lift |

The job's role description asks specifically for `reliably at web scale` and for measurable *improvement to model reasoning*. Neither outcome is currently established in the public research. This gap is stated openly rather than filled with unrelated math results.

## Share exactly this package

1. **Portfolio URL for a website / additional links field:** https://d3lefts.github.io/d3lefts/portfolio.html
2. **GitHub profile / repository URL:** https://github.com/d3lefts/d3lefts
3. **Optional research statement:** [RESEARCH_STATEMENT.md](RESEARCH_STATEMENT.md) (ready to copy into a statement/additional-information field where offered).
4. **Evidence checking:** [CLAIM_AUDIT.md](CLAIM_AUDIT.md) plus [source-recovery checkpoint](../RESEARCH_CONTEXT_20261029.md).
5. **Resume/CV and personal application answers:** require the applicant's verified education, employment dates, contact details and work authorization. No invented stand-in is provided.

## Reproduce the portfolio claims

From the repository root:

```sh
node scripts/test_portfolio_search.cjs
node scripts/test_portfolio.cjs
python3 scripts/check_site.py
```

The full website check also runs headless mobile/tablet/desktop browser routes, theme contrast checks and canonical research regression suites in GitHub Actions.

## Unlisted visibility and submission scope

The portfolio intentionally has `noindex` metadata and does not appear in the site's public navigation or sitemap. Anyone with its direct URL can still open it; the site and GitHub code are public. This is suitable for a shared work sample, **not** a private document vault. The live research ledger updates only when the site's reviewed canonical registry deploys; the career-specific statement is editorially frozen to this dated source check.

**Application status: not submitted.** Human applicant review and explicit portal submission remain separate from publishing the work sample.
