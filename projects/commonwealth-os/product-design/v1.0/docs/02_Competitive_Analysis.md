# Comparative landscape and design opportunity

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Method and scope

This is a **product-feature comparison**, not a formal freedom-to-operate or exhaustive patent/prior-art review. Official documentation was checked on 15 November 2026 for the entries marked *source-checked*. An absent feature in checked documentation is **not proof that the software cannot support it** through customization or deployment practice. Earlier exploratory comps without adequate official source confirmation are listed separately.

## Key comparable systems

| Product | Officially documented strengths | Specific design lesson / boundary | Evidence |
|---|---|---|---|
| **Decidim** | Proposals, amendments, version integrity, participation processes and administrator-updated accountability/milestones | **Do not claim Decidim lacks traceability.** Investigate machine-checkable legal-authorization and implementation proofs *across* sources and governing authorities | [D1](14_Sources_and_Attribution.md) |
| **CONSUL Democracy** | Proposals, verified supports, voting, budgets, participatory collaborative legislation with phases, revisions, follow-up | Treat it as a serious legislative peer; distinguish provenance-preserving change-triggered personal profiles and rule-specific decision certification | [D2] |
| **Polis** | Structured agree/disagree/pass on statements, clusters and consensus across large-scale deliberation | Integrate open-ended deliberation insight but avoid converting opinion groups into binding decisions | [D3] |
| **Loomio** | Templates for consent/consensus/advice, discussions, votes, reasons, outcomes and review reminders | Supports a coherent decision record; product must additionally check venue-specific authority and effects rather than equating a poll to a law | [D4] |
| **Go Vocal** | Resident proposals, supports, discussions and engagement reporting | Useful pattern for municipal civic-facing participation; require source-to-rule linkage and unbiased aggregate denominators | [D5] |
| **Granicus Legistar** | Legislative files, agendas, meeting management, minutes and publication | Use it as authoritative **input/adjacent workflow**, not pretend to replace its functions in early city pilot | [D6] |
| **Quorum (goquorum.app)** | Versioned constitution, article-specific challenges, AI-assisted motions and configurable AI voting seat | Excellent constitutional versioning reference; **explicitly exclude AI voting seats** from Commonwealth OS | [D7] |
| **ElectionGuard** | Voter verification codes, challenge process and third-party verifiability artifacts for elections | Cryptographic evidence is not evidence of valid jurisdiction/rules or effect-time authorization; evaluate rather than claim integrated support | [D8] |
| **OpenZeppelin Governor** | Proposal→vote→quorum→queue→execution for on-chain control | Illustrates strongly coupled decision/execution in smart-contract environments; not a ready-made legal municipality workflow | [D9] |
| **CivicPlus/Municode** | Municipal codification/public code library (Huntsville uses a municipal code provider) | Treat published code and enacted-but-not-yet-codified measures distinctly; build synchronization and reconciliation | [D10] |

**Also reviewed earlier but not fully re-verified this session:** eSCRIBE, Diligent Community, Anthology Engage, OpenMeeting, StuGov, Vocdoni, and other campus-specific legislative tools. Do not infer gaps for them without a named source, release, and feature-level audit. The original comparative inventory is broader than the verified subset above.

## Unifying gap hypothesis: decision-state discontinuity

Existing categories often concentrate on one or more of: institutional document management, citizen engagement/deliberation, binding aggregation, cryptographic tally verification, or implementations. The research target is to establish a **uniform, testable chain of meaning and authority** when a document is changed, a rule is revised, membership shifts, or a decision produces effects:

`authoritative source → applicable rules → provision/version → participant eligibility → expression or authorized vote → certified outcome → implementation event → change/re-elicitation`.

The contribution is **not** “nobody supports this step.” Decidim and CONSUL already cover multiple steps. The proposed differentiator is verifiable continuity *across institutional rules, legal document versions, personal preference provenance, and authorized effects*; this remains to be implemented, evaluated and compared empirically.

## Four explicit points of distinction

1. **Living preference ledger:** provision-level source-grounded, continuously editable and private direct/inferred/unknown states; change notifications target stale answers.
2. **Authority portability:** independent institutions instantiate different rulebooks without sharing governance entitlements.
3. **Democratic Assurance Proof Passport:** each consequential decision packages its legal/charter authority, eligibility, quorum, text version, outcome, exceptions and effect record; a defined external checker can replay it.
4. **Separation of consultation and lawful voting:** never count profile positions as ballots; publicly distinguish resident sample opinions from binding representative decisions.

## Competitive validation plan

Choose a controlled case study: a proposal created, materially amended after a public comment, put to a vote with a changed membership roster, adopted, then incorporated into a new code edition. Test in target baseline systems where permitted. Compare provenance retention, authority proof completeness, human review steps, exception handling and total operating cost. Publish neutral feature-level findings with version/build IDs and vendor responses.

## Sources

Full URLs, exact investigated assertions, and verification limitations appear in **14_Sources_and_Attribution.md**.
