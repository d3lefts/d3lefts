# Cairn Commons C-10 — public evidence reconciliation and referee handoff (v1, 2026-11-22)

**Claim:** https://cairn-commons.com/claims/C-10  
**Research:** NIGHTFALL / PHASESHIFT; research lead Devin J. Wright  
**Decision:** The public-source packaging objection has an existing GitHub-release remedy, but **C-10 remains disputed and externally unreproduced on Cairn** until its claim record is updated and a non-author reviewer actually checks the numeric witness. This document does not promote theorem, originality, or leaderboard status.

## Scope of the claim worth testing

The proposed mathematical statement is the explicit **upper bound only**:

\[
\mu \le Q =
\frac{34788888032212764146872525963225147703298526879}
{91343852333181432387730302044767688728495783936}
=0.380856370118029325246278763656\ldots.
\]

The constructed step function has **N = 131,072** equal cells on [0,2], integers \(A_i\), height denominator \(D=2^{70}\), and \(H=N/2=65,536\). The admissibility conditions are \(0\le A_i\le D\), \(\sum_i A_i=HD\). Define \(B_j=D-A_j\) for \(0\le j<N\) and \(B_j=0\) outside. The exact finite certificate requires

\[
S_k=\sum_{0\le i<N,\;0\le i-k<N} A_i B_{i-k}
\le p=34788888032212764146872525963225147703298526879
\]
for **all 262,143 signed interior lags**, with equality *only* at \(k=-17,280\). The normalization is \(H D^2=2^{156}\). Both f and the support-restricted complement g are zero outside [0,2]; otherwise the continuum bridge is incorrect. Since the overlap is affine between grid translations, the finite maximum is also the continuous maximum, attained at real translation \(135/512\) in the stated orientation.

This does **not** determine \(\mu\), provide a universal lower-bound improvement, or identify an eligible accepted Einstein Arena submission.

## Source reconciliation: the files existed publicly before the objections

The Cairn claim was submitted **2026-10-21** and currently lists **four objections** and **zero attached artifacts**. Review dates: November 2, 3, 7, and 14, 2026. The reviewers checked arithmetic and conditional algebra, but none received the heights or reran the all-lag witness. The first reviewer explicitly offered to reconsider upon attachment.

The missing artifact was **not** the result of an absent public GitHub release:

| Item | Pinned reference / exact identity | What it establishes |
| --- | --- | --- |
| GitHub public release (published 2026-10-29 06:32:46 UTC) | https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28 | An existing public release preceding all four objections |
| Curated math ZIP | https://github.com/d3lefts/d3lefts/releases/download/nightfall-research-2026-10-28/NIGHTFALL_Curated_Math_Evidence_CANDIDATE_v2_20261029.zip | **11,882,806 bytes**, SHA-256 **f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23** (GitHub release asset API metadata, 2026-11-22) |
| Fixed ZIP member | programs/erdos-overlap/frozen-witness/heights_u70.txt | **131,072 integer heights**, re-extracted and verified **2,156,159 bytes** on 22 November; SHA-256 **a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e** |
| Original publicly recorded fresh-download receipt | https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/CURATED_PUBLIC_DOWNLOAD_RECEIPT_20261029.json | An October 29 verification record, **not** a fresh 2026-11-22 binary replay |
| Release CI / exact GMP all-grid check | https://github.com/d3lefts/d3lefts/actions/runs/40831149715 | Completed **success** at commit 67de7b269c8d1f47b31f6f8f56bc073e52014072; job stages include fresh anonymous asset downloads and all signed shifts |
| Replay instructions | https://github.com/d3lefts/d3lefts/blob/d6ea1abc16e7db85701f0d27e94a27c6d965c077/research/nightfall/projects/erdos/EXTERNAL_REFEREE_PACKET_20261029.md | A source-pinned public referee guide |
| Independent checker | https://github.com/d3lefts/d3lefts/blob/d6ea1abc16e7db85701f0d27e94a27c6d965c077/scripts/verify_erdos_independent.py | Python standard-library packed-integer convolution; different from the historical NTT/CRT implementation |

**Important:** C-10 calls the historical private master archive NIGHTFALL_VI_Exact_Seven_Scale_Research_Checkpoint.zip and says to run replay.sh. Do not assert that this exact historical master ZIP is the public curated release. The publicly disclosed, owner-approved **curated** math ZIP contains the same hash-identified **upper-bound witness**. Its publicly supported replay path is below. The historical full seven-scale claims may require additional evidence and should not be automatically approved by replay of the upper-bound witness.

## Minimal anonymous reproduction, pinned to public source

On a machine with internet access, Python 3, and sufficient memory for large Python integers:

~~~bash
git clone https://github.com/d3lefts/d3lefts.git
cd d3lefts
git checkout d6ea1abc16e7db85701f0d27e94a27c6d965c077
python3 scripts/download_nightfall_curated_assets.py public-assets
python3 scripts/verify_erdos_independent.py --self-test
python3 scripts/verify_erdos_independent.py public-assets/heights_u70.txt
sha256sum public-assets/heights_u70.txt
~~~

The downloader anonymously retrieves the two existing approved curated ZIPs, checks exact sizes, SHA-256, ZIP CRCs, every manifest member, and the fixed witness entry. The second checker verifies the **witness hash, count, box constraints, mass, all signed-lag integer coefficients, exact maximum and unique maximizing lag**. The last line must print the pinned witness hash. The checker is not an independent external *reviewer* merely because it uses a different algorithm.

For a **Cairn attachment**, upload the extracted public-assets/heights_u70.txt (reported **2,156,159 bytes**, below the reviewer-stated 5 MB artifact cap), and link both the pinned checker and the curated GitHub ZIP. Do not upload private historical archives.

### Why packed convolution is exact

In the published Python checker each base-\(Z=2^{160}\) digit of the product represents one signed correlation. Each digit coefficient is nonnegative and at most \(N D^2 = 2^{157} < 2^{160}=Z\), so no carries cross coefficient boundaries. The resulting \(2N-1\) digits enumerate all signed shifts exactly. The self-test compares the packed calculation against direct sums on small random arrays. A reviewer should independently reimplement the full calculation, not assume this suffices for external certification.

## Reconciliation of the four objections

1. **Missing heights / unattached archive:** Source release and verifier exist, but the Cairn claim record still has *Artifacts: None*. Supply the actual 2.16 MB witness and stable exact links on C-10. A filename and digest alone do not resolve the objection.
2. **Need finite exact recheck:** Published CI and author-side independent implementations are positive supporting evidence. Another person or an independently controlled reproducer must confirm mass, all 262,143 shifts, the fraction, the lag, and the continuous interpolation argument. A fresh assistant-authored full all-shift GMP replay passed on 22 November, but a genuinely external non-author replay was **not** performed.
3. **Unsupported two-sided headline:** Remove the Wetch lower bound from the *claim statement*. It remains appropriately attributed as a distinct source-reported, not independently rerun, lower-bound line in background discussion. Restrict C-10 to \(\mu\le Q\).
4. **Conflation with ancillary results / current records:** General perturbation and block-average identities can be stated separately; the seven-scale and historical witness-specific numbers need their own complete source packets. Do not call this an established current record: the public Einstein Arena leaderboard currently lists Blob above NIGHTFALL, and the 131,072-cell witness exceeds the Arena's 100,000-entry cap.

**Review state as of this reconciliation:** available public release metadata = confirmed; previous CI = confirmed pass; exact member = freshly extracted from the connected Drive copy of the owner-approved curated release and hash-checked; assistant-authored independent all-lag GMP replay = **PASS**; independent Cairn reproduction = **open**; platform claim status = **disputed**. This is an evidence-custody repair, not proof certification.

## Suggested replacement claim statement on Cairn

> The NIGHTFALL human–AI collaboration reports the explicit rational step-function upper bound \(\mu \le 34788888032212764146872525963225147703298526879 / 91343852333181432387730302044767688728495783936\), using 131,072 cells. The witness and independently implemented integer checker are publicly available in the version-pinned GitHub release and source links below. Internal all-shift replay passed; **independent external reproduction of this submitted claim remains requested**.

Do **not** include Wetch's reported lower bound in the replacement statement.

## Remaining action / promotion gate

**Owner/platform action:** edit or supplement https://cairn-commons.com/claims/C-10; attach heights_u70.txt; link the curated ZIP, pinned checker, and the referee packet; remove the lower-bound assertion from the statement or explicitly correct it with platform support. Ask the prior reviewers for a fresh **reproduce** review using independently controlled software. Keep the proof status disputed or awaiting verification until that review actually occurs. Preserve all original review records.

**Research audit:** receive and archive the external replay command, source, exact witness hash, full all-shift peak, environment, and pass/fail receipt. If the reviewer finds a counterexample, demote the upper-bound claim and preserve it. Do not infer novelty, best-known status, or competition acceptance from a successful finite replay.

**New 2026-11-22 full witness replay (scope-limited):** the container could not directly download GitHub release bytes because DNS access was disabled, so the owner-approved curated ZIP was fetched through the connected Google Drive archive instead. Its **11,882,806 bytes and SHA-256 f01702cd554a727711dfdff2908cc21b28b715689885ae8eadf562bdef878d23** matched GitHub's release asset metadata. ZIP CRCs passed. Extracted member **2,156,159 bytes; SHA-256 a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e** matched the frozen witness. New distinct GMP C++ code (source SHA-256 **e640e82bb42ee9cbed0055634080175426f69ce84c03678c6dd7d32b1a8b086f**) computed **all 262,143 signed shifts** in exact integers, independently direct-summed nine shifts, and found the published numerator/denominator, unique lag **-17,280**, runner-up lag **36,482** and numerator **34788888032196508685160787678357375369567622621**. The exact code and machine-readable receipt are [archived in the C-10 branch](cairn_c10/). This is an *additional assistant-authored* arithmetic reproduction, not an independent non-author reviewer or a verification of all ancillary seven-scale claims. Cairn has **not** been updated.
