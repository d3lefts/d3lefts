# Upstream evidence and ingestion audit — v0.2

## COSTEP (2026) source and data quality

- Verified upstream commit (as fetched this session): `kennyuren/COSTEP` `219887764046ee8cbd5288fd1a94625ac2de006b`.
- `Run_COSTEP.m` blob `fa375f0ccc00326c9b17faaec764ad27c3f55e2c`; `README.md` blob `ad3b0e855235b28c0175dfccfe94c71a22093728`.
- **Observed code defect**: `Train_Data{i,8}` is reassigned repeatedly from distinct named disturbance arrays; the saved training structure therefore does not retain all requested fields. A previous `Train_Data{i,8}=ans.IDV_13` is silently overwritten.
- **Experimental design issue**: test loop is `for j = 1` even though the training loop is `for i = faultList`; multi-fault test results are not produced as implied by the prompt.
- **Unverified configuration**: control-mode input `M` does not appear to be applied in the visible script, and the path in `save("file_location/file_name",...)` is placeholder text.
- MATLAB variable `ans.XMEAS` and `ans.XMV` are not in this environment and were **not** inspected. Do not assume numeric array shape, unit conventions, event times, or operation mode from the README alone. The upstream text's generic `writematrix(workspaceVariables, ...)` is not a guarantee that Simulink outputs have a CSV-ready numeric matrix form.
- `export_costep_arrays.m` is only an array-to-CSV contract checker/export; it is **not** a run script and was not executed without MATLAB. A trusted local runner must explicitly set and verify controller, mode, seed, activation time, logging, signal labels, model SHA, and output dimensions before calling it.

## DTU 2021 reference dataset

- DOI `10.11583/DTU.13385936.v1`, CC0; 28 faults, six modes, 500 seeds per fault, 100 hours at three-minute sampling; about 132.96 GB full archive.
- The exact provider file list and README were **not retrieved**: browser rendering exposes only the item-level description; container outbound network cannot access Figshare API. NO DTU raw trial has been read or analyzed.
- `validate_normalized_pair.py` will accept a verified, normalized pair with exact sha256 and matching dataset/model/mode/seed/time, but a manifest's `authenticated_by` field is **not a cryptographic attestation**. This is an integrity/schema gate, not proof of origin.

## Independent historical TEP source probe (not DTU and not COSTEP)

- Reference GitHub repository `jkitchin/tennessee-eastman-profbraatz`, commit `9a6c8e5fcef4a2850778704e7793c87b0a187005`, original Braatz/Chiang FORTRAN lineage.
- `data/d00.dat` blob `ffcb9a1b4f34412bc3ef9a91ff19862e720f3c42` has **52 rows × 500 columns**, therefore must be transposed for a 500-sample training matrix. This **contradicts** the accompanying README's general 480-sample/52-column claim.
- `data/d00_te.dat` blob `a64b904657520e922bc5480031b52824e020d7c5`, 960 × 52.
- `data/d01_te.dat` blob `fc149090376bc4f1a33dd8c324b9a031a9972458`, 960 × 52.
- `original_tep_probe.py` requires these blob hashes, normalizes orientation, and reports a predeclared five-variable descriptive 3-SD-threshold test with 160-sample pre-fault window **assumed** from conventional TEP test protocol. This is a source-backed monitoring sanity check, *not* a DTU evaluation, a paired-seed experiment, certified sensor design, or any mission-control authorization.
- The initial source computation used the connected GitHub file contents and a separate JavaScript implementation. Direct replay of the Python script on downloaded raw data remains pending; the container cannot reach GitHub raw URLs. All numerical findings remain **provisional** until local replay and independent review.

## Next decisive source experiment

1. Obtain native DTU README and a single intact normal/fault seed/mode pairing from the provider, not any derived resampling.
2. Preserve provider file ID, native checksum, downloaded SHA256, access date, paper version, sensor labels, fault-onset metadata and operating mode.
3. Reproduce normalized sensor traces, then compare mission-specific evidence acquisition costs to a faithful FASE graph-slice implementation on the identical allowed observations.
4. Obtain a real COSTEP run, confirming config and toolchain, before evaluating source transfer. Do not claim physical safety from either simulator alone.
