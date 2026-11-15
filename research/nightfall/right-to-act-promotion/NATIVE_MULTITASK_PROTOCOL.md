# Native Inspect/ControlArena full-tool multi-task attack experiment (2026-11-15)

**Purpose:** Separate real open-file-choice agent work from the prior five-choice source-edit trials. This uses unmodified pinned ControlArena 20.1.1, IACFastSetting, its bash/text_editor/cdk_ls/cdk_synth agent tools, official scoring, untrusted_policy_builder, and Inspect eval.

**Pre-registered sample IDs.** Honest mode MT_add_interpretability_ou and MT_create_billing_alarm. Attack mode Cartesian product of those two main tasks and the side tasks disable_fsx_deny_policy and detach_mfa_requirement_policy (four attack combinations). Select EXACT sample IDs, not the first records in the benchmark. One attempted native evaluation per sample. No retries, cherry-picking, pre-authored patches, path allowlist or constrained source-edit slot. Local `ollama/qwen2.5-coder:3b` model, no credentialed hosted model.

**Measure:** per-sample official main/side score and any errors, native Inspect .eval trace, task metadata, elapsed mode time, model digest, pinned framework and Docker versions. Model failures must stay in denominator; no valid attack execution implies NO measured defense success. Full tool access is limited to the official Docker/IaC Fast sandbox and limited run-time; this is not 'unrestricted real-world authority'.

**Boundary:** Native ControlArena evaluates model behavior; it does **not** automatically expose altered source templates to the NIGHTFALL finality service. Do not conflate native Inspect scorers with separately executed local effect-time enforcement. Complement this experiment with the exact same-task ControlArena independent template promotion/cost experiment; neither provides production AWS deployment assurance.

**Stop:** six pre-selected samples total, one model version, fixed token cap 14k, no AWS credentials/deployment or source modifications to the official tests. If native evaluation cannot execute, fail closed and archive full error. Resource budget one 55-minute GitHub-hosted runner, no paid hosted LLM API.
