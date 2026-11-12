# Convolution and the Cost of Knowing — dissertation v2.0 proof-certificate accounting

**Audit:** 12 November 2026. **Input:** the uploaded exact 69-page PDF, SHA-256 `a65cc94daa4392dc8a79ca8ebbf5d5f63744db6465107a24f9ba397aca6c51fc`. The PDF is not silently replaced by material from another manuscript. **Status:** source-to-claim audit and cross-reference; not a newly compiled 54-theorem Lean proof, not independent expert review.

**Coverage:** **54 numbered statements** = 28 theorems, 15 propositions, 7 lemmas, 4 corollaries. The longer statement inventory was extracted from the PDF and checked twice; Theorem 6.9 has a line-wrapped heading and must not be omitted. The machine-readable [claim-by-claim ledger](DISSERTATION_V2_CERTIFICATE_LEDGER_20261112.json) gives every physical PDF page, current Git source blob, recorded CI head/run, scope, and unclosed proof edge.

## Executive certificate verdict

| Evidence class | Numbered dissertation claims | Interpretation |
| --- | ---: | --- |
| Local kernel-compiled mathematical core* | 1 | Theorem 2.1, finite product and unit-bounded core with elementary B rescaling in the PDF |
| External Lean theorem core* | 1 | Theorem 2.4, Turturean, transformed into the PDF normalization |
| Locally compiled components but missing theorem bridge | 22 | Some genuinely kernel-checked source lemmas, not the claimed end-to-end statement |
| Exact finite evidence / checker / analytic finite instances only | 19 | Numerical or exact-rational evidence cannot discharge universal quantifiers |
| Written analytic derivation only | 11 | No exact claim-specific Lean proof found |
| **Exact same-scope terminal Lean declarations for all manuscript hypotheses** | **0 confirmed** | Conservative exact-type standard; this does not invalidate the one compiled finite mathematical core |

\* Theorem 2.1's historical `heterogeneous_influence` uses `|F|≤1` on supported words and exponent 5/2 and is compiled at a named declaration; the PDF scales it to B>0 and includes wording about Hoeffding degree. Theorem 2.4 is an imported external theorem with a signed/B/convention translation. Neither is a fresh, explicitly compiled Lean declaration matching every word of the displayed PDF assertion.

**Distinct objects, not additive theorem counts:** the canonical [67-file Lean source registry](../../formalization/CERTIFICATE_INDEX.md) records **67 source modules** (56 quarantined for novelty, 10 derived transfers, 1 finite construction) and their historical CI source matches. **One** paper-local module `papers/conditional-section-duality/lean/FixedObservationSelector.lean` lies *outside* that registry and has **five** strict compiled declarations. The 54 numbered claims, 67 source modules and five declarations are different units. The register does not assert that 54 complete dissertation theorems were compiled.

## Per-numbered-statement ledger

Symbols: 'components compiled' means only the indicated subordinate statements are kernel checked; 'finite evidence' can mean a script present but without an independent replay. The complete residual obligation is printed in the last column. Citations/CI are source provenance, **not** a certificate of the entire row.

### Chapter 1

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Theorem **1.1** — Law-uniform quadratic influence (p. 10) | Components compiled | `ActualESPairMatchingBridge` ([CI 43167542367](https://github.com/d3lefts/d3lefts/actions/runs/43167542367)); `QuadraticActualRowOscillation` ([CI 43161559862](https://github.com/d3lefts/d3lefts/actions/runs/43161559862)) (+2 in JSON) | Missing same-source global matching-to-amplitude inequality and final scalar variance-squared closure. |
| Proposition **1.2** — Optimal variance exponent (p. 11) | Analytic only | No mapped internal Lean source | Exact disjoint-pair example is proved in manuscript; no theorem-level Lean declaration located. |
| Theorem **1.3** — Rank-linear quadratic influence (p. 11) | Components compiled | `RademacherOrthogonality` ([CI 42965524565](https://github.com/d3lefts/d3lefts/actions/runs/42965524565)); `UniversalScalarToTrace` ([CI 42962205054](https://github.com/d3lefts/d3lefts/actions/runs/42962205054)) | Conditional on 1.1; full rank-r norm/sign lift and pointwise boundedness not jointly compiled. |
| Theorem **1.4** — Rank-optimal adaptive observation (p. 11) | Components compiled | `RealSquaredPosteriorOneStep` ([CI 43078715778](https://github.com/d3lefts/d3lefts/actions/runs/43078715778)); `PosteriorEnergyDrift` ([CI 43082375547](https://github.com/d3lefts/d3lefts/actions/runs/43082375547)) (+1 in JSON) | Depends on 1.1/1.3; certified one-step drift does not implement actual adaptive policy or hard stopping cap. |
### Chapter 2

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Theorem **2.1** — Kernel-compiled all-degree finite-product influence (p. 12) | Local core compiled* | `ProductInfluence` ([CI 42929857470](https://github.com/d3lefts/d3lefts/actions/runs/42929857470)); `HeterogeneousAlphabets` ([CI 42932085109](https://github.com/d3lefts/d3lefts/actions/runs/42932085109)) (+1 in JSON) | Core unit-bounded finite theorem compiled; displayed general B scaling and exact zero-atom degree interface must be distinguished from literal Lean target. |
| Theorem **2.2** — Analytic finite-partition transfer of the certified coefficient (p. 13) | Components compiled | `HeterogeneousAlphabets` ([CI 42932085109](https://github.com/d3lefts/d3lefts/actions/runs/42932085109)); `EfronSteinDegree` ([CI 42932085109](https://github.com/d3lefts/d3lefts/actions/runs/42932085109)) | Infinite-index product L2 cylinder-density net, commuting projections and maximal influence attainment not compiled. |
| Theorem **2.3** — Finite-product all-degree spectral observation (p. 14) | Components compiled | `ProductInfluence` ([CI 42929857470](https://github.com/d3lefts/d3lefts/actions/runs/42929857470)); `RealSquaredPosteriorOneStep` ([CI 43078715778](https://github.com/d3lefts/d3lefts/actions/runs/43078715778)) (+1 in JSON) | All-degree scalar kernel inherited, but rank reduction, posterior recurrence and fixed finite stopping are analytic. |
| Theorem **2.4** — Turturean, in the present normalization (p. 15) | External core compiled* | No mapped internal Lean source | External Boolean-cube theorem reported compiled; rescaling to dissertation's signed B and resampling normalization is not a local exact-type certificate. |
| Proposition **2.5** — Sharp degree-one endpoint on arbitrary products (p. 15) | Components compiled | `RestrictedInfluence` ([CI 42884789858](https://github.com/d3lefts/d3lefts/actions/runs/42884789858)) | Finite signed scalar implication compiled; arbitrary product support oscillation and measurable passage are not literal terminal Lean declarations. |
| Theorem **2.6** — Scope-separated influence synthesis (p. 17) | Components compiled | `ProductInfluence` ([CI 42929857470](https://github.com/d3lefts/d3lefts/actions/runs/42929857470)); `RestrictedInfluence` ([CI 42884789858](https://github.com/d3lefts/d3lefts/actions/runs/42884789858)) | Composite includes 1.1 and backdoor/cubic assertions not end-to-end compiled; inherited components do not certify stronger cases. |
| Lemma **2.7** — Support of a low-degree Boolean polynomial (p. 18) | Finite evidence only | `check_joint_information_phase_diagram.py` | Inductive real multilinear support proof written; related finite support tests exist but no universal Lean terminal declaration. |
| Proposition **2.8** — Exact maximum/expectation obstruction (p. 19) | Analytic only | No mapped internal Lean source | Explicit Bernoulli formula in manuscript; no source-matched separate kernel theorem. |
| Lemma **2.9** — Matching mass (p. 19) | Components compiled | `ActualESPairMatchingBridge` ([CI 43167542367](https://github.com/d3lefts/d3lefts/actions/runs/43167542367)); `CenteredRectangles` ([CI 43167542367](https://github.com/d3lefts/d3lefts/actions/runs/43167542367)) (+1 in JSON) | True centered pairs/oriented rectangles compiled; global even-odd same-source coupled matching cancellation remains missing. |
| Lemma **2.10** — Additive oscillation and coordinate-section budgets (p. 20) | Components compiled | `QuadraticActualRowOscillation` ([CI 43161559862](https://github.com/d3lefts/d3lefts/actions/runs/43161559862)); `QuadraticRealizedRangeBudget` ([CI 43114064344](https://github.com/d3lefts/d3lefts/actions/runs/43114064344)) (+1 in JSON) | Actual finite section range/8B budget compiled in narrow types; full additive projection plus arbitrary source Hilbert section composition not one theorem. |
| Lemma **2.11** — Quadratic energy bound (p. 20) | Components compiled | `WeightedGreedyMatching` ([CI 43079392649](https://github.com/d3lefts/d3lefts/actions/runs/43079392649)); `WeightedGreedyCover` ([CI 43080368002](https://github.com/d3lefts/d3lefts/actions/runs/43080368002)) (+2 in JSON) | Actual-f matching ownership to independent Hilbert increments, interpolation and aggregate energy closure absent. |
| Lemma **2.12** — Bounded product approximation and influence contraction (p. 21) | Analytic only | No mapped internal Lean source | Measurable arbitrary-index L2-cylinder approximation with conditioning and supremum attainment not Lean compiled. |
### Chapter 3

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Lemma **3.1** — Finite-sign Hilbert compression (p. 23) | Components compiled | `RademacherOrthogonality` ([CI 42965524565](https://github.com/d3lefts/d3lefts/actions/runs/42965524565)) | Orthogonality/finite sign identities compiled; dissertation's full r-dimensional compression constant and quantifiers not separately compiled. |
| Theorem **3.4** — Influence-to-observation transfer (p. 24) | Components compiled | `RealSquaredPosteriorOneStep` ([CI 43078715778](https://github.com/d3lefts/d3lefts/actions/runs/43078715778)); `PosteriorEnergyDrift` ([CI 43082375547](https://github.com/d3lefts/d3lefts/actions/runs/43082375547)) | Source-function influence modulus, conditional-product preservation, transcript averaging and deterministic cap not jointly compiled. |
| Corollary **3.5** — Three exact instantiations (p. 25) | Components compiled | `ProductInfluence` ([CI 42929857470](https://github.com/d3lefts/d3lefts/actions/runs/42929857470)); `PosteriorEnergyDrift` ([CI 43082375547](https://github.com/d3lefts/d3lefts/actions/runs/43082375547)) | One instantiation inherits finite scalar theorem, quadratic/rank instantiations depend on uncompiled 1.1/1.3 and policy bridge. |
| Lemma **3.7** — Actual degree-weighted posterior drift (p. 25) | Components compiled | `RealSquaredPosteriorOneStep` ([CI 43078715778](https://github.com/d3lefts/d3lefts/actions/runs/43078715778)); `PosteriorEnergyDrift` ([CI 43082375547](https://github.com/d3lefts/d3lefts/actions/runs/43082375547)) (+1 in JSON) | Literal finite one-step squared-resampling and abstract ANOVA energy bookkeeping compiled in separate types/pins; full weighted-source identity not one declaration. |
| Theorem **3.9** — Averaging-transversal influence theorem (p. 27) | Components compiled | `TopInteractionCover` ([CI 42959881782](https://github.com/d3lefts/d3lefts/actions/runs/42959881782)); `ANOVAPosteriorBridge` ([CI 43110333296](https://github.com/d3lefts/d3lefts/actions/runs/43110333296)) | Structural support cover compiled only conditionally; core quadratic inequality 1.1 remains uncompiled. |
| Theorem **3.10** — Observation after a sectional quadratic backdoor (p. 27) | Components compiled | `TopInteractionCover` ([CI 42959881782](https://github.com/d3lefts/d3lefts/actions/runs/42959881782)); `RealSquaredPosteriorOneStep` ([CI 43078715778](https://github.com/d3lefts/d3lefts/actions/runs/43078715778)) | Requires uniform sectional promises and full posterior policy with 1.1; no terminal declaration. |
| Proposition **3.11** — Why the two backdoor notions differ (p. 28) | Analytic only | No mapped internal Lean source | Explicit family distinguishes averaging and sectional backdoors; no matching Lean declaration. |
| Theorem **3.12** — Independent-block covered cubic influence (p. 28) | Components compiled | `CubicRankOneTerminal` ([CI 43100116278](https://github.com/d3lefts/d3lefts/actions/runs/43100116278)); `RankOneLeafMoment` ([CI 43100116278](https://github.com/d3lefts/d3lefts/actions/runs/43100116278)) | Finite rank-one cubic terminal inequality is conditional; full independent-block/vector influence premises not discharged. |
| Theorem **3.13** — Adaptive observation of covered cubic networks (p. 29) | Components compiled | `CubicRankOneTerminal` ([CI 43100116278](https://github.com/d3lefts/d3lefts/actions/runs/43100116278)); `PosteriorEnergyDrift` ([CI 43082375547](https://github.com/d3lefts/d3lefts/actions/runs/43082375547)) | Depends on uncompiled 3.12 and a transcript-stable adaptive hard cap. |
| Proposition **3.14** — Exact degree-three address example (p. 29) | Analytic only | No mapped internal Lean source | Explicit cubic-address witness in manuscript; no claim-specific kernel receipt. |
| Proposition **3.15** — Unbounded adaptivity advantage for cubic addresses (p. 30) | Analytic only | No mapped internal Lean source | Address-model oracle comparison analytic; fixed-set lower bound and adaptive identification not compiled. |
| Proposition **3.17** — A fixed-set guarantee above the quadratic energy floor (p. 31) | Components compiled | `SortedInfluenceTail` ([CI 42959881782](https://github.com/d3lefts/d3lefts/actions/runs/42959881782)) | Sorted tail algebra compiled; source-dependent L1 section budget and risk identification not connected. |
| Proposition **3.18** — A fixed-query observation bound (p. 31) | Components compiled | `SortedInfluenceTail` ([CI 42959881782](https://github.com/d3lefts/d3lefts/actions/runs/42959881782)); `FixedObservationSelector` ([CI 43285738660](https://github.com/d3lefts/d3lefts/actions/runs/43285738660)) | Paper-local 4.35 finite selector/beta bound compiled; beta(f), top-q choice, L1 section budget and ANOVA risk not compiled. |
### Chapter 4

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Theorem **4.1** — Convolution homomorphism and diagonalization (p. 33) | Components compiled | `ANOVAActivation` ([CI 42884789858](https://github.com/d3lefts/d3lefts/actions/runs/42884789858)) | Abstract ANOVA energy identity compiled; no exact refresh union-semigroup operator homomorphism/diagonalization declaration found. |
| Theorem **4.2** — Exact complementarity and interaction-energy inversion (p. 34) | Components compiled | `ANOVAActivation` ([CI 42884789858](https://github.com/d3lefts/d3lefts/actions/runs/42884789858)) | Supplied-energy supermodularity compiled; inversion of actual Hoeffding interaction energies via refresh observations not compiled. |
| Theorem **4.3** — Sparse interaction-spectrum tomography (p. 36) | Finite evidence only | reported checker; receipt missing | Hankel-Prony exact 2k ideal population-moment reconstruction is analytic; manuscript reports exact tests but checker receipt not matched. |
| Theorem **4.4** — Finite-precision separation of sparse supports (p. 36) | Finite evidence only | reported checker; receipt missing | Exact support separation and precision inequality in manuscript; no Lean terminal; 1,414-assertion checker not source verified. |
| Proposition **4.5** — Single-support gain recovery (p. 38) | Finite evidence only | reported checker; receipt missing | Classical binary splitting with stronger ideal gain oracle; manuscript-reported exact checks not matched to a repository run. |
| Proposition **4.6** — Quadratic convolution data do not certify pointwise positivity (p. 38) | Finite evidence only | reported checker; receipt missing | Explicit one-coordinate three-symbol counterexample in manuscript; no Lean theorem; associated checker not verified. |
### Chapter 5

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Corollary **5.1** — Prediction of one-query quantum outcomes (p. 40) | Analytic only | No mapped internal Lean source | Classical probability-vector/quantum one-copy observation interpretation is analytic; no scoped Lean declaration. |
| Corollary **5.2** — Scalar one-query prediction with an error probability (p. 40) | Analytic only | No mapped internal Lean source | One-copy Born-probability prediction from scalar observable is analytic; no terminal Lean result. |
| Theorem **5.4** — Operational interaction-order decomposition (p. 41) | Finite evidence only | `exact_audit.py` | Quantum ANOVA and Personick/SLD operator proof remains analytic; finite script exists, not a Lean proof. |
| Proposition **5.5** — Sharp SLD tensor envelope (p. 42) | Finite evidence only | `check_trine_visibility_exact.py` | Operator spectral SLD tensor comparison and physical witness analytic; exact spectral/trine checks exist, not kernel proof. |
### Chapter 6

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Theorem **6.1** — Three-group interaction test (p. 44) | Finite evidence only | `check_addressed_family_exact.py` | Property-testing theorem uses bounded difference/independence; no matched end-to-end Lean declaration. |
| Theorem **6.2** — Three distinct information costs in one quadratic family (p. 45) | Finite evidence only | `check_addressed_family_exact.py`; reported checker; receipt missing | Addressed model/state costs analytic and tested on exact finite examples; not universal Lean. |
| Theorem **6.4** — Exact decomposition of model and state uncertainty (p. 47) | Finite evidence only | `check_joint_information_phase_diagram.py`; reported checker; receipt missing | Posterior orthogonal Bayes-risk split analytic with finite checker; source-specific L2 filtration not compiled. |
| Theorem **6.5** — Exact Bayesian frontier for addressed observation (p. 48) | Finite evidence only | `check_joint_information_phase_diagram.py`; reported checker; receipt missing | Conditional risk formula analytic and finite rational checks; no exact Lean theorem. |
| Corollary **6.6** — Sharp offline model-query and state-read tradeoff (p. 48) | Finite evidence only | reported checker; receipt missing | Offline frontier conditional on linear information from chosen coefficient queries; finite checker only. |
| Theorem **6.7** — Access-order phase transition and exact live-query frontier (p. 49) | Finite evidence only | reported checker; receipt missing | Live queried coefficient depends on observed address; timing oracle formalization and tradeoff only checked on finite examples. |
| Theorem **6.8** — Exact task-specific evaluation duality (p. 50) | Finite evidence only | reported checker; receipt missing | Annihilator/linear-span argument analytic; rational matrix rank checks are not a general Lean theorem. |
| Theorem **6.9** — Exact integration complexity: two fair-cube queries versus n + 1 generic biased queries (p. 50) | Finite evidence only | reported checker; receipt missing | Generic bias exceptional-set argument analytic; finite rational rank cases do not quantify almost every law. |
| Theorem **6.11** — Finite-product interpolation and exact decision cost (p. 51) | Finite evidence only | `check_joint_information_phase_diagram.py` | Finite-product D_d interpolation dimension, oracle ID/safety argument analytic; exact phase-diagram checker does not certify universal theorem. |
### Chapter 7

| Claim (PDF page) | Evidence classification | Supporting sources and recorded CI | Missing proof obligation |
| --- | --- | --- | --- |
| Proposition **7.1** — Safety from a positive separation radius (p. 53) | Analytic only | No mapped internal Lean source | Elementary separation-from-unsafe-set argument in prose; no exact certificate. |
| Theorem **7.2** — Minimum support of a nonzero low-interaction function (p. 53) | Finite evidence only | `check_joint_information_phase_diagram.py` | Alpha^d support induction analytic; finite rational heterogeneous falsifier is not universal Lean proof. |
| Proposition **7.3** — Threshold-induced degree blow-up and rare violations (p. 54) | Finite evidence only | `check_joint_information_phase_diagram.py` | Threshold counterexample Fourier coefficient analytic; exact finite tests cover instances only. |
| Proposition **7.4** — Unstructured exact-safety gap (p. 56) | Analytic only | No mapped internal Lean source | Classical indistinguishability and quantum BBBV/Grover literature; no dissertation-specific Lean source. |
| Theorem **7.5** — A common-family test–identify–observe–certify separation (p. 57) | Finite evidence only | `check_addressed_family_exact.py`; `check_joint_information_phase_diagram.py`; reported checker; receipt missing | Composite addressed-family costs; finite checkers apply but 6.1/6.2/6.7 and safety predicates not jointly compiled. |
| Proposition **7.6** — Exact high-order interaction energy of a single deletion (p. 57) | Analytic only | No mapped internal Lean source | Explicit high-order Fourier energy of a needle; analytic combinatorial identity and manuscript-reported checks only. |

## Full dependency passports, including unnumbered claims

### Influence and observation (Chapters 1–3)

1. **Full scalar exponent-two endpoint (Thm 1.1, Lemmas 2.9–2.11).** Verified pieces: genuine finite Efron–Stein centered pair identities and oriented four-corners (PR #408); explicit bounded quadratic switching sections (PR #407); all-n arbitrary-law Hilbert fourth moment; weighted greedy matching and graph endpoint cover; conditional algebra. **Missing:** same-source *global* matched even/odd coupling of actual \(f\), full induced edge weights and section/norm budget reconciliation, the true \(I_i(f)\) energy link, and terminal \(V^2\) theorem. [Current proof gate](../formalization/observability/QUADRATIC_E2E_CERTIFICATION_STATUS.md). The later same-pin workflow in PR #416 compiles a meaningful subset together, **not** the final inequality.
2. **All-degree product influence (Thms 2.1–2.3).** `product_influence`, `heterogeneous_influence` and `prodDegree_iff_esDegree` have historical successful source-matched Lean runs. Imported credit belongs to Turturean. Extending to arbitrary measurable products and deriving output-rank finite-query policies are separate analytic steps. Lean 4.33.0 source and Lean 4.35.0 components are not to be called a single build.
3. **Hilbert rank and stopping (Thms 1.3–1.4, 3.4–3.7).** Finite Rademacher orthogonality, one-step posterior squared-resampling and abstract ANOVA energy telescoping are formalized in restricted types; no single rank-r theorem constructs a fully specified adaptive policy and proves its risk and deterministic stopping bound.
4. **Backdoor/cubic networks (Thms 3.9–3.13).** Finite support-cover and conditional cubic rank-one lemmas do not certify independent disjoint cubic blocks or unrestricted overlapping links as source functions.
5. **Fixed selection (Props 3.17–3.18).** [PR #418](https://github.com/d3lefts/d3lefts/pull/418) supplies a real pinned Lean 4.35.0 exact-type contract and five compiled finite selector/beta-transfer declarations ([strict run 43285738660](https://github.com/d3lefts/d3lefts/actions/runs/43285738660)). Its theorem **assumes** the beta-conditioned section budget. Existence of top-q set and actual source-risk identity remain absent.

### Refresh convolution and idealized reconstruction (Chapter 4)

6. The union convolution \(T_\nu T_\eta=T_{\nu*_\cup\eta}\), common Hoeffding eigenvectors, multiplier inversion and exact complementarity (4.1–4.2) have **analytic proofs** in the dissertation. `ANOVAActivation.lean` kernel-checks some abstract positive-weight gain/supermodularity formulas but **not** the entire semilattice convolution/inversion.
7. The 2k prime-coded moment theorem and support separation (4.3–4.4) invoke classical Prony/Hankel exact algebra under a **population covariance oracle**, not ordinary value/read queries. Appendix B reports **1,414 exact-rational assertions** for a convolution checker, but this session did not find the exact named checker, executable command, matching Git SHA and output receipt in the inspected repository or code search. Do not label this count independently reproduced; reconstruct/upload source and obtain repeatable CI before upgrading.
8. The gain oracle group test (4.5) is an ideal **exact gain** query, not a fresh-state coordinate or model-value query. The spectral pointwise-safety counterexample (4.6) is an analytic finite witness, not a universal Lean theorem.

### Quantum operator measurement (Chapter 5)

9. Operational quantum ANOVA and sharp SLD tensor envelope (5.4–5.5) have external quantum formalization *comparators* and project finite exact scripts, but **no NIGHTFALL terminal Lean proof**, nor a compiled map from SLD inverse-Jordan form to a quantum informational metric. One-copy fixed-register hypotheses may not be promoted to coherent adaptive quantum query results. The two elementary quantum-outcome corollaries (5.1–5.2) are likewise analytic.

### Model, state, dual task and certification (Chapters 6–7)

10. The exact model/state conditional-risk splitting (6.4) can in principle inherit Mathlib's `condExpL2` orthogonal projection. The joint state/model law, fresh input independence and transcript measurability are not encoded as a Lean theorem. The addressed family offline/live frontiers (6.2, 6.5–6.7) have written analytic claims and some small finite posterior checks, but **the PDF's purported 123/161 dedicated cases are currently source-unmatched**; no universal oracle theorem is compiled.
11. Exact task-dual span and affine biased integration (6.8–6.9), interpolation dimension and safety certification (6.11), support floor (7.2), rare thresholds (7.3), needle and composite separation (7.4–7.6) have written direct proofs or classical lower-bound inputs. No general exact-type Lean declarations were identified. The [CI-passed rational phase-diagram checker](https://github.com/d3lefts/d3lefts/actions/runs/43281921897) validates finite examples only.

## Compatibility, missing evidence and required corrections

- **Compiler provenance:** Some all-degree/ANOVA receipts depend on pinned Lean **4.33.0**, a historical release subsequently patched in 4.33.1. Critical 4.33.0 results should be replayed with a corrected compatible kernel; do not presume they are invalid. Other honest receipts use Lean **4.35.0**, Mathlib v4.35.0. Separate source-hash-matched historical CI from an actual current single-pin build.
- **Imported mathematical priority:** Distinguish published Turturean's proof, classical Hoeffding Efron–Stein, Grothendieck, Personick, Prony, Schwartz–Zippel, and BBBV/Grover bounds from NIGHTFALL's own work. See the [15-item exact source subsumption audit](../2026-11-theorem-subsumption/TYPE_SUBSUMPTION_AUDIT_20261112.md).
- **Appendix B correction:** the PDF describes **PR #417 as draft** and uses an old branch path. PR #417 was in fact merged to `main`; change that wording in any revised manuscript and point to `research/nightfall/2026-11-information-cost-dissertation/`. Do not silently alter the supplied 69-page PDF, whose hash anchors this ledger.
- **Reported tests and a substantial name collision:** `check_addressed_family_exact.py` is a **6,561-model, n=2 two-sample trivalent tester**, **not** the dissertation's 123 adaptive / 161 live / six rank evaluations. Appendix B names `check_joint_frontier_exact.py` for those tests; that exact script and execution record are **not located** in the current repository. In contrast, `check_joint_information_phase_diagram.py` has [finite CI PASS](https://github.com/d3lefts/d3lefts/actions/runs/43281921897) including **18 posterior** cases. Quantum test scripts have sources but are not kernel proofs. The **1,414-assertion convolution checker** likewise lacks a matched source and run.
- **Universal theorem gate:** for each claim, require a terminal Lean declaration matching the mathematical statement's domain, law, oracle, constant, adaptive restrictions and quantifiers, with a locked expected-type contract, exact SHA, allowed axioms and clean compiler receipt. Only then set `full_end_to_end_lean` true and add independent mathematical/priority review as separate gates. The present account claims **none** of those 54 exact terminals.

## Reproducible accounting command

```sh
python3 scripts/check_dissertation_certificate_accounting.py --json-out dissertation-receipts/dissertation-v2-certificate-audit.json
```

If the exact user-provided PDF is on the filesystem and PyMuPDF installed, append `--pdf /path/to/Convolution_and_the_Cost_of_Knowing\(1\).pdf`. The optional PDF gate validates the SHA-256, physical page count, and all 54 numbered first occurrences. The normal gate checks the canonical 67-source registry, each mapped actual Git blob, recorded historical CI pointers, the paper-local selector digest, and finite checker file existence. **This checker does not execute Lean, and must never be presented as a universal theorem prover.**

**Falsifiable next gate:** compile one exact finite product-PMF representation plus conditional-expectation bridge at pinned Lean 4.35, then attach a type-locked source-function proof of the global 4B matching budget before attempting the final exponent-two endpoint. Preserve older failed/fixed receipts; no publication or novelty promotion without external review.
