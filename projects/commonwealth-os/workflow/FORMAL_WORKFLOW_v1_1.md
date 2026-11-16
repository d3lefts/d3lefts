# Commonwealth OS — Synthetic Legislative Workflow v1.1

**Status:** Formal design plus independently reimplemented *synthetic consistency checker*. No live legislation, institutionally binding vote, secure public election, verified human identity or independent security assurance. 15 November 2026.

**Depends on:** `projects/commonwealth-os/BLUEPRINT_v1_0.md`, `IMPLEMENTATION_AND_RELEASE.md`, and `CITY_SOURCE_INGESTION_POLICY.md`. The framework must run for a fictional UAH-style senate, HOA, or hypothetical municipal body by changing jurisdiction-specific rules **without treating those simulated rules as adopted law**.

## 1. Goal, baseline, and non-goals

Construct an auditable transaction from proposed text to verified recorded outcome with a separately reviewed public projection:

`Draft → Amend → Deliberate → Vote → Certify → Publish preview`.

A *passed motion* is not necessarily an enacted ordinance, nor is a successful demo verification an official vote. An *AI-proposed* bill has no authority unless a duly authorized human accepts and moves it through adopted procedures. Official voting is **hard-disabled** in the supplied reference implementation even if a caller sets a fictional `official_enabled` flag.

The first implementation does **not** establish Internet-ballot secrecy, remote identity proofing, legally valid electronic voting, legislative replacement, automatic standing-vote execution, or the applicability of any specific organization's parliamentary rules. Those require separate adoption and audits.

## 2. Typed domain objects

The minimal authoritative data graph is:

`Institution / Jurisdiction → GoverningRuleRevision → MembershipCredential / AttendanceSnapshot → Session → AgendaEntry → LegislativeItem → Revision → MotionLock → Ballot → CastReceipt → CertifiedOutcome → ProofPassport → PublicationProjection`.

A state snapshot is

`S=(tenant, jurisdiction, item, revision, status, mode, rules, roster, attendance, lock, casts, outcome, certifier, publication_reviewers, journal)`.

- `tenant, jurisdiction`: every transition is institution-scoped; IDs never prove authority by themselves.
- `item, revision`: stable proposal ID and immutable revision sequence, linked by supersession. Each revision has exact text and source provenance.
- `mode`: `DEMO`, `ADVISORY`, or future `OFFICIAL`. The provided code permits consequential progression **only** for DEMO/ADVISORY.
- `rules`: independently approved authority source, current version, quorum formula, voting threshold, jurisdiction, time validity, required publication conditions and revocation status. In the demo, a deliberately fictional simple majority of votes cast (excluding abstentions) is used; no claim that this is a real SGA/HOA/city rule.
- `roster, attendance`: eligibility and meeting participation established server-side from trusted institutional evidence, **not client-provided assertions**. Both are frozen into ballot eligibility scope.
- `lock`: a cryptographic digest binding institutional context, exact motion revision, governing rules, and roster. Demonstration digest covers text, revision, tenant and item; production digest additionally binds attachments, fiscal amendments, action type and effective-date clauses.
- `casts`: unique, immutable cast events associated with one locked ballot; authentication/ballot secrecy depend on a future separate subsystem.
- `outcome`: certified **pass** or **failure** of the proposal, distinct from whether evidence verification succeeded. `REJECTED` means a lawfully counted proposal did not meet its threshold; `VOIDED` means the attempt was withdrawn/interrupted.
- `journal`: append-only, sequence-numbered, hash-linked events. A digest alone is tamper-*evident against an independently retained root*, not tamper-proof or a digital signature.

## 3. State machine and guards

State labels are explicit. Amendments are events; they do not create an additional persistent state.

| Operation | From → To | Actor capability | Required guard and effect |
|---|---|---|---|
| CREATE | none → DRAFT | AUTHOR | Human actor, same tenant; new stable ID, revision=1, source recorded |
| AMEND | DRAFT / IN_REVIEW / AGENDA_SET / DELIBERATING → DRAFT | AUTHOR | New immutable revision and digest; invalidate previous review/agenda approvals |
| SUBMIT_REVIEW | DRAFT → IN_REVIEW | AUTHOR | Meaningful revision and attribution |
| SET_AGENDA | IN_REVIEW → AGENDA_SET | CLERK | Review accepted, agenda and session assigned |
| OPEN_DEBATE | AGENDA_SET → DELIBERATING | PRESIDER | Session active, adopted procedure (simulated in demo) |
| LOCK_MOTION | DELIBERATING → MOTION_LOCKED | PRESIDER | Current authority, no stay, valid jurisdiction/rules, quorum, frozen digest |
| OPEN_BALLOT | MOTION_LOCKED → BALLOT_OPEN | PRESIDER | Lock still matches, unique ballot and eligible snapshot, mode permitted |
| CAST | BALLOT_OPEN → BALLOT_OPEN | eligible human member | One cast/member, exactly valid choice, matching tenant and lock; atomic uniqueness required |
| CLOSE_BALLOT | BALLOT_OPEN → BALLOT_CLOSED | PRESIDER | Recheck rule currency, stay, quorum, lock and roster |
| CERTIFY | BALLOT_CLOSED → CERTIFIED or REJECTED | independent CLERK | Independently recompute evidence and tally; reject stale/unknown/invalid context |
| PREPARE_PUBLICATION | CERTIFIED / REJECTED → PUBLICATION_REVIEW | CLERK | Privacy classification and approved redacted projection required in production |
| REVIEW_PUBLICATION | PUBLICATION_REVIEW → same | independent RELEASE_REVIEWER | First distinct human approval; output not public yet |
| APPROVE_PUBLICATION_PREVIEW | PUBLICATION_REVIEW → PUBLISHED | second distinct RELEASE_REVIEWER | Required second reviewer; binds approved projection digest; demo preview only |
| VOID | any active pre-decision state → VOIDED | PRESIDER | Reason mandatory; no mutation of prior events; restart via new linked motion |

The supplied Python reference includes the causal guards but not all real-world prerequisites named above (e.g. legally adopted rules, actual session clocks, binding publication privacy review). **Those are production requirements, not passing assertions.**

## 4. Legality, authority and independence

The validity of an official decision requires at least the conjunction:

`AuthorizedInstitution ∧ AuthorizedSession ∧ CurrentRule ∧ EligibleCastSet ∧ QuorumSatisfied ∧ ThresholdSatisfied ∧ LockedTextUnchanged ∧ NoLegalStay ∧ IndependentCertification ∧ RetainedEvidence`.

The term `ThresholdSatisfied` pertains to a **passed motion**; a legitimately defeated motion may still have a verified result. Certification of a result must not be conflated with adoption of a proposed law.

Official-mode enablement must require signed and dated institutional authorization, a jurisdiction-specific ruleset, independent election/security review, legally approved fallback, responsible officers and contractually documented scope. Such evidence cannot be replaced by a boolean field. The reference model **categorically disables OFFICIAL transitions**; independent checker also rejects official evidence.

Capabilities are checked per **actor, tenant, action and item**. The author may not certify their own measure. The certifying clerk is independent of the electorate in this conservative demo policy. Two distinct human release reviewers separate from author/certifier approve publication. Actual institutions may require different separation patterns and must adopt them explicitly.

AI has no AUTHOR, PRESIDER, CLERK, official voter, certifier or RELEASE_REVIEWER capability. AI suggestions are untrusted drafts until reviewed, attributed and accepted by an authorized human.

## 5. Safety invariants (formal requirements)

For any **reachable** state, provided all changes go through atomic, authenticated transitions:

- **I1 (No unauthorized execution).** `Transition(S,a,S') ⇒ Human(a) ∧ Allowed(tenant,a,action,scope)` for every consequential operation. Recorded democratic authority is not inferred from ownership of a client/device.
- **I2 (Revision immutability).** Once ballot opened: `motion_digest = locked_motion_digest` until closing/certification. Amending after lock is prohibited; a new motion requires a new transaction ID.
- **I3 (Unique casts).** For each ballot: `∀member, count(valid_casts(member)) ≤ 1`. The authoritative database must enforce `(ballot_id, member_id)` uniqueness transactionally, not only client state.
- **I4 (Eligible casts).** `Cast(member) ⇒ member ∈ roster_at_open ∩ attending_at_open ∧ membership_active_at_cast`.
- **I5 (Certified outcome integrity).** `CERTIFIED ∨ REJECTED ⇒ tally = Fold(eligible_unique_casts) ∧ Current(rule) ∧ NoStay ∧ Quorum ∧ SameLockedMotion ∧ IndependentClerk`.
- **I6 (Fail closed).** Any unknown/expired/contradictory authority evidence blocks `LOCK`, `OPEN`, `CLOSE`, or `CERTIFY`. No caller may send a success field that overrides server checks.
- **I7 (Publication independence).** `PUBLISHED ⇒ prior_reproducible_outcome ∧ reviewed_public_projection ∧ two_distinct_approvals ∧ no_protected_voter_profile_in_projection`.
- **I8 (Non-repudiable sequence — contingent).** Audit events form a contiguous hash chain. **External signed anchoring, reliable key custody and source preservation are preconditions** for claims stronger than local consistency; not implemented here.
- **I9 (No implicit citizen vote).** Survey results, inferred profiles and standing preferences never create ballot casts unless an explicit, legally authorized delegation/voting subsystem is implemented later.
- **I10 (No cross-institution effect).** An action scoped to institution `A` cannot mutate records or authorize ballots in institution `B`.

### Proof sketch for model-level invariant I2

Base: `DRAFT` has no locked digest. Inductive steps: `AMEND` changes the content only in states strictly before `MOTION_LOCKED`; `LOCK_MOTION` writes the digest once; `OPEN_BALLOT`, `CAST`, `CLOSE_BALLOT` and `CERTIFY` never change revision or text and check the lock. `VOID` produces a terminal state. Hence all **honest reducer-generated** accepted casts are bound to the motion locked before opening. This is a *conditional model argument*, not a proof of deployed data integrity, concurrency correctness, or identity authenticity.

### Proof sketch for model-level invariant I3

Base: empty cast sequence. `CAST` checks member not already in casts; no other valid transition inserts or edits casts. Induction gives at most one cast/member **assuming serializable processing of transitions**. Without an atomic unique database constraint, concurrent submissions could violate the assumption.

## 6. Democratic Assurance Proof Passport (DAPP)

The `ProofPassport` should bind:

1. `J`: jurisdiction, tenant, institutional authorization and procedural scope.
2. `S`: exact immutable source/revision hashes, valid supersession relation, rule version and authority timestamp.
3. `R`: roster eligibility and applicable quorum with protected member data segregated.
4. `B`: ballot/motion digest, allowed choices, no-stay evidence, opening/closing state.
5. `T`: deterministic tally and threshold interpretation, distinction between outcome passed/failed.
6. `C`: authorized independent certifier, relevant attested signatures and validity period.
7. `P`: privacy-screened public projection, two independent publication approvals, correction chain.
8. `E`: ordered audit journal, externally anchored digest, verification method and limitations.

An internal checker should return detailed Boolean/unknown results for each required claim and the exact missing evidence. Public disclosure should expose the verification result, hashes and appropriate aggregate information, not private member identity or preferences.

A demo passport contains hashes, tally, event-root, and explicit fields `legal_authority=false` and `independent_review=false`. It must never display an **OFFICIAL / legally certified** badge.

## 7. Transaction, API and event contracts

**Event envelope**: `{event_id, seq, tenant, legislative_item_id, expected_state_version, name, actor_id, actor_role, timestamp, payload, previous_hash, event_hash, authority_ref, command_id}`. Every command uses an idempotency key and an optimistic expected-version predicate or serializable transaction.

API surface (proposal):

- `POST /v1/legislative-items` → creates `DRAFT` (AUTHOR)
- `POST /v1/items/{id}/revisions` → new revision and mandatory review reset (AUTHOR)
- `POST /v1/items/{id}/transitions` → state change validated server-side
- `POST /v1/ballots/{id}/casts` → immutable cast with atomic uniqueness; no nonhuman authority
- `POST /v1/ballots/{id}/close` → presiding capability plus rules/quorum recheck
- `POST /v1/ballots/{id}/certifications` → independent evidence verifier, immutable certification record
- `GET /v1/items/{id}/passport` → versioned receipt; never implies court/government certification
- `POST /v1/publications/{id}/reviews` → two-person privacy and release gate
- `GET /public/decisions/{public_id}` → only reviewed redacted projection

**Storage transaction rule:** accepted command atomically appends its event, mutates one item state, commits idempotency result, increments the item version, and records an outbox event. Failed commands commit no state/event. Outbox consumers may reprocess idempotently, never grant authority. No cross-tenant DB read or write, even for AI document retrieval.

**Corrections:** certification and publication are append-only. Invalid outcomes are superseded by a signed corrective/cancellation record, not overwritten. A later official clerk record always retains priority over a synthetic import. An institutional appeal or recount is a separate authorized procedure.

## 8. Demonstration path / acceptance criteria

Fixture: entirely fictional UAH-style senate, three eligible and attending members; fictional quorum `2` and majority-of-nonabstaining-casts rule; AUTHOR, PRESIDER, CLERK, two independent RELEASE_REVIEWERS. No UAH governing rule or meeting record is asserted to match.

Happy path:

1. Human AUTHOR proposes `SB-014`; accepted content stored as revision 1.
2. AUTHOR submits for review; CLERK puts it on agenda; PRESIDER opens debate.
3. AUTHOR may submit a textual amendment; that event creates revision 2 and resets review. The presider then locks the accepted current motion.
4. PRESIDER opens the **demo** ballot with frozen rule/roster/motion hashes.
5. Three eligible members cast `AYE`, `AYE`, `NAY`. Attempted duplicate casts are refused.
6. PRESIDER closes, CLERK checks and records tally `2/1/0` as PASSED; a failed motion gets a different outcome while still being recorded.
7. CLERK prepares public preview. Two independent reviewers sign off; the preview links to the evidence chain.
8. An independent checker replays the event history and verifies the passport against supplied evidence.

Negative tests must include stale rule, changed motion, changed roster, missing quorum, unauthorized/AI/cross-tenant actor, double vote, stale authority, forged tally, forged source, missing event, two reviews by same person, and inappropriate OFFICIAL mode.

A published demo does **not** prove secure Internet voting, legal effect, authentic institution members or real-world fairness; no actual Huntsville City Council records are imported.

## 9. Audit plan, scope of testing, and open gaps

The package includes two different Python files, deliberately authored with distinct methods: `workflow_model.py` (state transition implementation) and `independent_checker.py` (independent event reconstruction). It includes the complete `test_workflow.py` unit suite. They share the specification and example inputs, so this is *author-side implementation plus separate internal checker*, **not external independent peer review**.

The `unittest` suite currently has 28 passing cases, including complete enumeration of the `3^3=27` complete ternary ballots for one fixed 3-person synthetic scenario. That finite check does not prove correctness over all sessions, arbitrary actor counts, fault interleavings or malicious server behavior.

Remaining gates for even a real advisory deployment: independent threat modeling, institutional rule review, secure identity-provider integration, private/public data separation, digital signature/key-management implementation, persistence/concurrency testing, legal release review, accessible UI, attack-injection evaluation and approved incident recovery. Official election deployment is a distinct higher-risk program and remains out of scope.

**No municipal source connector is enabled** until the design, authority and source-provenance gates in `CITY_SOURCE_INGESTION_POLICY.md` pass.