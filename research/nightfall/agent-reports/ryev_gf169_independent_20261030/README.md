# Ryev independent third-field audit of GF169 sumset-hole decoder

**Date:** 2026-10-30. **Research lead:** Devin J. Wright. **AI verifier:** Ryev. **Construction and parametric family:** Vesper, PR #272, built on Tessera PR #267. **Assignment:** issue #273. **Status:** R1 internal, independent software arithmetic and explicit finite certificates; no human referee or general Lean proof.

## Frozen model and representation

Original oracle in each field K: every reading is the square of one K-linear form, and the only equivalence on signals is **one common global ± sign**. Count every calibration and mixed reading, include zero and sparse signals, prohibit reading an unsquared intermediate value. Distinct fields GF(p²) have distinct oracles; no claim of same-field advancement across different primes.

The checker uses F13[y]/(y²+y+2), irreducible since discriminant 6 is a nonsquare mod 13. The isomorphism from source F13[t]/(t²−2) is t=3+6y; its square is 2. Both ring operations and all 13⁴ ordered source products are checked in this representation. This is a third representation, not one of the two built inside the original producer checker.

## Reproduce

    python3 research/nightfall/agent-reports/ryev_gf169_independent_20261030/verify_third_field.py

The GitHub Actions workflow independently runs the same source and prints its SHA-256. Python standard library only.

## Exact fixtures and adversarial controls

- All 64 binary sums generated independently, 167 pairwise sums, both exact missing elements, 64 legal distinct GF169 squared observations from the theorem coefficients.
- All partial tables for 1–6 signs; all 28,561 k2 inputs including zero; 1,093 k7 canonical support/relative-phase sectors; 12,000 deterministically seeded arbitrary k7 inputs; internal anchor on a support with leading zero coordinates.
- Root and inverse tables reconstructed in the third quotient, not imported from producer output. Zero-anchor and zero-coefficient mutations must cause collisions; wrong isomorphism and unattainable non-square measurement values are rejected.
- For p=13/29/31/61/127 independently generate each four-tile binary cube and nine-rectangle sumset; check the alleged hole. For p<=31 compare the rectangular sumset with brute-force T+T. For each p independently choose an irreducible quadratic quotient and verify every **actual squared** translated output (64,256,256,1024,4096 values respectively) is distinct.
- A finite pass does not prove the quantified d>=2 rectangle lemma, universal all-k decoder, existence of infinitely many eligible primes or global priority.

## Mathematical dependency graph

Odd-characteristic field → distinct binary cube → missing element in its pairwise sumset → translate by −m/2 → antipodal-free points → injectivity after squaring → arbitrary nonzero supported anchor and canonical roots → legal partial-block coefficient absorption → full all-support two-round decoder.

The prime-indexed family additionally requires an all-d argument that the four translated rectangles are disjoint and the nine pairwise rectangles miss the claimed point. The even-extension r=2n product transfer is separate and remains an algebraic assertion subject to mathematical review.

## Prior art and remaining work

The additive subset-sum/cube and Freiman machinery is classical (Tao–Vu, Additive Combinatorics); Alon–Zamir's 2025 Sumsets in the Hypercube concerns a different characteristic-two model and cannot by itself establish this exact powered-oracle priority. A human mathematical reviewer must still assess the symbolic family theorem, general injectivity lemma, adaptive decoder and historical comparison before claim promotion. No external submission, production merge, or website status changes are authorized.

Next formalization milestone: Lean kernel-check the **abstract sumset-hole implication** with explicitly stated odd-characteristic, distinct-sum and no-antipode hypotheses; keep finite 64-state decide and general all-k supported decoder as separate obligations. Do not treat a Boolean enumeration as an all-k theorem.
