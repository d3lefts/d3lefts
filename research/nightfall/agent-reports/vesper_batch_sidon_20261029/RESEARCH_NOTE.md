# Vesper / NIGHTFALL — exact simultaneous Sidon insertion with a collision core

**Date:** 2026-10-29. **Scientific owner:** Devin J. Wright. **Research assignment:** [#108](https://github.com/d3lefts/d3lefts/issues/108).  
**Status:** internally proved scoped algorithmic result; independent direct-sum finite audit and formal CI required. External mathematical referee, priority search and publication status open.  
**Baseline:** Axiom's matching formula for one prescribed point in [draft PR #62](https://github.com/d3lefts/d3lefts/pull/62) and Vesper's protected-prefix extension in [merged PR #71](https://github.com/d3lefts/d3lefts/pull/71).

## Mathematical problem

Let G be an abelian group, D a finite Sidon subset, E a finite set disjoint from D of **k prescribed new marks**, and F⊆D protected. Delete the fewest members R⊆D\F so that (D\R)∪E is Sidon. A Sidon set has all *unordered sums with repeated summands included* unique. If E itself is not Sidon, no feasible repair exists.

Unlike a sequence of individually optimal one-point insertions, the batch problem handles cross-interactions between **all** new marks simultaneously. The objective preserves the whole batch E, regardless of its order.

## Collision taxonomy / exact reduction

Each repeated sum of two unordered pairs is classified by the number of E-marks in each pair.

- **(0,0)**: collisions between D+D sums cannot occur, since D is Sidon.
- **(1,0)**: a+z=x+y, with a∈E and x,y,z∈D. The deletion support is C_(a,z)={x,y,z}, containing two or three distinct marks. Deduplicate equal supports into a family H.
- **(1,1)**: a+x=b+y, a,b∈E, x,y∈D. Since equal a=b would force x=y, a genuine collision requires distinct fresh marks. Delete x or y, yielding a support of size two.
- **(2,0)**: a+b=x+y with a,b∈E (including a=b) and x,y∈D. Delete x or y, giving a support of size one or two.
- **(2,1)**: a+b=c+z with a,b,c∈E and z∈D. Delete z, a singleton support.
- **(2,2)**: an internal repeated E+E sum cannot be affected by deletion of D, hence is immediately infeasible.

The three middle types (1,1), (2,0), and (2,1) form an **exceptional support family** Q, each member of size ≤2. Thus exact Sidon repair is equivalent to a minimum old-mark hitting set for H∪Q, with forbidden deletions F.

**Count of exceptional supports.** Sidon difference uniqueness gives at most one (1,1) collision for each unordered distinct a,b∈E: there is at most one ordered D-pair with difference b−a. Hence ≤binom(k,2) supports of type (1,1). Each unordered E-pair contributes at most one (2,0) support, giving ≤binom(k+1,2). For type (2,1), each E-pair and each c∈E specify z uniquely by cancellation, giving ≤k·binom(k+1,2). Therefore every exceptional-support mark lies in a set B₀ of cardinality

```
|B₀| ≤ 2 binom(k,2) + 2 binom(k+1,2) + k binom(k+1,2)
     = (k³ + 5k²)/2.
```

**Low incidence of ordinary supports.** Fix old t∈D and fresh a∈E. The element t appears as distinguished z in at most one (1,0) support, because a+t has at most one D+D representation. As a right-hand x or y, it satisfies a+z=t+u, equivalent to u−z=a−t. Since a∉D, this nonzero difference has *at most one ordered D representation*. Proof: if u−z=u'−z'≠0, then u+z'=u'+z, and the Sidon property forces (u,z)=(u',z'). Thus t belongs to ≤2 supports for each a, and to ≤2k distinct members of H, even in groups with torsion.

Let **c** be the number of D-marks with H-incidence at least three. Set B=B₀∪{t:deg_H(t)≥3}. Then

```
|B| ≤ c + (k³+5k²)/2.
```

## Theorem — exact fixed-parameter batch repair

For all finite Sidon D in any abelian group and any specified disjoint E,F as above, the minimum deletion set, with an explicit infeasibility determination, can be computed in time

```
2^[ c + (k³+5k²)/2 ] · poly(|D| + k),
```

where the polynomial factor uses a standard **general-graph maximum matching** algorithm (Edmonds/Blossom). This is fixed-parameter tractable in k+c, but makes **no global polynomial-time claim** for unrestricted k,c.

**Proof.** Branch on the deleted/not-deleted status of every mark of B; branches deleting F are disallowed. A branch must hit every exceptional support Q, because Q⊆B. It also already hits every ordinary support containing a selected B mark. In the residual ordinary family H', only marks outside B∪F can be deleted, and every such mark appears in ≤2 of its supports. If any H' support lacks an available incident mark the branch is infeasible. Otherwise build one graph vertex per support in H'. An available mark incident to two vertices acts as an ordinary graph edge; one incident to a single support acts as a singleton option. All vertices are coverable. The exact minimum additional number of deletions is `m−ν`, where m=|H'| and ν is a maximum matching size of the two-support edge graph. To see this, take maximum matching edges and add one available edge for every unmatched nonisolated vertex, and one singleton for each isolated vertex; conversely any cover by available incidence-1/2 marks induces an edge cover with size at least m−ν (singletons can be represented as loops or pendant leaves). The optimum of the branching and residual matching formulas equals the minimum full deletion, because every feasible deletion induces precisely one choice of deleted B marks and all collision types have been enumerated. Standard polynomial matching plus at most 2^|B| branches gives the stated running-time bound. QED.

**Scope:** this is an algorithmic structural reduction. It is neither an asymptotic Sidon density improvement nor a solution to Erdős #44/#156/#329. A dedicated literature search found standard Sidon equivalence and hitting-set FPT background, but no exact same-scope multiple-insertion reduction in the searched results; this is **not** an exhaustive novelty clearance.

## Executable proof contract

- `batch_core.py` computes all collisions explicitly and returns an optimal deletion **witness** using exact branching and bitmask maximum-matching DP. The DP is deliberately exponential for small transparent test instances; the mathematical theorem's polynomial subroutine is a general-graph matching implementation.
- `audit.py` independently enumerates all allowable deletion subsets and recomputes every unordered pair sum, including diagonal pairs, over cyclic and direct-product groups. It checks optimality and that the actual returned union is Sidon.
- Additional independent negative tests ensure an overlooked 2a=x+y event produces a **wrong** answer, a non-Sidon E is refused, and fully protected D cannot be altered.

Run from repository root:

```sh
python3 research/nightfall/agent-reports/vesper_batch_sidon_20261029/audit.py
```

The GitHub workflow `vesper-batch-sidon-audit.yml` runs these checks on the PR and on main. **Verified GitHub Actions run [40830849729](https://github.com/d3lefts/d3lefts/actions/runs/40830849729): 52,886 exact (D,E,F) cases** across nine cyclic/product groups: (4,) 104; (5,) 420; (6,) 972; (7,) 4242; (8,) 8144; (2,2) 56; (2,3) 972; (2,4) 3632; (3,3) 34344. **674 (D,E) pairs had ordinary supports with at least one incidence-3 mark**; this specifically exercises the new core-branching mechanism, not merely the pre-existing one-point matching case. The exact canonical row SHA-256 is `75a2a71c22e9194d4cfe04f78c136ec2120b4db8228d3aed051670a1d1531d38`. Each test directly compares the solver's deletion count against exhaustive enumeration and checks the Sidon property of the returned witness. Source code and CI constitute independent-in-project exact checks, **not** external peer review.

## Next theorem

A *structural coupling bound* that forces c=O(k³) for a useful algebraic class of simultaneous block insertions would turn this exact parameterization into a uniform polynomial repair procedure for that class. The currently proved theorem makes no such claim. Axiom should attack whether Sidon difference structure bounds c under Bose–Chowla/Singer translations; Lemnis should seek an adversarial torsion counterexample to the collision taxonomy or matching proof; Ryev should implement an independent Blossom-based checker for larger k and compare to exact brute force.

**Historical grounding:** classical Sidon/Golomb uniqueness and graph edge-cover/matching are established. [Sidon set background](https://mathworld.wolfram.com/SidonSet.html); [general FPT hitting-set literature](https://doi.org/10.1016/j.ic.2024.105261). External priority remains open.
