# NIGHTFALL B1/B2 real local coding-agent pilot — calibration, not a blind score

**Scope (18 Nov 2026):** actual inference from a pinned-by-digest *observed* local
Qwen2.5-Coder-3B model, mediating real file-read/write/public-test actions. The
two task seeds are source-SHA frozen, and **only agent-visible candidate/ material**
is provided to the local model. No private grader, author reference, or
independent audit source is visible in the model workspace. All source execution
is confined to Docker under no-network/no-credential/limited-resource flags.

**This is exploratory calibration**. Initial artifact image/model digests are
recorded **after downloading**, not independently frozen before the first
calibration run. One attempt per task is not a benchmark; a public 3/3 smoke
result is not a hidden-grader score and cannot establish correctness or
difficulty. A failure to elicit usable code or a successful tool call must
remain in the denominator; zero-tool attempts are failures, not valid agent
completions. Raw model and tool transcripts must be audited before any
external generalization. Native coding-agent harness differences and small-model
limitations must be disclosed.

## Fixed source and evaluation scope

| Task | Exact intended original seed head | Scope |
|---|---|---|
| DispatchQ-B1 | \`c11881717d354462d49205ad86eecbdde719c47e\` | SQLite lease/claim/fencing concurrency |
| ArtifactGraph-B2 | \`d5158a3aa37fa0f0ac877406ec806389cc04b5b6\` | dependency DAG, source/sha validation, cache atomicity |

The model is called via the real local Ollama \`/api/chat\` endpoint with
\`format=json\`, fixed generator options and full model prompt/event trace.
Allowed mediator tools: \`list_files\`, \`read_file\`, \`write_file\`,
\`run_smoke\`, \`finish\`. Only already-existing package implementation
\`.py\` files may be overwritten. No arbitrary host shell, hidden scorer,
network from executed candidate, test/ISSUE modification or unbounded runtime.
The model may produce invalid JSON or edit no code; those outcomes are logged,
never scored as a successful blind run.

**Evidence:** \`PUBLIC_CALIBRATION_RECEIPT.json\` records source, issue, model,
container, and emitted patch/transcript SHA-256, tool call count, edit count,
public smoke exit, and strict \`blind_agent_score:null\`. The submitted patch
and full raw inference/tool trace are saved by the trial process itself but
must **not be assumed confidential** merely because their filenames say
\`PRIVATE\`: this is a public GitHub repository. Do not publish a potentially
correct model patch or private model transcript to unprotected public Actions
artifacts. Public receipts and manifest hashes can be shown without revealing
the code. Source-exact independent replay of the model transcript requires
separately authorized private, access-controlled artifact custody; absent
that, no external replay or accepted blind score may be asserted.

**Current scorer:** public smoke only; no private grader is run. The grader
execution/capture infrastructure is maintained separately in #841; it must
receive a real model patch and externally precommitted plan before full
benchmark admission. Candidate prompt, model options, task SHA, complete raw
events, full patch, actual grader execution, fixed denominator and independent
review are all mandatory before promotion.

## Reproduce the mediator contract without model inference

\`\`\`sh
python3 -I research/nightfall/evaluations/assurance/real_agent_pilot/test_local_model_swe_pilot.py
\`\`\`

The GitHub workflow attempts the **real local model** and records its actual
model and image digests, source SHA, tool calls and acceptance ceiling, but
must not promote an attempted run into a scored benchmark without separate
source-custody and grading gates.

## Hypotheses and failure signals

- Expected: a small local code model will be able to invoke at least one
  genuine mediator tool and may produce a candidate source edit.
- Alternatives: invalid model JSON, zero tool calls, attempted forbidden
  edits, exhausted budget, public smoke failure. Each is a real failed/partial
  attempt and remains reportable.
- Positive controls: synthetic scripted mock-model tools prove path
  confinement and input-output wiring. These controls are **not agent results**.
- Adversarial controls: path traversal, disallowed test modification, symlink
  import, oversize content and shell-tool injection are denied by the mediator.
- Next: independent public contract audit against the *real* model patch,
  then real held-out execution in a trusted scoring container with a separate
  frozen run plan and verified execution join. Do not call any of these steps
  already accomplished merely because the workflow code exists.
