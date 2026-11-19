# Component identification for product laws, and strong simulation over M-mixtures

> **2026-11-19 independent audit:** The component lemma and strong-product transfer are provisional paper arguments, not Lean-certified or peer-reviewed results. See [INDEPENDENT_AUDIT_20261119.md](INDEPENDENT_AUDIT_20261119.md) and the follow-on [STRONG_TRANSFER_CLOSURE_20261119.md](STRONG_TRANSFER_CLOSURE_20261119.md), which gives a paper-level explicit block-length bound and weighted transcript-duel calculation. The previous strong-product proof below has been sharpened to make the threshold polynomial and the encoding-length fixed point explicit. The general polynomial-in-1/δ mixture theorem in the earlier preprint remains a separate, certified result even if this bounded-round improvement ultimately fails.

Date: 2026-11-19.

**Status.**

- **Lemma 1:** paper proof. It relies only on Bernstein's inequality, which is classical. It is checked
  numerically by `component_id_check.py`, on 3 seeds and 1200 random instances: the Bernstein ratio is at
  most 0.49, and the TV bound held in all 148 separated cases. The audit found that last check
  **vacuous**, because the right-hand side exceeded 1 there. See `component_id_nonvacuous_check.py` for
  an exact nonvacuous instance.
  - **Steps 3–5 are Lean-certified**, with standard axioms only, in
    `formalization/product_space/ComponentIdentification.lean`. The certified theorems are
    `component_identification_core`, `mean_near`, `cell_cost`, `pay_per_cell`, `min_le_sqrt_mul`,
    `prod_one_sub_le_exp` and `hellinger_K_le`.
  - Step 2 (Bernstein) enters as the explicit hypothesis `hBern`.
  - `mean_near` assumes u ∈ [0,1]. The audit's u ∈ [−ε, 1+ε] variant is not yet covered; clipping the
    centres to [0,1] reduces to it. Failure sets only shrink, but the separation |u − v| can drop by up
    to 2ε.
  - Not yet reviewed by a person.
- **Theorem 2:** a conditional composition. It takes strong per-component product simulation as a black
  box.
- **Novelty is provisional.** BDST arXiv:2608.19158 and GMNR arXiv:2609.35327 were inspected on 2026-11-19. Comprehensive priority and human reviews remain outstanding.

## Setting

- Coordinate i takes values in a finite alphabet Σ_i.
- A product law P = ⊗ p_i has **margin c** if p_i(a) ≥ c for every i and every a ∈ Σ_i.
- f: ∏Σ_i → [0,1] has degree ≤ d. Concretely, it is a multilinear polynomial in the one-hot indicators
  1[x_i = a], with at most one indicator per coordinate in each monomial and at most d coordinates per
  monomial. The acceptance probability of a t-query quantum algorithm has degree ≤ 2t.
- For a product law with marginals r = (r_i), write F(r) = E_{x∼⊗r_i} f(x). This is a polynomial of
  degree ≤ d in the entries of r.

## Lemma 1 (component identification)

**Hypotheses.**

- P and Q are product laws with margin c ∈ (0, ½], 0 < δ < 1, d ≥ 1, and ε ≤ 1/4 (the regime needed when comparing [0,1]-valued candidate outputs separated by ≥4ε).
- The function f has degree ≤ d and values in [0,1].
- There are u, v ∈ [0, 1] with Pr_P[|f − u| > ε] ≤ δ, Pr_Q[|f − v| > ε] ≤ δ, and Δ := |u − v| − 3ε > 0.

**Conclusion.** There is a set S of coordinates with |S| ≤ K := ⌈π²d² ln(1/δ)/(8ε²c²)⌉, and a test
φ(x_S), such that

    Pr_P[φ = Q] + Pr_Q[φ = P] ≤ max(δ, 2δ/Δ).

The set S and the test φ depend only on P, Q, d, ε and c, so the queries are non-adaptive.

### Proof

**Step 1 (large and small coordinates).**

- Let γ_i = max_a |p_i(a) − q_i(a)| and η₀ = 4εc/(πd).
- Let L = {i : γ_i ≥ η₀} and R = [n] \ L.

**Step 2 (Bernstein).**

- Fix x_L. Under both P and Q, x_R is independent of x_L and has laws P_R and Q_R. The restriction
  g = f(x_L, ·) still has degree ≤ d and values in [0,1].
- Let s = (p_R − q_R)/γ_R, where γ_R = max_{i∈R} γ_i < η₀ ≤ c. Every entry of s has absolute value
  ≤ 1, and for each i the entries of s_i sum to 0.
- So r(λ) = q_R + λs is a product of probability vectors for |λ| ≤ c, because q_i(a) ≥ c.
- Let h(λ) = E_{⊗r(λ)} g. It is a polynomial of degree ≤ d with |h − ½| ≤ ½ on [−c, c].
- Bernstein's inequality gives |h'(λ)| ≤ (d/2)/√(c² − λ²). Integrating from 0 to γ_R:

      |E_{P_R} g − E_{Q_R} g| ≤ (d/2)·arcsin(γ_R/c) ≤ (π/4)·d·γ_R/c < ε.

**Step 3 (every x_L is costly).**

- Let δ_P(x_L) = Pr_{P_R}[|g − u| > ε], and define δ_Q(x_L) similarly with v.
- Since δ < 1, the global good events ensure u,v ∈ [−ε, 1+ε]. Hence for 0≤g≤1 the excess of |g−u| or |g−v| beyond ε is at most 1. Thus |E_{P_R} g − u| ≤ ε + δ_P(x_L) and |E_{Q_R} g − v| ≤ ε + δ_Q(x_L).
- Combined with Step 2: |u − v| < 3ε + δ_P(x_L) + δ_Q(x_L). That is, δ_P(x_L) + δ_Q(x_L) > Δ for
  **every** x_L.

**Step 4 (TV).** Write P_L, Q_L for the marginals on L. Then

    Σ_{x_L} min(P_L, Q_L)·Δ ≤ Σ_{x_L} (P_L·δ_P + Q_L·δ_Q) ≤ 2δ.

So the Bayes test on L has total error Σ min(P_L, Q_L) ≤ 2δ/Δ.

**Step 5 (few coordinates suffice).**

- For i ∈ L: H_i² := 1 − BC(p_i, q_i) ≥ TV(p_i, q_i)²/2 ≥ γ_i²/2 ≥ η₀²/2.
- **If |L| ≤ K:** take S = L and apply Step 4.
- **If |L| > K:** take any K coordinates of L. Then BC_S = ∏(1 − H_i²) ≤ exp(−Kη₀²/2) ≤ δ, and the
  likelihood-ratio test has total error ≤ BC_S ≤ δ. ∎

**Remarks.**

- The bound has no dependence on n, on the alphabet sizes, or on the magnitude of the small gaps.
- The 1/c factor enters only through Step 2. This is the sparse-input obstruction (item 2 of the plan),
  isolated in one place.
- Step 3 is the key point. Bernstein's inequality makes the small-gap coordinates useless for moving the
  *mean* of a low-degree f. The separation must therefore be paid for, pointwise in x_L, by failure mass.
  Summing that payment converts it into TV on L with only a *linear* loss in δ. A moment-based tail
  transfer, by contrast, loses δ^{O(log 1/ε)}.

## Corollary (conditional version; weighted proof)

Let B be a common deterministic transcript obtained by running a collection of decision trees, and fix two product components P,Q. At a leaf ℓ, let α=P[B=ℓ], β=Q[B=ℓ], and a_P(ℓ),a_Q(ℓ)∈[0,1] be the candidate outputs. The conditional laws of unqueried coordinates are the original product marginals. We only test leaves with |a_P(ℓ)−a_Q(ℓ)|≥4ε. Put

    E_P(ℓ)=Pr_P[B=ℓ and |f−a_P(ℓ)|>ε]
    E_Q(ℓ)=Pr_Q[B=ℓ and |f−a_Q(ℓ)|>ε].

Use the large-coordinate set L and the cap K computed from the unqueried marginals and a test-target δ_test.

**Small L.** If |L|≤K, the pointwise inequality ε≤δ_P(ℓ,x_L)+δ_Q(ℓ,x_L) follows from Steps 2–3. Multiply it by min(α P_L(x_L),β Q_L(x_L)), and sum over x_L. The resulting *unnormalized* Bayes-test error at this leaf is at most (E_P(ℓ)+E_Q(ℓ))/ε. This is valid even if conditional failure rates at a low-probability leaf are close to 1.

**Large L.** If |L|>K, select any K large-gap coordinates. Their Hellinger/Bhattacharyya bound gives BC(P_S,Q_S)≤δ_test. Thus the unnormalized Bayes-test error on this leaf is at most √(αβ)·δ_test≤(α+β)δ_test/2.

Summing over the tested leaves (which are disjoint) gives the explicit *two-sided* error bound

    Pr_P[wrong duel] + Pr_Q[wrong duel]
    ≤ δ_test + (Pr_P[|f−T_P|>ε]+Pr_Q[|f−T_Q|>ε])/ε.

This is the version used in Theorem 2. The conditional lemma must **not** be invoked with a uniform small conditional failure parameter on every leaf; only the weighted estimate above is justified.

## Theorem 2 (strong simulation over M-mixtures, conditional)

**Assumption (product simulation, black box).** For each component P_j there is a decision tree T_j of
depth D = D(t, ε, δ₁, c) with Pr_{P_j}[|f − T_j| > ε] ≤ δ₁. Candidate source: BDST Theorem 1 for d-round
algorithms on the uniform cube, transferred to biased products by the gadget. That transfer has **not**
been verified here.

**Algorithm.**

1. Run T_1, …, T_M and record their leaf values a_1, …, a_M. This uses at most M·D queries.
2. For each pair (j, k) with |a_j − a_k| ≥ 4ε, run the conditional Lemma 1 test for P_j vs P_k on the
   unqueried coordinates. This uses at most K(δ₁) queries per pair.
3. Output a_j for any j that lost no duel.

**Correctness.**

- Let θ be the true component.
- If T_θ is ε-accurate and θ wins all of its duels, then θ is undefeated.
- Any undefeated j satisfies |a_j − a_θ| < 4ε. Otherwise j and θ dueled and θ lost.
- So the output is within 5ε of f.
- Failure probability ≤ δ₁ + M²·(δ₁ + 2δ₁/ε). Setting δ₁ = εδ/(4M²) gives failure ≤ δ.

**Depth.**

    M·D(t, ε, εδ/(4M²), c) + (M choose 2)·O(t² log(M/(εδ))/(ε²c²)).

If D is polynomial in log(1/δ), this is **strong (log 1/δ) simulation over M-mixtures of margin-c
products**, with only polynomial overhead in M, t, 1/ε and 1/c.

## Lemma 3 (strong biased-product simulation: audited paper construction, conditional on closing the fixed-point estimate)

**Sources and scope.** BDST Theorem 1 (arXiv:2608.19158) gives strong simulation on the uniform Boolean cube. GMNR Proposition 3.6 (arXiv:2609.35327) transfers *average-error* simulation across biased source distributions. Their 1/a block-length cost arises from **biased source bits**; uniform source bits give dyadic error at most 2^{-m}. Neither reference explicitly proves the strong arbitrary-product result here. Novelty is not established.

**Parameters.** Fix 0<ε≤1/2, 0<η<1/2, original t queries and d rounds, and original product atom margin c>0. Let S(t,d,ε,η) denote a uniform-cube simulator with worst-case classical query depth at most S and failure probability at most η. Define D(m):=S(2mt,2d,ε,η). Choose

- k = ceil((2/(9 ε^4)) ln(1/η));
- h(m) = 2k (2t + D(m));
- an integer m with 2^{-m} ≤ min(c/2, cη/h(m)).

Such an integer **exists** because, for fixed d and fixed other parameters, the BDST bound makes h(m) grow polynomially in m while 2^m grows exponentially. To certify the displayed final O-bound, an explicit quantitative choice of m and its dependence on d remains to be written.

**Construction and proof steps.**

1. **Dyadic encodings.** For each finite alphabet Σ_i, partition {0,1}^m into cells and let g_i map each block uniformly onto symbol i with probability p'_i(a) satisfying |p'_i(a)-p_i(a)| ≤ 2^{-m}. Because p_i(a)≥c, all p'_i(a)≥c/2. The encoding covers every atom without alphabet-size dependence beyond c.
2. **Quantum pullback.** Replace a coherent query to an original symbol by queries to all m block bits, reversible computation of g_i, and uncomputation. This gives a 2mt-query, 2d-round Boolean-oracle algorithm with acceptance f(g(Y)).
3. **Uniform strong simulation and decoding.** Apply BDST to obtain a deterministic bit-query tree of depth D(m), approximating f(g(Y)) within ε except with probability η for uniform Y. For X∼P', sample **one fixed latent block per original coordinate** from Y_i conditioned on g_i(Y_i)=X_i, consistently reusing it at every later bit query. Averaging over the latent-block seeds and then fixing one global seed gives a deterministic X-query tree T of depth at most D(m), with Pr_{P'}[|f-T|>ε] ≤ η. Clip all leaf values to [0,1].
4. **Explicit failure-event polynomial.** Let r=floor(5kε²/2) and let

       φ(z) = Σ_{j=r+1}^k binom(k,j) (z²)^j (1-z²)^(k-j).

   This polynomial has degree ≤2k and, for all z∈[-1,1], takes values in [0,1]. Hoeffding's inequality for Binomial(k,z²), using the gap between ε² and 4ε², shows φ(z)≤η if |z|≤ε and φ(z)≥1−η if |z|≥2ε. Consequently G(x)=φ(f(x)-T(x)) has indicator degree at most h(m) and satisfies 0≤G≤1 everywhere.
5. **Dimension-free Bernstein rounding.** Write γ=max_{i,a}|p_i(a)-p'_i(a)| ≤2^{-m}. If γ=0 then P=P'. Otherwise the interpolation r_i(s)=p'_i+s(p_i-p'_i) consists of probability vectors for s in [−c/(2γ),1+c/(2γ)]. The function H(s)=E_{⊗r_i(s)} G has degree ≤h(m) and remains in [0,1] throughout this interval. Bernstein's derivative inequality implies |H'(s)|≤h(m)γ/c for 0≤s≤1, hence |E_P G-E_{P'}G|≤h(m)2^{-m}/c≤η.
6. **Strong-error transfer.** By the polynomial sandwich,

       Pr_P[|f−T|>2ε] ≤ E_P G+η
                           ≤ E_{P'}G+2η
                           ≤ Pr_{P'}[|f−T|>ε]+3η
                           ≤ 4η.

   Invoke this lemma with internal ε/2 and η=desiredFailure/4 to obtain ε-accurate per-component trees.

**Follow-on paper proof and remaining gates.** [STRONG_TRANSFER_CLOSURE_20261119.md](STRONG_TRANSFER_CLOSURE_20261119.md) supplies an explicit m satisfying the fixed-point inequality and a transcript-weighted Bayes-risk proof of the mixture tournament, including the unequal-transcript-prior case. These derivations are still author-side: recheck the binomial threshold boundaries, match the exact BDST query model/constants, audit the finite-alphabet coherent oracle pullback, obtain a separate independent review, and formalize analytic dependencies. An unreviewed paper argument is not a Lean certificate.

## Theorem 2, instantiated (paper level)

Inputs: d-round, t-query algorithms, and M-mixtures of margin-c products over finite alphabets.

- **Approximation:** 5ε (with Lemma 3 invoked at internal accuracy ε/2 and its failure parameter set to a sufficiently small fraction of the per-component budget).
- **Failure:** ≤ δ.
- **Depth:**

      M·2^{O(d²)}·(t·log(M/(εδc))/ε)^{O(d)} + M²·O(t²·log(M/(εδ))/(ε²c²)).

**Provisional:** a complete paper-level route to the polylog(1/δ) bound for fixed d is now recorded, including an explicit encoding-length estimate and a weighted conditional-tournament argument in [STRONG_TRANSFER_CLOSURE_20261119.md](STRONG_TRANSFER_CLOSURE_20261119.md). The end-to-end theorem has not been kernel checked or reviewed by an independent person.

**Prior art.**

- BDST, LM26 and EPS26 treat the uniform cube only.
- GMNR treat µ_p, slices and products, but without δ tracking or mixtures.
- A search for simulation over mixtures of products found nothing.
- Closest in spirit: Bogdanov–Cheung–Dinesh–Lui, "Classical simulation of one-query quantum
  distinguishers" (APPROX 2023). It concerns general distribution pairs with one quantum query, not
  products or strong simulation.

## What remains

1. **Prior-art check.** Initial comparison covers BDST Theorem 1 and GMNR Proposition 3.6/Remark 3.5; specialist novelty review remains open.
2. **Audit the product black box.** The fixed-point inequality now has an explicit author-side proof; verify it independently against the exact BDST constants, the coherent alphabet reduction and the binomial event-polynomial tails.
3. **Lean.** Steps 3–5 finite scalar core have passed pinned Lean 4.36.0-rc2 with standard axioms, workflow run 44487229739. The real-polynomial Bernstein interpolation and actual product-law tensorization remain separate, explicit formalization obligations.
4. **Margin.** Remove or soften the dependence on 1/c, e.g. with a Hellinger (√p) reparametrisation of
   the segment in Step 2. This is the sparse regime, item 2 of the plan.
