# Prior-art check: strong (log 1/δ) bounded-round simulation beyond the uniform cube

Date: 2026-11-19. Sources were read through the arXiv abstract and PDF pages.

## What exists

- **BDST, arXiv:2608.19158.** Theorem 1 is stated only for the **uniform** distribution. It gives
  2^{O(d²)}·(t·log(1/δ)/ε)^{O(d)} queries for t-query, d-round algorithms. The log(1/δ) comes from the
  tail term in their Theorem 7. Conjecture 2 (adaptive, expected query weight) remains open. The
  "Final comments" section announces round-preserving and t^{O(d)} improvements in a companion note.
- **Liu–Mutreja.** Nonadaptive, plus a t^{O(4d)} bound for d rounds. Uniform.
- **Escudero Gutiérrez–Palazuelos–Saucedo.** Nonadaptive rank-r algorithms. Uniform.
- **Girish–Mittal–Nehoran–Raz, arXiv:2609.35327.** The simulation conjecture under the fixed-bias
  product μ_p, and under the slice, is *equivalent* to the uniform conjecture. The reduction uses a
  gadget: a q-biased bit is simulated by g on m p-biased bits.
  - Overhead: S'(T, ε) ≤ S(2mT, ε/2), with m = ⌈(2/a)·log₂(8T/(ε√a))⌉ and a = min(p, 1−p, q, 1−q).
  - Remark 3.5 says it extends to per-coordinate biases in [a, 1−a]; this is not worked out.
  - Rounds, parallelism, δ and log(1/δ) are not addressed. Mixtures and k-ary alphabets are not
    discussed.

## Consequence for the planned target

**BDST combined with the GMNR gadget already almost gives strong d-round simulation for products with
biases bounded away from 0 and 1.** The composition is routine:

1. Compute g, query, then uncompute. This turns d rounds into 2d rounds and t queries into 2mt.
2. The classical side samples gadget bits from the conditional law given y_i.
3. The gadget error is averaged over inputs. Markov's inequality turns it into a pointwise-except-δ
   error at m = O(a⁻¹·log(T/(εδa))).

The result has poly(1/a) overhead and polylog(1/δ) dependence. It is a corollary to note in our paper
and **must not be claimed as new**.

## What remains genuinely open (and fits this repo)

1. **No bias floor.** Biases can be arbitrarily close to 0 (a → 0), which is the sparse-input regime.
   The gadget size m grows like 1/a. Our product-space framework has no dependence on the minimum atom
   probability, but our 1/δ dependence is polynomial.
2. **Mixtures of products (latent sources).** No reduction covers them. For d rounds with log(1/δ),
   the missing piece is a *strong component-identification lemma*:
   - Setting: P and Q are product laws (the conditional components at a leaf), f is a bounded
     multilinear polynomial of degree 2t, f concentrates within ε of v_P under P and of v_Q under Q,
     each except probability δ, and |v_P − v_Q| > 2ε.
   - Claim: a classical decision tree of depth poly(t, 1/ε, log(1/δ)) distinguishes P from Q with
     error O(δ).
   - Heuristic: for products, |f(p) − f(q)| is controlled by the level-1 mass of bounded degree-d
     polynomials, which is O(d) (Chebyshev-tight). So some poly(d/ε) coordinates should carry
     Hellinger mass ≳ log(1/δ).
   - Status: **unproved**.
3. **k-ary alphabets.** These presumably reduce to the binary case through encodings, with the same
   min-atom issue as item 1.

## Recommended order

Start with item 2: prove the component-identification lemma. Then compose it with BDST and the gadget,
running the component trees jointly and querying to resolve posterior-ambiguous leaves. That would give
strong d-round simulation over M-mixtures of products with biases bounded away from 0 and 1. Item 1 is
harder and should be attempted after.
