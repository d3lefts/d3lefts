# Proof Passport — Normalized quantum circuits over product mixtures and TV neighborhoods

**Claim ID:** `quantum-mixture-tv`  
**Snapshot:** 2026-11-19  
**Evidence tier:** Integration or compiler gate open  
**PR:** https://github.com/d3lefts/d3lefts/pull/878  
**Exact PR source head:** `ce2428e3ea154dd8003573a1fa7d434bf7c1f2e8`  
**Named theorem:** `Nightfall.ProductSpace.QuantumCircuitMixtureSimulation.circuit_tv_approx_mixture_jensen`  
**Pinned CI run:** Not confirmed for this composite claim

## Formal claim and domain

Proposed composition: one normalized finite matrix-oracle T-query circuit has a Jensen-bound classical simulator under M-product mixtures; if TV(target, mixture)≤η, error adds at most η with unchanged query depth.

**Feasible set / hypotheses.** Finite circuit and alphabet model, valid normalized gates/oracles, exact mixture weights, finite TV and positivity hypotheses; result located in unmerged stacked PR.

## Representation and mechanism

Proved degree≤2T and Born normalization for the constituent formalization, Jensen mixture simulator and elementary TV event transfer.

## Certificate and current validation

PR #878 declares exact-head CI still unverified; underlying #866 and #867 have distinct green receipts, not an automatic combined certificate.

**Checker/replay.** No independent exact-head Lean verification supplied for this full claim. Inspect PR source, checker(s) and unresolved proof obligations.

## Boundary, novelty and review

Not merged or independently compiled as a named combined theorem at this checkpoint; not a polytime simulator.

**Attribution / prior art.** NIGHTFALL and prior quantum polynomial method; Jensen theorem reused, not rediscovered.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Pass exact-head combined Lean CI and de-duplicate sources against parents #866/#867.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/878
- Source-head custody: `ce2428e3ea154dd8003573a1fa7d434bf7c1f2e8`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
