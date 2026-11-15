# Exact replay provenance — NIGHTFALL dependent/noisy recertification v0.2

Research checkpoint UTC 2026-11-15. This branch records the theorem, audit synopsis and claim status. The full **self-contained Python source and generated 549-state certificate** are preserved in the accompanying conversation artifact `NIGHTFALL_Dependent_Noisy_Authenticated_Recertification_v0_2_20261115.zip`; they are not yet checked in as executable files on this PR.

## Frozen complete-archive receipt

- Zip SHA-256: `6675c36566f22ed13ddb00063082a6590be9b18eb1e9151ec65a22714556f13e`
- Generated 549-state `bellman_receipt.json` SHA-256: `1299871f6d5eae420736e127e569994e319f2647218b57540c05306ab96b1045`
- Ordered exact independent brute policy comparison SHA-256: `d5cfdaf9a499badbf3d57255304ac14c43131b5505f0d48dd394784e2e8e95c8`.
- Local fail-closed command: `python3 make_receipt.py && python3 run_all.py`. This command passed at the frozen local checkpoint; no GitHub CI or Lean receipt is claimed for v0.2.
- Strict exact checks: 54 independent contingent-policy comparisons, 549 Bellman history nodes, 8 cache-attestation rejection cases, 8 additional falsification controls, and a separate exact primal-dual LP with global conditional class error budgets both 1/8 and optimal cost 3 versus deterministic cost 5.

## Current limitation

This is a calibrated **finite mathematical model**, not an operational authorization service. Source-factor truth, complete change-impact dependency discovery, trust anchor and revocation, actual sensor reliability, unknown dynamics and superintelligent-agent behavior are external assumptions. Do not promote to a deployment certificate or globally original theorem without an independent source review.

The on-disk bundle contains `SHA256SUMS.txt` pinning each original input, checker and proof; the SHA-256 entries are a proof-replay certificate for the **bundle**, not an assertion that GitHub markdown file hashes coincide with every original local source byte.
