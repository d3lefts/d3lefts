# Commonwealth OS — Design and Implementation Blueprint v1.0

> Faithful text extraction from `Commonwealth_OS_Design_and_Implementation_v1_0.docx` (15 November 2026). Original formatted DOCX/PDF and full engineering package were produced in the originating project; this file preserves readable design text, not an assertion of deployment or legal authority.

COMMONWEALTH OS | DESIGN BASELINE v1.0



COMMONWEALTH OS
Design and Implementation Blueprint — v1.0
November 15, 2026

Mobile-first, representative-first civic operating system — design baseline, not a deployed system.

Core design agreement

Institutionally authorized representation and administration come first. The OS maintains versioned
legislative documents, amendment history, sessions, voting rules, signed proof-passport evidence, and a
reviewed public record. Voluntary citizen profiles and delegated participation come later, with explicit
consent and separate approval. AI assists but never independently exercises sovereign authority.

Pilot order: UAH student government → other Huntsville universities → Huntsville City Schools student
councils → HOAs → Huntsville City Council (last). A 2027 Huntsville pitch is a demonstration opportunity, not
city authorization or installation.

Design freeze meaning: Decisions in this blueprint are frozen for the first engineering baseline. Legal
authority, institution-specific thresholds, and partner approvals remain explicit dependencies. Nothing here
constitutes implementation, a live vote, source ingestion or independent security certification.




Commonwealth OS — Product Requirements Document v1.0
Status: DESIGN BASELINE FROZEN (implementation proposed; deployment NOT authorized) Date: 2026-11-
15

1. Problem, users, and purpose
Commonwealth OS is a mobile-first, role-governed legislative workspace for representatives, secretaries,
presiding officers and administrators. It combines versioned policy text, amendments, agendas, deliberation,
authorized voting, certification, public records and performance reporting. Its future constituent layer
supports voluntary issue profiles, direct authenticated participation and revocable delegation. It is politically
neutral infrastructure and is organizationally distinct from the American Commonwealth Party.
The initial system must improve procedural fidelity and provenance before it attempts public voting or
automated lawmaking. It must NEVER silently use pilot responses to profile residents, infer voting eligibility,
or replace elected authority. The eventual public system must be disclosed from pilot inception, with
purpose-specific privacy notices.

2. Locked design decisions
Product name: Commonwealth OS. Role-specific workspace modules: Home, Bills, Session, Records,
persistent AI assistant; administrator console also includes Sources, Members, Rules, Questions, Publishing,
Audit.
Mobile-first responsive PWA (desktop accessible), dark, restrained civic-technical styling; accessible high-
contrast alternative. Browser-based first; native wrappers only if research proves necessary.
Representative-first, private workspace at first; opt-in public verified read-only records later; authenticated
constituent responses only after separate approval.


                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                                COMMONWEALTH OS | DESIGN BASELINE v1.0

AI assists with retrieval, drafting, amendment comparison, procedural checklists, issue mapping and
outcome reporting; NEVER autonomously authorizes, certifies, votes, publishes, or transfers money.
An official vote mode is technically provided, disabled for each jurisdiction until documented authorization
and independent assurance pass; otherwise DEMO / ADVISORY clearly labeled throughout.
Single multi-tenant governance core with per-jurisdiction authorities, distinct data isolation, configuration
and publication rules. No default cross-tenant queries.
Existing official records remain authoritative. Commonwealth OS can become authoritative only by explicit
lawful delegation; importing records does not establish authority.

3. Primary users
Representative — Capabilities: Read documents, compare revisions, propose amendments, debate, cast
authorized vote; Hard boundary: Cannot certify own tally or alter finalized records
Presiding officer — Capabilities: Manage agenda and debate, call votes after authority checks; Hard
boundary: Cannot edit votes, quorum or adopted text post hoc
Secretary / clerk — Capabilities: Verify sources, attendance, minutes, tally, publish eligible official records;
Hard boundary: Cannot create an authorization out of nothing
Parliamentarian / legal reviewer — Capabilities: Validate rules, points of order, legal scope and statuses;
Hard boundary: Advisory interpretation unless duly delegated
Institutional admin — Capabilities: Configure organization, access, retention and workflows; Hard
boundary: Cannot override legal votes or erase audit records
Independent auditor — Capabilities: Read evidence, run checker, flag defects; Hard boundary: Read-only;
no hidden edit privilege
Public visitor (later) — Capabilities: Browse nonconfidential verified records and outcomes; Hard
boundary: No personal profile access
Constituent (later) — Capabilities: Manage profile, issue responses, consent and delegation; Hard boundary:
Responses not binding unless legally authorized

4. Navigation and essential screens
Home: tasks due, current session, proposals awaiting review, recent activity, sourced AI insight, warning
states.
Bills: docket filters, text viewer, version timeline and redline, amendments, legal citations, fiscal attachments.
Session: agenda, motion status, attendance/quorum, speaking queue, minutes draft and floor procedures.
Vote: exact motion/version, rule basis, eligibility, quorum, method, confirmation, immutable receipt,
OFFICIAL vs DEMO indicator.
Records: searchable decisions, minutes, resolutions, source bundles, public release status, Proof Passports.
AI: persistent assistance with source-cited answer and clearly distinguished suggestions; no tool capable of
binding effects.
Admin: authority matrices, personnel and roles, question neutrality certificates, source approval, release
queue and audit dashboard.
Public portal (feature flag): institution-specific public dockets, adopted text, roll calls where lawful, fiscal
data, timelines, outcome metrics.


                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                              COMMONWEALTH OS | DESIGN BASELINE v1.0

Constituent profile (feature flag): issue/ordinance preferences, explicit voting scopes, delegations,
revocations, accessibility controls.

5. Acceptance criteria by priority
P0 — source-linked document versioning; audit trail; access controls; agenda and meeting; amendment diff;
simulated voting; manual certification; proof-passport export; credible responsive UI; private tenant
segmentation; user notice. P1 — authorized official voting (institution by institution); public release
workflow; question registry and certifications; verified public portal; financial/outcome records. P2 —
authenticated citizen profiles; neutral adaptive questionnaires; scoped delegated/direct voting where
authorized; predictive outcome analytics with uncertainty; public APIs. Excluded from v1: mandatory
federal ID, city-election conduct, automated judicial judgments, money transfer, blockchain ballot storage,
autonomous adoption of laws, scraping/importing Huntsville meeting notes, universal government
replacement.

6. Service quality and research targets (engineering targets, NOT achieved)
WCAG 2.2 AA across all public and constituent workflows; keyboard and assistive-tech testing.
Any binding transition is server-validated, idempotent, atomic and produces a signed audit receipt; stale or
conflicting requests fail closed.
No material critical/high security findings at a third-party release assessment; OWASP ASVS 5.0.0 used as test
catalog.
Pilot performance targets: median core screen load <2 seconds on specified test networks; 99.9% monthly
availability target after production hardening; RPO <=15 minutes and RTO <=4 hours for non-voting pilot;
stronger targets before authorized voting.
Pilot research metrics: issue/profile coverage, question comprehension, framing sensitivity, citation
accuracy, administrator time, version attribution, disclosure and incident rates. No causal claims without
appropriate design.




Commonwealth OS — Engineering Architecture and Decisions
A. Architecture style
A modular monolith first: TypeScript web client/API, PostgreSQL authoritative transactional store, S3-
compatible versioned object store, queue/worker for nonbinding analysis, append-only event journal,
independent receipt-verification service. Separate public read model from private transactional data. Split
services only when security isolation, load, or governance requires it. This reduces early distributed-systems
failure modes.
Recommended technology choices (replaceable, NOT implemented): Next.js/React/TypeScript PWA; server-
side TypeScript or Kotlin; PostgreSQL with tenant-guarded Row Level Security plus app-level authorization;
object storage with immutability and legal hold where appropriate; OIDC + phishing-resistant authenticators
(passkeys) and institution federation; durable queue; OpenTelemetry; IaC, secret management/KMS;
independent backup and restore pipeline.

B. Trust zones
ZONE 1 (public): published immutable snapshots, redacted records, generic explainers, accessibility assets,
rate-limited API. ZONE 2 (institution): draft texts, committee records, authorized ballots, staff discussions,
                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                              COMMONWEALTH OS | DESIGN BASELINE v1.0

approval queue; tenant-scoped. ZONE 3 (private identity/preferences): identities, consent, constituent issue
profiles; keys, indexes and access policies separate from institution records. Public aggregate counts must
not permit re-identification; withhold small cells. ZONE 4 (AI sandbox): read-only, authorized scoped
retrieval; input/output safety filters; no direct write to authoritative tables; suggestions emitted as untrusted
drafts requiring human acceptance. ZONE 5 (assurance): append-only signed event log, external exports,
checker inputs, attestations; independent read account.

C. Canonical objects
Jurisdiction, GovernanceBody, GoverningRuleRevision, AuthorityGrant, PersonIdentity,
MembershipCredential, RoleAssignment, Meeting, AgendaEntry, LegislativeItem, ItemRevision, Amendment,
Motion, AttendanceSnapshot, BallotRule, Ballot, BallotCast, Tally, TallyCertification, SourceDocument,
SourceAssertion, ProofPassport, AuditEvent, PublicationDecision, PublicArtifact, IssueQuestion,
NeutralityCertificate, Response, Delegation, Consent, OutcomeMetric, FinancialRecord.
Rules: immutable identifiers and versioned foreign keys; items are never overwritten after adoption; all
changes append superseding revisions; derived machine summaries are never stored as official law; every
official text claim has an approved source record.

D. APIs (proposed)
GET /api/v1/me/workspace GET /api/v1/legislation?status=… POST /api/v1/legislation/:id/revisions (draft only;
optimistic concurrency) POST /api/v1/meetings/:id/motions POST /api/v1/ballots/:id/casts (requires eligibility
proof and enabled authorization) POST /api/v1/ballots/:id/certify (independent clerk + presiding
authorization) GET /api/v1/passports/:id POST /api/v1/publications/:id/approve (two-person review) GET
/public/v1/jurisdictions/:id/decisions (public-only projection) POST /api/v1/ai/analyze (read-only suggestions,
sourced) No ingestion endpoints are enabled during design freeze; their schemas may be stubbed.

E. Database hardening
Transactions SERIALIZABLE or explicit locks for tally certification; idempotency keys on every state change;
immutable session/motion version after ballot opening; append-only signed event receipts; separate KMS
envelopes for identity and profile data; no plain-text political profiles in logs; RLS tests prove tenant
isolation; no client-controlled claims of membership or quorum.

F. Proof Passport algorithm
Inputs: precise motion hash/version; current jurisdiction and institutional rules; voter eligibility snapshot;
attendance/quorum; time window; ballot-cast receipts; tally procedure; independent certification;
publication authorization; source chain, key identifiers and revocation/stay status. Decision conditions:
AUTHORITY_VALID && RULE_CURRENT && ELIGIBLE_VOTERS && QUORUM_VALID && THRESHOLD_MET
&& APPROVED_VERSION_MATCHES && NO_STAY_OR_REVOCATION && SCOPE_OK &&
EVIDENCE_COMPLETE. If any condition is FALSE or UNKNOWN: do not emit certified official outcome.
UNKNOWN is distinct from TRUE. A checker can attest that the submitted evidence satisfies encoded rules; it
does not independently prove that the governing rule is lawful or all human intent was captured.

G. Threat model and responses
Insider changes tally: immutable vote snapshots, independent signer, cryptographic receipts, external audit
export.
Cross-tenant data leak: isolation in DB+API+object store, fuzzed tenant access tests.



                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                              COMMONWEALTH OS | DESIGN BASELINE v1.0

Compromised admin: least-privilege grants, dual approval, security alerts, revocation and out-of-band
recovery.
AI prompt injection in imported source: treat source as data, read-only retrieval, cite-and-verify, no tool side
effects, hostile document tests.
Mass automated profile manipulation: scoped authorization and revocation, independent audit, no
unobserved silent default votes.
Stale law used: effective-date and supersession checks on sources and authority grants.
Privacy breach: data minimization, private/public segregation, incident and deletion workflows per lawful
retention.
Outage during authorized vote: fail closed, no partial certification, lawful fallback/offline process defined by
institution.

H. Selected architecture decisions
ADR-001 modular monolith rather than microservices at pilot scale. ADR-002 one mobile-first responsive
web client, accessible desktop layout. ADR-003 PostgreSQL transaction log is canonical, with signed tamper-
evident receipts and periodic anchored hashes; no public blockchain for personal ballots, voting profiles or
raw evidence. ADR-004 sources have explicit legal status: draft, proposed, enacted, repealed, superseded,
unknown. UNKNOWN cannot certify. ADR-005 AI suggestions require human review; no autonomous
legal/financial effects. ADR-006 tenant-by-tenant policy configuration, not jurisdiction logic hard-coded in
code. ADR-007 publishing is a reviewed projection, never direct database exposure. ADR-008 community
participation is opt-in and consent-scoped; no political-party data sharing.




Commonwealth OS — Mobile Experience and Legislative State Machine
Design system
Quiet institutional dark interface; graphite/ink surfaces, restrained violet/cyan accent, legible tabular figures,
no manipulative urgency cues. A light/high-contrast scheme is required. Mobile screen minimum target 360
CSS pixels, keyboard and screen-reader compatible, responsive desktop 3-column docket/reader/evidence
layout.
Bottom bar: HOME | BILLS | AI | SESSION | RECORDS. Persistent assistant may be accessed from any screen
without obscuring formal vote confirmations. Avoid conveying official authority through color alone; text
labels REQUIRED: OFFICIAL (AUTHORIZED), ADVISORY, DEMONSTRATION, DRAFT, CERTIFIED, STAYED.

Screen-to-action contracts
Home: show personal tasks, live meeting info, outstanding amendments, event log, sourced assistant note; no
unrelated partisan or constituent profiling. Bills: canonical text; revision compare, annotations, cite/source
access, amendment proposal with provenance. Session: agenda order, speaker queue, quorum sources,
procedural motions, public participation links if allowed. Vote: exact motion, version hash, voting mode, rule
threshold, eligible membership, deadline, review choice, submit once, receipt and separate tally certification.
Never animate as a game. Records: adopted versions, vote receipts where lawful, certified passports, official
record cross-links and corrections. AI Assistant: retrieved sources and confidence/unknown badges,
suggestion composer, alternatives, expose source provenance, copy but NEVER direct execution. Admin:



                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                               COMMONWEALTH OS | DESIGN BASELINE v1.0

signer management, role grants, authority configuration and signatures, source status, legal/policy review
queue, publication view as public will see it.

Formal lifecycle
WORK_ITEM: INTAKE -> DRAFT -> REVIEW -> ON_AGENDA -> DELIBERATION -> VOTE_READY -> VOTING ->
TALLY_PENDING -> CERTIFIED -> PUBLISHED -> MONITORING -> SUPERSEDED / REPEALED. Exceptions:
WITHDRAWN before vote; STAYED after official challenge; REJECTED following unsuccessful vote;
CORRECTION publishes a new version and retains old record; FAILED_CHECKER blocks certification.
Mandatory transitions: - REVIEW -> ON_AGENDA: secretary checks docket completeness and applicable
notice requirement. - DELIBERATION -> VOTE_READY: governing officer records proper motion, applicable
rules, current quorum, frozen document hash. - VOTING -> TALLY_PENDING: time window closes;
duplicate/out-of-roster cast rejected. - TALLY_PENDING -> CERTIFIED: separate certifier checks rules, roster,
receipt count, threshold, source freshness. - CERTIFIED -> PUBLISHED: publication-policy reviewer redacts
legally protected content and signs release snapshot. - Any unexpected authority/source change -> paused for
re-evaluation; no silent auto-correction.

Constituent feature flags
C0 no constituent login, no collection. C1 public transparency read-only after publication approval. C2
voluntary feedback / 24-question neutral instrument per institutional pilot; NO vote counting from inference.
C3 scoped authenticated preferences and delegation, explicitly user-enabled, with ability to inspect, override
and withdraw; legally binding only after additional authority and security review.

Neutral question workflow
Verify source and jurisdiction -> encode canonical legal action, threshold, scope and effect -> generate strictly
templated wording -> legal semantic check -> bias/comprehension test -> independently issue neutrality
certificate -> publish with source and expiration/recertification trigger. Answers: Support, Do not support, No
preference, Need more information, Not applicable, Unanswered. Answers are not transitive across
materially different laws. For active policy, ask new question if legal meaning changes.

Five institutional rollout stages (binding sequence)
University of Alabama in Huntsville (UAH) student senate/council, authorized internal demonstration.
Other willing universities in Huntsville, portability test across student-government rules.
Huntsville City Schools public high-school councils, subject to district approval, heightened minor-data
safeguards and advisory-only participation.
Willing Huntsville-area HOAs, subject to member status, bylaws and contractual rules.
Huntsville City Council, last stage of the first pilot program, initially parallel/read-only until authorized. A
city pitch/demonstration in 2027 is distinct from final municipal deployment.
The three research questionnaire classes remain student-government, HOA, municipality; high-school
student councils are a separate deployment cohort using an age-appropriate student-government
configuration. Do not confuse study instruments with rollout order.




                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                               COMMONWEALTH OS | DESIGN BASELINE v1.0

Commonwealth OS — Authority, Public Transparency, and Data-Governance
Policy
Non-negotiable institutional principles
The institution’s currently operative bylaws, ordinances, rules and responsible officials control all real-world
decisions. Model definitions have no authority without formal adoption.
No binding municipal electronic council vote without written city legal/administrative approval and
independent assurance; lawful meetings and minutes remain outside system until explicitly integrated.
A private pilot is not a secret future profiling operation. Tell participants from day one that transparency
and voluntary constituent participation are long-term product goals; collect no resident profiles before
separately informed opt-in.
Research/party separation: OS governing organization cannot provide identifiable civic profiles to the
American Commonwealth Party or a campaign.
Records transparency applies to all lawfully releasable institutional records, not private citizen ballots,
profiles, student data, protected HOA records or security secrets.

Privilege hierarchy
Public visitor < registered constituent < representative/officer < institutional admin, BUT no rank grants
unilateral powers; actions require fine-grained capabilities and relevant legal authority. Secretary
certification and public-release approval require independent sign-offs. All high-risk operations logged and
external audit accessible.

Source hierarchy and provenance
AUTHORITATIVE: official clerk record / adopted text with verified legal status. PROPOSED: docketed measure
never represented as law. THIRD_PARTY: secondary summaries, transcripts and meetings notes; require
verification before promotion. DERIVED: AI output, tagging, embeddings, search snippets; never
authoritative. Record: issuer, jurisdiction, canonical URL, retrieval time, official publication/meeting time,
document hash, effective date, version, supersession, claim reviewer, reviewed time.

Public records publication policy
Public-ready: meeting date, agenda, enacted text, accessible redlines, approved votes (where lawful),
approved budgets/line-items and outcome metrics with audit trail. Private/protected: voting credentials,
personal contact details, private issue preferences and individual ballots, unpublished legal advice, student
records and restricted security metadata. Before publish: classification review, lawful release basis,
PII/FERPA/private-area screening, accessibility, discrepancy check, two-person approval, checksum and
preview. Corrections are additive, linked and publicly visible; withdrawal requires lawful reason and
preserves nonpublic trace.

Profile and identity policy
Identity proofing, authentication, legal eligibility and question participation are separate. Apply NIST SP 800-
63-4 to select assurance per risk; institutional official-voter privileges require verified role/roster. A device or
federal ID possession alone is not proof of legal voting eligibility. No automatic registration of minors for
binding municipal voting. No silent inferred standing votes in pilots. Consent is versioned and revocable
within lawful retention constraints.



                         Design specification • Proposed, not deployed • 15 NOV 2026

                                                              COMMONWEALTH OS | DESIGN BASELINE v1.0

Legal, assurance and policy sign-offs
Institutional authority owner signs Rules Matrix; counsel/parliamentarian reviews legal consequence;
security lead reviews vote mode and threat model; privacy lead approves notices; independent reviewer
audits passport checker; accessibility reviewer verifies user experience. No signed approval => pilot remains
simulated/advisory.




Commonwealth OS — Implementation Plan, Milestones and Release Gates
Delivery strategy
Build one trustworthy end-to-end vertical slice (proposed rule -> source -> draft -> amendment -> motion ->
simulated vote -> independent certification -> public-release preview) using synthetic fixture data. Add real
institutional sources only after schema, authority model, provenance and security controls pass predefined
tests. The municipal meeting-note importer remains deliberately disabled.

2026/2027+ indicative schedule (targets; not commitments)
G0 Spec & institutional requirements (Nov-Dec 2026): sign design baseline, authority templates, wireflow,
schema, threats, privacy/notice and research protocol. Deliverable: v1.0 docs and synthetic golden fixture. G1
Engineering foundation (Dec 2026-Jan 2027): repository, CI, migration, identity, tenant separation, append-
only event log, backup/restore, source/version API. Gate: isolation and replay tests pass. G2 Core legislative
workspace (Jan-Mar 2027): mobile dashboard, bills, redline, agendas, amendments, session controls, AI read-
only retrieval. Gate: 100% golden workflows replay; UX and accessibility review. G3 Assured voting and
passports (Mar-Apr 2027): demo vote, authority checker, frozen version, receipt, independent tally, signed
passport, no official mode without sign-offs. Gate: adversarial negative tests all fail closed. G4 UAH pilot
(dependent on UAH authorization; 2027 aspirational): live authorized student-government workflows where
permitted, or advisory parallel test. Gate: consent, protocol preregistration and independent report. G5 Other
Huntsville universities: portability/configuration audit; new rule sets without changes to core voting engine.
G6 Huntsville City Schools high-school councils: district approvals, minors protections, nonbinding only;
ethics/parental approval as applicable. G7 HOA pilot: association documents, member eligibility, assessments
and procedural rules, with approved retention and public disclosure policies. G8 Huntsville City Council:
2027 pitch/demo may show synthetic data and read-only public archives; final stage operates only if
law/officials authorize pilot. First municipal deployment is parallel and nonbinding. Binding municipal
workflows are a separate later gate. G9 Public portal / profiles: feature-flagged, reviewed
privacy/security/disclosure, scoped voluntary participation, independent transparency and survey audits.

Engineering backlog by dependency
E01 repo + threat model + CI E02 tenants, user provisioning, roles and authority matrix E03 source registry
and immutable revision store E04 drafts, amendment and redline services E05 meetings, agenda, attendance,
quorum E06 vote simulation, receipts, certifier, independent verifier E07 AI retrieval and citation validation
E08 reviewed publication projection and public portal E09 neutral question registry / controlled survey
engine E10 constituent identity/consent/role-specific integration E11 live institution adapters, approved per
institution

Definition of done for initial demo
All navigation and flows function on a mobile browser and desktop, using 100% synthetic test data; every
official action is clearly marked DEMO.

                        Design specification • Proposed, not deployed • 15 NOV 2026

                                                             COMMONWEALTH OS | DESIGN BASELINE v1.0

Amendments have semantic diffs and source links; after adoption, content is immutable with subsequent
corrections represented as revisions.
Tally cannot be certified without applicable source rules, eligible roster, quorum, threshold and approved
text hash.
Passport verifier recomputes receipt hashes and dependencies; injected stale source, duplicate vote, invalid
membership, changed motion, missing authorization and wrong tenant are rejected.
Read-only AI cannot alter binding records and cites only verified retrieved material; failures show NOT
VERIFIED.
Publication defaults PRIVATE; redaction and dual-approval process documented/tested before public release.
End-to-end code, tests, build and data migrations run from README on a clean environment; no third-party
secrets included.

Research evaluation
A/B test drafting time and citation errors vs ordinary workflow; for question neutrality, randomized
semantic-equivalence tests with independent review; for traceability, measure coverage of records and
checker findings; report false-positive/negative and sampling limitations. No claims of causal improvement
on convenience samples alone.

Risk register (critical items first)
R1 no legal authority for official voting -> disable OFFICIAL, demo or parallel only. R2 human employee
threshold / larger economic framework is separate from OS -> do not implement corporate taxation/UBI in
civic app. R3 AI can hallucinate legal effects -> read-only AI, source status and human confirmation. R4
unauthorized public disclosure -> private by default, publication decisions and separate public projection. R5
compromised administrator -> separation of duties, hardware-backed authentication, independent audit. R6
minors in high-school pilot -> district authorization, data minimization, legal/privacy review. R7 source drift /
corrections -> version/effective-time ledger, recertify dependencies. R8 representative vs constituent
confusion -> labels ADVISORY/DEMO/OFFICIAL, distinct counts and cohorts.

Open authority questions that cannot be hard-coded
Exact jurisdiction rules for motions/quorum/notice and signatories; SGA vote authority; HOA membership
and bylaws; city e-voting and publication approvals; high-school data governance; partner agreements and
budget. These require documentary authorization and are not software design blockers.




Commonwealth OS — City Records Intake Contract (DESIGNED, DISABLED)
Scope: No Huntsville council notes, minutes, recordings, votes or records are fetched, parsed, imported or
indexed under this v1.0 design baseline. Only schema and acceptance requirements are written.
When authorized to activate later: 1. Source discovery limited to published official city pages, lawful access
and published retention policies; honor access terms and request limits. 2. Preserve original
PDF/HTML/recording untouched with content hash, retrieval timestamp, source URL and legal-publication
metadata. 3. Automated extraction is sandboxed and marked UNVERIFIED; possible prompt-injection
content is always data, never instructions. 4. Distinguish agenda, draft ordinance, motion, recorded minutes,
adopted ordinance and third-party note; never infer enactment from mere discussion. 5. Human records
manager validates mapping to docket identifier, exact dates, official action and effective status. 6. A second

                          Design specification • Proposed, not deployed • 15 NOV 2026

                                                              COMMONWEALTH OS | DESIGN BASELINE v1.0

independent reviewer approves promotion to VERIFIED SOURCE status; conflicting sources stay unresolved.
7. Generate a permanent source-to-claim graph and audit event; mark retractions or corrections without
deleting original evidence. 8. AI search consumes only explicitly permitted source collections, cites originals
and displays their status. 9. Live ingestion requires security test, public-records/legal sign-off, maintenance
owner, rate limiting, versioning, deletion/retention policy and incident response.

No-scrape check: no network fetchers, scheduled jobs, crawler credentials, embeddings of municipal
transcripts or meeting notes included in v1.0 package.

Sources to investigate ONLY later: City of Huntsville City Clerk
(https://www.huntsvilleal.gov/government/departments/city-clerk/), official City Council Agendas & Archives
(https://www.huntsvilleal.gov/government/city-council/agendas-archives/).




Commonwealth OS — Verification and Independent Audit Matrix
DA-01 — Requirement: No binding action without authority; Minimal decisive test: Attempt certify in demo
tenant; Release blocker: YES
DA-02 — Requirement: Exact-version vote; Minimal decisive test: Change approved text after first cast;
Release blocker: YES
DA-03 — Requirement: Voter eligibility; Minimal decisive test: Inject cast from nonmember/revoked role;
Release blocker: YES
DA-04 — Requirement: Quorum and threshold; Minimal decisive test: Test 0, boundary, and above threshold;
Release blocker: YES
DA-05 — Requirement: Source currentness; Minimal decisive test: Supersede rule between agenda and
certification; Release blocker: YES
DA-06 — Requirement: Independent certification; Minimal decisive test: Sign vote with same principal as
tally creator; Release blocker: YES
DA-07 — Requirement: Identity/privacy isolation; Minimal decisive test: Cross-tenant API and DB access
attempts; Release blocker: YES
DA-08 — Requirement: Public redaction; Minimal decisive test: Seed PII into private draft, attempt publish;
Release blocker: YES
DA-09 — Requirement: AI read-only boundary; Minimal decisive test: Hostile text asks AI to cast a vote or
publish; Release blocker: YES
DA-10 — Requirement: Fail-closed outage; Minimal decisive test: Drop DB mid-certification and replay
request; Release blocker: YES
UX-01 — Requirement: Mobile accessibility; Minimal decisive test: WCAG 2.2 AA audit, assistive tech tasks;
Release blocker: YES
Q-01 — Requirement: Neutrality control; Minimal decisive test: Semantic-equivalence test and blinded audit;
Release blocker: YES for profile deployment
Q-02 — Requirement: No inferred binding votes; Minimal decisive test: Submit predicted support without
scoped consent; Release blocker: YES
EVT-01 — Requirement: Auditability; Minimal decisive test: Replay event journal and independently verify
receipts; Release blocker: YES
                        Design specification • Proposed, not deployed • 15 NOV 2026

                                                            COMMONWEALTH OS | DESIGN BASELINE v1.0

PUB-01 — Requirement: Document provenance; Minimal decisive test: Attempt to publish derived summary
as enacted ordinance; Release blocker: YES
Pass criterion is evidence from executed reproducible test with build hash, input fixture, command, output
and independent reviewer; a listed test is NOT a passed test.
Independent audit plan: reviewer B authors adversarial test plan before seeing developer A’s golden outputs,
executes against separately deployed build, verifies cryptographic signature chain, tests negative legal/role
states, and reports all disagreements. Formal proof claims require proof artifact/checker and explicit
assumptions.

Prior standards (checked 2026-11-15): NIST SP 800-63-4; OWASP ASVS 5.0.0; WCAG 2.2; Alabama Open
Meetings Act; City of Huntsville City Clerk and Agendas & Archives. No represented security or legal
certification has occurred.




                        Design specification • Proposed, not deployed • 15 NOV 2026
