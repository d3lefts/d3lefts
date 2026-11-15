# Implementation and release plan — v1.0

## Architecture decisions
- Modular monolith initially, with a mobile-first responsive PWA (Next.js/React/TypeScript proposed, not selected as a binding vendor requirement).
- Server-side authority checks and transactional PostgreSQL system of record. Separate append-only signed audit/receipt log, versioned sources, and a read-only publication projection.
- Explicit trust zones: PUBLIC, INSTITUTIONAL, PRIVATE IDENTITY/PREFERENCES, READ-ONLY AI SANDBOX, and ASSURANCE/EVIDENCE.
- No personal political preferences or raw ballots on a public blockchain. Cryptographic tamper-evidence does not require publicly disclosing sensitive source records.
- Tenant isolation at API, database, storage, and authorization layers. No cross-tenant queries by default.
- Feature flags: public portal, constituent profiles, official voting, local source import all disabled independently unless their own gates pass.

## Dependency-ordered build
| Gate | Deliverable | Proof required before progressing |
|---|---|---|
| G0 | Frozen v1.0 product scope, synthetic fixtures, threat model, authority templates | Versioned documents and assigned review owners |
| G1 | Repo scaffolding, CI, migration framework, identity, tenants, audit journal | Access-control, tenant-isolation and backup/replay tests |
| G2 | Home/Bills/Session/Records/AI; amendment redline; agenda and attendance | Complete replayable mobile and desktop synthetic workflow; accessibility check |
| G3 | DEMO vote, quorum/threshold rule engine, proof passport, independent verifier | Negative tests: duplicate cast, stale rule, wrong tenant, changed motion, unauthorized voters fail closed |
| G4 | Proposed UAH research pilot | Institutional permission, research consent, legal/privacy review |
| G5 | Other university bodies | Rule/config portability without rewriting the core authority checker |
| G6 | Huntsville City Schools | District authorization, data minimization, minor-participant ethics and accessibility review; advisory only |
| G7 | HOA | Actual association documents and membership evidence; approved financial and retention policy |
| G8 | Huntsville municipality last | Read-only/public parallel pilot only after legal permission; official mode separately approved |
| G9 | Constituents/public transparency | Approved publication redactions, independent privacy, user consent, neutrality evaluation |

## Initial acceptance tests
- A created proposal has a stable ID; revisions are immutable with explicit supersession.
- Every amendment displays source/target revision, author and provenance.
- Voting never opens for an unapproved motion/rule; client cannot supply authoritative membership, quorum, or tally.
- The ballot hashes the exact item version; changed text invalidates outstanding authorization.
- Tally certification requires current governing rule, scope, roster, meeting state, threshold, no stay/revocation, and independent signatory.
- Unknown evidence is **not** counted as true. Fail closed on conflicting, stale or absent conditions.
- Proof Passport points to immutable source versions and allows independent checker replay; checker claims limited to supplied evidence.
- PUBLIC views show only approved redacted projection; PUBLIC access can never retrieve PRIVATE profile tables.
- AI retrieved source text is untrusted; model cannot directly invoke official vote/certify/publish endpoints.
- Research pilots report sample/denominator, survey uncertainty, semantic neutrality tests, citations and observer limitations.

## Operational targets (not measurements)
WCAG 2.2 AA, NIST 800-63 identity guidance, OWASP ASVS security testing; median core screen load <2s under specified network conditions, post-hardening uptime 99.9%, nonvoting RPO ≤15m and RTO ≤4h. Before production authorized voting, establish stricter lawful fallback, independent penetration testing, end-to-end ballot verification requirements and incident response.

## Out of scope for the software v1.0
Automated judicial decisions, fiscal dividend distribution, national identity issuance, conversion of U.S. constitutional authority, blockchain voting, real municipal source scraping, and nonconsensual constituent profiling. The broader political-economic framework is research context, **not** a dependency for the first civic software demonstrator.

## Known unresolved decisions
Institutional legal authority, quorum rules, consent and privacy review, sample representativeness, public-records restrictions, key custody, official election constraints, budget, and pilot partner approval. Do not hide these as default parameters.
