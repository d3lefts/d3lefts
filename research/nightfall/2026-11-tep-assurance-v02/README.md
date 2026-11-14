# NIGHTFALL — Mission-Conditioned Recertification of Autonomous Multi-Agent Systems

**Program:** Assurance Engineering for Superintelligent Systems  
**Version/date:** v0.1 / 2026-11-13  
**Lead:** Devin J. Wright, NIGHTFALL; AI-assisted research scaffolding  
**Status:** research charter plus separately implemented finite *toy-contract* computation; **not** a Tennessee Eastman result, certified plant safety, verified frontier-AI control, novel theorem, or externally reviewed contribution.

## 1. Principal research question

What is the minimum total trusted information acquisition, model computation, certificate construction/checking, and engineering work needed to reauthorize a changed multi-agent system for a specified mission, while meeting quantitative soundness and completeness requirements?

An early shorthand is `C*(M, Δ, G, O, δ)`, for mission, authenticated changes, dependency structure, allowed observation/checker interfaces, and false-authorization budget. A well-posed version must **also specify** the world/model class, horizon, true safety predicate, acceptable nonauthorization/error rate, and cost accounting. Otherwise a 'deny every action' policy achieves vacuous zero verification cost.

For a world class W and protocols π producing a certificate and an authorization decision, require:

- **Soundness:** `sup_{w in W_unsafe} P_w(π authorizes) <= δ`.
- **Useful completeness:** `inf_{w in W_safe_target} P_w(π authorizes) >= 1 - α`, or a predeclared mission-dependent service guarantee.
- **Authenticity and lifecycle validity:** each trusted measurement, model bound, and reused evidence object must have a verifiable provenance, freshness rule and explicit dependence on changed components.
- **Cost:** `E_w[C_sensing + C_model_calls + C_compute + C_authentication + C_proof_check + C_repair + C_approval]`, with time, money, and resource usage recorded separately before applying a declared common weighting.

**Target:** prove matching upper/lower bounds under precisely matched observations, model and adversary access, and exhibit conditions under which cost scales with active boundary/mission interactions rather than whole-system size.

## 2. Existing mechanism and limits

Build on the exact finite research in `research/nightfall/2026-11-digital-twin-evidence-cut/README.md`, already present on NIGHTFALL `main`. It contains a *conditional* contractive boundary-envelope theorem, a 128-site rational ring where 121 of 127 external safety claims survive, and modular evidence-complementarity constructions with finite checkers. Source validity and physical calibration are external assumptions. Its lower bounds are scoped to specially typed oracles, not general multi-agent control. **Do not relabel existing certificates as novel universal safety results.**

The current v0.1 executable below solves a **restricted deterministic evidence-selection problem**. Each obligation admits a disjunction of alternative *conjunctive* evidence sets; a selection is adequate iff one complete alternative is acquired for each mission obligation. This captures informational complementarity (a pressure reading without its calibration is not treated as a certificate) but **does not establish that any alternative is physically sound**. That premise is supplied by the hypothetical contract file.

The general finite weighted selection problem is NP-hard: weighted set cover reduces to the special case where each target obligation has singleton alternatives for the evidence sources covering it. Consequently, broad claims of efficient global exact optimization need structure, parameterization, approximation or a lower bound qualifying the computational regime. This is a classical complexity observation, not a novelty claim.

## 3. Source-matched engineering testbed

**Simulator:** Johandri Vosloo, Kenneth R. Uren, George van Schoor, *A complete and open Simulink model of the Tennessee Eastman Process (COSTEP) for the purpose of control and process monitoring*, *Digital Chemical Engineering* 20 (September 2026), 100328; https://doi.org/10.1016/j.dche.2026.100328; MIT source https://github.com/kennyuren/COSTEP. Requires MATLAB R2024b+, Simulink, Signal Processing Toolbox and DSP Toolbox. Exposes 145 additional measurements and internal process variables. The article reports a roughly 3-minute 24-hour simulation on its test machine versus ~20 seconds for the FORTRAN baseline; these are **literature results**, not our measurements.

**Benchmark:** Christopher Reinartz, Murat Kulahci, Ole Ravn, *An extended Tennessee Eastman simulation dataset for fault-detection and decision support systems*, *Computers & Chemical Engineering* 149 (2021), 107281; https://doi.org/10.1016/j.compchemeng.2021.107281; data https://doi.org/10.11583/DTU.13385936.v1 (CC0, full archive ~132.96 GB). Includes 28 fault conditions, six modes, 500 seeds per fault, 100-hour runs, three-minute sampling and operating transitions. **The dataset was generated from Bathelt's earlier extended model, not COSTEP. Neither is a live-plant dataset.**

**Do not assume the raw-data file schema without reading its README.** Acquire a deliberately small, versioned seed/mode/fault subset and record file SHA256, exact file names, variable mapping, source URL, and simulator commit. The complete 133-GB download is neither necessary nor justified as the first step.

### Required experimental architecture

- Plant physics: unchanged, deterministic/stochastic simulator with logged solver and seed; faults and changes injected via a versioned interface.
- Agents: reactor observer, separator/recycle observer, product-quality observer, supervisory planner, policy executor. All tool calls and proposed actions logged. No agent is itself a trusted source of its own correctness.
- Assurance kernel: independent deterministic checker for evidence provenance, mission/config version, safety predicates, contract assumptions, cross-agent dependencies and proof object. Only it can issue authorization in the simulation.
- Adversary/faults: changed controller/model, stale calibration, corrupted source record, coordinated or correlated sensor fault, adversarial agent recommendation, mission transition, weak observable faults.
- Missions: (a) containment/constraint preservation, (b) product quality. Actual pressure, composition and actuator bounds must come from simulator/controller specification or independently justified engineering assumptions; **none are certified yet**.

### First pre-registered comparisons

The same dataset seeds, allowed sensors, noise model, threat model, solver, logging and certificate rules apply to every strategy:

1. Full re-analysis and evidence reacquisition.
2. FASE 2026-style dependency-triggered analysis slicing, **implemented faithfully**, not an artificially expensive all-source proxy.
3. Existing boundary-envelope / evidence-cut mechanism under its documented contraction assumptions.
4. Mission-conditioned, complementarity-aware evidence acquisition with charged authentication and verification.
5. For small finite instances, exact optimal selection and exhaustive independent checking as an optimum certificate; for larger instances, bounds and timed solvers.

**Primary endpoints:** number of unsafe authorizations (subject to explicit statistical uncertainty), safe authorizations/service rate, total audit cost, cost disaggregation, time-to-reauthorize, false rejections, certificate replay, and robustness under alternative seeds, modes and cross-simulator transfer. A single clean zero-failure run does *not* statistically establish low risk.

**Hypothesis to falsify:** mission-conditioned selection and certified boundary reuse yield a lower total source-matched cost than a faithful FASE-style incremental baseline *without increasing unsafe authorization within a predeclared risk tolerance*. If provenance, calibration, repeated-change error composition or lost controller validity erases the cost advantage, report that failure. Test strongly observable disturbances and weakly expressed faults separately: COSTEP's 2026 paper explicitly warns that some labeled faults barely affect standard observed variables.

**Cheapest decisive real-world-data experiment:** one normal/fault pair using a shared seed, a single documented operating mode, the logged pre/post-fault sensor mapping and one chosen mission; then attempt an independent calibration/provenance check and compare correct evidence requests. Do not add LLM agents until the physical/source baseline is reproducible.

## 4. Prior art and novelty bar

- T. Liu, S. Tyszberowicz, B. Beckert, *Analyses as First-Class Citizens in Model-Driven Development*, FASE 2026, DOI: https://doi.org/10.1007/978-3-032-22774-4_10. Establishes sound analysis slicing and incremental recertification; our baseline must reproduce its applicable semantics rather than use a straw man.
- Zaker, Nejati, Lavaei, *Data-Driven Safety Certificates of Infinite Networks with Unknown Models and Interconnection Topologies*, preprint https://arxiv.org/abs/2507.10979, later Automatica research. Addresses compositional data-driven safety of interconnected systems.
- Zhang and Xu, *Certified Task-Conditioned Active Observability*, https://arxiv.org/abs/2609.28520 (2026 preprint). Addresses task-specific observation and certification; match observation access exactly before claiming novelty.
- Classical baselines: weighted set cover, Dobrushin/contractive perturbation bounds, sequential hypothesis testing, formal assume-guarantee verification, safety cases and threat-modelled AI control.

A novel contribution must establish a substantively different theorem, oracle-matched complexity separation, or externally reproducible engineering improvement—not merely rename composition, analysis slicing or active sensing.

## 5. Reproducible v0.1 finite pilot

- `cases.json`: illustrative 5-unit-process-inspired *synthetic* evidence contract set, two missions, nine evidence actions with abstract integer costs. No real TEP measurements or calibration.
- `solver.py`: shortest-path/Dijkstra selection over acquisition subsets. For this finite input, finds exact minimum total abstract evidence cost for the declared trusted contracts.
- `audit.py`: separately constructed exhaustive subset enumeration, compares optima, tests single-source unavailability and ensures mandatory authentication is never silently bypassed. The direct enumeration is independent of the solver algorithm, **not an external human review**.

Run using Python 3.10+ with no third-party dependencies:

```bash
cd nightfall_te_assurance_v0_1
python3 solver.py
python3 audit.py
```

As of v0.1 local execution, two synthetic mission instances produced exact abstract costs `15` and `19`; direct enumeration matched both; 25 assertions passed. The toy full-source baseline costs `34`, and the toy union-of-alternatives baselines `25` and `29` respectively. **These baselines are not faithful implementations of FASE, do not use source data, and are not publishable performance comparisons.**

## 6. Milestones and stop rules

**M0 (this artifact):** Charter + source/provenance ledger + small exact candidate/checker; done; synthetic-only.

**M1:** Obtain a small, authentic 2021 benchmark subset; inspect schema and SHA256; establish independent seed/mode/fault partitions; verify the published baseline variables and fault activation timing; run same-source fault detection and monitoring. Stop if the data provenance or variable correspondence cannot be established.

**M2:** Run COSTEP under its actual MATLAB environment; record simulator git commit and MATLAB/toolbox versions, cross-check 2021 source traces under matching modes, fault timing and controllers; do not silently conflate models. Stop if cross-simulator differences dominate the intended effect.

**M3:** Implement reauthorization kernel and proof objects for genuinely justified safety contracts. Compare all baselines with identical observations and all costs charged. Stop/retire the numerical claim if mission-conditioned gains disappear under authentic calibration, authentication and checker costs.

**M4:** Prove a restricted mathematically original bound if one survives complete comparison with FASE, data-driven safety certification and active observability; commission independent review. No automatic promotion to theorem, breakthrough, or published result.

**Version and reproducibility:** preserve local SHA256 of this bundle, source commit IDs, run manifests, failure cases and exact commands. Additional runs should record environment, input hashes, configuration, measured wall-time and algorithm versions.

### Normalized signal export diagnostic (not source certification)

`paired_seed_diagnostic.py` accepts two **already normalized** long-equivalent wide CSVs (one sample per row, `time_s` and common sensor columns), with identical timestamps and chosen post-fault activation time. It checks alignment and numeric integrity, and reports pre/post paired RMS differences. It does **not** read the DTU archive's unknown native format, determine a safe threshold, validate sensor calibration, or establish physical safety. The included CSVs are explicitly synthetic smoke-test fixtures. In an authenticated COSTEP run, generate these normalized exports from the simulator at the same seed/controller/mode using its documented experiment script, and preserve their file hashes and configuration.

```bash
python3 paired_seed_diagnostic.py examples/normal_toy.csv examples/fault_toy.csv --fault-time-s 12
```

---
## v0.2 incremental research checkpoint (2026-11-13)

**Status:** finite synthetic-contract reauthorization optimized and checked; preliminary historical-source monitoring result from separate FORTRAN-lineage data; **NO authentic DTU 2021 paired trace, no COSTEP run, no calibrated safety predicate, no frontier-AI control, no new externally reviewed theorem**.

### New exact restricted construction

`lifecycle_cases.json` specifies versioned evidence with source dependencies, changes, prior certificate records, freshness steps, external authentication flags and two possible acquisition modes (`reuse` or `reacquire`). `lifecycle.py` computes the minimum additive cost satisfying each mission obligation via at least one *whole* permitted evidence bundle, and emits a replayable contract certificate. It refuses unknown components or unregistered dependencies. Authentication flags are **trusted inputs**; this is not a signature-verifying cryptographic protocol.

The cheapest action for each chosen evidence source is sufficient under these declared source-identity-only obligations and additive costs. Exact Dijkstra on acquisition subsets returns the global optimum in the finite contract model; independently written Cartesian-product enumeration and proof replay compare solutions. NP-hardness of the general weighted disjunctive-bundle selection problem follows from weighted set cover; this is a classical result, **not a novel theorem**. The bound `C*` for stochastic agent interaction, incomplete sources, physical safety, and nonzero `δ` remains open.

Run:

```bash
python3 lifecycle.py
python3 independent_lifecycle_audit.py
python3 test_v02.py
python3 audit.py
```

Synthetic-only lifecycle costs: `controller_change = 10`, `quality_change = 12`, `no_change = 5` abstract units. 110 independent-audit assertions, 11 fail-closed tests and the earlier 25 standalone checks passed. **Do not interpret these numbers as savings against FASE or costs observed in a Tennessee Eastman plant.**

### Source inspection and initial monitoring probe

`UPSTREAM_AUDIT.md`: COSTEP upstream code ingestion defects and DTU retrieval limitations. `original_tep_probe.py`: hash-pinned normal-training/normal-testing/fault-1 single-run historical TEP comparison; `results_historical_source_observed.json` and `SOURCE_PROBE.md` contain source-derived provisional readings. `export_costep_arrays.m` and `validate_normalized_pair.py`: fail-closed normalized data interface, not tested on an authentic COSTEP or DTU trace. Normalized paired CSVs in `examples/` remain **synthetic**.

The top selected signal XMEAS(4) flagged 743 of 800 post-window fault-1 samples against 4 of 800 normal ones under a fixed 3-SD rule; XMEAS(40) flagged zero in both traces. These are serially correlated sample counts from different traces; the first-order conclusion is only heterogeneous fault observability. This historical source is **not** the requested DTU reference source; its data must not be used as DTU-calibrated evidence.

### Decisive experiment and stop rule

Obtain DTU dataset native README plus a small, externally authenticated normal/fault pair with identical mode/seed, and one completed MATLAB COSTEP run with the model commit, controller and exact variable mapping recorded. If both cannot be acquired, **do not claim** a cross-simulator performance result. Once available, implement the actual FASE analysis-dependency graph with correct triggers and required goals, then compare complete lifecycle costs including provenance, sampling, inference, verification and false acceptance under identical oracle/mission access. A cost benefit failing under these charges is a negative result to archive.
