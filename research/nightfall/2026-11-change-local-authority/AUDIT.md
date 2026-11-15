# Reproducibility and audit gate

Run with CPython 3.11+ standard library only:

```
python3 audit_independent.py
python3 run_experiments.py
sha256sum mincost.py audit_independent.py run_experiments.py THEORY.md experiment_receipt.json
```

Expected first command output, frozen November 15, 2026:

```
{
  "cases": 3000,
  "finite_world_assignments_checked": 296401,
  "sha256": "db65a6856e595baa84149fc94205a70d9b92f7b1ac3631ca975eca3fa2aa9f82",
  "status": "PASS"
}
```

Independent checker uses distinct brute strategy enumeration for every test instance, verifies max-flow feasibility / conservation / min-cut equality on every returned certificate, checks posterior-risk feasibility via uncovered count, and for small cases enumerates full latent worlds, verifies zero false denials, and adversarially changes unread incidence values. Uses seeded random *input generation only*; all mathematical calculations are exact `fractions.Fraction`.

Certification levels: exact finite replay and analytic proof; **not** a Lean kernel certificate, human review, or novel global theorem. Never promote beyond the specified generative model and pinned probability law. Credit prior work and disclose assumption that cached evidence is genuinely current.
