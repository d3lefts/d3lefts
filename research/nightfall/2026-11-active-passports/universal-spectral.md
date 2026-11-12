# Proof Passport: NF-UNIVERSAL-SPECTRAL-20261111

**NIGHTFALL Constellation · Devin J. Wright · version 1.0 (2026-11-11).**
**Status:** ANALYTIC MANUSCRIPT; partial Lean cores; full certification OPEN. This is a claim-specific proof-passport note, not an independently refereed theorem or novelty certificate.

## Exact claim and quantifiers

For a Hilbert-valued bounded degree-d observable, PR #332 proposes a deterministic whole-coordinate observer with error ≤τ_r+η after N=ceil((40/3)·U·log(1+4U)), where U=d^7 B^3 r^(3/2)/(c_*η^(3/2)) and c_*=sqrt(3/12500)/π^6. The bound is independent of input dimension and alphabet size but not of r, degree, tolerance, or source verification assumptions.

**Display shorthand:** `E||F−F̂||² ≤ τᵣ + η  (candidate)`

## Premises

1. Independent product coordinates; measurable bounded Hilbert output of degree ≤d; covariance spectrum and tail τ_r.
2. Exact finite scalar theorem coefficient c_*, not the stronger unverified coefficient sometimes written in source manuscripts.
3. Posterior selection, arbitrary-product passage, PSD concentration and Hilbert rank lift must hold under their stated measurability hypotheses.

## Mechanism (dependency graph)

1. Finite-to-product scalar reduction aims to transfer the Lean finite-table influence theorem by finite rectangular conditional expectations.
2. A signed Hilbert projection and PSD matrix-moment estimate turn scalar coordinate influence into rank-trace-sensitive gain.
3. ANOVA total-influence posterior potential decreases under greedy coordinate queries; orthogonal rank-r output projection adds covariance tail τ_r.

## Provenance and certification

1. PR #317 is a pinned finite scalar Lean theorem; PR #332 is a DRAFT written all-degree Hilbert argument, not the same theorem.
2. PRs #339/#340 contain partial Lean. Further merged source-specific Lean successes include 13 categorical/cover/tail declarations (CI #42959881782), signed-ensemble orthogonality (#42965524565), diagonal sign coherence (#42972554673), finite transition-kernel budget (#42972560393), and actual posterior resampling influence (#42973878336). They are classical/routine supporting certificates; the general Hilbert theorem remains uncompiled.
3. Source REVIEW_GATES.md records a corrected formula for a four-bit cubic selector example when p>1/2; future manuscripts should use the corrected all-p equality.

**Primary analytic manuscript:** draft GitHub PR #332 (unmerged), with an additional supplied v6 package outside the public source tree. The `REVIEW_GATES.md` on main is a critical review ledger, not the complete universal proof. The present page is a source-bound summary and does not supersede the primary original proof.

**Research source links:**
- [Universal v1 analytic proof PR](https://github.com/d3lefts/d3lefts/pull/332)
- [Finite scalar kernel passport](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md)
- [Partial scalar-to-trace Lean PR](https://github.com/d3lefts/d3lefts/pull/339)
- [Universal budget kernel PR](https://github.com/d3lefts/d3lefts/pull/340)
- [Spectral gates and known source correction](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/2026-11-spectral-observability/REVIEW_GATES.md)

## Failure conditions, limits, and priority

1. No end-to-end Lean proof of the random-sign PSD estimate, arbitrary-product bridge, posterior measurable policy or spectral risk.
2. v6 log-free bounds require coherence at EVERY reached posterior; initial-only coherence is insufficient.
3. No computational runtime, unrestricted cubic (2,4), global originality certificate, or external referee clearance.

**Upstream attribution and comparison:** Turturean's finite scalar cube proof and Lean transfer, classical Hilbert covariance/ANOVA, related query complexity work. PR #332 and the v6 supplied manuscripts are internally authored proof candidates.

## Independent adversarial audit

Rederive finite-to-infinite approximation with null-set and degree controls; independently prove the PSD rank-trace inequality and posterior budget; test the v6 coherence condition after every observation; deposit full source and distinct checksums before publishing a universal theorem.

**Gate:** Preserve this certificate and every failed or superseded result, but do not promote to published novel theorem without independent proof review and dated prior-art comparison. No frozen historical Proof Passport or five approved Original Findings are being changed.

## Revision v2 — corrected merged finite-core status

The merged **ActualPosteriorInfluence.lean** passes [CI #42973878336](https://github.com/d3lefts/d3lefts/actions/runs/42973878336); the prior draft/failure state was superseded. The module proves posterior product normalization, a signed resampling identity and a rank-factor bound. The more delicate scalar-to-trace application with actual posterior covariance, analytic PSD compression, measured-space policy and end-to-end spectral risk remain outside Lean. Quarantine of routine finite identities, with full source enumeration, is in [the 39-module ledger](../../../docs/lean-certificate-provenance.json). The dated PR #332 analytic candidate remains a separate originality and validity review.


## Revision v3 — 12 November 2026, separate all-degree and quadratic tracks

**Do not conflate three different assertions.** (1) The pinned finite heterogeneous-product scalar 5/2 theorem is kernel checked; (2) the universal all-degree Hilbert observability program in draft #332 is an **analytic** transfer candidate using scalar laws, PSD estimates and nontrivial posterior selection; (3) the degree-two **Theorem D** proposed rank-optimal bound O(rB²/η) and its sharper v9.2 numerical form use a different stronger scalar degree-two exponent-two premise. The latter is not a compiled consequence of the finite 5/2 theorem.

Main PR #407 gives an actual finite quadratic Hilbert-row bridge; #408 gives eight strict compiled true Efron–Stein pair/rectangle-source declarations ([source ledger](../formalization/product_space/ACTUAL_ES_PAIR_MATCHING_LEDGER_20261112.md)). These close smaller dependencies but **not** global actual-source parity, full Hilbert rank and measurable posterior construction, or universal all-degree observability. Current original source provenance has 67 individual Lean modules; the earlier 13-declaration count in the 11 Nov spectral README refers only to that dated batch. The dedicated [quadratic and rank passport](quadratic-rank-observability.md) records theorem conditions and the pending external review.
