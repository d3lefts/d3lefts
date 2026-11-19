# DispatchQ-B1 — site-ready project card

**Category:** Software Engineering Evaluations · **Status:** Calibration prototype / independent review pending

**Short description:** A realistic Python/SQLite queue-repair challenge testing whether coding agents can maintain durable state and concurrency guarantees while repairing interacting failures.

**Verified author-side evidence:** 20 weighted contract tests; reference 100/100 in ten repeat runs; eight seeded defect variants detected. Starter scored 52–60/100 under repeated tests because a concurrency check is scheduler-sensitive.

**Unresolved:** blind agent performance, independent reviewer acceptance, agreement on alternate correct solutions, secure evaluation isolation. No Gemini, Claude, or ChatGPT benchmark scores exist.

**CTA:** [Inspect the public challenge](candidate/ISSUE.md)

**Guardrail:** Do not claim endorsement by Google/Polaris or that the task is already a discriminating frontier-model benchmark. Keep reference implementation and hidden scorer out of the site and public repository until holdout strategy is resolved.
