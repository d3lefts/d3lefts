# Identity, privacy, voting and security architecture

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Threats and assets

Assets: sensitive political preferences, institutional rosters, identity claims, ballots, governing documents, rule configurations, source provenance, hash/signature keys, audit records, and implementation endpoints. Adversaries: credential thieves, insiders, poisoned source feeds, fabricated AI summaries, colluding members, vote replay clients, and privileged actors bypassing enforcement.

## Identity vs authorization

Identity verification does not establish a person's entitlement to a specific institution vote. Use institution-approved identity and eligibility attestations for UAH, other universities, schools, and HOAs. City adult registered-voter eligibility must be verified through a separately authorized election-administration process; GPS, mailing address, publicly available voter-roll access or student status do not establish it.

## Data minimization and role separation

Store the minimum necessary identifiers in a credential vault, policy preferences under a distinct pseudonymous identity, and ballots under a separate authorized tally system. Do **not** give institutional clerks access to individual resident political preferences by default. Do not expose secret ballot contents through audit export. Do not build tools for candidate targeting or political-message personalization.

Use privacy-preserving aggregate reporting: denominators, self-selection warnings, opt-in consent category, suppression thresholds, small-cell/membership disclosure checks, and no false implication of representative sampling. Differential privacy may be considered but must not be claimed without a defined epsilon/delta, threat model and audit.

## Consent and research boundaries

Separate: (i) using a governance service, (ii) optional private preference profiling, (iii) academic study, (iv) public statistical release, and (v) reuse for future research. Refusal to participate in research must not disqualify otherwise eligible official governance. Any future use to study automation of representative labor must be disclosed and separately consented to; **no hidden secondary-purpose collection**. Deletion must explain records required to preserve official election validity and lawful retention.

## Minors and schools

Huntsville City Schools pilot requires district sponsorship and legal review. Apply FERPA where student records are involved; determine COPPA and state requirements by user age, data and operator model. Do not collect individual minors' federal ideology or political preference profiles. School-governance exercises should be narrow, educational, opt-in and age-appropriate, with parent/guardian policies documented as applicable.

## Ballot and security boundaries

- Binding ballot cast only after role/rule/eligibility/time/text lock checks.
- Server-authoritative idempotency for resend, retries and disconnected clients.
- No coercion-sensitive vote receipts showing plaintext to third parties when secret voting is required.
- Authenticity, ballot secrecy where mandated, tally verification, challenge procedures, malware, accessibility and operational resilience require dedicated audits.
- Audit events append-only and hash-linked; administrative superusers cannot erase past evidence without detection.
- Source-fed LLM context treated as untrusted input; prompt injection cannot operate privileged tools or alter law parsing without human review.
- Complete effect mediation is an assumption **to verify**, not a default fact.

## Privacy incident response

Detect → contain → scope → preserve evidence → notify institution/affected participants according to law and contract → independent postmortem → remediation and regression tests. Maintain disclosure limits, retention schedules, backup deletion and breach exercises.

## Legal research checkpoint

Alabama law on municipalities (§11-45-1, §11-45-2, §11-45-8) and FERPA are **initial references**, not a comprehensive legal opinion. The exact governing documents and institution authorization control in earlier pilots. Retain counsel's written determinations at each stage.
