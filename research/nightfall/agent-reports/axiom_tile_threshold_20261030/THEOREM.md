# Axiom — sharp two-sided transition for Vesper's four-tile sumset-hole operator

**Date:** 2026-10-30. **Human research lead:** Devin J. Wright. **AI theorem derivation:** Axiom; starting seed and fixed shifts from Vesper PR #272, informed by Tessera PR #267. **Stage:** R1 mathematical proof candidate with exact finite checks; no independent human proof review or global-priority certification. **Parent assignments:** #249, #272, #273.

## Objective, original model, external reference, decisive test

**Objective:** Replace the isolated-prime condition p=4D−3 or 4D−1 by a positive-width prime interval, and rigorously identify why the original four-tile shift recipe cannot cross the lower modulus range.

Let D=2^d (d≥2), p an **odd prime**, G=F_p² the additive group of K=F_(p²). Use *exactly* the sign-square powered-linear oracle y=(a·x)² over K and global ± scalar, with coordinate queries charged. Define

    B=[0,D−1]², I=[0,2D−2],
    v=(2D−1,D+1), w=(−1,D+1) modulo p,
    T=B ∪ (B+v) ∪ (B+w) ∪ (B+v+w).

T is a binary 2d+2-cube: powers 1,2,4,...,D/2 in both coordinates plus v,w, whenever all four D² tiles are disjoint.

**Best previous direct reference:** [Vesper PR #272](https://github.com/d3lefts/d3lefts/pull/272) proved a missing sum m=(2D−2,2D+1) for the exact two endpoint prime forms p=4D−3 and 4D−1; this is previously established NIGHTFALL work, not an Axiom claim. It also contains a separate F169 direct six-phase certificate, k7=8, and an F13 extension-degree transfer. [Tessera PR #267](https://github.com/d3lefts/d3lefts/pull/267) gives a distinct product signed-digit baseline B(p,2); **beating it** is a stricter significance gate than merely proving a new valid tile family.

**External backdrop:** sumset-hole structure, additive cubes, projective sign orbits and translated antipodal-free sets are standard additively/combinatorially motivated objects. See [Karam, *The structure of sets with cube-avoiding sumsets*, Mathematika (2025)](https://doi.org/10.1112/mtk.70041), which studies *different* dense cube-avoiding sumset questions, and classical sumset/finite-field sources cited in PR #272. [Prime Number Theorem](https://isa-afp.org/entries/Prime_Number_Theorem.html) is classical; using it does not create a new theorem about primes. This manuscript supplies **no worldwide novelty clearance**, and no equivalence to Karam's model is asserted.

**Cheapest discriminating test fixed before computation:** Determine whether m remains absent when p moves away from the two original forms, and whether every m has an **off-diagonal** representation below the threshold. Test D=8,16 symbolically and by exact independent pair sums; larger D is regression, not proof.

## Main structural theorem: sharp transition at p=4D−3

### (A) Construction on an entire half-line

For **every integer p≥4D−3** (not just primes), the four tiles are disjoint and the explicit element

    m=(2D−2, 2D+1) modulo p

is *absent* from T+T. Consequently |T|=4D²=2^(2d+2), and for every **prime** p in that interval the existing sumset-hole/translation lemma of Vesper PR #272 yields **one legal squared K-linear observation encoding 2d+2 anchored relative signs**.

**Proof of disjointness.** For D≥8, the three y-bands are [0,D−1], [D+1,2D] (v and w), and [2D+2,3D+1] (v+w); since p≥4D−3>3D+1, they do not wrap and are pairwise disjoint. The two middle-band x intervals [2D−1,3D−2] and {p−1}∪[0,D−2] are disjoint. At D=4 and p≥14 the same argument works; at the only boundary modulus p=13, the last y-band [10,13] wraps at y=0 only, with x∈[6,9], disjoint from the base tile x∈[0,3]. Hence all four tiles are disjoint even there.

**Proof of the missing sum.** Because B+B=I×I, exactly

    T+T = union_{a,b∈{0,1,2}} (a v+b w + I×I).

Group the nine rectangles by n=a+b. At the target y=2D+1, n=0 is impossible (ends 2D−2). For n=2 the raw y band [2D+2,4D] is above y and cannot wrap down to it when p≥4D−3. For n=3 the band [3D+3,5D+1] is also too high to hit y, even after subtracting p, since y+p≥6D−2>5D+1. The n=1 band can hit y, but its two x intervals [-1,2D−3] and [2D−1,4D−3] exclude x=2D−2 modulo p. Only n=4 could additionally hit y for some p up to 4D+1; its sole x interval is [4D−4,6D−6], which excludes 2D−2 modulo any p≥4D−3 because (2D−2)+p≥6D−5. Thus m is absent. This proof holds **without an upper bound on p**, though competitiveness decreases as p grows. QED.

**Positive-width prime intervals (unconditional existence in the asymptotic sense):** For every D=2^d, d≥2, **every prime p∈[4D−3,5D]** works. These intervals have length D+3, rather than the two isolated endpoints. Standard PNT implies for sufficiently large d,

    #{p prime:4D−3≤p≤5D} ~ D/log D,

so this supplies infinitely many valid primes with growing D **without requiring the unproved infinitude of primes exactly 4·2^d−3 or −1**. In fact the construction works for *all* primes p≥4D−3, not only that slice. This is a field-family validity statement, **not a claim of capacity optimality across the interval**.

### (B) Exact obstruction to this very tile class in a positive-width lower interval

Assume **D≥8** and **3D+2≤p≤4D−4** (any integer p; primality is unnecessary for the additive statement). The same four tiles are disjoint, yet:

    EVERY m∈(Z/pZ)² is a sum u+v of DISTINCT u,v∈T.

In particular the **off-diagonal** sumset is all of G. Therefore no translation of this exact T can make the squaring map injective on its 4D² points when p is prime and K=F_(p²). This is strictly stronger than "the chosen hole m fails": **every possible offset fails** for this prescribed weight family. It is **not** a universal impossibility of 2d+2 phase packing for those fields via different coefficients.

#### Symbolic coverage proof with off-diagonal witnesses

Write p=4D−t, 4≤t≤D−2. The n=0,...,4 y-bands of the nine rectangles are

    Y_n = [n(D+1), n(D+1)+2D−2] mod p.

For n=2, its three x intervals are

    [-2,2D−4], [2D−2,4D−4], [4D−2,6D−4] mod p.

Together they cover **every x residue**: their only two gaps on the integer line are 2D−3 and 4D−3; the former gains a representative after adding p in the last interval, and the latter after subtracting p in the first. More importantly, every x has a **distinct-point representation** in n=2, uniformly in the local y∈I:

* The middle (a,b)=(1,1) x interval is
  J=[2D−2,p−1]∪[0,t−4] and represents a sum of points from the distinct v and w tiles.
* For x outside J, necessarily x∈[t−3,2D−3]. If x=t−3 or t−2, use the a=0,b=2 tile-pair rectangle x shift −2; its local x sum is t−1 or t, respectively, strictly between 0 and 2D−2. If x∈[t−1,2D−3], use the a=2,b=0 rectangle x shift 4D−2 ≡t−2 modulo p; its local x sum lies in [1,2D−t−1]⊂[1,2D−3]. In all these cases the local x sum is interior to I, hence has at least **two distinct decompositions into [0,D−1] summands**. Thus every x in Y_2 has an off-diagonal representation.

The n=2 y-band covers [0,t]∪[2D+2,p−1] modulo p. All other y values lie in [t+1,2D+1]. Split this complementary interval into three disjoint pieces:

**Piece A:** y∈[t+1,D]. Both n=0 and n=3 are active: n=3's wrapped y-band ends at D+t+1. The n=3 x intervals [2D−3,4D−5] and [4D−3,6D−5] cover all x except x=4D−4−p=t−4. Every n=3 representation uses two *different* tiles (v+w and w+v shifts of different multiplicities), so distinctness is automatic. At missing x=t−4, n=0 covers x∈[0,2D−2], and local y∈[t+1,D]⊂[1,2D−3] is interior; hence a distinct-point decomposition exists.

**Piece B:** y∈[D+1,D+t+1]. Both n=1 and n=3 are active. The two n=1 x intervals [-1,2D−3] and [2D−1,4D−3] cover all x except x=2D−2; the n=3 intervals omit only x=t−4. These two exceptional x values differ; their union covers all x, using distinct tiles in either n=1 or n=3.

**Piece C:** y∈[D+t+2,2D+1]. Both n=1 and n=4 are active. n=1 covers every x except 2D−2. The n=4 x interval [4D−4,6D−6] contains x=2D−2 modulo p because x+p=6D−t−2 belongs to it. The local n=4 y sum is y−(t+4), which lies in [D−2,2D−t−3]⊂[1,2D−3]; hence even this same-tile representation admits two **different** summands.

All y and x values are covered by an off-diagonal T+T representation. QED. The argument holds for composite moduli too (an additive-group assertion); only the subsequent field-square recovery interpretation requires prime p.

### (C) Sharpness and limits

The thresholds match at adjacent integers: at p=4D−4 the **off-diagonal** sumset is all G; at p=4D−3 the explicit m is absent from even the full T+T. The tile operator therefore undergoes a **sharp additive-combinatorial phase transition** at exactly 4D−3, valid at every D≥8. D=4 is excluded from the lower-range obstruction because the interval [3D+2,4D−4] is empty.

The construction at **prime** p=4D−3 or 4D−1 reaches the information-theoretic maximum **2d+2 signs** (already Vesper's prior endpoint result). For **p≥4D+1** it remains valid, yet the existing product signed-digit method of Tessera PR #267 typically packs **2d+3 signs** for p in [4D+1,8D−1], so the extended four-tile validity is *not* a better capacity record there. Do **not** present the positive-density prime interval as a family of new capacity optima, a same-fixed-field gain, or proof that no alternative tile/linear row can improve a negative instance.

This is the requested **field-family generalization plus narrowly exact structural no-go**. The broad significance and historical novelty of these elementary rectangle arguments remain OPEN.

## Exact checker contract and falsifiers

[check_tiles.py](check_tiles.py) requires Python 3.12 standard library only. Independent algorithms reconstruct the binary tile geometry and nine rectangle sumset, compare brute unordered pair sums, and (in negative-range samples) brute *distinct* pair sums, without invoking PR #272 producer source. Positive prime cases directly compute squared values in Fp[t]/(t²−δ) for the first nonsquare δ; negative controls corrupt the hole and compare adjacent moduli, including composite moduli only as finite abelian groups.

Coverage:
- **Negative whole integer ranges:** all p=26,27,28 for D8, and all p=50,...,60 for D16. Direct off-diagonal pair enumeration for D8 all p and D16 p53,59,60; D32 p101 with independent 8-million-pair enumeration. Additional D32 edge controls p98,101,113,124.
- **Positive ordinary primes:** D4 p13/17/19/23; D8 p29/31/37/41/43; D16 p61/67/71/73/79; D32 p127/131/137; D64 p257/263, with 64 to 16,384 exact squared codewords each. Both original endpoint primes and **off-endpoint primes** verified.
- The accepted proof is symbolic, not extrapolated from those primes; complete p count limited to small parameters. False hole at D16,p59 must be detected.

**Independent audit requests:** Lemnis attack the off-diagonal coverage, including corner sums, y-band wraps and D8 edges. Ryev implement independent modular interval and field-square code, ideally use Lean for a restricted tiling lemma. Vesper compare against published additive-cube sumset structure, ensure owner/site scientific gates and credit the earlier endpoint theorem. The formula is elementary; no dated academic source has yet certified historical originality for its exact sharp threshold.

## Discovery graph

Existing binary tiled six-sign construction (Vesper) → mod-p rectangle sumset → threshold variable t=4D−p → nine-rectangle projection → every-value off-diagonal coverage below threshold → explicit missing-sum witness above threshold → full positive-width prime families by PNT → nonoptimality warning against Tessera product baseline → independent exact checker → request external mathematical/prior-art review.

**Stop rule:** Do not anneal coefficients; no solver or provider spending. If one independent counterexample to the symbolic interval formula appears, demote the affected theorem and preserve counterexample. No merge/publication/site promotion pending non-author proof review and human owner authorization.
