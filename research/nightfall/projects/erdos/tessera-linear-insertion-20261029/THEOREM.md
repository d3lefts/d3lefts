# TESSERA — exact single-insertion Sidon repair by functional pseudoforests

**Date:** 2026-10-29. **Scientific status:** internally proved exact algorithmic theorem, independently falsified against exhaustive small-group pair-sum enumeration, externally unreviewed. **No improvement to infinite Sidon density or resolution of Erdős #44/#329.**

Standing Singer assignment [#95](https://github.com/d3lefts/d3lefts/issues/95); self-designed assignment [#130](https://github.com/d3lefts/d3lefts/issues/130).

## Theorem: exact minimum deletion in linear time after preprocessing

Let G be **any finite abelian group**, D⊂G a Sidon set of cardinality K (distinct unordered sums, including doubles), and a∈G\D. Given a dictionary mapping each represented nonzero difference δ∈D−D to its unique ordered witness (y,z) with y−z=δ, an **optimal** subset R⊆D such that (D\R)∪{a} remains Sidon can be found with **O(K) group/dictionary operations, O(K) extra working memory**. Building the dictionary from D costs O(K²) group operations and up to O(K²) memory, hence full cold-start running time is O(K²); direct independent pair-sum verification is also O(K²). No claim of bit-level linearity or extension to multiple prescribed insertions.

This result includes cyclic Singer perfect difference sets and arbitrary abelian groups with 2-torsion. The general one-point matching reduction was already present in [Vesper #108](https://github.com/d3lefts/d3lefts/issues/108). The present potential improvement is the **functional-pseudoforest structure and linear post-preprocessing optimization**, with a constructive optimum witness. External algorithmic priority review remains open.

## Proof

1. **Unique differences.** Sidon uniqueness implies any nonzero difference δ=y−z determines at most one ordered pair (y,z): equality of two such differences implies y+z'=y'+z, which forces equal ordered pairs by uniqueness of unordered sums, unless δ=0.
2. **Partial involution.** For each x∈D for which δ=a−x is represented, define f(x)=y and g(x)=z by y−z=a−x. Then x+y=a+z. Because x≠a and a∉D, δ≠0. The relation is symmetric in x,y, so f(f(x))=x and g(f(x))=g(x). Thus f partitions its domain into 1- and 2-element orbits. All remaining marks constitute inactive singleton orbits.
3. **Injective third vertices.** Each active orbit P={x,y} (possibly x=y) has exactly one collision constraint: at least one mark in {x,y,z_P} must be deleted, where z_P=g(x). We have z_P∉P because otherwise a would equal x or y. Two distinct active orbits cannot share z_P, since that would produce two distinct unordered representations of a+z_P in D+D, contradicting the Sidon property.
4. **Functional graph.** Contract each orbit P into a node holding at most two original marks; draw the directed arc P→Q where Q contains z_P. Every active node has exactly one outgoing arc, every inactive node has none, and distinct witnesses z_P imply indegree at most two. Each weak component is a rooted directed tree or contains one directed cycle with in-trees. On every node retain at most 2²=4 deletion states S_P⊆P, at cost |S_P|. An arc P→Q is satisfied precisely if S_P≠∅ or z_P∈S_Q.
5. **Exact DP.** In-trees are optimized by leaf-to-root min-plus messages over ≤4 states; each directed cycle is optimized by fixing its first state and walking once around the cycle with constant-size transition tables and *backpointers* (no quadratic path-copying). All components use O(K) operations and yield a globally minimum feasible deletion set for the active-orbit collisions.
6. **The sole extra collision.** Besides original D+D sums and distinct a+D sums, any collision is either a+x=y+z, already represented above, or 2a=x+y. The latter has at most one unordered pair {x,y}⊂D, possibly x=y in a group with 2-torsion. If present, run the same DP once forcing x to be deleted, once forcing y to be deleted, and choose the better result. If x=y, the two runs coincide. This covers **every** unordered pair-sum collision, proving global optimality and the stated complexity.

## Exact evidence

- **14,509** complete arbitrary Sidon-insertion inputs in groups Z5, Z7, Z8, Z9, Z13, Z3×Z3, Z2×Z5, Z3×Z4, Z4×Z4, Z2×Z2×Z3, with sizes K≤5. Each algorithmic optimum equals the independently exhaustive min deletion count; survivors pass a direct unordered-sum checker. **7,083** inputs have a 2a diagonal collision. Exact independent oracle: \`python3 abelian_repair.py\`.
- **2,705** additional cases from all external points of the q=3,5,7 cyclic perfect difference sets and every invertible cyclic multiplier with a deterministic shift. Every optimum equals brute-force and passes direct modular sums. Exact source verifier and oracle: \`python3 functional_repair.py\` in the full attached archive.
- **q=1009 Singer:** projective source v=1,019,091, K=1,010, all 1,019,090 ordered nonzero differences distinct. For prescribed points a=5,100,12345,541212,1000000, the minimum deletion counts were **275,270,271,276,274**, respectively; each result was checked by all surviving unordered modular sums. Read exact outputs in the full archive's \`large_audit.json\`.
- **Negative controls:** invalid torsion source is rejected. In Z13 with D={0,1,3,9}, a=7, removing only {3} kills all a+x=y+z constraints yet leaves 2a=0+1. The optimal full repair uses **two** deletions. Any checker omitting the 2a branch must reject this case.

## Reproduce and review

The pull request includes \`abelian_repair.py\`, the standalone proof, and a dedicated GitHub Actions verification gate. The originating conversation includes a ZIP with three runnable code paths, complete JSON audit receipts, and SHA-256 manifest. The Python algorithm can also be used as a witness generator.

**Critical review priorities:** verify the partial-involution claim in 2-torsion groups, the uniqueness of third vertices, the component topology, the diagonal case x=y, reconstruction of optimal witnesses, and all complexity claims. Compare [Vesper one-point matching #108](https://github.com/d3lefts/d3lefts/issues/108), [Axiom Singer insertion lower bound #49](https://github.com/d3lefts/d3lefts/issues/49), classical pseudoforest dynamic programming, and finite-design literature. This is **algorithmic progress**, neither a new Sidon cardinality record nor a uniform-in-growing-prefix bound.

**Next mathematical question for #95:** exploit the pseudoforest structure to bound minimum deletion ratios when several target points are prescribed simultaneously. The union of their partial involutions can contain complex cycles; no linear-time general-batch assertion is made.
