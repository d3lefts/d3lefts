# NIGHTFALL Discovery Engine — version 1

Launch: https://d3lefts.github.io/d3lefts/discovery.html

The application unifies problem contracts, representation lineage, a reusable operator registry, preregistration, local finite experimentation, exact replay, and portable evidence packaging. It uses the existing research archive as the reference source and preserves its proof-status boundaries.

## Capabilities

1. Define the quantified objective, assumptions, feasible set, external baseline, proven gap, significance threshold, budget, audit, checker and cheapest decisive experiment.
2. Branch representation lineage and record transformation, invariants, failure modes and assumptions. Fork finite candidates into new seeds.
3. Select eight operator families: symmetry, coarsen-refine, active set, exact neighborhood, multistart, relax-repair, dual lower bound and adversarial mutation.
4. Freeze prediction, discriminating outcomes, operator, representation, contract, seed and budget before execution. Compute a preregistration SHA-256 digest.
5. Run a reproducible finite *cyclic-overlap toy* in the browser, with exact integer A and separate same-package exact integer B arithmetic plus corrupted-claim negative control. A second arithmetic path is **not** an independent external agent.
6. Create pending external experiment manifests for the Werner, phase retrieval, SourceBound and Sidon programs. GitHub Pages cannot execute these programs' Python, Arb or Sage tools.
7. Export a ZIP containing the contract, representation lineage, operator registry, experiments, verification results, Markdown handoff and SHA-256 manifest. Export/import the complete JSON workspace.

## Exact toy specification

Let a binary cyclic sequence have n cells and mass m. For every nonzero cyclic shift k, count c(k), the number of ordered pairs whose difference is k modulo n. Minimize the maximum of c(k). The exact identity summing these counts across k yields m(m-1), hence the maximum is at least ceil(m(m-1)/(n-1)). Generator A counts pair differences; verifier B independently loops over shifts. Both use integer arithmetic.

**Boundary:** The cyclic toy objective is a different mathematical problem from the continuous signed-shift overlap objective of EA #36. A passed toy test has no bearing on the reported 131,072-cell continuous-overlap record.

Run the pure-kernel regression with:

    node scripts/test_discovery_core.cjs

Website CI additionally tests the interactive experiment and ZIP download at three browser widths.

## Release and security scope

Browser data persists in localStorage without encryption; keep credentials, secrets and unpublished private data outside the interface. Importing a workspace leaves its claims unverified. Local preregistration hashes provide integrity for exported snapshots, not immutable public timestamps.

For independent scientific certification, freeze source and inputs first, then commission a separate reproducer, adversarial auditor and formalizer under the existing AGENT_VERIFICATION_PROTOCOL.md. Exact finite checks, analytic reductions, imported source premises, publication novelty and competition eligibility remain separate gates.

The scientific runner adapter, distributed agent execution, signed remote receipts, immutable external storage and repository synchronization are future integrations; this version does not claim those features.

## Local scientific worker

From a repository checkout, validate an exported package:

    python3 research/nightfall/discovery-engine/runner.py PACKAGE.zip --plan-only

Execute only the fixed allowlisted scientific checker scripts and record a scoped result:

    python3 research/nightfall/discovery-engine/runner.py PACKAGE.zip --out receipt.json

The worker validates ZIP SHA-256 hashes and preregistration digests, executes source-controlled scripts in a temporary directory, captures source and output hashes, and records logs and exit codes. Optional Python dependencies such as sympy require a locally provisioned environment. Each receipt explicitly retains the imported-premise and independent-agent gates. Run the worker test harness with python3 scripts/test_discovery_worker.py.


## Adaptive resolution: Cartesia H-Net research synthesis (2026-10-28)

The [adaptive abstraction design](ARCHITECTURE.md) extends the existing representation studio and coarsen/refine operator portfolio. It treats **chunk boundaries and granularity as first-class representation decisions**, preserves byte-exact source identity, and forces resegmentation at counterexamples, changed active constraints, and source-attribution boundaries. Cartesia's work motivates the hierarchy, while NIGHTFALL retains its stricter raw-data/independent-checker certificate gate.

- [Exact two-stage segmentation reference implementation](adaptive_resolution.py): injectable context-dependent boundary scores, forced evidence splits, SHA-256 per chunk, lossless reconstruction, parent-child coverage checks, resegmentation after a verifier failure.
- [Seven engineering regression tests](test_adaptive_resolution.py): 299 randomized binary inputs, empty source, Unicode bytes, failure-driven split, segmentation-invariant raw checking, stale hash rejection, invalid boundary and adversarial mutation controls.

```bash
cd research/nightfall/discovery-engine
python3 -m unittest discover -v -p 'test_*.py'
```

**Integration state:** The Python module is an experimentally validated **deterministic baseline**, rather than a trained H-Net. It is currently separate from the browser's JavaScript optimizer and from the scientific worker's allowlisted scripts. The browser representation studio links its design and remains the entry point for operator selection. Future adapter work will map EA #36 raw cells/contact events and SourceBound evidence spans into this shared raw-atom contract, then compare constant, heuristic, frozen learned, and jointly trained boundaries at identical discovery compute budgets.

**Research metric:** compute per independently replayable certified result and downstream transfer. The Cartesia language-model compute multipliers are external findings, and no analogous NIGHTFALL gain has been measured.

Primary sources: [Cartesia H-Net Part I](https://www.cartesia.ai/blog/from-tokens-to-bytes-part-1), [Part II](https://www.cartesia.ai/blog/from-tokens-to-bytes-part-2).

## Stage 2 — Granularity as an optimized experimental coordinate (2026-10-28)

The scientific worker now accepts the **Adaptive granularity study** environment. It executes the bounded paired study using its source-controlled `granularity_study.py`, `granularity_oracle.py`, and `adaptive_resolution.py` modules, then exports a hashed results receipt.

The study compares **atomic**, **fixed**, **event-adaptive heuristic**, and **trained discrete policy-selection** schemes. The training selector jointly searches fine chunk budget, edge-trigger strength, and coarse grouping width, using exact *training* outcomes as its objective. Held-out cases are generated from distinct frozen seeds. Each arm receives identical candidate pools and the same count of independent exact oracle calls.

Two proxy domains are included: binary *cyclic* overlap and source-span support with immutable trust boundaries. These are **synthetic engineering benchmarks**, with no claimed transfer to continuous EA #36 or real-world SourceBound effectiveness. The independent atomic oracle reconstructs the original byte atoms for each accepted result. Every policy is checked for lossless reconstruction and trust-boundary preservation.

### Run the complete matched-budget study

```bash
python3 -m unittest discover -s research/nightfall/discovery-engine -p 'test_granularity_study.py'
python3 research/nightfall/discovery-engine/granularity_study.py --seed 1729 --train 12 --test 12 --output granularity_results.json
```

The GitHub website verification workflow runs the exact tests and this study, writes the result SHA-256, and publishes its report as a downloadable workflow artifact.

A saved browser workspace can select **Adaptive granularity study**, set its training/test counts and seed, freeze the experiment, export the ordinary 8-file research ZIP, and send it to the allowlisted local scientific worker:

```bash
python3 research/nightfall/discovery-engine/runner.py PACKAGE.zip --out receipt.json
```

The worker restricts the configurations to training/test sizes 3–32 and a 32-bit random seed, and signs no scientific validity beyond its stated exact finite scope. Its package receipt hashes the benchmark's generated JSON.

### What this establishes

The implementation establishes downstream-supervised *discrete selection* of representation boundaries and a matched evaluation protocol. It is **not** Cartesia's differentiable end-to-end boundary network. The measured compute model records coarse scoring operations and exact calls separately; training/segmentation overhead and elapsed time must be included for any systems-speedup claim. Third-party independent replay, natural-web held-out trials, and continuous-overlap validation remain separate gates.

### 2026-10-28 adversarial correction — proxy-label isolation

An initial diagnostic implementation used the same raw binary support labels for candidate ranking and exact source-span adjudication. That admitted label leakage: apparent 96/96 valid SourceBound proxy selections could reflect direct exposure to ground truth. The result has **no standing as external transfer evidence**.

The revised benchmark uses *observable noisy source cues* for boundary routing and coarse selection, and a separately generated *hidden atomic support annotation* for exact adjudication. Training labels are available only through the downstream training outcome; held-out annotations never enter boundary construction or selection. Reported per-case hashes distinguish observable source bytes from annotation bytes. A negative-control test flips every hidden annotation label while holding observable bytes fixed and verifies that all candidate-selection traces remain unchanged. This fixes the demonstrable direct-leakage path; real-world transfer remains untested.

All comparative results must use the latest corrected `granularity_study.py` and its SHA-256 report. Earlier unisolated source-proxy numbers are diagnostic and superseded.

### Search-space correction

The first selection grid omitted the fully atomic representation. The corrected 19-option grid explicitly includes it. The trained policy therefore may choose uncompressed input when that wins the preregistered exact downstream gain objective. Comparisons against restricted 18-option reports must remain labeled diagnostic. A selected policy is a training-instance optimum within the stated discrete grid, never a global mathematical optimum.
