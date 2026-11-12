# Frozen source identity and repository custody

**Original pre-referee bundle:** NIGHTFALL_Publication_Package_20261111.zip, generated November 11 2026, 61 entries and 4.5 MB. It is linked in the research conversation but not stored under this GitHub path. Publication bundle's original REPLAY.sh and root SHA256SUMS remain the complete local artifact manifest.

## Existing GitHub source and runnable checkers

| Work | Canonical repository source | Exact replay command |
| --- | --- | --- |
| Quantum sharp SLD spectral inequality | papers/quantum-sld-tensorization/THEOREM_AND_AUDIT.md | python3 -I papers/quantum-sld-tensorization/checks/check_trine_score_exact.py && python3 -I papers/quantum-sld-tensorization/checks/check_spectral_constant_exact.py |
| Binary/simple Hermitian no-extra-loss | research/nightfall/2026-11-sld-transfer-sharpness/SLD_Exponential_Separation.tex | python3 research/nightfall/2026-11-sld-transfer-sharpness/check_sld_separation.py |
| Werner k-dependent window | research/nightfall/projects/werner-atlas/ANALYTIC_CONTINUATION.md | python3 research/nightfall/projects/werner-atlas/verify_three_block_uniform.py |
| Quadratic influence v8 | papers/finite-product-influence/Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex | python3 papers/finite-product-influence/check_v8_exact.py && python3 papers/finite-product-influence/check_rank_posterior_exact.py |
| Four-shuffle N4 | research/nightfall/2026-11-four-shuffle/verify_four_shuffle.py | python3 -I research/nightfall/2026-11-four-shuffle/verify_four_shuffle.py |
| Five-shuffle N5 | Full sources **not yet in repo** | See SHUFFLE_N5_CERTIFICATE_STATUS.md; original unpacked bundle runs bash 04_Shuffle_Thresholds/repro/run_all.sh |

## Original research package LaTeX SHA-256 values

- SLD_Sharp_Tensor_Information.tex: 2e1d7d426825851d959122320b386a7a476d9a3c8839f4a81a4b9a9539072d6b
- Werner_Finite_Copy_NPT_Window.tex: 6847aa209416a61eedf129d82e5fb5e8117591ce21996a95fdfdebeeb8516847
- Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex: 8544ca9dcc21a31df7b5b52de7eaa56f59a85de2a6f3bb4f45af0638bc58b832
- Exact_Four_Five_Shuffle_Thresholds.tex: 6340f7b031d4ef6940e8bd480a306972d3130711daa10e9daea0985fe228710a
- Multiscale_Hypermatching_Certificate_Calculus.tex: d33286dc78d5ed4baebdcdcbb91e56a8b117898bf8d727f52826f73825c9b621
- Publication_Readiness_Dossier.tex: 4346a412f82c66cc39d32b96ede3151312dda16770b6e6e42e0b6daacbd84e05

These are **package** hashes, not a claim that corresponding bytes are hosted by GitHub. The existing frozen v8 TeX/manifest are unchanged.

## Original author-side replay receipt

Original session verified six original v8 source hashes, optimized constant regressions, 1,638 posterior and 384 rank tests; SLD rational spectral/physical checks and 600 Hermitian tensor tests; Werner three-site coefficient identities, strict odd-tail margin greater than 2.036635971e-8 and selected 24/25-copy checks; exact N4/N5 full upper-graph/lower-witness replay (302/107,480 paths, eight exceptions and 55 lower-witness windows).

Finite replay **does not** establish general theorem correctness, imported source endpoint claims, originality or human referee acceptance. Missing N5 public source remains a release blocker. No external submission occurred.