# Polaris benchmark portfolio card — ProofGraph-Hard v0.1

**Artifact ID:** POLARIS-PROOFGRAPH-HARD-20261119-v0.1
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

## Integrity mechanism

Immutable source tree hash -> allowlisted .lean submission overlay -> fresh trusted-target Lake build -> evaluator-owned #print axioms -> separate leanchecker replay -> hashed receipt. The simulated-runner tests attack unapproved files, source changes, symlinks, path traversal, axiom injection, sorry, forged/missing reports, build failures and checker failures.

## Upgrade threshold: when it becomes a real hard benchmark

1. Freeze a *nontrivial*, already-established NIGHTFALL theorem from a pinned source and a known-correct reference build.
2. Withhold a substantive supporting module, segregate all ground-truth proofs and mutation tests from agent-visible inputs.
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
