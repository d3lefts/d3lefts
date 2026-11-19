# Component identification for product laws, and strong simulation over M-mixtures

Date: 2026-11-19.

**Status.**

- **Lemma 1:** paper proof. It relies only on Bernstein's inequality, which is classical. It is checked
  numerically by `component_id_check.py`, on 3 seeds and 1200 random instances: the Bernstein ratio is at
  most 0.49, and the TV bound held in all 148 separated cases. It has **not** been reviewed or formalized
  in Lean.
- **Theorem 2:** a conditional composition. It takes strong per-component product simulation as a black
  box.
- **Novelty is unchecked.** A prior-art search is still pending: BDST arXiv:2608.19158, Liu–Mutreja, and
  Escudero Gutiérrez–Palazuelos–Saucedo.

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

- P and Q are product laws with margin c ∈ (0, ½].
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
- Since 0 ≤ g ≤ 1, we have |E_{P_R} g − u| ≤ ε + δ_P(x_L) and |E_{Q_R} g − v| ≤ ε + δ_Q(x_L).
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

## Corollary (conditional version)

Condition on any leaf ℓ of a decision tree. Coordinates that are not yet queried stay independent with
unchanged marginals. So Lemma 1 applies at ℓ with constants a_P(ℓ), a_Q(ℓ) in place of u, v. Summing Step 4
over (ℓ, x_L), and using Cauchy–Schwarz for the case |L| > K, gives total error over the whole tree of at
most δ_tot + 2δ_tot/Δ, where

- δ_tot = Pr_P[|f − T_P| > ε] + Pr_Q[|f − T_Q| > ε], and
- T_P, T_Q are the leaf values.

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

## Lemma 3 (strong product simulation from the uniform case: the black box, paper proof)

**Why this is needed.** BDST Theorem 1 is stated for the uniform cube only. Its setup line says all
probabilities are over uniform x. Girish–Mittal–Nehoran–Raz (arXiv:2609.35327), the "gadget" source,
cover µ_p and products with biases in [a, 1−a]. But they work with error ε and overhead poly(T, 1/ε), and
never track δ. So neither paper supplies a polylog(1/δ) simulation for biased products, and we prove one
here.

**Claim.**

- **Setup:** S(t, d, ε, δ) is a uniform-cube strong simulator for t-query, d-round algorithms; BDST gives
  2^{O(d²)}·(t log(1/δ)/ε)^{O(d)}. P = ⊗p_i is a product law over finite alphabets with margin c.
- **Conclusion:** there is a tree of depth D ≤ S(2mt, 2d, ε, δ) with Pr_P[|f − T| > 2ε] ≤ 3δ, where
  m = log₂(deg/(δc)) + O(1) and deg = (2t + D)·O(log(1/δ)/ε).

**Proof.**

1. **Encoding.** For each coordinate, pick a map g_i: {0,1}^m → Σ_i whose pushforward p'_i satisfies
   |p'_i(a) − p_i(a)| ≤ 2^{−m}, using a binary expansion. Then p' has margin ≥ c/2 once 2^{−m} ≤ c/2.
2. **Quantum algorithm on the encoding.** A' answers each query to x_i by computing g_i(y_block) with m
   parallel queries and then uncomputing. It uses 2mt queries and 2d rounds, and its acceptance
   probability is exactly f(g(y)).
3. **Uniform simulation.** Apply S to A' over uniform y.
4. **Back to x.** Convert the y-tree into an x-tree:
   - when the y-tree queries a bit of block i, query x_i;
   - sample y_block uniformly among the preimages of x_i;
   - fix the random seed by averaging.

   If x ∼ P' = ⊗p'_i, the simulated y is exactly uniform. So Pr_{P'}[|f − T| > ε] ≤ δ.
5. **Rounding by Bernstein.**
   - Let φ be a polynomial of degree O(log(1/δ)/ε) mapping [−1,1] to [0,1], with φ ≤ δ on [−ε, ε] and
     φ ≥ 1 − δ outside [−2ε, 2ε].
   - Then x ↦ φ(f(x) − T(x)) has degree ≤ deg in the one-hot indicators, since a depth-D tree has
     degree ≤ D.
   - Its mean along the segment from p' to p changes by at most (π/4)·deg·2^{−m}/(c/2) ≤ δ, by the
     choice of m.
   - So Pr_P[|f − T| > 2ε] ≤ E_P φ + δ ≤ E_{P'} φ + 2δ ≤ Pr_{P'}[|f − T| > ε] + 3δ'. Here
     δ' = max(δ, the Bernstein term), so 3δ' ≤ 4δ, and rescaling δ gives the claimed bound. ∎

**Margin dependence.** The margin enters this lemma only as **log(1/c)**, through m. The stated GMNR
transfer has block size m ≈ (2/a)·log(·), which is linear in 1/a. The gap comes from using binary
rounding and paying for it with Bernstein instead of exact couplings. This needs an independent check
before it is relied on.

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
