# The Price of Permission — NIGHTFALL first decisive experiment

This bundle contains an exact closed-form permission-capacity bound, a matching feasible schedule, an independent exhaustive optimizer, an exact two-sided calibrated monitor-routing information floor, and a prior-art/scope ledger.

Run:

```
python3 audit_independent.py
python3 monitor_mixing.py
```

Both programs use only Python's standard library and integer/rational arithmetic. Theorem statements and assumptions are in `THEOREM.md`. The model is **synthetic** and does not claim a real-world agent deployment or Lean certificate. Related flagship issue: https://github.com/d3lefts/d3lefts/issues/589.

## v0.3 — inheritance of NIGHTFALL's strongest scoped theorems

Read [THEOREM_INTEGRATION_v0_3.md](THEOREM_INTEGRATION_v0_3.md) before extending the capacity experiment. It integrates the original-source Q2 theorem (Lean PR #564), one-coordinate source-law recentering/SCIF (Lean PR #529), exact semantic-fence soundness (Lean PR #554), mission quotients, pure information complementarity (PR #469), posterior-actionable influence, dependency-aware evidence reuse, nominal-path optimal recertification (PR #576), two-clock freshness, and the present batch-capacity bound. Each result retains its own assumptions, status, limitations and previous authorship/priority.

A new explicit finite bridge shows that a coordinate can have positive Efron–Stein influence while an exact individual read carries zero mutual information about the safety decision. The source-law replacement test further separates probabilistic support from physically admissible adversarial effects. For the modular mission with mandatory version guard, the zero-error fresh-evidence cost is `c_G + min(c_T + c_A, c_D)`; the exact checker is [permission_bridge_exact.py](permission_bridge_exact.py).

Reproduce all three checks:

```sh
python3 audit_independent.py
python3 monitor_mixing.py
python3 permission_bridge_exact.py
```

The scoped Lean results are verified mathematics, **not** evidence that the integrated Price of Permission theorem is Lean-certified, worldwide original, or physically deployed. The complete v0.3 manuscript is a separate rendered DOCX/PDF research artifact; the source-of-truth integration section and checker are in this branch.
