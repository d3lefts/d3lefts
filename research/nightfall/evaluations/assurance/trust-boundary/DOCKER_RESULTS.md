# Separate-origin Docker proof-attack receipt — 2026-11-18

**Evidence tier:** real Docker execution of a preregistered *synthetic toy* test; **not** a validated SWE/model score.

## Exact run and source
- [Completed two-Python workflow](https://github.com/d3lefts/d3lefts/actions/runs/44403908246), source commit `28c2edcc004dc158ce0cf102ebbee750ea92cf27`.
- Host Python 3.10.22 / 3.13.18. Both jobs completed successfully.
- Both jobs recorded container image `python:3.13-slim`, image ID `sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90`.
- Artifacts: [3.10](https://github.com/d3lefts/d3lefts/actions/runs/44403908246/artifacts/14473777455) and [3.13](https://github.com/d3lefts/d3lefts/actions/runs/44403908246/artifacts/14474737354), with per-fixture source hashes and structured result receipts.
- Preregistration: [`DOCKER_PREREG.md`](DOCKER_PREREG.md). Implementation: [`docker_boundary.py`](docker_boundary.py).

## Observations, identical on both host Python versions

| Synthetic candidate | Expected status / score | Observed status / score |
|---|---|---|
| Correct fixture | completed / 100 | completed / 100 |
| Incorrect fixture | completed / 0 | completed / 0 |
| Writes forged score JSON directly to stdout | blocked_protocol / null | blocked_protocol / null |
| Returns correct only if private scorer path is visible | completed / 0 | completed / 0 |

The candidate runs in a separate Docker container with no scorer file mount; the host interprets a narrow result envelope and assigns scores. This specifically reverses the two scorer-origin failure mechanisms from [#843](https://github.com/d3lefts/d3lefts/pull/843), where same-process candidate code controlled authoritative stdout/exit and could inspect the mounted scorer.

## Certification boundary

A controlled toy passing these tests **does not** imply secure isolation for arbitrary code or protection against every protocol, container, kernel, cache, timing or side-channel attack. The Docker image identity was recorded at run time, not pinned before initial pull. This does not test the complete B1/B2 contract suite, independent alternate repair, or real Qwen-generated patch against the private grader. **No accepted blind model score.** Preserve the [#846 stop-ship policy](https://github.com/d3lefts/d3lefts/pull/846) until a genuinely isolated candidate runtime is integrated with both private scorers and independently reviewed.
