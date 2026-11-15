# Questionnaire design and preference attribution

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Formal definitions

Let `L_j` be the finite, **verified in-scope** set of operative normative provisions for institution/jurisdiction `j` and legal snapshot `t`. The underlying legal corpus is changing and nonuniform: cannot conflate all published pages with distinct independent policy choices.

For each user `u` and provision `ℓ`, output:

`p(u,ℓ,t) ∈ {support, oppose, neutral, unknown, conflict, stale}`

with basis `b ∈ {direct-provision, direct-topic, reviewed-inference, no-evidence}` and cited evidence/mapping version.

**No preference (`neutral`) ≠ unknown**. A person may explicitly be indifferent; unknown means the app cannot reliably assign any position.

## Research questionnaire v0.1

Maximum total items **96**: 1 open priorities item (not scored into policy position by default) + 40 local seed questions + 30 federal seeds + up to 25 adaptive questions. The document's intent is broad coverage, but **it has not been validated to infer a person's support for every ordinance or federal law**. Count *validated mapped positions*, not mere candidate mappings. Local precedes federal in adult/eligible flows. One grouped item may map to many legally equivalent clauses only after reviewed mapping.

## Coverage and fidelity metrics

- `Coverage_exact = #provisions with direct exact-version answers / #in-scope verified provisions`.
- `Coverage_reviewed = #provisions with direct or independently validated mapping / #in-scope verified provisions`.
- `Abstention = #unknown+conflict+stale / #in-scope verified provisions`.
- `Mapping error`: rate of user disagreement with an inferred position when separately asked an exact-provision question; sample is held out and stratified. Report Wilson/Clopper-Pearson CIs.
- `Question efficiency = validated incremental coverage per answered question`, measured against random, flat, topic-only and human-curated baselines.
- Evaluate fairness by age-appropriate adult groups and opt-in participant categories; no ideological optimization.

## Decision rule (specification, not proven theorem)

A question-to-provision edge may be labeled `equivalent` only when the proposition and the clause are semantically equivalent *within explicitly defined conditions, exceptions, sanctions, dates, applicability and funding tradeoffs*. Otherwise label `related` and abstain. For every inference, present the exact generating question and the human-reviewed mapping version. If provisions bundle independent normative dimensions, split or ask the full law directly.

Proposed adaptive item utility:

`utility(q) = expected reduction in unresolved high-relevance provisions * calibrated fidelity - burden_cost(q)`.

Select questions within budget `B<=96` under fairness and randomization constraints. This is an **optimization target**, not evidence of a universally optimal algorithm or guarantee of total legal preference reconstruction.

## Version-aware update procedure

At substantive law update: identify affected clause IDs; invalidate only mappings dependent on changed semantics; generate source-specific review questions; preserve old direct responses as history; never retroactively alter a historical ballot. At editorial integration: maintain equivalence certificate and update citations without asking unneeded questions. For new provisions, default unknown until reviewed.

## Bias controls

Preregister neutral wording, randomize symmetric question framing for A/B error testing, present tradeoffs and excluded exceptions, separate evaluative AI text from the three-choice response, blind reviewers to response direction and participant identity, allow no preference and skip. Report false inference, false certainty, and re-elicitation burden—not just apparent question compression.

## Cheapest decisive experiment

Choose 120–200 authenticated *fictional* local ordinance clauses with human-created exact-provision reference questions, design 20–30 grouped seeds blind to held-out responses, obtain opt-in adult respondents and compare map precision and coverage against direct questioning. A pilot is positive only if the pre-registered fidelity threshold is met *and* abstentions are honestly reported. Independent reviewers must challenge mappings, particularly exceptions, penalties and cross-clause interactions.
