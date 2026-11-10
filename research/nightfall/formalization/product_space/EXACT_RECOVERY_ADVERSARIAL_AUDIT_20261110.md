# Independent proof attack — arbitrary-product exact recovery v0.2
Date: 2026-11-10. Research owner: Devin J. Wright, NIGHTFALL.
Verdict: **FINITE SWITCHING CORE PASS (Lean); FULL INFINITE-PRODUCT THEOREM INCONCLUSIVE.** This is AI-assisted audit, not external human review.

## Frozen target
Finite-palette f with q distinct real values, Hoeffding degree at most d, range R and minimum palette gap Delta is claimed to admit almost-sure exact adaptive recovery in at most d^3 min{(q-1)^2,R/Delta} coordinate queries. For Boolean f this is d^3. This proof is independent of the influence certificate transfer in #298 and the open quartic Q(C) question. The v0.2 manuscript and reproducible exact checker are in the research handoff archive; this note establishes its narrower checked status.

## Attack A: null-set witness destroys hybrid degree
On [0,1]^2 with independent Lebesgue coordinates define f(x1,x2)=1{x1=x2}. It has Hoeffding degree zero because it equals zero almost everywhere. At almost any x=(a,b), a != b, choosing individual replacements y1=b and y2=a produces hybrid values (0,1,1,0) on masks (00,10,01,11), i.e. z1+z2-2z1*z2, degree two. Therefore arbitrary existential witnesses cannot be used in a hybrid-degree proof. The manuscript must prove **positive-measure** sensitivity and intersect its replacement sets with the almost-sure valid-hybrid set by Fubini.

## Attack B: overlap destroys degree
A one-bit degree-one f(x)=x can acquire switch degree two if switches z1,z2 both control the original bit via x=z1 XOR z2. Every original coordinate must belong to at most ONE query block. The formal map Coord -> Option Query enforces this.

## Remaining measure-theoretic gates
1. Countable reduction is plausible and correctly uses a measurable version of completed-product f followed by countable-coordinate support. Countability is over finite index sets, NOT uncountably many observed values.
2. For each fixed observed finite A, section low degree must follow from L2 approximation and conditional Fubini; squared Hoeffding projection energies must be measurable functions of observed values, making first-positive-energy choice measurable.
3. For each fixed finite disjoint tuple S1,...,Sm, high-order Boolean difference of the hybrid vanishes a.s.: every vertex has the original product law and finite-coordinate degree-d approximants pull back. Exchange finitely many vertices before L2 limiting. Fubini must give a conditional full-measure set of REPLACEMENT TUPLES for a.e. base input.
4. Since the effective coordinate set is countable, intersect null-set exclusions over all fixed finite A, S, and disjoint block tuples. Do not take an uncountable union over possible observed symbol values.
5. A maximal-size nonzero Hoeffding component g_S must establish nonconstant S-section for almost every complementary input, and hence positive-measure resampling sensitivity at the same original input.

No counterexample was found to the stated almost-sure hypotheses; that is not independent full-theorem proof certification.

## Finite switching core — actual kernel receipt
Exact source: https://github.com/d3lefts/d3lefts/blob/6c8da9d219e96628712bab9ded5b074cdc4bf5a5/research/nightfall/formalization/product_space/FiniteSwitchingCore.lean
Exact checked-source SHA-256: 5cd35e8c14078c993dd71dfb39d97a34fd4955b72b8c497495940a7df46b675c
Successful CI: https://github.com/d3lefts/d3lefts/actions/runs/42916562788
Seven named declarations compile under pinned Lean 4.35.0 and Mathlib v4.35.0 with only Classical.choice, Quot.sound, propext, no sorryAx/custom axioms. In particular, an explicit finite degree-d low-support representation stays degree <=d under disjoint-block Boolean switching; and a changing block becomes a sensitive singleton switch.
Failed initial CI, omitted DecidableEq Query (preserved as failed run): https://github.com/d3lefts/d3lefts/actions/runs/42916194182 ; repaired at 6c8da9d.

**Not formalized:** finite ANOVA decomposition from conditional expectations, infinite/completed measures, measurable selection, maximal-component sensitivity, palette reduction, Tal/FHKL estimates, the whole decision tree, or global novelty.

Separate exact-rational finite checker: 1600 randomized heterogeneous finite representations, plus both explicit negative controls; PASS within that finite scope only.

## Next decisive theorem
On a finite independent product with strictly positive masses, define weighted conditional expectations and centered Hoeffding components. Prove (i) degree <=d implies an explicit sum of terms supported on <=d coordinates; (ii) a nonzero component of maximal order yields a nonconstant block section for EVERY fixed complementary input and thus positive-measure resampling sensitivity. Then reconstruct the measurable countable-product lift. Keep each logical bridge separately scoped.

Status: audit record on draft PR #301; no merge, external publication, or site originality promotion.
