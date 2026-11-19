# Proof Passport — Distribution-uniform low-degree decision-tree simulation

**Claim ID:** `product-simulation`  
**Snapshot:** 2026-11-19  
**Evidence tier:** Merged / named Lean  
**PR:** https://github.com/d3lefts/d3lefts/pull/858  
**Exact PR source head:** `ef6a29bf7693ea4069bcd0c49689d52a6853e5c3`  
**Named theorem:** `Nightfall.ProductSpace.Simulation.simulation_degree`  
**Pinned CI run:** https://github.com/d3lefts/d3lefts/actions/runs/44433153026

## Formal claim and domain

A bounded degree-d function on finite arbitrary independent products admits an adaptive whole-symbol decision tree with error at most δ under the stated ε and n budget n ε³δ²√δ ≥ 6√2π⁶d⁶.

**Feasible set / hypotheses.** Finite independent sources, bounded function, Efron–Stein degree, ε>0 and δ>0; depth means worst-case whole-coordinate queries, not construction time.

## Representation and mechanism

Source-influence total potential, pinning decrement, leaf truncation and variance stopping.

## Certificate and current validation

PR #858 merged; exact named original-source pinned Lean run 44433153026. Quantum consequences require the separate quantum-degree/normalization bridge.

**Checker/replay.** Inspect pinned named-declaration workflow https://github.com/d3lefts/d3lefts/actions/runs/44433153026, exact theorem type, imported axioms and source hash; this passport is an evidence index, not an independent rerun.

## Boundary, novelty and review

No polytime simulator, no arbitrary correlated law, and no log(1/δ) strong simulation conclusion.

**Attribution / prior art.** NIGHTFALL source-level construction using the Aaronson–Ambainis/Turturean framework.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Integrate receipt and module into the full Lake graph; separately audit the quantum query-model bridge.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/858
- Source-head custody: `ef6a29bf7693ea4069bcd0c49689d52a6853e5c3`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
