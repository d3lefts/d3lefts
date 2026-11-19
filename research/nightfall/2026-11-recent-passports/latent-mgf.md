# Proof Passport — Latent-mixture exponential moment lower bound

**Claim ID:** `latent-mgf`  
**Snapshot:** 2026-11-19  
**Evidence tier:** PR-head / named Lean  
**PR:** https://github.com/d3lefts/d3lefts/pull/869  
**Exact PR source head:** `0cbdab0611fc2edc2d73fd4b904e9a5539478269`  
**Named theorem:** `Nightfall.Forrelation.Information.latent_exp_component_lower_bound`  
**Pinned CI run:** https://github.com/d3lefts/d3lefts/actions/runs/44459219905

## Formal claim and domain

Under a normalized finite block-product latent mixture, specified uniform first-block marginal and MGF bound, exp(N c²/2) ≤ M, where c is the statistic's latent-joint expectation.

**Feasible set / hypotheses.** Finite F,G,Θ, normalized weights, component laws, exact marginal and an explicit MGF hypothesis; no independence within the two blocks required.

## Representation and mechanism

Exponential moment domination plus finite Jensen eliminates entropy/KL and posterior division.

## Certificate and current validation

PR #869 exact-head source SHA-256 99a2f6e32ac8be925ae3af1c7f193e765b562cac716cad7e2aba18c6b9edd540, pinned Lean run 44459219905 PASS; unmerged stacked branch.

**Checker/replay.** Inspect pinned named-declaration workflow https://github.com/d3lefts/d3lefts/actions/runs/44459219905, exact theorem type, imported axioms and source hash; this passport is an evidence index, not an independent rerun.

## Boundary, novelty and review

Does not prove Gaussian-sign Forrelation source identities, Hadamard MGF or TV-robust Forrelation lower bound.

**Attribution / prior art.** NIGHTFALL abstract formal operator; Gaussian Forrelation originates with Aaronson–Ambainis and information lower-bound ideas are known prior art.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Prove concrete MGF and Gaussian-sign hypotheses separately; seek independent review.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/869
- Source-head custody: `0cbdab0611fc2edc2d73fd4b904e9a5539478269`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
