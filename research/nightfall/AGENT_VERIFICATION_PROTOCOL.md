# NIGHTFALL autonomous verification protocol — version 1

**Operating model:** Independent *agents* are the verification workforce. Each claim is checked by an adversarial agent, an independent reconstruction agent, and, where feasible, a proof-formalization agent. These are distinct tasks with distinct outputs. No claim is accepted solely because several language models agree.

## Core rule

The machine-checkable artifact is the result. An agent's verdict is a routing suggestion unless its decisive claim is supported by executable deterministic verification, an explicit formal proof checked by a kernel, or a complete falsifying counterexample.

### Independence contract

- Freeze the target claim and original source digest *before* handing it to any agent.
- **Reproducer:** receives the claim and original inputs, but not construction code, previous answers, expected intermediate arrays, or source checker internals. It writes a fresh verifier.
- **Adversarial auditor:** receives assumptions and proof text; hunts for counterexamples, invalid quantifiers, missing hypotheses, numerical vulnerabilities, and discrepancies with published work. A failure report must include a reproducible concrete witness when possible.
- **Formalizer:** reconstructs each implication in a proof assistant, or supplies a precise list of unproved lemmas and their dependencies. A compilable declaration with an `axiom`, `sorry`, an oracle, or imported target-equivalent hypothesis does not count as a complete proof.
- Use separate execution environments and seed material, independent source and checker commits, and no hidden reliance on the source author's precomputed result. Separate models alone are insufficient.
- The coordinator compares **artifacts**, never votes. Disagreement produces an `INCONCLUSIVE` status until resolved.

### Result fields

Every run must publish:
1. Claim ID and frozen source commit, precise theorem or finite objective and conventions.
2. Agent role, implementation/model version and toolchain, exact prompts and non-secret run configuration.
3. Original input hashes plus independently produced source/checker hash, executable commands, output and environment.
4. The checker’s mathematical scope: finite arithmetic, all real-shift analytic bridge, source SDP premise, full theorem, etc.
5. `PASS` / `FAIL` / `INCONCLUSIVE`, exact rational output or interval, and minimal counterexample if applicable.
6. Known dependencies and limitations, including mismatched assumptions, missing archival inputs, and possible source leakage.
7. Date and a reproducible receipt committed as a report under `research/nightfall/agent-reports/`.

### Verdict gates

| Verification gate | Examples | What success means |
|---|---|---|
| Input integrity | Release hashes, ZIP entry counts and CRC | The exact frozen bytes were received. |
| Finite exact reproduction | Independent bigint integer convolution vs source six-prime NTT | The specified finite upper-bound certificate is reproduced. |
| Analytic reduction | Exact proof the continuum extremum reduces to tested shifts | The bridge from finite arithmetic to the claimed continuous problem is supported. |
| Imported source premise | Independent interval/SDP/analytic source reconstruction | The conditional theorem's upstream hypothesis is independently established within checked scope. |
| Formal proof | Kernel-checked theorem without undeclared axioms or gaps | The theorem statement follows from explicitly listed accepted premises. |
| Novelty / competition | Dated prior-art and official accepted result matching fixed conventions | A separate historical record claim is supported. |

Passing one row **never** silently passes another. For the Erdős construction, the new big-integer replay is a finite exact check; the real-shift reduction and current prior-art comparison are separately auditable.

## Four initial assignments

- **EA-36-FINITE-131072:** reproduce the frozen witness using a different convolution mechanism, verify hash, mass, box constraints, every signed shift and exact rational supremum. [Agent task / issue #1](https://github.com/d3lefts/d3lefts/issues/1). The publicly uploaded master archive is a dependency for independent external execution.
- **WERNER-QUTRIT-6-9:** independently reconstruct exact rational polynomial identities and correlated spectator; separately audit original four-/five-copy SDP inequalities. [Issue #2](https://github.com/d3lefts/d3lefts/issues/2).
- **PHASE-RETRIEVAL-LLL:** audit all-signals probability, bit complexity, field hypotheses and a fresh decoder; reconstruct without relying on prior agent proof text. [Issue #3](https://github.com/d3lefts/d3lefts/issues/3).
- **AGENT-SAFETY-AXIOMS:** independently formalize and break the oversight/authorization theorem series, especially restricted policy classes and Horn reductions. [Issue #4](https://github.com/d3lefts/d3lefts/issues/4).

## Reproducible implementation now committed

- [Big-integer exact reconstruction](../../scripts/verify_erdos_independent.py): self-contained Python verifier of the 131,072-cell witness, using a separate convolution algorithm, independently compared against the frozen file in the research session.
- [Frozen release gate](../../scripts/verify_frozen_release.py): validates both ZIP SHA-256 values, ZIP CRC and entry counts, extracts only the canonical nested witness, and runs the independent big-integer verifier.
- [Release-triggered GitHub Actions](../../.github/workflows/verify-frozen-release.yml): once both original archives are uploaded, GitHub CI downloads the public assets and checks their immutable hashes and exact witness without additional manual steps.

This currently establishes a functioning **deterministic verification lane**, not a fleet of independently provisioned LLM agents. Agent prompts and task IDs here make additional autonomous reviewers reproducible once connected. Neither the deterministic lane nor an agent verdict constitutes human peer review; the objective is transparent machine-certified evidence.

## Privacy and safety

Only public research artifacts may be processed by external services. Logs, prompts and receipt text must omit credentials, private workspace records, personal identifiers and unpublished account data. Refuse any upload/release workflow that exposes those items.

## Public claim language

Use `source-reported`, `independent-algorithm internal replay`, `CI replay after public release`, `machine formal proof` and `conditional source premise` as distinct descriptions. A published issue is an invitation, never a verified result by itself.
