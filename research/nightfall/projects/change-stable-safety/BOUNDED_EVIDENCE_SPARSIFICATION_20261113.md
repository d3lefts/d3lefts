# Bounded evidence sparsification and minimum-cost selection with exceptional dependencies

**NIGHTFALL corollary | 13 November 2026 | Author-directed AI-assisted derivation; provisional priority**

This note strengthens the accompanying [tree/exception certificate theorem](TREE_CONVEX_CERTIFICATES_20261113.md) from an efficient *verifier* to a finite-dimensional bound on *how many trusted evidence items an optimal certificate needs*. The central tree-transversal identity is classical; the present composition with a declared safety-update oracle is an author-derived application, not yet a claim of historical novelty.

## Scope

Let C be vertices of a known tree and E a set of s exceptional changeable components. Each evidence item i has a nonempty dependency D_i subset C union E; D_i intersect C must be empty or a connected subtree of C. An update changes at most k distinct components, invalidating any row whose dependency it intersects. A certificate is robust when, after any such update, at least one selected item survives. Costs e_i are additive and nonnegative. Untrusted system updates and incompletely reported dependencies are excluded by assumption.

For integers s,k>=0 let

    M(s,k) = sum_{j=0}^{min(s,k)} binomial(s,j) (k-j+1).

For example, M(0,k)=k+1 and M(1,1)=3.

## Theorem D: bounded-size robust subcertificate

**Every robust collection I of evidence items contains a robust subset J with |J| <= M(s,k).** In particular, for arbitrary nonnegative acquisition costs there exists a minimum-cost robust certificate with at most M(s,k) evidence items.

**Proof.** For each A subset E with |A|<=k, let r=k-|A|. Consider evidence items not invalidated by A. By the complete exceptional-dependency criterion in Theorem C, one of two witnesses exists:

(1) A surviving item has empty residual dependency on C. Keep that one row. It cannot be invalidated by any further update confined to C.

(2) Otherwise the residual C-dependencies have hitting number greater than r, which equals their pairwise-disjoint packing number by the explicitly supplied-tree lemma. Keep r+1 items with pairwise-disjoint residual supports. Any remaining update of at most r components in C misses at least one of those rows.

Take the union J of rows kept over all A branches. Every update U with |U|<=k determines its exceptional part A=U intersect E and residual part U intersect C. The recorded branch witnesses for that A guarantee at least one member of J survives U. Counting at most r+1 rows per branch gives |J|<=M(s,k).

Now start with a minimum-cost robust I. The subset J obtained above remains robust and has no greater sum of nonnegative costs. Hence it is also minimum-cost, and its cardinality obeys the bound. QED.

**Algorithmic consequence.** A complete minimum-acquisition-cost algorithm enumerates subsets of size at most M(s,k), charging their evidence costs and testing each with the O(2^s poly(n,m,k)) branch verifier. The running time is bounded by

    O( (sum_{j=0}^{min(m,M(s,k))} binomial(m,j)) * 2^s * poly(n,m,k) ).

This is polynomial for *fixed* s and k, but only an **XP-type** guarantee as s or k grows, not an FPT claim. The special case s=0 admits the substantially better polynomial dynamic programming in Theorem B, without fixing k.

## Sharpness for one exceptional component and one update

Take C={0,1} with host-tree edge 0--1, E={2}, k=1, and three evidence supports

    D1={0,2}; D2={1,2}; D3={0,1}.

All pairs intersect: D1,D2 at 2; D1,D3 at 0; D2,D3 at 1. Any two items can therefore both be invalidated by one component update, so no two-item certificate is robust. But all three together survive every one-component update. Thus M(1,1)=3 is **attained**.

This example is also an obstruction to replacing the exceptional-dependency branch certificate with the simpler instruction to supply k+1 disjoint *full* dependency supports. The exception-branch certificate succeeds where global packing fails.

## Quantitative threshold corollary

Under the margin model b_i,delta_i, set a target gamma>0 and a per-leaf check cap q. Discard rows with b_i<gamma or t_i>q. If any remaining row has b_i-delta_i>=gamma, it is itself a robust one-row certificate. Otherwise the surviving threshold-adequate rows are all fragile, and the preceding theorem applies verbatim to their dependency supports. Hence an optimal nonnegative-cost gamma-certificate can be chosen with at most max(1,M(s,k)) rows.

This uses the *binary* all-or-nothing declared weakening envelope for a changed support; accumulating per-component weakening requires a different theorem.

## Exact finite falsification

An independent checker (local researcher execution, 13 November 2026) compared the theorem with exhaustive enumeration:
- 1,155 generated robust instances: the union of branch witnesses remained robust and respected M(s,k).
- 998 instances: exhaustive minimum-cost searches over all selected subsets matched searches restricted to subsets of size at most M(s,k).
- The explicit three-item triangle was checked to be robust with no robust two-item subcollection.

These tests do not constitute a claim of external refereeing, Lean compilation, or worldwide novelty.

## Open novelty and next experiment

The underlying tree hitting/packing theorem, chordal independence algorithms and fixed-parameter branching are established techniques. Search the literature for subsumption by resilience/robust hitting-set sparsification *under exactly this modulator representation*. The decisive practical test is whether an independently audited proof dependency graph admits a small genuine exceptional set s, rather than merely declaring one by hand. If not, this theorem has limited deployment significance.
