# Independent source-level audit of the proposed rank-free two-query tensor simulator

**Date:** 2026-11-22. **Target:** closed unmerged [PR #1016](https://github.com/d3lefts/d3lefts/pull/1016), source head `537411f2b1bab7e073f430f06d475325576dd99c`. **Status:** independently reproducible finite checks; proposed all-\(L\), all-quantum-circuit theorem remains **unreviewed and unproved by Lean**. This note is an additional audit source, not an authorized journal or record submission.

## Objective / model

A uniform hidden \(s\in\mathbb F_2^{2^L}\) gives the classical oracle parities \(\chi_r(s)\) at rows \(r\in R_L=\{e_0,e_1,e_0+e_1\}^{\otimes L}\), \(|R_L|=3^L\).
Does **every** two-query quantum circuit \(O_s U O_s\), with arbitrary workspace and arbitrary effect \(0\le P\le I\), have a nonuniform original-row classical acceptance estimator with \(O(L^3/(\varepsilon^2\delta))\) parity queries at failure \(\delta\)? Classical preprocessing is not charged; quantum state sampling, worst-secret approximation and constructive runtime are **not** claimed.

The PR's candidate uses a four-slot coefficient decomposition into primitive all-distinct rows, repeated labels, and distinct nonprimitive zero-triple groups. Its central nontrivial dependency is a tensor-matroid circuit bound.

## Strongest externally checked reference

[B. Lovitz and F. Petrov, *A generalization of Kruskal's theorem on tensor decomposition*, Forum of Mathematics, Sigma **11** (2023), e27](https://www.cambridge.org/core/journals/forum-of-mathematics-sigma/article/generalization-of-kruskals-theorem-on-tensor-decomposition/515357D904DD4AD1042F37BBCBC95B35) — **Theorem 4** (splitting theorem) and **Corollary 21** (product-tensor circuit local rank \(>1\) in at most \(n-2\) subsystems). Both statements explicitly apply over an arbitrary field, including \(\mathbb F_2\). They establish the external circuit geometry antecedent, *not* the candidate's quantum interference estimate or historical novelty.

Under the exact \(2\)-dimensional local field, a nonzero product-tensor circuit \(E\) of size \(k\) has \(\sum_j(d_j(E)-1)\le k-2\). This underlies the proposed three-free-sites encoding for primitive four-slot XOR representations. The intermediate combinatorial encoding and **all** quantum grouped-coefficient estimates still require an independent complete proof reconstruction.

## Preregistered finite tests and results

The two audit scripts were written independently of the candidate branch code and first executed locally in exact Python rational/bitwise arithmetic. Inputs, predicted competing outcomes, and results:

| Test | Distinguishing failure criterion | Exact outcome |
|---|---|---|
| Ordered pair nonzero XOR-fiber cap on \(R_L\cup\{0\}\) | Any max \(M\ne2L+2\) | PASS \(L=1..4\): \(4,6,8,10\) |
| All ordered primitive four-label lifts | Missing category or mistaken multiplicity | PASS \(L=1..3\): maximum \(0,312,1992\), with 0/15/255 nonempty nonzero fibers |
| Explicit \(\binom L3\) four-row primitive family | Wrong XOR or dependent rows | PASS \(L=3..7\), witness cardinalities \(1,4,10,20,35\) |
| Actual two-query noncommuting row mixing | Walsh/path expansion disagrees with direct final effect | PASS exact rational circuit at \(L=2\), all 16 secrets |
| Nonzero-frequency trichotomy: repeated/primitive/zero-triple | A four-slot tuple escapes all cases or grouped sum drifts | PASS: 4680 / 3816 / 864 nonzero-frequency contributing ordered lifts |
| Cross-stage coherence nonzero | Simulator silently assumes all pairs are orthogonal | PASS: crossed-stage Fourier contribution nonzero, 7 distinct acceptance values |

Each check is source-exact and reproducible from Python's standard library:

```sh
python3 scripts/check_tensor_t2_rankfree_independent.py
python3 scripts/check_tensor_t2_rankfree_coherence.py
```

The coherence checker constructs a **10-dimensional** one-dimensional-per-frequency rational phase-oracle representation (the more general rank-two-sector case has a different checker in #1002), rational Householder inter-query unitary, and full-rank positive effect \(P=I/2+|\psi\rangle\langle\psi|/4\). It independently confirms direct acceptance equals the four-path XOR expansion and its exact Walsh transform, with nonzero crossed-stage terms. The complexity theorem remains untested outside these finite model families.

## Independent proof-attack obligations

1. **Tensor geometry:** reconstruct the exact inequality from Lovitz–Petrov over \(\mathbb F_2\), then prove that for a minimum-cardinality primitive reference set of size \(\le4\), every alternative representation has at most three *freely variable* local sites after the forced-site patterns and circuit partitions. Audit the \(5^4(1+4\cdot3^6)^4\sum_{j\le3}\binom Lj\) constant, including zero labels and multiplicities of ordered paths.
2. **Quantum path operator:** independently establish the frame inequality \(G_{\rm light}\preceq\eta I\) for **both** first- and second-stage light labels under arbitrary complex workspaces, along with the six single-equality regroupings and their \(\operatorname{Tr}(G_\ell PGP)\) bookkeeping.
3. **Zero-triple case:** rederive \(\widehat T_z=\sum_{a+b=z}t_{ba}\) bounds and each of four survivor positions; check repeated-overlap subtraction and whether 145 is a valid total coefficient in the L² estimate.
4. **Uniform secret model:** confirm Fourier Parseval, fixed heavy-row span, conditional expectation, worst-case query-depth semantics, and original-row charge. A distributional acceptance estimator is weaker than efficient quantum sampling.
5. **Priority:** search the exact correlated repeated-oracle model and relevant Fourier/quantum simulations. No global nonduplication or significance record may be claimed without dated specialist review.

## Certificate / limits / next cheapest test

The previous candidate's formula is not yet an independent theorem:

\[
Q_{\rm class}\le
\min\left\{3^L,
\left\lceil \frac{2(2\sqrt{K_L}+145\sqrt M)^2}
{\varepsilon^2\delta}\right\rceil\right\},
\qquad
K_L=5^4(1+4\cdot3^6)^4\sum_{j=0}^{\min(3,L)}\binom Lj .
\]

Because its constant is large, the theorem may not improve the exhaustive \(3^L\) query bound for small \(L\), even if mathematically correct. The finite checker **does not** establish it; a random search could falsify but never prove an all-\(L\) inequality. A complete, non-author derivation of the opposite-path \(a=b'\) event and four zero-triple survivor cases is the cheapest decisive mathematical audit. Lean should target the finite-field circuit encoding before quantifying over arbitrary complex Hilbert spaces.

**Status gate:** numerical/exact finite witness accepted, paper theorem still provisional. Preserve source mechanism, hypothesis, checker, and failure scope when transferring to Simon/task-aware simulations. No automatic theorem, novelty, record, or website flagship promotion.
