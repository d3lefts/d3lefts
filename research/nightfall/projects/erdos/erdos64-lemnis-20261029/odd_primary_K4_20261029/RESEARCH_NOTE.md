# LEMNIS — order-three voltage obstruction for cubic K4 covers

**Date:** 2026-10-29. **Assignment:** [#85](https://github.com/d3lefts/d3lefts/issues/85), primary Erdős #64 [#47](https://github.com/d3lefts/d3lefts/issues/47). **Status:** complete internal algebraic proof plus two differently written exact finite checks; independent expert and comprehensive priority review pending. The general Erdős–Gyárfás conjecture remains open.

## Structural theorem

Let G be a group, and form a regular voltage cover of K4. Set the edge voltages of a star (0,1),(0,2),(0,3) equal to the identity by switching. Write a,b,c for the directed voltages of the chords (1,2),(1,3),(2,3), with inverse voltage on reversed edges.

**Lemma.** If *any two* of a,b,c have order three and generate distinct order-three cyclic subgroups, the cover contains a **simple 16-cycle**. The group need not be abelian and other edge voltages are unrestricted.

**Proof.** Relabel the vertices 1,2,3 of K4 so the selected chords become (1,2), (2,3), with directed voltages x,y (possibly inverted). Relabelling keeps the star voltages trivial. Then x³=y³=e and the five elements e,x,x²,y,y² are distinct. The projected closed walk is

    0,1,2,0,1,2,0,1,2,3,0,2,3,0,2,3,0.

Its net voltage is x³y³=e. The sequence of group labels at successive visited base vertices, excluding the final repeated start, is:

* base 0: e,x,x²,y,y²;
* base 1: e,x,x²;
* base 2: x,x²,e,y,y²;
* base 3: y,y²,e.

All 16 pairs (base vertex, group label) are distinct. The walk therefore lifts to a simple 16-cycle. This is an exact group identity, independent of group order or commutativity. QED.

**Corollary.** Every connected regular K4-cover with finite deck group of exponent 3 has C4, C8, or C16. If the group is noncyclic, connectedness forces two chord labels to generate different order-three subgroups, giving C16 by the lemma. If the deck group is C3, all 27 choices (a,b,c)∈C3³ are checked by an exact 12-vertex enumeration: 13 have C4 and no C8, 8 have C8 and no C4, and 6 have both. If the deck group is trivial, the base K4 contains C4. This C3 enumeration is a fully finite proof obligation; the accompanying standard-library checker exhausts all 27 cases.

## Independence and exhaustive evidence

For H27=UT3(F3), all nonidentity elements have order three. A K4 cover is connected precisely when the three chord labels generate H27, equivalently their abelianized images in F3² span that space. Counting rank-two triples gives (9³−1−4(3³−1))×3³ = **16,848** generating triples. Exhaustive independent literal C++ simple-cycle DFS on 108 vertices reports:

| First detected power-of-two cycle | Count |
|---|---:|
| C4 | 1,296 |
| C8 after excluding C4 | 3,888 |
| C16 after excluding C4/C8 | 11,664 |
| none of C4/C8/C16 | **0** |

A second Python code path represents H27 with *literal 3×3 upper-unitriangular matrices*, independently chooses the relevant chord pair, and verifies a simple 16-cycle for **every one of 16,848 triples**. It also exhausts the 27 C3 boundary cases and rejects the deliberately degenerate case of three labels in one order-three subgroup as a valid application of the 16-cycle lemma.

In the free class-two exponent-three group on three generators (729 elements), the same explicit 16-step walk is a simple cycle in the 2,916-vertex regular K4 cover; an independent rooted DFS finds C16 after finding no C4/C8. This confirms that the structural argument survives a genuinely nonabelian group with three independent generators.

## Scientific boundary and stop rule

The theorem eliminates a *regular K4 voltage-cover construction family*, **not all cubic graphs or all odd-primary voltage covers**. In particular, covers with deck elements of order 9, base graphs other than K4, irregular graph covers and voltage assignments lacking the two order-three-subgroup condition remain available. The group-word construction is elementary and may have appeared implicitly in earlier voltage-graph literature; **worldwide novelty is unverified**. Classical voltage-graph monodromy provides the background; see Gross–Tucker. Recent Erdős–Gyárfás finite baselines and related Cayley cases include Ducoffe–Dumitru (arXiv:2609.28594), Tranquilli (arXiv:2608.02675), and Ghasemi–Varmazyar, *On the Erdős–Gyárfás conjecture for some Cayley graphs* (2020/2021).

**Stop:** no more searches over connected UT3(F3) K4 assignments and no more exponent-three regular K4 covers. New test family must change group exponent (e.g., 9), base graph, or covering geometry and use literal all-power-of-two cycle verification before any claimed counterexample.

## Reproduce

    g++ -O3 -std=c++20 -Wall -Wextra -Werror h27_cover_scan.cpp -o h27_cover_scan
    ./h27_cover_scan 16848
    python3 verify_h27_independent.py
    python3 free3_cover.py

Verifiers are independent of the source's symbolic proof; numerical counts are exact. No external mathematical referee has signed off.
