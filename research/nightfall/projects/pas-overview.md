# Proof After Scarcity — causal verification and evidence-grounded graphs

**Devin J. Wright · NIGHTFALL research collaboration · public dossier updated 28 October 2026**

## Negative result: 8/20 versus 11/20

The 13 October 2026 *retrospective* stress test found that uncalibrated causal triage selected the historically documented weak-link category first in **8 of 20** challenged cases. Upstream-first and reach-per-cost baselines each scored **11 of 20**. Within the first three checks, PAS scored **17/20**, while both baselines scored **19/20**. Cases, coarse labels, and simplified dependency graphs were selected after historical outcomes became known. These scores measure category agreement, not defects discovered, reviewer hours saved, real error rates, or prospective predictive superiority. The negative finding remains the lead result.

The **24-case inventory** comprises **20 challenged cases** with scored retrospective weak-link categories and **four censored corroboration / formalization controls**: the 2012 Higgs-boson results, 2015 GW150914, the four-colour theorem, and the Kepler conjecture. The four controls have **no known defect-category label** and were excluded from both 20-case score denominators. They serve only as evidence-structure tests (independent sources versus shared dependencies and formal checks).

## Established mathematical scope

Within a single finite proof dependency DAG, the strictly triangular transfer matrix is nilpotent, hence spectral radius zero, allowing a finite path-sum exposure model. The publication-reuse graph may be cyclic and is a different object. The October 6 source snapshot reports **722 manuscripts, 597 bibliographic citation edges, and 73 mutual-citation groups**; those connections do not by themselves establish logical dependencies. Cost, origin and transfer parameters require separate calibration.

The 27 October exact-rational reference model had **216 synthetic DAG exposure comparisons** and **802 exact edge-derivative comparisons**. Here *independent* means an **alternate brute-force path-enumeration implementation** agreeing with the finite-DAG dynamic-programming reference path, with separate AI-written code. It does **not** mean human referee review, independently sampled empirical data, or independently developed assumptions. The code itself remains unpublished in this GitHub tree; the original paper records source SHA-256 values `reference_model.py = 4b9d272c832ceb0cb050dff7284f07f61cbb96462fd678b40844715c4fc3628c` and `independent_checker.py = 17f5321a325a274e2b0830cbeb003699f0273f1120a6b86e6d7ee562fcd2072c`. No fresh code rerun is claimed here.

## Public metadata freeze, and distinct graph preregistration

The **372-family metadata ranking** was locally recorded as frozen **2026-10-06 20:23:39 EDT**. Its complete ordered-family fingerprint `c429732aac46eae9` is reproduced from the source release at commit `adc7f1241b42e322a6451854ab7e4b4c146bf78a`. The **full CSV and SHA-256** are public: [freeze, exact hash and generator](pas/README.md); CSV SHA-256 `3e303b69ef8e530b5c618e61f9cb5c4527ea717b0588c59f2fb75b4afd5924e7`. Its scoring task is prediction of later *substantive manuscript revisions*, with rank-based evaluation against predeclared metadata baselines. Its historical local freeze date has **no externally controlled October 6 timestamp yet**.

A **separate manuscript-graph freeze** records `2026-10-07T00:05:14Z` with historical manifest digest `b0b439e0e44a4ea06f87297c9479063ae8aa26f7be731912d39ed6a1870ab697`. Its **H1 prospective test** is whether unit exposure `x₀N` predicts later substantive corrections better than own prior `x₀`, using a **one-sided 10,000-draw permutation test within equal-prior strata**; minimum **20 corrected manuscripts**, support at `p < 0.05`, decisive scoring **2027-04-06**. The original `PREREGISTRATION.md`, `FREEZE.json`, `MANIFEST.sha256`, graph files and source model, as well as an independently held third-party timestamp (e.g. Zenodo/OpenTimestamps), are still **not publicly available**. The digest is recorded rather than freshly matched to the original bytes. This is **historically recorded, publicly incomplete**, hence no claim that the October 7 graph experiment presently meets a third-party preregistration standard.

## Research direction and audit criteria

The proposed graph system makes claims atomic, typed, versioned, and attached to exact source spans. Bibliography links stay separate from proof-dependency edges; revisions trigger downstream review. Proposed tests compare evidence-complete answers at equal token budgets against flat retrieval, source-grounded retrieval and graph retrieval; separately compare calibrated PAS triage with simple upstream-first and reach/cost baselines. Measure complete support, answer correctness, human review cost, latency, and extraction error under temporally held-out, blinded labels. No deployed search advantage has been measured.

**Credit and limits:** Human-led by Devin J. Wright with AI research collaborators. Mathematical identities, synthetic arithmetic tests, retrospective adverse comparisons, historical freeze records, published metadata ranking and external peer review carry distinct status labels.
