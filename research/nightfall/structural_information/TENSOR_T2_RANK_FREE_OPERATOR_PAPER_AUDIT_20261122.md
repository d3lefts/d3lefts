# Rank-free T2 quantum path-energy audit for the six-site tensor route
Version 1.0 (2026-11-22). **Author-side mathematical derivation only; not a Lean proof or independent external referee result**.

Source under scrutiny: archived #1016. This is an independently written, order-explicit reconstruction of the *same* Hilbert and Fourier estimates, using the new all-frequency B_{k,L} bound instead of the sharper, technically delicate author K_L=O(L^3). Mathematical originality and quantum theorem certification remain open.

## Oracle model (must match the claim)

Let D=R_L∪{0}. Work in any finite-dimensional **complex** Hilbert space H, with mutually orthogonal projections Π_a (a∈D) summing to I. For hidden s uniform over the binary dual source, set O_s=Σ_{a∈D} χ_a(s)Π_a, χ_a(s)=(-1)^(a·s), including the always-positive response sector Π_0. Fix unit ψ, any unitary U, any positive effect 0≤P≤I (no rank/trace restrictions). Absorb final unitaries into P. A two-oracle-query circuit has final state O_s U O_s ψ and acceptance f(s)=⟨O_s U O_s ψ,P O_s U O_s ψ⟩∈[0,1].

Define ψ_a=Π_a ψ, t_{ba}=Π_b U ψ_a, p_a=||ψ_a||², q_b=Σ_a||t_{ba}||², so Σp=Σq=1. Then

    f(s)=Σ_{a,b,a',b'∈D} χ_{a+b+a'+b'}(s)c_{a,b,a',b'}
    c_{a,b,a',b'}=⟨t_{b'a'},P t_{ba}⟩.

No orthogonality between different two-query paths of equal XOR frequency is assumed.

## Basic frame lemma — unrestricted terminal effect

Define G=Σ_{a,b}|t_{ba}⟩⟨t_{ba}|, with G≥0 and Tr(G)=1. For first-stage light labels a with p_a<η,

    G_{a-light}=Σ_{a:p_a<η,b}|t_{ba}⟩⟨t_{ba}|≤ηI.

Reason: the ψ_a are mutually orthogonal and individually have squared norm <η, hence Σ_{a:p_a<η}|ψ_a⟩⟨ψ_a|≤ηI. Conjugate by U and pinch with the projections Π_b; both preserve operator ordering. For second-stage light labels b with q_b<η,

    G_{b-light}=Σ_{b:q_b<η,a}|t_{ba}⟩⟨t_{ba}|≤ηI

because each b-block is positive with trace q_b<η, and blocks are mutually orthogonal.

For any such G_light,

    Σ_{light term, all opposite terms}|c|²
       =Tr(G_light P G P)
       ≤ηTr(P G P)=ηTr(G P²)≤η.

This is valid for any noncommuting positive contraction P, using 0≤P²≤I and Tr(G)=1. The same applies when light occurs in a primed slot. A union over four possible light slots therefore has total *ungrouped squared* coefficient energy at most 4η. This is the only primitive-lift energy estimate.

Choose the heavy original-row labels H0={a∈R:p_a≥η or q_a≥η}, with |H0|≤2/η. Let W=F₂-span(H0). If a nonzero-frequency z lies outside W, every tuple with XOR z contains a label outside W; that label is nonzero and light at the corresponding first or second query stage.

## Group A: pairwise-distinct slot labels with primitive nonzero entries

**Disjoint partition clarification (independent parallel audit #1068):** Classify any four-slot tuple containing *any repeated label*, including two or more zero labels, as Group B first. Among the remaining all-slot-pairwise-distinct tuples, the nonzero entries are either primitive (Group A) or, if all four are nonzero and the total frequency is nonzero, have exactly one zero-XOR triple (Group C). The counting invariant B_{4,L} may overcount primitive tuples with repeated zero labels, but these are excluded from the actual Group A coefficient contribution. This overcount affects only a bound, not the decomposition identity.

## Group A: primitive four-slot contributions

With all four original slot labels pairwise distinct by the preceding partition, erase at most one zero slot and collect the remaining nonzero labels. If they have no nonempty zero-XOR subset, they form a primitive representation of their nonzero frequency z. The new six-site result gives at most B_{4,L} ordered such lifts per z. By pointwise Cauchy-Schwarz in each frequency, sum of squared Fourier coefficients outside W ≤ B_{4,L}×4η. Their L² tail is therefore ≤2sqrt(B_{4,L}η).

## Group B: all repeated-label cases

There are six pairwise slot-equality events among a,b,a',b'. Inclusion-exclusion of their union has six first-order terms and at most 2^6−1−6=57 higher-order intersections. At nonzero frequency each intersection of at least two distinct equalities either forces two repeated pairs (zero frequency) or one triple repeated label and a singleton. A nonzero frequency z fixes XOR of the two surviving labels, so at most M ordered pairs support it; the ungrouped light-slot frame lemma gives ≤2sqrt(Mη) per higher intersection. Their combined tail is ≤114sqrt(Mη).

For each single equality, sum the coefficient over its canceled index, then apply the displayed frame lemma to the two surviving frequency labels. Each such grouped matrix has trace-≤1 families and light frame ≤ηI, hence **ungrouped survivor-index squared energy ≤2η**, and at most M ordered surviving pairs give each nonzero frequency. Therefore each single-equality Fourier tail is ≤sqrt(2Mη).

The six grouped identities and their bounds are:

1. a=a'. Surviving labels are b,b'. In enlarged direct-sum space, T_b=⊕_a t_{ba} are mutually orthogonal with ||T_b||²=q_b. Grouped coefficient is ⟨T_b', (⊕_a P)T_b⟩; the block effect is a contraction. Light b/b' frames ≤ηI.
2. b=b'. Surviving labels are a,a'. Put P_diag=Σ_bΠ_bPΠ_b, 0≤P_diag≤I. Grouped coefficient ⟨Uψ_a',P_diag Uψ_a⟩. The Uψ_a form an orthogonal family of squared norms p_a.
3. a=b. Surviving a',b'. The canceled-path vector V=Σ_a t_{aa} has ||V||²=Σ_a||t_{aa}||²≤1 (distinct output sectors). Grouped coefficient ⟨t_{b'a'},PV⟩; the light surviving path frame has operator norm ≤η.
4. a'=b'. Complex conjugate of the previous case with primed/unprimed variables exchanged.
5. a=b'. Surviving b,a'. Put F_b=Σ_aΠ_a P t_{ba}; grouped coefficient ⟨Uψ_a',F_b⟩. For every scalar family β_b,
       ||Σ_b β_b F_b||²
        =Σ_a ||Π_a P Σ_bβ_b t_{ba}||²
        ≤Σ_{a,b}|β_b|²||t_{ba}||²
        =Σ_b q_b|β_b|².
   The last step uses *same-stage* orthogonality of t_{ba} across b at fixed a, not false orthogonality across two-query paths. Hence the F_b frame has trace ≤1 and its q-light subframe ≤ηI. The Uψ_a' frame is orthogonal with p-light bound ≤ηI. This proves the grouped 2η estimate.
6. b=a'. Conjugate of case 5.

Total repeated-label tail ≤(6sqrt(2)+114)sqrt(Mη).

## Group C: four distinct nonzero labels with a zero triple

Four distinct nonzero labels of nonzero total XOR are nonprimitive iff they contain a zero-XOR triple (singletons and pairs cannot vanish over F₂). The triple is unique: two distinct zero triples would force the fourth labels equal. The survivor d is exactly the total frequency z and hence lies outside W and is light whenever z∉W.

For nonzero e put

    hatT_e=Σ_{a,b∈R:a+b=e} t_{ba}.

There are at most M terms per such pair fiber. Thus Cauchy-Schwarz and the disjoint frequency partition of path labels give

    Σ_{e∈R}||hatT_e||²≤M.

For a survivor at first-query position a'=d, temporarily allow d to equal a triple label. Grouping the triple gives

    K_d=⟨Uψ_d, Σ_{e∈R}Π_e P hatT_e⟩.

The second vector has squared norm ≤M: orthogonality of Π_e and contraction P. Summing |K_d|² over p-light d yields ≤ηM by orthogonality of Uψ_d.

For a survivor at second-query position b'=d, the grouped coefficient is

    K_d=Σ_{e∈R}⟨Π_d Uψ_e, P hatT_e⟩.

Cauchy-Schwarz gives |K_d|²≤q_d Σ_e||Π_d P hatT_e||²; sum over q-light d and the complete orthogonal Π_d resolution to get ≤ηM. The two unprimed survivor locations are conjugates. Hence each temporarily extended zero-triple group has outside-W Fourier norm ≤sqrt(Mη).

Subtract the temporary overlaps where d equals one of its three triple labels. Once d and its survivor placement are fixed, the other two triple labels XOR to d, so at most 3M ordered lifts occur at a nonzero frequency. Their ungrouped squared energy with light survivor is at most 4η, so their Fourier norm is ≤2sqrt(3Mη). Thus each of four survivor placements contributes at most (1+2sqrt(3))sqrt(Mη).

Total unique zero-triple tail ≤4(1+2sqrt(3))sqrt(Mη).

## Fourier projection and final query count

The three groups partition **all nonzero-frequency** four-slot terms. Zero-frequency terms are retained by conditional expectation, with no need to bound them. The triangle inequality gives

    ||f-E[f|χ_h,h∈H0]||_2
     ≤ [2sqrt(B_{4,L})
        +(6sqrt2+114+4(1+2sqrt3))sqrt(M)] sqrt(η)
     ≤ (2sqrt(B_{4,L})+145sqrt(M))sqrt(η).

Under uniform s, Walsh characters on the full dual vector space are orthonormal. The σ-field of observed queried characters corresponds exactly to span W, even if queried rows are linearly dependent, so conditional expectation retains precisely frequencies in W. The estimator g(s)=E[f|queried responses] lies in [0,1], is deterministic nonadaptive in the original-row bits and can be precomputed nonuniformly. No run-time/preprocessing claim follows.

The six-site *independent* primitive k=2 bound M≤B_{2,L} yields, at η=ε²δ/[2sqrt(B_{4,L})+145sqrt(B_{2,L})]²,

    Pr_s(|f(s)-g(s)|>ε)≤δ
    Q_class≤min{3^L, ceil(2[2sqrt(B_{4,L})+145sqrt(B_{2,L})]²/(ε²δ))}
           = O(L^6/(ε²δ)) for fixed ε,δ.

We may use the much sharper M=2L+2 from the tensor T1 work for a better constant, but it is not a dependency for polynomiality.

## Audit/priority/certification gates — NOT CLOSED

- The matrix inequalities above are *paper-level independently re-derived within an author-controlled instance*. This is not an independent human referee. The exact rational test suite in PR #1029 checks finite complex/high-rank cases but cannot prove all H and P.
- A full Lean terminal needs the LP-support identity (not currently in pinned Mathlib), disjoint circuit decomposition and word-cover count, plus the matrix-frame and Walsh conditional-expectation lemma. The separate six-site Lean construction and conditional support budget lemmas do not magically close these.
- Prior art for the shared active-mode mechanism: Lovitz–Petrov (2023), Corollary 21, and Wang–Yuan (October 2026), Theorem 4.3. General fixed-round uniform-input classical simulation is prior art from Blanc–Docter–Strassle–Tan (FOCS 2026) and Liu–Mutreja (2026). Our source is a tiny correlated linear code, so same-distribution priority is still unresolved.
- Do not publish or call a certified breakthrough without exact-source full Lean verification, adversarial non-author mathematical review, and specialist same-model priority audit. A formal implication from explicit hypotheses is not an unconditional formalization.

**Outcome:** a full, mathematically explicit *author-side* O(L^6) route now exists, replacing only the unverified sharp primitive-count argument with the simpler published-circuit-based all-frequency bound. Separate independent referee and Lean gates remain open.

## Parallel-instance reconciliation (2026-11-22)

PR [#1068](https://github.com/d3lefts/d3lefts/pull/1068), an independent parallel branch, states the same general binary-label four-fiber simulation criterion and independently compares unordered-support versus ordered-tuple exact enumeration, including K4/M2=(24,2) independent labels and (16,4),(348,6),(2004,8) tensor depths L=1,2,3. It explicitly warns that repeated zero labels must be assigned to the repeated-label group before the primitive-group frequency sum. The clarified disjoint partition above incorporates this audit. Credit #1068 for independently discovering the general formulation and for its disjointness check; do not count our closely related theorem as a separate novel result.
