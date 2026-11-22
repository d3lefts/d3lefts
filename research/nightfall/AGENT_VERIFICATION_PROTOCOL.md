# NIGHTFALL autonomous verification protocol — version 1

**Operating model:** Independent *agents* are the verification workforce. Each claim is checked by an adversarial agent, an independent reconstruction agent, and, where feasible, a proof-formalization agent. These are distinct tasks with distinct outputs. No claim is accepted solely because several language models agree.

## Shared agent command contract (2026-11-22)

The implementation is [COMMAND_CONTRACT_V1.md](agent-operations/COMMAND_CONTRACT_V1.md): static `just` recipes call an allowlisted Python dispatcher; Nushell is preferred for structured orchestration where installed. Standardize **task names and evidence receipts**, not the language used by scientific constructors or independent checkers. The dispatcher is never a Lean theorem prover, an independent-audit authority, or a priority certifier. After the November 22 A/B tampering test, a source/output provenance assertion requires the explicit `python3 scripts/nightfall_agent_tasks.py replay <receipt>` or Nushell `task-verify` gate against the *same clean checkout*. Structural-only `verify` / Nu `task-structure` must not be treated as source attestation. Replay reuses the original checker; it does not count as independent mathematical verification. A reported task PASS is valid only for its explicitly labeled metadata/control scope. Audit agents must independently reconstruct proof and computed claims using original specifications, not a copied producer program.

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


## Exact staged differential formalization (4CT-inspired, v1)

**Provenance of the method.** This refines NIGHTFALL's existing independence
contract using the reproducible staged computer checks from Inoue,
Kawarabayashi, Miyashita, Mohar, Thomassen and Thorup,
[arXiv:2603.24880v3](https://arxiv.org/abs/2603.24880v3)
and the published [C++](https://github.com/near-linear-4ct/computer-checks),
[specification-only Python](https://github.com/near-linear-4ct/computer-checks-by-Claude-Code),
and [Rust/Lean](https://github.com/kfl/4ct-checks-rust-lean) checking
efforts. The later [arXiv:2610.39753v1](https://arxiv.org/abs/2610.39753v1)
supersedes the first paper's O(n log n) algorithmic complexity claim,
but not the staged verification lesson. These are credited precedents,
not source code imported into NIGHTFALL.

For a theorem whose proof relies on an exact finite enumeration, a
computationally decided lemma, or a program-generated certificate:

1. **Freeze the mathematical contract first.** Record the exact version of
   the paper/proof, enumerated lemma labels and dependency DAG, input format,
   mathematical quantifiers, theorem statement, and hashes of raw inputs.
   Independently reconcile the paper version against the code: a port of a
   v2 pseudocode appendix is not automatically a checker for v3.
2. **Build from the *specification*, not another program.** Give a reproducer
   the mathematics, published input format, and frozen data, but not reference
   implementation internals, intermediate arrays, or expected answers. Record
   authorship, access and implementation lineage. A port that mirrors a C++
   source file is useful differential evidence but is not specification-only
   independent reconstruction.
3. **Keep stages inspectable.** Provide one executable command, source SHA-256,
   exact input SHA-256, canonical output and output SHA-256 per stage. Match
   stage labels to source lemmas; require complete coverage and resolve
   upstream-stage failures before relying on downstream results.
4. **Compare exact objects, not headlines.** For portable finite outputs use
   sorted-key, compact UTF-8 NDJSON with a trailing newline and exact integers
   or rational strings (never floating-point JSON). Compare full output bytes,
   record counts and hashes across at least one reference and one
   specification-only implementation. If exact canonicalization is not
   feasible, write a new format contract and a separate sound comparison
   proof; a tolerance-based numerical match is not a byte-identical check.
5. **Formalize the *checker theorem*.** Where Lean is used, state the
   mathematical proposition the program or certificate encodes, then prove
   checker soundness (accepted certificate => formal property), coverage or
   completeness of the finite case family, and the source-theorem bridge.
   State all three obligations separately. A proved parser/homomorphism
   subroutine or successful Lake build does not close the surrounding theorem.
6. **Attack the evidence gate.** Include source-byte tampering, dropped
   cases, duplicate implementations, shared lineage, version drift,
   noncanonical serialization, count mismatches, arithmetic overflow,
   and unequal outputs among negative controls. Reviewer independence and
   semantic equivalence cannot be established by assertions in a manifest.
7. **Report certificates by scope.** Distinguish byte-level differential
   replay, independent code audit, exact finite coverage, mathematical
   semantics, named-declaration kernel checks, and human or prior-art review.
   Never promote any of these statuses automatically.

### Shared differential evidence gate

For new finite computational-lemma families, run:

```sh
python3 scripts/check_formalization_differential.py --self-test
python3 scripts/check_formalization_differential.py \
  --manifest path/to/versioned-evidence.json --root .
```

The versioned manifest schema is
`nightfall.formalization-differential/v1`, with required
`source {identifier,url}`, `specification {path,sha256}`,
`inputs [{path,sha256}]`, `required_stage_ids` and corresponding
`stages [{id,paper_lemma,depends_on,implementations}]`.
Each stage has two or more `implementations`: a `reference` and a
`spec_independent` checker, **distinct declared lineages**, separate
hashed checker files, replay `command` arrays, hashed canonical NDJSON
`output` files and exact `records` counts. The mandatory
`claim_boundaries` map has four `false` values:
`independent_code_audited`, `formal_semantics_proven`,
`full_theorem_certified`, `external_peer_review`.

The checker rejects byte-identical checker files even when stored at different
paths, and rejects shared output paths masquerading as independent output
artifacts. These are necessary but not sufficient independence controls.

The checker runs 18 adversarial self-test controls, checks actual file
bytes and complete stage outputs, and fails closed on mismatches. **It
does not execute the listed producer commands**; run and record those
separately. It does not authenticate GitHub logs or prove independent
development, enumeration completeness, mathematical semantics, or a
theorem. A complete formal certificate therefore needs a separate
pinned Lean theorem contract, verified terminal declaration, source-
theorem correspondence review and any external mathematical premises.
Do not retroactively revise or promote older passports.

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

## Additional judgment-provenance gate (JP-01; proposed, unvalidated)

A correct calculation does not reveal who selected the assumptions, endpoint or interpretation. For any consequential choice with two defensible analyses, the Proof Passport should retain: (i) the analyst's time-stamped provisional choice **before** seeing the favored recommendation; (ii) origin and model of each proposal; (iii) an independently prepared opposing case that has not been exposed to the favored conclusion; (iv) the final decision with reasons and attribution; (v) declared shared model/prompt/source dependencies. Label this `JUDGMENT_PROVENANCE_RECORDED` only when records exist; label `JUDGMENT_INDEPENDENCE_UNTESTED` when they do not. This information supplements rather than replaces mathematical replay, proof checking, and independent human oversight.

The [Judgment Provenance experiment](projects/judgment-provenance-2026-10-29/README.md) defines a randomized three-workflow test of agent-preference influence and a separate methodological-quality preservation gate. The proposed protocol is **not a completed study, a certified intervention, or an Original Finding**. Synthetic unit tests prove only that the proposed data-analysis checker obeys its documented arithmetic contract.

## Privacy and safety

Only public research artifacts may be processed by external services. Logs, prompts and receipt text must omit credentials, private workspace records, personal identifiers and unpublished account data. Refuse any upload/release workflow that exposes those items.

## Public claim language

Use `source-reported`, `independent-algorithm internal replay`, `CI replay after public release`, `machine formal proof` and `conditional source premise` as distinct descriptions. A published issue is an invitation, never a verified result by itself.
