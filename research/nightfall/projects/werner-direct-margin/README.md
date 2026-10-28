# NIGHTFALL PHASESHIFT — Three improved qutrit Werner certificates (six–eight copies)

**Research date:** 27 October 2026  
**Research lead:** Devin Wright (NIGHTFALL PHASESHIFT). Computational mathematical exploration, exact dual reconstruction, and independent software verification were assisted by GPT-6. Quantum-state and partial-trace source theorems are attributed to the external authors identified below. Priority relative to all current literature requires further dated review.

## Main result: three strict quantitative improvements

Under the *same quantitative four- and five-qutrit source assumptions* used by the previous NIGHTFALL peer-review archive, the following sufficient undistillability thresholds hold:

| Copies | Previously archived | This package | Exact improvement | Strict certified dual margin |
|---|---:|---:|---:|---:|
| 6 | 44819/100000 = 0.448190 | **11219/25000 = 0.448760** | **57/100000 = 0.000570** | ~2.67427143473e-6 |
| 7 | 4321/10000 = 0.432100 | **10807/25000 = 0.432280** | **9/50000 = 0.000180** | ~4.55641892023e-5 |
| 8 | 4197/10000 = 0.419700 | **4199/10000 = 0.419900** | **1/5000 = 0.000200** | ~3.86084831173e-5 |

For complex potentially nonnormal rank-at-most-two matrices `C` acting on `(C^3)^tensor k`, with

`Q_k(t,C) = sum_{J subset [k]} (-t)^|J| ||Tr_J C||_F^2`, 

the exact certificate for each row proves `Q_k(t,C) >= M_k ||C||_F^2`, **conditional on the inputs below**. This is a mathematically sufficient undistillability condition for the Werner state at `alpha=-t`. Strictly larger `t` is a stronger statement.

### Formal source contract and its limit

The two additional **quantitative** source inequalities imported from the earlier peer-review archive are:

```
Q_4(4979/10000,C) >= (229/10000000)*||C||_F^2
Q_5(47/100,C)     >= (401/100000)*||C||_F^2
```

They are assumed for every complex rank-at-most-two `C` on four and five *individual physical qutrits*, respectively. We additionally use the known universal three-copy `Q_3(1/2)>=0`, four-copy `Q_4(79/160)>=0` (arbitrary local dimension with the accepted zero-padding extension), the sharp two-group rank-two trace inequality, qutrit dimension-monotonicity, global PSD tensor products, and the universal rank-two trace cap. Original four- and five-qutrit numerical margin claims were extracted conservatively from the published source's printed SDP/error figures. **Independent full replay of that external source's SDP witness remains outstanding.** All dependent values here therefore have the label **certified conditional construction** and are not promoted to unconditional independently refereed theorems.

The new six-copy certificate uses the quantitative source forms directly rather than relying on previously strengthened five-copy endpoints. This removes a lossy intermediate transfer. The new seven- and eight-copy forms also apply the quantitative margins directly.

## New separable spectator mechanism

Write `P_i=|Omega_3><Omega_3|` on the `i`-th qutrit pair, with `Omega_3=sum_i |ii>`. Define

`G(P_1,P_2)=I-(P_1+P_2)/3+P_1*P_2`,

represented as the formal moment polynomial `G(z)=1-2z/3+z^2`.

This spectator is separable across Alice's two local sites versus Bob's two local sites. Specifically, start from the **Alice–Bob product** density matrix associated with `|Phi_3>_A tensor |Phi_3>_B`, where `|Phi_3>=sum_i|ii>/sqrt(3)` is entangled only *within* one party. Twirl independently with local unitaries `U_i` at Alice and `conj(U_i)` at Bob. The normalized sector probabilities in the two commuting projections `Q_i=P_i/3` are exactly `(p00,p10,p01,p11)=(8/9,0,0,1/9)`; the corresponding sector eigenvalues are `1/72,0,0,8/72`. The twirled operator is `G/72`, proving `G` separable. Products `G^2` on disjoint pairs of spectator sites are separable as well.

A rank-two block-positive source may be tensored with `G` or `G^2`; contraction of a rank-two test vector by each product ket/bra from the separable decomposition preserves Schmidt rank at most two. This justifies all rows labelled `Q*source*G` and `Q*G_squared` in the three exact certificates.

## Dual certificates and checker

Each certificate supplies a nonnegative rational multiplier for every named valid profile row and a strictly positive rational residual `M`. Its checkable identity is

`(1-t*z)^k = M + sum(lambda_row * row(z))`

**in the basis of normalized moment coordinates `a_0=1,a_1,...,a_k`**. The equation is an equality of formal coefficient vectors, rather than an assertion that a polynomial evaluated at arbitrary real `z` must be nonnegative.

- `certificate.json` — six-copy rational identity
- `certificate_k7.json` — seven-copy rational identity
- `certificate_k8.json` — eight-copy rational identity
- `verify_independent.py` — standard-library sparse-polynomial exact-arithmetic verifier, independent from the symbolic-matrix rational solver used for certificate construction
- `source_certificates/` — archived four- and five-copy *downstream* rational identities (source assumptions still required)
- `upstream/WERNER_1_TO_14_PEER_REVIEW_20261027.zip` — original referenced peer-review baseline and source contract
- `SHA256SUMS` — file manifest for reproducibility

Reproduce with Python 3, without third-party packages:

```
python3 verify_independent.py
sha256sum -c SHA256SUMS
```

The independent checker reconstructs all source rows from their mathematics, tests the sector-twirl coefficients through direct four-index arithmetic, verifies all exact moment coefficients and positive rational weights, and checks the inherited four- and five-copy downstream dual identities. The finite arithmetic is exact; there is no numerical feasibility tolerance in verification.

## Search outcome and limitations

The initial enlargement of the six-copy spectator family alone plateaued near 0.4471 using zero-additional-margin input theorems. Replacing the inherited endpoint statements by the earlier original **positive quantitative source margins** changed the active constraint and produced the new six-copy value. The method transfers to seven and eight copies with separable correlated spectators and independently verifiable rational identities.

No exhaustive proof of the global optimal six-, seven-, or eight-copy endpoints is asserted. No new result has been established directly from the finite-simple-group classification; that user-supplied chart prompted a representation/symmetry investigation, while the actual mathematical mechanism uses isotropic unitary twirling and exact dual transfer. Dated current-literature priority checks and independent source-SDP replay remain required before record/publication claims.

## Attribution and sources

- Human program leadership and research direction: **Devin Wright**, NIGHTFALL PHASESHIFT.
- New conditional constructions and computational verification: NIGHTFALL PHASESHIFT with GPT-6 mathematical/computational assistance.
- Original external source input and comparison: Tejasvi Singh Tomar, *Undistillability of Werner states from three, four and five copies*, October 2026, https://www.mefyi.com/papers/werner-states-copies/.
- Partial-trace formulation: Pablo Costa Rico, *New partial trace inequalities and distillability of Werner states* (2025), https://doi.org/10.1007/s11005-025-01935-y.
- Two-copy foundational inequality: Thomas C. Fraser, Felix Huber, Balázs Pozsgay, István Vona, arXiv:2607.24309; see the other two-copy source approaches cited in the included prior archive.

The historical source archive SHA-256 and all output checksums are recorded in `SHA256SUMS`.