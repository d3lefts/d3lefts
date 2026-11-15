# Civic Neutral Question Standard — Draft v1.0

## Purpose
Measure constituent views on actual institutional decisions while minimizing question-wording effects. No natural-language template guarantees neutrality: the standard combines semantic control, independent review, and empirical testing.

## Required canonical policy object
Each item has policy/source IDs and versions, governing authority, jurisdiction, proposed action (adopt/repeal/amend/fund/require/prohibit/permit), explicit policy object, affected population, amount/threshold, time and effective date, legal status, source URL and content hash, and source reviewer.

## Constrained wording
Template: **Should [institution] [neutral operative action] [precise subject] [scope, quantity, time]?**
- Exactly one actionable decision per question; split double-barreled proposals.
- Exclude emotive language, implied approval, asserted benefit, appeals to authority, partisan endorsements and unverified fiscal estimates.
- Use legally necessary numbers and exceptions rather than vague benefit adjectives.
- Explain proposal consequences only in a separate, source-checked and balanced information panel.
- Use a fixed response order or randomized order with logged experimental control where permitted.

## Distinct responses
Support; Do not support; No preference; Need more information; Not applicable to me; Skip.
A request for more information, no opinion, and missing response are **not** equivalent. Responses must not be transformed into binding votes by default.

## Certification sequence
1. Verify exact source authority and legal status.
2. Derive canonical policy semantics.
3. Produce two or more independently reviewed meaning-preserving phrasings.
4. Adversarial semantic review before revealing response data.
5. Cognitive interviews assessing the intended action's comprehension.
6. Randomized equivalence experiment across response groups and presentation modes.
7. Estimate total-variation framing effects with appropriate uncertainty intervals.
8. Separate subgroup invariance, translation and accessibility testing.
9. Independent certification, audit provenance and version locking.
10. Re-elicitation if law or policy meaning changes; withdraw certification after invalidation.

## Failure/hold states
UNVERIFIED_SOURCE, SEMANTIC_DISAGREEMENT, WORDING_EFFECT_UNRESOLVED, INADEQUATE_SAMPLE, LIMITED_JURISDICTION, DEPRECATED_VERSION. None of these authorizes a standing vote.

## Pilot instruments
The seed design has 24 fixed questions per class (8 shared oversight and transparency themes, 16 jurisdiction-specific), up to 12 source-linked adaptive follow-ups, and an optional priorities prompt. All questions are research drafts, not confirmed or neutral-certified live legislation.

Measure framing sensitivity, comprehension, test-retest reliability, calibration, completion, nonresponse, applicability, legal-mapping accuracy and aggregate representativeness. Record preregistration and pilot sampling limitations.
