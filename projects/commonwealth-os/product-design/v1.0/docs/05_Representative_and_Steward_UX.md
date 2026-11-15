# Chamber and Steward mobile product specifications

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Chamber design principle

The first institution-facing experience is **a personal legislative dashboard** for an authorized elected student representative or council member. Voter-facing features should not leak into the workspace without a separately established authority mode. The persistent AI assistant may explain, retrieve and draft, but never independently adjudicates eligibility, changes a governing document, or casts a vote.

## Screens and detailed behaviors

**CH-01 Today.** Role badge, institution name, meeting and task queue, deadlines, assigned bills, agenda and decision states. A single pinned “Authority mode: [advisory/authorized]” chip. No misleading green certified indicator.

**CH-02 Bills.** Proposed act list with source status, version, stage, committee, visible amendment history; filters for pending review, in debate, awaiting vote, decided.

**CH-03 Bill detail.** Authoritative source and source hashes, plain-language AI summary with references, fiscal/implementation considerations, conflicting interpretations; compare versions; open debate; propose amendment; link to resident aggregate consultation (where permitted).

**CH-04 Debate and amendment.** Threaded reasoning, amendment redlines, sponsors, procedural motion history, conflict/disclosure requirements. A proposed amendment never silently changes the voting text; revisions create new text versions.

**CH-05 Vote chamber.** Preflight eligibility/rulebook/quorum gate; frozen exact motion/version; deadline; confirmation; cast receipt; no implicit proxy/delegation. If institution permits proxy/delegation, it must be an explicit, scoped and auditable rule, not a default.

**CH-06 Decision passport.** Outcome, vote method, eligibility snapshot version, governing rule citations, tally verification state, exceptions, challenges, implementation status.

**CH-07 AI assistant.** Contextual, persistent conversational interface with source retrieval, draft assistance, procedural questions and dissent display. Tool capabilities are separately permissioned, logged and confirmation-gated. It must not silently transact or vote.

## Steward screens

**ST-01 Institution setup:** charter upload, rule parsing, legal authority review, roles and access control, jurisdiction boundaries. Human administrator explicitly approves any extracted rule before activation.

**ST-02 Members & eligibility:** credential proof and revocation, term dates, role coverage, conflict-of-interest restrictions. Identifiable political preferences are not visible by default.

**ST-03 Agenda & sources:** schedule meeting, approve legislative provenance and source imports; reconcile out-of-sync codification.

**ST-04 Vote administration:** configure quorum, notice, ballot format and secret/open vote; dry-run rule checker; cancel or pause on integrity exceptions.

**ST-05 Publication & incidents:** publish lawful record, manage corrected evidence through append-only supersession; publish decision certificate and appeals outcomes.

## Institution-specific modes

- University: eligibility from approved SGA rules; students as members; student senators as voting officers.
- High school: student councils only, minor protection and district supervision, no federal legal profile.
- HOA: lot/unit/member entitlements, weighted votes, proxy rules and thresholds verified against documents and law.
- Municipal: public records, open-meeting constraints, actual city officer authorization, advisory citizen preferences; legal authority for digital binding decisions requires separate written conclusion.

## Red-line design invariants

1. One actor cannot grant themselves voter eligibility, activate a rule change and certify the same vote without separation-of-duties checks.
2. Secret-ballot cryptographic receipts cannot link a publicly observable identity to vote content.
3. Vote on a superseded motion is refused or re-authorized under explicit institution procedure.
4. Ballots cannot be inferred from topic preferences.
5. Every operator exception has a date, reason, authority and audit flag.
