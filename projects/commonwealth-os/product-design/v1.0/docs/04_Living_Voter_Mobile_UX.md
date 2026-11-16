# Living Voter mobile experience specification

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Experience goals

A resident should be able to (a) understand what a question really covers, (b) respond or pass, (c) see why a law provision has a given state, (d) correct it, and (e) be notified only when the relevant legal substance changes. **Never suggest a profile response has been officially cast as a ballot.**

## Screen inventory and acceptance tests

| Screen | Main information and actions | Acceptance criteria |
|---|---|---|
| LV-01 Welcome / role | Institution, adult/minor flow, purpose and separate privacy consents | All important data uses visible before collecting answers |
| LV-02 Home | Local and federal **validated** coverage with denominator, active changes, task shortcuts | Unknown and unverified mappings not counted as “support measured” |
| LV-03 Local onboarding | 40 or fewer seed items (research target), three large buttons, source explainer, progress | Keyboard/voiceover readable; no default choice; skip/pause supported |
| LV-04 Federal onboarding | Separate source corpus, 30 seed items + scoped adaptive review | Local stage offered before federal; no fabricated completeness |
| LV-05 Law ledger | Filter by jurisdiction, status, direct/inferred basis, evidence freshness | Every law links to authoritative text/version and influence explanation |
| LV-06 Law detail | Official text, effective date, normative clauses, answer attribution, overrides | Direct override prevails prospectively and logs provenance |
| LV-07 Changes inbox | Proposed, amended, repealed, integrated with diff and action | Editorial relocation handled as distinct event with proof; no false re-vote |
| LV-08 Profile/Privacy | Identity assurance status; export/delete; consent; language/accessibility | Erasure constraints and retention exceptions explained accurately |
| LV-09 Consultation/ballot | Clear title “Advisory response” **or** “Authorized ballot” | Separate route and confirmation, legal basis, eligibility and receipt |
| LV-10 AI explanation | Source-bound summary, evidence, alternative interpretations, uncertainty | Can't fabricate citations or cast positions/votes; user controls outcome |

## Mobile patterns

Bottom navigation: **Home / Laws / Changes / Profile**. The first screen foregrounds the next useful action, not political affiliation. Legal text uses collapsible plain-language explanation + primary authoritative text + change diff, never summary alone. Provide tap target minimum 44×44 CSS px as initial guideline, readable minimum text, reduced motion and high contrast. All state indicated by text and icon as well as color.

## Question card microcopy

**Label:** Local ordinance group / Federal law group. **Prompt:** neutrally worded, single normative dimension. **Choices:** Support / Don't support / No preference. **Context:** “This question may inform the following provisions,” with clear direct/inferred status and “Not an official vote.” **Review:** “This answer does not settle provisions with exceptions, penalties or tradeoffs not mentioned here.”

## Law-status ledger semantics

- “Directly answered”: user answered about that exact operative provision/version.
- “Provisional / inferred”: a reviewed question may support a suggested interpretation but is not a vote.
- “Uncertain”: ambiguity, contradiction or unreviewed equivalence; ask or abstain.
- “Unknown”: no admissible evidence.
- “Outdated”: answer refers to superseded legal text; prompt version-specific review.

Display legal version and last checked source timestamp per record. Display `n/m mapped` only alongside a **sample corpus label** and coverage formula; in the concept demo all counts are synthetic.

## Response integrity and dark-pattern prohibitions

No default choice, forced question, order optimized to move ideology, turnout nudges based on sensitive beliefs, party labels used to guess policy preferences, or notification wording that misrepresents an inference as an obligation. Users must be able to deliberately mark “No preference,” distinct from not answering.

## Prototype linkage

`../prototype/living_voter_dashboard_prototype.html` is the retained concept artifact, with 7 synthetic grouped questions over 14 fictional provisions. It demonstrates flow and local browser persistence **only**. It is not the 96-question instrument, source-ingestion system, identity service or production polling engine.
