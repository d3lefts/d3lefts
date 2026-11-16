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

## Synthetic legislative workflow v1.1
[Formal state-machine specification](workflow/FORMAL_WORKFLOW_v1_1.md) · [Executable demo reference and independent replay checker](workflow/README.md). The demo reference rejects OFFICIAL mode; 28 internal tests cover the fictional case and negative guards, not a legally authorized electronic election.

## Runnable legislative app v0.2
[Run the full synthetic governance workspace v0.2](app/README.md). The Python mobile-first app now includes three fictional pilot questionnaires, audited role revocation, multi-item dockets, synthetic budget/public views, private advisory profiles, and locally signed test receipts. It reuses the v1.1 workflow reducer and independent checker. **Role switching remains a demo, and no real municipal data, verified voter identity, official election, or authorized public service is present.** See [source](app/main.py) and [scoped app CI](../../.github/workflows/commonwealth-app-ci.yml).

## V1 demonstrator
The first testable vertical slice uses entirely fictional governance records:
**Draft → Amend → Deliberate → Vote (DEMO) → Verify → Publish preview.**
Its goal is a replayable governance transaction with a version-locked motion, rule/eligibility/quorum checks, a reviewable Proof Passport, and publication safeguards. Pilot operation is explicitly gated on testing and permission.

The archived v1.0 reference package reported 8 passing toy checker tests. Those do **not** constitute deployed software, verified ballot secrecy, legal certification, or independent security audit.

## Evidence labels
DESIGN / IMPLEMENTED / INTERNALLY TESTED / INDEPENDENTLY VALIDATED / LEGALLY AUTHORIZED / DEPLOYED must remain distinct. Current state: **IMPLEMENTED SYNTHETIC PROTOTYPES** (Python v0.2 and separate JS browser/server workbenches), **INTERNALLY TESTED**, not externally certified, legally authorized, identity-verified or deployed.

## Integrated product design and evidence archive

The baseline includes a separate, versioned [Product Design v1.0 source tree](product-design/v1.0/README.md) with 14 detailed design docs, requirements, schemas, diagrams, comparative prior-art matrix, synthetic Living Voter prototype and visual dossier. The [Product Design workspace index](PRODUCT_DESIGN_WORKSPACE.md) links the private [Google Drive archive](https://drive.google.com/drive/folders/1aWkKDXaiLereebPVTIbRtZWGZ2gGw0tr) and earlier Democratic Assurance, questionnaire, and Huntsville pilot research. [Research status and release gates](STATUS_AND_GATES.md) distinguish design, tests, verification and authorization.

Where this representative-first implementation blueprint and the companion citizen-preference design differ, neither silently overrides the other. Treat conflicts as explicit product decisions to resolve with institution-specific authorizations and validation.

## Experimental browser and server workbench (DEMO ONLY)

- [Reference browser app](apps/browser/README.md): synthetic scenarios, browser core, fixture tests.
- [Local transactional server](apps/server/README.md): SQLite prototype restricted to localhost, typed tenant/role/eligibility actions, versioned decisions and synthetic signed evidence; its `OFFICIAL` mode is absent and `legalAuthority` is `NOT_ASSESSED`.
- [Verifier](apps/server/verify.mjs) and [conditional Lean refinement model](apps/server/formal/REFINEMENT_LEDGER_20261115.md): evidence contracts and tests, **not** a verified refinement of production JS/SQL or a legally authorized election.
- [Integration provenance and gates](architecture/INTEGRATION_READINESS_20261115.md).

This intentionally integrates the scoped contents of development PRs #610 and #615 without overwriting the existing product baseline or consent/privacy controls. Figma and Living Voter UX previews remain separately versioned under `product-design/` and `prototypes/`. Production election activation, municipal ingestion, remote API binding and real users remain out of scope.
