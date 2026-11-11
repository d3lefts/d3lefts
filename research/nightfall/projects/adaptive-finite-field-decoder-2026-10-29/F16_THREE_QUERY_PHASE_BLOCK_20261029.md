# Three-query phase compression in F16: an exact finite block and its two-round transfer

**NIGHTFALL research note, 29 October 2026 (ET)**  
**Project lead:** Devin J. Wright · **Construction:** AI-assisted NIGHTFALL search · **Certificate:** Lean 4 bridge plus independent Python polynomial implementation  
**Status:** candidate theorem; source and finite arithmetic internally checked, full transfer argument recorded below. Independent mathematical referee and same-oracle historical novelty review **not yet completed**. No global research-priority claim.

## 1. Fixed oracle, conventions, and previous upper bound

Let K=F16, L=F4, and identify K=F2[z]/(z^4+z+1). Field elements are four-bit polynomials. The subgroup H=L^× is {1,6,7}, and h^3=1 for every h∈H. Each query chooses a K-linear form a on x∈K^k, receives (a·x)^3∈K, and may adapt later forms to earlier outputs. The identifiable object is x modulo the global scalar action of H.

This is the **same full-subfield-phase cube-power oracle** as NIGHTFALL's previous q=4,r=2 decoder, whose support-aware two-round guarantee was k+(s−1)≤2k−1 queries (s=the support size). No stronger signal prior or new oracle is introduced.

## 2. Explicit three-measurement, four-phase gadget

For η=(η₁,η₂,η₃,η₄)∈H⁴ define

    C(η) = ( (14+12η₁+15η₂+3η₃+7η₄)^3,
             (15+4η₁+9η₂+6η₃+8η₄)^3,
             ( 5+ 5η₁+ 3η₂+14η₃+6η₄)^3 ).

All arithmetic is in K. In matrix form the coefficients, including the anchored constant, are

    A = [[14,12,15, 3,7],
         [15, 4, 9, 6,8],
         [ 5, 5, 3,14,6]].

**Finite certificate:** C is injective on all 3⁴=81 possible relative-phase vectors. Two independently implemented exact GF16 multiplication algorithms (shift/XOR in Lean and polynomial long division in Python) check pairwise distinctness without floating point. The Lean kernel must check the Boolean/table computation under an explicitly recorded foundation-axiom scope; no external theorem assumptions, admitted gaps, or `sorry` are present.

This finite certificate is the nontrivial algebraic step. Its 81 images can be enumerated once to form a deterministic inverse lookup.

## 3. Arbitrary-dimensional two-round decoder

**Claim (candidate theorem).** Every x∈K^k of support size s is recoverable up to H using

    m(k,s) = k + 3 floor((s−1)/4) + ((s−1) mod 4)
           = k + ceil(3(s−1)/4)

queries when s≥1. For the zero vector only the k coordinate queries are needed. Consequently every signal admits at most k+ceil(3(k−1)/4) queries. Compared with the previous bound 2k−1, this saves floor((k−1)/4) measurements in the full-support worst case.

**Proof.** First query x_j³ separately for all j. The support is known because the cube vanishes only for zero. For each nonzero j, choose any u_j with u_j³=x_j³; then x_j=λ_j u_j for some λ_j∈H, because the cube map's kernel on K^× is H. Choose a supported anchor t, set η_j=λ_j/λ_t∈H for j≠t, and partition the s−1 nonanchor indices into groups of four plus a remainder of 0–3.

For a full block (j₁,…,j₄), make three legal K-linear queries with coefficient A_{r,0}/u_t on the anchor and A_{r,i}/u_(j_i) on each block coordinate, zero elsewhere. Before powering, the r-th result equals

    λ_t [ A_{r,0} + ∑_{i=1}^4 A_{r,i} η_(j_i) ].

Since λ_t³=1, its cube is exactly the r-th coordinate of C(η_(j₁),…,η_(j₄)). By the certified injectivity, these three observations determine all four relative phases. For each remaining index j, one additional query of (x_t/u_t + z·x_j/u_j)³ resolves η_j individually. Indeed, 1 and z are L-linearly independent; if (1+zη)^3=(1+zη')^3 then 1+zη=h(1+zη') for some h∈H. The L-basis (1,z) forces h=1 and η=η'. Reconstruct x̂_t=u_t and x̂_j=η_j u_j. Then x=λ_t x̂. The second round depends only on first-round coordinate values. Counting gives three queries per full block and one per remainder coordinate. QED.

This transfer proof uses standard field facts plus the finite block certificate. **Only the finite block computation is in the present Lean file**; the universally quantified signal theorem has not itself been translated into Lean.

## 4. Exact worst-case optimality at k=5

The cube map K→K has precisely M=1+(16−1)/3=6 possible outputs. There are

    S_k = 1+(16^k−1)/3

global-H signal classes. A deterministic adaptive protocol of depth at most m produces at most 6^m distinct transcripts, even when future linear forms depend on prior answers. Therefore necessarily 6^m≥S_k.

For k=5, S₅=349,526 while 6⁷=279,936. Seven or fewer queries cannot identify every signal class. The construction above uses five coordinate queries plus three gadget queries on a full-support signal, and no more on smaller supports. Hence the **exact worst-case optimal query count is 8** for (K,L,d,k)=(F16,F4,3,5), conditional only on the supplied finite gadget and standard algebraic reduction.

The matching lower bound is an information-theoretic decision-tree argument and makes no claim about noise robustness. The counting step is elementary; its significance is the *matching explicit universal construction*.

## 5. Mechanism, scope, and possible transfer

The old algorithm made each mixed query carry a single relative phase because it used a fixed L-basis anchor separation. The new mechanism is **blockwise projective alphabet coding**: three nonlinear power observations jointly encode four multiplicative-subgroup phases. One-query basis capacity is not a multi-query throughput limit. This is a reusable design operator for other finite-field subgroups, extensions and power maps.

For this field each observation has only six possible outputs. Three outputs can potentially distinguish at most 6³=216 configurations; our 81-vector gadget is feasible, while five relative phases have 3⁵=243 possibilities and therefore cannot fit into three observations by any method, anchored or otherwise. Thus the gadget attains the largest possible number of *relative phases from three outputs*, although higher-throughput gadgets with more outputs remain open.

## 6. Reproduction and independent attack plan

1. Run `python3 research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/verify_f16_phase_block.py` (independent exact schoolbook polynomial multiplication and 10,000 deterministic randomized signal replays).
2. Compile `research/nightfall/formalization/phase_block/PhaseBlock.lean` using repository-pinned Lean 4.35.0. Preserve output of `#print axioms` and differentiate foundational Lean axioms from named unproved assumptions.
3. Adversarially verify polynomial irreducibility (no F₂ roots; not divisible by the sole irreducible F₂ quadratic z²+z+1), field subgroup, all coordinate conventions, zero rows and residual blocks.
4. Separate formal Lean finite computation from the external proof of arbitrary-dimensional extension.
5. Search for prior work on *this precise* finite-field cubing oracle and k=5 optimal adaptive reconstruction. Do not conflate complex absolute-square phase retrieval with this finite powered-field model.

**Prior-art first pass (29 October 2026 ET):** Charikar–Wu–Ye, *Adaptive Discrete Phase Retrieval*, SOSA 2020, DOI 10.1137/1.9781611976014.9, concerns finite-precision signals under complex intensity measurements; Balan–Casazza–Edidin (2006) gives classical nonadaptive complement-property background; Bartusel–Führ–Oussa (2023), *Phase retrieval for affine groups over prime fields*, studies complex group-frame measurements. None of those inspected descriptions is the exact K=F16, L=F4 cubing oracle. This targeted check is **not exhaustive novelty clearance**.

**Originality threshold:** only after independent mathematical referee and same-model priority review. **Current claim level:** finite candidate verified by exact replay; global transfer argument internal, pending independent proof review. The finite construction itself is reproducible and falsifiable even if an earlier equivalent construction is found.
