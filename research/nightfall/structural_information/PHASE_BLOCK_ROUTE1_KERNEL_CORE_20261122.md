# Phase block → Route1: exact checked core merged-source receipt

**2026-11-22. Scope:** this checkpoint integrates **only** two exact-source named Lean-checked modules and their finite arithmetic checker. The full raw-circuit → grouping → Route1 physical DTree terminal remains draft in [#1084](https://github.com/d3lefts/d3lefts/pull/1084). Do not promote that unfinished composition from these receipts.

## 1. Exact eight-state phase-block decoder and support rigidity

Module: `PhaseBlockRoute1.lean`. On four fixed real squared-linear sensors `(1,0),(0,1),(1,1),(1,-1)`, eight explicit sign-inequivalent integer signals provide a 4-symbol intensity code with:
- any three sensors identify the finite hidden state;
- for each possible first sensor, there is a first outcome for which every choice of second sensor leaves an indistinguishable pair, including **adaptive** policies;
- the whole raw table for any index type B has no Hamming-distance-one pairs;
- any rectangular product support contained in a no-edge code is a singleton, including arbitrary B-block tables.

**Kernel receipt** [#45058739792](https://github.com/d3lefts/d3lefts/actions/runs/45058739792) passed all 6 named declarations, standard axioms only. Independent arithmetic audit [#45058739579](https://github.com/d3lefts/d3lefts/actions/runs/45058739579) passed, with separate recursion certifying optimal worst-case finite decoder depth exactly three. The finite checker does not prove entropy or quantum statements.

## 2. Complex-path degree bound on actual block symbols

Module: `PhaseBlockQuantumDegree.lean`. For a finite family of complex amplitude paths, each with T factors depending individually on a hidden block variable, and any fixed (input-independent) complex effect E, the real quadratic acceptance `effectValue` has `Route1LatentDegree.DegreeLE` at most 2T. The predicate is **definitionally** the Route1 `HasProdDegreeLE`, as demonstrated by merged `Route1DegreeSourceBridge.local_to_source`. Its proof genuinely derives a finite-support representation, not merely assumes the 2T degree claim.

**Kernel receipt** [#45059108351](https://github.com/d3lefts/d3lefts/actions/runs/45059108351) passed named theorem `effectValue_degree` and source axiom gate. It does not itself prove generic matrix-oracle circuit→path expansion; corresponding prior merged `QuantumCircuitPaths`/`QuantumCircuitSimulation` modules are separately available on main.

## 3. Classical source coding and credit

For B independent uniform 8-state blocks, the raw 4B distinct physical intensity coordinates are a code with no single-coordinate neighbors. Any conditional product distribution supported in that code is Dirac, hence the *classical* entropy consequence is `C_W(Y)=H(Y)=3B bits`; on decoded independent 8-symbol blocks `C_W=0`. The Wyner entropy equality is a **paper-level use of the certified combinatorial lemma**, not an additional Lean theorem.

**Independent parallel confirmation:** [merged PR #1087](https://github.com/d3lefts/d3lefts/pull/1087) constructed a **different** eight-state integer signal code under the same sensors, with independently certified any-three and adaptive-two behavior. Preserve both authors' work and the independent reconstruction; no world-first claim. Further, B-independent query complexity already follows by the trivial four-reading per-block fetch; the fixed-sensor phase decoder improves the cost to three. This is **not** a general lower bound for arbitrary sensing vectors, nor a guaranteed factor-4/3 speedup on every task.

**Outstanding work:** [draft #1084](https://github.com/d3lefts/d3lefts/pull/1084) carries a *computable* 3-read physical `ProductSimulation.DTree` compiler, generic degree pullback from raw to decoded blocks, direct original matrix-oracle `QuantumCircuitSimulation` link, and actual Route1 source terminal. Those source files must pass independent exact-head named Lean builds before any global quantum-simulation promotion. Query bounds do not certify classical preprocessing complexity, state simulation, quantum sampling, relative signs, or worldwide novelty.

## Source custody rules

Current main's 67 historical source-matched Lean records remain immutable. Register the two new exact blobs as `unreviewed-source` under the strict pending ledger even though they have separately successful named Lean compiler receipts; source-custody metadata does not automatically convey an end-to-end formal proof or peer review. The paper-level core, prior-art and future terminal are intentionally different certification levels.
