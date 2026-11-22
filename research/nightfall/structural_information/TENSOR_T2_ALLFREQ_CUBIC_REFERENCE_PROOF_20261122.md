# Independent all-frequency cubic primitive-lift theorem by forced-reference sites
Version 1.0 — November 22, 2026

**Status:** Complete *paper-level* proof conditional only on a precisely cited published tensor-circuit lemma (Lovitz 2018 / Lovitz–Petrov 2023); source-faithful exact finite adversarial tests and scoped Lean bridge are separate gates. This is NOT a Lean-certified arbitrary-Hilbert quantum simulator, a new published Kruskal theorem, or a globally cleared priority claim.

## Objective and statement

For L≥1, let R_L be the 3^L nonzero pure tensors in (F₂²)^(tensor L), and D_L=R_L∪{0}. For nonzero XOR frequency z let K4^A(L,z) count ordered four-slot tuples of pairwise **distinct** labels in D_L, with total XOR z, whose nonzero labels form a primitive set (no nonempty subset XOR zero). This is **exactly Group A** in the disjoint quantum Fourier partition of #1059/#1068; do NOT substitute this number into an older definition counting repeated zero labels.

Let M2(L)=max_{u≠0} #{(a,b)∈D_L²:a XOR b=u}; its source-exact all-L paper classification from #1029 gives M2(L)=2L+2.

**Theorem CUBIC-A (paper level, published LP circuit support imported).** For all L≥1 and all nonzero z,

    K4^A(L,z) ≤ 52 · (1+4·3^6)^2 ·
                min(1+4·3^6, M2(L)) ·
                Σ_{j=0}^{min(L,3)} binom(L,j).          (C1)

The constant 52 is Bell(5), not a fitted or asymptotic value. If desired, replace it by 625=5^4 for an entirely elementary finite overcount using labeled assignments of four reference rows to circuits or unused.

Thus max_z K4^A(L,z)=O(L³). Since #1029's exact pure-row primitive four-set count is A4(L,z)=5binom(L,2)+30binom(L,3), and each four-set gives 4!=24 all-distinct ordered paths, the maximum is also Ω(L³). Therefore **the cubic growth exponent is sharp for the Group-A multiplicity**, although neither the optimal constant nor the classical query lower bound is established. This independently recovers the stronger cubic *order* asserted in archived #1016, while avoiding its difficult minimum-reference four-lift enumeration.

## Mechanism: charge circuits against reference variation, not all sites

Fix any nonzero z with at least one Group-A representation and choose a **minimum-cardinality representation** C⊆R_L, XOR(C)=z, with r=|C|≤4. It is primitive: any nonempty zero-XOR subset could be deleted to get a shorter representation. Choose an alternative primitive C'⊆R_L, |C'|≤4, XOR(C')=z. Write T=C△C', a zero-XOR set.

If T=∅, the alternative is C and can be counted by the empty circuit pattern. Otherwise, greedily partition T into disjoint minimal nonempty zero-XOR circuits E₁,…,E_q. Each E_i contains at least one row from the reference-only side C\C' and at least one from the alternative-only side C'\C: a circuit lying entirely on either side would contradict that side's primitivity. Define A_i=E_i∩C and B_i=E_i∩C', with sizes s_i,t_i≥1. Distinct A_i are disjoint, and Σ_i t_i≤|C'|≤4.

Let F_i be the sites at which the rows of the **known reference subset A_i** have differing nonzero local factors. Let S_i be the active sites of the entire circuit E_i, so F_i⊆S_i. Source-exact Lovitz–Petrov Corollary 21 gives |S_i|≤s_i+t_i−2. Here is the crucial *minimum-reference variation lemma*:

    |F_i| ≥ s_i−1  for every nonempty A_i ⊆ C.         (V)

Proof by s_i:

- s=1: |F|≥0 trivially.
- s=2: two distinct product rows differ at at least one tensor factor.
- s=3: if three distinct rows varied at only one site, their three local factors would be all nonzero vectors of F₂², summing to zero, so these three rows would be a forbidden zero-XOR subset of primitive C. Thus at least two sites vary.
- s=4: this can occur only when C itself has r=4. If its four product rows varied at at most two sites, their sum z would be a tensor supported on at most a 2×2 binary matrix times fixed nonzero factors. Every 2×2 F₂ matrix is the sum of at most TWO rank-one binary matrices (e.g., its two rows), and hence z would have an original-row representation of length≤2, contradicting minimality of |C|=4. Thus at least three sites vary. This uses only elementary finite F₂ matrix rank, NOT a supposed general maximal-rank theorem for 2×2×2 tensors.

Therefore |S_i\F_i|≤t_i−1. Put F=∪_i F_i, V=∪_i(S_i\F_i). By union subadditivity,

    |V| ≤ Σ_i (t_i−1) = Σ_i t_i −q ≤4−1=3.           (V3)

Moreover U=∪_i S_i=F∪V, and the original LP budget gives |U|≤Σ_i(s_i+t_i−2)=|T|−2q≤6. Thus **at most three tensor sites are freely selected**; all other active sites are already forced by subsets of C.

## Count the finite forced patterns

The nonempty, pairwise-disjoint subsets A_i of C form an unordered partition of a subset of the r≤4 reference rows. Adjoin a dummy symbol ∞ and put unused reference rows in the block containing ∞. This is a bijection with partitions of r+1 elements. The number of possible reference-side circuit patterns is Bell(r+1)≤Bell(5)=52 (independently finite-enumerated; do not confuse with a count of possible new tensor sites). Each pattern determines the **fixed** site set F=∪_i F_i directly from C. The remaining V has at most three arbitrary sites, hence at most Σ_{j≤min(L,3)}binom(L,j) choices. We count only V with |F∪V|≤6; every actual alternative appears among these.

For each such (F,V), every alternative row either is shared with reference C or belongs to a circuit E_i and matches some row of A_i⊆C outside S_i⊆F∪V. All alternative nonzero rows therefore match one of ≤4 reference rows outside U=F∪V. Since |U|≤6, there are at most N=1+4·3^6=2917 candidate labels including zero.

Now count an all-distinct four-slot tuple of XOR z: choose its first two labels from at most N choices each. Its final two labels have residual XOR u=z XOR first XOR second, necessarily u≠0 (otherwise they coincide over F₂ and violate distinctness). There are at most M2(D_L) ordered pairs (third,fourth) of XOR u, and at most N because choosing the third from the candidate alphabet uniquely fixes the fourth. Thus ≤N² min(N,M2) alternatives per (F,V). Multiply by ≤52 reference patterns and ≤Σ_{j≤3} binom(L,j) freely chosen site sets. This proves (C1).

**Negative control:** if the four slots are NOT all distinct, a residual zero pair is permitted, so the M2 nonzero-frequency cap is invalid. This is why (C1) is specifically the actual disjoint Group A, not the historically broader K4 definition that included repeated zero placeholders. Repeated-label paths are handled separately by the Möbius Group B theorem in #1097.

## Quantitative conditional quantum consequence and comparisons

Combined with the still-unformalized full complex Hilbert frame/grouped-energy theorem in #1059/#1068, and the independently Lean-checked Möbius identity and scalar c≤35 in #1097, (C1) yields the **paper-level candidate**

    Q_class ≤ min(3^L,
      ceil{ 2 [2sqrt(K4^A(L))+35sqrt(2L+2)]² / (ε²δ) }).

The exponent O(L³/(ε²δ)) is thereby restored for the **complete distributional acceptance-probability bound, CONDITIONAL on the quantum-energy terminal**. It does not certify polynomial classical preprocessing or simulate output states.

At ε=δ=1/4 (so ε²δ=1/64), exact integer-root interval comparisons of the displayed candidate upper-bound formulas produce:

| Candidate bound | First L at which it beats all 3^L row queries |
| --- | ---: |
| Original 2026-11-22 six-site N⁴ / c=145 | 50 |
| Revised N³ / c=35 | 42 |
| Revised N² min(N,M2) six-site / c=35 | 38 |
| **Cubic (C1), 52 reference patterns / c=35** | **36** |

These are *upper-bound formula* crossovers, not real algorithm timings, measured quantum separations or independent acceptance-probability replay. Source-based exact integer comparisons rather than floating-point thresholds are required for the benchmark claim.

## Audit and proof passport requirements

1. Independent exact finite source checker: exhaust primitive reference/alternative pairs for L≤3, sample L=4 including a certified minimum-cardinality four-row reference with 4×4 flattening rank 4, check each decomposed circuit's A_i support property (V), every extra-site V bound, number of allowed Bell patterns and candidate-row matching. Include a negative fixture deliberately using a nonminimum four-row reference with too few variable sites, which breaks the s=4 argument and demonstrates that minimum-cardinality reference is essential.
2. Scoped Lean: certify source-depth-two every tensor is sum of ≤2 original rows, and the abstract free-site arithmetic |S\F|≤t−1 from the explicit hypotheses; no invented Lovitz–Petrov Lean axiom. Full (C1) terminal remains OPEN until these and source equivalence are formalized.
3. Obtain non-author mathematical audit of the reference-pattern bijection, circuit deletion and source min-cardinality step. Prior art: Lovitz (2018), Lovitz–Petrov (2023), Wang–Yuan (2026). This is **not** a claim to invent the tensor splitting theorem; the independently derived count and its T2 application remain priority candidates.
4. Separately audit/Lean-check the full complex Hilbert Group A/B/C energy and actual original-row oracle conditional expectation. Passing a finite checker or an abstract conditional Lean statement must not promote the complete quantum theorem.
