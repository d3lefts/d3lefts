# Lemnis self-directed theorem — sharp copy-parity threshold for locally orthogonal rank-r blocks

**Dated:** October 28–29, 2026 · **Research lead:** Devin J. Wright (NIGHTFALL PHASESHIFT) · **Mathematical development:** Lemnis (GPT-6).  
**Classification:** Self-contained restricted-family theorem; analytic proof supplied, independently implemented exact physical partial-trace examples. **External expert referee and exhaustive novelty check pending.** This sharpens the two-block theorem in this PR; it is **not** a general rank-r Werner positivity result, and it does **not** settle unrestricted rank-two undistillability.

## Theorem and exact phase diagram

Fix integers n>=1, r>=2, d>=r, and heterogeneous parameters 0<=t_j<=1. At each site j, take **r mutually orthogonal nonzero local subspaces** V_(1,j),...,V_(r,j) of C^d. Let V_i=⊗_j V_(i,j), take arbitrary complex vectors u_i,v_i in V_i, and set

    X_i = |u_i><v_i|,     C=Σ_i X_i,     rank(C)<=r,
    A_i=||u_i|| ||v_i||,   τ_i=Tr(X_i)=<v_i,u_i>,
    L=∏_j(1-t_j),         M=∏_j t_j,
    Q(C)=Σ_(J⊆[n])(-1)^|J|(∏_(j∈J)t_j)||Tr_J C||²_F.

The **exact polarized interference identity** is

    Q(C)=Σ_i Q(X_i) + (-1)^n M ( |Σ_i τ_i|² - Σ_i |τ_i|² ).        (1)

Each individual rank-one term satisfies Q(X_i)>=L A_i², by the swap-operator bound I-t_j F_j >= (1-t_j)I on the product vector u_i⊗v_i.

Consequently:

* **Even n:** Q(C)>= (L-M) Σ_i A_i² + M |Σ_i τ_i|².  
  **All such C have Q(C)>=0 if and only if L>=M.**
* **Odd n:** Q(C)>= (L-(r-1)M) Σ_i A_i².  
  **All such C have Q(C)>=0 if and only if L>=(r-1)M.**

The "only if" directions are **sharp for every n,r,d**. Select r mutually distinct local basis symbols a_i at every site, write D_i=|a_i...a_i><a_i...a_i| (rank-one diagonal blocks).

* For **odd n**, C=Σ_i D_i has rank r and Q(C)=r[L-(r-1)M]. Thus L<(r-1)M produces a strict negative example.
* For **even n**, choose nonzero complex coefficients z_i summing to zero (e.g. z_1=...=z_(r-1)=1, z_r=-(r-1)). Then C=Σ_i z_i D_i has rank r and Q(C)=(L-M) Σ_i |z_i|², which is negative iff L<M and vanishes at equality.

In particular, for homogeneous t_j=t:

    even n: t<=1/2;
    odd n:  t<=1/(1+(r-1)^(1/n)).

This is a **parity-dependent threshold for the specified locally orthogonal r-block class**. At t=1/2, even n admits every rank-r member of this class, while any odd n and r>=3 admit a negative rank-r diagonal example. For r=2, both cases reduce to the earlier sharp t=1/2 theorem.

## Proof of the exact identity (1)

For i≠h, the supports of X_i and X_h lie in mutually orthogonal local alphabets at **every** site. In the polarization of Q, a proper partial trace over J⊊[n] leaves at least one untraced site where the two operators have orthogonal supports; the Hilbert–Schmidt cross inner product vanishes. Only the J=[n] term survives; it equals (-1)^n M conjugate(τ_i) τ_h. Summing over ordered pairs (i,h) gives identity (1).

For even n, insert Q(X_i)>=L A_i² in (1) and rearrange. For odd n, use |τ_i|<=A_i and

    |Σ τ_i|² - Σ|τ_i|²
      <= (r-1) Σ|τ_i|²
      <= (r-1) Σ A_i²,

a direct Cauchy–Schwarz inequality. The explicit diagonal examples prove necessity, including zero/equality parameter cases. All quantifiers are over arbitrary complex vectors; the proof does not project any low-rank block into a potentially high-rank sector.

## Reproducible exact controls

Companion program \`verify_multiblock_parity.py\` computes Q from **all physical partial traces**, independently of the swap-operator derivation. Controls:
- Sharpness at homogeneous endpoint t=1/2 for n=1..5 and r=2..4 (compatible d>=r).
- Even-n rank-three phase-balanced zero-energy examples (coefficients 1,1,-2), and negative examples when L<M.
- Odd-n rank-three exact endpoint negatives n=1: -3/2, n=3: -3/8, n=5: -3/32.
- Noncollinear complex u_i,v_i in a two-dimensional local block, plus additional singleton blocks, n=2,3 and heterogeneous rational t_j: exact cross-term identity (1) and the spectral lower bound.

The exact example statuses are checked computationally; the theorem's universal quantifiers follow from the algebraic proof, rather than finite enumeration.

## Prior-art boundaries

Closest mathematical background: the partial-trace rank criterion in **Pablo Costa Rico, Letters in Mathematical Physics 115 (2025)** (DOI:10.1007/s11005-025-01935-y); **Bharti, Gajjala, Haug (2026), arXiv:2607.24479** on tensor-factorized witness families and finite-copy inequalities. The tensor-product swap positivity and Cauchy–Schwarz steps are elementary and may yield this classification as an immediate corollary of earlier formulations. No worldwide first-discovery claim is supported without a closer literature review.

**Research use:** The parity distinction gives a clean negative/positive control suite for any proposed "rank-r from rank-two" transfer: a proof that incorrectly extends the even-n conclusion to odd n and r>=3 is falsified by the explicit r-point diagonal example. The result is a **restricted** exact family, not a lower bound on global rank-r positivity.
