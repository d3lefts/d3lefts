# NIGHTFALL Lean certificate provenance / quarantine — 2026-11-11

## Decision
The repo contains **59 Lean source files** at main commit `f0007f6baea9ea53dfbde809bb243c017c17dbc6` (all 59 Git blob hashes in `docs/lean-certificate-provenance.json`). Classification: **48 originality-quarantined**, **10 scoped dependent transfers**, **1 distinct finite construction**. This is a full *main-branch source census*; it does not establish fresh same-commit compilation or a worldwide novelty result. Frozen historical eleven are unchanged. The public HTML mirrors all 59 entries.

**Quarantine preserves valid proof code.** A known identity or an explicit-premise reformulation can be correctly kernel-compiled without being a new mathematical result. The cost is mistaken novelty attribution, not Lean soundness. We therefore remove *originality claims*, not source, logs, or checks.

## Category boundaries
- Quarantine: Hoeffding/Efron–Stein decomposition and finite conditional expectation; independent-sign moments; Cauchy and sorted tails; Nisan-style packing and certificate complexity; simple phase/odd-cycle arithmetic; abstract posterior drift. Dependencies remain available for proof replay but cannot be counted as independent discoveries.
- Derived transfer: Turturean's `AaronsonAmbainis` machinery plus source-specific finite competing-symbol rows, two-draw mass weighting, arbitrary-marginal product influence, and concrete finite certificate/posterior sampling. These have existing site passports, with *priority not cleared* and imported components credited.
- Distinct finite construction: the `F16` three-query phase block and its literal 81-state no-collision certificate. Adds one source-specific public passport. Historical global originality not established.

## External checked prior-art anchors
1. W. Hoeffding (1948) and ANOVA decomposition: https://encyclopediaofmath.org/index.php?title=Hoeffding_decomposition
2. B. Efron and C. Stein, *The Jackknife Estimate of Variance* (1981): https://doi.org/10.1214/aos/1176345462
3. Nisan/decision-tree and block sensitivity prior art: https://www.sciencedirect.com/science/article/pii/S030439750100144X
4. Chugh–Podder–Sanyal, FSTTCS 2023: https://drops.dagstuhl.de/doi/10.4230/LIPIcs.FSTTCS.2023.27
5. David Turturean, *A proof of the Aaronson–Ambainis conjecture* (2026): https://arxiv.org/abs/2611.09773

No exhaustive global search of all related abstract theorems was performed. These references justify the conservative inherited classification, not a claim of exhaustive priority adjudication.

## Failure conditions and checker
Fail closed if any `.lean` file on main has no ledger row, if source routes do not exist, if a quarantined item is called a globally original theorem, or if the historical registry changes. Run `node scripts/test_lean_certificate_provenance.cjs` in the repo; this is editorial certification only. Lean CI receipts are linked in the manifest. Replaying each source's exact theorem type and axiom dependency is a separate proof operation.

## Further independent review
Request an author-unrelated mathematical prior-art review for both the heterogeneous finite influence transfer and the F16 block, particularly identical query model and categorical law assumptions. Do not promote either to global novelty before review.

## Off-main recovery after the 39-file census

The 43 files are **main only**; this is not a census of closed historical PRs. One source-matched archived candidate recovered in this review is [Ryev PR 252](https://github.com/d3lefts/d3lefts/pull/252) `AdaptiveBlock.lean`, compiled in [run 41110673165](https://github.com/d3lefts/d3lefts/actions/runs/41110673165) with a scoped 27-state adaptive F16 Boolean certificate, numeric k4/k7 bounds, and *conditional* phase-factorization lemma. The original [Tessera PR 255](https://github.com/d3lefts/d3lefts/pull/255) supplies the different adaptive mechanism and exact Python audits. Neither branch merged to main; the full adaptive protocol was not one Lean theorem and outside priority remains unreviewed. The [companion evidence docket](phase_block/ADAPTIVE_BRANCH_EVIDENCE_20261111.md) and `docs/lean-certificate-provenance.json.off_main_certificates` keep this evidence inspectable without corrupting the main-branch 39-file classification.

## 11 November scoped-quadratic additions; no main theorem promotion

The contemporaneous merged PR 359 introduces FOUR additional compiled modules: `QuadraticDiscoveryCore.lean`, `ArbitraryLawFourthMoment.lean`, `HilbertTwoIncrementMoment.lean`, and `QuadraticHoeffdingBridge.lean`. Exact program-specific CI runs include [43058772711](https://github.com/d3lefts/d3lefts/actions/runs/43058772711), [43058085067](https://github.com/d3lefts/d3lefts/actions/runs/43058085067), and [43057281341](https://github.com/d3lefts/d3lefts/actions/runs/43057281341). These are independently useful formal **foundations** of the proposed full quadratic result: a sharp 7B polynomial interpolation bound, conditional certificate arithmetic, ordinary Hoeffding projection, and standard two-independent-increment fourth moments. They are now novelty-quarantined individually. In particular the actual matching certificate, multi-increment Hilbert induction and derivation from a general degree-two product function have NOT been compiled. See the [scoped source passport](observability/QUADRATIC_DISCOVERY_PROOF_PASSPORT.md). The additional modules are on main; the distinct closed-PR F16 adaptive certificate remains *off main* and must not be counted among these 43.


## Census reconciliation v8 (11 November 2026)

The prior static inventory covered 47 current source files, while 59 were on `main`. The twelve recovered files are: `research/nightfall/formalization/observability/ParityBlockCancellation.lean`, `research/nightfall/formalization/observability/PosteriorEnergyDrift.lean`, `research/nightfall/formalization/observability/QuadraticMatchedParity.lean`, `research/nightfall/formalization/observability/QuadraticOscillationBound.lean`, `research/nightfall/formalization/observability/QuadraticRealizedRangeBudget.lean`, `research/nightfall/formalization/observability/QuadraticSingleReplacement.lean`, `research/nightfall/formalization/observability/QuadraticSwitchingIdentity.lean`, `research/nightfall/formalization/observability/SignMomentLogTransfer.lean`, `research/nightfall/formalization/observability/SpectralProductHalf.lean`, `research/nightfall/formalization/observability/WeightedGreedyCover.lean`, `research/nightfall/formalization/observability/WeightedGreedyMatching.lean`, `research/nightfall/formalization/product_space/RealSquaredPosteriorOneStep.lean`. Each now has an exact Git blob SHA and conservative historical CI or no-receipt status, without promoting partial quadratic or spectral modules to end-to-end theorems. Check `node scripts/test_lean_certificate_provenance.cjs` to verify all current bytes against the manifest. The old 43/46/47 counts describe earlier editorial checkpoints and must not be used as the live census.

**Kernel receipt boundary:** Historical Lean 4.33/4.35 scoped compilation runs are referenced per module, but neither those links nor this manifest certify fresh compilation of all 59 source blobs. `QuadraticMatchedParity`, weighted greedy matching/cover, actual 8B/16B quadratic switching, and real-squared posterior one-step have distinct scoped proof types; the combined arbitrary-law quadratic influence and universal adaptive theorem remain without an end-to-end same-pin Lean proof. No custom axiom, sorry, or final theorem claims are inferred from the ledger.


### Final source-hash / CI-head reconciliation (revision 9)

Of the **59** Lean modules on the frozen source checkpoint, **58** exact current Git blobs were located in the trees of **successful** historical GitHub Actions run heads. The published JSON contains each source blob SHA-1, successful run id and head commit; the dedicated range-budget workflow [43098858989](https://github.com/d3lefts/d3lefts/actions/runs/43098858989) reached success on **attempt 2** after a cancelled earlier attempt. Prior stale citations for odd-cycle modules, the product two-sided bridge and the weighted reciprocal transfer have been replaced by receipts that contain the actual current source files. The matching-parity source was linked to a later run containing the repaired source, not an obsolete parity blob.

**One remaining directly unverified source:** `ANOVAPosteriorBridge.lean` is recorded as source-present but without an identified direct named-declaration certificate. It imports an already certified bridge; that fact is **not sufficient** to certify its own new statements. All 59 source files remain originality-scope classified (48 routine/inherited, 10 derived transfer, 1 finite construction).

**Important distinction:** source blobs matching a green run prove code identity and the referenced workflow's success, **not** universal theorem coverage, custom-axiom freedom for unlisted declarations, or a complete merged proof. Historical Lean 4.33 and 4.35 modules have not all been rechecked in one compiler environment. Independent mathematical review and global priority are separate outstanding gates.


### Final direct ANOVA gate and source-count closure (revision 10)

[Workflow 43110333296](https://github.com/d3lefts/d3lefts/actions/runs/43110333296) **succeeded**, including pinned Lean **4.33.0** strict axiom checks of all three `ANOVAPosteriorBridge.lean` named declarations: `anova_component_erase`, `anova_posterior_potential_identity`, `anova_weighted_observation_descent`. The module's exact Git blob `1568424ba292dfcf18ccd8b1307eb3baf466be63` at the successful head is identical to the 59-file main-source checkpoint. All **59/59 source blobs** are now associated with successful scoped historical CI heads, while each named-declaration receipt remains limited to its own theorem assumptions and compiler pin. The earlier 58/59 status is superseded by this dated verified outcome; retain it as an audit-history record, not the current result. No simultaneous all-file 4.35.0 certificate or universal all-law quadratic/adaptive Lean theorem is claimed.


## Revision 11 (11 Nov): direct actual-function certificates, distinct Lean pins

`QuadraticANOVA.quadratic_actual_product_influence_e2e` is an unconditional actual finite product law, degree-two result at the known exponent **5/2** (not exponent two), strictly compiled in pinned Lean 4.33 [run 43113339892](https://github.com/d3lefts/d3lefts/actions/runs/43113339892), blob `a936845286a74fbf5f0ee70fc5feca6b08108694`. `QuadraticSwitching.quadratic_actual_all_section_ranges_le_sixteen` constructs actual coordinatewise extrema and proves the full 16B range budget, strictly compiled in Lean 4.35 [run 43114064344](https://github.com/d3lefts/d3lefts/actions/runs/43114064344), blob `bc3ec344bb47426a9db0508893f8588e7a5d8ea2`. **No combined universal variance-squared influence theorem is certified**; compiler pins and missing source-function matching/Hilbert-energy links remain separate.


## Census revision 12 (pending joint actual-function declaration)

The branch adds `QuadraticUnifiedFinite.lean` as the 60th source. It combines the previously **kernel-certified** finite arbitrary-law degree-two exponent-5/2 baseline and constructed 16B range for the *same actual function*, under an explicit quadratic representation. **Compilation is pending** in [PR #391](https://github.com/d3lefts/d3lefts/pull/391); do not count this module as a successful certificate until its strict named check passes. The proposed variance-squared exponent-two theorem remains *uncompiled*, and a direct-source representation derivation and energy/matching moment bridges remain open. This is not a novelty finding.


## Rev13: joint same-kernel declaration PASS

The formerly pending `QuadraticUnifiedFinite.actual_degree_two_baseline_and_all_sections` has **strict Lean 4.33 successful** source-matched [run 43115838586](https://github.com/d3lefts/d3lefts/actions/runs/43115838586) at Git blob `6ca3d371ed2006e1cafc04bf3fba036afc1eefb3`. The theorem links the classical exponent-5/2 arbitrary-law influence bound and the constructed 16B full section-range on the **same** actual f with ESDegreeLE and explicit quadratic representation. This rev13 result supersedes the earlier pending rev12 status. All 60 main-compatible blobs now have successful historical scoped CI source matches. **The arbitrary-law variance-squared endpoint remains uncompiled.**
