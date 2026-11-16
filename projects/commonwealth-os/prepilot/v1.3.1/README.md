# Commonwealth OS — The Living Voter Mobile Prepilot v1.3

**Date:** November 15, 2026 (America/New_York)  
**Status:** offline, nonbinding, mobile-first UX demonstrator; not an approved election system  
**Program:** *The Constitution of Computational Commonwealths* / Democratic Assurance

## What changed since v1.2

This is a rebuilt 390px-first UI with explicit accessible state transitions, a persistent mobile navigation bar, optional four-question onboarding, a Living Voter home screen displaying the *actual survey responses*, searchable and chamber-filtered historical cases, source-first issue briefs, deliberate retrospective vote simulation, comparison with only the members who participated in the same exact recorded question, a private simulated-vote history, and reset/privacy controls.

The new sequence is `welcome → optional survey → dashboard → explore record → evidence briefing → simulated vote → reveal exact official roll call → private history`. Users may skip the questionnaire. Retaking it updates their responses.

## Run

Open `living_voter_mobile_v1_3.html` in a browser. It has no build step, external code dependencies, tracking, backend API requests, or local-storage persistence. Refreshing the browser clears its survey and simulated choices.

The artifact is **not** publicly hosted. A file preview on some mobile clients may not allow scripts; use a browser capable of opening local HTML or host it only with appropriate permission/security settings.

## Evidence and scope

The three historical questions are representative **example records**, verified against primary-source roll-call records:

- **House Roll 297** (September 14, 2026), `H.R.3276`, question: `On Motion to Suspend the Rules and Pass, as Amended`, result Passed; Representative Dale Strong (Alabama District 5): **Nay**. Source: https://clerk.house.gov/Votes/2026297 .
- **Senate Roll 259** (November 12, 2026), `PN1181-1` cloture concerning Gregory Carl Cook; Senators Katie Britt and Tommy Tuberville **Yea**. Source: https://www.senate.gov/legislative/LIS/roll_call_votes/vote1192/vote_119_2_00259.htm .
- **Senate Roll 262** (November 12, 2026), `PN1181-7` cloture concerning Anna St. John; Senator Katie Britt **Yea**; Senator Tommy Tuberville **Not Voting**. Source: https://www.senate.gov/legislative/LIS/roll_call_votes/vote1192/vote_119_2_00262.htm .

The selected constituency is a fixed AL-05 demonstration. This is **not** inferred from the user's location, home, IP or device. These records are **not** exhaustive and the two Senate questions are distinct from the House question.

The limited brief explains what Yea and Nay mean for the **exact recorded procedural question**. It does not certify full bill impacts, nominee merits, budget costs, independent civic-AI analysis, or any lawmaker's private reasons.

## Assurance boundaries

The system distinguishes (1) illustrative issue survey views, (2) user-entered hypothetical retrospective choices, and (3) authoritative named congressional voting records. These types are not coercible into one another. A recorded congressional vote is not a measurement of the user's own historically secret ballot; public voice votes may have no named-rollcall data. The demo does not infer political ideology, rank representatives, or optimize for influencing an individual's political choices.

**Not achieved:** constitutional authorization, official eligibility, secure election cryptography, proven informed agency/equality, completeness of relevant historical issue ingestion, verified issue-to-law semantic mapping, or DAP-enabled binding government action.

## Validation

`python tests/test_mobile_flow.py` checks the complete mobile flow using Chromium and Playwright, including survey completion, exact vote source display, explicit simulation before named comparisons, chamber separation, Senate procedural vote, Not Voting, edit/delete, opt-out, and reset. The command also produces nine 390px mobile screenshots and `assets/mobile_storyboard_v1_3.png`.

Validation checks UI behavior against **known finite fixtures**, not congressional completeness or electoral security. All assets in this ZIP are SHA-256-listed in `SHA256SUMS.txt`.

## Next product engineering

Add a reviewed jurisdiction selector using actual public-office tenure data; source-complete, archived House/Senate roll-call ingestion; an independently assessed question-to-motion crosswalk; accessible full source briefs; and user-controlled encrypted data storage under an approved privacy architecture. Keep simulated prepilot voting separate from institutional binding-ballot systems until the relevant organization authorizes and independently assesses them.
