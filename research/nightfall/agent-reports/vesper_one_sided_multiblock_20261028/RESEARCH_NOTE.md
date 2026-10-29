# NIGHTFALL / Vesper — one-sided locally orthogonal multi-block Werner theorem

**Research note:** October 28, 2026 (New York) / October 29 UTC. **Research owner:** Devin J. Wright. **Derivation:** Vesper (GPT-6). **Dependency:** Lemnis's two-block theorem in [draft PR #35](https://github.com/d3lefts/d3lefts/pull/35). **Status:** independent elementary proof and exact finite checker; external referee and comprehensive publication-priority audit **open**. This is a *restricted block-family positivity criterion*, never an unrestricted Werner undistillability theorem.

## Sharp parity-dependent theorem

For n≥1, site dimensions d_j≥r≥2, parameters 0≤t_j≤1, and H=⊗_{j=1}^n C^{d_j}, let

    Q_t(C)= Σ_{S ⊆ [n]} (-1)^|S| (∏_{j∈S} t_j) ||Tr_S C||_F²,
    L=∏_j(1−t_j),  M=∏_j t_j.

Choose r nonzero vectors u_i in H and arbitrary v_i in H. Assume only **one-sided sitewise orthogonality**:

    u_i ∈ ⊗_j U_{i,j},   U_{i,j} ⟂ U_{h,j} whenever i≠h.

There are **no restrictions on the v_i**, including no requirement that their local supports be orthogonal to one another. Define C=Σ_i |u_i><v_i|, A_i=||u_i|| ||v_i|| and z_i=<v_i,u_i>. Then rank(C)≤r, and

    Q_t(C) ≥ L Σ_i A_i² + (−1)^n M ( |Σ_i z_i|²−Σ_i |z_i|² ).       (1)

All complex inner products and entanglement across copy sites are allowed.

Consequently:

- **Even n:** Q_t(C)≥(L−M) Σ_i A_i² + M |Σ_i z_i|². Positivity for every such C **iff L≥M**.
- **Odd n:** Q_t(C)≥[L−(r−1)M] Σ_i A_i². Positivity for every such C **iff L≥(r−1)M**.

These are **sharp parameter conditions for this restricted family**, provided d_j≥r, and no implication for all rank≤r matrices is asserted. For r=2, either parity recovers Lemnis's numerical criterion L≥M **while relaxing orthogonality of the right/column factors altogether**. For odd n, adding r≥3 blocks introduces an exact new obstruction at L=M, even though every two-block member stays nonnegative. For even n, the sharp condition is independent of r≥2.

With homogeneous t_j=t and n odd, the r-block condition is (1−t)^n≥(r−1)t^n, or

    t≤[1+(r−1)^(1/n)]^(−1).

For even n, the threshold remains t≤1/2, regardless of r, on this restricted family. This is a parity-of-copy-count phenomenon in the full-trace interference term; not a statement about the physical Werner parameter for arbitrary-rank witnesses.

## Proof

**Rank-one swap lower bound.** For any u,v in H, set Z=|u><v|. By the standard swap/partial-trace identity,

    Q_t(Z)=<u⊗v, [⊗_j (I−t_j F_j)] (u⊗v)>,

where F_j exchanges the two replicas of the j-th local factor. The F_j commute, and each I−t_j F_j is PSD with smallest eigenvalue 1−t_j (since 0≤t_j≤1). Therefore Q_t(Z)≥L||u||²||v||²=L A². This holds without sitewise product structure of u or v.

**Cross-term cancellation.** For i≠h, consider any proper subset S⊊[n] and one j∉S. The matrix Tr_S(|u_i><v_i|) has its **row support** in U_{i,j} at the retained site j, while Tr_S(|u_h><v_h|) has row support in U_{h,j}. Their Hilbert–Schmidt inner product is zero because these local subspaces are orthogonal. The identity includes S=∅ and remains valid for arbitrary overlapping column supports v_i,v_h. Only S=[n] survives, for which Tr(|u_i><v_i|)=z_i. Hence the exact polarized sum is

    Q_t(C)= Σ_i Q_t(|u_i><v_i|)
             +(−1)^n M (|Σ_i z_i|²−Σ_i |z_i|²).

Combining with the swap lower bound proves (1).

**Even n.** From |z_i|≤A_i and M≥0, (1) implies

    Q_t(C)≥(L−M)Σ A_i² +M|Σ z_i|².

If L≥M, nonnegativity follows. If L<M, choose local orthogonal basis words e_i (one basis symbol i at every site), and C=|e_1><e_1|−|e_2><e_2|. Its exact value is Q=2(L−M)<0, so the condition is necessary for r≥2 (additional block factors can be zero in the rank≤r class, or arbitrarily small nonzero contributions by continuity).

**Odd n.** Since |Σ z_i|≤Σ A_i and Σ|z_i|²≥0,

    Q≥LΣ A_i² −M[(Σ A_i)²−Σ|z_i|²]
     ≥(L+M)Σ A_i²−M(Σ A_i)²
     ≥[L−(r−1)M]Σ A_i²,

by Cauchy–Schwarz. If L<(r−1)M, use C=Σ_{i=1}^r |e_i><e_i| with r local-orthogonal product words. The swap bound is then attained termwise, and the cross term is negative, so Q=r[L−(r−1)M]<0. This proves necessity even when all r blocks are nonzero.

Every step preserves the original rank≤r factorization; a coordinate projection of C need not retain the original rank constraint and is never used as a positivity premise.

## Exact physical fixtures and meaningful strictness

1. **Odd-copy, rank-three obstruction:** n=3, d_j=3, t_j=1/2 and C=Σ_{i=0}² E_{iii,iii}; physical eight-partial-trace evaluation gives Q=−3/8. Every two-block subfamily has Q≥0 at the same t, so the r=3 odd-copy requirement is genuinely sharper than simply reusing Lemnis's two-block criterion.
2. **Even-copy, rank-three sharp negative:** n=2, d_j=3, t_j=3/5, C=E_{00,00}+E_{11,11}−2E_{22,22}; Q=−6/5. At t_j=1/2 the same C has Q=0. Both are exact two-site physical partial-trace identities.
3. **Genuinely one-sided, rank-two example (outside Lemnis's original two-sided support premise):** n=2,d_j=2,t_j=2/5, u_0=|00>, u_1=|11>, v_0=|00>+|11>, v_1=2|00>−|11>. The column factors overlap at *both* sites; the two rows are sitewise orthogonal. The four nonzero matrix entries give exact Q=27/5. The theorem certifies Q≥7/5 via A_0²=2,A_1²=5,z_0=1,z_1=−1. The assertion concerns the entire variable-v class, not just this isolated fixture.
4. **Even-copy exact zero at threshold:** n=4,d_j=3,t_j=1/2,C=E_{0000,0000}+E_{1111,1111}−2E_{2222,2222}; Q=0.

The standalone Python checker independently expands **all partial traces** and cross-checks the closed-form expression over 2,000+ rational cases, with mixed-column, endpoint, sharpness and mutation controls.

Run:

    python3 research/nightfall/agent-reports/vesper_one_sided_multiblock_20261028/verify_multiblock_one_sided.py

## Publication boundary and nearby literature

This theorem is an algebraic extension of the Lemnis restricted two-block result (PR #35), **not** a global NPT Werner threshold. It may be an elementary corollary of established partial-trace and block-positive-map inequalities; a dated, same-scope priority search and external specialist review are necessary before any originality claim.

Relevant established sources include:
- Pablo Costa Rico, *New partial trace inequalities and distillability of Werner states*, Lett. Math. Phys. 115 (2025), DOI 10.1007/s11005-025-01935-y.
- Kishor Bharti, Rishikesh Gajjala and Tobias Haug, *Two-copy nondistillability of Werner states: sharp partial-trace inequalities and finite-copy extensions*, arXiv:2607.24479 (July 2026).
- Zhiwei Song and Lin Chen, *A partial-trace matrix inequality and Werner-state distillability*, arXiv:2607.23416 (July 2026).
- Pablo Costa Rico and Michael M. Wolf, *Partial trace relations beyond normal matrices*, Journal of Mathematical Physics 67, 082203 (2026).

This result belongs in a mathematics draft with exact scope and proof ancestry. It should **not** enter the site's Original Findings list until independent proof review, novelty assessment and editorial acceptance.
