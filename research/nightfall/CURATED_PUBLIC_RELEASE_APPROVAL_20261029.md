# NIGHTFALL curated research publication — owner-approved disclosure set

**Decision recorded:** 2026-10-29. **Public disclosure of the two specified curated v2 derivatives is approved by research owner Devin J. Wright.** Approval is documented in [issue #5](https://github.com/d3lefts/d3lefts/issues/5#issuecomment-6489276164). This is a scope authorization, not evidence of external refereeing or scientific priority.

**Current delivery status:** **PENDING BINARY UPLOAD AND ANONYMOUS VERIFICATION.** These are private source files until real GitHub Release ZIP assets have been uploaded and anonymously retrieved. The proposed tag `nightfall-research-2026-10-28` must be checked for an existing release immediately before creation.

## Exact approved byte identities

| Asset filename (historical pre-approval name) | Bytes | Top-level ZIP members | SHA-256 |
| --- | ---: | ---: | --- |
| `NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip` | 11,882,806 | 88 | `f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23` |
| `NIGHTFALL_Curated_Supplementary_Certificates_CANDIDATE_v2_20261029.zip` | 1,046,556 | 16 (plus 78 nested members) | `7c3769047fa247a0abd922bbfafd3a8ab885af62d1cd2c949828805559bb2665` |

The word `CANDIDATE` and pre-approval language within the frozen v2 bytes record when the derivative was prepared. The owner subsequently approved **these exact unchanged bytes**, not an edited rebranding.

Both files are held in the owner-private Drive folder `NIGHTFALL Frozen Research Release - PRIVATE REVIEW`. Each carries `NOTICE_AND_PROOF_STATUS.txt`, `CURATED_MEMBER_MANIFEST.json`, `NESTED_MEMBER_MANIFEST.json`, and `EXPLICIT_EXCLUSIONS.json`. The local SHA-256, all top-level CRC checks, and nested lineage checks passed before approval and again upon Drive readback.

## Historical masters: NOT authorized for public release

- `NIGHTFALL_GitHub_Release_2026-10-27.zip` — SHA-256 `77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb`, 214 entries.
- `NIGHTFALL_Expanded_Research_2026-10-28.zip` — SHA-256 `fca5dba595475783e3482d72d5e4888e76b91c38052a0589577f0fde578b8275`, 226 entries.

These remain privately preserved without redaction or changed hashes. Excluded material includes Xi/critical-line research, the unindexed PHASESHIFT quantum-interference referee draft, other unapproved originals, private/personal documents, and nested upstream lower-bound sources requiring further disclosure review. See [PUBLICATION_SCOPE.md](PUBLICATION_SCOPE.md). A curated archive **never** inherits an original master's hash.

## Claim status and scientific boundaries

Research lead and owner: **Devin J. Wright**. AI collaborators **Axiom**, **Lemnis**, **Ryev** and other NIGHTFALL agents are credited for their respective contributions; external mathematical source authors retain their cited attribution. Checkers establish specific finite facts; imported-source analytic implications are conditional; mathematical manuscript proofs and novelty claims await independent review.

The 131,072-cell Erdős finite mathematical witness has exact objective

`34788888032212764146872525963225147703298526879/91343852333181432387730302044767688728495783936`

`= 0.380856370118029325246278763656…` (maximizing signed lag `−17280`). This is **not** the distinct accepted Einstein Arena result `0.3808564043546676`. The accepted submission values remain unrecovered under [issue #6](https://github.com/d3lefts/d3lefts/issues/6).

The conditional Erdős lower-source replay does not independently regenerate Wetch's upstream Arb integrals. Werner source-dependent inequalities retain their external analytic assumptions. Exact code replay is separate from independent mathematical proof refereeing and historical novelty determination.

## Safe publication procedure

1. Retrieve the two **exact approved v2** ZIPs through an authenticated, owner-authorized environment. Do not fetch or attach either historical master.
2. Run `python3 scripts/verify_nightfall_curated_assets.py <math.zip> <supplementary.zip>` and stop on any mismatch, duplicate/path hazard, nested-member failure, scope violation, or ZIP error.
3. Confirm proposed release tag does not already exist. Upload **both ZIPs as actual binary GitHub Release assets** using [RELEASE_NOTES_CURATED_20261029.md](RELEASE_NOTES_CURATED_20261029.md). A text mirror, link-only release, or private Drive URL is insufficient.
4. Freshly download both assets anonymously, compare their SHA-256s/bytes/entry counts against the table above, inspect member manifests, and rerun applicable standalone mathematical checkers. Record pass/fail/inconclusive with the exact commands.
5. Only then update `docs/evidence.html` with verified direct public binary links and open a narrowly scoped website PR. Preserve all four flagships, 33 dossiers, three Original Findings, and attribution/proof boundaries.
6. Run repository and website CI, browser visitor/mobile checks, then merge and verify GitHub Pages. Close issue #5 only after the archive assets and website links have passed public verification. Keep issue #6 open until the accepted Arena input is actually recovered.

**Reason publication is pending:** Connected GitHub actions available to the release auditor cannot create/upload GitHub Release binary assets, and authenticated private Drive downloads cannot be transferred anonymously by those actions. Approval resolves the disclosure gate; it does not itself complete binary upload. Use a capable browser/Work environment for the upload, without requiring a desktop file transfer by the owner.
