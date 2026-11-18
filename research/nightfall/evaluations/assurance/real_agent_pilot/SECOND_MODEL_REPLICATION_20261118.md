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


## Final matched public-source observations (2026-11-18)

Two fully executed, distinct local Ollama model weights sets, SAME frozen task source commits and allowed nine response/tool turns, with separate post-agent PUBLIC contract canary. The second run is from model Qwen2.5-Coder 1.5B. An automatically triggered matched Qwen2.5-Coder 3B rerun on the same PR head allows comparison under the same workflow contract.

- Qwen1.5B actual weights SHA256: d7372fd828518a4d38b1eb196c673c31a85f2ed302b3d1e406c4c2d1b64a0668
- Qwen3B actual weights SHA256: f72c60cabf6237b07f6e632b2c48d533cef25eda2efbd34bed21c5e9c01e6225
- Both used source-identical DispatchQ-B1 and ArtifactGraph-B2 task snapshots, the same pinned Python execution image, the same fixed mediator tool affordances, and no private grader.
- Qwen1.5B exact-head [CI 44390828857](https://github.com/d3lefts/d3lefts/actions/runs/44390828857): DispatchQ-B1 4 tool calls, one write, **no NET modified files**; 5 of 13 independent public contract cases pass, 8 violate. ArtifactGraph-B2 one tool call, no writes; 9 of 20 pass, 11 violate. Public smoke exit code 0 on both. Artifacts 14468011300 (DispatchQ), 14467886438 (ArtifactGraph).
- Qwen3B matched [CI 44390828722](https://github.com/d3lefts/d3lefts/actions/runs/44390828722): DispatchQ-B1 4 tool calls, one real final modification in dispatchq/queue.py; **still only 5/13 public contract cases**, 8 violate. ArtifactGraph-B2 8 tool calls, no writes; 9/20 pass, 11 violate. Public smoke exit code 0 on both. Artifacts 14469111176 (DispatchQ), 14467716806 (ArtifactGraph).

Exact source SHA identities, patch hash, raw transcript hash, public-contract auditor SHA, Docker image digest, model weights digest, attempts and artifacts have been copied into the small machine-readable PUBLIC ledger TWO_MODEL_PUBLIC_RECEIPT.json. This is a preservation of OBSERVED PUBLIC RECEIPT METADATA, not reconstruction of the withheld raw model transcripts. The checker check_two_model_public_receipt.py and dedicated Python 3.10/3.13 CI test arithmetic/provenance consistency with fail-closed scoring scope; they cannot independently authenticate unuploaded raw model output.

### One defensible evaluation finding

In both tasks and both real-model attempts, all deliberately shallow PUBLIC smoke tests passed; nevertheless a separately authored contract probe found 8 or 11 explicit obligations unmet. A nontrivial 3B DispatchQ source change failed to improve the public canary count relative to the unchanged starter. This is strong evidence of why *task completion must be checked against semantic and concurrent contract invariants rather than superficial smoke results*. It is NOT evidence that the agent architecture is intrinsically incapable of these tasks, or that the hidden author grader is valid.

Both configurations belong to the same Qwen2.5-Coder family, and the first experiment predates this second-model comparison. No externally frozen preregistration, independent review, complete public trace replay, held-out score, human reviewer certification, confidence interval, or model leaderboard exists. Numerical job-application claims must remain scoped to the actual source-exact public checks and zero accepted blind-grade episodes.

### Grader source-integrity blocker

Parallel [PR #843](https://github.com/d3lefts/d3lefts/pull/843) independently demonstrated 2/2 fabricated 100/100 toy scores from the same-process scorer capsule #841 under REAL Docker, despite proper plan/source/grader hashes. [PR #846](https://github.com/d3lefts/d3lefts/pull/846) provides only a synthetic-only stopgap while process/mount separation is unresolved. The present two-model pilots deliberately DO NOT invoke that grader. A future actual model-score experiment must first pass both attack cases as expected rejections under a separated trusted scoring authority.
