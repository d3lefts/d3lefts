# LEMNIS — four-copy Werner positive-eigenmode extension (2026-10-28)

**Research status:** derived restricted-witness theorem; exact internal independent-algorithm checks passed; independent human review and literature priority **pending**. **No unrestricted four-copy endpoint claim.** Research lead: Devin J. Wright (NIGHTFALL / PHASESHIFT); mathematical development and checking assisted by GPT-6 (Lemnis).

## Statement
Let H(a)=(a3-a1-a2,a4-a1-2a2) over F3, with S=F3×{0}, T={0}×F3. Let U consist of 81×81 coefficient matrices supported on row syndromes in S and column syndromes in T, dim_C U=729. Denote Q(C)=sum_{J⊆[4]}(-1/2)^|J| ||Tr_J C||_F².

Under the standard local decomposition M3(C)=span{I3} ⊕ traceless matrices, let E_0 be the tensor subspace with zero scalar factors and E_2 the subspace with exactly two scalar factors. Q's self-adjoint operator has eigenvalues 1 and 1/4 on E_0 and E_2.

Define W_m=E_m∩U^⊥ (m=0,2) and L=U⊕W_0⊕W_2. Exact ranks of projections U→E_0 and U→E_2 are 728 and 272. Hence dim W_0=4096−728=3368, dim W_2=384−272=112, and **dim L=4209**.

For every C=C0+D0+D2∈L, the decomposition is orthogonal, C0=P_U(C), and
**Q(C)=Q(C0)+||D0||_F²+(1/4)||D2||_F²**.
The projection P_U applies coordinate row and column projections, preserving matrix rank ≤2. Therefore the archived nine-word rank-two positivity theorem, plus complementary-syndrome gluing on U, gives **Q(C)≥0 for every rank≤2 C in L**.

This is a **5.77× increase in ambient linear dimension** relative to U, not a measured increase in the fraction of rank-two witnesses certified.

## Exact audit and files
- Independently rebuilt the archived nine-word 25-group certificate and evaluated all **531,441** integer kernel coefficients. Residual histogram (0:81, 4:216, 6:72, 8:216, 12:144). PASS.
- Projected Gram matrices: exact rational elimination in 81 difference fibres gives ranks E_0=728, E_2=272, E_4=1. PASS.
- Separately constructed Fourier evaluation matrices over F7 (primitive third root 2); ranks again 728,272,1. PASS.
- Direct sparse partial-trace tests: 108 split identities; an explicit non-coordinate E_2 vector has norm² 36, Q=9, and Q(C0+D2)=145/16. PASS.
- This session's complete reproducibility bundle **LEMNIS_WERNER_4209_CERTIFICATE_20261028.zip** has SHA-256 `c2ef13db05499d673fabcb037f9a24393e0be6145f8b900d4d31afc7820460b6`. The ZIP was generated in the session; a public immutable release and human review are pending.

## Key caveats and next step
The original nine-word theorem has a self-contained rank-two trace certificate; its coefficient identity was independently re-evaluated here. The spectral lift itself is standard representation theory applied to this particular support. Novelty of the exact 4,209-dimensional application requires separate prior-art review, including Bharti–Gajjala–Haug (arXiv:2607.24479), Song–Chen (arXiv:2607.23416), and Tomar's October 2026 work. No stronger unrestricted parameter bound follows. Next: rank-two-aware inequalities controlling colliding syndrome differences, beyond positive eigenspace directions.

**Verifier scope:** Exact integer/rational/finite-field arithmetic; two distinct implementations built in the same assistant session; no external referee certificate.