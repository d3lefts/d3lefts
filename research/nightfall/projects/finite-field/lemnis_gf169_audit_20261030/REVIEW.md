# LEMNIS — Independent sumset-hole adversarial audit and complete six-hole theorem

**Date:** 2026-10-30. **Assignment:** Vesper #273; producer PR #272. **Auditor:** Lemnis (AI role; not an independent human mathematical referee). **Research lead:** Devin J. Wright. **Stage:** R1 internally proved/coded; historical priority and external review unresolved.

## Audit target and model freeze

Producer: one allowed measurement is `(a·x)^2` over a finite field `K`, coefficient row `a` may depend only on previously observed squared readings, all measurements including k coordinate squares count, recover every `x` modulo one global sign. The additive precursor concerns only `G=(Z/qZ)^2`, which has a field interpretation for the specific prime `q=p`; **the composite-q additive extension is not a field-powered oracle construction**.

### Exact finite results independently reimplemented

1. In the different GF169 representation `u=t+1`, `u^2=2u+1`, six binary generators `w=(1,t,2,2t,7+5t,12+5t)` have 64 distinct subset sums, 167/169 pair sums, missing **exactly** `(6,9),(12,4)` in the original `(1,t)` coordinates. The specified mixed row `(8+2t;7,7t,1,t,10+9t,6+9t)` yields 64 different *legal squared* readings, including all 6-sign zero-output checks.
2. Independent all-support replay reconstructs all `169^2=28,561` two-coordinate signals, **every 126** nonempty partial-block sign assignment for b=1..6, and 12,000 seeded 7-coordinate signals. It never queries an unpowered amplitude. It handles the zero signal and root representative normalization explicitly.
3. Independent literal binary tile plus full pair-sum verification at p=13,29,31,61,127; p=509 uses disjoint tile + all nine Minkowski rectangle checks to avoid 4B redundant pairs. All sumset complements equal the exact symbolic theorem below. Composite `q=63,125,253,255,511` also checked via exact nine-rectangle union. All outcomes use Python integers, no tolerances.

## New quantified strengthening: *complete* six-hole theorem

Let `D=2^d >=8`, let `s ∈ {1,3}` and **q=4D-s be any odd integer** (primality is unnecessary here). Work in `G=(Z/qZ)^2` and define

- `A={0,...,D-1}^2`;
- `v=(2D−1,D+1)`, `w=(−1,D+1)`;
- `T=A ∪(A+v)∪(A+w)∪(A+v+w)`.

Then `|T|=4D²=2^(2d+2)` and **exactly six** elements of `G` are *not* in `T+T`:

```
G \ (T+T) =
   {(2D−2, 2D−1), (2D−2,2D), (2D−2,2D+1)}
 ∪ {(4D−4, s+1), (4D−4,s+2), (4D−4,s+3)}
```

In particular `|T+T|=(4D−s)^2−6`. **For D=4, q=13 the exceptional complement has only two elements** `((6,9),(12,4))`, so the six-hole formula is *false* at this boundary. Also `(6,7)∈T+T` at D=4. This boundary issue is explicitly protected by a negative test.

### Elementary complete proof (five horizontal fibers)

Write `L=2D−2` and `I={0,...,L}`. The nine translates of `I×I` from the four-tile sum are indexed by `a,b∈{0,1,2}`. For each `n=a+b=0,...,4`, union their x intervals into `X_n⊂Z/q`, and let their shared y interval be `Y_n=[n(D+1),n(D+1)+L] mod q`. Then

`T+T = ∪_(n=0)^4 (X_n × Y_n)`.

For every `D≥8`, direct interval arithmetic modulo q (including wrap) gives:

```
X0 = [0,L]
X1 = (Z/q) \ {a},  a=2D−2
X2 = Z/q
X3 = (Z/q) \ {b},  b=4D−4
X4 = [0,2D+s−6] ∪ [q−(4−s),q−1]
```

In particular `a ∈ X0` yet `a ∉ X4`, and `b ∈ X4` yet `b ∉ X0`. The two exceptional x-coordinates `a,b` are distinct.

The relevant y bands are

```
Y0 = [0,2D−2]
Y1 = [D+1,3D−1]
Y2 = [0,s] ∪ [2D+2,q−1]
Y3 = [0,D+s+1] ∪ [3D+3,q−1]
Y4 = [s+4,2D+s+2]
```

The `Y3` high interval is nonempty because `D≥8`; all endpoints lie in the stated ranges. If `y∈Y2`, then X2=all and the entire horizontal row is filled. All remaining y values form `[s+1,2D+1]`. Partition these into exactly five consecutive intervals; the available full-row horizontal unions are:

| y range | n values guaranteed present | only missing x |
|---|---|---|
| `[s+1,s+3]` | 0,3 | `b` |
| `[s+4,D]` | 0,3,4 | none (X3∪X4=all) |
| `[D+1,D+s+1]` | 1,3 | none (X1∪X3=all) |
| `[D+s+2,2D−2]` | 0,1 | none (X0∪X1=all) |
| `[2D−1,2D+1]` | 1,4 | `a` |

All five intervals are well formed (allowing an empty fourth interval for the smallest D,s); no extra X_n outside the specified union can fill the six claimed holes because y is outside Y2, and direct interval membership excludes the missing x from every Y_n active in the respective extreme intervals. This proves the **complete** complement, not just existence of one hole. Disjointness of the original four D×D tiles follows from their y bands and, for the two same-y tiles, disjoint x intervals; no primality is used. □

### Controlled transfer to fields

When `q=p` is prime, the additive group `F_p²` is the coordinate representation of `F_(p²)` as an F_p-vector space. The binary-tile T has `2^(2d+2)` distinct subset sums and a missing `m`, so translate by `−m/2`. The resulting coset has no opposite pair; the square map is injective there. This yields a genuine **one legal squared K-linear observation packing 2d+2 relative signs** and matching the one-query alphabet capacity for `p=4D−3 or 4D−1`. When `q` is composite, this additive result alone does **not** define the same square-field oracle. Do not conflate the two.

### Exact hole-amplification transfer

For **any finite abelian groups** `G_i` and sets `T_i⊂G_i`, the sumset of their Cartesian product is exactly the Cartesian product of sumsets:

`(T_1×...×T_n)+(T_1×...×T_n) = (T_1+T_1)×...×(T_n+T_n)`.

For n copies of the D≥8 tile, the complement therefore contains exactly `q^(2n)−(q²−6)^n` points, and the product binary cube has `2^((2d+2)n)` distinct subset sums. This is a count of additive holes, **not** a new globally optimal one-query bound for extension fields. For p13,D4 the exact analogous formula is `169^n−167^n`.

## Off-diagonal necessity attack and smallest independent control

The sufficient condition `T+T != G` is not necessary for a translation to permit squared-output injectivity: the exact iff is a hole in the **off-diagonal** pair-sum set `{u+v : u,v∈T,u≠v}`. The tiny example `G=Z/7Z, T={0,1,2,3}` is a two-generator binary cube from weights `(1,2)`; it has `T+T=G`, yet off-diagonal pair sums omit `0,6`. Choosing `m=6`, `c=−m/2=4`, the translated set `c+T={4,5,6,0}` meets every ± orbit exactly once (including zero) and its four squares are distinct. Thus the stronger full-sumset-hole hypothesis is genuinely only sufficient. This toy example is **classical elementary arithmetic**, not claimed a new theorem.

## Audit verdict / scope / reproduction

**Internal mathematical verdict: PASS** for the GF169 six-phase row and all-support algebraic decoder, subject to human specialist review; **PASS** for the new complete six-hole theorem with proof above and independent scripts; **FAIL** for extending the alternative hole `(2D−2,2D−1)` to D4; **INCONCLUSIVE** worldwide novelty. The original PR #272 claims the correct hole `(2D−2,2D+1)` and is not refuted. Its parametric prime restriction remains proper for the field interpretation.

Run:

```sh
python3 independent_tiles.py
python3 independent_f169.py
```

No imports from original source. The scripts include actual pair-sum checks up to D=32, finite nine-rectangle checks at D=128, alternate-field exhaustive 64-state reads, 28,561 k2 signals, 126 partial messages and 12,000 seeded k7 signals. The general field decoder is proved symbolically, not by impossible exhaustive enumeration of `169^7` signals.

**Closest prior art (dated quick check 2026-10-30):** Kemper–Lopatin–Reimers (2022), finite-field separating invariants (general polynomial orbits, different restricted oracle); Gao–Zhang (arXiv 2610.37136, 2026) on additive bases of finite abelian groups (different coverage objective); Han–Ren (arXiv 2610.14496, 2026) on restricted sumsets (different sumset definition). Classical dissociated subsets, sumset covering, additive rectangles and complement property have to be credited. This is **not** a full same-scope global priority clearance; no website flag or publication promotion.

**Cheapest next decisive transfer:** isolate a symbolic group-theoretic theorem specifying when binary tile product plus one extra coupling generator adds one phase beyond naive product capacity, preserving a hole, across *all even extension degrees*. Record exact proof and independent non-author challenge before claiming improved global field-family state.