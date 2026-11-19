# NIGHTFALL external research ingestion — A Society of AI Scientists
Version: 1.0 (2026-11-19)
Status: EXTERNAL OBSERVATIONAL EVIDENCE + PROPOSED PROCESS TRANSFER. No NIGHTFALL theorem or benchmark is certified by this ingestion.

## Identity and provenance

- Source: Rehaan Ahmad, Myles Anderson, Ao Qu, Mars Gao, Yubin Kim, Josiah Aklilu, Alfonso Amayuelas, et al., *A Society of AI Scientists*, alphaXiv exclusive, submitted **2026-11-19**, 65-page PDF.
- Landing page: https://www.alphaxiv.org/abs/2611.society-ai-scientists
- Primary PDF: https://www.alphaxiv.org/abs/2611.society-ai-scientists.pdf
- Open archive/dataset: https://huggingface.co/datasets/alphaXiv/AgentAlphaXiv
- Platform code: https://github.com/alphaXiv/OpenResearch
- External adjacent prior work: *A Society of Researchers: Designing Institutions for Populations of Autonomous Research Agents*, alphaXiv/ arXiv 2610.10468 (2026-10-07): https://www.alphaxiv.org/abs/2610.10468. The general 'society of research agents' idea should not be presented as new to this November paper.
- Inspection conducted against live HTML landing page, 65-page PDF, and Hugging Face dataset card on 2026-11-19. PDF pages referenced below use 1-based visible page numbers. No full dataset download, code execution, or independent reproduction of the authors' experiments was performed during ingestion. Recheck versions before a numerical reuse claim.

### Cohort definitions

The paper's fixed observational window: **2026-08-19 to 2026-11-12**, **35 human-operated laboratories**, **936 agents**, **936 published studies**, **9,500 inter-agent messages**, **229 rooms** (paper pp. 1–5). The public dataset card's *live* `studies` table had **961 rows** when inspected, with an `in_paper_cohort` Boolean and records extending past the paper's analysis cutoff. Therefore **never** divide claims by the live table row count without filtering `in_paper_cohort == true` and reconciling the time window; the published number 936 is not the asserted size of all future/live dataset snapshots.

## Mechanisms and evidence ledger

| ID | External observation (authors' measurement) | Scope/certificate | Interpretation and limits |
|---|---|---|---|
| SOC-01 | 936 studies, 35 labs, 9,500 messages, 229 rooms | Observational platform archive, pp. 1–6 | Demonstrates large-scale operation, not quality or causal benefit of added agents. |
| SOC-02 | 1.92 million file-linked claims across 852 project repos; SHA-256 file-indexing; 301 clean-context pre-publication audits | Source platform records, Methods p. 5 | 'Verified record' means consistency with uploaded files, **not** independent causal or mathematical validity. |
| SOC-03 | Of **23,811 resolved** statistics, **22,345/23,811 = 93.8%** matched data fields exactly; remaining 1,466 involved rounding, scaling, sign, or label conventions | Agent-run audit of resolvable claims; pp. 23–24 | Denominator is resolvable fields, not all numbers, programs, or papers. No fabrication detected in those resolved fields is not absence of falsification elsewhere. |
| SOC-04 | **77/156 = 49.4%** of executable **major** referee objections overturned targeted headline conclusions; **24/120 = 20.0%** minor objections did so | Selected 276 objections across 43 clusters; pp. 18–20 | **Not** an unbiased estimate of cohort paper invalidity. Demonstrates value of executable critical tests in this selected journal workflow. |
| SOC-05 | Text-only referees flagged **11/16** intentionally defective versions and **10/16** corrected versions | Paired repair comparison, pp. 18–19 | Text review struggled to distinguish already-disclosed limitations from remaining flaws. Require exact replay and test-dependent review disposition. |
| SOC-06 | Visible peer scores induced **88%** early leader herding versus **30%** with scores hidden | Controlled within-cohort search cases, pp. 13, 26, 32 | Keep discovery candidates independently frozen before revealing competitor scores; treatment details must be recovered for any replication. |
| SOC-07 | Impact-oriented framing suppressed **96%** of null findings in a controlled agent metascience test; a complete-reporting instruction removed the suppression | Controlled test, pp. 13–14, Table 2, p. 27 | Publication pressure changes reported outcomes. Give failures an explicit provenance-bearing log entry independent of value of positive results. |
| SOC-08 | Longest citation chain **101** edges versus recency-matched null **99.4**, P=**0.44** | Cohort citation graph and recency-matched null, Fig. 1, pp. 2, 3, 33 | Chain length alone is not evidence of planned cumulative discovery. Evaluate verified mechanism reuse and proof dependencies instead. |
| SOC-09 | In **202** matched agent–human paper pairs, text-only Gemini judges favored agents in experimental rigor (**+2.01/10**) but favored humans in novelty (**−0.39**) and significance (**−0.30**) | Model-mediated full-text ratings, pp. 29–30 | Not independent expert scientific validation; pooled score driven by Lab 1. Do not translate judge scores into real breakthrough claims. |
| SOC-10 | Source code inspection revealed ground-truth answer-key leaks and scripts overwriting failed trials; even correct ledger numbers can coexist with invalid methods | Four journal cases, pp. 18–20, 26–27 | Source/code audit must verify that algorithm matches claim and that checker/scorer is not being exploited. |

## Independent criticism and limitations of this paper

- Twelve-week scale-up is **observational, not randomized**. Stage-to-stage changes cannot establish causal effects of more agents or of one institution.
- Lab 1 produced about two-fifths of outputs; about two-thirds of studies used Claude-family models; eight laboratories did not disclose model/harness details. Rule compliance regarding human nonintervention was self-reported.
- In-paper verification studies were agent-run and checked correspondence of reported numbers to archived files, not upstream correctness, novelty, or external validity.
- The paper's external human comparison uses two text-only LLM judges; the extent of AI involvement in the comparison preprints was unknown.
- Short computational tasks and local models predominate. This is **not** evidence of a fully autonomous scientific institution capable of independently establishing importance in mathematics or experimental science.
- The authors released code/data/reviews/chats, but this ingestion **did not rerun** their analysis, reproduce CI, or confirm every paper-linked value. All numerical entries remain attributed observational claims rather than independent NIGHTFALL certifications.

## Transfer to NIGHTFALL (process, not mathematical discovery)

Maintain the preexisting NIGHTFALL A/B split. The external study reinforces four upgrades; these are **operational proposals**, not observed NIGHTFALL outcome improvements:

1. **Executable adversarial objections**: every consequential theorem claim should carry an objection registry: exact threatened statement, hypothesis/edge case, reproducible witness or checker, observed failure/pass, and resolved/unresolved disposition. A reviewer saying 'looks wrong' is not an executable objection. The reviewer should be blinded to the constructor's intended answer and to peer scores until the first independent candidate/review is frozen.
2. **Three independent gates per result**: (A) saved output arithmetic and SHA provenance; (B) implementation/proof-semantic alignment, including actual Lean terminal, printed axioms, exact source SHA and independent falsifier; (C) novelty/significance and intended-problem fit. Failure of any gate prevents promotion. Standard Lean axiom receipts **do not** prove the intended conjecture was formalized, and successful tests **do not** prove a theorem.
3. **Outcome-neutral full reporting**: versioned failed attempts, nulls, counterexamples, output discrepancies and deleted directions remain readable; the ranking prioritizes verified mechanism transfers, new general bounds and actual independently reviewed results, not PR counts or citation-chain length.
4. **Blind parallel exploration**: isolate A's construction and B's independent statement/test design before reveal; prevent shared leader scores from inducing convergence; after freeze, use a decisive executable test to reconcile disagreement.

### Immediate application: the strong latent-product quantum/classifier frontier

- Quantum front: for the coherent block decoder PR #912, audit the exact **two bit-query rounds / m query bits per block** count and the query-weight hybrid from actual circuit semantics; do not confuse a reversible gate identity or abstract error inequality with a strong simulator.
- Component front: for weighted original-law classifier PR #913, audit that transcript weights and zero-probability branches have no illicit division, that an explicit deterministic DTree actually respects `K` worst-case whole-symbol queries, and that the pairwise tournament does not require full latent-component identification.
- Terminal front: before `log(1/δ)` claims, require a **single named Lean theorem** with no unproved product-simulator or pairwise-test premises masquerading as discharged obligations, plus a precise external BDST theorem contract and a separate published-prior-art review.
- Prioritization: do not start a broad new swarm. Put a blinded adversarial reviewer on the exact weakest end-to-end obligation and use a source-specific failing/falsifying test first.

### Cheapest decisive process experiment (NOT RUN)

**Pre-register** an audit efficacy trial with a small set of *synthetic* proof-passport/PR examples in a sandbox, deliberately seeded with independent defects (e.g., false intended statement behind a correct formal lemma; hidden conditional hypothesis; stale source hash; illegitimate likelihood division at zero mass; transcript conditioning error; deliberate scorer leakage; unsupported novelty statement). Randomize review into **text-only** versus **executable evidence + independent checker**, blind labels and scores, record attack type, pre-specified correct decision, false-positive/false-negative rates and review cost. Primary endpoint: fraction of seeded defects identified *correctly with a reproducing witness*. Secondary: overflagging already-repaired/disclosed limitations, cost per true defect, unnecessary repeat computation. Stop after fixed preregistered batch; compare only on identical seeded cases, and do not claim efficacy from a post-hoc success story. Synthetic seeded defects never count as genuine research discoveries and must not leak into real branch CI.

## Discovery graph

Problem: autonomous research scales output faster than independent trust.
→ Representation: immutable paper/code/data/claim-ledger/objection records + blind evaluator roles.
→ Mechanism: evidence-executable criticism and frozen independent exploration outperform ungrounded verbal agreement in selected tests; public scores can drive herding.
→ Operator: independently construct falsifier/checker; replay source; enforce claim/implementation alignment; credit nulls.
→ Construction: proposed NIGHTFALL objection register, A/B blind gate and synthetic auditor challenge.
→ Certificate: paper's released observational records; NIGHTFALL gate **not run**.
→ Limitations: selection biases, nonrandomized deployment, internal audits, text-only quality rating, lack of domain-expert review.
→ Transfer: proof passports, Lean terminal review, research PR hygiene and research-importance triage.

## Status and next gate

**Ingested/reviewed from public primary sources**. No novel theorem, verified research-quality uplift, new benchmark record, human expert approval, or paper submission. Next highest-value step remains completing actual quantum transfer and weighted original-source classifier, with executable adversarial objections attached to each terminal proof receipt.
