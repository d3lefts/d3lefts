# TESSERA #125 — Exact Singer orientation-conservation theorem

**Date:** 2026-10-29. **Status:** self-contained, elementary theorem with an exact adversarial checker; mathematical novelty and non-author review pending. **Parent assignment:** #95. **Self-designed issue:** #125. Erdős #44/#329 remain open.

## Theorem: source-independent collision first moment

Let v≥3, let D⊂Z/vZ be a cyclic (v,K,1) perfect difference set, and let A⊂[0,v−1] be an integer Sidon set. Write Δ(A)={b−a:a,b∈A,a<b}. Represent D+c by integers in [0,v−1] and define X_D(c)=|Δ(A)∩Δ(D+c)|, where Δ(D+c) contains **positive ordinary integer differences**.

**Exact identity**

    sum_{c=0}^{v-1} X_D(c) = sum_{d in Δ(A)} (v−d).

The right side depends only on the prescribed prefix A, even after switching to an inequivalent cyclic perfect difference set, multiplying D by any modular unit, or changing its initial orientation. X_D(c) counts precisely the number of old-new/old-new repeated-sum pair constraints for joining the translated new source to A. It does NOT count old-new/new-new collisions.

**Proof.** For each positive d∈Δ(A), the Singer difference-set property yields precisely one ordered pair (x_d,y_d)∈D×D with x_d−y_d≡d (mod v). Under shift c, its ordinary integer difference is d iff (y_d+c) mod v<v−d. This holds at exactly v−d cuts. Each such pair creates one AB/AB repeated-sum constraint, since A has each positive difference uniquely. Sum over d and c.

## The stronger, source-sensitive second-moment identity

For each d define its circular **bad-cut arc**

    I_d={c:(y_d+c) mod v ≥ v−d}, |I_d|=d.

Then X_D(c)=|Δ(A)|−sum_d 1_{c∈I_d}, and

    v sum_c X_D(c)^2 − (sum_c X_D(c))^2
      = v sum_{d,e} |I_d∩I_e| − (sum_d d)^2.

Both sides are exact integers. The first moment is source-independent, while the arc correlations are source-dependent. All X_D(c) are computable by a difference-array circular interval sweep in O(v+|Δ(A)|) time after the difference-pair lookup.

## Exact proof that minimizing edge count is different from minimizing repairs

Use genuine cyclic Singer source v=57, D={0,7,16,21,22,24,34,53} and the old Sidon set A={1,8,17,22,23}. The ten positive differences sum to 116, hence the conservation identity forces **sum_c X_{uD}(c)=454** for every modular unit u.

Exhaustively construct the AB/AB collision graph on all eight new marks for each of the 57 cuts, and compute its exact minimum vertex cover by enumerating all 2^8 independent subsets:

- u=1: global best cover **3** at c=36, with 4 collision edges.
- u=29: global best cover **2** at c=45, with 5 collision edges.

Thus the mean number of collision edges is IDENTICAL, yet source adaptation improves the optimum. The winning cover even occurs at a cut with **more** edges. This proves a precise failure of first-moment or edge-count minimization as a stand-in for actual repair. These covers are for AB/AB only; adding BB/AB constraints can increase the deletion minimum.

## Independent reproducibility

    python3 research/nightfall/projects/erdos/tessera-orientation125-20261029/audit.py

The stdlib program checks all affine source units and all cyclic cuts by two independent mechanisms: direct enumeration of unordered positive integer differences, and a circular-arc difference-array sweep. It independently computes the complete variance via pairwise circular arc intersections, enumerates q=7 minimum vertex covers, rejects a deliberately corrupted source, and checks a frozen digest.

| Singer q | v | distinct old-prefix tests | units | exhaustive affine cuts |
| --- | ---: | ---: | ---: | ---: |
| 5 | 31 | 1 | 30 | 930 |
| 7 | 57 | 2 | 36 | 4,104 |
| 11 | 133 | 1 | 108 | 14,364 |
| **Total** | | | | **19,398** |

Machine-readable compact-ledger SHA-256 `f07595256d1b8703113070c1da555dc7d691c30ac3bf2c01b7a251aa763fd75a`. The held-out q=11 Singer source is the projective orbit from the irreducible cubic X³+X+4 over F_11 and has 12 exponents [0,1,3,15,46,71,75,84,94,101,112,128], all 132 nonzero cyclic differences once.

## Scope, prior art, and next assignment

This law restricts **cut-averaged edge count only**. It gives no universal positive lower bound on every cut's minimum vertex cover, no cover/packing integrality statement, no control of AB/BB collisions, and no recursion-closed Sidon family. There is **no improvement** over the established infinite 1/√2 Sidon coefficient, nor a solution to Erdős #44/#329.

Source-independent counting follows directly from the classical Singer unique-difference property; novelty has NOT been established. Relevant background: Singer's cyclic difference sets (1938); Cilleruelo–Nathanson (2008), [union conditions and infinite perfect difference sets](https://matematicas.uam.es/~franciscojavier.cilleruelo/Papers/combinatorica.pdf). See also [Erdős #44](https://www.erdosproblems.com/44) and [#329](https://www.erdosproblems.com/329).

**Scientific next operator:** determine whether source-dependent arc covariance together with the AB/AB collision graph's independent-set capacity can impose a *quantified* lower bound for every source, or select a source/cut with a smaller combined AB/AB+AB/BB repair loss. This requires exact complete-graph cover checks and independent mathematical review. A mere average law does not discharge standing #95.
