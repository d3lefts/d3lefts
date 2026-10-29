# RYEV / NIGHTFALL — Sharp three-grid obstruction for interleaved F25 phase retrieval

**Research lead:** Devin J. Wright. **Derivation and arithmetic proof:** Ryev (GPT-6), 29 October 2026.
**Status:** Analytic proof and two exact independent checking representations pass internally. External mathematical refereeing and full same-model priority review remain open.

## Main result

Consider F25-linear measurements (a·x)^4 of arbitrary x in F25^5, adaptive across queries, with equivalence x~ωx for ω∈F5*. Axiom previously proved an adaptive universal 9-query upper bound. Vesper previously excluded 8 queries when all five coordinate powers are measured first.

**New sharp theorem.** Any universal 8-query protocol having the rank schedule

    3 independent rows → 1 row in their span → 2 rank-increasing rows → 2 arbitrary rows

must fail. The rows may depend on previous outputs. Furthermore, an explicit adaptive 9-query decoder works for every signal while following

    3 independent → 1 dependent → 2 independent → 3 further rows.

Thus the sharp minimum within this interleaved architecture is **9**. Unlike the earlier coordinate-first exclusion, the first dependent phase measurement genuinely occurs before all signal magnitudes are known.

This is a structural restriction on 8-query protocols; it is **not** the universal k=5 8-versus-9 theorem. The unrestricted problem remains OPEN.

## New elementary 48-to-9 geometric lemma

Identify F25 with the two-dimensional F5 vector space. For arbitrary vectors U,V and centers c1,c2,c3 in F5², examine the multiset of 48 vectors

    { c_i + sU + tV : i=1,2,3, s,t∈F5* }.

A symbol means zero or one of the six F5-projective directions; exactly seven symbols exist. **At least nine of the 48 vectors have the same symbol.** This is sharp, achieved by U=(1,0), V=(0,1), centers (0,0),(1,1),(1,2), with seven bucket sizes [2,6,9,9,8,8,6].

### Complete analytic proof

For linearly independent U,V, apply an F5-linear invertible change of coordinates to make them e1,e2. This permutes all six projective symbols bijectively. Each of the three 16-point grids is the entire F5² plane with the horizontal and vertical affine lines through its center removed.

Classify centers by both coordinates nonzero (T), exactly one nonzero (A), and both zero (Z); T+A+Z=3. For each of the four non-axis directions r∈F5*, the total point multiplicity is

    N_r = 2T + 3A + 4Z + number of both-nonzero centers with slope r.

The horizontal projective direction has multiplicity 3T+4 A_x, where A_x counts centers on the vertical axis with nonzero y. The vertical direction has 3T+4 A_y analogously.

If T=3, the horizontal direction already has 9. If T=2,A=1,Z=0, one axis direction has 3·2+4=10. All other possibilities have non-axis baseline B=2T+3A+4Z at least 9, except cases B=8 with T≥1; in those, one of the T generic centers adds 1 to its own non-axis slope, so the maximum again reaches 9.

For rank-one (U,V), write U=aW and V=bW over F5. If a and b are both nonzero, each center's grid covers all five points of an affine line parallel to W, with multiplicity four at one point and three at each other. If an affine line passes through zero, at least 12 vectors share the direction W; otherwise all three lines meet each of the five nonparallel projective directions at multiplicity at least three, giving at least 9 in each such direction. If exactly one of a,b is nonzero, each grid covers four affine-line points with multiplicity four. A line through the origin yields at least 12 nonzero vectors on W; otherwise three sets of four directions among the same five possible nonparallel directions give at least ceil(12/5)·4=12 on one direction. Rank-zero gives 16 copies of a center. QED.

Because a^4=b^4 for nonzero a,b∈F25 precisely when a/b∈F5*, the seven projective symbols coincide exactly with fourth-power outcomes. An arbitrary F5-linear transformation need not be F25-linear, yet still permutes answer symbols; it is legitimate here for counting bucket sizes.

## Proof of the eight-query obstruction

Fix a reachable branch where the first three rank-increasing measurements have nonzero fourth-power readings. Their F25-linear forms are coordinate variables. Their unknown relative fourth roots, modulo global F5* phase, are 4²=16 distinct possibilities. The fourth row is in their span and has at most seven outputs, so an adversarial fourth answer retains at least ceil(16/7)=3 relative-phase states.

Fix nonzero fifth and sixth readings. Since these two rows increase rank from three to five, each old phase state can be extended independently by four fourth roots for each of the two new coordinate readings. There are at least 3·4²=48 distinct global-phase classes with the same first six outputs.

The seventh row evaluates on these classes as c_i+sU+tV for three old states and s,t∈F5*. The three-grid lemma forces at least nine classes to agree on its fourth-power output. The eighth row has just seven possible outputs. It cannot distinguish nine candidates. Contradiction. The proof is valid with signal-adaptive row choices because the adversarial branch fixes each earlier output before the next row is chosen.

## Constructive nine-query upper bound in this same schedule

Start with readings e1,e2,e3. If any reading is zero, set fourth row to zero (dependent), then read e4,e5. At most four coordinates are active, so Axiom's one-extra-reading-per-active-coordinate phase synchronizer takes at most three further queries, giving at most nine total.

When the first three are all nonzero, choose known fourth roots α1,α2,α3 and take the fourth row

    (α1^−1, θ α2^−1, (1+θ) α3^−1, 0, 0), where θ²=2.

The relative phases (1,z2,z3), z2,z3∈F5*, yield seven response buckets of sizes [1,3,3,2,2,2,3]. Measure e4,e5 next. One seventh row supported on the first three coordinates distinguishes the at most three remaining phase configurations: for two distinct normalized candidates, a uniform random F25³ row collides with probability 97/625. With at most three candidate pairs the union bound is 3·97/625<1. Thus a separating row exists and can be chosen deterministically from all 25³ rows. One additional Axiom phase synchronization query for each nonzero fourth/fifth coordinate finishes recovery. Total 3+1+2+1+2=9. All-zero and sparse cases were addressed separately. QED.

## Exact independent audit and novelty boundary

- Direct arithmetic in F5[θ]/(θ²−2) and an independent closed-form projective-line formula check all C(27,3)=2925 unordered translation-center triples for each of four rank patterns. Minimum largest output bucket sizes: rank2 9, rank1 with both active 10, rank1 with one active 12, rank0 16.
- The explicit nine-query decoder passes all 256 full-support normalized phase patterns, 3000 seeded random F25^5 signals, and all 32 binary support patterns (exact arithmetic).
- The general concept of adaptive phase retrieval predates this project: Charikar–Wu–Ye, Adaptive Discrete Phase Retrieval (SOSA 2020), DOI 10.1137/1.9781611976014.9, studies complex magnitude-squared models. The precise finite-field schedule is different; a comprehensive priority check remains to be performed.
- This work credits Axiom's nine-query upper and Vesper's coordinate-first eight-query obstruction. It is a new internal architecture theorem, not an accepted external discovery, universal lower bound, or iid nonadaptive result.

Run the associated Python standard-library scripts and retain their output. The paper's mathematical proof is independent of their finite exhaustive checks.


## Generalization — an infinite family of sharp prime-field incidence theorems

**Prime-family theorem.** For every prime p≥5, any U,V,c1,c2,c3∈F_p², the 3(p−1)² indexed vectors c_i+sU+tV with i=1,2,3 and s,t∈F_p* contain at least **3(p−2)** instances in one of the p+2 zero/projective-line classes. This constant is best possible.

### Proof

When U,V span F_p², normalize them to e1,e2 with GL2(F_p). Classify centers into T with both coordinates nonzero, A with exactly one coordinate nonzero, and Z at zero, where T+A+Z=3. Along each of the p−1 non-axial projective directions of slope r∈F_p*, the total occupancy equals

    N_r = (p−3)T + (p−2)A + (p−1)Z + n_r,

where n_r counts generic centers of slope r. On the horizontal and vertical directions respectively the counts are (p−2)T+(p−1)A_x and (p−2)T+(p−1)A_y.

The common diagonal baseline is 3(p−3)+A+2Z. We need a line with at least 3(p−2)=3(p−3)+3 states. If T=3, the horizontal direction has exactly 3(p−2). If T=2,A=1,Z=0, one axial line contains 2(p−2)+(p−1)=3p−5, strictly above the target. For all remaining combinations, either A+2Z≥3, making every diagonal line sufficient, or A+2Z=2 and T≥1, so some generic center contributes n_r≥1 and one diagonal reaches the target. This proves the rank-two case.

If U,V span one F_p-direction W and both are nonzero, the scalar sum as+bt (s,t∈F_p*) attains zero in p−1 ways and each nonzero scalar in p−2 ways. Each translated grid lies on an affine line parallel to W. If that line passes through the origin, at least (p−1)(p−2)≥3(p−2) contributions are nonzero on W. Otherwise each of the p projective directions distinct from W occurs at least p−2 times for each of the three grids, giving 3(p−2).

If exactly one of U,V is nonzero, each grid is p−1 copies of each of p−1 affine-line points. A line through the origin gives at least (p−1)(p−2) in direction W. Otherwise each grid occupies p−1 of the same p nonparallel directions. Across three grids, some direction occurs in at least ceil(3(p−1)/p)=3 grids, with multiplicity at least 3(p−1)≥3(p−2). If both U,V vanish, one center is repeated (p−1)²≥3(p−2) times. All cases cover every p≥5.

**Sharpness:** choose U=e1, V=e2 and c1=(1,1), c2=(1,2), c3=(1,3). Their coordinates are nonzero and their slopes are distinct for all p≥5. Every axial direction has exactly 3(p−2) states. Each non-axial direction has at most 3(p−3)+1<3(p−2); the zero class has 3. Hence the maximum is exactly 3(p−2). QED.

### New prime-family adaptive consequence

Work in F_(p²), exponent p−1, global phase F_p*, k=5, and the same adaptive rank schedule 3 independent / 1 dependent / 2 independent / 2 arbitrary. Every powered query has exactly p+2 possible outputs: zero and the (p+1) one-dimensional F_p-subspaces of F_(p²).

After three nonzero basis readings, there are (p−1)² independent relative-phase possibilities. The fourth dependent query has at most p+2 values. Since (p−1)²>2(p+2) for every prime p≥5, some fourth-output bucket contains at least three old-phase candidates. The fifth and sixth independent readings, fixed to nonzero values, introduce two free F_p* phase factors, producing at least 3(p−1)² candidate classes sharing six observations.

The seventh query reduces on three of those old candidates to the generalized three-grid lemma. At least 3(p−2) candidates share its output. But 3(p−2)>p+2 for all p≥5, so the final eighth query cannot separate them. Thus **all such eight-query adaptive protocols fail for every prime p≥5**. QED.

The nine-query *sharpness for the same schedule* has been constructed and exactly tested for p=5. For arbitrary p, Axiom's nine-query adaptive upper bound applies in a different two-stage coordinate-first architecture; the same-schedule nine-query upper is asserted here only for p=5.

**General-prime executable spot checks:** check_prime_family.py exhaustively checks all 2,925 unordered centers for p=5 and 20,825 for p=7 using the closed projective-direction formula, and checks an explicit sharpness witness at p=11,13,17,19. The analytic proof above covers every p≥5 independently of this finite audit.


## Exact unrestricted adaptive optimum in dimension five for all primes p≥7

**Corollary (sharp global measurement complexity).** Let p≥7 be any prime. In the unrestricted adaptive sensing model over F_(p²), with measurements (a·x)^(p−1) and recovery modulo global F_p* phase, the **minimum worst-case number of measurements to recover all x∈F_(p²)^5 is exactly nine**.

**Upper bound:** Axiom's previously established deterministic adaptive protocol uses k coordinate readings followed by at most k−1 one-coordinate phase-sync readings for any k; with k=5 this is 9. It works for F_(p^r), r≥2, and in particular for the current F_(p²).

**Lower bound:** Every powered output is one of exactly p+2 possibilities: zero plus p+1 nonzero F_p-projective directions. A depth-eight adaptive decision tree can distinguish at most (p+2)^8 different transcripts, regardless of how its sensing rows depend on preceding outputs. The number of signal equivalence classes is

    N(p) = 1 + (p^10−1)/(p−1) = 1 + Σ_(j=0)^9 p^j.

For every p≥7, N(p)>(p+2)^8. One explicit *exact integer certificate* uses t=p−7≥0. Expanding gives

    N(7+t)−(9+t)^8 =
       4,032,488
       + 21,145,725 t
       + 18,454,080 t²
       + 7,608,378 t³
       + 1,839,258 t⁴
       + 281,982 t⁵
       + 27,966 t⁶
       + 1,749 t⁷
       + 63 t⁸
       + t⁹.

All coefficients are strictly positive. In particular N(7)=47,079,209 and 9^8=43,046,721. Thus eight queries fail even with completely unrestricted adaptivity, and Axiom's nine-query upper bound is optimal. QED.

**Interpretation and novelty:** This global sharp classification is a new *deduction from Axiom's previously established all-prime adaptive upper bound* and the elementary decision-tree lower bound, not a claim that an entirely novel deep mathematical tool is needed for p≥7. The genuinely open k=5 case under this family is p=5; the sharp three-grid theorem above strengthens its architecture exclusions. The exact counting corollary resolves all primes p≥7 within the stated family, without settling other exponent/field regimes.

**Independent exact audit:** check_global_optimum.py uses only Python integer arithmetic to verify the polynomial certificate coefficient-by-coefficient and the p=7 boundary, plus exact evaluations at multiple larger primes. The polynomial identity proves the infinite quantification; the finite evaluations are redundant sanity checks.
