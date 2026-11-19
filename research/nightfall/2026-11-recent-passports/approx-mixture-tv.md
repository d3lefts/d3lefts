# Proof Passport — TV-stable mixture simulation change-of-law interface

**Claim ID:** `approx-mixture-tv`  
**Snapshot:** 2026-11-19  
**Evidence tier:** Integration or compiler gate open  
**PR:** https://github.com/d3lefts/d3lefts/pull/880  
**Exact PR source head:** `8e3e5d35403f2bda87947b7b0f41f228c38f0c7a`  
**Named theorem:** `Nightfall.ProductSpace.ApproximateMixture.approximate_mixture_simulation_jensen`  
**Pinned CI run:** Not confirmed for this composite claim

## Formal claim and domain

For target q within TV η of an M-product mixture r, the same source-trained whole-symbol tree has target error at most the Jensen mixture bound plus η.

**Feasible set / hypotheses.** Finite normalized mass tables and bounded degree-d f; no atom floor; finite mixture geometry.

## Representation and mechanism

Exact TV positive-variation identity and event transfer, composed with #867.

## Certificate and current validation

Proposed named Lean source in PR #880; PR description marks exact-head compilation pending.

**Checker/replay.** No independent exact-head Lean verification supplied for this full claim. Inspect PR source, checker(s) and unresolved proof obligations.

## Boundary, novelty and review

A standard change-of-measure argument, not independently novel; do not list as Lean certified until its own receipt passes.

**Attribution / prior art.** Classical total-variation event inequality, merged Jensen source; NIGHTFALL composition.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Run exact-head pinned workflow and inspect all premise preservation.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/880
- Source-head custody: `8e3e5d35403f2bda87947b7b0f41f228c38f0c7a`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
