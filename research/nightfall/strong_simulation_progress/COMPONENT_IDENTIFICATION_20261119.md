# Component identification for product laws, and strong simulation over M-mixtures

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
    centres reduces to it.
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
- There are u, v with Pr_P[|f − u| > ε] ≤ δ, Pr_Q[|f − v| > ε] ≤ δ, and Δ := |u − v| − 3ε > 0.

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

## Lemma 3 (strong product simulation via uniform bits; corrected paper-level argument)

**Assumptions.** P is a finite-alphabet product law of atom margin c>0; f is the acceptance probability of a t-query, d-round quantum algorithm. Let S(t,d,η,τ) be the uniform-bit strong simulator of BDST. Fix output tolerance ε∈(0,1/2] and failure target δ₀∈(0,1); put τ=δ₀/8.

**Claim (conditional on the stated polynomial-smoother construction).** There is a deterministic depth-D product-law simulator with Pr_P[|f−T|≥ε]≤δ₀ and D≤S(2mt,2d,ε/2,τ), where m is any integer satisfying

    2^(−m) ≤ min(c/2, 2cτ/(π k(2t+D))),
    k = O(log(1/τ)/ε).

The self-reference of D and m must be eliminated explicitly to obtain a closed asymptotic bound; since S grows polynomially in m for fixed d, a polylogarithmic choice of m suffices.

**Proof.**

1. For each alphabet Σ_i, partition the 2^m uniform m-bit strings into groups of integer sizes whose normalized sizes p'_i(a) approximate p_i(a) to within 2^(−m) (balanced rounding). The pushforward product P' has atom floor ≥c/2.
2. Simulate each quantum query to x_i=g_i(y_i) by reading all m bits of block i in parallel, computing the symbol reversibly and uncomputing. This uses at most 2mt bit queries in at most 2d rounds. Its acceptance function on uniform y is f(g(y)).
3. Apply BDST at tolerance ε/2 and failure τ to obtain a uniform-bit decision tree of depth D.
4. Given a symbol query x_i, sample the whole y_i block uniformly among its preimages under g_i (reusing it on future queries). When x∼P', the induced y is uniform. Average over all decoder seeds and fix one deterministic seed with Pr_{P'}[|f−T|>ε/2]≤τ. Clip T's outputs to [0,1]; this cannot increase error.
5. **Named analytic dependency:** there exists a real polynomial φ of degree k=O(log(1/τ)/ε) satisfying 0≤φ≤1 on [−1,1], φ(z)≤τ for |z|≤ε/2, and φ(z)≥1−τ for |z|≥ε. This is a standard gap-threshold approximation statement, not yet proved in Lean here.
6. Put G(x)=φ(f(x)−T(x)). The function G takes values in [0,1] and has one-hot coordinate degree at most k(2t+D). The interpolation r_i(λ)=p'_i+λ(p_i−p'_i)/γ, γ=max_{i,a}|p_i(a)−p'_i(a)|, stays probabilistic for |λ|≤c/2. The Bernstein interior derivative estimate gives |E_P G−E_{P'} G|≤(π/4)k(2t+D)γ/(c/2)≤τ.
7. Hence E_{P'}G≤2τ, E_P G≤3τ, and Pr_P[|f−T|≥ε]≤3τ/(1−τ)≤δ₀. QED, **pending independent verification of the smoothing polynomial, parameter fixed point, and quantum-oracle substitution**.

**Source comparison.** GMNR Proposition 3.6 and Lemma 3.7 use a *p-biased gadget source*, with largest atom ≤(1−a)^m≤2^(−am), hence their displayed factor 1/a. The present encoding uses exactly uniform source blocks, whose largest atom is 2^(−m). This explains why a log(1/c) block size is plausible without contradicting GMNR. A comparison against GMNR alone does not establish novelty.

**Status:** paper proof with explicitly named analytic dependencies; not Lean-certified, independently refereed, or established as novel.

## Theorem 2, instantiated (paper level)

Inputs: d-round, t-query algorithms, and M-mixtures of margin-c products over finite alphabets.

- **Approximation:** 5ε.
- **Failure:** ≤ δ.
- **Depth:**

      M·2^{O(d²)}·(t·log(M/(εδc))/ε)^{O(d)} + M²·O(t²·log(M/(εδ))/(ε²c²)).

This is strong (polylog 1/δ) simulation over latent product sources for every constant number of rounds.

**Prior art.**

- BDST, LM26 and EPS26 treat the uniform cube only.
- GMNR treat µ_p, slices and products, but without δ tracking or mixtures.
- A search for simulation over mixtures of products found nothing.
- Closest in spirit: Bogdanov–Cheung–Dinesh–Lui, "Classical simulation of one-query quantum
  distinguishers" (APPROX 2023). It concerns general distribution pairs with one quantum query, not
  products or strong simulation.

## What remains

1. **Prior-art check.** Do BDST or the concurrent papers already handle product or mixture inputs?
2. **Verify the product black box.** Check that BDST Theorem 1 plus the gadget gives D with polylog(1/δ)
   dependence for margin-c biased products, and record the exact c-dependence.
3. **Lean.**
   - Steps 3–5 are finite combinatorics and fit the existing posterior and TV infrastructure.
   - Step 2 needs Bernstein's inequality for real polynomials, which is probably not in Mathlib. The plan
     is to state it as a named hypothesis first and discharge it later.
4. **Margin.** Remove or soften the dependence on 1/c, e.g. with a Hellinger (√p) reparametrisation of
   the segment in Step 2. This is the sparse regime, item 2 of the plan.
