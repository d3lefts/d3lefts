# Operational quantum ANOVA — reproducible v2 archive

**Status (11 November 2026):** Analytic author-side theorem and independently designed finite falsification checks; **not** Lean kernel-certified, externally refereed, or globally priority-cleared. This is the source-complete **v2 proof checkpoint**, not a claim that the v3 quantum ANOVA bridge is new or superseded.

- [v2 analytic theorem, exact operational support expansion, metric-kernel distinction](OPERATIONAL_QUANTUM_ANOVA_v2.md)
- [Current v3 / classical quadratic influence synthesis](../finite-product-influence/QUANTUM_ANOVA_BRIDGE_20261111.md)
- [Sharp SLD tensorization and physical ternary no-go](../quantum-sld-tensorization/README.md)

## Replay

Requires Python with \`sympy\` and \`numpy\` installed. From the repository root:

\`\`\`sh
python3 papers/quantum-operational-anova/checks/exact_audit.py
python3 papers/quantum-operational-anova/checks/near_degenerate_audit.py
python3 papers/quantum-operational-anova/checks/metric_family_audit.py
\`\`\`

All three scripts were replayed from the uploaded v2 archive on November 11, 2026, with exact checks passing for biased noncommuting qubits, near-singular \`κ_Q=133302015\`, and 200 deterministic-seed noncommuting complex cases over four metrics. Numeric tests are falsification evidence, **not** proofs of the universal theorem. No external submission or claim registry promotion is implied.

The original v2 source bundle SHA-256 was \`5a5917aaf0b7f1feb950fc61cb7fd0fddb12353106f41fab4c078c8445524688\`. The contents are checked in here as human-readable source instead of a binary archive; any later edit changes the Git version, rather than silently overwriting the historical source.
