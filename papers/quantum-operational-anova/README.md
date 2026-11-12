# Operational quantum ANOVA — reproducible v2 archive

**Status (11 November 2026):** Analytic author-side theorem and independently designed finite falsification checks; **not** Lean kernel-certified, externally refereed, or globally priority-cleared. This is the source-complete **v2 proof checkpoint**, not a claim that the v3 quantum ANOVA bridge is new or superseded.

- [v2 analytic theorem, exact operational support expansion, metric-kernel distinction](OPERATIONAL_QUANTUM_ANOVA_v2.md)
- [Current v3 / classical quadratic influence synthesis](../finite-product-influence/QUANTUM_ANOVA_BRIDGE_20261111.md)
- [Sharp SLD tensorization and physical ternary no-go](../quantum-sld-tensorization/README.md)

## Replay

Requires Python with `sympy` and `numpy` installed. From the repository root:

```sh
python3 papers/quantum-operational-anova/checks/exact_audit.py
python3 papers/quantum-operational-anova/checks/near_degenerate_audit.py
python3 papers/quantum-operational-anova/checks/metric_family_audit.py
```

All three scripts were replayed from the uploaded v2 archive on November 11, 2026, with exact checks passing for biased noncommuting qubits, near-singular `κ_Q=133302015`, and 200 deterministic-seed noncommuting complex cases over four metrics. Numeric tests are falsification evidence, **not** proofs of the universal theorem. No external submission or claim registry promotion is implied.

The original v2 source bundle SHA-256 was `5a5917aaf0b7f1feb950fc61cb7fd0fddb12353106f41fab4c078c8445524688`. The contents are checked in here as human-readable source instead of a binary archive; any later edit changes the Git version, rather than silently overwriting the historical source.


## November 12 COST III–IV research source addition

[Research integration map, dependencies and certification](COST_INTEGRATION_20261112.md) links the now-archived [COST III quantum hypergraph/complexity manuscript](COST_III_Observability_Recovery_Complexity.md), its [exact finite checker](checks/cost_master_exact_audit.py), and [COST IV noise-robust quadratic terminal visibility](COST_IV_Noise_Robust_Interaction_Visibility_Addendum.md). The sharp all-qubit [COST V trine visibility](../quantum-sld-tensorization/COST_V_TRINE_VISIBILITY_FRONTIER.md) conjecture was already merged separately in PR #406; it is not proved by these checks.

COST III's finite exact replay includes 64 rational density-matrix cases, 4 entangled conditional/product-average cases, 1,098 finite graphs and a bounded-width dynamic-programming test. It **does not** supply a new global uniqueness, computational efficiency for arbitrary representation, or end-to-end Lean certificate. COST IV is conditional on the separate quadratic influence and SLD premises. No unpublished result is represented as peer-reviewed or priority-cleared.

\`\`\`sh
python3 -I papers/quantum-operational-anova/checks/cost_master_exact_audit.py
\`\`\`
