# Historical representation and exact recorded-vote UX — v1.1

**Design basis:** [historical contract v0.3](../../HISTORICAL_REPRESENTATION_CONTRACT_v0_3.md) and [standalone history engine](../../historical/README.md). Neither guarantees complete real-world coverage.

## Meaning of "all votes since birth"

Render **all available, individually attributable publicly recorded roll-call positions** on all covered motions within the selected historical period. The default range is date of birth through current date **if the user explicitly supplies birth date for that purpose**. The application may not promise that every act of governance produced a named roll call, nor infer how an official voted when only voice or anonymous totals exist.

- **Represented during residence (default):** show an official only when evidence establishes residence at the time, applicable time-effective geographical seat, office tenure at that date and corresponding named vote record. Do not assign a predecessor's vote to a successor.
- **History of current seats:** explore past officeholders for the user's currently selected seats even before birth or before moving; prominently label that these people may never have represented the user at that time.
- **Browse all records (research):** user-selected era, institution and office without suggesting a historical personal representation relation. This is not an authenticated voting feature.

### Layout / interaction contract

Header: Your Representation · [FICTIONAL DATA / VERIFIED RECORD] · coverage and last-checked timestamps.  
Control row: from date [default DOB], to date [today], office groups [multiselect], interpretation mode [represented / current-seat history / general browse].  
Timeline grouped by year and legislative chamber, then by motion. Each row: date; institution and seat; official name and tenure range; exact motion identifier; classification FINAL_PASSAGE / AMENDMENT / CLOTURE / PROCEDURAL / NOMINATION / OTHER; recorded choice YEA / NAY / PRESENT / ABSTAIN / NOT_VOTING / UNKNOWN SOURCE; result; source link or explicit FICTIONAL FIXTURE label.  
Detail sheet: proposed action and exact operative text/version, original source bytes/hash and custodian, roll-call sheet and motion context, coverage/ambiguity, corrections and time status, related issue mapping if separately reviewed. Avoid inferred motive or partisan characterization.

Use pagination / stable chronological sorting; filters must not silently change counting denominators. For a long timeline, virtualize rows while keeping keyboard and accessibility navigation coherent.

### Historical binding predicate

For record time t, user u, seat s and official o:

**Personally represented at t** only if  
KNOWN_RESIDENCE(u,t) AND APPLICABLE_SEAT(u,s,t) AND SERVED(o,s,t) AND VERIFIED_ROLLCALL_POSITION(o,m,t).

Historical residence, district boundaries and office terms use half-open intervals [from, until). Handle vacancies, simultaneous senators, at-large seats, multi-member and nonpartisan offices, district splits, annexations, moves, succession and redistricting. Unknowns remain unknown.

A roll-call event without a named individual position is NOT equivalent to NOT_VOTING, NAY, abstention or absence. SOURCE_GAP and NO_NAMED_VOTE are distinct from recorded NOT_VOTING. Count motions and individually named positions separately. A failed motion still has a valid vote record.

### Consent and DOB

The user may enter DOB voluntarily for the default. For users unwilling to disclose DOB, start at the earliest verified record or a chosen date, clearly labeled. Do not transmit DOB or personal address through query-string URLs, analytics, third-party embeddings, public caches, logs or share links. Use server-side private profile boundaries for authenticated deployments. A public research mode must not require real identity. Under-18 users in school pilots do not receive an adult federal ideological profile.

### Correspondence and personal-issue comparison

A citizen answer to a proposition is not a vote. Only compare an explicitly given DIRECT_EXACT answer to an identical motion under matched legal scope and time; REVIEWED_SUBSTANTIVE may be displayed with an explanation, not automatically called agreement/disagreement. TOPIC_ONLY, UNREVIEWED, conflicting or stale mappings do not justify stance comparison. Default output is factual side-by-side positions without a cross-official score.

Never interpret assent to an amendment as assent to the final bill. A cloture vote is about debate procedure; an approval of tabling may oppose continued consideration without resolving substantive policy support.

### Coverage proof and negative conditions

Display an interval-by-source matrix with VERIFIED_NAMED_POSITIONS, PARTIAL, SOURCE_UNAVAILABLE, NOT_A_RECORDED_ROLLCALL, NOT_YET_INGESTED and UNKNOWN. An empty list is not proof of inactivity. Historical record coverage is corpus-specific, not universal from a birth date. Corrected source versions append to provenance, not silently rewrite earlier results.

### v1.1 research acceptance

Tests must cover: before birth; birthdate=period start; exact end-date half-open boundaries; moving between districts; district reorganization; same official in multiple terms; vacancy; two simultaneous senators; unnamed voice vote; explicit NOT_VOTING versus missing record; invalid interval; source correction; partial corpus; and separation of mode outputs. For synthetic fixtures, use a second join-oracle implementation and check present-main integration with the actual UI/API. A historical engine's standalone passing tests do not prove the Python app has integrated it.
