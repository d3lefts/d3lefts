# DispatchQ-B1 — private grader proof attack (public evidence)

**NIGHTFALL Evaluation Lab · 2026-11-18 · internal author-side audit, not a validated benchmark.**

## The falsifying experiment

A correctly solved programming challenge is worthless as a benchmark if its grader awards full credit to incorrect implementations. We attacked the **withheld numerical scorer**, not merely the intentionally defective public starter. Twelve narrowly modified variants of the trusted reference repair were scored against the original 20-test evaluator. Five contract-breaking variants each received **100/100**. The failures spanned numeric/Boolean input validation and fractional retry scheduling. They were independently distinguished from the unchanged correct reference by a second black-box contract-witness program.

The v0.2 private grader adds five separate weighted tests and redistributes 16 existing points, keeping the total at exactly 100; it rejects **12/12 executed source-local fault variants**, while the correct reference scores **100/100 in ten fresh-interpreter runs**. The unchanged starter received **47/100 in ten v0.2 runs**. The v0.1 and v0.2 starter scores must not be compared as if the grading weights were unchanged.

## Methodological correction — preserved, not erased

The original sealed preregistration described twelve mutant *families*. Eleven were executed as planned. The twelfth, `claim_limit_float`, was discarded because SQLite itself rejects the invalid floating-point LIMIT value, so merely removing the Python pre-check could not show a contract failure. A separately marked **post-registered** token-uniqueness mutant replaced it. The original plan is preserved unmodified in the *private* archive; the public receipt records the deviation.

## Evidence custody and replay

- Public, inspectable summary: [`RECEIPT.json`](RECEIPT.json).
- Public integrity checker: [`check_receipt.py`](check_receipt.py), runs in stdlib Python 3.10 and 3.13. It verifies **arithmetic and metadata consistency only**, not the private scorer's authenticity.
- The owner-held private v0.2 archive has SHA-256 `78fd45854d4f650e100cd2042964297ebb332ed357ef1e47d7727d2965d1b33f`. It contains the original/reference sources, revised hidden suite, independent black-box witness, exact mutation replay program, unchanged original preregistration, and per-run receipts. **Do not commit or link publicly to its contents.**
- Original private archive SHA-256: `6be359d6bcd1f09ab21e45ab242c2ce7ab52c8cf8a774bcfe242bf6998b8e8ea`.

## Promotion gate for parallel contributors

1. Independently audit the five contract witnesses against the agent-visible issue and the fixed source snapshots.
2. Replay the sealed v0.2 grader on Python 3.10 and 3.13 in a clean, no-credential environment. No such replay is claimed here.
3. Freeze the grader/score denominator and holdout custody before real-model runs, integrating the shared receipt-gate work from PRs #829/#830.
4. Run at least two blind model-agent attempts under a preregistered budget, including timeouts/tool failures in the denominator. Never expose hidden evaluator/reference to the agent.
5. Only after external human review should the site promote the work beyond **internally calibrated prototype**.

Related: DispatchQ task PR #818, independent public canary #820, state-machine checker #833, ArtifactGraph-B2 #824, and shared run-receipt gate #829.

**Nonclaims:** No real frontier model was measured. No human-independent validation or full benchmark correctness proof. No association with or endorsement by Polaris, Google, DeepMind or SWE-bench.
