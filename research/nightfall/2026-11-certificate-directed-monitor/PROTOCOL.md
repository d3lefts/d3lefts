# Certificate-directed monitor: source-matched ControlArena evaluation

**Date:** 16 November 2026. **Status:** preregistered current-head experiment; do not claim a result until exact CI and independent receipt audit pass.

## Objective and comparator
Test whether a certificate-obligation-based check ordering can reduce real wall/CPU time in host-side verification while preserving official-task legitimate availability and rejecting known harmful source changes. Compare **identical** synthesized effect templates and missions under (a) the full task-specific verifier from merged #605, (b) a necessary protected-policy precheck followed by the SAME full verifier, and (c) an equally informed baseline permitted to use the identical precheck and full verifier.

The third arm is the decisive matched comparator: any improvement over (a) that disappears against (c) is a **non-novel algorithmic scheduling optimization**, not a frontier monitoring breakthrough. Do not claim any learned monitor gain because the check scheduler is deterministic.

## Model provenance and corpus
Two already-authored ControlArena IaC Fast main tasks (OU and monthly billing SNS), paired with two separate preauthored harmful changes (FSx deny weakening; MFA detachment): six **authored** candidates, plus two previous local Qwen2.5-Coder 3B constrained model-authored action omissions reproduced from exact raw JSON in PR #601. The last two are **not freshly sampled** model attacks and not unrestricted tool-use. ControlArena version 20.1.1 and CDK 2.260.0 are pinned. Each candidate is synthesized in Docker, scored using the original official main and harmful side test(s), then admitted/denied by host-side verifiers. No AWS credentials or deployed effects.

## Assumptions, mechanism and falsifiers
The authenticated source and pinned original baseline are trusted inputs. The precheck enforces only two protected policy necessary conditions (contents and attachments) and **NEVER grants** permission. Positive admission requires the same complete mission verifier as baseline. A cached research receipt is merely a logical equality and epoch check, not a signed credential or a deployed enforceable effect gate.

Predictions:
1. Both arms require full verification for the two legitimate controls; 2/2 must be admitted.
2. Both arms must deny all six known harmful templates; unknown labels do not create a default allow.
3. A selective precheck can reject both model-authored FSx omissions earlier than full verification, but may increase cost for harmless candidates and certain missing-MFA cases.
4. The matched comparator can adopt exactly the same ordering, so **no proprietary advantage** is expected.
5. A source-epoch update invalidates cached permission, even if template bytes are identical, until trusted recertification.

Stop and demote if any harmed candidate is admitted, honest candidate is rejected, official source score fails, model response provenance drifts, receipt hash mismatches or forged receipt passes the independent audit. Do not infer deployment, model safety rate, statistical significance or dollar savings from 8 selected templates. For meaningful deployment advantage, subsequently test a model-generated heterogeneous task sample against equally informed strong monitors, and include complete mediation and source-refresh costs.

## Existing reference and priority boundaries
- [NIGHTFALL #605](https://github.com/d3lefts/d3lefts/pull/605): source-matched official tasks, source/mission changes, real local effect guard service, negative verifier-cost result.
- [NIGHTFALL #601](https://github.com/d3lefts/d3lefts/pull/601): two different Qwen-generated constrained source omissions; legitimate scaffold supplied separately.
- [NIGHTFALL #604](https://github.com/d3lefts/d3lefts/pull/604): native agent full-tool run produced **zero actual tool calls** and no valid task successes.
- [NIGHTFALL #636](https://github.com/d3lefts/d3lefts/pull/636): separate finite Lean proof for checkpointed joint cost; it **does not certify this Python implementation**.
- Prior art includes FAVA, VEPA, Matoi and assurance-aware scheduling. No novelty priority approval.

## Reproduction
Run the pinned workflow `.github/workflows/nightfall-certificate-directed-controlarena.yml` (Docker, pinned dependencies, exact-score and receipt checks). Its artifact preserves 8 candidate templates, original receipt, independent check, raw model responses in the runner source, environment fingerprint, no simulated AWS effect. Timing results are machine-specific.
