# Proof Passport — Exponential mixture rank can coexist with easy queries

**Claim ID:** `diagonal-mixture-rank`  
**Snapshot:** 2026-11-19  
**Evidence tier:** PR-head / named Lean  
**PR:** https://github.com/d3lefts/d3lefts/pull/883  
**Exact PR source head:** `41126153f47a4609f9a4635dc7bef72caff0e43a`  
**Named theorem:** `Nightfall.Structure.DiagonalMixtureRank.boolean_diagonal_exponential`  
**Pinned CI run:** https://github.com/d3lefts/d3lefts/actions/runs/44464612579

## Formal claim and domain

Any exact nonnegative mixture of block-product tables with positive diagonal and zero off diagonal needs at least |F| components; on Boolean N-vectors, M≥2^N.

**Feasible set / hypotheses.** Finite nonnegative block-product decompositions, exact diagonal support and normalized component constraints; this rank theorem is not about quantum advantage.

## Representation and mechanism

Rectangle-support / nonnegative-rank diagonal obstruction; explicit diagonal point masses attain equality.

## Certificate and current validation

PR #883 source-exact Lean 4.36.0-rc2 pinned run 44464612579 PASS on 41126153; exact source SHA-256 9f90e6188e8797d90a0a8b29a92f4f02844e7d08e1994ab0e3b6dd39eb47d4d2; unmerged draft.

**Checker/replay.** Inspect pinned named-declaration workflow https://github.com/d3lefts/d3lefts/actions/runs/44464612579, exact theorem type, imported axioms and source hash; this passport is an evidence index, not an independent rerun.

## Boundary, novelty and review

The query-local pullback theorem and robust TV/Fano lower bound in the accompanying note are paper-only; exponential mixture rank alone does not imply query hardness.

**Attribution / prior art.** Elementary nonnegative-rank rectangle-cover mechanism (prior art); NIGHTFALL exact finite formalization.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Independently audit pullback query simulation and approximate-rank bound before generalizing.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/883
- Source-head custody: `41126153f47a4609f9a4635dc7bef72caff0e43a`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
