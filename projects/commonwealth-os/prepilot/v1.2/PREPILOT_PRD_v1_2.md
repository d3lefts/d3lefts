# Commonwealth OS — Living Voter prepilot product requirements v1.2

**Program:** *The Constitution of Computational Commonwealths — Democratic Assurance*  
**Date:** 2026-11-15 · **Scope:** public-facing nonbinding proof of concept · **Status:** DESIGN + local offline reference UI (not an election system)

## North-star outcome
A participant can choose a jurisdiction, answer voluntary source-linked policy questions, inspect an accurate neutral evidence briefing for a relevant issue, intentionally record how they *would* vote on the exact issue (nonbinding simulation), and see the officially recorded votes of the members of Congress representing the selected constituency on matched historical roll calls. User may inspect primary source records and correct private preferences. No inference is presented as a real vote.

**Critical sequence:** jurisdiction + privacy disclosure → survey → Living Voter Dashboard → choose governance matter → primary text + balanced considerations + unknowns + procedure explanation → explicit retrospective voting choice → personal choice history → member-by-member historical roll-call record and citations.

## Prepilot user flows
1. **Landing:** Opt-in, locally scoped *example constituency*, private by default; do not infer voter residence from device, IP, state of visit or previously saved political opinions. No verification/eligibility claim. Demo fixture Alabama's 5th House district + Alabama's two senators, with transparent notice; configurable to other user-provided districts after verified official mapping.
2. **Survey:** Configurable research instrument. Primary visible options *Support / Don't support / No preference*; *Skip* and *Need more information* remain distinct. Source-linked questions express one normative dimension only and show original text/version, uncertainty, tradeoffs, costs and exemptions when available. Never infer a party/ideological label or cast a ballot from survey answers. No forced answers.
3. **Dashboard:** Show *Your survey views* (direct/derived/unknown), *Your retrospective choices* (explicit simulation only), *Official recorded votes* (named public records with action type, date and member), and *Coverage & evidence gaps*. Avoid approval scores or politician rankings. For each item show personal status and official records side by side with an explanation of whether their questions are actually comparable.
4. **Issue detail/How to vote:** Present exact current or historical proposition, governing body, stage and date; plain-language summary labeled as interpretation; legal text and primary sources; best grounded arguments and counterarguments; fiscal or administrative tradeoffs; procedural significance and what a Yea/Nay changes; source provenance and recency. User must confirm exact text and voluntary choice for any retrospective simulation; offer *No preference* and *Skip*.
5. **History:** A *retrospective choice made in Commonwealth* is not a historical official ballot. A later verified institution-authorized platform ballot gets a distinct custody and privacy mode and cannot expose individual secret-ballot selections via public DAP. Secret off-platform votes cannot be recovered or inferred from public records. Personal history is editable/exportable/deleteable within actual data retention limits.
6. **Official comparison:** Show every in-scope *available named roll call* from the selected legislators, filtered by scope/topic/time and with complete-source coverage reporting. Distinguish substantive final passage, amendment, cloture, procedural motions and nominations. Always show Yea, Nay, Present, Not Voting or unavailable as documented; never turn Not Voting into opposition or infer motive. Voice/consent votes lack member-level positions. Never claim a vote on a bill proves a stance on every contained provision. Every `historical_record` binds chamber, congress, session, vote number, precise question, action type, date, bill or nomination, outcome, member's record and source URL. Multiple records may map to one issue; no misleading one-to-one inference.

## Survey instrument reconciliation
- Existing GitHub `pilots/QUESTION_STANDARD.md`: 24 seed questions per institution (8 common + 16 specialized), up to 12 adaptive.
- Earlier `Commonwealth_OS_Design_Dossier.pdf`: adult Living Voter research budget of 1 open priorities prompt + 40 local seeds + 30 federal seeds + at most 25 adaptive; *not validated as comprehensive law coverage*.
- v1.2 keeps **both as versioned configurable research instruments**. The offline demonstration offers a smaller illustrative set. More questions never imply more historical votes or democratic authority. Adult local→federal order is user-configurable. For minors, do not enable federal political profiling without dedicated authorization and safeguards.

## Neutrality and political privacy
No personalized persuasion, politician scoring, political-party affiliation inference, ideology classification, manipulative framing, unsolicited issue prioritization, third-party resale or secret campaign use. Responses private and optional. Client-only demo stores answers in volatile memory (page refresh clears); production requires separate, minimally retained private account scope with deletion/export and lawful retention exceptions. No device-location-based constituency selection. AI may retrieve, compare and explain sources but may not select a voting outcome for a user.

## Evidence model & adequacy boundaries
A relevant-issue link is a claim, not a vote. Classify mapping `EXACT_QUESTION`, `SUBSTANTIVE_REVIEWED`, `TOPIC_ONLY`, `UNREVIEWED`, `NO_RECORD`. Only `EXACT_QUESTION` supports literal same/different vote comparison; `SUBSTANTIVE_REVIEWED` must disclose differences in wording, exceptions, authority and temporal applicability, never assert equivalence unless independently validated. All others show contextual links only. Relevance filter must allow **all** verified matched historical records (pagination, declared corpus and gaps), not just curated supportive votes. Missing vote: explicitly report absent, unavailable, voice, not-in-office, unverified or no-available-source.

## Data entities
`SurveyInstrumentVersion`, `SurveyQuestionVersion`, `SurveyAnswer`, `IssueVersion`, `SourceDocument`, `EvidenceBriefVersion`, `IssueVoteMapping`, `SimulationChoice`, `ConstituencySelection`, `MemberTerm`, `RollCallRecord`, `MemberRollCallPosition`, `RecordCoverage`, `SourceReview`, `PrivacyConsent`, `DAPClaimRef`.

`SimulationChoice` and `BallotCast` use distinct tables, keys and event namespaces. `SurveyAnswer` cannot be written to `BallotCast`, and `SimulationChoice` cannot become `BallotCast` even when identical. Profile responses cannot be exported as named citizen votes. Official congressional records are public, but user-specific joined response/constituency/history is not.

## API and provenance contracts (proposed, not live)
- `GET /public/v1/issues?jurisdiction=&topic=&recordType=&cursor=`: verifiable source coverage and exact query type.
- `GET /public/v1/rollcalls/{chamber}/{congress}/{session}/{number}`: immutable per-rollcall source and ingest hash.
- `GET /private/v1/me/survey` / `POST /private/v1/me/survey/responses`: privacy-scoped, consent-aware, independently sourced.
- `POST /private/v1/me/simulations`: explicit idempotent retrospective decision event; never a real ballot.
- `GET /private/v1/me/dashboard`: joins only permitted read models; externally verified official rolls never interpreted as a proxy personal vote.
- `GET /public/v1/evidence/{issueVersion}`: facts, arguments, constraints, sources, mappings, unknowns, human review and corrections.

**Primary sources:** House Clerk official XML roll calls since 1990; Senate.gov roll calls since 1989; Congress.gov bill/actions and member records, subject to changing API coverage. `Congress.gov` API House vote member endpoint is beta and cannot be assumed to cover all procedural or earlier votes. Use a source adapter fallback and gap ledger. Relevant local ordinances require jurisdiction-specific authority, consent and source mapping; none are currently ingested into the demo.

## Acceptance (prepilot)
1. An adult participant can complete/skip survey and navigate dashboard without giving a name or real registered-voter identity.
2. UI maintains separate status labels for survey, inferred policy view, retrospective simulated choice and certified organizational ballot.
3. The evidence pane includes source-linked exact voting question, procedural meaning, alternative views, unknowns and context before a user can choose.
4. No prior simulated choice is edited without an explicit user event; refresh/delete clears demo.
5. Official member attribution, office date, vote question, recorded position and record URL exactly match the cited source fixture; Not Voting remains Not Voting.
6. An absent/voice/irrelevant vote is never invented or converted to position; every topic filter reports corpus/coverage limitations.
7. User can inspect every relevant matched record through source link; rankings, endorsements, and aggregate representative alignment scores are absent.
8. Test absence of selection bias: all reviewed issue-match results from bounded corpus returned, including divergent/absent votes.
9. Privacy negative tests: survey → ballot privilege escalation forbidden; AI profile → public log joins forbidden; cross-tenant user profile read fails.
10. A live binding institutional vote remains disabled in this prepilot demonstration; later authorized pilots follow the separately reviewed DAP vote/certification workflow.

## Academic evaluation
Preregister comprehension, balanced framing, source recall, procedural-vote comprehension, choice revision under contrary evidence, answer-to-question consistency, assistive-technology accessibility and dropout; separate participant self-selection from population-level claims. Human agency and equality require experimentation, not a successful technical demo.
