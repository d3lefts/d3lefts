# Commonwealth OS — Browser Foundation v0.2

**Date:** 2026-11-15 · **Status:** INITIAL IMPLEMENTATION (synthetic, browser-only, nonbinding) · **Supersedes:** no design baseline.

## Decision record and delta against frozen v1.0

The merged v1.0 specification freezes a student-government-first deployment ladder. This v0.2 implementation track **adds a cross-institutional technical demonstration sequence** of (1) firefighter/employee association, (2) university student council, (3) municipal shadow review. It does not assert that an organizational partner has agreed or alter the original law/approval gates. The earlier HOA/schools rollout remains historical planning context, not a deployed commitment.

This track implements a minimal vendor-neutral browser vertical slice; it does not select a production host, cloud, identity provider, AI service, public-record importer, or ballot service.

## Boundaries and trust zones

```text
BROWSER DEMO (untrusted)                  FUTURE SERVER (not built)
institution profile view                   authenticated roles, tenant identity
synthetic motion & evidence                authoritative source and motion versions
local procedural checker                   policy evaluation + transactional state machine
JSON export + unsigned hash                signed, immutable append-only evidence
no accounts, no real vote                   restricted ballot custody + independent verifier
```

A thin browser client **cannot establish identity, voter eligibility, quorum, secrecy, legal authority, authentic votes, custody of records or independent certification**. The current checker validates the consistency of a supplied synthetic dataset only. It is unsuitable for use as an actual balloting or records system.

## Core governance representation

`InstitutionProfile`: immutable institutional namespace; versioned governing rule; eligible *synthetic* roster; quorum; rational yes/no threshold; explicit synthetic mode.

`Motion`: institution ID, item ID, exact revision, lock state and author.

`Evidence`: institution ID, rule revision, motion revision, synthetic ballot-close state, eligibility/attendance attestations, attendee IDs, cast ballots and separate reviewer confirmation.

`Report`: ten checks (PASS/FAIL/UNKNOWN), deterministic outcome, tally, explicit official=false, legality-not-assessed and independent-verification-not-performed.

The prototype uses exact integer comparisons for rational vote thresholds. `yes * denominator >|>= (yes+no)* numerator`; abstentions are excluded **only within these invented demo rules**. Actual quorum and threshold bases must come from institution-approved documents, including any rules about abstentions, majority of the whole body, weighted representation and tie handling.

The first safe invariant is **no official certification from browser-supplied evidence**. A PASS is named `SUPPORTED_IN_SIMULATION`, not a legal outcome. Stale authority, wrong institution, motion mutation, ineligible/duplicate ballots, unmet quorum or threshold fail. Missing reviewer evidence yields `INDETERMINATE`.

## Planned deployment architecture

Use a modular monolith first, with separate modules for identity, institution policy, legislative lifecycle, event journal, evidence and publication. The browser communicates through a tenant-bound API. Each write runs inside an authenticated, authorized server transaction with expected state version and idempotency key. Ballots are independent of a generic public audit journal, and public documents derive from reviewed redacted projections. No model-generated text or imported source may directly perform binding actions.

**Interfaces, not vendors:** JSON Schema/OpenAPI, standard authenticated identity federation, portable authority rules, versioned document digests, standard DB transactions, signed evidence exports, an independently executable verification protocol. Real ballots will require an explicit election-security threat model rather than treating a hash or ordinary e-signature as proof of election integrity.

## Production invariants (requirements, not yet implemented)

I1: Every stored record is tenant-scoped; every access rechecks trusted tenant membership at the API and storage layers.
I2: Authority and rule versions are approved, effective and frozen for the relevant decision time.
I3: A ballot links to the exact immutable motion/version and the authorized electorate snapshot.
I4: Consequential transitions are server-side, atomic, permission-checked, idempotent, and logged.
I5: A clerk cannot create governing authority; no one role can both cast and self-certify a tally.
I6: Secret voter preferences never appear in public proof material; only approved public projections are released.
I7: A source amendment triggers dependency-based re-evaluation of affected passport claims.
I8: Invalid or unknown mandatory conditions cannot yield an authoritative certified decision.
I9: There is a lawful, tested offline/cancellation recovery path.
I10: No production official vote, source ingestion or constituent profile is enabled without institution-specific approvals.

## Acceptance evidence and next slice

**Achieved by source implementation:** pure client-side simulation and negative cases for the three pilot shapes, inspectable report, JSON export with SHA-256 metadata, zero external dependencies.

**Not achieved:** authenticated server; real governance transactions; independent verifier; legal review; cross-tenant security under an adversarial server; secret ballot assurance; third-party audit; institutional pilot approval; compliance certification; accessible assistive-technology test.

**Next engineering slice:** add API contracts and a local transactional repository layer with version locking and server-owned policy/eligibility data; then independent checker in a separately authored implementation. Do not promote a numerical test pass into a legal or security claim.

### Experimental protocol
Hypothesis: A common procedural checker can apply different parameters across three synthetic institutional profiles.
Counter-hypotheses: Different rule semantics require separate engines; an ambiguous or incomplete rule yields false support; shared config leaks authority across tenants.
Discriminators: all three valid synthetic fixtures support; each negative case fails; missing evidence remains indeterminate; changed one profile authority does not alter another; independent audit later reproduces these claims.
Stop rule: do not proceed to binding workflows until independent implementation, security testing and institution-approved rule formalizations exist.
