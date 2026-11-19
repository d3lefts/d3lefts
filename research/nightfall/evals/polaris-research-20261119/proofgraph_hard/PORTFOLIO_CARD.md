# Polaris benchmark portfolio — ProofGraph-Hard v0.2

**Artifact ID:** POLARIS-PROOFGRAPH-HARD-20261119-v0.2
**Class:** formal proof integration / research-engineering evaluation
**Claim status:** validated *calibration harness*, not a scored frontier-agent benchmark
**Maintainer:** NIGHTFALL; not affiliated with Meta FAIR or Vals AI

## Verified checkpoint

- **17/17** simulated-runner unit tests passed (local run and GitHub CI).
- **1/1** public toy Lean fixture passed an actual Lean build under leanprover/lean4:v4.36.0-rc2.
- Trusted declaration: ProofGraph.terminal, natural-number addition commutativity. Exact statement resides in evaluator-owned ProofGraph/TrustedTarget.lean, not in the submitted proof file.
- The grader-owned axiom report returned **[]** (no axiom dependencies).
- A separate leanchecker process replayed ProofGraph.TrustedTarget from the compiled .olean, exit code 0.
- Trusted project SHA-256: 73bdac506fccb57a5d34d55a00f31aa5a892502fe8836cbcdf441874f7e7ec97.
- Candidate proof SHA-256: 374208248ecdeeda4f8b7263e49047a1835ed47e97b564f9762e001354637dda.
- GitHub Actions evidence: https://github.com/d3lefts/d3lefts/actions/runs/44560021054
- CI receipt: https://github.com/d3lefts/d3lefts/actions/runs/44560021054/artifacts/14548401455

This verifies tooling only. There are **zero** measured frontier-agent trials, no hidden holdout task, no independent-implementation proof audit, and no expert novelty review. One trivial theorem is not a research-grade benchmark.

## Tier 2: genuine NIGHTFALL Q2 scalar proof integration — verified reference

- **Statement:** `Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation`, exact shifted-c/4 real moment interpolation under Hölder and strong fourth-moment hypotheses; part of the merged finite-product degree-two coefficient C107 proof (#558).
- **Trusted inputs:** frozen `ShiftedC4Bernstein.lean` (Git blob `d29a1e5f0396ca7f29fde24a34325fc324a3d3c0`) and evaluator-owned `NightfallPolarisQ2Target.lean` (Git blob `7f0c86d5e6e04e0f6330f017aceff6bbb141c747`).
- **Known-correct public positive control:** original `ShiftedC4Scalar.lean` successfully compiled with Lean 4.36.0-rc2 and Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`. The trusted target compiled and printed exactly `Classical.choice`, `Quot.sound`, `propext`; separate `leanchecker` returned exit code 0. CI run https://github.com/d3lefts/d3lefts/actions/runs/44564272576 ; receipt https://github.com/d3lefts/d3lefts/actions/runs/44564272576/artifacts/14551751354 .
- **Adversarial semantic negative:** replacing the candidate with a theorem of the correct name but conclusion `True` was **rejected by the frozen Lean target**, not merely a lexical scan. Verified in run https://github.com/d3lefts/d3lefts/actions/runs/44565025248 ; both positive and negative receipt files https://github.com/d3lefts/d3lefts/actions/runs/44565025248/artifacts/14551063562 .
- **Separate exact audit:** the existing Fraction-based c/4 Bernstein checker is integrated into the CI job, independently recomputing its own polynomial positivity certificate. This checks that polynomial only, not the full source-product inequality.
- **Task and reproducibility:** [research-Q2 task](../research_q2/TASK.md), [equal-budget trial protocol](../research_q2/TRIAL_PROTOCOL.md), [minimal input preparer](../research_q2/prepare_agent_bundle.py), and [grade script](../research_q2/grade_research_q2.py).

The research target is **not** the full original-source Q2 terminal theorem and not a new mathematical discovery. No blind agent attempted it, and no external referee independently audited the proof. Public-source access makes memorization and answer leakage possible; an unpublished task variant and isolated agent execution are required before performance scoring.

## Tier 3: sealed submission and untrusted-code isolation (experimental)

A [restricted container entrypoint](../research_q2/sandbox_runner.py), [preliminary image recipe](../research_q2/Dockerfile), and [threat-model protocol](../research_q2/SANDBOX.md) have been added. The input set contains exactly five named files, protects the trusted theorem and Bernstein source with immutable hashes, uses a network-disabled read-only container with non-root uid and resource limits, and validates all six reported proof/axiom/kernel steps before writing a host receipt. The container is supposed to use a fresh ephemeral Mathlib workspace per candidate. The source/policy/receipt tests are CI-exercised. An image was **built and content-addressed** in [CI run 44575864049](https://github.com/d3lefts/d3lefts/actions/runs/44575864049), but **0/3 real runtime controls validated** because the previous full-workspace copy produced no grader JSON. The [failure artifact](https://github.com/d3lefts/d3lefts/actions/runs/44575864049/artifacts/14557991714) confirms an infrastructure failure, not theorem refutation. Thin-workspace staging and Docker stderr/negative-receipt retention are committed, but awaiting a successful new three-case CI run. The image was **not independently security-audited**. This remains an implementation gate, not a security certification or scored agent result.

## Integrity mechanism

Immutable source tree hash -> allowlisted .lean submission overlay -> fresh trusted-target Lake build -> evaluator-owned #print axioms -> separate leanchecker replay -> hashed receipt. The simulated-runner tests attack unapproved files, source changes, symlinks, path traversal, axiom injection, sorry, forged/missing reports, build failures and checker failures.

## Upgrade threshold: when it becomes a real hard benchmark

1. Completed for the Q2 scalar development tier; a truly unpublished research target is still needed for a clean hidden evaluation.
2. The source-minimal input generator excludes the known proof; physically segregate ground truth and block public-source leakage before any blind scored trial.
3. Run arbitrary agent Lean code in an ephemeral nonprivileged VM/container without network, with explicit CPU/memory/time/tool budgets. The current Python adapter alone is NOT a sandbox.
4. Independently audit task truth, target equivalence and checker coverage. Test adversarial proof-bypass attempts and hidden task-family generalization.
5. Execute at least two blinded agent baselines on the SAME target and budgets; report the full outcomes, costs and recovery paths.

## Scoring contract (not yet active)

**Hard validity gate:** intact trusted target, allowed proof modules only, clean build, allowed axioms, kernel replay. All failures count as invalid regardless of explanation quality.

**Separate dimensions:** research mechanism and generalization; reproducibility; held-out robustness; efficiency and recovery after failed attempts. No partial-credit compensation for an invalid proof.

## Prior-art / design credit

Benchmark design informed by Vals AI's analysis of Autoform-Hard and the 2026 Lean formalization of Smoktunowicz's Gap Theorem:
https://www.vals.ai/blogs/smoktunowicz-gap-theorem

Meta FAIR AutoformBench:
https://github.com/facebookresearch/autoformbench

Neither provider has evaluated or endorsed this NIGHTFALL prototype.
