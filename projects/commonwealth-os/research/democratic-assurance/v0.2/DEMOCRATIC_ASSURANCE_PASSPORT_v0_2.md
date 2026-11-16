# NIGHTFALL Democratic Assurance Passport (DAP)
## Formal specification and proof obligations, version 0.2

**Research direction:** Devin J. Wright / NIGHTFALL; AI-assisted specification, draft proof arguments, code and programmatic audits. No independent human referee review.  
**Program:** *The Constitution of Computational Commonwealths: A Blueprint for Human-Sovereign Governance in the Age of Synthetic Autonomy*  
**Research specialization:** Democratic Assurance  
**Date:** 2026-11-15  
**Status:** Conditional logical construction plus exact finite-model executable checks. Not a cryptographic protocol proof, Lean theorem, independently audited system, legal opinion, empirical validation, or general U.S. deployment certificate.

## 1. Research contract

**Objective.** Specify evidence that binds a human-governed collective decision to an authorized public or organizational effect, while exposing the distinct unproved requirements of informed agency, effective political equality, lawful authority, and operational assurance (A/E/L/S). Quantify the minimum cost of sufficient evidence within a declared model, and how that cost changes after a legal, ballot, budget, source, or appeal change.

**Feasible set.** Finite organizations with explicit voting rules, an authenticated versioned decision, trusted attestations for facts the machine cannot establish, a specified effect vocabulary, and an atomic trusted enforcement sink. Binding student-organization or HOA votes are the first proposed pilots, conditioned on their actual governing rules. Government elections are not covered merely because the pilot works.

**Closest external reference checked this session.** ETH Zurich KOF/NOMIS supported democracy (2026–2031); Jansen et al., *Decidos* (CHI EA 2026); EAC VVSG 2.0 and its December 23, 2025 E2E evaluation process; NIST SP 800-63-4 (2025); National Academies, *Securing the Vote* (2018); Florida Statutes 720.317 (2026). URLs in Section 12. Closely related governance-to-execution and formal-verification traditions must also be evaluated before making priority claims.

**Best construction.** A typed reference passport with an external-election-proof interface, a lawful-authority interface, a current-world oracle, and a single-use atomic effect guard. The separately coded reference oracle checks 45,056 finite guard cases. A classical weighted-cover demonstration has an exact 18-unit joint certificate cost versus 22 isolated units, verified by brute force and DP. All costs are synthetic.

**Remaining gap.** No implemented E2E voting cryptography, ballot secrecy proof, endpoint malware defense, legal authority opinion, complete distributed effect-path audit, measured A/E, or actual institutional pilot. No human reviewer has independently assessed this construction.

**Novelty threshold.** A rigorous non-implication/cost lower bound for the coupled democratic assurance chain that cannot be recovered as an unmodified classical cover/authorization theorem, or a measured controlled pilot advantage under comparable threat/rights conditions. The present composition theorem and toy cost calculation do not satisfy this threshold.

**Independent audit plan.** Election-protocol specialist validates ballot evidence; election administrator or relevant organization officer verifies rules and eligibility; independent counsel assesses authority and rights; security assessor verifies guard completeness and race conditions; political scientists test A/E instruments and pre-register outcomes. Separate mathematical referee tests lower-bound hypotheses and prior-art overlap.

**Budget/stop rule.** No live binding pilot until institution-specific legal authorization, security audit, privacy threat assessment, accessible voting alternative, incident/appeal channel, and independent governance approval. Stop live execution after one confirmed bypass or unauthorized effect. Prototype further only in isolated simulation before these gates pass.

**Cheapest decisive next test.** Compare a valid cryptographic tally with (a) an unverified legal authority and (b) an authenticated current legal authority; evaluate whether an independently operated effect sink distinguishes the two. Add one controlled rule change, one stay, and one revocation between certification and execution; log completeness and cost.

## 2. The object and its trust boundaries

A **Democratic Assurance Passport** is a typed, scope-limited evidence bundle for a specific organizational decision, not an assertion that a government or human is legitimate in general. It is publicly inspectable insofar as secrecy and privacy allow. It does **not** expose ballots, voter identity-to-choice mappings, individually inferred political preferences, or private AI deliberation transcripts.

The bundle has four logically distinct domains:

- **A — Informed human agency (empirical):** preregistered comprehension and fidelity instruments; uncertainty, manipulation and accessibility tests; consented aggregate evidence. This is a research finding with a population, interval, and study design, never a machine-proved statement about every voter.
- **E — Political equality (formal + empirical):** proof of the formal franchise under the governing instrument; verified one-person/one-member/one-property rule **as actually authorized**; accommodations and demographic participation analyses. HOA shareholder/member votes are not interchangeable with universal equal citizenship.
- **L — Legal authorization (jurisdictional + procedural):** the operative source of governing powers; proposal/rule hashes; eligibility roster epoch; notice, quorum, threshold, final tally; external competent-authority and rights attestations; appeals, stays, expiration, and revocations.
- **S — Operational assurance (formal + engineering):** action binding, current-state evidence, least privilege, replay resistance, atomic enforcement, telemetry, auditing, and availability. Effects outside the modeled trusted sink invalidate universal soundness claims.

The source hierarchy is: operative official law or bylaws > authenticated decision records > independent specialist attestations > machine-checked derived claims > model-generated civic summaries. A model-generated legal explanation is never itself legal authorization.

## 3. Typed mathematical specification

Fix an institution `J`, a decision identifier `d`, a proposal digest `h`, voting rule digest `r`, a certified election result `v`, and relevant epochs `e=(e_roll,e_law,e_source,e_budget)`. The passport is

`P=(J,d,h,r,e,v,procedural_attestations,legal_attestations,permitted_effects,bounds,expiry,evidence_refs)`.

A current world is

`s_t=(J_t,d_t,h_t,r_t,e_t,t,stay_t,revoke_t,current_authority_t,current_budget_t,current_rights_t)`.

An effect request is `x=(J_x,d_x,effect_id,kind,amount)`. The `effect_id` is unique within the trusted sink.

Let the election component `VoteValid(P)` require an external verification certificate for eligibility and at-most-one valid vote, ballot recording/tally correctness under the adopted election protocol, and a threshold computation bound to the exact proposal and rule. The executable **toy** predicate additionally checks a simple yes/no fraction and integer quorum; it is not a universal legal election rule.

Define the effect permission predicate:

```
Permit(P,s_t,x) :=
   SameInstitutionDecisionAndProposal(P,s_t,x)
   AND SameVotingRuleAndEpochs(P,s_t)
   AND AttestedElectionCorrectAndHumanFinal(P)
   AND VoteRulePassed(P)
   AND CompetentAuthorityAndProcedureAttested(P)
   AND RightsAndFiscalAuthorityAttested(P)
   AND NoStayOrRevocation(s_t)
   AND CurrentAuthorityBudgetRights(s_t)
   AND IssuedAt(P) <= t <= ExpiresAt(P)
   AND InApprovedEffectScope(P,x)
   AND NonnegativeAmountWithinCeiling(P,x).
```

The reference guard commits only if `Permit` holds and `effect_id` has not already been consumed. The external trust assumptions include *truthfulness and completeness of source attestations*, *authenticity of source/version metadata*, *reliable final-state inspection*, *atomic inspect-and-commit*, and *complete mediation of all relevant effects*. These assumptions are not implied by possession of a hash or signature.

## 4. Theorem DAP-S1 — conditional soundness of effect-time permission

**Statement.** Let `T` be any finite sequence of transitions in a closed-world system. Suppose every relevant effect can occur only via the unique trusted sink; each sink transaction reads a coherent current-world state atomically with the effect; the evidence source predicates are faithful to the actual legal and administrative world; and the sink commits only when `Permit(P,s_t,x)` is true and `effect_id` is unused. Then for every committed effect `(x,t)` in `T`, there exists a passport `P` such that `Permit(P,s_t,x)` was true at the effect's linearization point. No effect ID commits twice.

**Proof.** Induct on the number of sink transitions. Initially the commit log and consumed-ID set are empty. A rejected transition modifies neither. At an accepted transition, the sink's implementation checks `Permit` and nonmembership in the consumed-ID set at the same atomic operation that appends `(x,t)` and adds the ID. Therefore the newly committed effect has a witnessing passport and no duplicate ID. Earlier commits retain their previously true time-indexed witness. Exhausting these cases completes induction. **QED under the stated premises.**

**What is not proved.** That the attested law is actually legally correct; that the voting protocol preserves privacy; that a member was free of coercion; that A/E thresholds hold; that every external API or human administrator obeys the sink; that a distributed source can furnish an atomic current-state view; or that legitimate actions always complete. These require separate verification and/or experiments.

**Provenance.** This is a straightforward invariant-preservation argument for the *new composition specification*. It must not be described as a worldwide novel theorem. More ambitious compositional transfer requires novelty review and full implementation verification.

## 5. Theorem DAP-N1 — evidence indistinguishability obstruction

**Statement.** If there are two legally admissible worlds `w+` and `w-` that yield exactly the same verifier observations but require opposite authorization decisions for an effect `x`, no deterministic verifier using only those observations can both allow `x` in `w+` and reject `x` in `w-`. The same holds with probability one for a randomized verifier if both perfect properties are demanded.

**Proof.** The verifier receives an identical transcript in both worlds, hence makes the same decision (or has the same distribution over decisions). That decision cannot equal both required opposite outcomes. **QED.**

**Concrete fixture.** Two worlds have the same proposal digest, election and tally records, and voting rules. In one the institution retains spending authority; in the other that authority has been withdrawn. A tally-only passport cannot decide the correct action. The extra current legal-authority evidence is necessary, or the verifier must abstain. The checker includes this pair.

This is the classical observational indistinguishability principle adapted to democratic assurance, **not a new discovery by itself**.

## 6. Corollary DAP-C1 — freshness and legal source updates

Let a passport certify an authority predicate at epochs `e`. If a relevant source changes to `e' != e` and the certified dependency closure includes that source, strict version matching rejects reuse of the old passport. After a separately verified source-invariance proof, a more permissive verifier may preserve unaffected evidence and only refresh the changed dependency cone. The current reference model uses the conservative rule of rejecting all epoch mismatches.

This connects to NIGHTFALL's existing exact finite-model change-stability and recertification results. **Their stronger conditional reuse theorems are not automatically transferred to public law**: legal semantics, authentic official changes, appeal rules and source completeness have not been formalized by the finite-world models.

## 7. Passport assurance gates: four individually typed outputs

A final DAP should produce an explicit status vector, not a misleading averaged score:

```
Agency = (population, protocol, outcome, uncertainty, limits, reviewer, status)
Equality = (formal_franchise, access_design, disparity_tests, limits, status)
Legal = (source_authority, jurisdiction, procedure, current_attestation, status)
Operational = (protocol_verifier, threat_model, mediation_scope, event_log, status)

JointAssured = all required gates approved independently for the SAME
institution, proposal, decision, and operating conditions.
```

The empirical gates must retain the sample population, confidence intervals and attrition/adversarial testing evidence. A formal `Legal=true` flag in the reference program is *only an input attestation*, not the output of a legal theorem. A `VoteValid` flag similarly represents an independently checked cryptographic artifact, not a ballot-proof implementation.

## 8. Privacy, coercion and equality limitations

Ballot secrecy and public proof are different data products. Publish commitments, proofs, tally certificates and decision-to-effect artifacts only insofar as they cannot be linked to identifiable voter choices. Proof passports must not contain political-preference embeddings, private model prompts, reidentifiable ballots, or identifying device telemetry.

Threats needing separate controls include malware at the voter's endpoint, credential theft, coercion, vote buying, denial of service, manipulated AI advice, inaccurate roster entries, quorum manipulation, server collusion, ballot challenge failure, and inaccessible alternatives. Organizational binding Internet votes may be legally available; this does not imply public-election suitability. The 2018 National Academies report warns that secure Internet return of marked ballots is not yet established by available technologies, and 2025-26 EAC protocol evaluation expressly separates mathematical E2E protocol approval from system-level suitability and security.

## 9. Joint assurance resource optimization

Let `Q` be the set of **technical** evidence obligations in a declared finite model and let an evidence operation `i` have cost `c_i` and cover a certified subset `S_i subseteq Q`. The minimum modeled evidence cover is

`C_tech* = min_{I subseteq operations} sum_{i in I} c_i subject to union_{i in I} S_i = Q`.

This is **classical weighted set cover**, so it does not constitute a new complexity result. The associated sample evidence portfolio has six obligations (`electorate, tally, legal, freshness, budget, effect`) and nine operation types. Separate standalone operations cost 22 abstract units. Shared evidence and a guarded sink cover the same obligations for 18 abstract units. Brute-force enumeration and a different bitmask DP return 18 exactly, a 4-unit (18.18%) modeled reduction. It is not a real deployment or human-cost estimate.

The dissertation target is broader:

`C_DA*(J,tau)=inf_{architecture pi} C_lifecycle(pi)`

subject to *separate* human-agency, equity, legal, and operational constraints, with empirically calibrated observation, citizen time, appeals, legal review, threat response, accessibility, cryptographic verification and maintenance expenses. Infeasibility is an admissible answer. Proving nonseparable lower/upper bounds for this system remains open.

## 10. Files, commands and reproducibility

From the package root, run:

```
python3 dap_finite_audit.py
python3 dap_cost_audit.py
python3 independent_audit.py
python3 finite_costs.py
python3 independent_cost_audit.py
```

Artifacts are `dap_model.py`, `dap_finite_audit.py`, `dap_cost_audit.py`, `dap_audit_receipt.json`, `dap_cost_receipt.json`, and the retained v0.1 programs and receipts. The SHA-256 manifest identifies the archived bytes. **No Lean compilation or operational external system testing has been performed for DAP v0.2.**

## 11. Gating review before a real binding pilot

A real student council/organization or HOA pilot requires: a governing-body resolution authorizing electronic ballots; independently reviewed organization-specific election rules; legally sound eligibility and duplicate-vote controls; cryptographic protocol selection and independent evaluation; privacy and coercion threat assessment; disability-accessible voting alternatives; complaint/recount mechanisms; delegated authority for any effect; atomic effect-time integration and external-effect inventory; approved participant research ethics where research data are collected; public incident disclosure and shutdown procedure. Federal/state municipal public voting requires a separate standards and statutory assessment.

The pilot must separately establish the prespecified human-agency and equality evidence before making joint assurance claims. An adverse result on either gate is a valid scientific outcome.

## 12. Primary and closest prior-art anchors

- ETH Zurich KOF / NOMIS, *Trustworthy AI Voting Assistants and Supported Democracy* (2026–2031): https://nomisfoundation.ch/projects/trustworthy-ai-voting-assistants-and-supported-democracy/
- Jansen, Schraffenberger & Jacobs, *Decidos: Accessible, Usable and Secure Voting in Low-stakes Elections Using Identity Wallets* (CHI EA 2026), DOI: https://doi.org/10.1145/3772363.3798937
- U.S. EAC, *End to End Protocol Evaluation Process* (2025-12-23): https://www.eac.gov/voting-equipment/end-end-e2e-protocol-evaluation-process
- U.S. EAC, *Voluntary Voting System Guidelines* v2.0: https://www.eac.gov/voting-equipment/voluntary-voting-system-guidelines
- NIST, *Digital Identity Guidelines*, SP 800-63-4 (2025): https://csrc.nist.gov/pubs/sp/800/63/4/final
- National Academies, *Securing the Vote* (2018): https://www.nationalacademies.org/news/securing-the-vote-new-report
- Florida Legislature, Florida Statutes s. 720.317 (2026): https://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&Search_String=720%2F&SubMenu=1&URL=0700-0799%2F0720%2FSections%2F0720.317.html&mode=View+Statutes
- NIGHTFALL, *The Price of Permission*, v0.3: https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-price-of-permission/THEOREM_INTEGRATION_v0_3.md
- NIGHTFALL, *Change-invariant authority*: https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-change-invariant-authority/THEOREM.md
- NIGHTFALL, *Compositional recertification*: https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-compositional-recertification/THEOREMS_AND_PROOF_AUDIT_V02.md

**Priority status:** External references supply components and benchmarks. No independent referee has yet verified global novelty for a new democratic assurance theorem or system. Attribution is deliberately retained for every inherited mechanism.