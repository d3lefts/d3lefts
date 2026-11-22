# Erdős C1b — strongest located NIGHTFALL bounds (2026-11-22)

**Separate claim identity:** This page does not replace [Cairn C-10](https://cairn-commons.com/claims/C-10), which continues to identify the older October 29 public witness with SHA-256 a574c280f8839503c90076507a27f4c819455fb2512fae6a43b6a17f6a784b8e. The October 22 PhaseShift V3 witness below has a different source identity and hash.

## Strongest recovered NIGHTFALL upper construction

\[
\mu\le
\frac{34788888032172582064857141282352546289212755441}
{91343852333181432387730302044767688728495783936}
=0.38085637011758942610704804175087023177\ldots.
\]

- Exact witness: 131,072 equal-width cells on [0,2]; height denominator 2^70; height bounds [0,1]; exact integral one.
- Reconstructed heights SHA-256: **46ba45724bb7ff98f6b28b4b7ef3bcf2390f747db8ca290ae0f2f0eaba63c59c**.
- 262,143 supported signed correlations, one unique maximizing lag **-17,354**, zero at both boundary lags. Real translations lie between breakpoint events with affine overlap. The runner-up score occurs at **both -5,962 and +5,962** (GMP prints one runner lag, new Python independent replay detects the tie).
- Original October 22 certificate came from a nested archived PhaseShift V3 proof package, via NIGHTFALL_EA36_LOWER_AGENT_AUDIT_20261028.zip / NIGHTFALL_WRIGHT_ERDOS_LOWER_DISCUSSION_HANDOFF_20261022(1).zip / V4_PROOF_PACKAGE.zip / phase_v3/.../exact_u70/heights_u70.txt. This is *not* the public curated C-10 master ZIP.
- Improvement versus the original public C-10 witness: 4.3989913923072190515438 × 10^-13. An incremental exact improvement, **far below the 10^-8 reporting threshold**.

**Evidence mechanism:** The file phase_v3_delta.b85 is a compressed, checkable list of precisely **719 integer-height updates** applied to the October 29 *public* C-10 witness. reconstruct_upper.py downloads only the pinned public release (or accepts a supplied local C-10 witness) and verifies its full ZIP SHA-256, 2,156,159-byte source, source member SHA-256, all mass and box constraints, and reconstructed target SHA-256. This is a durable, publicly replayable construction without changing C-10's original hash.

**Verification:** verify_upper.py is a distinct author-side Python integer implementation of carry-free radix-2^160 convolution. The archived independent GMP C++ check was independently rerun locally on November 22. Both enumerate all 262,143 signed interior lags; selected lags are separately direct-summed. No external non-author audit has been completed.

## Tightened NIGHTFALL lower deduction: conditional

Under the *unchanged inherited* Wetch universal kernel / physical Gram constraints and original central and outer Arb enclosures, the eight exact-rational dual rows now give

\[
\mu>\frac{3806274746266857709}{10000000000000000000}
=0.3806274746266857709.
\]

This is 5.7709 × 10^-15 above the October 27 conditional target 0.38062747462668. That is **not** a structural lower-bound breakthrough. The existing eight-row family cannot justify a materially larger result: a separately checked rational test point bounds every row's pointwise return less than 10^-19 above the new target. This is a ceiling on the frozen proof family, **not** on the actual constant.

lower_tight_bundle.b85 is a byte-pinned compressed archive of the exact inherited rows, source certificate, and new rational-window certificate. verify_lower.py independently checks hashes, every strict rational endpoint, the complete eight-window mean cover, and the exact ceiling. The script expands the source files for inspection in an ignored local directory.

**Critical limitation:** No fresh original Wetch transcendental/Arb integrations or independent proof of the universal analytic reduction were completed. The *finite rational calculation* is reproduced; the *universal lower statement* is still **conditional**.

## Reproduction

With Python 3 from this directory, run:

    bash replay.sh

To reuse the original C-10 file rather than downloading the public ZIP:

    bash replay.sh /path/to/original_C10/heights_u70.txt

The scripts fail closed under python -O, which would otherwise disable the asserts. The full original auxiliary package and GMP source are preserved in the November 22 handoff archive, but the GitHub replay is standard-library only.

**Claim boundaries:** no determination of the Erdős constant; no global upper optimality or current-world-record claim; no independent peer review; no eligible Einstein Arena submission (131,072 exceeds its 100,000-item limit). The current Arena score is a separate, not independently rechecked external witness.

**Attribution:** Devin J. Wright/NIGHTFALL for PhaseShift construction and refinements, Justin Wetch and earlier cited authors for inherited lower mathematics, GPT-assisted source recovery, endpoint refinement and exact-source replay.

**Related records:** [Historical public C-10 packet](../EXTERNAL_REFEREE_PACKET_20261029.md) · [Source and prior-art ledger](../STATUS_AND_PRIOR_ART_20261028.md) · [conditional lower evidence](../../../agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md).
