# Gate B / Sidon finite theorem — two-path exact replay

**Verification completed:** 2026-10-28; GitHub Actions [#193](https://github.com/d3lefts/d3lefts/actions/runs/40782321424), commit `10d0ba2181cc5f7466158ce298e43f36a42bb101` of the Observatory review branch.

## Exact independently checkable result

The explicitly published 30-integer weak Sidon (4,5) set has maximum Sidon subset cardinality exactly 17. This is a finite-instance theorem, with no asserted global extremal priority and no new asymptotic bound.

Two separately implemented exact proof paths:

1. The standalone search verifier `verify_sidon30_standalone.py`, with full exact four-subset enumeration and recursive 12-deletion AP hitting-set impossibility check.
2. The source generator `generate_proof_dag.py` reconstructing the complete 7,801-state proof DAG, and the **separate** `scripts/verify_sidon_dag_independent.py`, which verifies every branch, complete three-way coverage, disjoint packing leaf, reachable node, exact 17-element lower witness and all 27,405 four-element tests. The checker rejects a deliberately corrupted root.

The second checker verifies a supplied proof; it does not trust the generator's branch choices. Both paths use Python standard-library integer arithmetic.

## Frozen data and reproducing commands

- Original 30 integers: `research/nightfall/projects/sidon-finite-30/witness_30.txt`, SHA-256 `dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f`.
- Generated DAG: `sidon_no_18_proof.json`, SHA-256 `4e31c53667cba63db34354eb861f503ac7284a0e76cd7219306dff8239032181`.
- Actions evidence bundle: [nightfall-sidon-gate-b-proof](https://github.com/d3lefts/d3lefts/actions/runs/40782321424/artifacts/12857956395), contains witness + DAG + machine-readable independent receipt (90-day Actions retention).

```bash
python3 research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py
python3 research/nightfall/projects/sidon-finite-30/generate_proof_dag.py
python3 scripts/verify_sidon_dag_independent.py
sha256sum research/nightfall/projects/sidon-finite-30/sidon_no_18_proof.json
```

The log reports full proof graph of 7,801 states and independent proof rejection control PASS. No external human referee audit or worldwide originality verdict is inferred. Long-term publication of the archive file and frozen original ZIP remains pending.

**Gate classification:** Gate B machine reproduction **passed**. Gate C experimental research transfer **pending**. Gate D public Observatory release **blocked**.
