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
