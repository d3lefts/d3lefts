# CONSTELLATION / Living Investigation: Discovery Loop Pilot

**29 October 2026 · implementation tier: bounded research-instrument pilot**

## Thesis

NIGHTFALL's tools already define, attack, check, and archive evidence. The missing capability is *research-state-dependent selection of the next experiment*. The first implementation is deliberately narrow: a deterministic, transparent, finite mathematical pilot, not a simulated autonomous researcher. Its essential scientific question is whether a local heuristic prediction survives a complete finite search.

## Runnable protocol

- **Seed.** A preselected question asks whether the elementary cyclic correlation bound remains sharp when six marked positions grow from a 15-position cycle to 16.
- **Represent.** A configuration is a binary length-n cyclic word with exactly m marked indices, with 8 ≤ n ≤ 16 and 3 ≤ m ≤ 6. For each nonzero cyclic displacement d, count ordered pairs of marked positions separated by d. Minimize the maximum displacement count.
- **Lower bound.** All displacement counts sum to m(m−1), so the maximum is at least \`ceil(m(m−1)/(n−1))\`. This elementary counting argument is established background, not a new theorem.
- **Selection.** After the first experiment, score untested parameter pairs by proximity to the most recent result, forward-adjacent mass-preserving tests, novelty, prior failed prediction, and finite computational cost. The deterministic scoring rule is in \`docs/discovery-loop-core.js\`; no large language model, cloud runner, or real background agent is connected.
- **Hypothesis.** Predict the exact lower-bound gap from the nearest previously enumerated same-mass pair. This is expressly a *heuristic local-transfer prediction*, never a universal mathematical claim.
- **Decisive experiment.** Enumerate all (n−1 choose m−1) subsets containing position 0; every nonempty cyclic subset has a translate containing 0. For each, calculate all nonzero correlation shifts and the minimum possible maximum. Store one optimum configuration, correlation histogram, subset count, exact lower bound, and the gap.
- **Falsification.** Compare prediction and complete finite optimum. If they differ, emit a Discovery Residue containing source parameters, observed discrepancy, an explicit falsifier, a new structural research question, and an evidence-scope label. A positive strict gap also produces a residue in the absence of failed prediction.
- **Stop and export.** Maximum twelve experiments. Browser-local persisted state, explicit run buttons, versioned JSON export and replay. A copied receipt is untrusted input; its contents must be recomputed before use.

## Controlled first-two-step experiment

The deterministic pilot starts at (n,m)=(15,6), where the elementary lower bound of 3 is attained. The adaptive rule then selects (16,6), hypothesizing that the lower-bound gap remains 0. Exhaustive finite enumeration yields exact minimax 3 versus elementary bound 2: **gap 1**. That prediction is refuted within the finite cyclic model. A local explanation cannot yet be promoted to an infinite-family theorem or worldwide original result.

A fixed illustrative control schedule (15,6) then (14,6) observes two sharp cases and misses the n=16 gap in the same two evaluations. This is a single designed contrast, **not** a randomized, blinded or broadly representative efficiency benchmark. Its selection advantages are conditional on the seeded question. A meaningful system-level claim about superior discovery efficiency requires matched compute budgets, multiple unseen research problems, precommitted metrics and independent review.

## Verification and adversarial controls

- \`scripts/test_discovery_loop.cjs\`: independently enumerates **all** binary masks (not anchored subsets), and counts each shift by direct bit-vector multiplication for small and target instances. Confirms the two key optima, subset counts and sample witnesses.
- The algorithm internally recomputes its displayed optimum witness with a second direct-shift arithmetic implementation.
- Deterministic local replay reconstructs every selection, prediction, result and residue from the fixed initial state. Tests corrupt the optimum, prediction status, target, residue ledger and duplicate-target history, and require rejection.
- The website's mobile/desktop browser smoke walks the first two steps, confirms the failure-residue label, checks JSON export, corrupts browser persistence, confirms reload rejection, and tests four-step execution.
- The CI runs this pilot as a website research instrument test; this is **not external mathematical proof checking**. External implementation and dated closest-prior-art comparison remain open scientific gates.

## Status and separation

**Locally executable finite enumerations and reproducible heuristic prediction failure, with internal independent-code-path arithmetic tests.** This pilot has neither autonomous server execution nor an LLM researcher. Its observed finite gap is known small-scale cyclic design territory; no mathematical novelty, record or flagships are claimed. The original 131,072-cell continuous minimum-overlap construction is unaffected, since its continuous signed-shift objective is different from this cyclic discrete proxy.

The pilot records research residues in its **own versioned browser-local state**, with no automatic transition into the separate Discovery Engine, Referee, Claim Lab, Atlas, or GitHub issue tracker. Future connections require precise matching domain types, independently checked imports, no silent status promotion, and explicit human release gates.

## Next release gate: real original finding discovery

Run a precommitted comparison on a *live unresolved* NIGHTFALL assignment with (a) a fixed-budget nonadaptive schedule, (b) a fixed-budget adaptive residue loop, and (c) the same source dossier, independent checker and prior-art access. Record the first genuinely new, decisive falsifier, construction, proof lemma, or structural invariant attributable to loop choice; externally audit originality and measure effective compute costs. A failure to outperform the baseline must be displayed, not hidden.

**Engineering objective:** a research system that modifies its own investigation after a reproducible surprise. **Publication objective:** an original contribution that survives separate evidence and approval gates. These are two different claims.