# Information architecture, roles and journeys

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Application topology

**Commonwealth OS Shell:** account and institution switcher, authenticated context, alerts, support/accessibility, status and consent.

- **Chamber** (elected/appointed institution representatives): Today; Bills; Deliberation; Votes; Audit; AI assistant.
- **Living Voter** (adult resident or member, scoped by institution): Home; Laws; Changes; Profile; interactive question path; source/attribution ledger.
- **Steward** (clerk/admin): Institution; Rulebook; Roles & eligibility; Agendas; Documents; Publication; Security; Audit & incidents.
- **Public View** (phase gated): records and aggregate participatory results only where legally publishable; never identifiable private profiles.

UI **must visually pin the active institution, role and authority mode**. A student senator in UAH cannot accidentally act as an HOA board member or a Huntsville resident.

## Adult resident flow — local before federal

1. Choose institution/jurisdiction; privacy explanation and data-use consent.
2. Eligibility status: unverified preview / verified institution member / verified registered voter (only after authorized integration). Avoid treating identity as voter-roll qualification.
3. Open priorities prompt (optional/skip allowed). Then up to 40 local policy seeds, each with Support / Don't support / No preference.
4. User sees a transparent ledger: directly answered questions, provision-level *inference candidates*, unknowns and conflicts; can override a provision directly.
5. After local block, offer federal profile: up to 30 federal seeds; up to 25 adaptive prompts total across instrument, budgeted for unresolved high-value ambiguities.
6. Subsequent visits emphasize targeted change queue, not redoing the whole questionnaire. User can pause, resume, withdraw consent, export and erase.

**Important:** For 2027 university participants and school members, the operational institution dashboard is *not* the same as an official municipal registered-voter profile. School minors do not receive federal political profiling.

## Representative workflow

`Sign in → institutional role confirmed → task dashboard → open proposed act → authoritative text/version and prior changes → AI summary with citations → debate / propose amendment → check eligibility and voting window → confirm locked text → cast authorized vote (if approved) → audit receipt → outcome & implementation view`.

**Critical interrupts:** source stale; rulebook changed; quorum rule unavailable; vote window expired; eligibility contested; amendment after lock; external system mismatch; trust boundary unavailable. These must visibly block binding acts rather than render a green success state.

## Clerk workflow

`Import source → reconcile version → set rules and roles → define agenda → make proposal public → authorize debate/voting under institution bylaws → run tally/verifier → publish disposition + evidence → track effective action`.

Clerk corrections to sources use append-only superseding events with reasons; never erase the underlying evidence for an authorized result.

## Notification taxonomy

| Event | Recipient | What app does | State |
|---|---|---|---|
| Draft introduced | Subscribers / eligible participants | Summary, source, direct input option | New, no vote presumed |
| Substantive amendment | Those whose relevant earlier views may no longer apply | Reopen targeted questions, invalidate mapping when needed | Stale until confirmed |
| Repeal | Affected participants | Ask about repeal *proposal*, preserve prior law position | Proposal separate from existing-law preference |
| Codification/integration | Interested users | Show old/new location and equivalence proof | No unnecessary prompt if purely editorial |
| Vote scheduled / text locked | Eligible representatives | Authority-mode reminder, locked hash, deadline | Binding only when permitted |
| Outcome implemented | All relevant viewers | Source-based effect update | Effect confirmed / disputed / pending |

## States and copy rules

- **Preference:** `support`, `oppose`, `neutral`, `unknown` (no answer), `conflict` (evidence inconsistent), `stale` (source changed).
- **Basis:** `direct-provision`, `direct-topic`, `inferred-reviewed`, `inferred-unverified`, `not-assessed`.
- **Vote:** `not-open`, `open`, `cast-pending`, `cast-receipted`, `tally-pending`, `certified`, `challenged`, `void`.
- **Authority:** `advisory`, `institution-authorized`, `lawful-government`, `unknown`. Never display unverified authority as certified.

## Low-bandwidth / non-smartphone path

Provide accessible web, assisted kiosk or paper-backed channels subject to authority and auditing; manual transcription must be independently reconciled. Do not exclude participants lacking smartphones.
