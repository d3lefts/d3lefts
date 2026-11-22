# NIGHTFALL agent interface A/B — verified results (2026-11-22)

**Status:** reproducible process measurement, **NOT** mathematical certification,
a measured reduction in actual researcher mistakes, or causal evidence that real
independent agents discover mathematics faster.

**Frozen experiment:** [preregistration](AGENT_CONTRACT_AB_PREREG_20261122.md)
and benchmark [source](benchmark_agent_contract.py). Exact-head GitHub Actions
[run 45057382539](https://github.com/d3lefts/d3lefts/actions/runs/45057382539)
succeeded: three separate role-labeled jobs, one aggregate job. CI checkout
Git commit in the measurement artifact: `494f16214d30915f07abbec42cf91e00642a962c`
(GitHub pull-request synthesized checkout SHA; examine the pull request and
source file blobs before rerunning outside that checkout).

## Process timing (warm shell invocation, no install or human time)

| Invocation | Median milliseconds across 9 task-by-role medians | Median ratio to direct same-role checker |
| --- | ---: | ---: |
| Direct authoritative Python | 41.604 | 1.0000× |
| Python dispatcher | 90.170 | 2.2053× |
| just recipe → Python dispatcher | 92.653 | 2.2633× |
| Nushell task-run → Python dispatcher | 100.728 | 2.4452× |

Each CI role ran three real existing verifier programs with 8 repetitions in
4 orders: 3×8×4 = **96 runs per role**, **288 warm runs total**.
The outputs of each underlying checker matched byte-for-byte by SHA-256.
The randomized mode order varied by task/role/repetition.
The preregistered 20%-faster benchmark gate failed for **all** new modes.

These are hosted-runner process latencies for short Python metadata checks.
No deployment setup, agent reasoning, model token usage, task discovery time,
or actual multi-agent merge conflict rate was measured. The result is
evidence **against raw shell/runtime savings**, not evidence that the command
contract has negative scientific value.

## Error-injection results

There were 42 receipt-validation mutation tests: 3 role-labeled runners ×
7 variants × Python/Nu frontends, with results:

| Mutation | Acceptance count | Interpretation |
| --- | ---: | --- |
| Forged `mathematical_theorem=true` | 0/6 | Correct rejection |
| Contradictory PASS/FAIL metadata | 0/6 | Correct rejection |
| Malformed Git commit SHA | 0/6 | Correct rejection |
| Invalid reviewer role label | 0/6 | Correct rejection |
| Different but valid-looking Git commit SHA | 6/6 | **Accepted structurally** |
| Different but valid-looking source-anchor SHA-256 | 6/6 | **Accepted structurally** |
| Different but valid-looking stdout SHA-256 | 6/6 | **Accepted structurally** |

Result: 24/24 required malformed metadata rejects; 18/18 syntactically
well-formed but false hash/commit substitutions accepted. This second group
is a **known trust-boundary hole in relying on structural-only validation as
if it authenticated provenance**, not a demonstrated unsound Lean proof or a
proven increase in real-world agent error rate. The existing `verify`
command explicitly checks structure, not true SHA-to-file binding or replay.

A *direct legacy checker* has no comparable receipt schema, so it is
methodologically invalid to claim `24` fewer mistakes than baseline.
The tested setup doesn't measure real mathematical proof mistakes.

## Exact replay artifacts (90-day CI retention)

- [Aggregate summary JSON](https://github.com/d3lefts/d3lefts/actions/runs/45057382539/artifacts/14768405768):
  ZIP digest `sha256:ad9e77800d38776fc31eb1684e242250c63944139de69b54e266375963b264b0`
- [Constructor raw JSON](https://github.com/d3lefts/d3lefts/actions/runs/45057382539/artifacts/14766939785):
  ZIP digest `sha256:b6513a649371a65a0ce42b4a3d07009b0edb702c76ef20d1103528d87076e3ff`
- [Independent-reproducer *role label* raw JSON](https://github.com/d3lefts/d3lefts/actions/runs/45057382539/artifacts/14766934893):
  ZIP digest `sha256:6b5be26ba2e699f038c4a34f0c1ec924c6b9a1db5d57f2992b7ba857ce9be543`
- [Auditor *role label* raw JSON](https://github.com/d3lefts/d3lefts/actions/runs/45057382539/artifacts/14766839926):
  ZIP digest `sha256:ca5387040bdf748fd822583722ef83039aa54bf146cea57337d9e6b9187f1969`

The above are three independently scheduled **CI runner jobs executing
the same frozen benchmark script**, not independent AI or human reviews.
Their files are archived separately to prevent a false independence claim.

## Two failed dry runs, preserved

- [Run 45057145126](https://github.com/d3lefts/d3lefts/actions/runs/45057145126):
  an incorrect `just --quiet` invocation suppressed output.
- [Run 45057241972](https://github.com/d3lefts/d3lefts/actions/runs/45057241972):
  a benchmark-only diagnostic f-string contained a literal escaped apostrophe.
- Amendments A1/A2 in preregistration document disclose both failures.
  Neither failed run produced an analyzable comparison artifact.
  The final run retains the same task/role/repetition plan.

## Decision and transfer

**Do not migrate existing scientific checkers to Nushell for raw speed.**
Keep `just` as a discoverable and consistent task catalogue, Python as the
authoritative dispatcher, and Nu as an optional structured-data view.
The measured overhead is dominated by additional process launches and
source metadata collection. If optimizing performance, batch only after
validating unchanged proof/receipt scope; prefer caching verified source
metadata within a single bounded task invocation.

**Next security improvement:** add an *explicit opt-in* `replay` verification
gate that validates current checkout Git HEAD and source-anchor bytes and
reexecutes the allowlisted checker to compare output hashes. Preserve the
separate structural-only `verify` for offline inspection; do not call it
provenance certification. Independently test all seven mutations again.
Even a successful replay check is not an independent mathematical audit
because it uses the same verifier source.

**Next genuine parallel-agent experiment:** randomized or matched-pair
theorem-review jobs with different actual agents, task discovery elapsed
time, malformed-receipt rates, wrongly promoted hypotheses, source-mismatch
detection, and a blinded expert adjudicator. Comments requesting scoped
real-instance adoption were posted to parallel #1047/#1058/#1059;
no response is counted as completed evidence without actual receipts.
