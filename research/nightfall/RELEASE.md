# NIGHTFALL master release — provenance and publication status

**Research led by Devin J. Wright**  
**Master archive:** `NIGHTFALL_GitHub_Release_2026-10-27.zip`  
**Archive SHA-256:** `77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb`  
**Uncompressed entries:** 214  
**Archive source size:** ~21 MB compressed, 21,707,919 bytes uncompressed.  
**Compiled:** 2026-10-27; GitHub text publication began 2026-10-28.

## GitHub publication scope

The public tree contains the evidence-status overview and selected original source texts. **A GitHub text mirror is not a full byte-for-byte mirror of the 214-entry master archive.** In particular, large manuscript PDFs, exact witness arrays, compiled artifacts, NTT residue bundles and several verifiers remain in the separately prepared master ZIP. Their absence from this GitHub tree should not be interpreted as an independent check of their contents.

Source statements in the index are labeled by their own certificates:
- exact finite construction and cross-checked replay (Erdős, finite Sidon);
- source-dependent exact rational deductions (multiple Werner copies);
- mathematical source manuscript / experimental verification (finite-field phase retrieval);
- algorithmic reduction conditional on an imported source theorem (SAT network);
- implementation findings tested on synthetic data (SourceBound);
- bounded Xi / reciprocal-Hankel results, distinct from unresolved global statements.

The master archive contains audit logs named `audit/erdos_full_replay.log`, `audit/werner-direct-margin.log`, `audit/werner-correlated-6-9.log`, `audit/sat-network-compression.log`, `audit/sidon-finite-30.log`, with corresponding project checkers and the full `SHA256SUMS.txt`. This list is a reproducibility map, not proof that those unmirrored files are present here.

To validate a future uploaded master ZIP, compute SHA-256 and compare to the exact value above. After extracting, run the explicit audit commands in [AUDIT.md](AUDIT.md).

No public release of passwords, API tokens, personal account credentials, or unpublished private repository data is authorized as part of this collection. This release is public technical evidence with human-led program credit and manuscript-specific external citations.
