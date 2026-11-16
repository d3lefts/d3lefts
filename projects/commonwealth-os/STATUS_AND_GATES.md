# Commonwealth OS — proof, authorization and release gate register

**Revision:** Product Design v1.1 reconciliation, source audit of main at c562a76821d95aaa40d3db794b371e5c788f49ad (2026-11-16). No external peer review, official institutional endorsement, real identity or production authorization is implied.

## Current executable / integration evidence

| Component | Observed at audit checkpoint | Status | Remaining gate |
|---|---|---|---|
| Python legislative app | app/main.py and app/static/app.js implement fictional role-switching and v1.1 demo workflow; current branch no longer has app/history.py or app/civic.py | IMPLEMENTED_SYNTHETIC (v0.1-style), not v0.3 integrated | Reconcile deleted PR #619/#629 modules and prove current-head E2E |
| Historical recorded-vote service | historical/ with bundled synthetic House, Senate, municipal and issue fixtures, separate read-only API | IMPLEMENTED_SYNTHETIC; **separate service** | Integration adapter for actual-residence/DOB-specific history, source custody and privacy |
| Browser civic intelligence lab | docs/commonwealth-intelligence.html/js synthetic local-only comparison and profile walkthrough | IMPLEMENTED_SYNTHETIC; not authenticated/integrated | Tested server API binding and independent provenance |
| Node transactional demo and browser evidence checker | apps/server and apps/browser; different synthetic authority/evidence models | IMPLEMENTED_SYNTHETIC; distinct workbenches | Common authority contract and source-different replay suite, see [#626](https://github.com/d3lefts/d3lefts/issues/626) |
| Formal assurance | assurance/ finite model and Lean scoped proof | INTERNAL FORMAL SCOPE only | Real source and deployed action proof assumptions remain open |
| Source custody / law applicability | [#623](https://github.com/d3lefts/d3lefts/issues/623), [#624](https://github.com/d3lefts/d3lefts/issues/624) | DESIGNED, not real-corpus certified | Current-law versioning, applicability, exceptions and precedence audit |
| Profile/semantic integration | [#625](https://github.com/d3lefts/d3lefts/issues/625), Living Voter prototype | DESIGNED and partially synthetic | Explicitly no inferred/automated ballots; held-out semantic validation |
| Production identity, official votes and municipal import | disabled / no institutional authorization | NOT ESTABLISHED | Institution, identity, privacy, source-custody, accessibility, independent security review |

**Critical reconciliation:** historical representation PR #629 merged as fe49bedad20d958622c8e96075f5f83faefb3395, but the Python modules and tests added there were subsequently deleted on main. Previously published 79-test results refer to an earlier head, **not** present-main app coverage. The separate historical/ service is real synthetic code but does not substitute for the missing Python Representation UI. Read [v1.1 design revision](product-design/v1.1/README.md) and [integration audit](product-design/v1.1/05_IMPLEMENTATION_RECONCILIATION_AND_ACCEPTANCE.md) before promoting status.

## Original v1.0 workstream goals (retained for traceability)

| Workstream | Current evidence | Verification status | Needed before advance |
|---|---|---|---|
| Product charter, UI and flows | 14 design docs, UX specifications, synthetic HTML prototype | Design proposal | Formal usability, accessibility, and security testing |
| Existing code/law corpus | Proposed source adapters and schema | Not implemented for authoritative Huntsville corpus | Source inventory, official reconciliation and effective-date audit |
| Preference compression | 96-question research budget + mapping/inference model | Unvalidated research hypothesis | Held-out user studies, error/abstention and counterexample analysis |
| Democratic Assurance Passport | DAP v0.3 drafts and v1.0 schema | Historical formal claims not independently reviewed in this session | Independent proof/code audit and institution-specific legal review |
| Authorized ballots | Governance decision flows and data structures | Not deployed, not authorized | Election authority approvals, deterministic rules engine, reconciliation tests |
| Privacy and identity | Threat model and P0 acceptance criteria | Design only | Data-protection impact assessment, retention policy, independent penetration test |
| University pilot | UAH first, other universities next | No confirmed partnership | Authorization and defined eligibility rules |
| School pilot | Huntsville public high schools next | No confirmed partnership | District approval, minors' data safeguards and nonpolitical educational scope |
| HOA pilot | After schools | No confirmed partner | Association-specific bylaws, quorum, member voting validity |
| City council final pilot | After HOA phase | No confirmed municipal authorization | Clerk, legal, security and records review; procurement where applicable |

The comparators (Decidim, CONSUL, Polis, Loomio, Legistar, ElectionGuard and related systems) are credited in the design's [competitive analysis](product-design/v1.0/docs/02_Competitive_Analysis.md). Claims of universal uniqueness are not certified.

## Release decision rule

No transition from draft to authorized production ballot without a documented authority chain, stable ballot and governing-rule versions, eligibility/quorum checks, independent result verification, effect-time enforceability, rollback and incident-response policies, and a signed institutional release decision. A research theorem does not substitute for legal authorization. A lawfully authorized vote does not by itself validate inferred preferences.

## Data handling

Keep individual policy preferences private, minimize consent/identity linkability, preserve redaction and withdrawal controls where legally applicable, and avoid real participant identities in code examples. All current fixture data is synthetic.
