# Cubic primitive XOR multiplicity for local dimensions two and three
NIGHTFALL independent structural extension — 2026-11-22

**Status:** Paper theorem relying on published Lovitz–Petrov circuit support plus independently specified finite algebra. Not a full Lean theorem, not a complete T2 quantum simulator and not globally priority-cleared.

## The local-dimension threshold

Let q be the dimension of a local F₂-vector space, let A_q=F₂^q\{0} (all 2^q−1 nonzero vectors), and R(q,L) be its L-fold pure tensor row set, so |R(q,L)|=(2^q−1)^L. D(q,L)=R(q,L)∪{0}. Let K4^A(q,L,z) count the actual four **pairwise-distinct** slot labels in D, with nonzero XOR z, whose nonzero entries form a primitive set. Define M2(q,L) to be the maximum ordered nonzero XOR pair fiber in D².

**Paper theorem (q=2,3):** For all L≥1 and all nonzero XOR frequencies z,
  
    K4^A(q,L,z) ≤ 52 [1+4(2^q−1)^6]^2
       min(1+4(2^q−1)^6, M2(q,L))
       · Σ_{j=0}^{min(3,L)} binom(L,j).

In fact for every q≥2,

    M2(q,L) = 2L(2^(q−1)−1)+2.

For q=2, recover M2=2L+2 and the previous cubic tensor bound. For q=3, M2=6L+2; taking q=3 gives the explicit candidate all-frequency cubic bound with candidate alphabet size N=1+4·7^6=470597. For each q=2 or 3, the exact F₂² subalphabet embeds into F₂^q, carrying over a pure-target family of ≥24·30·binom(L,3) ordered primitive four-row representations. Hence the exponent Θ(L³) is sharp for the **combinatorial Group A multiplicity** (not the classical query cost). The proof below shows why q≤3 is the precise range of this elementary forcing method; it does NOT establish failure of cubic multiplicity bounds for q≥4.

## Proof

The published Lovitz–Petrov 2023 Corollary 21 applies over arbitrary fields and any local dimensions: a minimally dependent family E of m distinct nonzero pure tensors has nontrivial local variation at no more than m−2 sites.

Choose a minimum-cardinality original-row representation C of z with at most four rows; it is primitive. For an alternative primitive C' of at most four rows, partition C△C' into disjoint minimal zero-sum circuits E_i. Every circuit includes s_i≥1 reference-only and t_i≥1 alternative-only rows. Let F_i be sites on which its s_i reference rows vary; S_i sites where its whole circuit varies. LP bounds |S_i|≤s_i+t_i−2.

For every subset A of s≤4 reference rows from C, |variation(A)|≥s−1, for q=2 OR q=3:
- s=1, trivial;
- s=2, distinct product rows must differ somewhere;
- s=3, variation on at most one site would make the XOR of these three pure rows either zero (violating primitiveness) or a single pure row. If the latter and |C|=3, the minimum representation is shorter; if |C|=4, replacing the three reference rows with their one-row XOR makes a representation of z with two rows, also contradicting minimal length. Thus s=3 forces at least two varying sites.
- s=4, then C itself has length four. Variation at at most two sites makes its XOR a q×q binary matrix tensored by fixed nonzero factors. Every q×q matrix is a sum of at most q rank-one binary matrices. When q≤3, this gives a z-representation with ≤3 original pure rows, contradicting the assumed minimum four. Hence the reference four must vary on at least three sites.

Therefore |S_i\F_i|≤t_i−1. Summing gives at most three genuinely freely varying tensor sites since Σ_i t_i≤4 and ≥1 circuit. The fixed reference-side circuit patterns number at most Bell(5)=52, and the whole circuit variation set U has at most six sites. Each alternative nonzero row agrees outside U with a reference row, so the candidate alphabet has ≤N=1+4(2^q−1)^6 labels including zero. Fix first two distinct slot labels; their residual XOR cannot be zero (otherwise last two coincide) and therefore there are ≤min(N,M2) completions. Multiply the counts. No assumption of product-space stochastic independence is used: this is exact binary tensor algebra.

For M2, classify pairs by their number h of distinct local factors. If h=1, pair XOR is a product row. For a given product target, at each differing site there are (2^q−2)/2 = 2^(q−1)−1 unordered decompositions into two distinct nonzero local vectors summing to the target. Across L sites, p_z = L(2^(q−1)−1). If h=2, pair XOR has rank two as a q×q matrix after factoring common outside tensors; its number of unordered rank-one decompositions is exactly |GL₂(F₂)|/2=3. Any other alternative pair would form a four-element circuit varying at most two sites by LP, so all decompositions stay in those sites. If h≥3, alternative pair would give a four-element zero circuit varying at least three sites, violating LP; its multiplicity is exactly one. Thus ordered D² fibers for original row target attain 2L(2^(q−1)−1)+2, and other frequencies have 2×3=6 or 2 representations; the displayed M2 is maximal for q≥2, L≥1.

## Negative boundary at q≥4 (method failure, not theorem disproof)

In V=F₂^4 and L=2, let e₁,…,e₄ be the standard unit vectors. The four distinct tensor rows e_i⊗e_i XOR to the 4×4 identity matrix. Matrix rank is four, so no representation by ≤3 rank-one tensor rows exists; this is a genuine minimum-cardinality four-row reference C. Yet C varies on exactly **two** sites, not the three required by |variation(C)|≥|C|−1. Hence the crucial reference-forcing lemma is FALSE at local dimension q≥4, despite the same published LP circuit theorem remaining valid. One cannot promote our q≤3 argument to arbitrary q simply by changing 3 to (2^q−1).

This counterexample is an operator-family boundary: it neither falsifies the all-frequency cubic theorem for q≥4 nor exhibits a quantum speedup. The corresponding q≥4 optimal exponent needs a different representation/active-set operator.

## Limits and next audits

1. Verify the s=3 replacement argument carefully for all C of length four (especially when a three-row XOR is zero, already excluded by primitivity).
2. Supply an independent GF₂ matrix rank checker for q=3 and rank-four negative fixture for q=4.
3. Formalize the q≤3 local rank-budget and explicit q=4 failure in Lean, preserving the source definitions and the published LP as an external *proven theorem*, not an unproved Lean axiom. Current PR #1109 supplies only the q=2 local matrix rank cover and conditional three-site arithmetic.
4. Global-priority search must compare all fixed-rank secant-fiber counting literature; no claim of universal novelty or complete T2 quantum theorem is licensed here.
