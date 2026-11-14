# Research lineage: binary change-stability to quantitative tree-convex certificates

**NIGHTFALL | 13 November 2026 | Internal analytic results; no external priority certification**

These predecessor theorems were developed in author-directed AI-assisted research before the new tree-convex and bounded-exception results. They are preserved here to make the logical dependency graph and changes of scope inspectable. Claims of general Hitting Set, Grothendieck, or proof-carrying-code invention are expressly **not** made.

## Baseline 1 — binary evidence survival is a transversal condition

Let H be a set of unsafe circumstances. Evidence row i excludes circumstances C_i subset H and depends on components D_i. A system update T invalidates i if T intersects D_i. Assume complete hazards, complete dependencies, a trusted checker for each exclusion, and all updates of size <=k as adversarially possible.

For selected items I, the safety decision survives every permitted update iff for each hazard h in H, the collection of supports

    F_h(I) = {D_i: i in I and h in C_i}

has transversal/hitting number tau(F_h(I)) > k. The empty collection has hitting number 0; a family containing an empty dependency has hitting number infinity.

**Proof.** A destructive update for hazard h is exactly a set of <=k components intersecting every support of an item excluding h. Existence of such an update is equivalent to tau(F_h)<=k. Negating for every hazard proves the statement.

Acquisition/check expenditure can be minimized over selected subsets, but even the k=0 case contains weighted Set Cover. Exact parameterized and approximation methods belong to the established Hitting Set/Set Cover literature.

## Baseline 2 — quantitative margin for mutually exclusive update groups

Each evidence item has baseline margin lower bound b_i, worst group-update weakening delta_i>=0, unique group g(i), acquisition cost e_i>=0, and per-version leaf-check cost t_i>=0. At most k distinct groups may change. For selected items define U_g=max_{g(i)=g} b_i, L_g=max_{g(i)=g}(b_i-delta_i). Then

    min_{|T|<=k} max_i(b_i-delta_i 1[g(i) in T])
      = max(max_g L_g, (k+1)-st largest U_g),

where the order statistic is -infinity when fewer than k+1 groups exist.

At required gamma and leaf-check budget q, exact minimum acquisition cost equals the minimum of

    min {e_i : b_i-delta_i >= gamma, t_i<=q}

and the sum of the k+1 cheapest qualifying per-group evidence costs among distinct groups, with qualification b_i>=gamma and t_i<=q. Infinite infeasibility is permitted.

**Proof idea.** A durable row survives any change. Otherwise an adversary must affect every group having baseline-adequate evidence. If k+1 such groups remain, one always survives. Conversely if <=k suffice, change those groups. For minimum cost, drop every row but one durable row or one cheapest baseline-adequate row in each of k+1 groups.

This is a special case of the tree-convex margin theorem with supports equal to singleton group nodes. Its combinatorial order-statistic content is closely related to budgeted robust optimization.

## What changed in the new work

The independent-group assumption is restrictive: multiple pieces of evidence may rely on the same mutable component, and each piece may depend on a connected chain of components. The [tree-convex theorem](TREE_CONVEX_CERTIFICATES_20261113.md) gives exact margin and cost formulas for overlapping *connected* supports; its [exception-set extension](TREE_CONVEX_CERTIFICATES_20261113.md#theorem-c-a-complete-certificate-with-a-bounded-non-tree-exception-set) admits arbitrary overlap on at most s declared exceptional components. The [sparsification corollary](BOUNDED_EVIDENCE_SPARSIFICATION_20261113.md) bounds the number of evidence items needed in any minimum-cost robust certificate by M(s,k).

## Trust, checking, and publication gates

The purely combinatorial formulas are only correct about their exact declared dependency model. Applying them to an actual AI safety decision requires authenticated source evidence, correct safety semantics, complete change events, independently verified degradation bounds, complete hazards, and a trusted checker. Source hashes demonstrate stable bytes only. A repository commit, generated paper, or AI critique is not independent peer review.

Literature comparison remains open for *worldwide novelty* of the composed models and computational results. These notes should be described as **original internal research constructions with classical antecedents**, not as accepted or externally reviewed breakthroughs.
