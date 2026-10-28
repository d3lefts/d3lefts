# What Survives the Cut — finite-group shadow codes

## Heterogeneous reliability extension — October 28, 2026

Unequal coordinate survival rates change the optimal allocation. The [exact reliability and complexity theorem](HETEROGENEOUS_ERASURE_COMPLEXITY.md) derives a convex workload identity, proves NP-completeness of variable-class reliability allocation even on cyclic groups, and establishes a pseudo-polynomial dynamic program computing the **entire** error–erasure Pareto frontier for two labels. A [standalone exact verifier](verify_heterogeneous_erasure.py) checks the formula against direct orbit observations, the cyclic four-measurement separation example, both 3-PARTITION fixtures, and random optimal-frontier comparisons.

The earlier simultaneous cardinality-balancing theorem assumes identical survival probabilities. This newer result specifies the boundary and produces optimal designs under heterogeneous rates. Global publication priority and proof-assistant formalization remain open.

## Nonabelian breakthrough — 28 October 2026

A new **unconditional algebraic extension** now covers every finite group, including noncommutative groups, with a nonidentity order-two automorphism. Translated orbit measurements obey the exact distance rule, and their twisted-coboundary label classes are left cosets \(tH\) of the automorphism's fixed subgroup.

The [complete universal theorem and proof](NONABELIAN_SHADOW_THEOREM.md) establishes all of the following:

- **Sharp distance:** `d=m-max_c(n_c)`, with maximum `m-ceil(m/q)`, where `q=|G|/|Fix(S)|`.
- **Exact full ordered-pair Hamming spectrum**, depending solely on the label occupancies and the fixed-subgroup size.
- **Exact counts of erasure-ambiguous surviving subsets at every size**, plus explicit independent-erasure failure probabilities.
- **Simultaneous sharp optimality:** balancing label counts maximizes guaranteed error correction and minimizes *every* fixed-cardinality erasure failure probability.

This extends the earlier finite abelian construction. In `S4`, the six label values are **not a subgroup**; the coset-set result genuinely extends beyond abelian homomorphism methods.

**Machine evidence:** 14 group/automorphism actions including simple A5, 20,736 translation lists, 1,417,256 directly checked ordered message pairs; an independent [Cayley-table verifier](certify_nonabelian_instance.py) of the [24-element S4 witness](S4_nonabelian_certificate.json); an [independent error–erasure optimality audit](verify_nonabelian_erasure_optimum.py) over 8,192 erasure patterns and 8,568 allocations. Seven deliberately corrupted certificates were rejected in the full separate package. [Machine verdict](NONABELIAN_AGENT_VERDICT.json).

**Scope:** Written universal group-theoretic proof and reproducible exact finite checks; no proof-assistant kernel formalization yet. The initial prior-art survey confirms twisted group actions and orbit coding are established fields; worldwide novelty of these exact formulas remains under investigation. The full original source and adversarial suite are preserved in the 14.7 KB archived package `NIGHTFALL_NONABELIAN_SHADOW_BREAKTHROUGH_20261028.zip` (SHA-256 `a974448b10bb987f4b84b5801bf08a0ecffb0d13d3069579bc8d3b0e567af21b`), awaiting binary release.


**Researcher:** Devin J. Wright. **Date:** October 13, 2026. **Status:** exact algebraic finite-group construction and testable theorem, with external priority review outstanding.

Let A be a finite abelian group with nonidentity involutive automorphism S, and let each observation return an orbit symbol [x+t] under S. Write q=|(S−I)A|>1. For translations t₁,…,tₘ set ℓⱼ=(S−I)tⱼ and n_c=number of labels ℓⱼ=c. The manuscripts prove:
```
d(C)=m−max_c n_c
max_{t₁,…,tₘ} d(C)=m−ceil(m/q).
```

These are sharp minimum-Hamming-distance and optimal label-allocation formulas. Part II derives a pairwise distance enumerator, erasure-pattern characterization, an O(m²)-candidate reconstruction scheme, balance results under independent faults, and a conditional cryptographic point-recovery example. It does **not** supply a general elliptic-curve discrete-logarithm attack.

The original Part II research archive reports 918 finite-group configurations, 474,794 erasure-pattern tests, 5,052 mixed-fault tests, 1,293 probabilistic-law checks and additional allocation checks. A **new independent direct-orbit test on October 28** exhaustively compared the formula across **3,325 separate small-group/translation instances** (2,925 sign involutions on Zₙ and 400 coordinate-swaps on Zₙ²); all passed. These finite checks reinforce, but cannot substitute for, proof of universal finite-group statements.

[Searchable text transcribed from Part II expanded manuscript](What_Survives_the_Cut_II_extracted.txt). Original PDF and full verifier remain in the research Library.

**Prior-art and terminology update (28 October):** The coset-label mechanism is a finite-group version of a standard Cartan-embedding identity, and balancing occupancies applies classical majorization. Related group-automorphism code families and distance spectra predate this work. The present precise theorem package is a new extension of our earlier abelian result, with global novelty unresolved. The label fibers are **left cosets** \(tH\), correcting an earlier right-coset mislabel. See [detailed source audit](NONABELIAN_SHADOW_THEOREM.md#priority-assessment-and-terminology-correction--28-october-2026).
