# All-frequency six-site reduction for rank-free tensor T2 simulation
Version: 1.0, 2026-11-22
Status: **paper-level candidate, independent Lean full terminal and external peer review OPEN**.

Source under audit: archived full-T2 manuscript #1016, audit branch PR #1029 and issue #1021. This is an intentionally *coarser* and simpler alternative to the sharp O(L^3) primitive bound; no claim that it improves the latter. It uses published Lovitz–Petrov, Theorem 4/Corollary 21 (2023), not an original tensor circuit theorem:
https://www.cambridge.org/core/journals/forum-of-mathematics-sigma/article/generalization-of-kruskals-theorem-on-tensor-decomposition/515357D904DD4AD1042F37BBCBC95B35

## Definitions and exact theorem

Fix L≥1. Let V_L=(F_2^2)^{⊗L}; R_L consists of all 3^L nonzero product tensors with each local factor in F_2²\{0}; D_L=R_L∪{0}. A set C⊂R_L is primitive if every nonempty subset has nonzero XOR. For nonzero z, let Q(z) be the collection of ordered four-tuples (r_1,r_2,r_3,r_4)∈D_L^4 such that the nonzero entries are distinct, have XOR z, and are primitive.

**Six-site multiplicity theorem (paper proof, field-general splitting imported):**

    |Q(z)| ≤ B_L := (1 + 4*3^6)^4 * sum_{j=0}^{min(L,6)} binom(L,j).

The theorem holds at ALL z≠0, not only at product rows, and B_L=O(L^6).

### Proof with every dependency exposed

If Q(z) is empty, done. Choose a reference primitive subset C⊂R_L consisting of the nonzero entries of one tuple, with 1≤|C|≤4. For another tuple let C' be its nonzero entry set (1≤|C'|≤4). The symmetric difference T=C△C' has XOR zero since XOR(C)=XOR(C')=z.

If T is empty, use U=∅. Otherwise partition T into *disjoint* zero-XOR circuits E_1,...,E_q by greedily removing an inclusion-minimal nonempty zero-XOR subset. Each circuit contains at least one row of C\C' and one of C'\C: otherwise it would be a forbidden nonempty zero-XOR subset of a primitive set. In binary characteristic, a minimal nonempty zero-XOR set of distinct nonzero vectors is a matroid circuit; no hidden nonunit coefficients appear.

For each circuit E_i, let S_i⊂[L] be the set of local tensor factors where the rows in E_i have more than one local nonzero factor. **Lovitz–Petrov Corollary 21**, over F₂ and for L≥2, says

    |S_i| ≤ |E_i|−2.

The L=1 case is elementary (there is only one site); the same upper bound also holds for its distinct nonzero circuits, which must have three elements. Put U=union_i S_i. Since the circuits are disjoint and q≥1,

    |U| ≤ Σ_i(|E_i|−2) = |T|−2q
        ≤ |C|+|C'|−2 ≤ 6.

Every new row r∈C'\C lies in some E_i; pick any reference row c∈E_i∩(C\C'). Outside S_i (hence outside U), all local factors of r equal those of c. Every shared row r∈C∩C' also equals a reference row (itself) outside U. Therefore every nonzero entry r of the alternative tuple agrees with at least one c∈C on all coordinates outside U.

Fix U with |U|=j≤6. For each reference row c, at most 3^j original tensor rows agree with c outside U (three nonzero choices at each site of U). Since |C|≤4, there are at most 4*3^j possible nonzero tuple entries, plus the zero label, yielding at most (1+4*3^j)^4 ordered four-tuples, even when repetitions and nonprimitive tuples are overcounted. Sum over all U with size ≤6; replacing 3^j by 3^6 yields B_L. This completes the all-frequency multiplicity bound with no minimum-cardinality reference step.

**Important edge case:** E_i has at least three elements (distinct nonzero binary vectors), so LP's connected-circuit support bound is nonvacuous. When L=1, direct circuit verification replaces the m≥2 assumption of Theorem 4.

## Consequence for quantum T=2 (conditional on independently audited energy grouping)

For a two-query phase-oracle circuit with an arbitrary finite-dimensional complex Hilbert space H, projectors Π_a for a∈D_L, initial unit vector ψ, intermediate unitary U, terminal arbitrary effect 0≤P≤I, let

    t_{ba}=Π_b U Π_a ψ,
    p_a=||Π_a ψ||²,
    q_b=Σ_a||t_{ba}||².

Then Σp=Σq=1. Choose η>0 and query the original nonzero rows with p_a≥η or q_a≥η, at most 2/η queries. Let W be their F₂ span. The claimed Fourier tail decomposition from source PR #1016, independently checked in exact finite complex circuits in PR #1029, is:

    ||f−E[f | queried parities]||_{L²}
      ≤ [2 sqrt(B_L) + (6sqrt(2)+114+4(1+2sqrt(3)))sqrt(M_L)] sqrt(η)
      ≤ (2 sqrt(B_L)+145 sqrt(M_L)) sqrt(η),

where M_L=max_{z≠0} #{(a,b)∈D_L²:a+b=z} = 2L+2 (the pair bound is inherited from the earlier tensor T1 work). The four groups are: (i) primitive distinct nonzero entries (new six-site count); (ii) the six repeated-label equality events, handled by matrix-frame energy and inclusion–exclusion (up to 57 higher intersections); (iii) the four zero-triple survivor cases, handled by pair-sum grouping; and (iv) Fourier zero frequency, which is retained in W.

This gives a **paper theorem candidate**, not a Lean-certified quantum algorithm:

    Q_class ≤ min{3^L, ceil[2*(2sqrt(B_L)+145sqrt(2L+2))²/(ε²δ)]}
            = O(L^6/(ε²δ)),

for uniform s∈V_L*, deterministic nonadaptive original-row queries and an unbounded nonuniform conditional-expectation look-up table, with probability of ε error at most δ. This does not simulate output quantum states, guarantee pointwise accuracy, or give polynomial-time classical evaluation.

The tail lemma above is still a *substantive independent proof obligation*: especially for arbitrary complex P and ancillary workspace. A finite rational checker does not prove it. A complete Lean terminal MUST internalize the product-tensor counting, matrix frames and Walsh conditional-expectation bridge. The strong cubic exponent is *not necessary* to obtain a polynomial-query statement, but remains the stronger candidate if independently verified.

## Cheapest decisive tests and honest gates

1. Source-independent binary GF₂ enumeration of every primitive family through L≤4 and direct witness-to-circuit decomposition. Include all-frequency targets, zero labels, shared rows and no counterexample hidden in the sharp author's k=4 argument. Larger L requires selective adversarial construction (small levels alone cannot disprove >6-site behavior).
2. Reconstruct the quantum repeated-label frame bounds independently over **complex** Hilbert spaces, including phase signs and arbitrary nonprojective effects. Formalize as general finite matrices.
3. The all-L counting proof uses LP as **published prior art**; until its exact assertion is represented in Lean, classify the derivation as paper-level, not kernel-proved. No new global novelty claim beyond a possible specified application.
4. If the O(L^6) bridge survives independent review, isolate a complete kernel theorem with explicit query count. If it fails, preserve the counterexample and demote. Do not merge to the main research registry or announce a competitive record on finite checks.

Mechanism graph: correlated phase-oracle → primitive XOR supports → circuit decomposition → LP active-mode control → O(L^6) all-frequency cardinality → frame-energy Fourier tail → nonuniform original-row classical estimator → query certificate. Bound is sufficient, not known sharp; author-side proof only.


## v2: all fixed-order primitive frequencies, without relying on T1 sharp pair bounds

**General paper theorem (published tensor-circuit support imported):** For each k≥1, z≠0, define Q_k(z) as ordered k-tuples in (R_L∪{0})^k whose distinct nonzero entries have XOR z and form a primitive (zero-subset-free) family. Then

    |Q_k(z)| ≤ B_{k,L}
       := (1 + k*3^(2k-2))^k * sum_{j=0}^{min(2k-2,L)} binom(L,j)
        = O_k(L^(2k-2)).

**Proof:** Repeat the preceding symmetric-difference decomposition with both reference and alternative primitive subsets of size at most k. The disjoint circuit union has |U|≤|C|+|C'|−2≤2k−2. Each alternative nonzero tuple entry agrees outside U with some of ≤k reference rows. For given |U|=j the number of candidate labels is ≤1+k3^j, counting label zero. Overcount ordered k-tuples and sum over U. For k=1, two different one-row representations of z cannot occur and the formula holds trivially. For L=1 the circuit statement follows directly from the three nonzero local vectors; for L≥2 use published Lovitz–Petrov Corollary 21.

This gives **two independent quantities**, using the SAME published circuit theorem:
- primitive four-lift bound B_{4,L}=(1+4*3^6)^4 Σ_{j≤6} C(L,j) = O(L^6);
- all nonzero ordered pair-XOR multiplicities (no primitivity issue for nonzero sums) M_L ≤ B_{2,L}=(1+2*3²)^2 Σ_{j≤2} C(L,j) = O(L²).

The earlier claimed exact M_L=2L+2 is a much sharper optional improvement, separately documented in PR #1029; **it is no longer a dependency** for a polynomial T2 query theorem. Substituting M_L≤B_{2,L} in the Section 2 Fourier estimate gives the fully self-contained (relative to published LP plus the still-to-be formally audited operator-energy estimates) sufficient query bound

    Q_class ≤ min {3^L,
      ceil[2(2 sqrt(B_{4,L})+145 sqrt(B_{2,L}))²/(ε²δ)]}
      = O(L^6/(ε²δ)).

The value of the general k theorem is a reusable *finite-frequency algebraic mechanism*. At higher quantum query orders T, k=2T yields a primitive Fourier-frequency count O_T(L^(4T-2)), but **does not** by itself control repeated-label interference or give a T-query simulator. Do not claim such an extension before a separate quantum contraction theorem.

Prior-art boundaries: Lovitz–Petrov's 2023 circuit support bound and Wang–Yuan's 2026 effective-active-mode exchange result are inherited. Our possible contribution is the explicit all-nonzero-frequency binary-label count and correlated-oracle simulation application, subject to dated specialist search and human review. Full Lean theorem remains open.


## v3: rank-sensitive primitive fiber tiers (strictly stronger than the uniform degree)

For any nonzero z expressible as XOR of rows of R_L, define ρ_R(z) to be the **minimum number of distinct nonzero original tensor rows** with XOR z. A shortest representation is primitive: if a nonempty subset XORed to zero, removing it would give a shorter representation.

If 1≤r=ρ_R(z)≤k, fix a primitive reference set C of size exactly r. For any primitive alternative set C' of size≤k, the same disjoint-circuit support argument gives

    |U| ≤ |C|+|C'|−2 ≤ r+k−2,

and every new row matches one of the r reference rows outside U. Therefore the **frequency-by-frequency** ordered k-slot primitive bound improves to

    B_{k,L}(z)
      ≤ (1+r*3^(r+k−2))^k *
        Σ_{j=0}^{min(L,r+k−2)} C(L,j)
      = O_{k,r}(L^(r+k−2)).

For k=4, the certificate has separate structural tiers:

| minimal original-row XOR length ρ(z) | proved upper exponent in L |
| ---: | ---: |
| 1 (pure tensor row) | 3 |
| 2 (secant frequency) | 4 |
| 3 | 5 |
| 4 | 6 |

This is a **sufficient bound, not the exact asymptotic fiber growth**. Prior #1029 exact formulas show sharper exponents on some pure and rank-two fixed-core frequencies. The uniform O(L^6) theorem uses the worst tier r=4 and remains unchanged. An energy-weighted simulator that benefits from the lower-rank tiers would require a new certified link between quantum amplitude-sector mass and frequency rank; no such claim has been established.

**Numerical significance gate:** At ε=δ=1/4, the explicit *coarse* O(L^6) bound from v2 first beats the full 3^L row-query fallback at L=50 (formal bound ~6.77×10^23 vs 3^50~7.18×10^23), with the gap expanding thereafter. Thus it is a genuine asymptotic polynomial query result but its raw constants are not a practical finite-size efficiency gain. Stronger constants, a cubic exponent, or improved dependence on ε,δ matter for practical use. The calculation is a numeric comparison of the displayed proven-formula *candidate*, not an independent empirical quantum simulation benchmark.


## v4 priority correction — Lovitz 2018 precedes the 2023 paper

The independent priority auditor on [issue #1021](https://github.com/d3lefts/d3lefts/issues/1021#issuecomment-7083553767) located [Benjamin Lovitz, *Toward a generalization of Kruskal's theorem on tensor decomposition*, arXiv:1812.00264 (2018)](https://arxiv.org/abs/1812.00264). The earlier paper already states the connected-product-tensor circuit active-factor bound in the case where all but at most two local factors have dimension two; our tensor family has every local factor dimension two. The 2023 Lovitz–Petrov theorem extends the field-general framework.

**Credit both 2018 and 2023.** The active-factor/circuit-support bound, and the general idea of bounded-mode tensor exchanges, are not NIGHTFALL's discoveries. The claimed original mathematical object, if it survives a specialist search, is the *exact nonzero-frequency primitive XOR counting certificate in the correlated binary oracle* and its rank-free quantum query application. No novelty gate is satisfied merely by the present manuscript's explicit constants or finite Lean certificates.
