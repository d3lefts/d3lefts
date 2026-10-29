# Lemnis Sidon #49 — second-pass independent comparison, 970 → 974

**Date:** 2026-10-29. **New source:** [Vesper PR #68](https://github.com/d3lefts/d3lefts/pull/68). **Status:** independent exact finite audit PASS, asymptotic problem OPEN, publication priority OPEN. This addendum supersedes the earlier 970 construction numerically while retaining its frozen source/checkpoint.

## Fully independent alternative-field replay

Using the alternate polynomial presentation `F_1009[t]/(t²−14t+38)`, where `t=7+u` and `u²=11`, `verify_sidon_974_independent.py` reconstructed the complete 1,018,080-element multiplicative cycle, 1009 Bose–Chowla exponent positions, and 509,545 unique modular unordered pair sums. Translation `T=776570` and the 40 indices from the public PR #68 verifier produce 969 new integer marks. The compact JSON digest matches the pinned source `5c7d0e030377f9d441dc1e613a20d0902fe14c84cfccf69b63fc8f5f947bef7d`.

With prefix `A={1,2,4,8,13}`, all 474,825 ordinary integer unordered sums are distinct, split as `AA=15`, `AB=4,845`, `BB=469,965`. Final size **974**, endpoint **1,794,091**. Exact relative gain versus previous finite 970-mark witness:

    974²·1,794,316 − 970²·1,794,091 = 14,164,303,716 > 0.

Each of the **40** excluded source marks has a literal old/new pair-sum collision preventing its individual reinsertion. First witness: excluded 807758 + kept 816087 = kept 2 + kept 1623843. The deterministic 40-row collision-witness SHA-256 is `f3492f77c8cc64d856931b37237566be62fa6d6e16900df4d2738469d3d726a3`.

## Mathematical interpretation and stop rule

The earlier **970** witness was inclusion-maximal *for its fixed translation/source-block deletion*. Changing the block translation, re-solving the hitting set, and independently verifying produces a **strictly better 974 witness**. Thus local inclusion maximality of a deletion output is inadequate as evidence for maximum cardinality, much less an asymptotic barrier. This is a concrete falsifier for any extrapolation of our earlier 44-removal obstruction to other translations.

The 974 witness is a finite example. It provides **no improved uniform lower coefficient** for infinite Sidon sequences and proves neither Erdős #44 nor #329. A full independent review of PR #68's universal-prefix 1/√2 extension lemma is consistent with its classical Bose–Chowla proof: remove at most binom(k,2) old-difference conflicts, translate to separate all mixed pair-sum intervals, and pass to sufficiently rapidly growing primes. The coefficient `1/√2` is an established benchmark; publication priority is unresolved and no new asymptotic gain is claimed.

**Reproduce:** `python3 verify_sidon_974_independent.py`. Fully independent field coordinates, no import of PR #68 source, direct modular and ordinary sums including diagonals, restoration mutations.
