# NIGHTFALL v0.2 — audit ledger

Date UTC: 2026-11-15. Exact source: `THEORY.md`, executable source as SHA256SUMS.

## Decisive falsification tests (all exact)

| Counterexample/control | Checked claim | Result |
|---|---|---|
| Correlated sensors share common noise bit | independence-assumed likelihood is invalid | actual joint error 1/4 vs false 1/16 |
| Cached Z and new Y share unmodeled noise | missing separator is unsound | true safety 1 vs false 5/8 |
| Prior on boundary B changes | old posterior stays valid | false: old U=1 probability 3/4, current 15/22 |
| Old posterior risk at tolerance 3/10 | unsafe authorization allowed by outdated belief | old risk 1/4, current 7/22 |
| Forged 549-state receipt: lowered root V | certificate checker rejects | PASS |
| Forged 549-state receipt: altered posterior | checker rejects | PASS |
| Forged receipt: unauthorized terminal action | checker rejects | PASS |
| Forged receipt: deleted dependency | checker rejects | PASS |
| Forged receipt: changed noise parameter | checker rejects | PASS |
| Signed cache tampering | rejects altered evidence bytes | PASS |
| Signature verifies but outdated factor/channel/epoch/mission/revocation/impact | rejects reuse | PASS |
| Finite complete-world posterior wrong denial vs global denial | distinguish guarantees | cache Z=0 global false denial 3/16 > 1/10 pathwise threshold |

## Certificates / exact results

- `make_receipt.py` creates a portable 549-history exact rational Bellman value/policy table. SHA256 of canonical `bellman_receipt.json` is `1299871f6d5eae420736e127e569994e319f2647218b57540c05306ab96b1045`.
- `check_receipt.py` reconstructs the joint law and checks all 549 posterior risks, Bellman action comparisons, selected equalities and complete-world policy replay: cost = 145/22, P(unsafe and authorize)=0, P(safe and deny)=3/88 (all probabilities conditioned on cache Z=1).
- `audit_independent.py` compares the solver against exhaustive enumerations of all contingent policy trees on **54** rational cases; ordered receipt digest `d5cfdaf9a499badbf3d57255304ac14c43131b5505f0d48dd394784e2e8e95c8`.
- Exact changing-cache current/old posterior `15/22` / `3/4`; Ed25519 plus source/clock/mission/revocation checks reject 8 adversarial cases.
- `global_risk_lp.py` constructs and checks a rational LP solution of cost exactly 3, both global class-conditional error rates 1/8, dual Lagrangian lower bound 3, and exhaustive deterministic search of 50 distinct (cost, error, error) triples showing deterministic cost≥5. Independent SciPy LP agrees, but numerical output is not part of proof authority.
- Bounded hidden-state and test histories: 32 complete worlds; 6 tests; 549 positive-mass histories in the full cert. Test errors correlated; there is no false conditional-independence claim.

## Limitations and repair plan

These are exact mathematical tests for one finite model. An actual authenticated issuer, sensor calibration, complete change-impact monitor, model fit to a plant, semantic mission assurance, and ongoing dynamics remain external obligations. Lean4 strict kernel certification is not obtained. No globally original algorithm is asserted. Recover the next checkpoint using the immutable proof and source manifest; do not promote to real deployment, practical zero-risk safety, or universal minimal recertification.