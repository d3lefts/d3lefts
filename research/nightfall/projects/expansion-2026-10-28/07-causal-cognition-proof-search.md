# Dossier 07 — Causal cuts, capability measurement, and proof-search obstruction calculus

**Source dates:** 2026-10-01 to 2026-10-12. **Status:** mathematical framework manuscripts plus synthetic studies; no physical time theory or frontier-system capability claim.

## A. Directed causal-cut factorization

A directed causal-cut system begins each deterministic phase in canonical fresh data specified by an interface state \(q\). A phase either halts, diverges, or crosses an irreversible cut that emits the interface state \(\sigma(q)\) for the next phase. The entire evolution factors through the forward orbit of the partial map \(\sigma\).

Let \(Q^*\) be the quotient under equality of complete future behavior, including future cut states and within-phase costs. For an autonomous halting orbit with finite \(Q^*\), **no predictive equivalence class repeats**, giving a bound of \(|Q^*|\) phases. Every exact predictive summary must distinguish inequivalent future classes.

The paper assigns the bookkeeping value \(T=C+iH\), where \(C\) is accumulated nonnegative phase cost and \(H\) counts cuts. The imaginary term records a cut count: it is **not a physical time coordinate, spacetime metric, or observation of backward/complex physical time**.

Primary source: \`Directed_Causal_Cuts_Complex_Flowtime.pdf\`; motivating application: [fresh-layer Busy Beaver](04-busy-beaver-return-maps.md). Mechanisms overlap classical finite-state minimization, bisimulation, predictive-equivalence, and automata arguments. Novelty requires comparison at the level of precise theorem assumptions.

## B. Cognition First — inferential ordering

The \`Cognition_First.pdf\` working paper separates measurable capability under elicitation from consciousness-related hypotheses. Four numerical and structural results guide experimental design:

- Repeated-sampling gain curves encode moments of latent success-probability mixtures; observable failure is not a fixed inability label.
- Under the declared Rasch/item-response model, all-failure items may remain observationally indistinguishable while differing in prospective escape probability.
- Pooling failure mechanisms predicted to respond in opposite directions can seriously reduce detection power.
- Measurement error in a cognition covariate can manufacture spurious apparent residual common structure in consciousness indicators.

The October 7 report describes **illustrative simulations**, including a synthetic power shift 0.46 to 0.92 under failure-class separation and an 86% false-null rejection in a specified mismeasured-cognition simulation. These are *model-dependent synthetic outcomes*, not empirical estimates about current AI models.

## C. Transport Control — executed synthetic pilot

\`Transport_Control_Run_001.md\` gives exact independent-retry identities for valid pass \(v\), invalid scored pass \(i\), and failure \(f=1-v-i\). If \(q=v+i\), any raw pass in \(k\) independent tries has probability \(1-(1-q)^k\); selected valid outcomes depend on the selection and audit policy. Identical raw pass rates can produce very different selected-valid rates. One pilot intentionally changed the data-generating mechanism and broke prior predictions, recording the extrapolation limit.

This establishes an evaluation-transport *methodological lesson* under synthetic assumptions, without claiming real frontier-model capability improvement.

## D. Premise-relative proof-search obstruction calculus

For retained assumptions \(A\), admissible state class \(X_A\), target \(F:X_A\to Y\), and representation \(R:X_A\to V\), the target factors through \(R\) **iff**
\[
R(x)=R(y)\Longrightarrow F(x)=F(y)\quad\text{for all }x,y\in X_A.
\]
An admissible pair with the same \(R\)-image and different \(F\)-values is a decisive insufficiency certificate. Comparing induced partitions helps remove redundant mechanisms from proof search. This proposition is elementary; the research contribution being assessed is the auditable protocol for *using* such obstruction pairs, tracking assumptions, and demoting failed proof paths.

Primary sources: \`Premise_Relative_Obstruction_Calculus_v1.2.pdf\`, \`The_Witness_Boundary.pdf\`. The existing [AI-safety theory dossier](../ai-safety-peer-review-2026-10-28/README.md) gives the related observation-fiber formalism.

## Publication and reviewer boundaries

This folder provides theorem statements and study provenance. The original PDFs, synthesis code, and simulation datasets await a separate binary mirror. Peer reviewers should attack predictive-equivalence definitions, cost accounting, identifiability assumptions, synthetic data leakage, and any overclaim of application beyond the specified models.
