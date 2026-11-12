# Proof Passport: NF-NESTED-ADDRESS-SEPARATION-20261111

**NIGHTFALL Constellation · Devin J. Wright · version 1.0 (2026-11-11).**
**Status:** EXACT CONSTRUCTION; finite checked; general upper theorem separate. This is a claim-specific proof-passport note, not an independently refereed theorem or novelty certificate.

## Exact claim and quantifiers

For one replica with s independent uniform m-ary addresses and K=m^s independent fair-sign leaves, the maximum explained variance from c fixed whole-coordinate queries is g(c)=0 at c=0; m^(c−1−2s) for 1≤c≤s+1; min{1,(c−s)/m^s} thereafter. For r outputs with k replicas each, L=s+m^s, Q'=min(Q,rkL), a=floor(Q'/L), b=Q' mod L, the exact optimal nonadaptive Bayes risk is 1/k−(a+g(b))/(rk²).

**Display shorthand:** `R*Q = 1/k − (a + g(b))/(r k²)`

## Premises

1. Inputs are s independent uniform m-ary address symbols plus K=m^s independent fair-sign leaf variables per replica.
2. Whole-coordinate queries are fixed in advance; squared-loss risk uses optimal conditional-mean prediction.
3. All r·k replicas are mutually independent and scaled by 1/(k√r).

## Mechanism (dependency graph)

1. With h observed addresses and q leaf bits, exact explained variance is q/m^(2s−h).
2. The optimum per-replica gain g(c) has nondecreasing discrete differences; exchanging budget between partially observed replicas cannot reduce total gain when it concentrates queries.
3. An optimal fixed set completes a=floor(Q'/L) replicas, then partially observes at most one more. Adaptive reading can follow each address to the selected leaf at cost s+1 per replica.

## Provenance and certification

1. Written conditional-expectation and discrete-convexity proofs are merged on main via PR #338.
2. Exact checker reports 1,945 global dynamic-program comparisons; 645 local budget optima and 88 independent conditional-table enumerations are recorded in the supporting audit.
3. The finite lower family establishes Ω(r m^(d−1)/η) fixed-observation requirements in the specified parameter regime, while a construction-specific adaptive procedure costs O(dr/η).

**Primary source:** `research/nightfall/2026-11-five-closures/EXACT_GLOBAL_QUERY_ALLOCATION.md`. The present page is a source-bound summary and does not supersede the primary original proof.

**Research source links:**
- [Global optimality proof](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-five-closures/EXACT_GLOBAL_QUERY_ALLOCATION.md)
- [Single-replica phase transition](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-five-closures/EXACT_BUDGET_AND_GENERAL_LP_20261111.md)
- [Exact finite verifier](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-five-closures/checks/check_global_fixed_allocation.py)
- [Merged audit PR](https://github.com/d3lefts/d3lefts/pull/338)

## Failure conditions, limits, and priority

1. The formula does not prove a general upper bound for all degree-d observables or universal minimax equality.
2. Different address laws, dependent replicas, partial-symbol queries or adaptive nonuniform observation costs are outside the exact calculation.
3. External publication priority and non-author mathematical review remain open.

**Upstream attribution and comparison:** Classical conditional variance and Bayes estimators; NIGHTFALL merged five-closure audit. Claims are limited to the explicit address family.

## Independent adversarial audit

Independently derive posterior conditional means for each address fiber, verify the convex increments including boundary s=0, m=2 and c=s+1, and compare the global closed form against a separately implemented exhaustive budget-allocation DP.

**Gate:** Preserve this certificate and every failed or superseded result, but do not promote to published novel theorem without independent proof review and dated prior-art comparison. No frozen historical Proof Passport or five approved Original Findings are being changed.


## Revision v2 — 12 November 2026, distinct signed-address family

The [dissertation signed-pointer proof passport](information-costs-identification.md) adds a separate n-address scalar family f_θ(K,Z)=θ_KZ_K, with unknown θ∈{±1}^n. **Different oracle tasks:** once θ is known, the fresh state is exactly observed by reading K and Z_K (two coordinate reads); model **identification** via arbitrary complete-input queries has exact minimax squared-L² risk 1−min(q,n)/n. A one-sided two-value tester rejects ε-far functions with probability ≥ε/4 per trial. Exponential constant-scale code packing preserves an Ω(n) model query requirement. These follow from an elementary addressed-family/coding argument and are **not** further evidence for the exact nested-address allocation formula above.

The n=2 trivalent tester has been independently enumerated in this session in direct integer arithmetic (6561 inputs, zero failures, 64 equality cases). CI in the v12 passport workflow must replay the committed [integer checker](check_addressed_family_independent.cjs) and the [original Python checker](../2026-11-information-cost-dissertation/check_addressed_family_exact.py). Do not promote finite tests to all-n Lean certification or claim a new broad information-cost classification.
