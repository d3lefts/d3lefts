# TESSERA / Variable-width Singer grafting and exact cut-averaged difference transport

**Date:** 2026-10-30. **Standing Vesper assignment:** [#95](https://github.com/d3lefts/d3lefts/issues/95), latest [#60](https://github.com/d3lefts/d3lefts/issues/60) dispatch. **Status:** internally verified, reproducible finite construction + elementary general lemma. R1 only; independent non-author proof review and global originality review **NOT completed**. **Erdős #44/#329 remain OPEN.**

## Research contract / test result

**Hypothesis:** changing Singer source width from q25 (26 marks, v651) to q49 (50 marks, v2451) can preserve the *fixed hostile 23-mark Sidon prefix* from PR #192 and retain more than the 10 marks permitted by the q25 affine-orbit optimum of PR #205. Repeat one successor to test genuine integer Sidon closure, without assuming the prior repaired set remains a cyclic perfect difference set.

**Falsifier:** every q49 cut/translation tested yields ≤10 new marks, or any claimed 41/54-mark witness has a repeated unordered integer sum, or q49 fails the Singer modular difference check.

**Verified positive result:** independent GF(7^6) trace-zero Singer source, v=2451, K=50, all 2450 nonzero modular differences unique. The frozen q25 23-element prefix S0 from PR #192 has max 1167. Under affine cut (u,c)=(1,1581), translation T=3619, retain exactly **18** of 50 q49 source marks. The resulting S1 has **41 integer Sidon marks**, max 6047, and **861 unique unordered pair sums**. A further, separately cut q49 source (u,c)=(2,0) translated by T=12095, retaining **13** of 50 source marks, yields **54 integer Sidon marks**, max 14479, with **1485 unique unordered pair sums**.

The retained *source coordinates* (before the physical translations) are:

- Generation 2 (18): \`[15,33,157,322,473,657,898,1051,1211,1212,1437,1449,1702,1776,1931,2123,2398,2428]\`.
- Generation 3 (13): \`[100,235,258,505,817,860,1084,1619,1713,1953,2187,2353,2384]\`.

**SHA-256, newline-delimited decimal integers:** S0 \`feb60c46538147823f59d57f0cc868c40a1b7deab3256ede8a9e2f02c57980dd\`; S1 \`fbe94e71d0367fb9da77951f5a847296b60c61699239d764a08e3ec808500ced\`; S2 \`10a14f4a22a89850c569c066dffbdb016392cdb2e5743cb659ce8c68615b8cb8\`.

**Crucial same-scope density comparison:** fixed-width q25 second-generation optimum from PR #205 has 33 marks and max 2953, coefficient 33/√2953 ≈ **0.60727054**. This variable-width q49 S1 is 41/√6047 ≈ **0.52724670**, and S2 is 54/√14479 ≈ **0.44877068**. Therefore the width-changing operator **escapes the finite fixed-width cardinality cap but LOSES normalized density**, so there is **NO Sidon density advance** and no asymptotic conclusion.

No global optimality over all q49 multipliers, cuts, shifts, or retained subsets is claimed. The selection used one solver-assisted search per fixed affine cut, but public verification uses a dependency-free direct pair-sum oracle; solver success is neither needed nor relied on for the published claim.

## General quantified lemma: exact cut-averaged difference transport

Let S be any finite integer Sidon set with r points and let D⊂Z/vZ be a cyclic (v,K,1) perfect difference set. Define the positive difference set

\[
\Delta(S)=\{s_j-s_i : s_i,s_j\in S,\ s_j>s_i\},\qquad
L=\Delta(S)\cap\{1,\ldots,v-1\}.
\]

For each cyclic cut c∈Z/vZ, let Q_c be the ordinary integer representatives of D+c, and let e(c) count **new-source pairs whose positive integer difference belongs to L**. Exact ordered modular difference uniqueness implies the conservation identity

\[
\boxed{\sum_{c=0}^{v-1}e(c)=\sum_{d\in L}(v-d).}
\]

**Proof:** For each d∈L, Singer uniqueness gives one ordered pair (x,y)∈D² with x−y≡d mod v. Under the v possible translations c, its ordinary representatives have x'−y'=d for **exactly v−d cuts**; on the remaining d cuts the integer difference is d−v. Sum over d.

For every cut c, build graph H_c on K new source marks by putting an edge when their positive difference is in Δ(S). Retain an independent set I⊂Q_c and translate it by any integer T satisfying

\[
T>2\max S,\qquad T>\max S+\max Q_c.
\]

Then S∪(T+I) is an integer Sidon set: old-old and new-new pair sums are internally unique; old-old is below the mixed/new ranges; mixed/new-new equalities are excluded by the second inequality; remaining mixed/mixed equalities are exactly the graph edges.

Averaging and the elementary graph independent-set lower bound give **existence** of a cut with

\[
|I|\ge\left\lceil\frac{K^2}{K+2\lfloor\frac1v\sum_{d\in L}(v-d)\rfloor}\right\rceil .
\]

This guarantee is valid with arbitrary protected S, growing r and arbitrary q; it is weak in the regime r≈q and **does not ensure a uniform coefficient above 1/√2**, nor preserve any Singer property of the resulting union. The proof is a combination of classical perfect difference sets, simple cut averaging and the Turán/Caro–Wei independent-set bound; **no novel worldwide theorem is asserted.**

The program exhaustively checks all 2451 cyclic cuts for the frozen S0 and S1: the exact sums of e(c) are **511671** and **743965**, and the guaranteed number of retainable marks through this coarse bound is only **6** and **4**, respectively (actual retained 18 and 13 in our chosen cuts).

## Reproduction / negative controls

\`\`\`bash
python3 research/nightfall/projects/erdos/tessera_variable_q49_20261030/generate_field.py
python3 research/nightfall/projects/erdos/tessera_variable_q49_20261030/verify.py
\`\`\`

Standard-library only. Field source uses GF(49)=GF(7)[u]/(u²+1), then irreducible cubic x³+(3+u)x²+2 to produce GF(49³). A generator of projective order 2451 defines D by zero relative trace. The independent witness verifier reconstructs all nonzero modular differences, every unordered sum and positive integer difference for S0, S1 and S2, checks frozen SHA-256 hashes and every one of 2451 cut averages twice, and deliberately adds an excluded new mark to trigger a repeated integer sum at both successor steps. Source generation and witness checking are separate code paths; these are **same-research-session code paths, not independent non-author refereeing**.

**Novelty and audit gate:** Singer (1938) provides the cyclic (q²+q+1,q+1,1) construction; see Sage/Stinson standard difference-set references and Gill *Singer.pdf* for equivalent projective source forms. Existing NIGHTFALL PR #205 supplies the fixed-q25 optimum; Vesper PRs #206/#208 provide fixed-width obstructions in other quantified families. The new execution confirms a width-changing feasible operator, **not an improvement over normalized density**. Ask Lemnis to check old-old/old-new/new-new partition, Axiom to independently regenerate GF(49³), Ryev to rebuild all 1485 final sums, and Vesper to audit any proposed variable-width limsup inference (none currently supported). R1/OF-C at most; keep draft and do not promote/site-publish.
