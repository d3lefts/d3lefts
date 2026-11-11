# Research frontier — Higher-Order Interaction Matching

**Status: open problem, not a solved cubic theorem.**

## Target

Prove a distribution-independent variance-squared coordinate-influence guarantee for bounded degree-three observables on arbitrary independent product alphabets, ideally

    max_i I_i(f) ≥ c_3 · Var(f)^2 / ||f||∞²

with c_3>0 independent of dimension, coordinate biases, and alphabet sizes. Then seek c_d for all fixed d and a hypergraph certificate/operator interpretation.

## Verified structural reduction reported in supplied package

For a degree-d Hoeffding decomposition and a matching M of pairwise disjoint d-element supports, the source derives a matching-amplitude inequality

    Σ_{S∈M} ||h_S||∞ ≤ 2^d B/a_r,

where B bounds the output norm and a_r is the spherical projection factor (under the rank-r Hilbert setup). The argument uses mixed differences and parity distributions with identical proper marginals. This is a **paper proof in the source**, not an independently certified theorem in this PR.

## Exact obstruction at d=3

After assigning triples to an endpoint, two remaining indices may recur across multiple triples. The resulting increments are not independent, so the degree-two fourth-moment estimate cannot simply be reused. An arbitrary hypergraph matching bound alone does not control those shared pair codegrees.

## Cheapest decisive experiments

1. Formalize a bounded three-uniform hypergraph toy model with explicit codegrees; enumerate small exact rational examples of overlapping triples and test candidate fourth-moment/codegree inequalities.
2. Prove a decomposition into low-codegree pieces plus a structured high-codegree remainder; quantify whether the decomposition preserves a dimension-free influence floor.
3. Attack the most promising inequality with stars, sunflowers, complete tripartite supports, and biased rare-symbol distributions.
4. If successful, lift from scalar to Hilbert outputs and test posterior variance descent. Keep all-degree nonadaptive categorical results separate from the conjectured adaptive rate.

## Certification gates

A finite exact counterexample invalidates a candidate universal constant. A finite search without counterexamples does not prove the inequality. Advance to theorem status only after a complete proof, an independent proof attack, and a reproducible checker/formalization. Compare prior art in hypergraph matching, decoupling/U-statistics, low-degree influences, and juntas before claiming novelty.

## Source

Section 5 of `NIGHTFALL_Quadratic_Product_Observability_Proofs(1).zip` and its `nightfall-rank-appendix.md`. The companion route through random sign projections yields a conditional general-degree adaptive bound but does not solve this cubic bottleneck.
