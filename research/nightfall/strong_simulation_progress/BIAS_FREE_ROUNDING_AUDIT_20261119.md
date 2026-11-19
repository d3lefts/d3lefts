# Bias-free dyadic rounding and a candidate strong-simulation upgrade

2026-11-19. **Author-side analytical derivation, independently rederived from the common-part/Markov operator in PR #894. NOT Lean-kernel certified, human-refereed, priority-cleared, or an approved preprint headline.**

## Objective and source dependencies

PR #893 obtained a proposed strong product-law simulator by uniform dyadic encoding, with an interpolation step requiring a positive atom margin c. PR #894 proposes the stronger *bias-free product expectation stability* inequality (A). Combine (A) with the explicit event smoother in #893, rather than Bernstein, to remove **all dependence on a minimum atom probability** from the classical-query overhead. For arbitrary finite alphabets, only the maximum alphabet size A remains.

Prior external sources in the #893 audit: BDST arXiv:2608.19158 uniform bounded-round strong simulation; GMNR arXiv:2609.35327 biased-product gadgets (not mixtures). This derivation is a composition of existing analytical operators; a complete novelty search remains undone.

## Lemma A (unconditional product mean stability; analytical proof)

Let P=⊗p_i and Q=⊗q_i on finite alphabets, **allowing zeros**, and let G:∏Σ_i→[0,1] have one-hot coordinate degree at most h≥1. Set η=max_i TV(p_i,q_i). Then

    |E_P G - E_Q G| ≤ 2 h² η.                       (A)

For each i, write c_i(a)=min(p_i(a),q_i(a)), η_i=TV(p_i,q_i), so ∑c_i=1−η_i. Choose a common residual r_i=c_i/(1−η_i) when η_i<1; choose any r_i when η_i=1. Choose source-exclusive residuals u_i,v_i such that p_i=(1−η_i)r_i+η_i u_i, q_i=(1−η_i)r_i+η_i v_i (arbitrary for η_i=0). If η=0 the result is immediate. For σ∈{u,v}, the path

    R_σ(s)=⊗_i[(1−sη_i)r_i+sη_i σ_i],   0≤s≤1/η,

contains genuine probability vectors throughout, starts at R=⊗r_i, and ends at P or Q when s=1. Because G has coordinate degree ≤h, F_σ(s)=E_{R_σ(s)}G is a real polynomial of degree ≤h; it takes values in [0,1] along the whole interval. The Markov brothers' derivative bound rescaled to an interval of length 1/η gives |F_σ'(s)|≤h²η. Integrate from 0 to 1 and sum the two path differences to obtain (A).

**Assumption to formalize:** Markov's derivative inequality for a degree-h real polynomial bounded in [0,1] on an interval of length L, with derivative bound h²/L. No positive marginal floor is used.

## Lemma B (bias-free dyadic transfer; provisional)

Let f:∏Σ_i→[0,1] be the acceptance probability of a t-query, d-round coherent finite-alphabet value-oracle algorithm. Let A=max_i |Σ_i|≥2, with arbitrarily biased independent coordinates; zeros are allowed. Let S(t,d,ε,η) denote a uniform-Boolean **strong** simulator (BDST) of worst-case depth S, error ε, and failure η. Fix 0<ε≤1/2, 0<η<1/2. For any integer m≥ceil(log₂ A), choose maps g_i:{0,1}^m→Σ_i with dyadic output laws q_i satisfying |p_i(a)−q_i(a)|≤2^(−m). Then TV(p_i,q_i)≤A 2^(−m)/2.

Substitute each symbol-oracle quantum query with m parallel bit queries to a uniform m-bit block, reversible computation of g_i, and uncomputation; this uses ≤2mt bit queries, ≤2d rounds (with the same symbol-oracle model as the #893 audit). Apply BDST at ε and η to obtain a uniform-bit tree of depth D(m)=S(2mt,2d,ε,η).

Transfer the bit tree to a symbol tree by sampling each complete uniform-bit block conditional on the observed symbol under q_i, reusing the same block across future queries. Symbols with q_i(a)=0 may be assigned arbitrary decoder responses: they have zero Q-mass and affect neither uniform correctness nor tree depth. Fix a global decoder random seed by averaging. The resulting deterministic, clipped symbol tree T has depth ≤D(m) and

    Pr_Q(|f−T|>ε) ≤ η.

Let k=ceil((2/(9ε⁴))ln(1/η)), r=floor(5kε²/2), and use the *explicit* polynomial event smoother introduced in the #893 independent audit:

    φ(z)=Σ_{j=r+1}^{k} binom(k,j)(z²)^j(1−z²)^(k−j).

The required binomial/Hoeffding inequalities state 0≤φ≤1 on [−1,1], φ≤η for |z|≤ε and φ≥1−η for |z|≥2ε. Its degree is at most 2k. Put H(x)=φ(f(x)−T(x)); H∈[0,1] and its one-hot coordinate degree is at most

    h(m)=2k(2t+D(m)).

Apply (A) to P and Q:

    |E_P H−E_Q H| ≤ h(m)² A 2^(−m).

Choose m such that 2^(−m)≤η/[A h(m)²]. Then

    Pr_P(|f−T|>2ε)≤E_P H+η
       ≤E_Q H+2η
       ≤Pr_Q(|f−T|>ε)+3η
       ≤4η.

So invoking with inner ε/2 and η=δ/4 yields an ε-accurate tree with failure at most δ, **without any minimum-atom assumption**.

## Eliminating m's fixed-point dependence

The uniform BDST bound implies, for fixed d and target ε,η,

    h(m) ≤ C (m+1)^q

for q=O(d) and an explicit positive C depending on t,d,ε,η but NOT on n, product biases or c. Let

    B=max(1, ceil(log₂(A C²/η))),  N=B+q+1.

A deliberately conservative explicit choice is m=ceil(64N²). To check: log₂(m+1)≤7+2log₂ N≤7+2N (N≥1), and B+2q log₂(m+1)≤B+14q+4qN<64N²≤m, so

    2^m≥2^B(m+1)^(2q)≥(A/η) C²(m+1)^(2q)≥(A/η)h(m)².

This resolves existence **once explicit BDST constants and q are fixed**. The scaling is polynomial in d, log A, t/ε and log(1/η). A sharper logarithmic m is possible but unnecessary for the polylog(1/δ) conclusion.

**Caution:** If C<1, the definition of B still ensures 2^B≥A C²/η. The inequality used in the proof uses 2^B, not an assumption C≥1.

## Conditional mixture synthesis (research target, NOT promoted)

Use the margin-free known-component classifier in PR #894 (with positive separation gap g) at joint preliminary-tree leaves, and the weighted conditional-leaf error accounting in PR #893. For a duel with |a_j−a_k|≥4ε, g≥2ε and a fixed test budget

    K = ceil(32 (2t)^4 (2ε)^(-2) log(1/ζ))
      = ceil(128 t⁴ ε^(-2) log(1/ζ)).

This is an improved zero-bias identification budget (the 512t⁴/g² coefficient is before substituting g≥2ε). If desired, use the looser ceil(512t⁴ ε^(-2) log(1/ζ)).

Subject to full proof and review of both transfers and of the conditional pairwise-tournament composition, the natural target for M mixtures is

    M·2^{O(d²)} ( t·[log A + log(M/(εδ))] / ε )^{O(d)}
      + M²·O(t⁴ log(M/(εδ))/ε²),

with approximation error 5ε and total mixture failure δ. For fixed d and finite A this is polylogarithmic in 1/δ and **uniform across arbitrarily small/zero component atoms**.

This statement is an **analytic conjectural composition**, not a proved/certified new headline theorem. It also requires checking posterior-dependent query overlaps and exact resource accounting. No external reviewer has examined it.

## Frozen conditional tournament: explicit paper-level error accounting

This spells out the mixture step that must not be hidden behind a conditional-failure bound.

For each known component P_j obtain a **deterministic** product-law tree T_j with worst-case query depth D and global failure

    E_j := Pr_{P_j}[|f−T_j|>ε] ≤ ρ.

Run all M trees, fixing their *joint* transcript ℓ and outputs a_j(ℓ) clipped to [0,1]. Every as-yet-unqueried coordinate has its original product marginal under each component conditional on ℓ. For each unordered pair (j,k) with |a_j−a_k|≥4ε, choose a test coordinate set S_jk(ℓ) *before seeing any duel outcomes*, by the high-TV/low-TV rule in #894, with tail parameter ζ. Query the union of these coordinate sets, then evaluate the frozen likelihood-ratio tests using only their designated observations. This avoids conditioning later tests on earlier duel outcomes.

Let α_j=P_j(ℓ), α_k=P_k(ℓ), and E_j(ℓ),E_k(ℓ) be the **unnormalized** contributions to their global failure events. In the high-TV regime, the Bhattacharyya affinity between the queried residual products is ≤ζ, and the **unnormalized, two-sided** likelihood-test error at ℓ is ≤ζ√(α_jα_k)≤ζ(α_j+α_k)/2. In the low-TV regime, the Markov stability lemma gives a conditional mean gap at most g/2, with g=|a_j−a_k|−2ε≥2ε, so the residual conditional failure probabilities obey r_j(ℓ,z)+r_k(ℓ,z)≥g/2≥ε for **every** assignment z to the high-TV set. Weighting by min(α_j p_j(z),α_k p_k(z)) and summing shows the leaf's two-sided error ≤(E_j(ℓ)+E_k(ℓ))/ε. Summing over disjoint joint transcripts yields

    Pr_{P_j}[j loses duel vs k]
       + Pr_{P_k}[k loses duel vs j]
       ≤ ζ+(E_j+E_k)/ε ≤ ζ+2ρ/ε.

For a true mixture component θ, if T_θ is accurate and θ wins every duel it enters, θ is undefeated. Every undefeated j then has |a_j−a_θ|<4ε, so its output is within 5ε of f. By the union bound, under any θ,

    Pr[error] ≤ ρ+(M−1)(ζ+2ρ/ε).

Take ζ=δ/(4M), ρ=εδ/(8M), with 0<ε≤1/4, 0<δ<1. The right side is <δ. At each transcript, the number of distinct queried coordinates is at most the sum over pairs, giving worst-case depth

    M·D(t,d,ε,ρ,A) + binom(M,2) ceil(128 t⁴ ε^(−2) ln(4M/δ)).

This *derives the exact conditional accounting on paper* provided (A) and the biased-product transfer are valid. It **does not certify** the external BDST composition, coherent-oracle implementation, quantitative m, or any Lean statement. Overlapping pair query sets may be reused; no saving is assumed in this bound.

## Proof obligations / falsification gates

1. Independently construct and check the gap polynomial's binomial tail constants and endpoint conventions.
2. Formalize finite-product degree under common-part interpolation; prove the scaled Markov bound and Lemma A **without supplied A as a hypothesis**.
3. Verify the dyadic rounding and decoder even when q_i(a)=0; formalize the quantum oracle model and 2mt/2d count.
4. Close the self-consistency estimate with *specified* BDST constants (big-O alone does not give executable numeric parameters).
5. Adapt the conditional duels to the zero-atom case with *unnormalized* posterior leaf masses, and verify the M-mixture failure union bound.
6. Independent prior-art and non-author mathematical review, then Lean kernel receipts, then publication decision.

**Operator transfer:** common-part polynomial interpolation → Markov derivative stability → distributional rounding without support assumptions → strong simulation → latent-component identification. The operator transfers from PR #894's known-product classifier to PR #893's dyadic product-source transfer.
