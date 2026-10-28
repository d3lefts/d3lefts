# What Survives the Cut — finite-group shadow codes

**Researcher:** Devin J. Wright. **Date:** October 13, 2026. **Status:** exact algebraic finite-group construction and testable theorem, with external priority review outstanding.

Let A be a finite abelian group with nonidentity involutive automorphism S, and let each observation return an orbit symbol [x+t] under S. Write q=|(S−I)A|>1. For translations t₁,…,tₘ set ℓⱼ=(S−I)tⱼ and n_c=number of labels ℓⱼ=c. The manuscripts prove:
```
d(C)=m−max_c n_c
max_{t₁,…,tₘ} d(C)=m−ceil(m/q).
```

These are sharp minimum-Hamming-distance and optimal label-allocation formulas. Part II derives a pairwise distance enumerator, erasure-pattern characterization, an O(m²)-candidate reconstruction scheme, balance results under independent faults, and a conditional cryptographic point-recovery example. It does **not** supply a general elliptic-curve discrete-logarithm attack.

The original Part II research archive reports 918 finite-group configurations, 474,794 erasure-pattern tests, 5,052 mixed-fault tests, 1,293 probabilistic-law checks and additional allocation checks. A **new independent direct-orbit test on October 28** exhaustively compared the formula across **3,325 separate small-group/translation instances** (2,925 sign involutions on Zₙ and 400 coordinate-swaps on Zₙ²); all passed. These finite checks reinforce, but cannot substitute for, proof of universal finite-group statements.

[Searchable text transcribed from Part II expanded manuscript](What_Survives_the_Cut_II_extracted.txt). Original PDF and full verifier remain in the research Library.
