# ProofGraph-Hard / Q2 shifted-c/4 research-integration task (v0.1)

**Status:** public development task. A passing reference replay is **not** a frontier-model success or a novel theorem.

## Mathematical target

Build the frozen Lean declaration:

`Nightfall.Polaris.ResearchQ2.locked_shifted_c4_interpolation`

For reals `a s c u e q`, assume

- `0 ≤ a`, `0 ≤ s`, `0 ≤ c`, `0 ≤ u`;
- `e = a^2 + s`;
- `e^3 ≤ u^2*q`;
- `q ≤ 3*e^2 - 2*a^4 + 4*a*c*s + c^2*s`.

Prove `Real.sqrt e ≤ Real.sqrt 3*u + c/4`.

The trusted theorem statement is in `NightfallPolarisQ2Target.lean`. A candidate may supply only `ShiftedC4Scalar.lean` with the established namespace and named theorem `Nightfall.ShiftedC4Scalar.shifted_c4_from_strong_moments`. It may import the evaluator-owned `ShiftedC4Bernstein.lean`, which proves the exact semialgebraic nonnegativity needed for the c/4 bound. The grader separately freezes and checks the target and Bernstein source by Git blob hashes; no theorem weakening or invented axioms are permitted.

## Mechanism being tested

This is a real constituent of the finite independent-product degree-two influence bound with coefficient approximately 107.3934499. Solving the missing proof requires a scalar normalization (e.g. `t = sqrt e`), small/large `t` split, scaling to the unit square, the imported Bernstein polynomial bound, exact fourth-moment algebra, and a positivity/squaring argument.

This task is different from re-proving a fresh open problem. The theorem already has a certified reference solution, so performance measures proof reconstruction/integration and debugging, not discovery priority.

## Trusted source and reference boundary

- Lean compiler: `leanprover/lean4:v4.36.0-rc2`
- Exact Mathlib commit: `9d581dfff2e41de989072ea63abf3daf69311520`
- Trusted Bernstein Git blob: `d29a1e5f0396ca7f29fde24a34325fc324a3d3c0`
- Trusted locked target Git blob: `7f0c86d5e6e04e0f6330f017aceff6bbb141c747`
- Original source reference: merged PR #558, `research/nightfall/formalization/observability/ShiftedC4Scalar.lean`, Git blob `c978b8343785911162fd1028c96be32a0c9de242`.
- As the reference solution lives in a public repository, this is **not a leak-resistant hidden benchmark**. True blind evaluation requires physically excluding the reference proof and internet access from an agent's workspace, plus provenance and contamination review. Merely deleting the proof from a Git checkout does not hide public training data.

## Public positive-control command

First use `.github/actions/setup-nightfall-lean` to create and verify `/tmp/mathlib4` with compiled pinned Mathlib cache. Then, in the repository root:

```sh
python3 research/nightfall/evals/polaris-research-20261119/research_q2/grade_research_q2.py \
  --candidate research/nightfall/formalization/observability/ShiftedC4Scalar.lean \
  --workspace /tmp/mathlib4 \
  --receipt /tmp/polaris-q2-reference-receipt.json
```

The reference is a deterministic positive control, not an agent benchmark run. The grader compiles the trusted Bernstein proof, the candidate scalar proof, and an independently frozen theorem target; performs the terminal axiom audit; and invokes `leanchecker` on the target object. Failure of any step is a hard rejection.

The Python harness does **not** sandbox Lean. Execute untrusted solutions only in an isolated, nonprivileged, network-disabled VM/container. This reference CI uses an ordinary hosted runner as a source-controlled positive control, **not** an untrusted-submission execution service.

## Benchmark eligibility and metrics

- Truth and proof check: exact Lean target; standard axioms only; trusted sources unchanged; no sorry; separate kernel replay. Binary hard gate.
- Blind evaluation: at least two independent agents, same source bundle, toolchain, tokens, time and money limits, withheld grader files and proof.
- Research process: log lemma proposals, failed constructions, operator-family changes, intermediate verifier failures, final receipt, tokens, time, and costs.
- Review: independent task-truth audit, independent checker implementation audit, and prior-art screening before claiming novelty or a competitive result.
- No public score, model pass rate, or research breakthrough should be inferred from the reference success.

## Sources / credit

NIGHTFALL finite-product Q2 C107 original-source Lean result: https://github.com/d3lefts/d3lefts/pull/558

Vals AI's Smoktunowicz gap-theorem Autoform-Hard analysis (2026-11-18): https://www.vals.ai/blogs/smoktunowicz-gap-theorem

Meta AutoformBench: https://github.com/facebookresearch/autoformbench
