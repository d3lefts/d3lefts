# Direct one-sided hybrid transfer: uniform bits to arbitrary finite product laws

**Date:** 2026-11-19. **Status:** author-side complete *paper-level* argument, relying on the standard quantum hybrid theorem and published BDST uniform-input theorem. Not checked in Lean as a coherent quantum algorithm; not independently refereed; not a novelty claim.

## Theorem to be formalized

Let `A` be a `t ≥ 1` query, `r ≥ 1` round quantum algorithm with a coherent finite-symbol value oracle, and let `f(x)∈[0,1]` denote its acceptance probability on `x∈∏ᵢΣᵢ`. Let `P=⊗pᵢ` be *any* known product law with `max|Σᵢ| ≤ s`, `s≥2`, **allowing zero atoms**. Fix `ε,δ∈(0,1)`. Write `S_BDST(T,R,e,a)` for the depth bound in BDST Theorem 1 on uniform Boolean seed bits.

Then a deterministic classical symbol-query decision tree `T_P` exists satisfying

- `Pr_{X∼P}(|T_P(X)−f(X)|>ε)≤δ`;
- worst-case original-symbol query depth `≤ S_BDST(2 m t,2r,ε/2,δ/2)`;

where

`m = ceil(log₂(256 s² t²/(ε²δ²)))`.

Thus `m=O(log(st/(εδ)))` uniformly in the minimum nonzero atom probability, and, using BDST's bounded-round bound, the depth is `2^{O(r²)} (t log(st/(εδ)) log(1/δ)/ε)^{O(r)}` (the `O(r)` exponent absorbs the doubled round count).

## Proof

**1. A one-sided dyadic law.** For coordinate `i`, select an anchor symbol `a*=argmax_a pᵢ(a)`, hence `pᵢ(a*)≥1/|Σᵢ|`. Let `N=2^m`. For `a≠a*`, put `qᵢ(a)=ceil(N pᵢ(a))/N`, and assign all remaining probability to `qᵢ(a*)=1−∑_{a≠a*} qᵢ(a)`. The selected `m` satisfies `N≥s(s−1)`, so `qᵢ(a*)≥ pᵢ(a*)−(s−1)/N≥0`. All `qᵢ` are probability vectors with denominator `N`.

**2. Coupling with a conditional coordinate mismatch bound.** Couple `Xᵢ∼pᵢ`, `Yᵢ∼qᵢ` by preserving every nonanchor `Xᵢ=a` and, conditional on `Xᵢ=a*`, moving mass `qᵢ(a)−pᵢ(a)` to each `a≠a*`; the remaining anchor mass stays put. This coupling has the claimed marginals and for **every** possible `Xᵢ` gives

`Pr(Yᵢ≠Xᵢ | Xᵢ)≤s(s−1)/N≤γ,  γ:=s²/N≤(εδ/(16t))².`

Choose the couplings independently for all coordinates, conditional on `X`.

**3. Direct quantum hybrid, avoiding any event smoother and fixed-point calculation.** Let `w_{k,i}(x)` be the query weight on input `x` immediately before quantum query `k`. Thus `w_{k,i}(x)≥0` and `∑ᵢw_{k,i}(x)=1`. The standard quantum hybrid argument and measurement contraction give

`|f(x)−f(y)| ≤ 4∑_{k=1}^t (∑_{i:xᵢ≠yᵢ} w_{k,i}(x))^{1/2}.`

For fixed `X=x`, the query weights are deterministic. By conditional mismatch and Jensen,

`E_{Y|x}|f(x)−f(Y)| ≤ 4t sqrt(γ) ≤ εδ/4.`

Averaging over `X∼P` and applying scalar Markov at threshold `ε/2` shows

`Pr(|f(X)−f(Y)|>ε/2)≤δ/2.`

This works for arbitrarily small and zero atoms; no bounded-degree Bernstein/Markov interpolation or smoothing polynomial is used.

**4. Uniform seed lifting.** Each dyadic marginal is realized by `Yᵢ=gᵢ(Uᵢ)` with `Uᵢ` a uniform block of `m` bits. The original coherent symbol value oracle can be replaced by fetching the `m` bits of `Uᵢ` in one parallel bit-query round, applying the reversible value-oracle update `z↦z⊕gᵢ(Uᵢ)`, then uncomputing the seed fetch in a second round. Hence the lifted algorithm on uniform Boolean seeds uses `≤2mt` bit queries and `≤2r` rounds.

Invoke BDST Theorem 1 to obtain a uniform-seed classical simulator `B(U)` of worst-case query depth `S_BDST(2mt,2r,ε/2,δ/2)` satisfying

`Pr_U(|B(U)−f(g(U))|>ε/2)≤δ/2.`

**5. Simulate seed queries from the original symbol input.** Given `Xᵢ`, sample `Yᵢ|Xᵢ` using the coupling above, then sample `Uᵢ|Yᵢ` uniformly from `gᵢ^{-1}(Yᵢ)`. Cache the full block for every later seed query. Under `X∼P`, each `Uᵢ` has exactly the uniform distribution on `{0,1}^m`, and the blocks are independent. Any adaptive seed-bit decision tree is therefore simulated exactly in law, using **at most one symbol query per previously unseen block**, so the original-symbol query depth does not exceed B's bit-query depth.

By the two error events and the union bound,

`Pr(|B(U)−f(X)|>ε)≤δ.`

Finally, average over the internal sampler's randomness and fix a single nonuniform random tape achieving at most the same error under P. This yields a deterministic symbol-query tree. Its branches can depend on the known component law and on fixed nonuniform advice; no claim about time complexity is made.

## Independent adversarial replay

`conditional_seed_exact_check.py` tests the full finite coupling and conditional uniform-seed identities with `fractions.Fraction`. The exact-head CI run for PR #895 passed **272** cases, including point masses and sparse laws. These tests confirm algebraic sampling identities but do **not** certify coherent oracle substitution or the quantum hybrid inequality.

## Certification boundaries

- **Lean-certified on PR #895:** finite weighted Markov, likelihood-optimality, rounding mass bounds, and other finite supporting steps.
- **Mathematically external:** BDST Theorem 1 (uniform Boolean, bounded rounds); BBBV/BDST standard quantum hybrid estimate, adapted to symbol alphabets.
- **Still needing source-level Lean:** the finite-alphabet quantum oracle and its two-round seed simulation; query-weight hybrid; construction and derandomization of the seed-sampling tree. These are **theorem-level gaps**. No general quantum algorithm formalization is imported here.
- **Not claimed:** full certified strong mixture simulation or novel contribution; the mixture composition additionally needs its own end-to-end Lean bridge.

**Source checked:** Blanc, Docter, Strassle, Tan, *Quantum Speedups Require Structure or Depth*, arXiv:2608.19158v1, Theorem 1, Section 5 and Appendix B.
