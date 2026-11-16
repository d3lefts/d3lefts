# Identity, privacy, public transparency and proof assurance — v1.1

**Boundary:** constitutional authority and real election security are not established by synthetic data, source-linked UI, hashed records, or a passing proof checker. This document refines the frozen [v1.0 security design](../v1.0/docs/10_Identity_Privacy_Security.md).

## Separate trust zones

| Zone | Contents | Access boundary |
|---|---|---|
| Public institutional source | Verified public roll calls, legislation and official decisions | Available without personal authentication only after approved provenance/release |
| Private person/profile | DOB (if supplied), time-bounded residences, issue responses, consent and delegations | Purpose-scoped account access; protected from institutional clerks and public read models |
| Institutional operator | Rules, role grants, agendas, proceedings and authentic membership | Institution-specific permission and time-current eligibility |
| Restricted ballots | Actual authorized votes, ballot method and secrecy rules where applicable | Dedicated legally approved subsystem, never inferred from questionnaire |
| Evidence and custody | Immutable originals, source digests, verifier receipts, signed correction history | Independently checkable with a trust root outside application control |
| Untrusted AI and imports | Retrieved documents, OCR, legal extracts, synthesis and suggestions | Read-only quarantine, no authority to vote/certify/publish/modify authoritative rules |

Public recorded **official** roll calls may be identifiable where the source lawfully publishes them; individual **constituent** issue answers and secret ballots do not thereby become public.

### Profile integrity and political neutrality

- A respondent's voluntary answers are not an official ballot and cannot initiate an unattended governmental decision.
- Do not use sensitive beliefs for covert message targeting, partisan outreach, candidate persuasion, campaign optimization or concealed model training.
- Do not assign an overall politician ranking, tier or inferred motive. Display exact dated official positions and the user's directly stated positions only where substantively comparable.
- A user may export, correct or withdraw optional profile consent within applicable retention constraints; preserve public records required by law separately.
- Do not expose DOB, exact address, residential changes, or private mapped districts through public history download or client logs.
- Distinguish verified registered-voter eligibility from residence matching: knowing a district does not authorize a ballot.

### Proof Passport claim hierarchy

| Claim | Permitted proof meaning |
|---|---|
| SOURCE_INTEGRITY | Local bytes match declared source digest; **not** proof custodian is lawful |
| PERSON_TERM_MATCH | Given attested inputs, official served the seat at event time |
| ROLL_CALL_REPLAY | Named positions and tally match complete supplied roll-call evidence |
| MOTION_SEMANTICS | Recorded motion text/type available; comparison meaning requires independent review |
| REPRESENTATION_MATCH | Given private residence and boundary evidence, seat mapping valid at time; output may hide sensitive inputs |
| PUBLIC_RELEASE | Projection was reviewed and privacy/redaction checks passed |
| OFFICIAL_AUTHORITY | Requires original institutional grant, valid current law and signed human decision—not inferred from above |
| EFFECT_TIME_ENFORCEMENT | Requires transactional gate, no-bypass path test and independently audited deployment, not model assertions |

Claim status always PASS / FAIL / UNKNOWN (or specifically INDETERMINATE) with precise assumptions, inputs, version and limits. **UNKNOWN is not PASS.** A passed mathematical theorem over abstract atomic sinks does not show deployment has complete real-world effect mediation.

The separate [finite assurance workbench](../../assurance/README.md) and Lean source establish abstract finite-world implications under declared assumptions. The standalone Node [verifier](../../apps/server/README.md) checks synthetic signed event exports. Neither attests a real government, authorizes an election, or proves that any actual source record is authentic.

### Release and change gates

1. Institution confirms responsible officers, applicable versioned rules, source custodians, consent and retention basis.
2. Replace freely selectable demo roles with verified IdP + short-lived tenant-scoped grants and revocation.
3. Backed-up, transactional, independently reviewed store and key governance; signed event custody with external anchors.
4. Public/source imports staged and reconciled with exact authoritative originals; no trust escalation through AI.
5. Threat model includes compromised clerk, colluding reviewers, forged term/geometry, malicious OCR, vote replay, altered receipts, and small-group inference via aggregate transparency.
6. Test WCAG 2.2 AA, accessible offline/paper paths and independent red-team and recovery.
7. An institution explicitly signs scope of advisory pilot; official electronic voting needs separate legality, secrecy/verifiability and incident-response approval.

**For the current research stack:** no live municipal history ingest, real identities, legally consequential ballots or independent production audit. All implementation claims must name the exact component; do not represent multiple independent synthetic demos as one deployed OS.

## Design-review checklist

- Public raw record provenance visible while private residence location concealed.
- Role/capability checked server-side at effect time; tenant mismatch, stale grant, stale rule, stale source fail closed.
- Suppression of small respondent cohorts and linkage/differencing risks in public aggregates.
- Publication and correction history survives withdrawal of a draft, privacy change or later legal supersession.
- No current-seat official shown as having personally represented user before DOB absent explicit historical residence evidence.
- Historical member's lack of named roll-call record never rendered NAY, abstain or NOT_VOTING.
