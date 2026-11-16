# Product acceptance and design audit — Living Voter v1.3

## Passed in offline local browser test
- 390x844 mobile viewport and touch-target navigation.
- Welcome clearly identifies fixed *example* constituency, nonbinding demonstration, and no geolocation.
- Survey is skippable and 4 response prompts are treated as illustrative question wording, not political profiling or official referenda.
- Dashboard displays answered survey topics and response labels and enables review/retake.
- Issue explorer supports client-only search and chamber filter.
- Briefing shows exact motion, date, chamber, procedural meaning, verified source hyperlink, considerations on both sides, and limits.
- User must intentionally submit Yea/Nay/No preference before named officials' votes are displayed; choices can be revised and deleted.
- Comparison shows ONLY the officials with a record on that exact roll call; unrelated chamber votes are not treated as substitutes.
- Explicit Not Voting is neither Nay nor abstention.
- Private history can be erased, memory resets on refresh, no persistent local storage or third-party scripts.

## Not validated
- VoiceOver/TalkBack and native mobile Safari: requires separate device test.
- Full WCAG 2.2 AA: provisional contrast/semantic design only.
- Election-grade cryptography and actual binding ballots: not included.
- End-to-end official-record ingestion completeness or retrospective issue ontology.
- AI-sourced explanatory accuracy, empirical neutrality, accessibility equity and voter comprehension.
- Voter registration or real congressional district lookup.
- Figma native editable composition: tool plan limit prevented Figma edits; current artifact remains HTML and screenshots.

## Design invariants
1. Never derive a user's historical vote from a published election outcome.
2. Never let a survey response count as a real vote.
3. Never conflate a cloture vote with confirmation; neither is a roll-call vote by the other chamber.
4. Never display a ranking or simplified politician ideological score.
5. Whenever source coverage is incomplete, expose its bounds.
6. Before personalized AI is introduced, isolate it from ballot submission and private preference export.
