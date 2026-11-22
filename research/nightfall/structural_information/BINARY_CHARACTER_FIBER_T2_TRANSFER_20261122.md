# Binary-character fiber principle: a candidate rank-free T=2 simulation theorem

**Status 2026-11-22: new *structural generalization* of the paper argument in #1016/#1059, not an independently kernel-certified theorem, not a novelty clearance, and not publication authorization.** It makes the theorem's hypotheses invariant under the binary phase-oracle label geometry, instead of relying on tensors. The complete quantum-energy proof remains a distinct audit obligation. Primary mathematical ingredients belong to the earlier NIGHTFALL #1016/#1059 work and its cited antecedents; this note isolates the transfer principle.

## Exact problem and candidate statement

Let V be a finite-dimensional vector space over F₂ and let R⊂V\\{0} be any finite set of distinct nonzero labels. Write D=R∪{0}. A hidden s is uniform on V*, and one **classical original-row query** to a∈R returns χ_a(s)=(-1)^{a·s}. A two-query quantum circuit uses the **same label set** through the phase oracle O_s=Σ_{a∈D}χ_a(s)Π_a, where the Π_a are pairwise orthogonal complex-Hilbert projectors summing to identity. Inter-query unitaries, arbitrary finite ancillary space, and terminal effect 0≤P≤I are allowed. No independent input-bit promise, rank bound, trace bound, or classical runtime guarantee.

Define two *combinatorial* resources, using ordered tuples:

- M₂(R)=max(1, max_{z≠0}|{(a,b)∈D²:a+b=z}|).
- K₄(R)=max(1, max_{z≠0}|{(a,b,c,d)∈D⁴:a+b+c+d=z, **the distinct nonzero entries are actually pairwise distinct and linearly independent**}|). Equivalently after erasing zero entries, **no nonempty subset XORs to zero**. Repeated zero entries are allowed *in the counting invariant* to make this an upper bound for the disjoint primitive group.

**Conjectured source-derivable terminal (paper-level).** For any bounded acceptance probability f(s) of the above two-query circuit, every ε,δ∈(0,1) admits a deterministic, nonadaptive original-row classical estimator g(s)∈[0,1] such that P_s(|f-g|>ε)≤δ and

    Q ≤ min{|R|, ceil( 2( 2 sqrt(K₄(R)) + 145 sqrt(M₂(R)) )² / (ε²δ) )}.

Consequently, any family R_L for which K₄(R_L)+M₂(R_L) is polynomial in a parameter L has a polynomial-query **distributional acceptance simulator**, independently of the Hilbert dimension and terminal-effect rank. The quantum circuit and source can be nonuniformly known; classical preprocessing may be exponential.

## Why the tensor assumption is not used in the final operator argument

The proof of #1016 and its audit in #1059 is formulated using only characters, binary XOR, pair fibers, and Hilbert-space frame inequalities. Product tensors are used *solely* to prove a polynomial upper bound on K₄ (and optionally M₂), via the published Lovitz–Petrov tensor-circuit theorem. Removing that final specialization yields an arbitrary-label transfer theorem **if the quantum path-energy estimate survives audit**.

1. Decompose the two-query circuit as t_{ba}=Π_b U Π_a ψ, p_a=||Π_aψ||², q_b=Σ_a||t_{ba}||²; both p and q sum to 1. Heavy original labels H={a∈R:p_a≥η or q_a≥η} satisfy |H|≤2/η. Query these labels; W=span_F₂(H). Conditional expectation onto their queried characters preserves exactly frequencies in W under uniform s.
2. For a-light first paths, the positive frame G_ℓ=Σ_{a-light,b}|t_{ba}⟩⟨t_{ba}| satisfies G_ℓ≤η I by orthogonality of the Π_a and pinching. For b-light second paths the analogous inequality follows from block-trace q_b. For any 0≤P≤I, Σ_{light slot,opposite path}|⟨t',P t⟩|²=Tr(G_ℓ P G P)≤η. Union over four slots costs ≤4η.
3. **Use a genuinely disjoint coefficient partition**: (A) tuples with *all four slot labels pairwise distinct* and independent nonzero entries; (B) any repeated-label tuples, including repeated zeros; (C) all four slots distinct, nonzero, and containing a zero-XOR triple. At nonzero total frequency these cases exhaust the coefficient expansion. The enlarged invariant K₄ bounds Group A even though it also counts some tuples with repeated zero; these must NOT be counted twice when decomposing the actual Fourier expansion.
4. For A, at most K₄ ordered representations per outside-W frequency, so the Fourier tail is ≤2√(K₄η). For B, resolve six equality events by inclusion–exclusion; each higher intersection reduces to a nonzero two-label XOR fiber, while each first-order event is regrouped as a frame over the two surviving labels. The source estimate is ≤(6√2+114)√(M₂η). For C, the unique zero triple is grouped into a pair-convolution path vector; its four survivor positions and overlap corrections contribute ≤4(1+2√3)√(M₂η). **The B/C estimates are not independently re-proved in this note**; their exact complex-operator proof must be audited line by line.
5. Parseval/conditional expectation gives ||f−g||₂≤(2√K₄+145√M₂)√η. Set η=ε²δ/(2√K₄+145√M₂)² and apply Markov. Query all rows if this is worse than |R|.

This isolates a **testable general mechanism**: *low primitive four-XOR multiplicity plus low pair-XOR multiplicity imply low classical query cost for two-query quantum acceptance*, without assuming independent oracle bits. It does **not** imply the corresponding assertion for T>2; repeated-label/zero-subsum cancellations proliferate and need new operator estimates.

## Two model families / exact integer regression

The independent direct-tuple and support-subset enumerators in `scripts/check_binary_phase_fibers_exact.py` agree:

| Label set | |R| | K₄ | M₂ |
| --- | ---: | ---: | ---: |
| Four linearly independent labels | 4 | 24 | 2 |
| Nonzero pure tensors (F₂²)^{⊗1} | 3 | 16 | 4 |
| Nonzero pure tensors (F₂²)^{⊗2} | 9 | 348 | 6 |
| Nonzero pure tensors (F₂²)^{⊗3} | 27 | 2004 | 8 |

For *any* independent label family of size N≥3, K₄=24 and M₂=2 by direct rank counting (only a support of ≤4 distinct labels can XOR to z, with ordered placement 4!/(4-k)!). For the tensor family R_L, #1059's published-circuit argument implies K₄=O(L⁶), M₂=O(L²), so the same abstract conclusion would yield O(L⁶/(ε²δ)); the earlier sharper O(L³) author route #1016 remains separate and uncertain. These integer examples test only combinatorics; they do not certify arbitrary quantum circuits.

## Preregistered adversarial audit and promotion gates

**Builder:** derive a source-exact abstract binary-label theorem without tensor assumptions. Do not merely copy the tensor conclusion. Model and prove the disjoint three-way Fourier partition, with repeated zero labels handled explicitly; then reconstruct all complex frame inequalities from definitions and push to a named Lean terminal. First cheap test: full enumeration on every R⊂F₂³\\{0} and low-dimensional arbitrary complex effects.

**Independent critic:** develop the B/C grouped coefficients *without seeing builder's proof*, check all six first-order equalities, all 57 higher intersections, distinct-zero cases, arbitrary nonprojective P, rank≫1, and noncommuting sectors. Attempt counterexamples; finite tests are falsifiers, never theorem proof. The central failure candidate is an unjustified regrouping or an incorrectly reused light-slot bound.

**Checker / certification:** exact separate enumeration algorithms (provided), complex random/exact rational tensor tests with deliberately nonprojective P, one source-exact Lean module for the abstract operator theorem, standard-axiom and mandatory independent kernel replay, immutable head+compiler+source hashes.

**Prior-art gate:** compare claim with Aaronson–Ambainis/Turturean product AA, GMNR 2026, BDST bounded-round simulation, Fourier-based query lower/upper bounds, and #1029's Lovitz–Petrov/Wang–Yuan ledger. The *tensor-circuit active-site theorem* is **published prior art**, not a NIGHTFALL invention. No exact generic label-invariant predecessor was established by the limited 2026-11-22 search, which is not a novelty certificate. The exact model, success metric, and classical access accounting must be identical before declaring originality.

**Stop rule:** promote only after a fully checked abstract quantum terminal and source-matched mathematical review. If any complex operator estimate fails, save the smallest counterexample and demote the generic claim. Avoid extra exploratory branches until the A/B/C audit is resolved.

## Links / custody

- Earlier paper (credit): #1016 `TENSOR_TWO_QUERY_RANK_FREE_20261122.md`
- Independent six-site audit: #1059 `TENSOR_T2_RANK_FREE_OPERATOR_PAPER_AUDIT_20261122.md`
- Core counting/priority gate: #1029 and issue #1021
- Published tensor mechanism: Lovitz–Petrov, *A generalization of Kruskal's theorem on tensor decomposition*, Forum of Mathematics, Sigma 11 (2023), Corollary 21.
