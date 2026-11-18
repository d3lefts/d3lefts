# NIGHTFALL / Second independent local-model SWE calibration

2026-11-18. Source: stacked on draft PR #845, initial genuine local-model run at exact CI 44389322106. **Not a scored comparison, not an externally preregistered benchmark, not a successful task completion claim.**

## Goal

Run a second genuinely distinct local coding-model weights set on the exact SAME pinned, public agent-facing DispatchQ-B1 and ArtifactGraph-B2 tasks under the same mediated-tool protocol and nine-step budget as the first Qwen2.5-Coder 3B trial. The second model is Qwen2.5-Coder 1.5B (official Ollama tag qwen2.5-coder:1.5b). This is a different weights artifact in the same model family, not an independent human researcher or wholly different architecture.

Frozen task PR commits:
- DispatchQ-B1: c11881717d354462d49205ad86eecbdde719c47e
- ArtifactGraph-B2: d5158a3aa37fa0f0ac877406ec806389cc04b5b6

The first model ran with nine response/tool turns, temperature 0.2, seed 20261118, top_p 0.8, max 1850 response tokens, and allowed only list_files, read_file, write_file, run_smoke, finish. It could edit only existing package .py files. The second run reuses THE SAME source code and workflow contract through a small importlib wrapper that changes only the model tag. The source code of the mediator, public contract probes, grader and initial task is untouched.

The independent CI workflow re-downloads the official 1.5B weights and records the actual local Ollama SHA digest. Downloaded model weights are not externally committed before run; compare as calibration only. It uses fresh source/endpoint container and records any model failure or zero-patch outcome, not only successful repairs.

## Audit/control

- Real Ollama API inference and actual mediated file read/writes in a credential-free host workspace.
- Only public smoke tests execute agent edits, in Docker with disabled network, no-new-privileges and resource limits.
- A separately authored public contract canary is executed AFTER the model finishes on the generated patch, in an isolated phase with no hidden scorer. This is not the author-hidden graded benchmark.
- Public artifact records task commit, model and runtime digests, actual tool call counts, modified-file hashes, patch SHA, raw transcript SHA and public smoke/canary outputs. Raw transcript and patch are withheld from public artifact; that limits independent replay.
- No private DispatchQ or ArtifactGraph grader/reference source is accessed by the agent. The known-insecure same-process score-origin capsule in PR #841 is NOT used.
- A zero-patch run or a 3/3 public smoke pass is an unscored model behavior observation, NOT evidence of solving the full contract.

## Prior first-model observed baseline (NOT a benchmark score)

At initial PR #845 CI run 44389322106:
- Qwen2.5-Coder 3B / DispatchQ: 5 actual tool calls, 1 source file modified, model finished, public smoke exit 0; no held-out score.
- Qwen2.5-Coder 3B / ArtifactGraph: 9 actual tool calls, 0 files modified, model finished, public smoke exit 0; no held-out score.
- Weights SHA f72c60cabf6237b07f6e632b2c48d533cef25eda2efbd34bed21c5e9c01e6225.

These first observations were measured before this second-model branch existed; therefore do not label the two runs a prospectively registered head-to-head or a significant performance comparison. Environment images and per-run traces must still be reconciled.

## Success and stop rules

This PR succeeds as a *second actual tool-agent pilot* only if source-exact CI shows at least one actual inference response and the actual local model digest. Distinguish that from solving the programming task. No model leaderboard, confidence interval, blinded benchmark score or Polaris endorsement. Do not merge without reviewing public provenance and reconciling #845's own ongoing changes.

Next accepted benchmark gate: source/origin-separated trusted grader (synthetic score-forgery falsifier in #843), independent contract audit, preserved raw trace custody, externally frozen model and run denominators, then multiple blind attempts with matched budgets and approved evaluators. Until those gates, these are exploratory SWE-agent behavior records.
