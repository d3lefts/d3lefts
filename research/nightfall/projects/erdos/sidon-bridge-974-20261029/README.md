# Erdős #44/#329 — exact finite Sidon-prefix improvement (29 October 2026)

**Claim class:** independently checked finite construction; **not** a new asymptotic bound, a solution to an Erdős conjecture, or a worldwide finite-size record. External proof referee / novelty review outstanding.

## Verifiable quantitative result

Maintain the prescribed Sidon prefix `A={1,2,4,8,13}`. The prior NIGHTFALL construction in Axiom's [draft PR #55](https://github.com/d3lefts/d3lefts/pull/55) had 970 marks in `[1,1794316]`. This new construction has **974 marks in `[1,1794091]`**, a gain of 4 marks and a decrease of 225 in endpoint.

It has 474825 pair sums, **all distinct** (including diagonals), verified in integer arithmetic by [verify.py](verify.py). The comparison of density ratios is exact:

```
974^2 * 1794316 - 970^2 * 1794091 = 14164303716 > 0.
```

The construction takes a classical Bose–Chowla Sidon block of 1009 residues modulo 1018080, represented as powers of `7+u` in `F_1009[u]/(u^2-11)`. It translates the source residues by **776570**, then removes 40 source indices specified in `verify.py`. Together with the five unchanged prefix marks this gives 974 integers. The verifier independently reconstructs the field source, checks all 509545 modular unordered sums, then checks all 474825 ordinary integer sums and the exact comparison margin.

**Reproduction:** from this directory, execute `python3 verify.py`. Standard library only; no solver required.

## Search mechanism and negative result

The builder reduces all possible mixed sum collisions `(A+B)∩(B+B)` and internal mixed-sum collisions to an integer hitting-set problem. Binary minimum covers were solved by SciPy HiGHS for **5001 explicitly sampled translations** `770000,770002,...,780000`. The top restricted-search witness was `T=776570` with exactly 40 deleted source marks. The solver's objective was rechecked via completely separate integer pair-sum enumeration. A further 8301 deterministic shift trials (seed `2026102902`) provided no stronger coefficient. Neither finite scan establishes a globally optimal translation, nor does a finite optimization improve the infinite Sidon density coefficient.

The full reproducible research bundle (including shift search source, independent mathematical proof, exact JSON certificate, and SHA-256 manifest) is delivered with the 29 October 2026 NIGHTFALL Erdős campaign archive. This repository file is the minimal, dependency-free exact verifier.

## Structural lemma: universal prefix preservation at the known coefficient

Let `A ⊂ [1,N]` be any integer Sidon set, of size `k`. For every sufficiently large prime `q`, a classical Bose–Chowla modular Sidon set `S ⊂ [0,q²−2]`, of cardinality `q`, allows an explicit integer extension `A∪B`, with

```
|B| ≥ q - k(k-1)/2,
max(A∪B) ≤ 2(q²−1)+N−1.
```

**Proof.** Put `v=q²−1>N`. The nonzero differences of `S` are distinct modulo `v`. Each positive difference of elements of `A` therefore coincides with at most one ordinary positive difference of `S`. Delete one endpoint from the (at most `k(k−1)/2`) offending pairs of `S`, giving `S'`. With `T=v+N`, put `B=T+S'`. Then `A+B` is internally unique, since all required cross differences were removed. The `A+A` and `B+B` sums are individually unique by the Sidon hypotheses. Finally, the three sum ranges satisfy `max(A+A)<min(A+B)` and `max(A+B)<min(B+B)` by the choice of `T`; hence `A∪B` is Sidon. The displayed size and endpoint estimates follow. Iterating with primes `q_j` sufficiently fast relative to the current prefix size and maximum produces an infinite Sidon set containing the prescribed finite prefix and with limsup coefficient **at least the already-known `1/√2`**.

**Scope:** This is an elementary explicit consequence of *classical* Bose–Chowla machinery. It is an internally checked proof argument, **without a new asymptotic coefficient and without a novelty claim**. The substantive problem #44 asks for coefficient arbitrarily close to **1**, and #329 asks if the infinite limsup can equal **1**. These remain open, with the known lower coefficient `1/√2` (Krückeberg, 1961).

Sources:
- https://www.erdosproblems.com/44
- https://www.erdosproblems.com/329
- https://github.com/d3lefts/d3lefts/issues/49
- https://github.com/d3lefts/d3lefts/pull/55

**Next transition:** stop same-source shift polishing; seek a representation that yields a uniform-in-q improvement of the coefficient, with rigorous control of mixed collisions and independent review. Publication on the homepage's Original Findings list requires a dated novel mathematical theorem or other separately approved significant evidence; this finite checkpoint does not meet that gate.