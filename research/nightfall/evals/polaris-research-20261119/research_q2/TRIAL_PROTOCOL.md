# Polaris ProofGraph-Hard: preregistered trial protocol (v0.1)

**Purpose:** Measure whether two genuinely separate frontier agents can reconstruct and integrate a real pinned Lean proof under equal resources, without being allowed to weaken the theorem. **No agent trials have yet been run.**

## Objective, source and mathematical feasibility

- Target: `Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation` from `TASK.md`.
- Positive feasibility control: existing NIGHTFALL certified scalar proof, originally validated in PR #558; the reference reruns only in the trusted evaluator, not the agent workspace.
- Mathematical challenge: use the independently supplied Bernstein polynomial inequality to prove the shifted c/4 moment interpolation exactly.
- The stronger full original-source finite-product Q2 theorem is **not** the task statement; no result here proves an improvement to the Q2 coefficient.
- Source provenance: PR #558 and the public reference source. Because the answer is publicly accessible, this task is a **development/calibration benchmark**, even with a clean agent workspace. No hidden benchmark score until a genuinely unseen problem variant and an independent reference solution are arranged.

## Pre-registered run conditions (for future blind-heldout use)

One task bundle, two independent agents, one attempt each, in fresh VM environments that cannot communicate or access the reference proof. Each gets exactly the same task text, non-editable trusted source, Lean 4.36.0-rc2, pinned Mathlib commit, and no network or hidden reference files. Common maximum: **3,600 wall-clock seconds**, **100,000 total model tokens**, and **US$40 measured API cost**, whichever limit is reached first. An evaluator must actually enforce those limits; otherwise a run cannot be called comparable. Reject any environment that cannot provide synchronized source hashes and real usage accounting.

Before seeing any agent result, freeze the grader commit, exact task files and source SHA-256s, model identifiers and versions, prompts, allowed tools, evaluator environment, trial-start timestamps, timeouts, and pass/fail policy. Obtain two truly separate agent execution sessions rather than asking one model to simulate two reviewers.

## Acceptance and independent attack

1. Exact locked theorem builds from trusted copies plus the candidate-only overlay. An authored proof is not allowed to edit target, source, theorem statement, imports, or axiom policy.
2. Successful grader-owned `#print axioms` under the three-standard-axiom allowlist and separate `leanchecker` replay of the compiled trusted target.
3. Source integrity: all trusted inputs match pre-run hashes and remain unchanged after compilation.
4. Auditor B, designated **before** reviewing agent output, reproduces the checker result on an independently staged project and attacks changes to theorem statement, scalar constants, false imports, extra axioms, stale binaries, malformed receipts, and hidden-source leakage.
5. Any unauthorized axiom, omitted hypothesis, changed constant, proof hole, failed replay, contaminated trial, or missing trace is **FAIL**, regardless of prose quality. Do not promote an accepted formal certificate to a new mathematical theorem or novelty claim without separate external review.

## Trial receipt requirements

Each run must record: agent and model exact identifiers, provider/API version, source-bundle hash, evaluator repo commit, toolchain and Mathlib hashes, full input prompt, commands and outputs, failed attempts, tokens, elapsed time, monetary spend, candidate SHA-256, grader receipt digest, independent replay result, and whether any reference proof was accessed. Missing metrics are marked **missing**, never estimated. Baselines must use the same budget and access policy.

## Scoring

The primary binary outcome is correct/invalid, with an uncertainty flag for incomplete provenance; only complete verified trials enter pass-rate denominators. Separately report reliability over repeat seeds, transfer to genuinely different target families, proof mechanism, resilience to checker failures, and verified cost to success. Confidence intervals require enough independent samples; two agents are a feasibility pilot, not a statistically meaningful leaderboard.

**Stop rule:** stop and reject score publication if the reference proof fails reproducible clean replay, if the weakened-target negative control is accepted, if source-leakage is detected, or if resource budgets cannot be enforced. Public positive-control CI remains explicitly unscored.
