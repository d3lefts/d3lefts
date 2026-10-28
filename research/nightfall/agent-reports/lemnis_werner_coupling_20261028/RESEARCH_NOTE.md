# Lemnis: exact cross-syndrome coupling and rank-two positivity tube
**Checkpoint:** 2026-10-28. **Lead:** Devin J. Wright (NIGHTFALL / PHASESHIFT). **Research and checking:** GPT-6 (Lemnis). **Status:** internally exact-checked theorem manuscript; external proof and originality review pending.

## Sharp exact interaction constant

Let `U=P_S M_81(C) P_T` be the archived 729-dimensional four-qutrit complementary-syndrome rectangle, `P` its Hilbert–Schmidt orthogonal projection, and `K=(I-|Omega_3><Omega_3|/2)^{tensor 4}`. Then

`||(I-P) K P||^2 = 1/2`.

The 81 conserved-difference fibres have nine `U` entries apiece. On each fibre the missing-row Gram is `P K^2 P - (P K P)^2`, with the exact spectrum:

| difference weight | fibres | eigenvalues in each fibre |
|---:|---:|---|
| 0 | 1 | 1/32 (×1), 5/16 (×8) |
| 1 | 8 | 3/8 (×9) |
| 2 | 24 | 1/2 (×9) |
| 3 | 32 | 1/2 (×9) |
| 4 | 16 | 0 (×9) |

Total eigenvalues: 729. The sharp constant is *already attained by rank-one input* `X=|0000><0110|`. Exactly, `||K X||^2=9/16`, `||P K X||^2=1/16`, and `||(I-P) K X||^2=1/2`. Thus imposing rank≤2 on the input cannot improve this operator constant.

## Rank-two-safe nonlinear positivity extension

Let `W0=E0∩U^perp` and `W2=E2∩U^perp` from the archived 4,209-dimensional lift `L=U⊕W0⊕W2`. For rank≤2 complex `C`, decompose `C=C0+D0+D2+R` by orthogonal projections onto `U,W0,W2,L^perp`. Write `c=||C0||`, `r=||R||`, `w=||D0||^2+||D2||^2/4`. Then

`Q4(1/2,C) >= w - sqrt(2)*c*r - r^2/2`.

**Therefore `w >= sqrt(2)*c*r+r^2/2` is an exact sufficient positivity condition.** Proof: `rank(P_S C P_T)≤rank C≤2`, so archival base positivity yields `Q(C0)≥0`; spectral eigenmodes kill all cross terms involving `D0,D2`; `Q(R)≥-r²/2`; the exact off-sector norm bounds the remaining cross term by `sqrt(2)*c*r`.

An explicit rank-one witness lying *strictly outside* the old linear lift is
`C=|0000><0000|+2|0000><1111|+|0000><0121|`.
Its decomposition has `c²=1`, `||D0||²=14/3`, `||D2||²=0`, `r²=1/3`, `Q(R)=-1/6`; the sufficient inequality passes strictly, and independent full partial traces yield `Q(C)=73/16`. Hence the criterion certifies a nonempty relatively open rank-one family beyond the original linear witness sector.

## Independent evidence, scope, and next operation

- Exact \(\mathbb F_3^2\) Fourier construction checked all 81 fibres × nine characters.
- Distinct direct-kernel/missing-row Gram checker used exact rational SymPy spectra over all 16 zero patterns and obtained the same maximum 1/2.
- Third checker built the four-site partial-trace quadratic form separately and verified the sharp rank-one input plus strict nonlinear example.
- All checkers passed. Frozen research ZIP: `LEMNIS_WERNER_COUPLING_TUBE_20261028.zip`, **SHA-256 `a7255349f706e03cd04b47c77efbae87ff39887676d55a621edfaf11e9d9ce84`**. This note mirrors the mathematical statement and evidence summary; complete executable ZIP is currently a session artifact pending independent public mirror.
- No improved unrestricted 4-copy threshold is claimed; no first-discovery, external referee acceptance, or global optimality assertion.
- Relevant sources checked October 28: Tomar (2026), 4-copy qutrit t=.4979 (https://www.mefyi.com/papers/werner-states-copies/); Costa Rico (2025), DOI 10.1007/s11005-025-01935-y; Eriksson (2026-10-25), restricted Werner anchor sectors (https://airr.science/papers/ARR-2026-16NB5DD5M18TTBET/). These have distinct constructions; full priority audit pending.

**Next structural target:** colliding syndrome-difference sectors with shared global rank-two factors. The exact sharp rank-one coupling witness rules out simply lowering the off-block operator constant via rank≤2 input restriction.
