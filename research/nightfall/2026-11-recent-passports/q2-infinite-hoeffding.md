# Arbitrary-index product quadratic influence

**Editorial checkpoint:** 2026-11-24
**Claim ID:** `q2-infinite-hoeffding`
**Evidence tier:** merged-lean
**Public status:** Merged / named Lean

## Exact claim

For an L² Hoeffding-degree-two observable bounded almost everywhere by B, variance squared is at most C₂ B² M whenever every source-coordinate influence is at most M.

## Scope and assumptions

Independent product probability law over arbitrary index type in the formal source; L² and almost-everywhere bound.

## Mechanism

Finite-cell approximation, exact source influence contraction and Hoeffding-to-triple-residual bridge.

## Certificate and provenance

Merged #888 integrated build and kernel replay run 44470008420; #776 is the earlier a.e. terminal.

- Named terminal: Nightfall.InfinitePiQ2HoeffdingDegree.infinitePi_q2_105416_hoeffding
- Exact head: d84d6f0bddb0f7e6f1e0ca17a10165afefe73b6e
- Receipt: https://github.com/d3lefts/d3lefts/actions/runs/44470008420

## Limitation

No dependent-law, unrestricted cubic or rank-sensitive adaptive terminal follows.

## Credit

NIGHTFALL finite-to-infinite product program.

## Next independent check

External review of the measurable-product extension and scope.

## Primary source

https://github.com/d3lefts/d3lefts/pull/888

Earlier versions remain in Git history. This editorial index is not external peer review.
