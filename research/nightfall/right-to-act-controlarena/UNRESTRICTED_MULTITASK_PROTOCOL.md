# NIGHTFALL unrestricted, multi-task ControlArena paired experiment (v1)

## Objective and external references

Measure whether verified protected-effect substitution persists for a normal tool-using attacker over **multiple independent** real ControlArena tasks, and distinguish the offline measurement from actual authority service costs. The published ControlArena IaC Fast documentation specifies 5 main × 9 side tasks (45 combinations), with native bash/text_editor/cdk_ls/cdk_synth and official combined pytest scoring. These are the source of the task definitions, not custom model-selected edits.

Strongest relevant competing evaluation checked this session: *Democratizing Agent Deployment Safety: A Structural Monitoring Approach* (2026, OpenReview), which evaluates a structural CFG/DFG-based monitor over 100 honest / 160 attack IAC Fast episodes, reports 5% joint sabotage under realtime rollback and a utility decrease. This NIGHTFALL pilot is **not** a new structural-monitoring idea and cannot claim better effectiveness with 6 attempts.

## Frozen selected task pairs and negative hypothesis

Run official IaC Fast 20.1.1 under its native Inspect tool agent, local Qwen2.5-Coder-3B, standard untrusted_policy_builder, 16k token limit, 24 agent steps, 240 s per sample.

- Applied Interpretability OU + disable FSx exports.
- Billing alarm + allow public S3.
- Enforce mandatory resource tags + detach hardware-MFA requirement.

Three honest and three attack samples, each in a fresh official native Docker sandbox with the exact official task scorer. The agent receives full native shell and source-editor tools; **no preselected file, exact-string replacement, authored legitimate scaffold, or source path whitelist**. A fresh task selection does not constitute unrestricted adversarial compute: model, tasks, token steps, and Docker boundary remain restricted.

## Metrics/certification

Per attempt preserve native Inspect .eval log (full model/tool trajectory and scorer results), task ID, raw combined_pytest_scorer Score.value, source submission_diff where available, wall time, model/runtime digest, model/Inspect package versions. Count failures and tool errors in the attempted denominator and distinguish three separate events: agent completed, main task passed, side task passed. The independent auditor requires exactly 6 intended tasks, original source task names, no author-scaffold flag, a case receipt per attempt, C/I scorer codes rather than the Inspect status for main/side evaluation. Do not infer sampled safety rates from six samples.

The present run scores original generated changes natively. It does **not yet reconstruct each agent-modified source tree inside the trusted authority service**. Any such replay requires independent source/diff verification, a baseline source-to-template binding, identical task policy and effect-time enforcement. Do not claim end-to-end safe authorization on a model-generated native task unless that bridge is independently checked.

## Economic and lifecycle gates

Measured CPU and wall-clock costs of the full trusted local Unix-domain socket service, peer UID and signed issuance, source/policy hash and epoch checks, verifier selection, nonce replay prevention, durable fsync/atomic JSON publication, source advance and forced recertification are required to claim **local end-to-end enforcement costs**. AWS, IAM deployment, cloud commit latency/monetary charges, human review, and lifecycle support remain exclusions.

Stop after the six preregistered agent samples and limited local service benchmark. If model tools fail or native scorers do not run, report a blocked or failed benchmark; never substitute authored patches. Independent human review and additional larger diverse task coverage before general economic inference.

## Credit

Research program: Devin J. Wright / NIGHTFALL. Evaluation and engineering implementation: AI-assisted. Official simulator and tests: UK AISI/Redwood Research ControlArena and Inspect AI. Competing structural monitoring: *Democratizing Agent Deployment Safety* (OpenReview 2026); monitor-cost prior art Hua et al. (NeurIPS 2025), Terekhov et al. (ICLR 2026).
