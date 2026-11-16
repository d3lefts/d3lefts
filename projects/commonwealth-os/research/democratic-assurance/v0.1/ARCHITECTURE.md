# COMMONWEALTH 2030 — Federalist civic architecture (proposal v0.1)

**Claim status:** Architecture only. The included software verifies a narrow finite **authorization guard** model and computes a synthetic cost benchmark. It does not prove that continuous direct democracy works in the US, that online voting is safe, that an ordinance is legal, or that AI respects human autonomy. No independently recruited human reviewer or municipal authority has approved this architecture.

## The five-plane design

1. **Citizen plane.** Mobile/web app + libraries, public kiosks, telephone, paper, assisted access. Citizens can read original ordinance text, inspect evidence, compare competing analyses, propose edits, deliberate, petition, and see jurisdiction-specific choices. The citizen must explicitly confirm each preference; no hidden AI-delegated binding vote.
2. **Intelligence plane.** A personal civic assistant, source-bounded to official documents and disclosed third-party evidence; adversarial argument generation, counterargument views, numerical fiscal impact and uncertainty; fully optional AI-off mode. No profiling for political persuasion or microtargeting. The assistant cannot produce binding acts.
3. **Democratic procedure plane.** Versioned proposals, civic deliberation, petition signatures if law allows, citizens' assemblies and consultation, statutory electoral process if legally authorized, council votes where legally required; public process records and appeal routes. Binding decisions exist only at legally allowed endpoints. Continuous engagement does **not** imply permanent online binding elections.
4. **Constitutional/assurance plane.** Per-jurisdiction authority adapter recording law, charter, initiative/referendum power, notice, quorum, subject limits, procedural record, appropriation, rights and due process. Responsible human lawyers/clerks sign scope-limited attestations. A verifier checks completeness of machine-expressible procedural requirements, but cannot algorithmically conclusively settle disputed legal interpretation. Changes invalidate certificates based on recorded dependencies.
5. **Effect plane.** No budget disbursement, permit issuance, public notice, policy deployment, agent transaction, or ordinance publication without a trusted atomic effect-time guard bound to current ordinance digest, law/record/source epochs, human authorization, action scope, and amount. All effect paths need complete mediation, including retries, cached credentials and external vendor APIs. **This completeness is an engineering assumption, not a verified property of a municipality.**

## Critical data objects

`Ordinance = (jurisdiction, version, digest, official_text, citations, rationale, alternatives, fiscal_note, rights_impact, status)`

`AuthorityCertificate = (jurisdiction, ordinance_version, law_epoch, source_epoch, procedure_type, human_adoption_record, quorum, legal_attestation, fiscal_authority, scope, expiry, revocation_state, audit_links)`

`EffectRequest = (ordinance, scope, proposed_effect, budget_amount, actor, source_state)`

`ExecutionReceipt = (approved_version, identity_of_authorizing_public_office, guard_version, effect_id, immutable_timestamp, external_confirmation)`

Private citizen identities and voting choices do not belong in a publicly queryable ledger. Credential eligibility and participation uniqueness are separate from expression of choices, with unlinkability where the relevant lawful procedure permits it. Neither a 'soulbound' credential nor a zero-knowledge proof fixes device compromise, coercion, unlawful exclusion or ballot secrecy.

## Joint democratic requirements

**A (informed agency):** understanding of ordinance substance, recognition of uncertainty, fidelity to pre-deliberation values, independent final human choice, and measurable resistance to manipulative model variants. Assessed with preregistered human-subject experiments and red-team tests, not a formal software proof.

**E (political equality):** equal formal standing of eligible citizens, nondiscriminatory access across age, disability, internet access, socioeconomic and language dimensions; effective participation and influence parity tested empirically. Multiple non-digital routes are non-optional for the credible architecture. Avoid using a single numeric equity score to erase unacceptable group harms.

**L (legal authorization):** typed authority/jurisdiction mapping, human-signed adoption under actual municipal law, properly noticed proceedings, rights/appeal review and fiscal authority. Responsible officials and external counsel independently verify the human/legal facts; source checks must distinguish official documents from model summaries.

**S (operational assurance):** effect-time complete mediation, least-privilege implementation, revocation/stay, version invalidation, secure logging, public process audit, secret-ballot protections at any legally binding electoral endpoint, fail-closed defaults with an availability target and appeal/remediation procedures.

The feasible joint frontier minimizes lifecycle cost (technology, citizen time, professional review, election administration, cybersecurity, accessibility, oversight, recertification and expected losses) subject to specified constraints on A, E, L, S. Rights and legally mandatory procedures are hard constraints, not averaged into a single utility score.

## Pilot ladder

- **2027:** Publish legal authority matrix for one jurisdiction, threat model, original ordinance corpus and preregistration; controlled, nonbinding citizen studies. Require IRB/ethics approval where applicable.
- **2028:** Partner-approved advisory process with accessible offline alternative; independent ethics, cybersecurity, legal and election-administration audits. No transfer of binding legal power.
- **2029:** Replicate across distinct state legal regimes; stress-test stale law, misleading AI, unequal access, accessibility failures, forged records, compromised endpoints and appeals. Only use legally approved election infrastructure for any binding issue.
- **2030:** Aim for a national-interoperable local civic infrastructure and public evidence base, with legally permissible local implementations. A 50-state switch to continuous smartphone binding referendums is **not** established feasible or guaranteed by 2030.

## Kill switches and decision gates

No deployment if: local counsel cannot map adoption authority; an implemented effect path bypasses the guard; identity proofing excludes a relevant group without an acceptable alternative; AI causes prespecified material preference manipulation; covert political profiling occurs; binding remote ballot return cannot satisfy applicable law and independent security requirements; process lacks meaningful appeals; or observed participation burdens undermine representational equality.

## Prior art anchors

- NASEM *Securing the Vote*, ch. 5: https://www.nationalacademies.org/read/25120/chapter/7
- EAC paper-backed and auditable voting policy: https://www.eac.gov/news/2025/05/28/eac-commissioners-issue-policy-support-paper-based-and-auditable-voting-systems
- EAC E2E protocol evaluation (Dec 2025): https://www.eac.gov/voting-equipment/end-end-e2e-protocol-evaluation-process
- NIST SP 800-63-4 (2025): https://csrc.nist.gov/pubs/sp/800/63/4/final
- NCSL citizen initiative subject rules (2026): https://www.ncsl.org/elections-and-campaigns/citizen-initiative-subject-rules
- ETH Zurich supported democracy 2026-2031: https://nomisfoundation.ch/projects/trustworthy-ai-voting-assistants-and-supported-democracy/
- NIGHTFALL scoped precursor: https://github.com/d3lefts/d3lefts/tree/main/research/nightfall/2026-11-price-of-permission
