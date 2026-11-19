# NIGHTFALL research-engineering evaluation tasks (2026-11-19)

Status: **benchmark prototypes, not validated model evaluations**. These tasks are inspired by NIGHTFALL's latent-product simulation and formal-proof integration work. They do not claim affiliation with Google DeepMind's Polaris team.

## Task contract
Each task has a prompt, inputs, machine-checkable oracle, and limitations. Agents must not receive reference outputs or hidden tests in the evaluated workspace. The included deterministic fixtures are public smoke tests, **not hidden evaluation data**.

| Task | Objective | Checkable output | Status |
|---|---|---|---|
| ProofGraph | Integrate pinned Lean modules without assuming CI of isolated modules implies unified Lake closure | Exact module imports, axiom report, fresh-build log, source/commit hashes | Specification only; real pinned Lean checkout required |
| TheoremBreak | Find counterexamples to unjustified mixture/conditioning inference | Finite rational counterexample verified by checker | Executable starter fixture |
| InvariantLab | Demonstrate product-mixture rank can grow exponentially while deterministic query depth stays one | Explicit finite product-mixture rank lower bound and query decoder | Specification; proof obligations open |
| PotentialForge | Audit an entropy-potential improvement, not reproduce an unverified claimed theorem | Independently reviewed proof or finite counterexample | Research candidate; no benchmark ground truth |

## TheoremBreak starter
Run `python3 check_theorembreak.py examples/counterexample.json`. A valid answer must give two distributions on a finite set with **identical single-coordinate marginals but different joint probabilities**. This refutes the inference that matching marginals implies matching joint laws; it does not refute any particular published theorem. The checker uses exact rational arithmetic and independently recomputes both conditions.

The supplied example is a smoke test. For scored evaluation, create held-out variants and ensure the prompt does not disclose the witness.

## ProofGraph task specification
Input: a clean checkout pinned to a stated commit, a fixed Lean toolchain, and a manifest of required declaration names, modules, and allowed axioms. Agent task: integrate imports into the generated Lake manifest, resolve conflicts without weakening declarations, and provide machine-readable receipts.

Pass criteria: (1) `lake build Nightfall` from fresh checkout, (2) every named theorem elaborates at the pinned toolchain, (3) `#print axioms` matches the allowlist, (4) independent `lake check` replays the built objects, (5) receipts include source hashes. CI runs for isolated modules are insufficient. No scores until reproducible runner and baseline results exist.

## InvariantLab task specification
Construct a distribution on paired coordinates (X_i,Y_i) with Y_i=X_i and X uniform independent bits. Show the minimum number of *full-coordinate product distributions* in a positive mixture representation is at least 2^n: each product component supported on the diagonal must fix each pair (X_i,Y_i), so it is a point mass. Yet a deterministic decoder of X_i queries Y_i once. State precisely the query task and encoding; do not infer an arbitrary function's simulation cost from this observation.

## Scoring policy
Validity is a hard gate. For a task with a complete oracle: 35% correctness, 25% reproducibility, 20% mechanism/generalization, 15% robustness on held-out instances, 5% efficiency. A task with no validated oracle is **unscored**. Do not label fixture pass rates as model benchmark performance.

## Next gates
1. Reconcile this directory with the repository's existing evaluation lab; avoid duplicate public navigation.
2. Add pinned Lean integration fixtures and a hermetic container runner for ProofGraph.
3. Independently verify TheoremBreak held-out instances and establish failure baselines.
4. Audit InvariantLab's support/rank proof and source attribution.
5. Keep PotentialForge quarantined pending independent mathematical audit and prior-art review.
