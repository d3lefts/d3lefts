# NIGHTFALL — Simon additive transfer by affine-orbit calibration (v1.1)

**2026-11-22. Research checkpoint, NOT Lean-certified or independently reviewed.** Upstream: #988/#990; companion comparison: #992. Author-side scripts: `scripts/simon_k4_exact_audit.py`, `scripts/simon_affine_k5_rank_exact.py`, `scripts/simon_k4_symbolic_certificate.py`.

## 1. Objective, assumptions and results by certification level

Let N=2^m and Q_N be the iid-uniform distribution on full oracle tables Y:F_2^m->[N]. Let Simon_N choose a uniform nonzero s and an injective labeling of the N/2 s-pairs. For the exact homogeneous Efron–Stein level H_k(Q_N), set

`Gamma_k(nu,Q)=sup_{g in H_k(Q), ||g||infty<=1} |E_nu g-E_Q g|`.

- **Elementary exact formulas (paper argument, finite checks):** Gamma_1=0, Gamma_2=1/(N-1)^2, Gamma_3=(N+2)/((N-1)^2(N-2)) for N>=4.
- **Degree-four paper certificate:** for N>=4,
  `(N^2-N-1)/(N-1)^3 <= Gamma_4 <= 18/N`.
  The explicit lower test on an XOR parallelogram proves Theta(1/N) and a dimension-free upper bound follows from four probability probes.
- **Full Conjecture S (provisional, non-author audit needed):** at each fixed k, `Gamma_k(Simon_N,Q_N)<=C_k/N`, with C_k finite and independent of N. The proof uses affine-orbit symmetrization and finite-template calibration; the key rank-triangularity lemma is the priority audit target.
- **General symmetry-transfer candidate:** any nu invariant under AGL(m,2) address permutations and S_N common output-label permutations satisfies `Gamma_k(nu,Q_N)<=B_k delta_k` for fixed k, where `delta_k=max_{|S|<=k} TV(nu_S,Q_S)` and B_k does not depend on m,N. IMPORTANT: the small-N argument is corrected below; the trivial bound Gamma<=2 alone is **not** sufficient for this relative inequality.

No polynomial growth bound in k, q=Theta(log N) statement, or full quantum simulation is claimed. Finite exact checkers cannot certify the universal statements or establish novelty.

## 2. Finite orbit basis and the interpolation operator

Average a bounded exact-level-k g over AGL(m,2) on input addresses and S_N on output labels. This preserves its expectation difference and level, and contracts the supremum norm. Assume m>=k-1 and N>=k. Address k-subsets fall into a fixed finite list of binary affine matroid orbits A, independent of m; their stabilizers G_A are fixed. Let E_pi be the indicator of equality within the blocks of partition pi of [k]. Under the iid product Q_N, the exact-level-k projection P_k=prod_i(I-E_i) kills E_pi whenever pi has a singleton block. For N>=k, the remaining P_k E_pi for partitions with no singletons form a basis of the S_N-invariant pure-k space: the dimension is the inclusion-exclusion count `sum_j(-1)^(k-j) binom(k,j) Bell(j)`, the number of partitions without singleton blocks. Take G_A-orbit averages and then source-address orbit averages. Obtain D_k invariant basis functions U_{A,lambda} with D_k independent of m,N.

Their source kernels satisfy `||P_k E_pi||infty<=2^k` and `||P_k E_pi-E_pi||infty<=(2^k-1)/N`. The second estimate holds because every term with at least one resampled coordinate imposes at least one output collision, with conditional probability <=1/N. For any law nu with delta_k local TV, `|Delta E U_{A,lambda}|<=2^(k+1) delta_k`.

**Finite-template probes.** Fix r=k-1 and c>=k. For a deterministic c-coloring phi:F_2^r->[c], choose a uniform random affine map L:F_2^m->F_2^r and let the full oracle table be Y_x=embed(phi(L(x))). For any bounded g, `|E g(Y)|<=1`. Evaluate U_{A,lambda} on this probe and call the resulting coefficient M_{A,lambda}^N(phi). Replacing P_k E_pi with E_pi changes this by at most (2^k-1)/N, giving a fixed finite function M^infty on all c-colorings, independent of m,N.

**Rank-triangular independence lemma (paper proof requiring independent audit).** Apply the pure-k product projection on the c-color table variables phi. Affine maps that identify two of the k source addresses vanish under this projection. For the surviving maps, output affine rank never exceeds source rank; rank-preserving maps preserve the entire affine-dependence orbit. In any supposed linear relation among the M^infty_{A,lambda}, pick an orbit of greatest source affine rank with a nonzero coefficient, and project onto a target k-address set in that same orbit. Terms of smaller rank cannot contribute, and larger ranks have already been eliminated. The diagonal contribution is a positive probability `prod_{j=0}^{rank(A)-1}(1-2^(j-r))` times a G_A-invariant pure-k output kernel. Those kernels are independent for c>=k, so the coefficients on this orbit vanish. Descend by rank. Hence all D_k probe-column functions are linearly independent.

Choose D_k c-colorings giving a nonsingular rational matrix M_infty; write `L_k=||M_infty^(-1)||infty`, `A_k=2^k-1`. For N>=`N0=max(2^(k-1), k, ceil(2 D_k A_k L_k))`, the row-sum matrix perturbation is at most D_k A_k/N and the inverse satisfies `||M_N^(-1)||infty<=2L_k`. Thus every bounded invariant g has basis coefficient maximum <=2L_k. In the large-N range, a sufficient quantitative transfer constant is `B_k=2^(k+2) D_k L_k`.

**Small-N repair (v1.1).** For N<N0 the trivial bound Gamma<=2 only proves the *Simon-specific* O(1/N) result, NOT Gamma<=B_k delta_k for arbitrary nu with delta_k arbitrarily small. Instead use the actual Efron–Stein decomposition `g=sum_{|S|=k} g_S`. Each component is obtained by k products of I-E_i and one averaging operator from a function of norm <=1, so `||g_S||infty<=2^k`. Therefore
`Gamma_k(nu,Q_N) <= 2^(k+1) binom(N,k) delta_k`.
There are only finitely many N below N0, yielding a finite B_k. This is a substantive correction to the previous comment/note, not a new all-N experimental certificate.

## 3. Simon local comparison and final proposed consequence

On any k addresses, a nonzero hidden shift can connect one pair only if s equals one of <=binom(k,2) differences, with probability <=binom(k,2)/(N-1). Otherwise the k outputs are sampled without replacement; coupling with iid uniform labels costs <=binom(k,2)/N. Hence `delta_k<=binom(k,2)(1/(N-1)+1/N)<=3 binom(k,2)/N` for N>=2. Combining the symmetry transfer with this coupling proves the stated C_k/N conclusion **conditional on independent confirmation of the rank-triangular lemma and finite-basis scope**.

Via #990's degree-K additive risk certificate, this would transfer fixed-(d,q) squared risk at O_{d,q}(1/N), K=max(2d,d+q). It does not transfer growing-degree guarantees.

## 4. Sharper degree-four finite certificate

For a four-address configuration A (XOR parallelogram) or I (affinely independent), let P denote the six pair-equality indicators, T the four triple-equality indicators, B the three disjoint-pair product indicators, and A0 the all-equal indicator. The exact-level-4 kernels are
`h_A=A0-T/N+P/N^2-3/N^3` and `h_B=B-P/N+3/N^2`.

Constant labeling, iid fair two-color labeling, random affine one-bit labeling and random affine two-bit labeling give four bounded probability probes. With t=1/N their 4-by-4 matrix has determinant `27(1-t)(1-2t)(1-3t)/2048` and the Simon difference functional has weights

`w0=t(27t^2-7t+1)/(3(1-t)^2(1-3t))`,
`w1=8t^2(1-8t)/((1-t)(1-2t)(1-3t))`,
`w2=-4t/(1-t)`,
`w3=32t/(3(1-t))`.

Their absolute sum is <18t for N>=8. For N=4, the trivial Gamma_4<=2 suffices. An explicit centered disjoint-pair equality product on an XOR parallelogram gives lower bound `(N^2-N-1)/(N-1)^3`. The separate SymPy script checks the determinant and weights identically as rational functions; the exact enumeration script checks Simon tables for N=4 (36 tables) and N=8 (11,760 tables). The k=5 script enumerates affine maps and verifies a nonsingular 5-by-5 calibration determinant `86986431/9444732965739290427392`.

## 5. Independent review, prior art and next tests

**Independent audit request:** (A) prove or disprove the diagonal stabilizer claim for all k, (B) independently derive the homogeneous partition basis and show rank filtration survives orbit averaging, (C) replay k=5 determinant using separately authored enumeration, (D) search for an invariant bounded-degree counterexample to coefficient control, (E) charge C_k growth and determine useful K(N) regimes. A failure at any stage demotes the all-k claim without erasing k<=4 finite certificates.

Nearby prior art: Candela, González-Sánchez & Szegedy (2024), *On F_2^omega-affine-exchangeable probability measures*, Studia Mathematica 279:1–69, DOI 10.4064/sm230505-27-8 (limit theory for densities of linear forms). This connection makes a broad priority claim especially premature. Classical k-wise independence, Efron–Stein projections, Fourier low-degree methods, and Simon bounds must also be credited. No date-specific exhaustive novelty clearance has been performed.

**Stop rule:** Merge/archive as *provisional research and reproducibility*, not as independently certified theorem; require non-author paper audit + Lean kernel replay before promotion to theorem status. External submission remains human-authorized.
