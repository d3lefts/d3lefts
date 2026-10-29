# NIGHTFALL / PHASESHIFT — Curated Research and Reproducibility Collection

**Source checkpoint:** October 27–29, 2026. **Publication scope:** owner-approved, curated public derivatives of separately preserved historical evidence. **Research leadership:** Devin J. Wright, with AI collaborators Axiom, Lemnis, Ryev and the named NIGHTFALL research agents. Credits to external source authors are retained in the included research files.

This release attaches two **actual binary ZIP assets**, derived from owner-held research sources and verified against source-member manifests. Their **own byte identities** are listed below; do not confuse them with the private, unchanged 214/226-entry historical master archives.

| Downloadable file | Bytes | ZIP members | SHA-256 |
| --- | ---: | ---: | --- |
| `NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip` | 11,882,806 | 88 | `f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23` |
| `NIGHTFALL_Curated_Supplementary_Certificates_CANDIDATE_v2_20261029.zip` | 1,046,556 | 16 (+78 nested certificate members) | `7c3769047fa247a0abd922bbfafd3a8ab885af62d1cd2c949828805559bb2665` |

The word `CANDIDATE` inside the filename and frozen member notes reflects the original private pre-approval snapshot; the research owner explicitly approved disclosure of **these exact files** on October 29. Filenames and archive bytes were kept unchanged for traceability.

## Programs included

- **Erdős minimum overlap:** finite exact 131,072-cell construction with complete signed-shift certificate and exact rational objective `34788888032212764146872525963225147703298526879/91343852333181432387730302044767688728495783936` = `0.380856370118029325246278763656…`. This is a *mathematical witness*, separate from the accepted Einstein Arena leaderboard score `0.3808564043546676` whose submitted values remain unrecovered in issue #6. No new global lower bound is established.
- **Sidon/additive combinatorics:** exact 30-point finite machine proof, 974-mark construction, and finite SAT encoding. Finite statements must not be marketed as an asymptotic world record.
- **Finite-field phase retrieval and adaptive decoding:** source-scoped proof material, executable tests, and their stated restrictions. External proof/priority review remains open.
- **Werner quantum states:** finite-copy exact arithmetic and restricted-sector positivity certificates, with imported-premise results classified explicitly as conditional.
- **Additional Erdős computations:** reproducibility material and a lower-source exact rational audit dependent on upstream Wetch/Arb analysis that was *not* freshly recomputed.

Each asset contains a member manifest, nested manifest, provenance and exclusions statement. Publication of a finite checker or a result dependent on external theorems is **not** a claim of independent academic refereeing, global optimality, or historically novel mathematics.

## Exclusions and originals

Original master archives are **privately preserved and not published as assets in this release**. The curated bundles exclude the Xi/critical-line research line, the unindexed quantum-interference referee draft, unapproved September originals, private/personnel material, and identified restricted nested upstream sources. The detailed scope authorization is [CURATED_PUBLIC_RELEASE_APPROVAL_20261029.md](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/CURATED_PUBLIC_RELEASE_APPROVAL_20261029.md); see also [PUBLICATION_SCOPE.md](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/PUBLICATION_SCOPE.md).

## Reproduce the bytes

```sh
sha256sum NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip NIGHTFALL_Curated_Supplementary_Certificates_CANDIDATE_v2_20261029.zip
python3 scripts/verify_nightfall_curated_assets.py NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip NIGHTFALL_Curated_Supplementary_Certificates_CANDIDATE_v2_20261029.zip
```

The **release publisher must perform a fresh anonymous download** of both public assets and run these checks on the downloaded bytes. Issue #5 records upload and replay state. Issue #6 remains open for the distinct accepted competition entry.
