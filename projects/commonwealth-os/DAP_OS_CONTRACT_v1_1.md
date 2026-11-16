# Democratic Assurance Passport — OS Contract v1.1
**Status: design with inherited scoped finite-model results, not a deployed election security certificate.**

## Data and proof types
A passport binds tenant, jurisdiction, decision, exact frozen proposal hash, governing rule hash, electorate commitment, election proof reference, tally checker version, named legal authority, rule/authority/challenge epochs, effect-scope digest, evidence dependencies and signed review/expiry.

Each component claim carries: predicate; scope; assumptions; evidence pointer and digest; checker version; result; expiry; dependencies; reviewer; and limitations. Claim classes are: HUMAN_AGENCY_EMPIRICAL, POLITICAL_EQUALITY_EMPIRICAL, ELECTION_PROTOCOL_CHECK, LEGAL_HUMAN_ATTESTATION and EFFECT_GUARD_CHECK. UNKNOWN is not PASS. Private ballots, identifiable issue profiles and private AI conversations never enter a public passport.

## DAP-S1: conditional effect soundness
Under *truthful and complete* authority records, a trusted atomic sink and complete mediation of modeled effects, any committed effect must match a verified election, current competent legal authorization, no effective stay, approved effect bytes and sufficient budget. The model has not proved real external mediation, cryptographic election integrity, legal correctness, or genuine human comprehension.

## DAP-CR1: semantic reuse
For finite possible ballot worlds b, retained authenticated transcript T(b) and a new *legally applicable* authorization decision F(b), old election evidence determines the new decision exactly iff T(b)=T(b') implies F(b)=F(b') for all b,b'. Proof is by observational indistinguishability and transcript-fiber factorization. Whether a new rule can lawfully apply to a previous vote is a separate human legal question.

## DAP-CR2: minimum new nonadaptive election information
Let D comprise pairs of ballot worlds with the same retained transcript but different new authorization outcomes. With lawful supplementary queries q_i of cost c_i, exact universal-correctness nonadaptive evidence cost is the least sum of selected c_i whose queries distinguish every pair in D. This is classical weighted set cover, not an original general optimization algorithm. It excludes law review, AI comprehension studies, effect enforcement and real-world costs. When privacy rules block necessary queries, certification is UNKNOWN.

## DAP-CR3 and DAP-CR4: compositional privacy
If the public combined transcript is invariant under legally interchangeable voter permutations, publicly certifiable authorization must preserve that invariance. Separately nonrevealing identity/ballot/AI logs may reveal a person's vote when joined. Privacy must be attacked on the **combined** published transcript and auxiliary channels. Permutation invariance alone does not establish anonymity or coercion resistance.

## Implementation obligations
Use a maintained independently reviewed balloting subsystem; a successful account login is not an anonymous ballot proof. Freeze exact source and procedure bytes before voting. Independently verify tally receipts. Enforce stays and authority changes at effect-time, with idempotent linearizable commit. Maintain public redacted evidence and separate protected record custody. The AI has no direct official vote, certification, signing or effect privileges.

## Negative controls before institutional deployment
Replay; text switch; quorum errors; wrong jurisdiction; stale rules; legal stay; concurrent revocation; cross-tenant access; correlation leaks across issuer/ballot/AI/public logs; endpoint compromise; external effect bypass; accessibility exclusions; unlawful procedure. The verifier's input source and every effect path need independent review.

These statements derive from the earlier NIGHTFALL DAP v0.2/v0.3 proof manuscripts, finite checkers and classical antecedents. Global novelty, external human proof review, secure production ballots and full four-requirement democratic feasibility are not yet established.