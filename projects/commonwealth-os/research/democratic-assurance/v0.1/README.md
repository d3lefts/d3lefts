# COMMONWEALTH 2030 — executable reference specification v0.1

A narrow, source-traceable research scaffold for *The Constitution of Computational Commonwealths: A Blueprint for Human-Sovereign Governance in the Age of Synthetic Autonomy*.

## Run with Python 3 standard library

```bash
python3 independent_audit.py
python3 finite_costs.py
python3 independent_cost_audit.py
```

`independent_audit.py` checks a finite closed-world authorization implementation against a separately written failure-based oracle, with adversarial negative controls. `finite_costs.py` enumerates synthetic cost portfolios, and `independent_cost_audit.py` verifies the answer via a different dynamic-programming algorithm. Cost units and scores are **invented demonstration values**. Nothing here measures America or establishes that a particular local law is valid.

## Formal invariant under the toy model

Every effect committed through `GuardedSink` has a matching ordinance digest, version, source epoch, law epoch, jurisdiction, action scope, legally reviewed and human-adopted authority flags, budget bounds, and no stay/revocation. Proof: inspect `commit`: it appends an effect iff `guard` is true. For any arbitrary sequence of calls, induction on sequence length preserves the statement for newly appended effects. It assumes all real effects go through this sink and that stored truth flags are accurate; those premises are not proved by the program.

## Status

- Scoped finite-state software checks: **passed 2026-11-15**, see JSON receipts.
- Conditional logical invariant: **argument supplied**, independent formal-methods review not performed.
- Economic cost-optimal toy: **exact finite result**, not an empirical cost estimate.
- Constitutional, informed-agency, equality, physical security, national 2030 feasibility: **unverified**.
- Global novelty: **not established**.

See `ARCHITECTURE.md` and `RESEARCH_CONTRACT.md` for scope and next tests.
