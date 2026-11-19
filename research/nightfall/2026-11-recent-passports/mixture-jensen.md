# Proof Passport — Jensen simulation over finite mixtures of product laws

**Claim ID:** `mixture-jensen`  
**Snapshot:** 2026-11-19  
**Evidence tier:** Merged / named Lean  
**PR:** https://github.com/d3lefts/d3lefts/pull/867  
**Exact PR source head:** `b5e81949dfeb8107de24ad8c9e9baafe8adad9b5`  
**Named theorem:** `Nightfall.ProductSpace.Mixture.mixture_simulation_jensen`  
**Pinned CI run:** https://github.com/d3lefts/d3lefts/actions/runs/44456342019

## Formal claim and domain

For an M-component mixture of finite independent product sources, Pr(|f−tree|>ε) ≤ [3√2π⁶d⁶M/(τ√τ)+512d⁴M⁴/τ³]/n +τ/ε².

**Feasible set / hypotheses.** Finite common-alphabet input products with nonnegative component weights; positive τ, n, ε and bounded degree-d f. Source law may be a correlated mixture.

## Representation and mechanism

Jensen/power-mean inequality improves the within-component variance-potential decrement without selecting a heavy single component.

## Certificate and current validation

PR #867 merged to main as 9b64f8a7fcabfbcba056f171644c3a3a8795d6e6; source-exact pinned Lean run 44456342019; archive PR #872 separately preserves byte-exact receipts.

**Checker/replay.** Inspect pinned named-declaration workflow https://github.com/d3lefts/d3lefts/actions/runs/44456342019, exact theorem type, imported axioms and source hash; this passport is an evidence index, not an independent rerun.

## Boundary, novelty and review

The M⁴ separator term persists; entropy reduction and polynomial-time classical implementation are not proved.

**Attribution / prior art.** NIGHTFALL/Claude-assisted formalization; previous finite product AA mechanism acknowledged.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Challenge tightness of M dependence and integrate mixed circuit semantics without copying proofs as new claims.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/867
- Source-head custody: `b5e81949dfeb8107de24ad8c9e9baafe8adad9b5`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
