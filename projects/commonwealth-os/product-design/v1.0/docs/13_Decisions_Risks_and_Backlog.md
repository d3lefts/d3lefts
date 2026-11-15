# Product decisions, risk register and open decisions

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Accepted product decisions

- Working brand: Commonwealth OS; resident mobile module: Living Voter.
- Mobile-first; UAH SGA pilot first; then Alabama A&M/Oakwood (candidate institutions), Huntsville City Schools high schools, HOAs, Huntsville City Council.
- First representative interface: authenticated tasks, legislative review/amend/debate/vote with persistent AI. Initial public-facing institution dashboard gated by partner authorization.
- Resident questionnaire: 3 choices; local before federal, explicit provenance, direct overrides, change-triggered follow-up.
- Source-linked, multi-institution, versioned legal lifecycle and an auditable Proof Passport.
- Open source and wider government adoption are ambitions; licensing not selected.

## Decisions requiring owner/institution sign-off

| ID | Decision | Required owner | Blocking? |
|---|---|---|---|
| OD-01 | Name and trademark clearance | Project owner / counsel | Before public branding |
| OD-02 | Software/document licenses | Project owner / contributors / counsel | Before open-source release |
| OD-03 | UAH agreement and rulebook validity | UAH authorized body | Before live voting |
| OD-04 | Student data processing and IRB | UAH / relevant schools | Before research enrolment |
| OD-05 | Ballot implementation and independent audit vendor | Institution + external assessor | Before binding vote |
| OD-06 | Data retention and export policy | Institution and privacy counsel | Before collecting real profiles |
| OD-07 | Exact question mapping accuracy threshold | Research sponsor and auditor | Before measuring success |
| OD-08 | HOA selection and statutory proxy/weight rules | Association counsel | Before HOA votes |
| OD-09 | City source integration and lawful authority mode | Huntsville Clerk/IT/counsel | Before official city use |
| OD-10 | Public demographic/equity metrics and suppression | Privacy reviewer | Before publishing aggregates |

## Risk register

| Risk | Severity | First mitigation | Trigger/owner |
|---|---|---|---|
| Inferred law positions claimed as definite or complete | Critical | Abstention and explicit basis labels | Mapping reviewer; before pilot |
| Hidden reuse of political preference data | Critical | Consent segregation and public purpose disclosure | Privacy lead; before collection |
| AI summary biases/omits legal exceptions | High | Exact-source panel + adversarial summary evaluation | Content QA; every release |
| Outdated municipal codification | High | Enacted-but-uncodified delta ledger | Clerk/source operator; each import |
| Role/authority escalation | Critical | Rule engine, RBAC+ABAC, external audit | Security; binding gate |
| Failed ballot privacy or verification | Critical | Specialist election review and fallback | Auditor; binding gate |
| Minors' political profiling | Critical | School-only council workflow and prohibition on federal profiling | District; school gate |
| Low-representativeness civic feedback | High | Sample metadata and honest denominators | Research lead; each report |
| HOA unequal vote weights ignored | High | Verify bylaws, member and proxy entitlement | HOA legal lead; each election |
| Open-source use of third-party copyrighted sources | High | Source rights, attribution, no third-party code embedded by default | Legal; publication gate |

## Future backlog, not approved features

Delegation/topic standing instructions; privacy-preserving analytics; cryptographic election protocol adapter; city legislative integration; multilingual comprehension; offline kiosk reconciliation; multi-source legal diff; representative automation *research* under explicit separate governance and consent. None should be enabled silently as part of student or resident data collection.
