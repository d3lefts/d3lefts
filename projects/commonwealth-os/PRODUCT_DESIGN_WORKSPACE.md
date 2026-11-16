# Commonwealth OS — canonical project workspace

**Date established:** 2026-11-15. **Status:** Research and product-design baseline, not an institutionally approved or deployed voting system.

## Scope

Commonwealth OS is a vendor-neutral architecture for preserving continuity across governing rules, legislative versions, discussion, eligibility, authorized voting, decisions, and implemented changes. Its product surfaces are the **Living Voter** mobile preference dashboard, **Chamber** legislative workspace, **Steward** administration, and **Democratic Assurance Proof Passports**. These names are working labels.

## Canonical sources

**Current design revision:** [Product Design v1.1](product-design/v1.1/README.md) is the additive implementation-reconciliation and historical-representation specification. Original v1.0 source files and its MANIFEST.json remain an immutable source archive. Where a current implementation assertion conflicts with archived prose, verify the exact executable main-branch revision; do not silently rewrite history.


- [Editable Product Design v1.0](product-design/v1.0/README.md), including all 14 design documents, schemas, flowcharts, requirements and synthetic prototype.
- [Living Voter mobile prototype](product-design/v1.0/prototype/living_voter_dashboard_prototype.html).
- [Requirements register](product-design/v1.0/requirements/requirements_register.csv).
- [Legislative preference mapping](product-design/v1.0/docs/08_Questionnaire_and_Inference.md).
- [Democratic Assurance Passport](product-design/v1.0/docs/09_Democratic_Assurance_Passport.md).
- [Competitive analysis](product-design/v1.0/docs/02_Competitive_Analysis.md).
- [Huntsville phase plan](product-design/v1.0/docs/11_Huntsville_Pilot_Roadmap.md).
- [Source and attribution list](product-design/v1.0/docs/14_Sources_and_Attribution.md).
- [Product and research evidence status](STATUS_AND_GATES.md).
- [Historical representation contract](HISTORICAL_REPRESENTATION_CONTRACT_v0_3.md), [standalone fictional history engine](historical/README.md), [browser civic intelligence demonstration](../../docs/commonwealth-intelligence.html), and [v1.1 source reconciliation](product-design/v1.1/05_IMPLEMENTATION_RECONCILIATION_AND_ACCEPTANCE.md).
- [Google Drive archive, PDFs, earlier formal research and constitutional drafts](https://drive.google.com/drive/folders/1aWkKDXaiLereebPVTIbRtZWGZ2gGw0tr).

## Document archive

The Google Drive folder keeps full original ZIP and PDF packages, editable source files, historic versions and adjacent research without falsely implying that every earlier result has been certified.

| Folder | Contents |
|---|---|
| 01 Product Design | Current v1.0 package, dossier, representative platform design freeze, diagrams, mobile wireframe |
| 02 Democratic Assurance | DAP and compositional theorem drafts, v0.1–v0.3 formal-assurance packages |
| 03 Huntsville Pilots | University/school/HOA/municipal research plans |
| 04 Voter Profiles | Questionnaire instrument, preference-profile research |
| 05 Constitutional Research | Founding drafts and broader constitutional proposition; not operational law |

## Fixed pilot order

1. University of Alabama in Huntsville (UAH) student-government pilot.
2. Other Huntsville universities.
3. Huntsville City Schools public high schools, under school approval and child-data safeguards.
4. HOAs within Huntsville, under governing documents and member-voting law.
5. Huntsville City Council, final phase of the first pilot; advisory only unless a competent authority separately authorizes binding voting.

Dates, partners, participant counts and legal permissions are **targets**, not existing institutional commitments.

## Product non-negotiables

- Adult resident questionnaires are local ordinance questions first, federal law second; separate state coverage may follow.
- Choices: **Support / Don't support / No preference**; **unknown** is a distinct internal not-assessed state.
- A response may inform multiple laws only with documented mapping provenance, uncertainty and override. An inference is **never** a cast vote.
- Proposed, amended, repealed and integrated laws have immutable versions and re-elicitation rules; editorial codification is not treated as substantive change without evidence.
- Public summaries are clearly labeled as participant data, never a representative election result without valid sampling.
- No hidden political profiling, covert collection, public disclosure of individuals' policy responses, or automated assumption of a representative's legal authority.
- Actual ballots require institution-specific authorization, identity and eligibility controls, integrity verification, and accessible alternatives.
- No genuine registered-voter data or identifying political profiles are stored in this public repository.

## Archive and release discipline

Baseline v1.0 is an **engineering specification draft**, not a production release. Build/test and mathematical proof receipts belong with each claim. Original package `MANIFEST.json` is an archive-specific checksum ledger and **not** a GitHub file-content certification; transferred text may have normalized line endings. Link related NIGHTFALL results as supporting research, not as already-proved guarantees for this product.

## Next decisive gate

First reconcile the parallel synthetic components on current main: identify the intended canonical UI/API and restore or formally supersede the missing Python history/civic implementation from PRs #619/#629. Demonstrate the opted-in DOB-to-present representation flow and any-era history controls, with exact motion semantics, private data separation and independent synthetic tests. **Only after internal integration is evidence-complete** should a bounded UAH SGA pilot agreement and institution-specific rule review be pursued; official ballots require separate authorization and external assurance.
