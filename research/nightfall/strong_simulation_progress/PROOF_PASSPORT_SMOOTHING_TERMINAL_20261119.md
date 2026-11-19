# NIGHTFALL Proof Passport — Uniform Strong-Event Smoother

**Date:** 2026-11-19  
**Certificate version:** 1.0  
**Status:** Certified analytic polynomial subtheorem (NOT full strong simulation)  
**PR:** https://github.com/d3lefts/d3lefts/pull/897, draft, stacked on #893  
**Exact source SHA:** `7e1239094f96960651e477e235839b96eed42fed`  
**Pinned source-exact CI:** https://github.com/d3lefts/d3lefts/actions/runs/44556804974  
**CI job:** `135674942224` — success  
**Lean:** v4.36.0-rc2, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`.

## Construction

For 0<ε≤1/2 set `k=floor(2/(5ε²))`. Define:

```
base(z) := 1 - (1-z²)^k
cubic(x) := x²(3-2x)
amp_0(x) := x
amp_(j+1)(x) := cubic(amp_j(x))
eventPoly(ε,n)(z) := amp_(n+3)(base(z)).
```

All functions are defined as genuine `Polynomial ℝ` where necessary,
not abstract claims of existence.

## Certified conclusions

For every n∈ℕ, |z|≤1, 0<ε≤1/2:

* `0 ≤ eventPoly(ε,n).eval z ≤ 1`.
* `(eventPoly ε n).natDegree ≤ 2*k*3^(n+3)`.
* If |z|≤ε, then `3*eventPoly(ε,n).eval z ≤ (3/4)^(2^n)`.
* If |z|≥2ε, then `3*(1-eventPoly(ε,n).eval z) ≤ (3/4)^(2^n)`.
* Consequently if `(3/4)^(2^n) ≤ 3η`, the inner
  and outer failure-event sandwich holds with error η.

These are Lean theorems with exact names:

* `Nightfall.StrongSimulation.SmoothingBase.base_separator`
* `Nightfall.StrongSimulation.SmoothingTerminal.eventPoly_degree`
* `Nightfall.StrongSimulation.SmoothingTerminal.eventPoly_tails`
* `Nightfall.StrongSimulation.SmoothingTerminal.eventPoly_failure_bounds`

The build and `#print axioms` report only `propext`,
`Classical.choice`, `Quot.sound`; no `sorryAx` or
custom extra axiom. The file imports the parallel upstream
`StrongSmoothingAmplifier`, `StrongSmoothingPolynomial` and
`StrongSmoothingUniform` source and the independently
constructed `StrongSmoothingBase`.

## Mechanism

The initial separator uses only Bernoulli's elementary polynomial
inequality and a finite induction. In particular:
`1-(1-p)^k ≤ kp ≤ 2/5`;
and the product-form inequality
`(1-x)^n(1+nx)≤1` yields
`(1-4p)^k≤2/5` with `p=ε²` and
`(k+1)p≥2/5`. The cubic map preserves [0,1],
has complementary symmetry, and drives the low/high tails down
at a doubly-exponential rate. This supplies a self-contained
replacement for the proposed Hoeffding/binomial smoother.

## Remaining obligations and limits

1. The theorem takes `n` and the numeric `(3/4)^(2^n)≤3η`
   budget as inputs. A source-exact Lean parameter selector that
   bounds n by O(log log(1/η)) is not yet part of the certificate.
2. Bound the coordinate-degree of `eventPoly(f-T)` using genuine
   quantum acceptance and decision-tree degree interfaces, not just
   the one-variable polynomial degree.
3. Prove product expectation stability from the interpolating law,
   or use the existing, already kernel-checked `MixtureSimulation.fooling_tv`
   and pinned conditional version from PR #898.
4. Connect to exact dyadic input law encoding and strong uniform
   BDST semantics. BDST is an external published theorem and is not
   formalized as a Lean result in this project.
5. End-to-end quantum coherence, conditional seed fixing,
   frozen mixture-duel integration, human review and dated
   novelty/prior-art clearance are still open.

**Promotion:** Analytical smoothing lemma certified. Strong mixture
simulation remains provisional. Existing Lean-certified poly(1/δ)
simulation remains the preprint headline.

## Independent reviewer checklist

Verify positivity at zero/one endpoints, integer floor and
k=1 regimes at ε=1/2, q=2ε=1 outer endpoint, the exact
iterate/degree bounds, and the orientation of both tail inequalities.
Test all dependencies in the exact-source CI log and rerun on the
pinned Mathlib commit. Do not infer the strong theorem merely from
this passport.
