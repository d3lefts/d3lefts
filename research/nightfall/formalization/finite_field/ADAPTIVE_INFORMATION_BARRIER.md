# Symmetry–information barrier for finite-field power sensing

**Status (2026-10-30, post-prior-art audit):** exact mathematical argument; the universal arithmetic inequality compiled under pinned Lean 4.35.0 with only standard foundational dependencies (propext, Quot.sound); the orbit/decision-tree theorems are not yet formalized; no independent theorem review or originality claim. This package is a falsification / corrected lower-bound result, **not** a claim that the general adaptive query optimum is solved.

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

**Established prior art:** this planar optimum is already an elementary special case of Héger–Patkós–Takáts, *Search Problems in Vector Spaces* (arXiv:1309.6731, 2013/2014), §3. It must not be presented as a globally new finding.

## Exact checkpoints
| q | d | k | output A | orbits N | global LB | branch LB | best known comparison |
|---:|---:|---:|---:|---:|---:|---:|---:|
| 3 | 2 | 2 | 2 | 5 | 3 | 3 | 3 |
| 5 | 4 | 2 | 2 | 7 | 3 | 4 | 5 |
| 5 | 4 | 3 | 2 | 32 | 5 | 6 | 9 (established sharp result) |
| 5 | 4 | 4 | 2 | 157 | 8 | 8 | — |
| 25 | 4 | 3 | 7 | 3907 | 5 | 5 | — |

Python validation: arithmetic expansion checked for 810 cases (2<=d<=10, 1<=r<=10, 2<=k<=10). The identities themselves prove the universal result; finite sweeps are only replay checks.

## Prior art and limits — completed comparative audit (2026-10-30)
- **Strong direct overlap:** Tamás Héger, Balázs Patkós, Marcella Takáts, *Search Problems in Vector Spaces*, arXiv:1309.6731 (submitted September 26, 2013, revised January 30, 2014), *Designs, Codes and Cryptography*, DOI: 10.1007/s10623-014-9941-9. PDF: https://users.renyi.hu/~patkos/qsearchrevisedpublic.pdf .
- For the **binary indicator regime d=q-1**, (a·x)^n is zero exactly when x is in the hyperplane ker(a). The cited article studies adaptive membership queries for one-dimensional subspaces; our nonzero binary model is a **restricted query class** of theirs, with hyperplane tests only.
- The cited paper's **Theorem 1.1** establishes that for projective dimension two (vector dimension k=3) the optimal adaptive count, even allowing both point and line queries, is **2q−1**. At q=5 this gives a lower bound **9**, strictly stronger than our first-branch bound **6**. Section 3 gives an adaptive strategy using **only hyperplanes**: the k coordinate-zero tests followed by at most (k−1)(q−2) relative-coordinate tests. For k=3 this is 3+2(q−2)=2q−1. Its first k tests also distinguish the vector **zero**, so the optimum for our indicator oracle including zero is exactly 2q−1. For q=5 this is **9**.
- Our planar k=2 indicator optimum q follows from elementary projective-line identification, already implicit in Section 3 of the 2013/2014 paper. **No global novelty claim for this special case**.
- The general alphabet capacity argument uses classical decision-tree counting, cyclic multiplicative-group cardinality and orbit counting. We have no evidence that its specialization to arbitrary d is a first global result; failure to locate the identical formula for 1<d<q−1 does not establish novelty. The same caution applies to the branchwise fiber bound.
- Distinct but relevant background: Conca, Edidin, Hering, Vinzant, *An algebraic characterization of injectivity in phase retrieval*, https://doi.org/10.1016/j.acha.2014.06.005 . This is complex-valued nonadaptive phase retrieval, not the same finite-field adaptive query model.
- The elementary nonadaptive two-root ambiguity argument and 2k−1 obstruction are distinct from any adaptive lower bound; do not substitute them for adaptive results without proof.
- Current claim tiers: arithmetic `information_power_bound` **kernel-checked with standard Lean foundations**; orbit and decision-tree theorem **mathematical proof only, no independent review**; **world novelty unestablished**, with an explicit preexisting stronger theorem in the binary k=3 specialization. Not a flagship/record/publication claim.
- Generic-signal recovery, randomized errors, additional side information and affine/richer query models require separate analysis. The all-signals result includes zero and cannot be applied silently to a distributional or generic model.

## Next decisive experiment
A separate proof engineer should formalize quotient-orbit cardinalities and a bounded-depth adaptive decision-tree model, then check `N > A^k` kernel-end-to-end. An independent auditor should independently re-derive the general intermediate-subgroup case and determine whether any sharp new bound or matching construction is possible for 1<d<q−1; benchmark against the published projective-search baseline before proposing originality.
