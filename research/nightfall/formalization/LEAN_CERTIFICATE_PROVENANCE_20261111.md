# NIGHTFALL Lean certificate provenance / quarantine — 2026-11-11

## Decision
The repo contains 43 Lean source files as of main commit `c00924b8dc942ae5828df8c5d38a5e2fcd29bdfa`. Classification: **32 quarantine**, **10 scoped dependent transfers**, **1 distinct finite construction**. Frozen historical eleven are unchanged. Site inventory is `docs/lean-certificate-provenance.json`; the accompanying static HTML renders all 43.

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
