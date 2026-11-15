# Living Voter prepilot — UX and source contract v1.2
**2026-11-15 | DESIGN / limited local interactive demo | Extends v1.0 and draft PR #609 v1.1**

## Locked prepilot experience
1. User deliberately selects a demonstration jurisdiction; no district or voter registration inference from device location.
2. User receives a privacy explanation and optional, neutral survey with SUPPORT, OPPOSE, NO_PREFERENCE, NEED_MORE_INFORMATION and SKIP as separate outcomes. Responses are never ballots.
3. The Living Voter Dashboard shows directly answered questions, transparently reviewed inferred positions, unknowns, source coverage and explicitly cast *retrospective simulated choices*.
4. For each sourced governance matter, show exact proposition and procedural question, primary document, alternative interpretations, verified fiscal/legal context when available, competing considerations, source versions, uncertainties and amendment history. Then let the user intentionally record how they **would** have voted, without counting as a historical or binding election ballot.
5. For relevant historical issues, display official named House/Senate member rollcalls corresponding to the user-selected constituency, with dates, exact question, official outcome, recorded member position and direct links.
6. Permit clearing/correcting private choice history. No party-affinity profiling, preference inference from party, political persuasion optimization, or public voter profile.

## Accurate congressional history
- Official House Clerk rollcalls cover 1990 onward; Senate.gov named rollcalls 1989 onward; Congress.gov supplies bill/actions and some beta House member-vote APIs. Ingest directly, snapshot with provenance and report source completeness, not assume complete API coverage.
- Separate actual final passage, amendment, cloture, tabling, nominations and other procedures. A cloture Yea is not a confirmation vote, a Nay on one bill is not opposition to every provision.
- Voice and unanimous-consent votes often provide no identifiable member vote. Absence, non-recorded vote, not-in-office, Present, Not Voting and explicitly recorded Nay are distinct.
- Each question-to-record mapping has a type: EXACT_QUESTION, SUBSTANTIVE_REVIEWED, TOPIC_ONLY, UNREVIEWED or NO_RECORD. Only exact question authorizes a literal choice/rollcall juxtaposition. Other mappings disclose changed wording and limitations.
- All relevant means all matches **within a stated audited corpus/time period and relevance rule**, including counterexamples, with pagination and explicit missing coverage. Do not offer political ratings or rankings.

## Instrument reconciliation
Retain existing institutional 24 seed / up to 12 adaptive question standard and adult Living Voter dossier budget of 1 priority + 40 local + 30 federal + at most 25 adaptive. Both are research versions, not proven full legislative coverage. The offline demo uses four sample prompts and shows no real eligibility.
Protect minors from adult political profiling absent separate approved safeguards.

## DAP and binding distinction
SimulationChoice, SurveyAnswer and BallotCast are distinct legal/evidence classes, stored separately with distinct retention. Never silently promote simulations or survey views to ballots. A later legally authorized binding student-government/HOA ballot requires independent voting-protocol, identity, privacy, accessibility, DAP and institutional authority audits.

## Source-backed example fixture
- House 119/2 roll 297, September 14, 2026: H.R.3276 Local Communities & Bird Habitat Stewardship Act, suspend rules and pass as amended; Rep. Dale Strong (AL-05) Nay. https://clerk.house.gov/evs/2026/roll297
- Senate 119/2 roll 259, November 12, 2026: cloture on Gregory Carl Cook nomination; Katie Britt Yea, Tommy Tuberville Yea. https://www.senate.gov/legislative/LIS/roll_call_votes/vote1192/vote_119_2_00259.htm
- Senate 119/2 roll 262, November 12, 2026: cloture on Anna St. John nomination; Katie Britt Yea, Tommy Tuberville Not Voting. https://www.senate.gov/legislative/LIS/roll_call_votes/vote1192/vote_119_2_00262.htm
- Rep. Strong: https://clerk.house.gov/members/S001220

These three dated records are illustrative, not a complete live Congressional database. The local artifact package contains a self-contained HTML demo, fuller PRD, machine-readable fixture and finite tests.

## Acceptance
Can skip, read official source, see balanced issue information, intentionally record simulated choice, inspect genuine official rollcall statuses, erase private history and understand coverage. Never infer political identity, rank politicians, leak ballot preferences, invent voice-vote positions or mistake a simulated retrospective selection for a real election record.
