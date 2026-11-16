# Democratic Assurance Proof Passport and certification boundaries

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Objective

Every consequential institutional decision should carry a **portable evidence package** allowing an independent auditor to check that the right governing rules and text were used, the right participants were authorized, the decision procedure was valid, and any subsequent effect was correctly recorded. This is a **design objective**, not an existing certified implementation.

## Minimal passport

- `decision_id`, `institution_id`, `institution_type`, `authority_mode`
- `rulebook_id`, `rulebook_version_hash`, exact rule clauses (quorum, notice, majority, proxy, attendance, conflict)
- `proposal_id`, `locked_text_version_hash`, publication time, amendments and challenge history
- `eligibility_snapshot_hash`, snapshot time, eligible count/weights, exclusions and appeals
- `voting_window`, `vote_method`, `secret_or_open`, `ballot_integrity_method`
- `tally`, `quorum_result`, `majority_rule_result`, `verifier_version`, cryptographic or signed receipts where valid
- `certification_status`, `reviewers`, `exceptions`, `independent_audit_result`
- `implementation_events` with evidence and effective-time authorization
- `provenance` source metadata, checkpoint hashes and public redaction policy

## State machine

`DRAFT → SOURCED → AUTHORITY_REVIEWED → DELIBERATING → TEXT_LOCKED → ELIGIBILITY_FROZEN → VOTING → TALLY_PROVISIONAL → INDEPENDENT_CHECK → CERTIFIED_OR_BLOCKED → EFFECT_PENDING → EFFECT_CONFIRMED_OR_DISPUTED`.

A post-lock substantive amendment must abort/reinitialize the ballot unless the institution's specific rule says otherwise. An invalid or stale eligibility snapshot blocks valid certification. Unknown legal authority blocks a binding effect, even if the arithmetic is correct. The state machine must not be a decorative progress bar: the server guard checks transition invariants.

## Verifier contract (v1 proposal)

`verify(passport, authoritative_rule_set, verified_source_set) -> {PASS, FAIL, INDETERMINATE, findings[]}`.

To PASS, verify institution and rule authority; text and source hashes; roster validity; voting-period compliance; ballot method and weights; quorum/majority calculations; tally integrity; challenge resolution; publication and effect evidence under institution-specific requirements. **INDETERMINATE** if legal interpretation, audit materials or independent trust roots are missing. Publication of a JSON receipt alone is *not* a proof.

## Formal safety invariant (conditional)

`BindingEffect(e) ⇒ AuthorizedRule(e) ∧ EligibleBallot(e) ∧ LockedText(e) ∧ ValidProcedure(e) ∧ VerifiedOutcome(e) ∧ FreshSource(e) ∧ EnforcedEffectBoundary(e)`.

This is a **desired invariant conditional on complete mediation**, not a theorem currently proved for real institutional systems. Network retries, paper decisions, administrative overrides, legacy credentials and off-platform effects are bypass channels requiring separate assurance.

## Example checker pseudocode

```
require passport.authority_mode == 'institution-authorized'
require trusted(rule_version) && valid_at(rule_version, vote_time)
require trusted(source_version) && hash(locked_text)==passport.locked_hash
require verified_roster(passport.eligibility_snapshot)
require rule_engine.validate_ballots(ballots, roster, vote_window)
require recompute_tally(ballots, rulebook)==passport.tally
require quorum_pass && decision_threshold_pass
require no_unresolved_material_challenge
if effect_requested: require enforceable_boundary && fresh_effect_authorization
return PASS
```

A valid application cannot blindly disclose secret ballot plaintext to an external checker; integrate cryptographic tally proofs or controlled third-party audit depending on the institution's method.

## Maturity labels

`CONCEPT` → `PROTOTYPE` → `REPRODUCIBLE_TEST` → `INDEPENDENTLY_AUDITED` → `INSTITUTIONALLY_AUTHORIZED`. None implies universal election certification or legal effect beyond named scope. Proof Passport has no automatically granted authority.

## Relation to prior art

Decidim's traceable proposal history, ElectionGuard's cryptographic verifiability, and OpenZeppelin's propose/vote/execute mechanisms are **components and antecedents**, not work to erase. Originality, if established, requires verified cross-rule/source/effect continuity and a same-scope comparison.
