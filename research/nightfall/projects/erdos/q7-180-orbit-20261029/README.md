# Q7: exact four-deletion exclusion across 180 published 304-edge orbit representatives

**NIGHTFALL / Ryev — 2026-10-29.**  
**Status:** exact finite computational certificate (two internally separate algorithms); external referee and priority review pending. **No improvement in the global Erdős #86 bound.**

## Contract and dated prior art

The problem is to maximize edges in a C4-free subgraph of the 7-cube. The 2026-10-29 checked benchmark is **304 ≤ f(7) ≤ 308**; see [OEIS A245762](https://oeis.org/A245762) and [Erdős #86](https://www.erdosproblems.com/86). The 304 construction predates the 2026 computational work (Derrida–Pomeau–Toulouse–Vannimenus, 1979); the explicit data and 180-orbit classification are due to **Minamo Minamoto**, [source repository](https://github.com/minamominamoto/c4free-hypercube), revised 2026. This project claims neither ownership of the source constructions nor exhaustive classification of *all* 304-edge subgraphs.

**Input:** the 180 distinct 448-bit canonical orbit masks from Minamoto's q7_orbit_witnesses.json, SHA-256 of the upstream source file **4e5d7667664b48291ea9d132ac1a07d7e2d3a92d140323d426508b31425ef8b7** (as recorded in its upstream ODDSQUARE_BRIDGE_SHA256SUMS.txt). Each row of canonical_180.txt is one 112-hex-character canonical incidence mask, copied without changes. Edge order: dimension d=0..6, vertex v=0..127 with bit d zero, edge (v,v|2^d). Bit order within each byte is high to low.

**Goal:** find an improvement from any published representative by at most four original-edge deletions, or certify that the entire finite catalogue cannot be improved by this operator. Significance threshold: an independently checked 305-edge witness would be a new finite bound after dated priority review; a failed bounded search is a structural search obstruction, not a new record. Search budget: complete exact depth-four deletion/transversal enumeration across 180 seeds; stop once every seed passes.

## Finite claim and proof

**Proposition (conditional only on the exact 180 input masks).** For each of the 180 supplied C4-free 304-edge graphs H, no C4-free graph H' with at least 305 edges can be obtained from H by deleting at most four H-edges. Thus a 305-edge improvement from any of these particular representatives requires at least five deletions and at least six additions, i.e. **Hamming distance at least 11** in the 448-edge incidence vector.

**Proof.** A missing edge e belongs to six 2-faces. A *tight* face has all three other edges present in H. To insert e without creating a C4, at least one of those three present edges must be deleted for every tight face. For each e, the three-edge blockers from its tight faces are pairwise disjoint. The exact checker finds every missing edge has 2, 3, 4 or 5 tight blockers.

The checker exhaustively tests whether any two missing edges can be unlocked with at most two deletions: **none** can. It constructs the exact compatibility graph of missing edges individually unlockable with at most four deletions; an edge joins two missing edges iff a four-deletion set hits both blocker families. If four missing edges could all be inserted after four deletions, those four would form a K4 in this graph. Every K4 is enumerated, and an independent exact bounded hitting-set recursion tests its combined blockers. **No K4 is jointly unlockable.** Therefore after 1 deletion no missing edge can be added (all have ≥2 blockers); after 2 deletions at most one missing edge can be added; after 3 or 4 deletions at most three missing edges can be added. No strict improvement follows.

This is a *necessary-condition* proof: it does not need to test new squares involving multiple added edges, because it already rules out the requisite number of individually insertable edges.

## Exact audit result

- All **180** canonical masks decode to 304 selected edges and pass both the 672-square C4 enumeration and a distinct common-neighbour C4 check.
- Across 180 × 144 missing edges, tight-square counts: **2:129; 3:8,376; 4:10,290; 5:7,125**.
- The pair-compatibility graph contains no K4 in 173 orbits. The remaining seven orbits (0-based indices **19, 31, 66, 68, 73, 87, 104**) each have exactly 15 K4s, **105** in total. Every one of those 105 K4s fails the exact joint four-deletion transversal test.
- No two absent edges can be unlocked together after two deletions in any orbit.
- A separate JavaScript implementation computed the blocker families, pairwise compatibility, all K4s and joint feasibility, reproducing the same seven exceptional orbit indices and zero jointly unlockable K4s. This is *algorithmic independence*, not human refereeing.

**Reproducible input SHA-256:** 2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1 (canonical_180.txt). **Checker SHA-256:** 348cb84a2ecc48073a52687edb06a9c9e964efedee23159f61eb5b5f2e9f51c2 (check.py). **CI:** [GitHub Actions run 40821207509](https://github.com/d3lefts/d3lefts/actions/runs/40821207509) passed the full 180-orbit exact audit and an intentionally invalid 305-edge negative control. Pairwise compatibility edges across all 180 graphs: **20,668**.

**Symmetry corollary (conditional on the source orbit classification):** cube automorphisms preserve edge count, C4-freeness and deletion distance. Minamoto's independently archived orbit census reports 180 distinct orbits containing **34,227,200** labelled graphs in total. Thus the same four-deletion exclusion extends to all 34,227,200 *images of these representatives*, not to all possible 304-edge graphs. The labelled count is inherited from the upstream census, not recomputed by this checker.

**Run:** from this directory, python3 check.py. Standard library only; prints a JSON result including SHA-256 of the exact canonical_180.txt bytes. The pull-request CI runs this verifier.

## Mechanism and limits

**Operator:** change from seed-local ILP radius search to an exact *blocker hypergraph → pair compatibility graph → clique enumeration → joint hitting-set audit*. It eliminates all 1–4-deletion repairs of the 180 published canonical representatives. It does **not** eliminate 5+ deletions, non-catalogue 304-edge graphs, global 305 solutions, or establish a universal local-exchange theorem for all Q7 304-edge graphs.

**Next experiment:** 5–8 deletion search on inequivalent orbits, using blocker hypergraph transversals to seed MILP/MaxSAT and requiring an independent 672-square witness check. Switch operator family after failure; do not retune a saturated four-deletion neighborhood. Global upper bound remains 308; a solver infeasibility message without a portable proof is not a certified global result.

## Data rights and attribution

The derived 180-mask file is based on **Minamo Minamoto, 2026**, q7_orbit_witnesses.json, distributed under the MIT License. Copyright (c) 2026 Minamo Minamoto. Permission is granted to use, copy, modify, merge, publish, distribute, sublicense and/or sell copies of the source, provided the copyright and permission notice is included. The source is supplied AS IS, WITHOUT WARRANTY OF ANY KIND. See the full upstream [MIT license](https://github.com/minamominamoto/c4free-hypercube/blob/main/LICENSE). The NIGHTFALL checker and analysis are separate derivative work.

**Claim provenance:** data source URL + upstream SHA-256 above, committed derived input canonical_180.txt, check.py command, checker-output input SHA-256 and pull-request CI log. Status is not upgraded without independent human proof and novelty audit.
