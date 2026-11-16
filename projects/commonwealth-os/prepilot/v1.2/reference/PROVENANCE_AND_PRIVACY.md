# Provenance model: keep citizen preference, vote diaries and Congressional record distinct

## Claim types
| Claim | Meaning | Grounding | Display |
|---|---|---|---|
| `ISSUE_PREFERENCE` | Opinion explicitly chosen in question | question version, user response, consent scope | Private; nonbinding |
| `REVIEWED_INFERRED_POSITION` | Position entailed by independently reviewed law-question link | exact question+law version and reviewer | Private, separately labeled, correctable |
| `SELF_RECORDED_REFERENDUM` | Person says they chose option X in past ballot | user-provided private diary entry | "You recorded" / "self-reported"; never "verified ballot" |
| `PLATFORM_SECRET_BALLOT_RECEIPT` | A properly designed ballot system may provide participation/inclusion proof | institution-approved election verifier | NOT a server-linked proof of the selected secret choice |
| `OFFICIAL_ROLL_CALL` | An identifiable elected federal legislator voted Yea/Nay/other in recorded House/Senate vote | primary chamber record and recorded member ID | Public, exact date/roll/procedural question |
| `ISSUE_RELATION` | A source-reviewed connection between a civic issue and a bill/provision or vote | typed, scoped relation, human review, evidence | "Related" only when reviewed; not "same question" by default |

No silent transformation between types. `SELF_RECORDED_REFERENDUM` is particularly sensitive; even with an owner's consent, the service must avoid central storage by default. Device-only private diary with explicit export/delete is the preferred prototype pattern. Nonbinding survey preferences and actual casting must always be separate user actions and security domains.

## Source strategy (checked 2026-11-15)
- **U.S. Senate official roll calls**: https://www.senate.gov/votes/ and XML resources https://www.senate.gov/general/XML.htm
- **House recorded roll calls**: https://clerk.house.gov/Votes ; House individual-vote beta endpoint documented at https://api.congress.gov/ and https://github.com/LibraryOfCongress/api.congress.gov/blob/main/Documentation/HouseRollCallVoteEndpoint.md
- **Congress.gov API**: https://api.congress.gov/ supplies member and bill metadata, roll calls and House recorded member votes; access may require key and rate-limit accommodation.
- **Secret public ballot distinction**: public history records generally show whether one voted, not selections. See https://www.sjgov.org/docs/default-source/registrar-of-voters-documents/election-advisory-committee-documents/june-1-2023/consent-item-a-faq.pdf and https://usvote.freshdesk.com/en/support/solutions/articles/151000209454-why-can-t-i-find-a-history-of-who-i-voted-for-in-past-elections- .

## ETL discipline
1. Load a source *snapshot* with timestamp, issuer and original URL. Preserve raw bytes and digest.
2. Join each vote to `congress`, `session`, `chamber`, `roll_number`, `member_bioguide_id`, `date`, `question`, `bill_id` where applicable, `cast_category` and `data_source`.
3. Require full agreement of roll-call identity and member identity, recorded procedure, and serving member term before showing a named choice. Otherwise `UNKNOWN` or "Not individually recorded".
4. Associate state/district only from user selection/authorized district finder. Never infer residency from browser location.
5. A congressional **procedural vote** is not equivalent to substantive support for the measure. Do not compare automatically against a local referendum or generate a single "alignment score".
6. Issue-level relation must include an independent reviewer, mapping version, source citations, and status `RELATED_REVIEWED` or `NO_COMPARISON`; never claim exact proposition equivalence without affirmative review.
7. Expired/changed records must show as-of date and correction trail. Missing data is not evidence of abstention.

## Threat and privacy review
- Joint leaks: identity lookup timestamps + AI question responses + private diaries + ballot issuance metadata can reveal preferences; segregate and assess collectively.
- Coercion: a screenshot or self-recorded vote diary can be coerced; **never** present these as official proof of secret ballot selections.
- Consent: separate purpose-scoped choices for research, local private storage, external district lookup, sharing of notes, and reminders; each off by default.
- Access: citizens can inspect, correct and erase private diaries/issue answers. Export requires explicit action; prevent public caching, analytics collection and search indexing.
- Algorithmic framing: no targeted political persuasion, candidate/party classifications or ideologically optimized question order. Neutrality reviews and alternate wording experiments require research consent.
- Minors: adult federal politics instrument not offered to underage students by default.
