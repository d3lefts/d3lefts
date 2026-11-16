# Commonwealth OS — Real-Data Migration Gates

**Status: NOT CLEARED.** The synthetic application must remain separated from actual government or constituency records until an institution-approved migration is designed and independently tested. The municipal source intake feature is deliberately absent.

## A. Technical migration order

1. **Institutional authority:** obtain a named governing body sponsor, counsel/clerk interpretation of valid procedures, contractual data roles, privacy/records classifications, and documented scope (initially advisory only).
2. **Identity:** replace role-switch simulator with organization-owned IdP, MFA, membership issuance/revocation, session integrity, access review and separation of duties; no shared/admin demo credentials.
3. **Persistent infrastructure:** provision managed PostgreSQL or equivalent with automated schema migrations, explicit immutable journal, off-site backups, recovery exercises, transactional uniqueness constraints and data-retention/erasure boundaries.
4. **Proof custody:** establish independent signer, rotated key material and public-key provenance, durable external journal anchors, separately operated verifier, receipt and evidence escrow, independent challenge/recount procedure.
5. **Legal sources:** independently verify every authoritative charter, law, ordinance, revision, effective date and supersession chain. A downloaded agenda is not enacted legislation.
6. **Source adapters:** separate staging namespace; fetch only sources the institution is authorized to use; quarantine untrusted content; check hashes and malicious instructions; reconcile against custodian originals before promotion.
7. **Questionnaires:** independently review wording and jurisdiction, preregister equivalence tests, validate neutral semantics and population sampling. Unanswered/unknown preferences never silently create binding votes.
8. **Transparency and research ethics:** define PII redaction policy, small-sample/differencing analysis, institutional records schedules, accessibility audit, incident response, participant consent, restrictions for minors, and separation from any party or political campaign.
9. **Release:** production usability, pen-test, fault-injection, external audit and signed institution decision. Any official voting program requires its *own* legal and security certification and cannot be inferred from this prototype.

## B. Deterministic import requirements (not implemented)

Every future source must include `{institution_id, custodian, original_uri, retrieval_time, original_sha256, legal_status, effective_at, supersedes, privacy_classification, asserted_authority, reviewed_by, audit_receipt}`. Staging data must be converted to exact canonical law and motion versions. Unknown or conflicting authority results in `UNVERIFIED`, never `VALID`.

No production seed may contain identity or official permissions from `demo-*` tenants. Migration must run into fresh tenant IDs, with sandbox data *excluded*, reversible staging changes, and a dry-run reconciliation report before an authorized cutover.

## C. Current status

- Synthetic data and fictional institutions: **IMPLEMENTED**.
- Internal unit/integration tests and mobile mock/bridged-browser checks: **INTERNALLY TESTED**.
- Real institutional identity, authoritative rules, external signatures, managed persistence, independently reviewed consent and privacy, source ingestion, public law publication, legally valid voting: **NOT ESTABLISHED**.

No date, institution, or legal approval is implied by this roadmap.

## D. Historical roll-call source onboarding (NOT CLEARED)

The v0.3 synthetic representation explorer supplies an exact dated join interface but does not ingest any real member histories, user residence history, district maps or named votes. Federal roll-call archives, state records and municipal minutes must each pass custodian reconciliation, historical seat/term identity crosswalk validation, legal-source authority, completeness/gap reporting, privacy review and independent sampling checks. Manual date ranges before a resident's birth are marked as history of seats, not a claim of personal representation. Voice votes must not become invented member choices. See `HISTORICAL_REPRESENTATION_CONTRACT_v0_3.md`.
