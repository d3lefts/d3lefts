# Commonwealth OS — proof, authorization and release gate register

**Revision:** 2026-11-15 / baseline v1.0. No independent peer-review or official institutional endorsement is implied.

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

## 2026-11-15 additive legal-kernel progress

- **Implemented on a review branch:** `legal/kernel.py` deterministic fictional
  source/claim/derivation checker; `legal/independent_checker.py` separate replay;
  `legal/dossier.py` read-only civic dossier; hash-anchored fictional source fixture;
  adversarial Python tests and scoped CI. Once merged, this establishes a tested
  *in-model deduction* capability only.
- **Still not implemented:** real authoritative legal corpus and custody; formal
  binding-precedent/exception semantics; signed legal-reviewer interpretation
  attestations; continuously reconciled source updates; real economic-data
  adapters; Living Voter persistence integration; certified voter identity or
  secret ballots; one production backend and externally enforced effects.
- **Remain prohibited:** interpreting a supported fictional derivation as a
  legal opinion, actual development permit, public election, or real institution
  endorsement. No current claimed legal authority or external audit.

## Release decision rule

No transition from draft to authorized production ballot without a documented authority chain, stable ballot and governing-rule versions, eligibility/quorum checks, independent result verification, effect-time enforceability, rollback and incident-response policies, and a signed institutional release decision. A research theorem does not substitute for legal authorization. A lawfully authorized vote does not by itself validate inferred preferences.

## Data handling

Keep individual policy preferences private, minimize consent/identity linkability, preserve redaction and withdrawal controls where legally applicable, and avoid real participant identities in code examples. All current fixture data is synthetic.
