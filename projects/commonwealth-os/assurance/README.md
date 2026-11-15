# Democratic Assurance — finite proof-passport workbench

Read [FORMAL_ASSURANCE_v0_3.md](FORMAL_ASSURANCE_v0_3.md) before using any result. This is a scoped mathematical workbench, not a deployed voting or authorization service.

The reference implementation in [finite_model.py](finite_model.py) defines finite-world observational certificates, exact nominal minimum-cost observation sets, an atomic-sink abstraction, and a conservative version-matching guard. [independent_audit.py](independent_audit.py) compares certificate optimization against a different dynamic-programming oracle and attacks the guard with invalid snapshots, stale epochs, revocation, and replay. Run `python3 independent_audit.py` with Python 3.11+ and no external dependencies.

The analytic theorems are P1 (finite-world soundness and exact nominal observation certificate), P2 (same-world composition), P3 (conditional atomic sink safety), P4 (stale-check impossibility). The result **does not certify law, cryptography, ballot secrecy, voter eligibility, concurrent production execution, or democratic legitimacy**. No independent human or Lean review is claimed.

The source research note and audit receipt must be updated together when semantics change.

## Lean 4.36.0-rc2 scope and kernel receipt

[Lean source](lean/CommonwealthPassport.lean) and [proof-dependency/limitations ledger](LEAN_SCOPE_20261115.md) provide 15 strict named declarations, including the finite evidence-to-effect composition and least-cost finite sound-panel existence. [Pinned CI run #43777510711](https://github.com/d3lefts/d3lefts/actions/runs/43777510711) passed with only Lean foundational axioms. The theorem source SHA-256 is `4cb479a28e83b69c74127626d50ba4d78a8347d01dbd7495c45b589816658e49`. CI is a formal-kernel proof of the declared abstract implications, **not** a proof of real electoral correctness, truthful legal sources, complete effect mediation, or deployed transaction refinement.
