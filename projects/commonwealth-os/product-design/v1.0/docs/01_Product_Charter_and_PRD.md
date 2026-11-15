# Product charter and product requirements

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Executive definition

**Commonwealth OS** is a proposed multi-institution democratic operating system that connects governing rules, proposals, amendments, deliberation, authorized voting, recorded outcomes, and implementation evidence. **Living Voter** is its private citizen-facing legislative-preference interface. Working surface names: **Chamber** (representatives), **Steward** (administrators), and **Proof Passport** (audit view). Names are provisional.

**North-star user outcome:** A person can see what their governing institution is deciding, understand the relevant text and consequences, express an informed preference without being steered, and later verify whether an authorized decision actually took effect.

**Product thesis:** The cross-product gap to investigate is *decision-state discontinuity*: absence of reliably transportable evidence linking rule/version → eligible participants → consultation/deliberation → authorized vote → valid outcome → implementation. This is a **research hypothesis**, not proof that all compared systems lack the feature.

## Fixed founding requirements

1. Mobile-first; high trust; futuristic but credible; accessible without a smartphone through institution-approved alternatives.
2. **Three preference choices:** Support; Don't support; No preference. Keep **Unknown / not assessed** as a separate internal state.
3. Adult municipal onboarding proceeds **local ordinances first, federal law second**. A 96-question research instrument is a *budget*, not a proven claim of complete legislative coverage: 1 open-priorities prompt, 40 local seed questions, 30 federal seed questions, up to 25 adaptive questions. State law is a possible subsequent module, not a barrier between local and federal stages.
4. One question may map to multiple provisions only with reviewed semantic entailment and visible provenance. A response never silently creates a binding ballot.
5. New proposals, substantive amendments, repeals, and integrations are versioned; substantive changes prompt targeted review; editorial integration without normative change should not generate spurious preference reversal.
6. Personal political profiles and identifiable answers are private by default. Public-facing metrics are aggregate, labeled, and suppressed when they risk identification. No political microtargeting, persuasion optimization, resale, or covert secondary use.
7. Pilot delegates and officials have a mobile legislative workspace: tasks, pending decisions, review/amend/debate/vote, embedded explainable AI plus a persistent assistant. AI never has a vote or independent authority.
8. Human authority is grounded in each institution's charter/bylaws and applicable law. App features cannot confer authority they do not possess.
9. One pilot, five **non-interchangeable ordered stages**: UAH → other Huntsville universities → Huntsville City Schools high schools → Huntsville HOAs → Huntsville City Council. Target a potential city-approved deployment by 2030. All dates subject to institution permission.
10. Open-source intent and eventual broader adoption are strategic aspirations; no license or legal right to use personal pilot data for another purpose has been granted.

## Audiences and jobs to be done

| Role | Primary job | Core safeguard |
|---|---|---|
| Student senator / council representative | Review, amend, debate, and cast an authorized vote | Only correct role may vote on the locked text |
| Institution clerk / secretary | Set agendas, maintain records, certify proceedings | Version and authority evidence mandatory |
| Student / HOA member / resident | Understand decisions and express positions | Private responses, no accidental ballot casting |
| Institution administrator | Configure governing rules, roles and sources | Change control; no silent rule rewrite |
| Auditor / ombudsperson | Replay and challenge how decisions were reached | Read-only exportable receipts, exception ledger |
| Academic evaluator | Test fidelity, representativeness, costs | Explicit consent, research separation |

## Scope and release boundaries

**V0 / concept:** Browser-only synthetic Living Voter demo; example laws, anonymous localStorage, no real identity, source ingestion, voting, security, or institutional authorization.

**V1 / UAH:** Staff-confirmed institution constitution and senate bylaws, agenda/case tracking, bill version diff, assigned representative tasks, meeting & deliberation record, rule-configured vote lifecycle, certificates marked provisional until audited. Can operate as **recording/consultation** only until actual procedures are authorized.

**V2 / universities:** Tenant isolation and multiple independent governing rulebooks, federated account integration, export/import, institutional rule tests.

**V3 / schools:** School-specific governance; child and student privacy review; no minors' federal political profiling; no adult municipality eligibility claims.

**V4 / HOAs:** Exact membership, unit vote weights, proxies, quorum, budgets, and covenant-specific restrictions; legal review per association.

**V5 / Huntsville Council:** Official municipal document ingestion, authorized representative workspace, **advisory public dashboard first**; binding government voting only under clear legal authorization and independent election-grade assurance.

**Explicitly out of scope for early pilots:** public office replacement, autonomous elected-official votes, binding municipal referenda, identity claims based solely on GPS/IP, unconditional law-coverage percentages, political influence campaigns, production cryptographic verifiability without external audit.

## Product success measures (pre-register before pilots)

- Corpus coverage: % of verified *in-scope* governing provisions ingested, with source citations and gaps.
- Mapping precision: blinded human validation of answer→provision entailment; report abstention as well as error.
- Citizen control: override success and time-to-correct a wrong inference.
- Action continuity: % of decisions with complete rule→version→eligibility→ballot→outcome→implementation trail.
- Authorized voting: share of sample decisions passing independently reproduced quorum, eligibility and tally checks.
- Change latency: source update to correctly classified notification time; stratify by proposed/amended/repealed/editorial.
- Accessibility: automated + manual WCAG 2.2 AA audit, assistive tech and no-smartphone testing.
- Equity: compare completion/understanding across randomly recruited user groups; report nonresponse and coverage bias.
- Privacy: zero unauthorized exposures in red-team tests; deletion/export request completion and logged failures.

## Release gates

**G0** Design and legal scoping completed; **G1** source/corpus ground truth signed off; **G2** independent mapping study; **G3** rule tests, election-integrity design review and threat model; **G4** operator authorization; **G5** accessibility/security/privacy review; **G6** staged deployment and audit. No test can substitute for lawful institutional approval.

## Non-functional requirements

Encryption in transit and at rest, scoped authorization, secure key custody, immutable event log with independently verifiable hashes (hashes are necessary but not sufficient), audit export, recovery and backup, configurable retention, responsive touch targets, explicit status states, threat modeling, rate limiting, secure notifications, disaster recovery. Production SLOs and budgets must be set after user research and vendor estimates.

## Ethical and civic boundaries

Publicly disclose any long-term research into representative automation. Participation must be voluntary, consent-specific, reversible, and unlinked to education or association penalties. AI summaries require source references, dissent/uncertainty display and correction mechanisms. Do not use participant political preference profiles for electioneering, differential outreach, profiling of minors, or unconsented training.
