# Judgment Provenance: testing whether independent review preserves independent judgment

**NIGHTFALL research protocol JP-01, v0.1 | 2026-10-29 | status: PROPOSAL / NO HUMAN RESULTS**  
**Research lead:** Devin J. Wright | **Protocol integration:** NIGHTFALL research systems.  
**Public display category:** Research methods / proposed experiment, **never an Original Finding** until a completed audited study.

## Motivation and strongest checked reference

Amaç Herdağdelen, Hailey Joren and Alex Tamkin, *Who's Aligned to Whom? How AI Agents Shape Experts' Research Judgment Calls* (Anthropic, 2026-10-27):  
- [Research post](https://www.anthropic.com/research/agents-judgment-calls)
- [Full paper](https://www-cdn.anthropic.com/519c17a5d23a794e8b6d50a854048d0b61e0d73a.pdf)
- [Authors' preregistration](https://osf.io/t3q59)

Their 50-agent-user analytic sample matched randomly assigned AI preferences on 86% of four underdetermined analytical decisions; registered pooled influence was 72 percentage points (95% CI 60–83). The registered final policy effect was 17 points, one-sided p=0.069, **inconclusive**. The 11 self-selected non-agent users are **not** a randomized control group. One task, one model and deliberately strengthened leans limit generalization. We have inspected the paper and research post; **we have not independently replayed their private individual-level data**. This proposal does not reproduce their experiment or claim its novelty.

NIGHTFALL's [agent verification protocol](../../AGENT_VERIFICATION_PROTOCOL.md) already separates reproducer, adversary and formalizer. It checks arithmetic and logic. This new protocol measures a different failure mode: *judgment provenance* when every candidate analysis is defensible.

## Formal objective and feasible set

**Unit:** consenting human reviewer, assigned once to one workflow. **Within-reviewer unit:** four independently randomized binary analytical decisions on the same frozen, synthetic research brief. Record participant-level outcomes to preserve clustering. Obtain a valid informed-consent / ethics determination **before recruitment**; tell participants the system can express randomly assigned defensible recommendations, and debrief after completion. No publication of identifiable transcripts.

Arms, randomly allocated to participants in equal proportions:
1. **ordinary:** one competent agent presents an evidence-supported preference.
2. **adversary:** the same agent plus a visible opposing analysis, with both positions attributed to agents.
3. **blind:** a reviewer first freezes an initial choice and rationale without viewing the lead recommendation; a separate adversarial reviewer, isolated from the construction's preferred outcome, supplies the strongest alternative assumptions; only then are both alternatives exposed. The evaluator cannot retroactively edit the precommitment.

**Fairness constraint:** identical tasks, evidence, tool budget and maximum review time across arms where feasible. All agent advocacy must be honest, with opposing analytical choices genuinely defensible. The hidden randomized preference sets the direction of argument, never the data or ground truth. Reviewers may abstain and may overturn any preference using evidence. All decisions and rationales are logged with provenance timestamps. Blindness, independence and leakage require external process inspection; prompts alone cannot certify them.

## Registered hypotheses and endpoints (freeze before the first participant)

For decision d in {1,2,3,4}, Z=1 means agent instructed to favor option A, Z=0 option B; Y=1 means human chooses A. Z is independently randomized within reviewer and decision, and is concealed from the human until debrief.

For arm a define F(a) = (1/4) Σ_d { Pr(Y=1 | Z=1, arm=a, d) − Pr(Y=1 | Z=0, arm=a, d) }.

The **primary experimental contrast** is Δ = F(ordinary) − F(blind). Positive Δ indicates reduced preference-induced movement under blind review. A second predeclared comparison is F(ordinary)−F(adversary); it is exploratory and separately labeled. An alternative mechanism is that blinded reviewers simply ignore all input; reduced F alone is never a success claim.

**Co-primary preservation gate:** severe methodological-error frequency under blind review must not increase by more than 5 percentage points relative to ordinary review. Determine error against a **frozen rubric** using two assessors blinded to randomized lean and workflow; adjudicate disagreement. All workflow arms get identical access to raw evidence and objectively scored traps. Preservation gate needs its own uncertainty interval; failing to reject a quality drop is *not* proof of noninferiority. No unqualified effectiveness claim unless the 95% upper bound for (error_blind−error_ordinary) is under +0.05.

Secondary outcomes: methodology errors by type, analyst time, abstentions, explicit uncertainty, initial/final choice switches, correct attribution of arguments, sensitivity to task framing, independent rationale overlap, and full source/tool cost. Report these as exploratory.

**Analysis plan:** participant-clustered intervals, equal decision weight, ITT by original workflow assignment, all four decisions retained; missing outcomes and abstentions enumerated separately and treated as a sensitivity analysis (A/B assignments coded only when a binary choice exists). Never silently pool decisions as independent participants. The companion checker reports descriptive difference-in-proportions and cluster-sandwich 95% intervals; this does **not** substitute for the definitive human-study analysis, which will need a preregistered missingness policy, approved inferential approach, and adequately powered sample. No pilot p-value is used to claim efficacy.

## Execution stages and integrity gates

| Stage | Cheapest decisive test | Required certificate | Status |
|---|---|---|---|
| 0 / instrumentation | Synthetic balanced rows with known F=(1,.5,0), then deliberate corruptions | Standard-library checker; 4 rejection controls and a clustered-vs-naive counterexample | CI SYNTHETIC PASS / NO HUMAN DATA |
| 1 / feasibility | Small consenting pilot with balanced randomized leans and process logs | Frozen task pack, assignment manifest, audit of blinding, evaluator rubric, cost metrics | UNRUN |
| 2 / confirmatory | Independently powered randomized human trial; sample size fixed **before** enrollment | Preregistered analysis, immutable commit/hash, consent and ethics determination | UNRUN |
| 3 / external audit | Reviewer with no access to preferred findings independently reruns scoring and tests leakage | Signed, provenance-linked reproducibility receipt and limitations | UNRUN |

**Budget / stop:** stage 0 uses stdlib and no paid model calls. The pilot has no authorized participant or API budget in this protocol. Stop if viable honest alternative analyses cannot be produced; blinding fails; adverse influence is detected; source data are missing; consent is inadequate; the key outcome cannot be reliably coded. Reserve exploration for new mechanisms *after* preregistered primary analyses.

## Novelty threshold, failure conditions, and transfer

This extension is a **new proposed NIGHTFALL test design**, not a demonstrated novel scientific result. A publishable methodological contribution would require a statistically and practically meaningful Δ **and** a separately demonstrated methodological-quality preservation gate, with independent audit and a dated same-scope literature review. A null or adverse result remains publishable as a bounded negative experiment.

**Adversarial hypotheses:** (i) reduced F reflects reviewer stubbornness rather than better judgment; (ii) source sharing leaks the preferred conclusion; (iii) the blind adversary biases choices in the opposite direction; (iv) a common model makes ostensibly separate rationales dependent; (v) scenario effects swamp workflow effects; (vi) source coding and conditioning on completed tasks bias the estimate. Audit against all six.

**Transfer candidate:** attach a precommitment-and-influence ledger to every Proof Passport judgment call. Only distinct source inputs, isolation records, dated prior views and alternative-case analysis justify labeling a review as *judgment independent*. Reproducible numerical agreement alone cannot certify that property.

## Data contract (v0.1)

Accepted CSV columns: `participant_id,arm,decision_id,lean,choice`. Allowed arm values: `ordinary,adversary,blind`; decision_id 1–4; lean and choice 0/1. Exactly one row per participant and decision, and one arm per participant. Real runs additionally require separately secured randomized-assignment manifests, consent metadata and retained blind process logs; these are **outside** the checker. The checker refuses sparse arm-by-decision lean cells and emits an analysis-only verdict; see `scripts/check_judgment_provenance.py`. Test data **must** carry the `SYNTHETIC_FIXTURE` label. No fabricated human observations.

[Independent audit and experiment authorization tracker](https://github.com/d3lefts/d3lefts/issues/170) — participation and external review remain unstarted.

## Independent review assignments

- **Ryev / systems engineering (proposed):** isolate agent inputs, make an append-only immutable precommitment log, test browser privacy, and publish a redacted export schema.
- **Lemnis / adversarial methods (proposed):** attack assumptions and counterfactual interpretation before seeing any pilot results; derive minimum leakage and quality objections.
- **Vesper / coordination (proposed):** freeze protocol and allocate an independent human evaluator with source-blinded rubric; track attrition, budgets, and review gates.

No assignment implies an agent has been activated. Human participation, public external review and publication require separate authorization.

## Mechanism graph

Problem (unacknowledged agent influence) → representation (randomized lean, binary choice, provenance) → mechanism (precommitment, source-blind adversary) → operator (three-arm trial) → construction (task pack and signed transcript log) → certificate (cluster-aware analysis plus blind error grading) → limitation (small pilot and source correlation) → transfer (Proof Passport judgment gate).
