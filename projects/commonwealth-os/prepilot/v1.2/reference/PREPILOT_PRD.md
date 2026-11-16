# Living Voter prepilot — Product Requirements v1.2

## Objective and evidence boundary
Show how a continuous, mobile-first constitutional commonwealth can help a person understand their issue-specific positions and browse legislative history without performing or pretending to perform a government election. The POC displays personal referendum history only when the user **records it** or separately opts to keep a private client-side note of their own in-platform choice. A secret official ballot cannot be linked back to a user's identity by reading the public record.

## Journey (first-time adult)
1. **Scope, consent, and choice:** State that issue responses are sensitive, private, voluntary and nonbinding. Offer "skip survey / explore public roll calls." Ask the user to choose a jurisdiction manually; demo loads fictional region. No automatic party categorization.
2. **Research survey:** Optional priorities prompt, then local questions first and federal second. Three primary stance choices: `Support`, `Don't support`, `No preference`, plus a separate `Skip` (not assessed). Questions need a source and exact version; synthetic examples must be unmistakably labeled. User can pause, revisit, amend, and delete responses.
3. **Attribution screen:** Show which positions were directly expressed vs reviewed inference vs unknown/stale. A question can map to multiple law provisions only with reviewed proposition entailment; no probabilistic party/ideology label or unsupported complete law coverage.
4. **Living Voter Dashboard:** A) Private issue-position summary with basis and direct correction; B) Previous referendums: private self-recorded diary entries, clearly not verified official ballot choices; C) Federal delegation: selected state's two senators and selected House district's member(s), with sourced recorded roll-call votes and procedural-question titles; D) linked legislative record with date, chamber, tally, purpose and link; E) DAP explanation and data control.
5. **Change events:** An amended rule or bill invalidates only dependent position inferences; historical self-recorded vote is preserved as a dated personal note. Congressional member terms and roll calls are historical, never rewritten with incoming officeholders.

## Primary screens
- **Welcome:** "Your views are yours". Nonbinding consent and private data notice, view public data without political survey.
- **Question card:** source scope, jurisdiction, operative text, explicit three responses, skip, previous, progress (instrument count vs demo count).
- **Interpretation ledger:** direct / independently-reviewed derived / unknown / conflict / stale, with evidence and override.
- **Dashboard:** navigation `Overview | My positions | My referendum notes | Congress | Sources & privacy`; real vs demo data unmistakable.
- **Referendum note editor:** date, jurisdiction, referendum identifier, choice and **self-recorded, not independently verifiable** provenance. Delete/edit/export controls; no credential or receipt can prove content of a secret public ballot.
- **Congress view:** public named recorded floor votes, two senators plus one chosen congressional district, date and Congress/session/roll; `Yea`, `Nay`, `Present`, `Not voting`, `Unknown` accurately represented. Link primary source; explain motion types. No issue agreement/representative ranking.

## States and accessibility
`instrument = draft | reviewed | published | revoked`; `question = current | outdated | unverified`; `stance = support | oppose | no_preference | unknown | conflict | stale`; `history = self_recorded | private_platform_note | not_recorded`; `rollcall = official_verified | official_pending | stale | demo`.

Keyboard and screen-reader accessible; opt-in progress and non-color-only labels. No forced completion, manipulative urgency, sample party badges or targeted persuasion. Survey is optional for browsing official votes. The demo uses only memory, no browser storage or remote calls.

## Success criteria (research hypotheses, not accomplishments)
Usability completion and abandonment; correct self/official provenance comprehension; meaningful understanding of procedural vote questions; error rates on proposition mapping; ability to delete a private note; clear differentiation between inferred stance and real ballot; consent recall; subgroup accessibility and burden. All preregistered before recruiting real participants. No political targeting or individualized persuasion optimization.
