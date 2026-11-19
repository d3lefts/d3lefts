# ProofGraph-Hard Q2 — sealed-container execution gate (experimental)

**Status:** source and CLI policy implemented; static/unit tests are part of PR CI. This document is **not evidence that a Docker image has been built, inspected, signed, or run successfully**. The established trusted Lean reference CI uses a hosted runner and does not exercise this path.

## Why this gate exists

Lean 4 permits metaprogram execution during elaboration. Compiling an untrusted candidate directly in the repository or the reusable Mathlib workspace is unsafe. Reusing the workspace also risks contamination of subsequent trials by leftover .olean files. The container runner stages exactly five files: trusted Bernstein lemma, frozen terminal theorem, grading script, Lean pin, and the **candidate-submitted** proof. It never mounts the source repository or the known public reference proof as an extra source.

The `sandbox_runner.py` wrapper refuses any unpinned image, refuses a missing Docker runtime, refuses unexpected staging files, and ensures only the sealed task is bind-mounted read-only. Docker is configured without network access, as nonroot uid 10001, with read-only root filesystem, no capabilities, no-new-privileges, a PID cap, CPU/memory caps, and fresh tmpfs for a copied Mathlib workspace. The compiled objects cannot survive into another run. The only host receipt is written by the trusted wrapper after validation of the grader's JSON result.

**Security limitations:** Docker is not a virtual machine. The Docker daemon, image, kernel, host wrapper, Linux isolation settings, and grader remain in the trusted computing base. This runner has not been penetration-tested; do not run hostile submissions on privileged or sensitive hosts. For high-stakes evaluation use a dedicated disposable VM with rootless container runtime, independent artifact rebuild, enforced resource quotas, and external auditing. An image pinned by digest is not automatically trustworthy.

## Preparing an image

`Dockerfile` is a provisional build recipe. It pins:
- Lean `leanprover/lean4:v4.36.0-rc2`, source commit `b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a`
- Mathlib `v4.36.0-rc2`, commit `9d581dfff2e41de989072ea63abf3daf69311520`, with cached compiled artifacts
- A nonroot user uid 10001

It currently fetches the elan bootstrap over HTTPS without a separately pinned installer content hash and uses the Ubuntu release tag rather than an immutable base-image digest. A security review must lock and verify these before treating the image as independently reproducible.

A trusted operator can build the image from the `research_q2` directory, independently inspect it and push it to a controlled registry. Use the registry's immutable `repository@sha256:<digest>` reference, **not** `:latest` or an unverified image ID. This PR does not provision such a registry image, and the public positive-control run does not count as a sandbox execution.

## Example invocation *after* image audit

```sh
python3 sandbox_runner.py \
  --candidate /path/to/agent/output/ShiftedC4Scalar.lean \
  --image registry.example/polaris-q2@sha256:<audited-64-hex-digest> \
  --output /path/to/new/receipts
```

This is a **template**, not an executed command. The image must expose a pinned toolchain in PATH and a source-and-cache verified Mathlib checkout at `/opt/mathlib4`. The runtime makes an ephemeral private copy at `/tmp/mathlib4` for that trial. Failures of image identity, build, theorem checking, axiom checks, kernel replay, or source hashes reject the submission. An actual container run and independent security audit are prerequisites for claiming operational isolation.

## Offline policy checks

```sh
python3 -m unittest discover -s research/nightfall/evals/polaris-research-20261119/research_q2 -p 'test*.py' -v
```

Tests inspect the sealed file set, immutable-image syntax, required Docker flags, compiler identity, and fail-closed behavior. They do **not** test container escape resistance or prove that the preliminary Dockerfile builds.

## Scoring boundary

This remains a publicly known theorem with a public answer. Reproducing the proof is a calibration task, **not a hidden frontier benchmark**. No model has attempted it under the registered two-agent trial protocol, and no measured performance is claimed. Deployment requires a private task source with leakage controls, independent evaluator review, real enforced budgets, and authenticated receipts.
