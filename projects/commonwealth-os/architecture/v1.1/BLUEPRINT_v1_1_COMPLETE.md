# COMMONWEALTH OS
## A democratic operating system with proof-carrying public authority

**The Constitution of Computational Commonwealths: A Blueprint for Human-Sovereign Governance in the Age of Synthetic Autonomy**  
**NIGHTFALL / Commonwealth — Integrated architecture blueprint v1.1 — 15 November 2026**  
**Status:** proposed system architecture; not a production voting system, accepted legal opinion, security certification, or established proof of four-way democratic feasibility.

> **Mission.** Enable institutions to propose, explain, debate, amend, vote on, certify, and carry out collective decisions while preserving human sovereignty. Attach an independently checkable Democratic Assurance Passport (DAP) to each material decision. Learn, under controlled deployment, what it costs to satisfy informed agency, political equality, legal authorization and operational assurance simultaneously.

**Release definition:** “OS” means a federated *governance application and protocol platform*, not a replacement for a computer's kernel, a general purpose operating system, or a sovereign institution. A Commonwealth deployment never acquires greater powers than its legal host institution.

**First wedge:** binding, in-platform organizational voting at an authorized university student council or student association. **Second:** authorized HOA/member-association votes. **Third:** municipal legislative workflow, public consultation and representative voting, plus citizen ballot functions only where separately lawful and independently certified. The 2030 US aspiration is interoperable *institutions and evidence*, not assumed nationwide legal authority for online public voting.

---

## Repository reconciliation and decisions (checked 2026-11-15 18:35 EST)

**Existing canonical workspace:** [`projects/commonwealth-os/`](https://github.com/d3lefts/d3lefts/tree/main/projects/commonwealth-os), main commit [`17571cf14e49`](https://github.com/d3lefts/d3lefts/commit/17571cf14e49a76c599b0e7f98a769699b1314d9). The repo already contains `BLUEPRINT_v1_0.md`, the implementation/release plan, municipal ingestion freeze, administrator PRD, three-pilot charter, and civic-question standard. The latest relevant commit was a parallel design baseline merged to main. No open Commonwealth-named pull request was found among 15 open PRs as of this check.

**Compatibility:** Keep the existing mobile-first PWA, modular monolith, source-versioned legislative workspace, reviewed public publishing, consent-scoped civic preferences, vendor-neutral election adapter, and disabled municipal ingestion. These are not replaced.

**Intentional changes:** `DEMO` ballots remain for testing, but authorized binding organizational votes are now the **first production pilot**; no general-public binding municipal Internet ballot is assumed. Pilot progression is **university student councils/organizations → HOAs → city councils**. Other universities may replicate the first stage. Huntsville City Schools, if later included, is a **separately authorized optional research lane** requiring safeguarding of minors; it is not a required step in this new release sequence.

**New artifact:** `DemocraticAssurancePassport` binds an authenticated voting result to legal authority and exactly scoped actions; it carries separate empirical claims for informed agency/equality and verifiable technical predicates for the transaction. It inherits v0.3 finite-model CR1/CR2/CR3/CR4 without claiming they constitute new universal mathematics.

**Priority conflict to resolve before release:** the existing v1.0 pilot charter calls every pilot advisory before a separate adoption gate. That remains the **default safety state**, but it no longer forbids an institution from explicitly adopting binding in-platform elections after the gate is satisfied. Institutional approval, legal review, independent election protocol assessment, and operational audit are required. This blueprint is a design change proposal; it is not itself an institutional authorization.

**Authority of this document:** design specification, not source code in a deployed voting system. The finite sample guard in `tests/` is a deliberately limited executable model. Its success must not be described as cryptographic or legal certification.


## 1. Product contract and research boundary

### 1.1 Four simultaneous requirements

| Requirement | Product commitment | Evidence type | What the software cannot certify by itself |
|---|---|---|---|
| **A — informed agency** | Every voter can see the authentic text, opposing perspectives, uncertainty, and an AI-off path; nobody's vote is cast by the assistant. | Preregistered comprehension/preference-fidelity studies, content audits, adversarial AI experiments. | Inner autonomy or whether a citizen truly understands. |
| **E — political equality** | Eligibility and vote weight follow the valid rules; access is supported across device, disability, language and connectivity constraints. | Franchise audits, accessible usability testing, disparities and burden measurements. | Substantive equality or absence of social coercion. |
| **L — legal authorization** | Every binding procedure and consequential action is linked to a valid institutional rule and responsible human official. | Verified primary rule documents, election records, counsel/authorized officer attestations and challenge process. | Contested constitutional interpretation or rights questions. |
| **S — operational assurance** | Independent vote verification, append-only authenticated events, typed passport, current authorization checks and effect guarding. | Cryptographic protocol evidence, security assessments, model checks, guard coverage tests, receipts. | Security of unmanaged voter endpoints or effects outside the guard. |

These are **AND-gates**, not a weighted single democracy score. Positive averages cannot excuse a failed legal, security, privacy or equal-access condition. Policies may set research thresholds in advance; the designers cannot invent legal validity by selecting a convenient threshold.

### 1.2 Non-negotiable controls

1. Human final voting authority. AI may summarize, draft and simulate, but no autonomous legal vote, fabricated consent, or undisclosed preference steering.
2. No hidden voter profiling. The optional living-voter issue survey is distinct from the ballot; the 96-item research instrument (1 priority + 70 seed + at most 25 adaptive prompts) is never a precondition for voting. Citizens affirm **support / oppose / no preference** explicitly; relevant policy changes trigger transparent requests for reassessment. No inferred ideology is exported for campaign targeting.
3. Separated identity and vote records. The organization can establish eligibility without learning a person's secret ballot; public DAP data contain no per-voter choices, identity linkages, or private AI conversations.
4. Machine evidence never substitutes for human legal authority. The legal adapter is backed by authoritative records and designated officials; unresolved ambiguities require human review.
5. Every modeled effect is mediated atomically by a current authorization gate. Non-integrated/off-platform effects are reported as **outside certification**, not silently assumed secure.
6. Contestability: correction, reconsideration, appeal, public challenge and auditable remediation are product primitives.
7. Open standards and replaceable components: cryptographic election engines, identity providers, AI models, and official records systems are replaceable without rewriting governance semantics.

### 1.3 Explicit non-goals for the first release

No state/federal public Internet-ballot return; no replacing existing government election authorities; no automatic constitutional adjudication; no general-purpose AI government; no mandatory national civic identity; no blockchain token as a source of political rights; no claim of a proof of national democratic legitimacy.

---

## 2. Actors and initial product surfaces

**Mobile-first** but web-accessible, with offline-information alternatives and independently supervised accessible ballot options where required.

| Actor | Primary screen | Can do | Cannot do |
|---|---|---|---|
| Member / student voter | My ballot and issues | Read source, deliberate, submit proposals, cast binding ballots when eligible, review verification receipt | Change official rules or see another person's secret vote |
| Representative / senator / council member | My legislative workbench | Sponsor, amend, debate, take public roll-call votes when lawfully meeting | Substitute an AI vote or approve private effects outside authority |
| Clerk / legislative administrator | Agenda and document control | Publish authoritative text, manage notice, freeze agenda, maintain minutes | Unilaterally rewrite a certified result |
| Election administrator | Election operations | Publish eligible roll commitment, open/close election, arrange verifiers | Correlate secret selections to voter identity |
| Legal officer / designated authority | Legal and procedural review | Attest jurisdiction, procedure, applicability, review/stay status | Override a failed cryptographic tally certificate |
| Treasurer / agency executor | Action queue | Request an effect within approved scope | Execute with stale passport or without guard approval |
| Independent auditor | Public verification console | Fetch evidence roots, reproduce tally check, review DAP and execution receipts | Obtain raw secret ballots, issuer linkage tables or AI-private profiles |
| Operator / vendor | Operational controls | Maintain service and incident response under separation of duties | Mint governing powers or bypass two-person deployment approvals |

**Initial five screens:** (1) Representative Today, (2) Ordinance/Resolution Workspace, (3) Debate & Amendments, (4) Binding Vote, (5) Democratic Assurance Passport & Action Ledger. A sixth citizen Living Voter dashboard is opt-in and incrementally exposed as the pilot's authorizing institution allows.

### 2.1 Representative Today — initial dashboard

Top row: pending legislative tasks, approaching votes, procedural deadlines, currently stayed decisions, execution exceptions. Main feed: proposal text version/diff, official sources, amendments with sponsors, discussion and required decisions. AI copilot panel: **draft explanation**, **find conflicting authority**, **simulate fiscal scenario**, **construct argument against my draft**. Outputs are visibly AI-generated, cite source digests, and cannot change authoritative records unless accepted by an accountable human.

### 2.2 Living voter dashboard

Displays jurisdiction and currently applicable ordinances; personally selected policy topics; pending proposed changes; explanations grounded in citations; accessible views for contrary arguments and estimated costs; a clear ballot interface when an actual election is open. Private preference responses are stored separately from ballot proofs. A user can opt out of personalization entirely without losing voting eligibility.

---

## 3. Five-plane architecture and trust boundaries

![Commonwealth OS five-plane reference architecture](assets/commonwealth_os_architecture.svg)

### 3.1 Citizen and representative plane (untrusted client)

Native mobile or progressive web app, accessible public portal, representative workspace, notices and client-side encryption where feasible. The browser and smartphone are **not trusted** to enforce legal eligibility or guarantee secrecy. Any ballot claim must be verified independently of the client.

### 3.2 Civic intelligence plane (advisory and isolated)

Retrieval over immutable official documents with citations; version-aware ordinance summaries; deliberately balanced argument construction; machine-readable fiscal assumptions; optional personal preference context held in a separate consent-scoped store or on-device. All retrieved documents and user-submitted content are untrusted model input. The AI is denied signing keys, direct vote endpoints, voter-identity joins and effect credentials. A model output is not legal evidence.

### 3.3 Democratic process plane (institution-bound)

Event-sourced proposal and amendment records, calendar/notice, deliberation, voting procedure profiles, eligibility snapshot, isolated ballot subsystem, independent tally verification and contest procedures. **Three distinct voting modes:**

- **Secret member ballot:** elections, amendments or propositions where the governing procedure requires confidentiality; eligibility/ballot records must not be joinable.
- **Recorded representative roll call:** individual public votes when required by law or governing rule, with notice/minutes and meeting constraints; anonymous ballot protocol is not appropriate.
- **Advisory public expression:** nonbinding polling, issue surveys and consultations; never represented as official elections.

### 3.4 Constitutional / DAP plane (verification and legal sources)

Per-institution legal adapters with signed, time-effective rule versions; procedure engine; DAP compiler; static formal checkers; change-impact dependency graph; semantic reuse evaluator from DAP-CR1; lawful/privacy-compatible evidence selector from DAP-CR2; appeals/stays registry; non-automated legal override *with recorded accountable human basis*, never an unlabeled admin bypass.

### 3.5 Effect plane (trusted boundary)

An atomic execution gateway bound to the decision ID, proposal and rule digests, certified election, lawful jurisdiction and current challenge/budget epochs. Sandbox effect examples: posting an approved resolution to an institutional register, scheduling a valid publication, or authorizing a mock expenditure. Live banking, payroll, physical operations, permits and city systems require dedicated reviewed adapters, complete mediation tests and owner consent.

**Trust boundaries:** B1 client ↔ identity provider; B2 eligibility issuer ↔ ballot service (no shared selection-level identifiers); B3 AI ↔ primary sources (no authority); B4 public DAP ↔ private evidence vault; B5 legal attestations ↔ effect guard (must authenticate human issuers); B6 effect guard ↔ external system (every actual side effect must be covered).

---

## 4. Domain model, state machines and event contracts

### 4.1 Immutable identifiers and authoritative versions

Every substantive decision references `tenant_id`, `institution_id`, `jurisdiction_id`, `rule_profile_id`, `rule_digest`, `proposal_id`, `proposal_digest`, `electorate_snapshot_digest`, `election_id`, `election_proof_ref`, `authority_epoch`, `challenge_epoch`, `budget_epoch`, and `effect_scope_digest`. Digests are of canonical, versioned bytes. An event records its schema version, causal parent, issuing human/system identity and authenticated timestamp.

**Foundational rule:** changing even one word of a frozen ballot's authoritative proposal **creates a new proposition version**. The interface may show redlines, but it must never silently remap old ballots to a different text. Corrections after election opening require a specific, pre-authorized election rule and visible audit.

### 4.2 Proposal / decision lifecycle

`DRAFT → SPONSORED → PROCEDURAL_REVIEW → PUBLISHED → DELIBERATING → FROZEN → VOTING → CLOSED → TALLY_VERIFIED → LEGAL_CERTIFIED → EFFECTIVE → SUPERSEDED`

`REJECTED`, `WITHDRAWN` and `INVALIDATED` are explicit terminal or review states as specified by the procedure. `STAYED` and `CONTESTED` are **orthogonal effect-gating states**, not silently erased by a favorable tally. An institution may lack one or more phases; its authorized procedure profile must document those differences before voting opens.

Guards on transitions include eligibility to sponsor, notice deadlines, official text publication, amendment closure, valid electorate snapshot, quorum and threshold expression, independent tally evidence, human certification, applicable effective date and an appeal window.

### 4.3 Election lifecycle

`CONFIGURED → INDEPENDENTLY_REVIEWED → ROLL_FROZEN → OPEN → CLOSED → CRYPTO_VERIFIED → CERTIFIED/CONTESTED`

Election parameters—including ballot style, quorum, voting window, revoting rules, anonymous/roll-call mode, credential eligibility, tally function and dispute policy—are signed before `OPEN` and frozen. A mode switch requires a new election, not an implicit reconfiguration. A vote receipt cannot encode the secret choice in a publicly identifiable way.

### 4.4 Events and read models

Canonical append-only event examples:

```text
ProposalVersionPublished   (decision_id, proposal_digest, source_refs)
ProcedureFrozen           (decision_id, rule_digest, election_profile_digest)
ElectorateCommitted        (election_id, eligibility_root, valid_from)
ElectionOpened            (election_id, opening_time, observers)
ElectionClosed            (election_id, closing_time)
TallyVerified             (election_id, proof_ref, independent_checker_version)
AuthorityAttested         (decision_id, legal_basis_refs, scope, epochs)
ChallengeFiled            (decision_id, challenge_type, effective_stay)
AuthorizationReevaluated  (passport_id, dependencies, reuse_proof_ref)
EffectRequested           (effect_id, decision_id, payload_digest, idem_key)
EffectCommitted           (effect_id, guard_receipt, external_ack_digest)
EffectRejected            (effect_id, reason_code)
```

Derived search indices and read models are rebuildable from authoritative events; they are not sources of independent legal truth. Confidential election secrets are **never** placed into the general event log.

---

## 5. Binding voting protocol: integrated experience, isolated security

**The user casts the vote within Commonwealth OS.** The balloting engine remains a separate independently reviewed security component, so app convenience cannot quietly expand its trust base.

1. **Adopt procedure:** authorized officer attests election mode, franchise, secret/recorded requirements, appeal rules and institutional power.
2. **Freeze election:** hash proposal text/rules, electorate eligibility epoch and ballot presentation. Publish public commitments and audit schedule.
3. **Prove eligibility:** authenticate through the institution's provider; issue one election-scoped voting right using an independently reviewed eligibility/credential flow. Issuance logs never contain vote selections.
4. **Cast:** citizen intentionally confirms a choice; a dedicated ballot interface submits a protected ballot. Cast/recorded receipt must not reveal vote choice. Accessibility and alternate channel requirements are institution-specific and mandatory when applicable.
5. **Verify:** allow voter inclusion checks and independent tally verification using the chosen reviewed election protocol. Do not invent a custom novel election cryptosystem in v1.
6. **Certify and contest:** named election officials publish certification, verification reports, participation denominators and challenge outcomes before legal authority is issued.
7. **Guard effects:** the DAP binds the certified decision to an effect request and current institutional/legal status.

**Do not claim:** that login via passkey establishes anonymous voting, that “on-chain” storage ensures ballot secrecy, that end-to-end verifiability implies coercion resistance, or that a cryptographically valid tally legalizes an unauthorized franchise. Device compromise, intimidation, coercion, disenfranchisement and operational failures remain in scope for security and human review.

### 5.1 Election subsystem adapter

```text
ElectionAdapter.createElection(electionProfile, frozenDigests) -> electionId
ElectionAdapter.proveEligibility(issuerAssertion) -> electionScopedCredential
ElectionAdapter.castProtectedBallot(credential, encryptedBallot) -> opaqueReceipt
ElectionAdapter.close(electionId) -> immutableClosure
ElectionAdapter.publishProof(electionId) -> proofPackageRef
IndependentVerifier.verify(proofPackageRef, frozenDigests) -> VerifierResult
```

The adapter is implemented only after selection of an existing maintained protocol, threat model and legal review. Cross-origin isolation and independent administrative credentials prevent the civic AI from modifying ballot data.

---

## 6. Democratic Assurance Passport contract v1.1 (inherits mathematical v0.3)

### 6.1 Passport is a proof manifest, not a magical proof

The DAP publishes **typed claims** with pointers to authoritative evidence and separately verifiable checkers. Every claim has `predicate`, `scope`, `assumptions`, `evidence_ref`, `checker`, `result`, `expiry`, `dependencies`, `reviewer`, `claim_status`. A positive JSON schema check only establishes structural validity, never legal or cryptographic correctness.

DAP components:

- **Human evidence**: experiment or evaluation protocol, population, confidence interval, limitations; may be `not-conducted` without falsifying the tally proof.
- **Equality evidence**: formal franchise rules, eligible/participating aggregates where privacy permits, accessible options, empirical disparity reports; no identifiable ballots.
- **Election evidence**: immutable proposition/rules snapshot, eligibility commitment, tally/proof, independent verifier, contest record.
- **Authority evidence**: primary legal documents, named responsible signatories, effective dates, quorum and process, court/appeal status.
- **Effect evidence**: exactly permitted operations, scope and budgets, model time/epochs, guard code hash, independent complete-mediation status and execution receipts.

**Claim statuses:** `UNASSESSED`, `PROVISIONAL`, `FORMALLY_CHECKED_IN_MODEL`, `INDEPENDENTLY_REVIEWED`, `FAILED`, `SUPERSEDED`. No status is upgraded solely because another type of evidence passed. Public dashboards show unknown and disputed results rather than collapsing them into “verified”.

### 6.2 Core safety invariant (inherited DAP-S1)

Let `Executed(x,t)` mean an actual effect is committed through a fully mediated trusted sink. In the closed model:

```text
Executed(x,t) ⇒ ∃p : Bound(p,x) ∧ ElectionValid(p) ∧
                  LegalAuthority(p,t) ∧ NoEffectiveStay(p,t) ∧
                  CurrentEvidence(p,t) ∧ WithinScopeAndBudget(p,x,t)
```

**Conditional proof:** a trusted, complete, linearizable effect guard checks all predicates against one current serializable snapshot before committing. Every modeled committed effect therefore satisfies the predicate in that snapshot. This does not prove the external assumptions: completeness of mediation, correctness of signed legal facts, election secrecy, absence of out-of-band acts, or correct integration with external payment systems.

**Always bind authorization to effect bytes**, not just a descriptive action label. Idempotency key, action digest and external acknowledgement prevent replay/TOCTOU surprises. Revocation and payment/approval races must be linearized at the same effective commit boundary; if not technically possible, the effect is not certifiable under this invariant.

### 6.3 Change-stable semantic reuse (inherited DAP-CR1–CR4)

For finite ballot worlds `b`, retained authenticated transcript `T(b)` and *legally applicable* changed-rule authorization vector `F'(b)`:

```text
Retained election evidence is sufficient for the new decision ⇔
for all b,b': T(b)=T(b') ⇒ F'(b)=F'(b').
```

If false, the minimum **nonadaptive, universal-correctness** supplementary election-information cost is the minimum weight of lawful truthful queries distinguishing all equal-transcript/opposite-authority world pairs (weighted set cover). If privacy rules prohibit enough queries, the outcome is `INDETERMINATE` and execution is blocked. Legal review, voters' agency, political equality and effect costs are **not** included in that acquisition price.

Public query invariance under voter permutation only implies permutation-invariant outputs, not comprehensive ballot privacy. Separately private logs may leak when joined; therefore privacy analysis covers the combined published transcript, receipt metadata, AI interactions and auxiliary data.

### 6.4 Proof-carrying decision routine

```text
function authorizeAndExecute(passport, effect, now):
    assert validSignedInstitutionalRules(passport)
    assert proposalAndTallyReferToIdenticalFrozenBytes(passport)
    assert independentlyVerifiedBallotResult(passport)
    assert lawfulCurrentAuthorityAndProcedure(passport, now)
    assert noEffectiveStayOrRevocation(passport, now)
    assert effectBytesWithinPermittedScope(passport, effect)
    assert independentlyReviewedCompleteEffectAdapter(effect.kind)
    snapshot = acquireSerializableCurrentAuthoritySnapshot()
    if dependenciesChanged(passport, snapshot):
        outcome = assessSemanticReuseOrRecertification(passport, snapshot)
        if outcome != CERTIFIED: return BLOCK_AND_ESCALATE
    return commitEffectAtomicallyWithGuard(passport, effect, snapshot)
```

This is normative pseudocode, not a complete API or production security implementation.

---

## 7. Security, privacy, accessibility and operational controls

### 7.1 Key threats and responses

| Threat | Principal control | Independent evidence needed |
|---|---|---|
| Identity impersonation or duplicated eligibility | Federation with appropriate NIST assurance, election-specific credential accounting, separated issuer and ballot server | Third-party identity and credential review |
| Ballot tampering / incorrect tally | Adopted end-to-end verifiable protocol and independent verifier; audit procedures | Protocol-specific proofs and penetration tests |
| Identity-to-secret-ballot linkage | Organizational and technical separation, minimal telemetry, no shared join key, noncorrelating credential design | Joint privacy review against side information and logs |
| Prompt injection / AI misinformation | Source isolation, quotations linked to frozen primary text, no model privileges, counterargument and AI-off options | Red-team tests, factual evaluation, human studies |
| Coercion, accessibility, digital exclusion | Suitable alternative channels, notice, accessible clients and recourse | User research and external election counsel |
| Proposal swapped after voting | Signed proposal digest frozen at election start; independent display hash and binding | Adversarial document-diff tests |
| Stale or revoked authority | Change dependency graph, semantic reuse only when applicable, current effect-time guard | Race tests, legal review, verified adapters |
| Clerk/operator compromise | Separation of duties, 2-person sensitive approvals, HSM/KMS, audit anchoring | Security audit, recovery exercises |
| Financial or administrative effect bypass | Complete mediation inventory and deny-by-default connectors | Independent production effect-path inspection |
| Centralized civic surveillance | No cross-jurisdiction superprofile, local consent controls, minimization, enforceable deletion schedule | Privacy impact assessment and adversarial linkage tests |

### 7.2 Data partitions

- `public_registry`: signed rules, proposal versions, certified aggregate outcomes, legal attestations, public DAP, action receipts with necessary redactions.
- `identity_vault`: user identities, credentials, institution roles, eligibility claims. Restricted personnel and retention schedule.
- `ballot_vault`: cryptographic election material protected by the selected protocol; no personally linkable choice records exposed to the normal application.
- `personal_ai_store`: opt-in private issue preferences and conversation metadata; not automatically synchronized into public political records, elected officials' dashboards, or voter lists.
- `assurance_store`: signed evidence bundles, checker versions, scope, expiry, dependency graphs and audit findings.

**All secrets have a documented key owner, revocation/rotation procedure, backup, retention limit and recovery plan.** No single vendor administrator can both alter the election result and certify that alteration.

### 7.3 Public reproducibility

Publish stable schemas, verifier specifications, fixture datasets, versioned source code and reproducible audit commands. Keep independent verifier builds separate from the production application and publish negative/failed assurance receipts. Open-source transparency is valuable, but does not independently establish secure deployment.

---

## 8. Architecture decision records

**ADR-001 — Federated multi-tenant core.** One standards-based governance kernel, separately administered legal adapters and electorates per institution. A tenant cannot assert another's legal powers.

**ADR-002 — Event sourcing with signed snapshots.** Historical truth is an append-only sequence of authorized events. Sensitive ballot/identity data are partitioned away from that log. Public transparency is not equal to indiscriminate publication.

**ADR-003 — Pluggable independent election engine.** Reuse and appropriately attribute existing cryptographic voting work. Never improvise a new secret-ballot cryptosystem for an actual binding pilot.

**ADR-004 — AI advisory-only.** Human approval is required for every authoritative change. AI may not hold election or public-effect private keys.

**ADR-005 — DAP is a projection and independently checkable contract.** It cannot rewrite an election or fabricate a legal judgment. Its verified status is bounded by underlying attestations and evidence.

**ADR-006 — Guard before effect.** Consequential adapters accept only a current, effect-bound DAP. Dry-run/sandbox first; no unguarded alternate APIs.

**ADR-007 — Semantic reuse is opt-in and legally conditioned.** When a rule changes, a legally responsible person establishes applicability. Only then may DAP-CR1/CR2 reuse election evidence without a new vote.

**ADR-008 — Dual execution modes.** Secret citizen/member elections and recorded representative roll calls have different confidentiality obligations and must never share a generic ballot configuration that erases the distinction.

**ADR-009 — One public audit trail, no one national political dossier.** Federation shares schemas and certificate proofs, not person-level preference histories.

**ADR-010 — Community governance and capture safeguards.** Public roadmap, open licensing subject to compliance review, independent audits, transparent funding and vendor changes, independent review board, and nonpartisan access rules.

---

## 9. Implementation contracts and storage

### 9.1 Suggested initial stack (replaceable, not a mandatory procurement)

- `clients`: TypeScript mobile-first PWA with accessible components; native wrappers only when essential.
- `services`: TypeScript or Rust backend; strict API schema validation, per-tenant policy enforcement.
- `transactions`: PostgreSQL for source-of-truth procedural state, serializable transaction for guard decisions; separate election protocol data store.
- `events`: transactional outbox to an append-only, cryptographically chained, externally checkpointed log.
- `objects`: versioned, content-addressed documents and evidence bundles in immutable storage.
- `AI`: model-independent RAG service with retrieval audit and policy-sandbox tools, no privileged actions.
- `verifiers`: standalone Python/Rust/Lean-compatible proof checkers with deterministic fixtures; source-version and toolchain pins.

For portability, expose a documented GraphQL/read API and narrowly scoped REST/command endpoints. Do not adopt microservices before there is a specific isolation or scaling justification.

### 9.2 Draft API surface

```text
GET  /v1/tenants/{id}/public-rules
GET  /v1/decisions/{id}/versions
POST /v1/decisions/{id}/amendments             [authorized human]
POST /v1/decisions/{id}/freeze                 [clerk + independent check]
POST /v1/elections                            [authorized election officer]
POST /v1/elections/{id}/open                   [two-person confirmation]
POST /v1/elections/{id}/cast                   [isolated election adapter]
GET  /v1/elections/{id}/public-proof           [anyone]
POST /v1/elections/{id}/independent-verify     [external verifier service]
GET  /v1/passports/{id}                       [public redacted claims]
POST /v1/passports/{id}/challenge              [eligible challenger]
POST /v1/effects/authorize-and-commit          [trusted sink only]
GET  /v1/effects/{id}/receipt                  [authorized disclosure]
```

Live `cast` semantics and verifiers depend on the selected election engine; no unsecured public API should accept arbitrary plaintext votes with identity tokens.

### 9.3 Concrete machine artifacts in this package

`spec/dap_v1_1.schema.json` defines the public proof-manifest structure; `spec/procedure_profile.example.json` documents a synthetic university governance rule; `spec/event_contracts.json` lists critical events and payload requirements; `spec/acceptance_matrix.csv` connects failure cases to proof obligations. `tests/reference_guard.py` is a toy authorization state-machine model and `tests/test_reference_guard.py` tests its stated invariants. These artifacts describe and exercise the blueprint but are **not** an election backend.

---

## 10. First end-to-end vertical slice

**Scenario:** a consenting university student organization votes on and approves a binding internal allocation of fictional funds. A human clerk publishes a resolution; voters cast ballots inside the app through a designated isolated voting component; an independent verifier attests the tally; a designated official supplies procedural/legal authority; an executor requests an action; a DAP guard allows or blocks the simulated action.

**Acceptance sequence:**

1. A clerk publishes `Proposal v1` and cites its governing rule.
2. A sponsor introduces a valid amendment; the frozen final text receives its own digest.
3. A binding organization ballot runs under an explicitly adopted election procedure; eligible members can verify proper inclusion without revealing choices to the public.
4. An independent verifier produces a result referencing the frozen proposal and procedure.
5. A responsible officer issues authority scoped to `publish-approved-resolution` and a maximum simulated expenditure.
6. The DAP compiler emits a redacted public manifest with signature/evidence references.
7. A sandbox executor commits one valid effect and produces a receipt.
8. A retroactive change in rule text triggers either lawful semantic evidence reuse (if `CR1` holds), lawful supplemental recertification (if `CR2` is feasible) or an `INDETERMINATE` block.
9. A legal stay blocks a previously valid but not-yet-committed effect; the logged ballot outcome remains unchanged.
10. Cross-proposal replay, tampered text, double effect, wrong jurisdiction, stale epoch, and rule-conflict attempts are rejected.

**Negative controls:** swapped secret-vote and roll-call modes; a source-cited AI fabricated quotation; issuer/ballot metadata linkage; duplicate eligibility token; simultaneous stay and expenditure request; high-contrast/screen-reader failures; offline disenfranchisement; bypass through direct external API. Failures must not be concealed by a passing tally test.

### 10.1 Pilot release gates

| Gate | Required evidence before live binding vote | Consequence of failure |
|---|---|---|
| Institutional authorization | Governing documents reviewed; signed approval for binding online election; recorded franchise and appeal procedures | Advisory/sandbox mode only |
| Election independence | Reproducible independently evaluated protocol, valid threat model, audited custody and tally procedures | No binding vote |
| Privacy and equality | Joint evidence privacy assessment; applicable accessibility and alternative access; relevant group participation audit | Suspend or redesign pilot |
| DAP correctness | Reproducible guard tests and external review of mediation boundaries | No consequential effect adapter |
| Human accountability | Named officers, incident ownership, review/correction and recusal processes | Do not launch |
| Research integrity | Ethics approval where required, preregistration, separation of product analytics from political persuasion | No human-subject experiment |

---

## 11. University → HOA → Municipal ladder

### Phase U — university councils and organizations

Choose a cooperating student organization/council able to amend or lawfully adopt its own electronic voting procedure. Begin with binding *internal* resolutions. Student-government institution-wide authority is not assumed; the University of Alabama SGA's own published procedures must be followed or formally changed. Treat outcome, election security, and agency/equality research as separate study endpoints.

### Phase H — HOA or comparable membership governance

Add property/membership franchise semantics, proxies when permitted, statutory notice, member consent, accessibility, dispute workflows and document-retention requirements. Florida's 2026 section 720.317 allows online association voting subject to detailed requirements including consent, authentication and advance device connectivity checks. Local counsel must verify every clause in the deployed jurisdiction. HOA voting can be valid association governance without being a general model of equal one-person-one-vote citizenship.

### Phase M — municipal governance

Initially support ordinance drafting, public comment, legal procedure, administrative work, public minutes and recorded council votes **within existing law**. Alabama's Open Meetings Act constrains when and how local government members participate electronically; where section 36-25A-5.2 applies, remote attendance has conditions including physical quorum, advance policy and audible roll-call voting. Do not silently turn an online secret citizen vote into a municipal ordinance. Citizen-initiated binding local lawmaking requires a specific applicable legal grant, election-law compliance and robust election-security review.

### Nationwide 2030 goal

Open, independently auditable protocol and reference implementation; multiple separately authorized pilot institutions; public evidence on cost and four-way joint requirements; state-by-state legal capability map; transparent proposals for statutory changes **only where needed**. Federal reforms may be helpful for standards and funding, but local governmental powers and elections also require state/municipal legal analysis.

---

## 12. Research evidence program and stop rules

**Paper I — constitutional legitimacy:** compare real legal procedure profiles and derive what the OS can/cannot authorize across institution types; formalize appeal, rights, authority and transition conditions.

**Paper II — human agency and equality:** preregister experiments comparing primary documents, generic AI and a privacy-preserving personal civic assistant; measure comprehension, preference fidelity, opposing-argument recognition, participation burden, access and differential effects. Do not infer political preferences or evaluate personal ideology without informed consent.

**Paper III — cost of Democratic Assurance:** estimate and bound incremental evidence, staffing, cryptographic verification, legal review, contested decisions, fresh authorization, audit and remediation costs. Replicate DAP-CR1/2 over actual procedural changes; seek a nontrivial joint lower/upper bound or characterize infeasibility. Full lifecycle cost **is not** the same as ballot-query cost.

**Pre-registered comparison:** baseline verifiable online ballot + ordinary approved organizational workflow vs. same voting protections + a DAP/effect-guard integration. Measure all four requirements rather than only deployment throughput. No originality claim without independent close-prior-art audit and reproducible separation.

**Stop rule:** any unmediated effect, unrepairable privacy leak, unsupported legal power, unfair franchise/access failure or demonstrated systematic AI manipulation suspends the corresponding deployment. Continue research via safe sandbox or advisory trials.

---

## 13. Build order and owner roles

| Milestone | Shippable artifact | Dominant open risk |
|---|---|---|
| **M0 — foundations** | Tenant/procedure model; canonical documents, digest verification, auditable event log; public API | Correct authority modeling |
| **M1 — legislative workbench** | Clerk/representative tasks; proposal amendments, version freezes, original-source citation; AI-off mode | Source attribution and rights handling |
| **M2 — isolated election adapter** | End-to-end organizational ballot under approved rules, independent verifier, election-proof reference | Secret-ballot integrity and accessibility |
| **M3 — DAP + sandbox effects** | Typed proof manifest, stay/revoke events, semantic reuse, effect guard and receipts | Complete mediation and linearization |
| **M4 — externally reviewed pilot** | Authorized binding vote, accessible alternatives, public audit and incident exercises | External approval and legitimacy evidence |
| **M5 — replication** | HOA legal adapter, cost telemetry, independent comparisons; municipal read-only/roll-call pilots | Jurisdictional variation and public-election restrictions |

**Minimum governance team:** product/engineering lead; election cryptography specialist independent of implementers; institutional counsel; clerk/administrator representative; accessibility and privacy reviewers; independent security auditor; political-science methods lead; research ethics contact; community stakeholder representatives. These are necessary roles, not claims of people already appointed.

---

## 14. Prior art, attribution and novelty boundaries

- **ETH Zurich KOF Democracy Lab / Gersbach et al.** — supported democracy and trustworthy AI voting assistants. Commonwealth inherits AI-assisted informed choice; it tests continuity of constitutional authority and independently verifiable public effects.
- **Decidim** — participatory proposals, assemblies, public accountability and documented interfaces. Commonwealth can integrate/learn from rather than reinvent participatory infrastructure.
- **ElectionGuard / end-to-end verification research; EAC VVSG 2.0** — verifiable balloting and auditability; Commonwealth does not claim to have invented secret digital voting or achieved government certification.
- **NIST SP 800-63-4; W3C Verifiable Credentials 2.0** — identity and selective-disclosure principles; neither automatically establishes unlinkable ballots.
- **Classical observation factorization, weighted set cover and reference monitors** — mathematical antecedents for DAP-CR1/CR2 and the effect guard.
- **NIGHTFALL DAP v0.2/v0.3** — prior finite-model soundness, change-stable semantic reuse, evidence cost and anonymity-compatibility results. The current blueprint transports those exact *conditional* statements and preserves their limitations. No globally novel democratic-assurance theorem or real deployment has been independently certified.

**Research distinction (candidate, not established priority):** compositional Democratic Assurance spanning informed agency, effective political equality, verified collective choice, applicable law and *current effect-bound authority*, with cost and failure certificates that travel through institutional changes.

### Primary sources and governance standards

1. ETH Zurich KOF Democracy Lab: https://kof.ethz.ch/en/the-institute/kof-divisions/research-division-kof-lab/kof-democracy-lab.html
2. Decidim modules: https://decidim.org/modules
3. Election Technology Initiative / ElectionGuard: https://electiontechnology.org/technologies/election-guard/
4. EAC VVSG: https://www.eac.gov/voting-equipment/voluntary-voting-system-guidelines
5. NIST SP 800-63-4: https://csrc.nist.gov/pubs/sp/800/63/4/final
6. W3C Verifiable Credentials 2.0: https://www.w3.org/TR/2025/REC-vc-data-model-2.0-20250515/
7. National Academies *Securing the Vote*: https://www.nationalacademies.org/read/25120/chapter/7
8. Florida Statutes 2026, §720.317: https://www.leg.state.fl.us/statutes/index.cfm?App_mode=Display_Statute&URL=0700-0799/0720/Sections/0720.317.html
9. Alabama Open Meetings Act: https://openmeetings.alabama.gov/
10. Alabama Code §36-25A-5.2 (local electronic meetings): https://law.justia.com/codes/alabama/title-36/chapter-25a/section-36-25a-5-2/
11. NIGHTFALL DAP v0.3: bundled `archive_v0_3/COMPOSITION_THEOREM_v0_3.md`.

---

## 15. Decision log and certification ledger

**Design decisions made:** binding in-app votes for authorized organizations; open, modular governance application; human sovereignty; no AI votes; typed privacy-separated DAP; effect-time authorization; change-stable evidence reuse; student organizations → HOAs → municipality; named-independent verification; two distinct vote types.

**Proved in earlier finite research:** DAP-S1 under complete atomic mediation, DAP-CR1 semantic factorization, DAP-CR2 nonadaptive evidence covering, DAP-CR3 permutation necessity, DAP-CR4 marginal privacy noncomposition. These are scoped statements with classical antecedents, not production or novelty certificates.

**Checked in this blueprint:** deterministic reference-kernel tests and JSON schema validation only, if and when the bundled test commands pass in this release. They cannot verify cryptography or real legal authority.

**Not yet established:** verified ballot-engine integration, legal authority of an actual pilot host, an approved IRB research protocol, effective political equality, informed agency in actual populations, complete external-effect mediation, and a globally original joint-cost theorem. The blueprint is ready for institutional review and implementation planning, not an election launch.


---

## 16. Build acceptance and source-of-truth protocol

**Source priority:** The signed/custodian-attested primary governing rule, exact finalized proposal, authenticated eligibility commitment, independently verified vote evidence, named legal authority and stay registry, then the current authorization snapshot. AI summaries, search indexes, provisional profiles and imported records never substitute for an authoritative source.

**First production release gates:** (i) written institutional authorization for this exact voting procedure, (ii) externally reviewed ballot engine with privacy and inclusion/availability tests, (iii) accessible alternative voting route, (iv) independent tally verifier and challenge/appeal path, (v) source-complete effect adapter with atomic current-epoch guard and safe fallback, (vi) legal/privacy and research-ethics approvals when applicable, and (vii) complete incident/rollback exercises. Failing any gate returns to `DEMO/ADVISORY`.

**Research acceptance:** A and E are measured empirically with preregistered conditions and uncertainty intervals; they are not inferred from passing a machine-checkable election. L requires a competent named institutional legal reviewer. S is reported only for the externally inspected, fully mediated scope. Claims outside the verified scope are explicitly `UNASSESSED`.

**Implementation first:** import the baseline v1.0 workspace intact; add the DAP schema and guard contract, freeze a synthetic procedure and electoral fixture, run the 19 narrow tests here and v0.3 replay, then build the election adapter using an existing independently evaluated protocol. Do not implement a new voting cryptosystem, spend real funds or connect municipal systems in the first slice.