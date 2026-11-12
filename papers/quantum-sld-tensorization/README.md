# Quantum SLD tensorization: sharp spectral constant and physical ternary saturation

**Status (11 November 2026):** Author-side **analytic theorem candidate with independent exact finite checks**, not end-to-end Lean-certified, not externally reviewed, and not globally novelty-cleared.

**Central result:** For faithful local density operators of condition numbers \(\kappa_i\ge1\), the optimal coefficient in
\[
J_{\otimes_i b_i}^{-1}\succeq C_d(\boldsymbol\kappa)\otimes_iJ_{b_i}^{-1}
\]
is exactly
\[
C_d(\boldsymbol\kappa)=2^{1-d}\prod_i(1+\kappa_i)/(1+\prod_i\kappa_i).
\]
A family of independent uniform ternary classical symbols, encoded into faithful qubits, attains this coefficient in *optimal scalar quantum Bayes gain*. In particular, local visibility and bounded condition numbers alone cannot replace the exponential interaction-order penalty with an inverse polynomial in the degree.

- [Full theorem, proofs, physical extremizer, and claim limitations](THEOREM_AND_AUDIT.md)
- [Full exact ternary score enumeration](checks/check_trine_score_exact.py)
- [Independent exact spectral and heterogeneous physical check](checks/check_spectral_constant_exact.py)
- [Existing quantum ANOVA source, with a different certification scope](../finite-product-influence/QUANTUM_ANOVA_BRIDGE_20261111.md)
- [Prior universal observability manuscript and certification boundary](../universal-observability/README.md)

Replay from repository root:

~~~sh
python3 -I papers/quantum-sld-tensorization/checks/check_trine_score_exact.py
python3 -I papers/quantum-sld-tensorization/checks/check_spectral_constant_exact.py
~~~

Both tools rely exclusively on Python's standard-library exact fractions. Passing them establishes the listed finite cases, **not** the proof of the general theorem. See .github/workflows/nightfall-quantum-sharp-sld.yml for CI.

**No Lean custody promotion:** The 65-source Lean provenance registry is unchanged. This project has no named kernel-certified final declaration. Novelty, specialist review and theorem-level Lean formalization remain independent gates. Do not claim quantum query speedups, adaptive measurement depth, or resolution of the general Aaronson–Ambainis question from this theorem.
