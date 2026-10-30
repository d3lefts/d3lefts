# Symmetry–information barrier for finite-field power sensing

**Status (2026-10-29):** exact mathematical argument; the universal arithmetic inequality compiled under pinned Lean 4.35.0 with only standard foundational dependencies (propext, Quot.sound); the orbit/decision-tree theorems are not yet formalized; no independent theorem review or originality claim. This package is a falsification / corrected lower-bound result, **not** a claim that the general adaptive query optimum is solved.

## Formal model
Let q be a prime power, k >= 2, n > 0, d=gcd(n,q-1)>1, V=F_q^k, and mu_d be the subgroup of n-th roots of unity. An oracle call chooses a linear functional a_j, potentially depending on all earlier answers, and returns (a_j(x))^n. The unknown x ranges over **all of V, including zero**. The algorithm must identify x modulo the global mu_d action, for every x. Each call counts as one measurement; no additional side information is allowed.

There are A=1+(q-1)/d possible oracle outputs and N=1+(q^k-1)/d signal orbits, by the cyclicity of F_q^* and freeness of mu_d on V\\{0}. An adaptive algorithm with worst-case at most m calls yields at most A^m answer strings (pad early termination). Hence A^m >= N.

Write q=1+d*r, A=1+r, where r=(q-1)/d >=1. For k>=2 and d>=2,

    (1+d*r)^k - 1 - d*((1+r)^k-1)
      = sum_{j=2}^k binom(k,j)*(d^j-d)*r^j  > 0.

Therefore N > A^k; m>=k+1. The formal Lean target `information_power_bound` checks the stronger convenient inequality d*A^k < q^k. The pinned Lean 4.35.0 workflow has compiled this proof and audited its dependencies as exactly `propext` and `Quot.sound` (no `sorryAx`). SHA-256 of the checked Lean source: `4c71782cc674e214655b49a6c3d1bf01be8d694107863c64a43b832077cbbcb4`. The strict zero-axiom bridge mode intentionally rejects even these standard foundations; the CI workflow uses a separate explicit foundations-only audit. The finite-field orbit count and decision-tree theorem await formalization.

**Branchwise sharpening.** For every nonzero a and fixed nonzero response y, exactly q^(k-1) mu_d-orbits produce y: there are d scalar roots and q^(k-1) choices of the remaining affine coordinates, then quotient by d. Thus A^(m-1) >= q^(k-1) on that branch. Hence

    m >= max(ceil(log_A N), 1+ceil(log_A(q^(k-1)))).

The nonzero choice a=0 is uninformative, so it cannot beat this bound.

**Exact planar indicator case.** If k=2 and d=q-1 (for instance n=q-1), then y indicates a(x)=0 versus a(x) !=0. There are q+1 projective directions and an additional zero class. A nonzero linear test vanishes on exactly one projective direction. Along an all-nonzero transcript, m tests exclude at most m directions; with m<q two distinct nonzero directions remain indistinguishable. Conversely, q fixed linear forms with pairwise distinct kernels identify the tested q directions by their unique zero, the one untested projective direction by all-nonzero answers, and x=0 by all-zero answers. Hence **the optimal adaptive worst-case measurement count is exactly q** (q>=2).

This sharp planar result is related to established finite-geometric search and should be checked against prior literature before any originality claim.

## Exact checkpoints
| q | d | k | output A | orbits N | global LB | branch LB | planar optimal if applicable |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 3 | 2 | 2 | 2 | 5 | 3 | 3 | 3 |
| 5 | 4 | 2 | 2 | 7 | 3 | 4 | 5 |
| 5 | 4 | 3 | 2 | 32 | 5 | 6 | — |
| 5 | 4 | 4 | 2 | 157 | 8 | 8 | — |
| 25 | 4 | 3 | 7 | 3907 | 5 | 5 | — |

Python validation: arithmetic expansion checked for 810 cases (2<=d<=10, 1<=r<=10, 2<=k<=10). The identities themselves prove the universal result; finite sweeps are only replay checks.

## Prior art and limits
- Balan–Casazza–Edidin complement-property framework and the familiar 2k-1 nonadaptive lower bound; see https://doi.org/10.1016/j.acha.2014.06.005 .
- Finite-geometric adaptive search of one-dimensional subspaces: https://arxiv.org/abs/1309.6731 .
- These references make any global-priority/novelty claim inappropriate without deeper comparison. The alphabet and branchwise bounds are elementary counting arguments; value here is correcting NIGHTFALL's measurement model and furnishing exact stop criteria.
- The nonadaptive 2k-1 lower bound extends to this power-ambiguity model by the two-root partition construction, subject to the usual field-dimensional hypotheses; it does **not** apply to adaptive querying.
- A guarantee restricted to generic x, an input distribution, extra side information, or a richer oracle is a different sensing model. Do not use this result to refute those.
- Independent review needed: rederive nonzero branch orbit count, check zero vector, q=3 edge and q=5 planar optimality, inspect Lean's `#print axioms`, reproduce recorded tests. No agent independently reviewed these proofs at registration time.

## Next decisive experiment
A separate proof engineer should formalize quotient-orbit cardinalities and a bounded-depth adaptive decision-tree model, then check `N > A^k` kernel-end-to-end. An independent auditor should separately derive the planar adversarial lower bound and investigate specific prior-art coverage.
