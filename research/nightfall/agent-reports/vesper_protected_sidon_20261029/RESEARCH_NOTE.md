# Frozen-prefix Sidon insertion: exact protected-point matching repair

**Research note — Vesper cross-audit, 2026-10-29.**  
**Research ownership:** Devin J. Wright / NIGHTFALL.  
**Foundation:** Axiom's single-point Sidon matching reduction, [draft PR #62](https://github.com/d3lefts/d3lefts/pull/62).  
**Contribution in this audit:** explicitly allow an arbitrary protected subset of existing points, independently reconstruct the proof, and test 81,948 complete finite instances.  
**Status:** elementary mathematical derivation and distinct internal exact computer check. Independent expert proof review and novelty clearance remain open. No resolution of Erdős #44, #156, or #329 is asserted.

## Statement

Let `G` be any abelian group and `D⊂G` a finite *Sidon set*, meaning all sums `x+y` with `x,y∈D`, unordered and with repetition allowed, are distinct. Fix `a∈G\D`. Let `F⊆D` be a **protected subset** whose elements must survive.

We seek the minimum `|R|`, where `R⊆D\F`, such that `(D\R)∪{a}` remains Sidon. The instance may be infeasible.

For each `z∈D` with `a+z=x+y` for `x,y∈D`, define its collision support `C_z={x,y,z}`. As unordered `x,y` is unique, each support is well defined; deduplicate equal supports. If `2a=x+y` for `x,y∈D`, add the unique exceptional support `P={x,y}`.

**Protected-point matching theorem.** Delete only marks in `D\F`. If `P` is absent, the exact optimum is `m−ν`, provided every residual support has at least one deletable incident mark; otherwise the instance is infeasible. Here `m` is the number of distinct `C_z`, and `ν` the maximum matching size of the auxiliary graph having one vertex per support and an edge between two vertices whenever an **available** mark belongs to both.

If `P` exists, at least one mark of `P\F` must be deleted. For each eligible choice `t∈P\F`, remove every support containing `t`; form the residual auxiliary graph using marks in `D\(F∪{t})`. Let `m_t` and `ν_t` be its vertex count and maximum matching size, with infeasible branches discarded. Then the exact optimum is

```
1 + min_{t in P\F, feasible residual} (m_t - nu_t).
```

If no branch is feasible, insertion preserving `F` is impossible. With pair-sum construction and general-graph matching, the optimum is computable in polynomial time, e.g. `O(|D|³)` using a standard cubic upper bound for matching. This concerns a **single prescribed insertion**; simultaneous insertions and a globally optimal multi-step growth strategy remain separate problems.

## Proof

**1. Collision equivalence.** All unordered pair sums among surviving points of `D` remain unique, because `D` is Sidon. Every new collision is exactly of the type `a+z=x+y` or `2a=x+y`, with right-side points in `D`. Consequently a deletion set is feasible exactly when it hits every `C_z` and, when present, `P`. The protected set affects which marks may be deleted, without changing this equivalence.

**2. At most two supports per mark.** Fix `t∈D`. It can be a distinguished `z=t` in at most one support because the sum `a+t` has at most one unordered representation from `D`. If it occurs as a right-side endpoint, `a+z=t+u` is equivalent to `u−z=a−t`. The difference `a−t` is nonzero. A Sidon set has a unique **ordered** representation of every nonzero difference: two representations `u−z=u'−z'` imply `u+z'=u'+z`, and Sidon uniqueness forces `(u,z)=(u',z')` when the difference is nonzero. Thus `t` can be a right-side endpoint in at most one support. Duplicated supports lower the degree; they never increase it. This argument works in all abelian groups, including even-order groups with torsion.

**3. Reduction to graph edge cover.** Each available mark belongs to zero, one, or two remaining supports. Deleting it covers exactly zero, one, or two auxiliary vertices. Marks covering two supports correspond to graph edges; marks covering one support act as singleton-cover options (loops). A support with no available incident mark makes the residual instance infeasible. Otherwise the standard graph edge-cover/matching identity, with singleton options on isolated vertices, gives `m−ν` deletions. This identity remains valid if some vertices have only nonloop edges: take a maximum matching and add one incident edge for each unmatched nonisolated vertex, plus a singleton at each isolated vertex. The reverse inequality is the classical matching lower bound for edge covers.

**4. Exceptional pair.** Every feasible repair hits `P` whenever it exists, so choose some deleted `t∈P\F`. Once its incident supports are already hit, the residual problem is exactly Step 3. Taking the minimum over all eligible `t` proves the formula.

The proof extends Axiom's unconstrained matching method by removing forbidden deletions before constructing incidence edges. The graph-theoretic identity itself is established classical mathematics; originality of this application remains unverified.

## Independently rerun finite checks

Run:

```sh
python3 research/nightfall/agent-reports/vesper_protected_sidon_20261029/verify_protected_sidon.py
```

The checker independently enumerates every nonempty Sidon subset of size at most five in each listed finite group, every exterior point `a`, every protected subset `F`, and every allowable deletion subset, verifying the output directly from unordered sums. It separately computes the support-graph matching prediction. Each group is processed exhaustively under that size cap.

| Finite abelian group | Checked `(D,a,F)` cases |
| --- | ---: |
| Z/4 | 56 |
| Z/6 | 252 |
| Z/8 | 1,328 |
| Z/9 | 3,744 |
| Z/10 | 3,700 |
| Z/12 | 11,304 |
| Z/2 × Z/2 | 24 |
| Z/2 × Z/3 | 252 |
| Z/2 × Z/4 | 496 |
| Z/3 × Z/3 | 4,608 |
| (Z/2)³ | 112 |
| Z/3 × Z/4 | 11,304 |
| Z/4 × Z/4 | 44,768 |
| **Total** | **81,948** |

The locally authored check completed in approximately 2.9 seconds using standard-library Python. The committed checker asserts the exact per-group totals and fails on any discrepancy. This is bounded internal validation and cannot replace expert proof review.

## Application and limits

This proves that **freezing a prefix does not destroy the polynomial-time single-point matching reduction**. It provides an exact local operator for attempts to extend a prescribed Sidon set, potentially useful for deciding which points in a newly constructed auxiliary block to discard. It does *not* prove that successive locally optimal repairs attain optimal asymptotic density. The missing quantitative work remains a parameter-uniform bound on the number of repairs needed over an entire dense block and the resulting loss in global Sidon capacity.

**Review requests:** Lemnis should independently attack the difference uniqueness argument in torsion groups and graph edge-cover identity with protected incidence; Axiom should assess whether this local operator transfers to the prescribed-prefix #44 program; Ryev should cross-check the checker against an alternative exact formulation. No site-level Original Findings promotion without specialist referee and dated same-model priority review.
