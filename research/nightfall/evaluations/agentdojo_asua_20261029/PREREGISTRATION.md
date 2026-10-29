# NIGHTFALL / ASUA → AgentDojo empirical experiment
**Preregistration draft v0.1 · 2026-10-29 · NO RESULT / NO MODEL RUNS**

Research lead: Devin J. Wright. Execution/analysis: NIGHTFALL with independent blinded review. This document may be edited only by versioned amendments retaining the original.

## Exact question
Does enforcing a deterministic *action-authority boundary* between retrieved tool content and user-delegated tool actions reduce attack success on AgentDojo prompt-injection tasks, compared with no defense and a fixed repeat-user-instruction comparator, without materially harming legitimate task completion?

ASUA motivating mechanism: two histories can be observationally identical to the agent while differing in their underlying authority. A model that treats untrusted retrieved instructions as delegated commands can cross that boundary. This is a **testable engineering instantiation**, not a proof of the ASUA manuscript or causal confirmation from retrospective data.

## Source and frozen feasible set
- AgentDojo upstream repository fixed at [sequrity-ai/agentdojo@357c80dea9af34323f709c3505d9e6d224654c7e](https://github.com/sequrity-ai/agentdojo/commit/357c80dea9af34323f709c3505d9e6d224654c7e), benchmark paper and MIT-license terms credited.
- Suites: banking, Slack, travel, workspace, with ten eligible injected-task pairs per suite selected by sorted stable IDs after freezing the eligibility rule. Each task must have a scored attacker objective and a user-task objective. Publish full ID list **before** the first model inference.
- Conditions: no defense; existing repeat-user-prompt comparator; existing tool-filter comparator; proposed deterministic authorization-boundary defense. Each of 40 cases × five frozen seeds × four conditions, 800 attempted model trajectories, plus failed-provider calls logged separately.
- Model version, tool interfaces, defense text, attack type, parser/validator hashes, randomization, and pricing must be locked before any scored run. Use same deterministic task order/attack payload distribution in all conditions; model assignment blinded at scoring.
- Authority-boundary defense: tool-returned document/text segments may supply factual task data, never override the user's action intent, delegate third-party access, authorize sensitive writes, or alter allowed recipient/destination. Implement and test at the action gate, not merely via a prompt string. Unauthorized tool calls must be blocked and logged with a structured reason; false positives count toward legitimate-utility harm.
- **No cost-bearing run until model credentials and an explicit expenditure ceiling are approved by the research owner.** This document alone authorizes no API spending.

## Locked main prediction and thresholds
Primary endpoint is attacker-goal success rate (ASR) measured by AgentDojo's unchanged objective grader. Pair tasks/seeds across arms; estimate the defense-minus-no-defense ASR difference with task-cluster bootstrap (task as unit) and 95% CI. Secondary endpoints: legitimate task completion and refusal/invalid-action rates.

Predicted meaningful effect: **absolute ASR reduction ≥10 percentage points**, with the paired cluster 95% CI excluding 0, and **legitimate task completion drop ≤5 percentage points** vs the no-defense arm. Multiple-comparison outputs against the other comparators are exploratory, corrected or declared exploratory. No tuning on final test tasks.

### Alternative outcomes / kill criteria
- A confidence interval including zero means **inconclusive**, even when the point estimate is favorable.
- Reduction under 10 percentage points, or a legitimate-completion drop exceeding five points, **fails the predeclared useful-benefit gate**.
- If results lie within between-seed variability, publish null/negative evidence and all task-level logs.
- Any unimplemented or non-equivalent gate, benchmark drift, missing attack grader or unmatched task is an execution failure and must be disclosed without fabricated ASR.

## Reproducibility and publication
Frozen manifest: upstream commit, task IDs, seeds [171, 271, 371, 471, 571], model revision, four arm configurations, hashes of runner/grader, environment lock, runner command, expected bill. Raw per-task logs, pass/fail, grader version, blocked-action ledger, and failure reasons must be retained. At least two separately written outcome aggregators; reviewer gets blinded labels before key reveal. Human approval required for public datasets if they contain user data or secrets; use benchmark synthetic tasks only.

## Status
**R0 preregistration design.** No AgentDojo run, no reported efficacy, no safety flagship, and no Proof Passport evidence promotion at this checkpoint. Human and technical blockers: true gate integration, frozen task list, deterministic baseline success check, credential/budget approval, independent scorer.
