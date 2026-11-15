# NIGHTFALL v0.2 — Optimal recertification with correlated/noisy evidence and authenticated reuse

**Research status:** complete finite rational mathematical constructions and exact independent checks. The generic optimizers are classical Bellman and constrained-occupancy LP procedures, not claimed novel. Source model calibration, complete change-impact discovery, real issuer trust, and physical-system safety remain unverified. No Lean kernel certificate or human referee review.

## Run

```bash
python3 make_receipt.py
python3 run_all.py
```

Requirements: Python ≥3.10, `cryptography` for Ed25519. SciPy is optional for the independent numeric LP consistency check, while all primary optimality checks use `fractions.Fraction` and exact algebra.

Scripts:

- `recert.py` — arbitrary finite dependent, noisy **static** complete-world model, exact pathwise-posterior Bellman optimizer.
- `make_receipt.py` / `bellman_receipt.json` — source-exact full 549-state Bellman value/action witness.
- `check_receipt.py` — independently reconstructs all histories, posterior masses, action values, and terminal decisions from the source; no imports from `recert.py`.
- `audit_independent.py` — independent brute enumeration of all possible contingent policies on 54 exact small cases.
- `global_risk_lp.py` — exact two-sided **global error rate** occupancy LP, feasible policy and elementary matching dual, plus 50 deterministic policy cost/error triples.
- `cache_attestation.py` — actual Ed25519 provenance, exact separator message and eight rejection tests; demo key generated transiently, not production security.
- `test_negative.py` — adversarial counterexamples and intentionally forged proof receipts.
- `measure_policy.py` — exact world-by-world replay of the selected six-test policy; distinguishes conditional posterior from population error rates.
- `THEORY.md` — full statements, proofs, assumptions, global prior art, limitations and proof ledger.
- `AUDIT.md` / `CLAIM_STATUS.json` — versioned certification status and expected exact results.

## Main claims and boundaries

**Exact solved class:** finite, calibrated, rational complete-world law with arbitrary dependence among observations, static hidden mission truth, bounded noninvasive test set, finite additive costs, and authenticated current evidence. Both a per-terminal risk constrained DP and a separate globally constrained randomized policy LP are available.

**Reusable evidence theorem:** a cryptographically authenticated *conditional separator message* can be reused after changes outside its factor/channel/scope dependencies. An old unconditional posterior generally cannot be reused. Ed25519 validity does not imply channel calibration, freshness, trusted change impact, or the truth of the mission predicate.

**Not established:** globally original theorem, efficient exact computation in arbitrary large POMDPs, trusted real system integration, formally verified crypto implementation or Lean proof, independent human peer review.

Research direction NIGHTFALL. Earlier modular-noiseless case: [PR #583](https://github.com/d3lefts/d3lefts/pull/583). The file hash ledger is retained to make accidental substitutions detectable. Credit existing POMDP, junction-tree, incremental assurance, and attestation literature as specified in `THEORY.md`.