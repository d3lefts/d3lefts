# NIGHTFALL v8: Homogeneous-cubic / soft-cover bridge

This is a new, narrow analytic synthesis, **not** a proof of the unrestricted cubic variance-squared influence conjecture.

Run `python3 checks/exact_bridge.py` from this directory (stdlib only). The checker constructs an explicitly heterogeneous rational product distribution, computes ANOVA components independently using the Möbius conditional-expectation formula, checks cubic coefficient extraction and energy-cover identities, verifies the greedy weighted-cover recurrence on every small subset, and gives negative controls against posterior stability and additive adaptive-tail error.

`THEOREM.md` gives the homogeneous reduction, top-linear-cubic extension, layerwise-linearity theorem, soft energy-cover observation result, prior-work dependencies, and exact limits. `SHA256SUMS` verifies all source and output files (excluding itself). The ZIP also has an `ARCHIVE_SHA256.txt` supplied alongside the ZIP, not self-referentially within it.