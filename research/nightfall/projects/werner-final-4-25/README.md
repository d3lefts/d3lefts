# Final Werner certificates, 24 and 25 copies

**Research:** NIGHTFALL / PHASESHIFT, October 28, 2026. **Status:** source-theorem-conditional exact rational certificates. External mathematical and priority review remains open.

## Reported qutrit thresholds

| Copies | Exact t | Decimal | Lower margin |
|---:|---:|---:|---:|
| 24 | 8659/25000 | 0.34636 | 1.634436837843897e-10 |
| 25 | 4323/12500 | 0.34584 | 2.0455225316913627e-11 |

A separate every-finite-copy certificate gives t(k) = 1/3 + 31/(100k) for k >= 3, dependent on the published sharp two-/three-copy theorems. It approaches the PPT boundary with k.

The source's three-site identity is
`9*B3-D3 = (2/3)*J2+(68/9)*J3+(1/18)*Jcap`.
It bounds the first derivative response by `Dk <= 3*k*Bk`. The exact rational odd-tail estimator is reconstructed by the included [constructor](construct_A.py) and checked by the independent [Pascal/closed-form verifier](verify_independent.py). The original SymPy checker remains in the source archive.

## Exact reproduction

```bash
python3 construct_A.py
python3 verify_independent.py
sha256sum certificate.json COPY4_TO_25.csv
```

Frozen original hashes:
- certificate.json: `fcfd9582e193c0d98e9b5fcbe2fb8f22a7f4e1dac4a182598b204a6351e0e1d3`
- COPY4_TO_25.csv: `1bfc555728544215e797d3271999f2fc672c8e7a36a532532ac1c8d6a352ad4c`
- original ZIP `NIGHTFALL_WERNER_4_TO_25_FINAL_20261028.zip`: `86d0b862a44326a305c5402f938753688ccc9a1082c70684ca0f6db1d3c8bc64` (280,232 bytes; 11 entries).

**Mathematical correction (29 October 2026):** Isotropic-state twirling uses `U ⊗ conjugate(U)`, rather than `U ⊗ U`. The archived source PDF contains the incorrect symmetry notation and is pending corrected republication. This dossier records the correction explicitly; the PDF itself has not been silently altered. Any separability step relying on the incorrect symmetry requires independent rechecking. Exact arithmetic alone does not validate the imported two-/three-copy mathematical premises.

The original [approved Werner 4–20 registry](../werner-atlas/README.md) remains a separate evidence tier: earlier 4–18 stronger alternate values rely on quantitatively imported source margins. No automatic replacement occurs.

A separate six-qutrit no-additional-slack source certificate at t=0.4471 is recorded in [the correlated-spectator audit](../werner-correlated-6-9/S2_4471_CERTIFICATE_AUDIT.md); this does not alter the three-column approved registry.

Original recovered source notes: [dimension-uniform 17–23](UNIVERSAL_17_TO_23_SOURCE_NOTE.md), [earlier all finite k](PRIOR_ALL_FINITE_K_PROOF_20261028.md), [earlier checkpoint](RECOVERED_WERNER_CHECKPOINT_20261028_084128.md).

Source comparison: [Tejasvi S. Tomar, October 2026](https://www.mefyi.com/papers/werner-states-copies/). Originality review remains pending.
