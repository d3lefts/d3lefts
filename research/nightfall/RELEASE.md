# NIGHTFALL master release — provenance and publication status

**Research led by Devin J. Wright**  
**Master archive:** `NIGHTFALL_GitHub_Release_2026-10-27.zip`  
**Archive SHA-256:** `77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb`  
**Uncompressed entries:** 214  
**Archive source size:** ~21 MB compressed, 21,707,919 bytes uncompressed.  
**Compiled:** 2026-10-27; GitHub text publication began 2026-10-28.

## Publication-scope hold — owner review required

Before public upload, follow the [publication-scope review gate](PUBLICATION_SCOPE.md) and inspect the actual ZIP contents, including nested archives and PDFs. The expanded archive's published inventory includes `PHASESHIFT_Quantum_Interference_Referee_Draft_20261027.pdf`, while the public research index excludes the associated critical-line research track. A text-index exclusion does not restrict a public ZIP download.

Run the offline advisory inventory:

```bash
python3 scripts/audit_release_scope.py NIGHTFALL_GitHub_Release_2026-10-27.zip NIGHTFALL_Expanded_Research_2026-10-28.zip
```

**Decision required:** explicitly approve full original-byte disclosure, or create a separately named/hash-verified curated public derivative and keep original frozen source privately archived. A scope-redacted ZIP can never retain the original SHA-256. The release-triggered verification job runs after publishing; it is not a confidentiality gate.

## Frozen archive upload checklist — pending owner upload

The files below were frozen before this website correction. Upload their **original bytes** as two assets of the same GitHub Release tagged `nightfall-research-2026-10-28`; keep the names unchanged. As of this ledger update, neither binary asset is publicly downloadable.

| Release asset | Compressed size | SHA-256 | Expected ZIP entries |
| --- | ---: | --- | ---: |
| `NIGHTFALL_GitHub_Release_2026-10-27.zip` | 20,981,017 bytes | `77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb` | 214 |
| `NIGHTFALL_Expanded_Research_2026-10-28.zip` | 22,753,993 bytes | `fca5dba595475783e3482d72d5e4888e76b91c38052a0589577f0fde578b8275` | 226 |

On desktop, use [the release upload page](https://github.com/d3lefts/d3lefts/releases/new) and follow [the release blocker, issue #5](https://github.com/d3lefts/d3lefts/issues/5). Check both hashes locally, publish, then verify anonymous downloads and re-check each downloaded hash. Publishing does **not** itself upgrade an internal replay to an external independent reproduction.

```bash
sha256sum NIGHTFALL_GitHub_Release_2026-10-27.zip NIGHTFALL_Expanded_Research_2026-10-28.zip
unzip -t NIGHTFALL_GitHub_Release_2026-10-27.zip
unzip -t NIGHTFALL_Expanded_Research_2026-10-28.zip
```

Recovering the distinct accepted Arena submission input is tracked in [issue #6](https://github.com/d3lefts/d3lefts/issues/6); neither frozen master release hash substitutes for that input's own SHA-256.

## GitHub publication scope

The public tree contains the evidence-status overview and selected original source texts. Xi/critical-line and prime-frequency source pages are excluded from the present public repository; earlier frozen ZIP inventories remain historically unchanged. **A GitHub text mirror is not a full byte-for-byte mirror of the 214-entry master archive.** In particular, large manuscript PDFs, exact witness arrays, compiled artifacts, NTT residue bundles and several verifiers remain in the separately prepared master ZIP. Their absence from this GitHub tree should not be interpreted as an independent check of their contents.

Source statements in the index are labeled by their own certificates:
- exact finite construction and cross-checked replay (Erdős, finite Sidon);
- source-dependent exact rational deductions (multiple Werner copies);
- mathematical source manuscript / experimental verification (finite-field phase retrieval);
- algorithmic reduction conditional on an imported source theorem (SAT network);
- implementation findings tested on synthetic data (SourceBound);

The master archive contains audit logs named `audit/erdos_full_replay.log`, `audit/werner-direct-margin.log`, `audit/werner-correlated-6-9.log`, `audit/sat-network-compression.log`, `audit/sidon-finite-30.log`, with corresponding project checkers and the full `SHA256SUMS.txt`. This list is a reproducibility map, not proof that those unmirrored files are present here.

To validate a future uploaded master ZIP, compute SHA-256 and compare to the exact value above. After extracting, run the explicit audit commands in [AUDIT.md](AUDIT.md).

No public release of passwords, API tokens, personal account credentials, or unpublished private repository data is authorized as part of this collection. This release is public technical evidence with human-led program credit and manuscript-specific external citations.
