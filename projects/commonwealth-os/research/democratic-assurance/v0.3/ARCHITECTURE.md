# COMMONWEALTH 2030 — Federalist civic architecture (proposal v0.2)

**Claim status:** Architecture with bounded DAP v0.2 formalization. The included software verifies a narrow finite **authorization guard** model and computes two synthetic cost benchmarks. It does not prove that continuous direct democracy works in the US, that online voting is safe, that an ordinance is legal, or that AI respects human autonomy. No independently recruited human reviewer or municipal authority has approved this architecture.

## The five-plane design

1. **Citizen plane.** Mobile/web app + libraries, public kiosks, telephone, paper, assisted access. Citizens can read original ordinance text, inspect evidence, compare competing analyses, propose edits, deliberate, petition, and see jurisdiction-specific choices. The citizen must explicitly confirm each preference; no hidden AI-delegated binding vote.
2. **Intelligence plane.** A personal civic assistant, source-bounded to official documents and disclosed third-party evidence; adversarial argument generation, counterargument views, numerical fiscal impact and uncertainty; fully optional AI-off mode. No profiling for political persuasion or microtargeting. The assistant cannot produce binding acts.
3. **Democratic procedure plane.** Versioned proposals, civic deliberation, petitions when permitted, legally authenticated binding votes directly inside the platform for consenting organizations under adopted bylaws/rules (student councils, campus organizations, HOAs); statutory public elections and council votes only under applicable law and much stronger election-system review. Public process records, complaint/recount procedures and offline alternatives are required. Continuous civic activity and a binding election are different legal events.
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

## Pilot ladder — revised binding-vote assumption

- **2027:** Seek a participating student organization or student council authorized under its own governing rules to make **binding organizational decisions directly inside the platform** after independent security/legal/ethics review. A University SGA would require its own rules and institution approval, not an assumed right to replace its official election system.
- **2028:** Seek a willing HOA/member association, with jurisdiction- and bylaw-specific voting rights and electronic voting rules; Florida section 720.317 offers one conditional route. HOA franchise rules may differ materially from equal-citizenship suffrage.
- **2029:** Replicate at organizational scale and, where lawful, conduct municipal advisory processes. Public elections, initiative votes and binding citizen ordinances require state/municipal authority and much stronger election-security evidence.
- **2030:** Seek an independently evaluated, nationally interoperable civic and organizational-voting platform, and a jurisdiction-specific path toward binding local public voting. No assumption of universal secure Internet ballot return or nationwide statutory eligibility by 2030.

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


## Democratic Assurance Passport v0.2 integration

The DAP is now the typed bridge from certified collective decision to **current** effect-time authority. Refer to `DEMOCRATIC_ASSURANCE_PASSPORT_v0_2.md` for formal definitions, conditional invariants DAP-S1 and DAP-N1, privacy requirements, and unproved external premises. The reference model (`dap_model.py`) rejects invalid proposal, rule, electorate, law, source, budget, expiration, review or action attributes. It *assumes*, rather than implements, real cryptographic proof and legally faithful attestations. The companion independently coded finite oracle checks 45,056 cases. Six technical evidence obligations have a demonstration cost 18 jointly versus 22 as separate operations; values are synthetic, and the optimizer is classical weighted set cover. Human agency and effective equality are not reduced to boolean flags.
