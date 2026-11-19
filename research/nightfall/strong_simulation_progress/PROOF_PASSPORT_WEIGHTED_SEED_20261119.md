# Proof Passport — Exact finite weighted random-tape fixing

**Date:** 2026-11-19  
**Status:** Lean kernel-certified **finite probability subtheorem** (NOT a quantum-oracle transfer or strong-mixture theorem)  
**PR:** https://github.com/d3lefts/d3lefts/pull/893  
**Exact source commit:** `71b7797a15afe74b025bc934174830aded48d54a`  
**Pinned CI:** https://github.com/d3lefts/d3lefts/actions/runs/44568890845 (success)  
**Job:** `135718175654`  
**Source:** `research/nightfall/formalization/product_space/StrongSeedFixing.lean`  
**Source SHA-256:** `8a96914b20147b0143c7545fd70048887764cbdbe1f4d88b43f2a90138634e7e`  
**Lean:** 4.36.0-rc2, compiler `b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a`  
**Mathlib:** `9d581dfff2e41de989072ea63abf3daf69311520`

## Certified statements

1. `exists_seed_le_average`: a uniform finite random seed whose averaged real error is at most δ admits a deterministic seed with error ≤δ, for nonempty seed space.
2. `exists_deterministic_seed`: the same statement for finite source-weighted failure-event masses, without assuming the final deterministic simulator succeeds.
3. `exists_weighted_seed`: for finite nonnegative weights w summing to one and any real-valued error function e, if Σₛ wₛ eₛ ≤ δ, then some seed has wₛ>0 and eₛ≤δ. **No rationality or equal-weight condition.**
4. `deterministicMapWeights_nonneg`: for a finite stochastic kernel K:A→U→ℝ, the deterministic-map weights w(s)=∏ₐ K(a,s(a)) are nonnegative.
5. `deterministicMapWeights_sum_one`: if every row of K sums to one, the finite weights over all deterministic maps s:A→U sum to one.
6. `deterministicMapWeights_marginal`: for each a,u, the sum of w(s) over maps satisfying s(a)=u equals K(a,u).

Exact-source `#print axioms`: each declaration depends only on `propext`, `Classical.choice`, `Quot.sound`. No `sorryAx`, extra axiom or admitted theorem. The kernel build, source SHA-256 and axiom printouts are preserved in the CI artifacts.

## Mechanism and scope

The randomized conditional block decoder `K(u|a)` can have irrational probabilities even if the target *unconditional* bits are dyadic. A finite **uniform** random tape is generally not exact. Instead sample a deterministic map `s:A→U` before observing input, with real weight

```
w(s) = ∏_{a∈A} K(s(a) | a).
```

Then drawing `s` and returning `s(a)` at an observed symbol gives exactly the row `K(·|a)`, including zero atoms and irrational probabilities. Reuse the same map for repeated queries of the same coordinate; combine independent coordinate kernel seeds by a product distribution. Weighted averaging fixes the entire finite global seed without changing worst-case input query depth. **Seed support cardinality can be exponential; this is an existence/query-depth result, not an efficient implementation.**

## Still unproved in this module

- Kernel `K=U_i|X_i=a` must be constructed from the one-sided dyadic coupling, including support conditions.
- Prove product factorization of the global seed and implement persistent per-coordinate cache for adaptive input queries.
- Formalize the coherent, finite-alphabet reversible value-oracle pullback and quantum hybrid telescoping inequality.
- Connect the actual BDST strong uniform-Boolean theorem with explicit query/round/ε/δ parameters, then the source-level tournament and final depth.
- Independent adversarial review and dated novelty search remain separate gates.

**Promotion:** Certified finite kernel and weighted seed-fixing mechanism only. The strong mixture theorem remains provisional; the established poly(1/δ) theorem remains the manuscript headline.
