# Commonwealth OS — Product Design v1.1 (implementation reconciliation)

**Revision date:** 2026-11-15 (America/New_York). **Status:** design and source-audit revision, synthetic-only. **Authority:** none to enact law, administer elections or import real personal/government data.

This directory is the forward-looking design addendum to [immutable Product Design v1.0](../v1.0/README.md). The v1.0 MANIFEST.json describes the earlier archive and is deliberately not modified. Do not describe that archived checksum as validating the v1.1 additions.

## Priority and provenance

1. **Current executable behavior:** inspect the exact files at the named Git commit, plus the test run actually performed. A specification does not imply a deployed feature.
2. **Formal contracts:** [legislative workflow v1.1](../../workflow/FORMAL_WORKFLOW_v1_1.md) and [historical representation v0.3](../../HISTORICAL_REPRESENTATION_CONTRACT_v0_3.md) express intended interfaces and invariants.
3. **Design decisions:** the docs below specify the next integrated experience; implementation and approval remain separate gates.
4. **Original product record:** [v1.0 design documents](../v1.0/README.md), [v1.0 implementation blueprint](../../BLUEPRINT_v1_0.md), and [source/attribution index](../v1.0/docs/14_Sources_and_Attribution.md) remain intact.

### v1.1 documents

| Document | Purpose |
|---|---|
| [01 Product and journeys](01_PRODUCT_DECISIONS_AND_JOURNEYS.md) | Screens, roles, navigation, transparent representative workflows and product acceptance |
| [02 Historical representation UX](02_HISTORICAL_REPRESENTATION_UX_AND_SEMANTICS.md) | Birth-to-present default, any-time research, historical seat mapping, exact voting record presentation |
| [03 Data/API/provenance](03_DATA_API_AND_SOURCE_PROVENANCE.md) | Bitemporal identities and geography, exact recorded vote semantics, canonical import and read APIs |
| [04 Security and assurance](04_TRUST_SECURITY_AND_ASSURANCE.md) | Trust zones, privacy, Proof Passport requirements and independent validation |
| [05 Implementation reconciliation](05_IMPLEMENTATION_RECONCILIATION_AND_ACCEPTANCE.md) | What current main actually contains, removed functionality, restoration gates, nonclaims |
| [06 Institutional pilots](06_INSTITUTIONAL_PILOTS_AND_EVALUATION.md) | Research instruments, staged adoption, benchmarks and institution-specific authority |
| [07 Evidence traceability](07_EVIDENCE_AND_DEPENDENCY_INDEX.md) | Source-to-requirement map, known conflicts, issue references, review backlog |

## Critical finding from source audit

At the starting main-branch audit checkpoint **c562a76821d95aaa40d3db794b371e5c788f49ad**, the historical contract survives but the earlier Python app/history.py and its v0.3 tests/fixture have been removed from main since merge commit fe49bedad20d958622c8e96075f5f83faefb3395. The Python app present on main exposes a v0.1-style workflow. Separately, projects/commonwealth-os/historical contains a **different** synthetic history service, and docs/commonwealth-intelligence.html provides a browser-local synthetic civic intelligence demo. These are not one integrated application. See document 05 for exact evidence.

**Do not silently promote prior PR test counts to present-main test status.** A previously merged successful synthetic feature may be absent from the current app after later changes. Restoration and tests against current main are required.

## Invariants preserved from all revisions

- Civic infrastructure is neutral and institutionally separate from any party/campaign.
- No personal profile/consent response is a ballot; no inferred standing vote without independently authorized scope.
- No source is authoritative solely because a PDF, web page or model output says so.
- Original sources, exact motions and affected time intervals travel with any historical assertion.
- No fabricated voting history for voice votes, unavailable records, predecessor officials, missing residences or unsourced jurisdictions.
- No municipal connector or OFFICIAL election mode activated in the synthetic research system.
- Public transparency exposes authorized institutional records and method, never identifiable private civic preferences.
- The fixed pilot adoption order remains UAH → other Huntsville universities → Huntsville City Schools → HOAs → Huntsville City Council. Other synthetic experiment environments do not silently replace that sequence.

## Evidence status terms

**DESIGNED** = specified only; **IMPLEMENTED_SYNTHETIC** = code exists for fictional data in a stated component; **INTERNALLY_TESTED** = named test/scope/commit; **INTEGRATED** = one shared app path with end-to-end checks; **EXTERNALLY_AUDITED** = independently conducted review; **AUTHORIZED** = written institutional grant. No implication between these gates.
