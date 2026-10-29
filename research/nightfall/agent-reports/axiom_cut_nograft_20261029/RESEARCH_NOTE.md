# AXIOM / NIGHTFALL — exact cyclic-cut no-graft obstruction; saturated-anchor affine ceilings

**Date:** 2026-10-29. **Research lead:** Devin J. Wright. **Mathematical development and internal tests:** Axiom (GPT-6). **Assignment:** self-designed issue #109; related #46/#49. **Status:** self-contained restricted theorem and finite exact verification; external novelty/referee **OPEN**. The classical Bose–Chowla relative difference set is antecedent; a standalone first-discovery claim is unwarranted.

## 1. Relative-difference identity

Fix a prime power `q`, choose primitive `theta` in `F_(q²)^×`, set `L=q²−1` and

`S={e mod L: theta^e=theta+t for some t in F_q}`.

The set S has q elements and is a Sidon set **modulo L** (including diagonal sums). Let

`H={(q+1)j mod L: 0<=j<q−1}`, the subgroup of order q−1.

**Theorem A:** The ordered nonzero difference map `(s,t)↦s−t mod L`, `s≠t in S`, is a bijection from ordered distinct pairs onto `G\H`.

*Proof:* Since `S` is Sidon, each nonzero ordered difference occurs at most once (the only potential reverse-order degeneracy would force a nontrivial diagonal pair-sum collision). If `s−t∈H`, the ratio `(theta+u)/(theta+v)=theta^(s−t)` lies in `F_q^×`. Writing `theta+u=c(theta+v)` and comparing independent `1,theta` coefficients forces `c=1,u=v`, contradictory. Thus no difference lies in H. There are `q(q−1)=L−(q−1)=|G\H|` ordered distinct pairs, so each residue outside H occurs exactly once. □

## 2. Exact cyclic-cut obstruction

Let `A` be an integer Sidon prefix containing at least one pair at difference 1 **and** one pair at difference 2 (for example `A={1,2,4,8,13}`). Take a cyclic Sidon block `S⊂Z/LZ` for which ordered differences 1 and 2 both occur, and assume L≥5. For any cyclic shift `c`, represent its elements as ordinary integers `S_c⊂{0,...,L−1}`. For **every integer translation T**, `A∪(T+S_c)` (as a disjoint union) is **not Sidon**: it contains a repeated mixed `A+B` sum. In particular, for Bose–Chowla with q≥3, `1,2∉H`, so the conclusion always applies.

*Proof:* The unique ordered difference-1 pair of S must literally differ by either `1` or `1−L` after rotation. If the literal difference is `1`, two distinct old marks at difference 1 immediately give `a+(T+s_high)=a'+(T+s_low)` with `a'−a=1`. Thus avoiding any mixed collision forces that pair to cross the cyclic cut. In the chosen integer representatives it is the pair `(0,L−1)`.

Similarly, avoiding the old difference-2 collision forces the unique ordered difference-2 pair to cross the cut. Such a pair must be either `(0,L−2)` or `(1,L−1)`. In the first case S contains `L−2,L−1,0`, and `2(L−1)≡(L−2)+0 mod L`. In the second S contains `L−1,0,1`, and `2·0≡(L−1)+1 mod L`. Either is a forbidden nontrivial cyclic Sidon diagonal-sum collision. Therefore at least one old difference is realized as a literal positive integer difference and forces a repeated mixed sum. □

**Sharp converse for a one-difference prefix:** If `A={1,2}` and S has a unique cyclic ordered difference-1 pair, exactly **one** of the L cyclic cuts makes that difference wrap. For any sufficiently large positive translation T to separate old-old, old-new and new-new sum bands, exactly that cut makes `A∪(T+S_c)` Sidon. This sharpens “at most one cut” to exact attainability under the reduced premise.

**General rotation-count bound:** If A has any prescribed positive difference d with `d∈G\H`, `1≤d<L`, the unique ordered cyclic d-pair literally has difference d under exactly `L−d` shifts and `d−L` under exactly d shifts. Thus at most d rotations avoid this *particular* mixed collision. Across an arbitrary prescribed difference set `Δ(A)⊂G\H`, the number of rotations avoiding all mixed collisions is at most `min Δ(A)`. The 1-and-2 theorem improves this to **zero**.

**Strict boundary:** This obstruction concerns retaining **all q marks of one cyclic Bose–Chowla block**. It proves neither that sublinear deletions are impossible, nor a uniform `Ω(q)` repair lower bound, nor failure of nested Sidon constructions or Erdős #44/#329. The result closes the *rotation-only, deletion-free* mechanism and identifies what a successful repair must change.

## 3. Exact finite-field verification and negative control

A standalone Python 3 implementation builds `F_q[u]/(u²−c)` with c a quadratic nonsquare, identifies a primitive theta, reconstructs q Bose–Chowla exponents independently, and checks the entire ordered difference spectrum. For q=17,19,23,29,31 (L=288,360,528,840,960), respectively, **every one of the L cyclic rotations** fails a literal integer pair-sum test for `A={1,2,4,8,13}` and a sufficiently separated translation. Exactly one rotation passes with the sharp two-mark prefix `A={1,2}`. All individual wrap counts for the 10 distinct old positive differences match d exactly. Total rotations examined: `288+360+528+840+960=2,976`; the two prefix evaluations are separate exhaustive checks.

The checker is **finite support**, not a substitute for the universal proof. The two-mark positive control confirms the necessity of the simultaneous 1-and-2 premise. A three-term progression `{L−1,0,1}` breaks modular Sidon and would allow both wrap constraints; the proof explicitly excludes it.

## 4. Primary assignment #46: exact affine-isometry ceiling for two ten-mark anchors

Previously archived saturated 10-mark sets in [1,184] are:

- `S1={16,49,50,56,78,93,104,125,139,149}`.
- `S2={49,50,56,78,93,104,125,139,149,166}`.

A **separate direct unordered-pair-sum oracle** (not relying on the cyclic-difference code) verifies their complete blocker spectra. Their unique contiguous blocked integer intervals that contain all the marks are `S1: [0,187]` and `S2: [0,188]`. Translating by +1 therefore gives inclusion-maximal ten-mark Sidon sets on **[1,188] and [1,189]**, respectively. The sorted latter witness is

`{50,51,57,79,94,105,126,140,150,167}`.

It has exactly 55 distinct pair sums, and **all 179** omitted integers in [1,189] are blocked. Adding 190 is possible (first unblocked point). Any translate or reflection of the same S2 anchor has a blocked interval containing all its marks of length at most 189, hence **none of its affine-isometric copies can establish a ten-mark saturated Sidon set on [1,190]**. This is **a fixed-orbit ceiling**, not a universal #156 exclusion. Likewise S1's ceiling is 188. Current general result `9≤m_sat(184)≤10` is unchanged; the unknown nine-mark decision is untouched. The N189 ten-mark construction is an exact finite upgrade **over the previously reported N184 anchor**, without external extremal priority certification.

## Reproduce and evidence boundaries

```
python3 verify_wrap_barrier.py
python3 verify_anchor_envelope.py
```

Both files use only the Python standard library. `field_receipt.json` lists exact q/L/theta, source block fingerprints, all wrap counts and cut survivors; `anchor_receipt.json` includes both translated sorted witnesses and first addable point. No network, numerical tolerance or randomized solver is involved. SHA-256 records are in `MANIFEST.json`.

**Priority status:** Relative difference sets, primitive finite-field powers, Sidon difference uniqueness and rotation counting are classical ingredients. No comprehensive dated comparison of this 1-and-2 exact no-graft corollary has been completed. Do **not** promote this to an externally novel theorem or a solution of an Erdős problem. Independent Lemnis structural review, Ryev alternate algebraic oracle, and Vesper priority control remain the research gate.
