# Commonwealth OS — Governance Software Research

**Status:** Design baseline v1.0; engineering implementation and institutional partnerships not established.  
**Date:** 2026-11-15.  
**Principal context:** *Constitution of Computational Commonwealths: Human-Sovereign Governance for the Age of Synthetic Intelligence*.

Commonwealth OS is a mobile-first, representative-first civic governance system intended to support authenticated institutional workflows, versioned governing text, amendments, sessions, procedural votes, decision provenance, verified public reporting, and later voluntary constituent preference profiles. The platform is neutral public/governance infrastructure and **must be separated from any political party or campaigning system**.

## Source-of-truth documents
- [Full v1.0 blueprint](BLUEPRINT_v1_0.md): product requirements, architecture, trust model, navigation, release gates and test approach, preserved from the authored design specification.
- [Implementation/release plan](IMPLEMENTATION_AND_RELEASE.md): milestones, acceptance criteria, risks, and go/no-go boundaries.
- [City records ingestion freeze](CITY_SOURCE_INGESTION_POLICY.md): interface contract, provenance and enablement restrictions.
- [Pilot research charter](pilots/PILOT_CHARTER.md), [administrator PRD](pilots/ADMIN_APP_PRD.md), [neutral-question standard](pilots/QUESTION_STANDARD.md) (see notes on legal and survey validation).

- [Mathematical Proof Passport workbench](assurance/README.md): explicitly scoped finite-world theorems, exact evidence certificate optimization, source-different audits, and documented unresolved deployment assumptions.

## Non-negotiable constraints
1. **No live city-council record ingestion yet.** Use synthetic fixtures first. The municipal intake connector remains disabled by default.
2. **No institutional authority by implication.** Official voting is forbidden until jurisdiction-specific legal authorization, configured rules, security assurance, and independent sign-off.
3. **No autonomous lawmaking by AI.** AI assists with reading, sourcing, drafting and comparisons; binding actions require authorized institutional processes.
4. **No secret constituent profiling.** Private voter profiles are encrypted, consent-scoped, and segregated from the public record and political organizations.
5. **No misleading endorsement.** The University of Alabama in Huntsville, local HOAs, Huntsville City Schools, and Huntsville city government are *prospective* pilot settings, not institutional partners.
6. **Transparency of public decisions does not mean public personal ballots.** Public publishing requires review, redaction, legal basis, and a dedicated read model.

## Locked research rollout sequence
1. UAH student-government pilot, only if authorized.
2. Other Huntsville-area universities.
3. Huntsville City Schools' student councils with minors safeguards and district permission.
4. Participating HOAs.
5. Huntsville City Council last, initially a proposed parallel/advisory workspace.

A **2027 Huntsville pitch** is a demonstration target, **not** a city deployment authorization.

## V1 demonstrator
The first testable vertical slice uses entirely fictional governance records:
**Draft → Amend → Deliberate → Vote (DEMO) → Verify → Publish preview.**
Its goal is a replayable governance transaction with a version-locked motion, rule/eligibility/quorum checks, a reviewable Proof Passport, and publication safeguards. Pilot operation is explicitly gated on testing and permission.

The archived v1.0 reference package reported 8 passing toy checker tests. Those do **not** constitute deployed software, verified ballot secrecy, legal certification, or independent security audit.

## Evidence labels
DESIGN / IMPLEMENTED / INTERNALLY TESTED / INDEPENDENTLY VALIDATED / LEGALLY AUTHORIZED / DEPLOYED must remain distinct. Current state: **DESIGN**, plus a narrow source-package toy checker (internally tested). All other states remain unverified.
