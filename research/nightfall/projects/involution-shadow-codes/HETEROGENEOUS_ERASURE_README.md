# NIGHTFALL — Heterogeneous Erasure Complexity and Exchangeable Faults

Agent verification checkpoint · October 28, 2026 · Research lead: Devin J. Wright.

## Results

1. **Distribution-free:** Exact probability of ambiguous group-shadow recovery under *arbitrary correlated* coordinate erasures.
2. **Exchangeable faults:** Balanced label counts maximize minimum Hamming distance and minimize ambiguous reconstruction probability for *all exchangeable erasure laws*, even when erasures are correlated.
3. **Unequal independent failure rates:** Exact convex exponential-load objective. Balance by reliability workload, as distinct from balance by the number of observations.
4. **Complexity boundary:** Variable-class heterogeneous allocation is NP-complete even for cyclic inversion-orbit codes and dyadic rational failure probabilities, by a reduction from strongly NP-complete 3-PARTITION.
5. **Exact algorithmic result:** For two label classes, dynamic programming computes the entire attainable distance–reliability Pareto frontier using O(m^2 W) time and O(mW) states for dyadic log-failure weights summing to W.

## Reproduce

Run the standalone script in this directory using standard Python 3:

```sh
python3 verify_heterogeneous.py > replay.json
```

This verifies 252 independent direct group-orbit reliability cases, 90 subset-sum optimum comparisons, 120 complete Pareto-front comparisons, all 729 allocations under an exchangeable correlated-erasure example, two 3-PARTITION decision fixtures, and the four-measurement disagreement between error tolerance and random-erasure recovery. All computations use exact integers / fractions.

Inspect `THEOREM.md` for the complete universal mathematical arguments and their provenance. `AUDIT_RESULT.json` records the frozen deterministic run. Verify every SHA-256 digest against `MANIFEST.json`.

## Scope and attribution

The mathematical results apply to the NIGHTFALL translated involution-orbit finite-group code. Convex load balancing and hard reliability allocation have prior literature; the result here is a precise boundary within our particular coding construction. The universal proof remains a written mathematical proof pending proof-assistant kernel verification. Machine tests check finite instances, without asserting that tests establish universal quantifiers.

Source theory: [nonabelian involution-shadow theorem](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/NONABELIAN_SHADOW_THEOREM.md). Published formal foundations: 3-PARTITION strong NP-completeness, MIT *Computational Complexity and Intractability* lecture chapters and Garey–Johnson.