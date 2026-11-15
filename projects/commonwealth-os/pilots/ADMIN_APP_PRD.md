# Civic Decision Ledger — Administrative App PRD v1.0

**Status:** proposed product design; no live pilot or data import. See parent Commonwealth OS blueprint.

## Institutional use cases
Three distinct pilot governance environments share one system core:
1. HOA board and manager: covenants, rules, assessments, facility decisions, member eligibility.
2. University SGA representatives, executives and advisors (UAH proposed first): agenda, resolutions, allocated budgets, formal campus-policy recommendations.
3. Huntsville, Alabama municipality (final pilot): council docket, zoning, ordinances, services, budgets. A 2027 city pitch can use only synthetic records.

The institution defines the lawful voting population and authority source; students are not automatically all eligible SGA voters; HOA residents are not automatically legal voting members; municipal residents are not automatically eligible council members.

## Roles and experiences
- Representative: action-centered home, review assigned bills, redline, propose amendments, discuss and cast authorized official votes **only if individually approved**.
- Secretary/clerk: agenda and minutes, attendance snapshot, sources, certification, version history, publication proposal.
- Presiding officer: session control, recognized speakers, motion scheduling, authority-checked voting activation.
- Institutional admin: access provisioning, rules revision, identity integration, public release and audit.
- Independent auditor: read-only evidence and replay.
- Later: constituent private profile and public transparency portal under separate consent and publication permissions.

## Navigation
Home | Bills | Session | Records plus persistent AI helper; administrator-only Sources | Members | Rules | Questions | Publish | Audit.

## Canonical lifecycle
DRAFT -> IN_REVIEW -> AGENDA_SET -> DELIBERATING -> MOTION_LOCKED -> BALLOT_OPEN -> BALLOT_CLOSED -> PENDING_CERTIFICATION -> CERTIFIED or REJECTED -> REVIEWED_PUBLICATION.
Every legal transition is server-enforced. Draft/version changes invalidate pending voting authority. Exact rule, quorum, eligibility and motion version are prerequisites for certification.

## Research questionnaire integration
- One controlled policy-language schema reused across all three pilots.
- Each candidate question links to an official governing source; hypothetical research questions must be labeled as such.
- Standard responses: Support / Do not support / No preference / Need more information / Not applicable / Skip.
- Distinguish respondent sampling from official electorate counts. No preference and unanswered are not approval.
- Question variants are reviewed independently for semantic equivalence and framing effects before approval.
- Profile answers are nonbinding advisory evidence unless an additional explicit legal grant covers the exact matter and action.

## Transparency stages
0. Institutional workspace private; participant notice must disclose later transparency goals.
1. Reviewed publication of nonconfidential proposals, revisions, session decisions, and expenditures.
2. Public search, metrics, item history and downloadable provenance records.
3. Optional authorized constituent participation. Never publish individual voter preference profiles.

## Acceptance tests
Mobile/desktop full synthetic workflow, role separation, tenant isolation, correction trail, prompt injection resistance, idempotent voting, reproducible receipts, quorum/version/threshold checks, public release approval, WCAG 2.2 AA accessibility review. Passing synthetic tests does not establish legal authorization or secure Internet voting.
