# ProofGraph-Hard v0.1 — trusted-target Lean integration

Status (2026-11-19): PROTOTYPE, UNSCORED. The public toy target PASSED a pinned Lean 4.36.0-rc2 build, standard-axiom audit (no dependencies), and separate leanchecker replay in CI run 44560021054. The 17 fake-runner adversarial tests also passed. This is not a frontier-model score or mathematical research result; no research-level integration target has yet been wired.

## Objective

A trusted task manifest pins toolchain, source tree SHA-256, allowed submission file paths, and required theorem names. The agent provides only proof modules. The evaluator stages the independent trusted target and proofs in a temporary project, invokes the pinned Lake build, emits grader-owned axiom checks, and rejects nonstandard dependencies. The trusted target file contains the actual theorem statement and cannot be overwritten by the candidate.

The fixture uses ProofGraph.terminal, elementary commutativity of natural-number addition; the example proof is intentionally public and trivial. Never report its success as research performance.

## Local commands

    python3 -m unittest test_proofgraph.py -v
    python3 grade_proofgraph.py --manifest fixture/task.json --trusted-root fixture/trusted --submission fixture/submission --receipt /tmp/proofgraph-receipt.json

The first uses a FAKE Lake runner to test checker behavior. The second requires Lake and the pinned Lean toolchain, with a separate CI job to run it. Fake-Lake success is labeled harness-smoke-only. Real Lake success is labeled leanchecker-kernel-replay-pending-external-review. It means a separate Lean kernel replay passed; this is neither independent implementation verification nor external mathematical review.

## Security boundary

The manifest and trusted project must remain outside the agent's writable workspace. The evaluator pins the trusted-source SHA-256, copies only explicitly allowlisted .lean files, rejects symlinks and extra files, rejects common proof bypass tokens (sorry, axiom, unsafe, native_decide), inspects axiom reports, and checks trusted source bytes after execution.

**This Python adapter is not a security sandbox.** Candidate Lean metaprograms can execute host code. Production evaluation requires ephemeral, restricted, nonprivileged, network-disabled VM/container execution, resource limits, and independent kernel replay under a different trusted environment. The lexical scanner is defense in depth; the axiom report and kernel, not the scanner, govern proof soundness.

## Hard-task readiness gates

1. Freeze a substantive nontrivial theorem at a full immutable source commit and exact Lean toolchain. Prove a clean-room reference solution exists. Keep the proof withheld from candidates.
2. Provide the agent only the pinned input checkout, missing proof module contract, time/tool/token budget, and permitted references. Never expose reference outputs, source patches, proof receipts, or held-out tests.
3. Test hard negatives: theorem weakening, changed definitions, unauthorized axioms, missing proof, modified imports, stale cache, malicious source mutation, and build failures. Run independent kernel replay.
4. Run at least two blinded agents with logged attempts, tokens, costs, elapsed time and exact source hashes. Blindly assess any claimed new proof mechanism, and audit prior art before calling it novel.
5. Report independent pass/fail, research quality, efficiency, generalization and reliability as separate gates. A public fixture is a development benchmark only.

## Sources and attribution

Vals AI, GPT-6.2 Astra Formalizes Smoktunowicz's Gap Theorem (2026-11-18): https://www.vals.ai/blogs/smoktunowicz-gap-theorem

Meta FAIR, AutoformBench: https://github.com/facebookresearch/autoformbench

Neither source endorses NIGHTFALL. The public task is not comparable in difficulty to Autoform-Hard.
