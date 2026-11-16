# Commonwealth OS — competitor parity and public accountability benchmark v1.2

**Scope:** fictional browser-only participation experience in `docs/commonwealth-browser/`; canonical source mirror `projects/commonwealth-os/apps/browser/`. No claim of parity with live, multi-user, audited civic deployments.

## External benchmarks consulted

- [Decidim feature components](https://docs.decidim.org/en/develop/features/components.html): proposal/amendment wizard, comments, debates, participatory texts, meetings, surveys, budgets, result/accountability tracking and elections.
- [Decidim accountability](https://docs.decidim.org/en/develop/admin/components/accountability.html): trace proposals and decisions to public results, progress reports, and milestones.
- [CONSUL citizen proposals](https://docs.consuldemocracy.org/docs_general/participation-processes/citizen-proposals): proposal supports, moderation/community discussion, transparent process tracking.
- [CONSUL proposal use guide](https://docs.consuldemocracy.org/use_guide/1.-citizen-proposals): related proposals and discussion communities.

These are serious incumbent capabilities; do not falsely assert they lack historical records, amendments, or transparency extensions. Commonwealth's specific integration and historical source-custody differentiation remains a hypothesis until controlled evaluation.

## Feature parity status (current browser scope)

| Capability | Commonwealth v1.2 | Live parity achieved? |
|---|---|---|
| Proposal creation and search | Fictional searchable, versioned in-memory docket | No; no authentication, publication or persistence |
| Consultation and comment threads | One fictional visitor, stance/concern/question; reviewers can reply with written reasons; unanswered count remains visible | No; no real multi-user moderation, replies or notification service |
| Amendments and collaborative text | Alternative-text proposal, simulated acceptance/rejection, immutable exact-text revision trail, stale responses excluded | No; no real collaborative sessions/secure approvals |
| Advisory responses | Voluntary explicit revision-bound local preference with Unknown ≠ No preference | No; single-visitor simulation, not collective polling or ballots |
| Participatory budgets | Institution-scoped fixed-ceiling cost planner with strict over-budget warning | No; no appropriation or authoritative projects |
| Meetings and offline access | Fictional agenda cards, minutes status, proposed non-digital participation route | No; no scheduling, RSVP or offline transcription |
| Public feedback | Reasoned simulated acceptance/decline/review, explicit pending state, monotonic evidence milestones, correction request log | No; no accountable institution or real implementation data |
| Historic representation | Fictional dated residence/term/motion joins and source-status gaps, separate current-seat research mode | No; real roll-call adapters, GIS and trusted identity not connected |
| Proof Passport | Independent-scope ten-check demo contract and digest export retained | Not an authoritative source, ballot signature or proof of edited proposals |
| Privacy | Local memory only; dossier omits advisory positions and personal comment bodies | No; a protected production profile service is not implemented |

## Specific design improvements targeted at participation weaknesses

1. **Substance before counting:** ask contributions to identify whether they support, question, or object, and require actual text rather than relying on support counts. The browser cannot establish deliberative quality; study it independently against peer systems.
2. **Every contribution has an answer status:** UNANSWERED_FICTIONAL versus ANSWERED_IN_SIMULATION; users can see unresolved concerns. The steward's review is explicitly a non-authenticated role-play.
3. **Never hide the exact motion or revision:** accepted amendments create a new text version; prior advisory positions are not silently carried forward.
4. **Respond with reasons:** pending institutional response displayed; representative/administrative reasons required for synthetic state transitions, with visible implementation milestones and correction requests.
5. **Fiscal trade-off legibility:** selecting budget items shows exact subtotal, remaining ceiling, and invalid over-budget slate. It does not become a real appropriation.
6. **Source custody travels with claims:** use fixture IDs and explicit FICTIONAL_UNVERIFIED source status; link related history only as topic, not substantive equivalence. No invented named votes from voice votes or missing rows.
7. **Privacy boundaries in transparency:** public dossier provides staged disposition and event metadata without exporting private advisory votes or comment bodies. A user-authored proposal title/text is included, requiring review before optional download.

## Most important unresolved competitive gaps

True multi-user participation, identity/eligibility, moderation and harassment appeals, accessible assisted/offline participation, real meeting integration, production database, audited and independently custodial roll-call imports, secure ballots where lawfully needed, independent verification of executed institutional actions, operational reliability, and real participant outcome studies.

## Release gate and reproducible acceptance

- `node --test docs/commonwealth-browser/tests/*.test.mjs` plus canonical mirror tests.
- `npm test` in `projects/commonwealth-os/apps/browser` for original procedural checker and all new modules.
- Browser-local desktop/mobile interaction test for draft creation, discussion, amendments, revision invalidation, reply, status, budget overflow, history link, zero horizontal overflow; static module/network loading still not independently verified.
- Untrusted user text rendered with DOM `textContent`, never HTML insertion.
- New source/UI/index/test files mirrored byte-for-byte between `docs/commonwealth-browser/` and `projects/commonwealth-os/apps/browser/`, asserted by CI.
- **Explicit stop rule:** do not turn on real user profiles, public submission, real municipal import, or binding votes without separate identity, lawful authority, privacy, operational and independent audit evidence.

**Comparative conclusion:** this narrows the **fictional browser UX** feature gap with Decidim and CONSUL. It does not make Commonwealth an equivalently mature or publicly deployable system. The unique-research claim is contingent on independent comparison of historical matching accuracy, issue correspondence, source completeness, deliberative quality, transparency and total operating costs.
