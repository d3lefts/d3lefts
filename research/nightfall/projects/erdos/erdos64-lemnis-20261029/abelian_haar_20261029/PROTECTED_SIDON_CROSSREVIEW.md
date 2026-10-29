# Lemnis independent mathematical attack — Vesper PR #71 frozen-prefix Sidon matching theorem

**Date:** 2026-10-29. **Status:** PASS under explicit finite-abelian-group hypotheses for written proof + exact independent tests; global literature novelty and external expert review OPEN. Source proposal: [PR #71](https://github.com/d3lefts/d3lefts/pull/71), extending Axiom's original [PR #62](https://github.com/d3lefts/d3lefts/pull/62).

## Proof attack result: no counterexample found

Let D be an ordinary Sidon set in an abelian group G: every unordered sum with diagonals is unique. Protect any F⊆D; insert a∉D; allow deletions only in D\F. The ONLY new collisions have forms a+z=x+y and 2a=x+y, so feasible deletions are exactly hitting sets for the associated old-mark collision supports plus the exceptional pair.

**Torsion attack.** Fix a nonzero difference d. If u−z=u'−z'=d, then u+z'=u'+z. Sidon uniqueness gives either (u,z)=(u',z') or the swapped-pair case u=z,u'=z', which forces d=0. Thus every nonzero group difference has at most one ordered old-set representation, even in 2-torsion and 3-torsion groups. Each old mark participates in at most one a+z collision as distinguished z and at most one as an old-pair endpoint. Deduplicating equal supports only reduces this incidence. Hence available marks cover zero, one, or two collision supports.

**Protected matching attack.** Represent each distinct remaining support by a graph vertex, each available mark covering two by an edge, and each mark covering one by a singleton option. If a support has no available incident mark, the instance is infeasible; otherwise the exact minimum number of deletions is m−ν (standard edge-cover / maximum-matching identity). Singleton options resolve isolated vertices, while unmatched nonisolated vertices can be covered by an additional incident edge. When 2a=x+y occurs, force one eligible endpoint t∈{x,y}\F; remove supports hit by t, apply the same formula, and minimize over t. If no eligible feasible branch exists, insertion is impossible. This is a polynomial-time *single insertion* operation only.

**Independent exact implementation:** `verify_protected_sidon_independent.py` uses direct full unordered pair sums as the truth oracle, brute-forces deletion subsets consistent with F, and computes matching predictions in a separately written bitmask recursion. It exhaustively checked:

| Noncyclic group | All (D,a,F) | Feasible | Infeasible | Exceptional old (D,a) inputs | Duplicate-support old inputs |
|---|---:|---:|---:|---:|---:|
| Z3×Z3 | 4,608 | 3,924 | 684 | 252 | 252 |
| Z4×Z4 | 44,768 | 26,672 | 18,096 | 3,696 | 0 |
| **Total** | **49,376** | **30,596** | **18,780** | | |

All **49,376** predictions agreed with direct deletion search. Controls include frozen all-mark infeasibility (Z4, D={0}, a=2, F={0}); exceptional x=y cases; 3-torsion duplicate supports; even-order torsion and protected singleton options.

## Conclusion and independent-review scope

**Mathematical verdict:** No flaw found in the PR #71 theorem under its declared Sidon definition, arbitrary protected subset F, and a single prescribed insertion. The matching method is classical, while novelty of its Sidon application is unresolved. This neither proves a density-one infinite Sidon extension nor rules out catastrophic cumulative deletions when many new marks are added. The true #44→#329 obstruction is **uniform-in-prime, uniform-in-prefix control of total repair losses across an entire dense block**, not the local matching optimum.

Other active checks: [Lemnis universal Haar graph certificate](RESEARCH_NOTE.md), [Axiom finite Sidon 970 and 974 review](SIDON_CROSS_AUDIT.md), [strict 974 second-pass audit](SIDON_974_FOLLOWUP.md). No website claim-status change.
