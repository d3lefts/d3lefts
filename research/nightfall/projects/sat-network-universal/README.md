# NIGHTFALL independent agent proof — universal factor-network reduction

The universal mathematical theorem and its scope appear in [THEOREM_AND_SCOPE.md](THEOREM_AND_SCOPE.md). A standalone deterministic graph checker, structurally independent exhaustive tests, and adversarial counterexamples are included.

```bash
python3 check_structural_certificate.py example_graph.json
python3 verify_universal_factor_compiler.py
python3 exhaustive_cnf.py
python3 adversarial_controls.py
```

The proof and tests use only standard Python 3.10+; no third-party dependencies. The exact identity holds over any commutative semiring; the finite tests instantiate natural integers, signed integers and free formal polynomial monomials.

**Status:** PASS for the exact constructor, universal mathematical bijection, and tested proof certificates. No proof-assistant kernel proof of the universally quantified theorem. The faster contraction asymptotics from an outside 2026 paper remain a separate unverified claim.