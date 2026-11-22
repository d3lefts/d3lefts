# NIGHTFALL controlled agent-interface A/B evaluation — preregistration

**Frozen plan:** 2026-11-22, before collecting comparison results. Branch `research/agent-contract-ab-measurement-20261122` is based on current main containing merged #1051. Exact CI source commit will be included in the result artifact.

## Objective and target
Determine whether the new `just`/allowlisted Python/Nushell agent operating interface decreases **warm orchestration runtime** or **false-acceptance of deliberately invalid verification metadata**, relative to invoking the *same existing authoritative Python checker directly*. The objective is a process improvement, not a mathematical theorem, novel algorithm, or proof certificate.

## Feasible set, controls, competing hypotheses
Three role-isolated GitHub Actions jobs: constructor, independent-reproducer, auditor. These are **three runner-role simulations, NOT three autonomous mathematical agents**. All run on the same pinned repository commit, with identical test inputs and fixed commands. Within each job, for each of three existing checker families—`passport`, `compiler-lock`, `differential-guards`—run eight interleaved, deterministically randomized rounds of four execution paths:

1. **Legacy**: direct `python3 scripts/<existing-checker>.py <original arguments>` (existing source of truth).
2. **Python contract**: `python3 scripts/nightfall_agent_tasks.py run <task>`.
3. **just contract**: `just --quiet <task>` (calls exactly the same Python dispatcher).
4. **Nushell**: `nu -c 'use ...; task-run <task> | to json -r'`.

External just/nu binaries are installed **once before measurement**. Benchmarks time process launch, dispatcher, direct verifier execution, parsing, and exit status. They **exclude tool installation/checkout/cache warmup**; CI action step timestamps are separately inspectable. For each trial record monotonic duration (ns), task, mode, role, exit code, SHA-256 of outputs, and whether the pipeline preserved the direct checker's output digest. Do not infer agent thinking-time savings from CLI milliseconds.

**Predictions:** The extra process layers may make contract and Nushell runs *slower*, despite reduced human instruction/parse ambiguity. No speed benefit is presumed. Similar-source repeated trials address run noise; three runner roles address hosted-runner variation, not scientific independence. Initial side-by-side evidence may show no meaningful gain or a cost.

## Preregistered evidence and decision threshold
Compute per task/role/mode median and a ratio against that same task/role direct legacy median, plus median of per-round ratios. Aggregate over roles without treating trials as independent agent contributions. Report complete machine-readable raw records and SHA-256 artifact hashes. The **same subprocess success and identical verifier-output hash** must be seen across all modes for an equivalence claim.

Decision gate for *runtime overhead reduction*: contract median < direct median on each role and at least 20% pooled wall-clock reduction for at least two of the three checker families. Otherwise report overhead unchanged/increased; distinguish the alternative productivity benefit of having a canonical task menu.

## Mistake controls and observer effects
Positive controls: every mode runs the source checker and preserves its output; Python and Nu contract receipts must report `mathematical_theorem=false`, `independent_semantic_audit=false`, `global_priority=false`.

Negative mutations (separate from timed tasks): forged `mathematical_theorem=true`; dishonest PASS/FAIL status; invalid Git head; bogus role; and replacement of a well-formed 64-digit output hash with another well-formed hash. For each mutate a *fresh* receipt from the current runner. Run the Python and Nu receipt-verification front ends; count rejection/acceptance. The last mutation deliberately probes a **known scope limit**: `verify` currently validates receipt *structure* but has no external output bytes, so it may accept a syntactically valid incorrect digest. If so, record a reproducible limitation rather than mislabeling it a mathematical error.

A direct legacy checker has **no receipt API**. It can be compared on command failure/success and output equality, but not on detection of forged receipt fields. We cannot compute “mistakes prevented versus baseline” for categories baseline does not represent. No true new mathematical proof error rate is measured without a separate, blinded claim-review study.

## Strongest source checked
- Merged [#1051](https://github.com/d3lefts/d3lefts/pull/1051), commit `2b814d26443c6781d281b7ff817339269c266a5d`; source `scripts/nightfall_agent_tasks.py`, `justfile`, `task-interface.nu`, `.github/workflows/nightfall-nushell-agent-pilot.yml`.
- Existing independent gate `scripts/check_proof_passport_v2.py --self-test`, as well as the compiler-lock and differential-guard self-tests.
- Source-pinned execution is via `actions/checkout`, `extractions/setup-just` and `hustcer/setup-nu` action commit hashes already used in #1051.

## Independent audit and stop rule
The measurement script must not import `nightfall_agent_tasks.py` or copy its `verify_receipt` implementation. It independently specifies source checker commands and parses outputs from its public JSON interface. CI must fail closed if any source checker fails, a mode silently skips a checker, or output digests disagree. Different runner jobs produce separate immutable log artifacts; aggregate only after all three pass.

Stop after eight rounds/role/task unless an integrity failure occurs; on integrity failure investigate and version the test, do not silently discard failures or rerun until results look favorable. If source mismatch, invalid flags, or false green appears, preserve it as a counterexample and propose a separate fix. All performance numbers are **process-layer results only**, not proof of multi-agent speedup or lower real-world certification-error rate.

## What remains open
Blinded, cross-instance study of actual theorem review cycles using matched source problems, randomized routing and independent non-author graders. A PR history comparison without randomization is observational and confounded. No multi-agent effectiveness claim until that separate gate passes.

## Amendment A1: harness invocation correction, before data collection

Initial CI run [45057145126](https://github.com/d3lefts/d3lefts/actions/runs/45057145126) terminated in all three jobs with JSONDecodeError before producing any role measurement artifacts, because the benchmark used `just --quiet <task>` and then required task stdout. The documented baseline command catalogue uses `@` recipes already (preventing echo); the benchmark now calls `just <task>` so the task receipt is visible, with diagnostics identifying which mode returns invalid JSON. All 3 roles, 3 tasks, 4 modes, 8 repetitions, randomization seeds, timing statistics and mutations remain unchanged. This is an interface-harness repair, **not** exclusion of an inconvenient outcome. The original failed CI remains accessible.
