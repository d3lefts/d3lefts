# What Survives the Cut — finite-group shadow codes

## Nonabelian breakthrough — 28 October 2026

A new **unconditional algebraic extension** now covers every finite group, including noncommutative groups, with a nonidentity order-two automorphism. Translated orbit measurements obey the exact distance rule, and their twisted-coboundary label classes are right cosets of the automorphism's fixed subgroup.

The [complete universal theorem and proof](NONABELIAN_SHADOW_THEOREM.md) establishes all of the following:

- **Sharp distance:** `d=m-max_c(n_c)`, with maximum `m-ceil(m/q)`, where `q=|G|/|Fix(S)|`.
- **Exact full ordered-pair Hamming spectrum**, depending solely on the label occupancies and the fixed-subgroup size.
- **Exact counts of erasure-ambiguous surviving subsets at every size**, plus explicit independent-erasure failure probabilities.
- **Simultaneous sharp optimality:** balancing label counts maximizes guaranteed error correction and minimizes *every* fixed-cardinality erasure failure probability.

This extends the earlier finite abelian construction. In `S4`, the six label values are **not a subgroup**; the coset-set result genuinely extends beyond abelian homomorphism methods.

**Machine evidence:** 14 group/automorphism actions including simple A5, 20,736 translation lists, 1,417,256 directly checked ordered message pairs; an independent [Cayley-table verifier](certify_nonabelian_instance.py) of the [24-element S4 witness](S4_nonabelian_certificate.json); an [independent error–erasure optimality audit](verify_nonabelian_erasure_optimum.py) over 8,192 erasure patterns and 8,568 allocations. Seven deliberately corrupted certificates were rejected in the full separate package. [Machine verdict](NONABELIAN_AGENT_VERDICT.json).

**Scope:** Written universal group-theoretic proof and reproducible exact finite checks; no proof-assistant kernel formalization yet. The initial prior-art survey confirms twisted group actions and orbit coding are established fields; worldwide novelty of these exact formulas remains under investigation. The full original source and adversarial suite are preserved in the 14.7 KB archived package `NIGHTFALL_NONABELIAN_SHADOW_BREAKTHROUGH_20261028.zip` (SHA-256 `679fdd82413e41148a54b3c69fd8659d7160313bef19cc96036ae83fe65dda09`), awaiting binary release.


**Researcher:** Devin J. Wright. **Date:** October 13, 2026. **Status:** exact algebraic finite-group construction and testable theorem, with external priority review outstanding.

Let A be a finite abelian group with nonidentity involutive automorphism S, and let each observation return an orbit symbol [x+t] under S. Write q=|(S−I)A|>1. For translations t₁,…,tₘ set ℓⱼ=(S−I)tⱼ and n_c=number of labels ℓⱼ=c. The manuscripts prove:
```
d(C)=m−max_c n_c
max_{t₁,…,tₘ} d(C)=m−ceil(m/q).
```

These are sharp minimum-Hamming-distance and optimal label-allocation formulas. Part II derives a pairwise distance enumerator, erasure-pattern characterization, an O(m²)-candidate reconstruction scheme, balance results under independent faults, and a conditional cryptographic point-recovery example. It does **not** supply a general elliptic-curve discrete-logarithm attack.

The original Part II research archive reports 918 finite-group configurations, 474,794 erasure-pattern tests, 5,052 mixed-fault tests, 1,293 probabilistic-law checks and additional allocation checks. A **new independent direct-orbit test on October 28** exhaustively compared the formula across **3,325 separate small-group/translation instances** (2,925 sign involutions on Zₙ and 400 coordinate-swaps on Zₙ²); all passed. These finite checks reinforce, but cannot substitute for, proof of universal finite-group statements.

[Searchable text transcribed from Part II expanded manuscript](What_Survives_the_Cut_II_extracted.txt). Original PDF and full verifier remain in the research Library.
