# NIGHTFALL / Frozen blind-run evidence gate (v0.2)

**Purpose:** keep all coding-agent evaluation attempts, including tool failures and timeouts, in the denominator while preserving a frozen task/source, model, budget and hidden-grader identity. This is a **portable internal receipt consistency checker** and an adversarial test suite, **not** an agent executor, reference solution, grader, sandbox, independent human review, benchmark validator or cryptographically authenticated attestation.

## Objective and supporting work

NIGHTFALL currently has two draft, orthogonal tasks: [DispatchQ-B1 (#818)](https://github.com/d3lefts/d3lefts/pull/818), for durable multi-process queue correctness, and [ArtifactGraph-B2 (#824)](https://github.com/d3lefts/d3lefts/pull/824), for incremental DAG build and cache/source integrity. Each has an internal author-side calibrated hidden grader, plus separate public contract canaries in [#820](https://github.com/d3lefts/d3lefts/pull/820) and [#825](https://github.com/d3lefts/d3lefts/pull/825)/[#827](https://github.com/d3lefts/d3lefts/pull/827). **There are no accepted blind model results.**

The independent finding in #827 that Boolean JSON versions passed two author-reference checks is a direct reason to reject self-certified grader completeness. An equally important systems risk is that a failed model-tool protocol or dropped attempt can be accidentally counted as a valid benchmark success rate.

**Research hypothesis:** a frozen-plan, byte-hash-pinned, fail-closed structural gate can catch common score inflation and attempt-selection artifacts *before* a team publishes model comparisons. **Prediction:** one honest synthetic two-episode report (completed + tool failure) is structurally admissible; each deliberately malformed or tampered variant is rejected. This is an internal *process* improvement, not a mathematical or empirical model-capability result.

## Contract

A reproducible run directory contains:

```text
run/
  plan.json
  attempts/
    try-1/
      receipt.json
      trace.json
      patch.diff
      grade.json
    try-2/
      receipt.json
      trace.json
```

The run directory contains **only** the listed plan and attempts; each attempt contains exactly its allowed receipt, trace and (only for completed attempts) patch and grade files. The exact `plan.json` bytes must be SHA-256 pinned **outside the run directory before execution**. It freezes task Git commit and candidate-tree SHA-256, prompt SHA-256, private grader SHA-256, runner image digest, version-qualified model name, positive budgets, **immutable score denominators** (`grading.tests_total` and `grading.max_points`), distinct attempt IDs and declared holdout/isolation policy. It records the *intended* isolation, which must be independently verified by an actual OS/container runner. Do not put hidden grader tests/reference in the public run directory.

Each receipt references a hashed per-attempt **tool-event metadata trace** (call/result types and tool names, not raw arguments and outputs). A full runner must retain its complete raw transcript separately with independently controlled custody and a digest attached to the runner's authoritative record; this utility cannot certify it. An episode labeled `completed` must have at least one logged tool call and a nonempty hashed patch, plus a hashed grader receipt matching the frozen grader identity and **both separately pinned grading denominators** (number of tests and maximum points). Non-completed episodes—including zero-tool-call failures—must remain in the planned denominator **without a fabricated graded result**. The gate rejects score/test denominator drift, undeclared/missing attempt directories, duplicate JSON keys, nonfinite JSON tokens, stale plan hashes, mismatched source and grader IDs, over-budget claims, unsafe file paths and symlinks, cross-attempt artifact reuse, undeclared private grader files, tampered traces, invalid scores and silent omitted attempts. The checker never constructs a success rate from absent data.

The result is always labeled `structurally_consistent_unattested_internal_records`. The output field `author_reported_grader_scores_not_verified` explicitly prevents a successful schema/hashing check from being mislabeled a verified model benchmark.

### Plan format v2: frozen grading denominator

The plan is now schema `nightfall.eval.plan.v2` and must include exactly:

```json
"grading": {"tests_total": 20, "max_points": 100}
```

These values are **illustrative**; select the actual task grader's test count and score ceiling during preregistration, before *any* model attempt or graded patch. They must be positive exact JSON integers (booleans forbidden). Each completed attempt's `grade.tests_total` and `grade.max_points` must agree with the externally pinned plan; otherwise reject **the entire run packet**. V1 plans are intentionally rejected: v1 anchored the attempt set, source, model and grader digest but not the score denominator. No accepted real model runs require migration. The structural gate still cannot certify whether those points were deserved, whether the grader actually executed, or whether a forged complete transcript was created by a malicious operator.

### Independent v1 counterexample and repair

A separate review first added two **positive witnesses of a flaw** without changing v1 enforcement, then ran [source-exact CI 44374307614](https://github.com/d3lefts/d3lefts/actions/runs/44374307614) on Python 3.10 and 3.13 (**39 synthetic tests green**).

1. Under one frozen plan and grader SHA-256, an attacker reported a completed 50/100-point score and a second completed 7/7-point score with `tests_total` 2 versus 3. V1 accepted both as structurally consistent even though the scores have incomparable scales.
2. With no plan update, the attacker rewrote the only completed grade to 1/1 instead of 50/100, rehashed grade/receipt, and V1 accepted the report.

These witnesses establish the precise v1 parser weakness but say **nothing** about real agent/model scores. V2 includes the grader's `max_points` and `tests_total` in the externally frozen plan; both witnesses are now negative regression tests. Positive tests include two completed attempts at the same frozen scoring scale. No other reader should infer a new scored model run or independent human certification.

## Inspectable checker

```sh
python -m unittest discover -s research/nightfall/evaluations/assurance/tests -v

# For a real run, independently preregister the exact plan SHA-256 first.
python research/nightfall/evaluations/assurance/frozen_run_gate.py \
  /path/to/trusted/run --expected-plan-sha256 <64-character-hex>
```

The tests construct an ephemeral **synthetic** frozen plan, one completed episode with a fake external scorer receipt, one zero-tool-call failure, and independently mutate plan/trace/patch/grade/identity/denominator controls. There is **no actual coding agent, model inference, isolated grader, or hidden reference** in the test suite. The test verifies the validator's handling of evidence format and consistency only.

### External trust boundary

A malicious operator controlling the entire run and the external plan anchor can still manufacture a perfect receipt. SHA-256 protects only changes relative to a separately trusted recorded value. This tool does **not** attest the executor, the sandbox, the true model identity, the time budget, whether a grader was in fact held out, or grader correctness. Use OS-level isolation, approved runner attestation and independent human review as separate gates. Never infer trusted execution merely because `holdout.network_disabled=true` appears in a JSON claim.

The next decisive experiment is genuine clean-checkout, isolated, fixed-budget coding-agent runs on both tasks, with immutable external plan commitment, raw tool traces and separately executed locked holdout grader. A task is not promoted to `blind-model-measured` without real executable attempts and validation of the evaluation harness itself.

## Independent criticism and reuse

This implementation deliberately remains in `research/nightfall/evaluations/assurance/` and does not edit or merge either benchmark author's source, grader, private references, or candidate branches. A separate reviewer should attack assumptions on the evidence schema and the sandbox/credential boundary. Failures must be preserved with input SHA and a correction record; do not label these synthetic attack tests independent human peer review. This tool can transfer to any NIGHTFALL SWE task without claiming portability to environments with richer interaction schemas until their event format is explicitly validated.


## v0.3 trusted-host *grader execution* gate (separate from model execution)

**New experimental component:** \`trusted_container_grade.py\`. It closes one narrow,
real defect in the preceding evidence chain: the v2 receipt verifier could only
confirm that an author *reported* a grader identity and score, not that a real
scorer process executed against the submitted code. The new host-side component
constructs a patched workspace and executes a pinned single-file private Python
grader using Docker. Successful grades are derived **only from the executed
process output**, with failure or score-dimension drift denying publication.
The output remains **local, unauthenticated evidence**, not an independent blind
agent benchmark score or a solution to untrusted host compromise.

### Execution/custody protocol

1. Prepare a seed tree containing **only** the agent-visible starter code, a
   submitted UTF-8 Git patch, and an independent grader Python file **outside
   the agent-visible starter**. Never publish any private grader/reference.
2. Before the run, externally commit the exact v2 \`plan.json\` bytes and its
   SHA-256, the source tree hash (defined below), the grader file SHA-256,
   permitted attempt IDs, grader denominators, and Docker **image ID** in the
   plan's \`runner_image_digest\`. The image must already be present locally;
   the scoring tool does not silently fetch a newer tag.
3. The trusted host verifies the plan, source, grader, submitted attempt,
   image ID and patch paths. It copies the seed to a new temporary workspace
   and applies the patch with \`git apply --check\` and \`git apply\`. It
   re-hashes the resulting tree. No \`.git\` directory or symlinks are allowed.
4. **Only after the agent has finished** does the host run the scorer in Docker
   with \`--network none\`, read-only container rootfs, all Linux capabilities
   dropped, no-new-privileges, explicit UID/GID, CPU/memory/pid limits and a
   wall-clock deadline. The ephemeral patched worktree is writable only within
   the controlled scoring phase; the private grader file is mounted read-only
   at \`/opt/grader/score.py\`. The host captures bounded stdout and accepts
   only a single JSON score object. No grade is written for a timeout, failed
   grader, output overflow, schema drift or denominator mismatch.
5. On a successful run, an external output directory receives \`grade.json\`
   compatible with the v2 frozen receipt gate and \`capture.json\` with task,
   image, plan, grader, patch, seed-tree, patched-tree and grade hashes. Keep
   both under trusted custody, then assemble a full run packet using the *real
   model's* independently captured attempt trace. The capture tool itself
   **never invokes a model or creates a fictional agent attempt**.

**Canonical seed-tree SHA-256:** recursively visit regular files in sorted
POSIX-relative-path order (nonempty tree, no symlinks, no \`.git\` component).
For each file append
\`UTF8(relative_path) || 0x00 || ASCII(executable_bit_0_or_1) || 0x00 || ASCII(hex(file_SHA256)) || 0x0a\`
to the SHA-256 stream. Source byte hashes are not Git tree hashes; this
separate convention is pinned for this runner's v0.3 protocol.

**Private grader process contract:** a single Python file named by
\`--private-grader\` receives \`/work\` as its sole argument and emits exactly:
\`{"tests_passed":int,"tests_total":int,"score_points":int,"max_points":int}\`
to stdout with a zero process exit. Booleans, duplicate keys, nonfinite values,
self-adjusted maxima, partial logs and errors fail closed. An agent-controlled
module can execute *during* grading, but the agent cannot interact with the
grader while the held-out scoring phase occurs.

**Run (trusted host only, after externally freezing the plan):**

\`\`\`sh
python3 research/nightfall/evaluations/assurance/trusted_container_grade.py \
  --plan /trusted/plan.json \
  --externally-pinned-plan-sha256 "$PINNED_PLAN_SHA256" \
  --attempt-id try-1 \
  --seed /trusted/agent-visible-seed \
  --patch /trusted/submitted-attempt.patch \
  --private-grader /trusted/locked/score.py \
  --output /trusted/out/try-1
\`\`\`

The scorer executes untrusted candidate code and **must run on a disposable,
appropriately hardened Docker host without credentials or access to production
secrets**; Docker hardening is risk reduction, not a formal sandbox guarantee.
The temporary grader process could inspect hidden grader source and try to
write it to its disposable workspace; therefore never hand the post-grading
workspace or raw logs back to an agent, and do not claim that the grader is
secret from adversarial code *during* scoring. The returned score's
correctness is only as strong as the private grader and source contract.

### Independent synthetic proof attacks (no actual model performance)

\`tests/test_trusted_container_grade.py\` validates source-tree identity,
patch-path confinement, grader output schema and frozen score dimensions, then
runs **genuine Docker** scoring on a tiny synthetic \`ANSWER=0\` task changed by
a submitted Git patch to \`ANSWER=1\`. It also tests source/grader tampering,
grade denominator drift, failure-without-grade and denial of outbound network.
The CI matrix runs Python 3.10 and 3.13, capturing exact source hashes and
the Docker image ID actually executed. The demonstration's model ID deliberately
contains \`synthetic-nonmodel\`; it is not a blind-agent run, model benchmark
score, hidden-grader validation, or externally signed attestation.

### Remaining promotion gate

Before publishing any DispatchQ-B1 or ArtifactGraph-B2 agent score:
independently challenge the **actual** private grader, freeze real attempts
and score denominators, run a true isolated coding agent with complete raw tool
transcripts and verifiable task source, inspect runner/container trust
boundaries, score the untouched submitted patch with this or a stronger
executor, and have a separate reviewer verify the receipts. Otherwise the
portfolio must still report **zero accepted blind-agent evaluations**.
