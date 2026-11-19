# Proof Passport — Strong simulation: candidate tail improvement and falsified shortcut

**Claim ID:** `strong-simulation-frontier`  
**Snapshot:** 2026-11-19  
**Evidence tier:** Paper or exact-test candidate  
**PR:** https://github.com/d3lefts/d3lefts/pull/881  
**Exact PR source head:** `bd59b237d592663c826adf2160019f56799349e8`  
**Named theorem:** None claimed  
**Pinned CI run:** Not confirmed for this composite claim

## Formal claim and domain

A conditional-state block-Markov argument proposes a δ-exponent reduction in Jensen mixture depth; rare Bernoulli tails and ANDₖ expose inadequacy of the naïve variance/influence stopping rule for log(1/δ).

**Feasible set / hypotheses.** Paper-level argument, bounded degree-d finite product mixtures, additional uniform conditional-state proof obligation; does not establish BDST Conjecture 2.

## Representation and mechanism

Geometric tail from conditional remaining-query potential, plus exact rare-event counterexamples.

## Certificate and current validation

PR #881 paper and finite checker, no Lean certificate; related PR #879 independent formula/ANDₖ barrier is also unreviewed.

**Checker/replay.** No independent exact-head Lean verification supplied for this full claim. Inspect PR source, checker(s) and unresolved proof obligations.

## Boundary, novelty and review

Cannot claim strong/polylog(1/δ) simulation; multiplicative δ terms persist and the proposed bound needs proof attack.

**Attribution / prior art.** Blanc–Docter–Strassle–Tan strong simulation conjecture; NIGHTFALL proposed tail operator and falsifiers.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Verify conditional-state potential and off-by-one bounds independently; switch to query-weight lemma if this gate fails.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/881
- Source-head custody: `bd59b237d592663c826adf2160019f56799349e8`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
