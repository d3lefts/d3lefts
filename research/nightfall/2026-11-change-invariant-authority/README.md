# Exact change-invariant authority certificate

Run:

```bash
python3 audit_independent.py
```

Expected deterministic result:

```json
{"cases": 2100, "exact_change_margin": "1/2", "new_unsafe_A": "9/50", "new_unsafe_B": "1/10", "radius_checks": 4394, "same_old_risk": "1/10", "sha256": "662ee6ceebf2dc99e4caf028b527b10d05b092a4c716569087949f43f7292088", "status": "PASS"}
```

Proof, scope and prior art: `THEOREM.md`.

No sensor attestation or deployment authority is supplied by this mathematical checker. The model-dependent masses, separator and change class must be authenticated and externally validated.

The representation-identifiability theorem has a separate exact coefficient checker:

```bash
python3 representation_audit.py
```

Its deterministic receipt is `representation_receipt.json`.
