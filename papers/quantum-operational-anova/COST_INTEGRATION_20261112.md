# COST research integration — November 12, 2026

Source-scope note, not a new manuscript certification. The archived COST sources are:

- [COST III — Operational hypergraph realization, noise spectrum, and fixed-budget selection complexity](COST_III_Observability_Recovery_Complexity.md). This is **author-side analytic work** plus [finite exact checker](checks/cost_master_exact_audit.py) and [replay log](checks/COST_III_EXACT_AUDIT_LOG.txt), not a new end-to-end Lean theorem or independent priority finding.
- [COST IV — Noise-robust quadratic interaction–visibility](COST_IV_Noise_Robust_Interaction_Visibility_Addendum.md). This is an **analytic corollary conditional on the independent Wright quadratic/SLD source proofs**; noise exponent 4 has an exact parity witness.
- [COST V — Trine visibility extremality](../quantum-sld-tensorization/COST_V_TRINE_VISIBILITY_FRONTIER.md), previously integrated and merged in [PR #406](https://github.com/d3lefts/d3lefts/pull/406). **The sharp all-qubit visibility lower bound remains a conjecture**; conditional COST V formulae cannot be cited as unconditional theorems.

## Scope distinctions

COST III concerns **fixed-register subsets, one-copy optimal scalar Bayesian readout**, a faithful *product average* (conditional ensemble states may be entangled), and a specific local replacement-noise channel. The exact subset gain has a nonnegative support spectrum and local noise scales an order-(s) contribution by (t^{2s}). Physical hypergraph realization uses locally prepared full-rank noncommuting qubits, and the cardinality-budget NP-completeness statement is about explicit classical descriptions of those realized instances.

COST IV assumes independent classical coordinates, local product preparation, positive local **SLD** contrast Gram and degree at most two. Its (t^4 a^2V^2/(2C_2B^2)) estimate concerns **terminal leave-one-register-out gain**, not stand-alone local measurement or an adaptive quantum-query rate. For all-binary classical inputs the extra denominator factor two is removed.

No computational speedup, external review, full Lean certificate, or worldwide originality is asserted. The [standalone influence manuscript](../sharp-influence-backdoors/README.md) contains the classical degree-two foundation and has independent proof dependencies from Turturean.
