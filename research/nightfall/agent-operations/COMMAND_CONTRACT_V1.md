# NIGHTFALL agent command contract v1

**Effective:** 2026-11-22. **Authority:** orchestration only. This is the
default command convention for new NIGHTFALL agent tasks. It does not migrate
existing checkers, permit automated proof promotion, or replace a non-author
mathematical audit.

## Quick start

From the repository root:

```sh
just --list
just preflight
just passport
just compiler-lock
just differential-guards
just research-archive
just lake-manifest
```

For machines without `just`, every command has an equivalent Python entry:

```sh
python3 scripts/nightfall_agent_tasks.py list
python3 scripts/nightfall_agent_tasks.py run passport
python3 scripts/nightfall_agent_tasks.py run compiler-lock
python3 scripts/nightfall_agent_tasks.py run differential-guards
python3 scripts/nightfall_agent_tasks.py run research-archive
python3 scripts/nightfall_agent_tasks.py run lake-manifest
```

The `justfile` is a **static menu**, not a generic shell-execution bridge.
The Python dispatcher owns a finite allowlist of existing trusted checkers.
Unknown tasks fail; no string from an agent is interpreted as a shell command.
`just preflight` runs the five commands, but its success is a **program
metadata/control preflight**, not a Lean build or a proof of any theorem.

## Preferred Nushell interface

Pin Nushell to version **0.117.0** for the pilot (CI pins the setup action
to commit `1b8faed9a8ff673c8ce0beae243e0b72d0787241`). Use it for typed
exploration, filtering and inspection:

```nu
use research/nightfall/agent-operations/task-interface.nu *
task-list | get tasks | select name scope
task-run passport | get execution
task-run compiler-lock --problem NIGHTFALL-PHASE --role auditor
```

`task-run` checks the external process's nonzero exit code via Nushell
`complete`, parses JSON only after success, checks receipt schema and
certification flags, and refuses silent failure. It invokes **the same
Python dispatcher** used by `just`.

`passport-preflight.nu` is a separate non-authoritative structured
view of Proof Passport v2; always keep the existing Python passport validator.

Nushell is preferred for interactive structured work, **optional** for
agent environments where it does not exist. Bash, Python, Rust, Node and
Lean remain valid where their respective checkers require them.

## Reproducible task receipt

A task run emits exactly one machine-readable JSON object on stdout
(`nightfall.agent-task-receipt.v1`). It contains:

- task ID and fixed command array, problem ID and **claimed** agent role;
- complete Git HEAD, dirty-worktree flag and SHA-256 anchor digests for the
  Python dispatcher, called verifier, and compiler lock;
- Python runtime version, limited verification scope, process exit code,
  timeout state, duration and SHA-256 digests/lengths of both process streams;
- separate false flags for mathematical theorem certification,
  independent semantic review and global priority.

A role field is a **claim**, not independent reviewer authentication.
Anchor digests are not an exhaustive list of transitive input hashes:
the Git commit identifies the checked-in repository tree, and a dirty
worktree disqualifies any claim of source-complete replay. The task receipt
does not store stdout/stderr bytes, so archive log streams separately
when exact output replay matters.

To preserve a result without overwriting existing evidence:

```sh
python3 scripts/nightfall_agent_tasks.py run passport \
  --problem NIGHTFALL-PHASE --role auditor \
  --receipt /tmp/nightfall-passport-receipt.json
python3 scripts/nightfall_agent_tasks.py verify /tmp/nightfall-passport-receipt.json
```

`verify` validates the receipt's internal **structure** and consistency.
It is not a cryptographic attestation, re-run, substantive verifier, or
independent review. Do not label it a proof certificate.

The measured [agent-interface A/B result](AGENT_CONTRACT_AB_RESULTS_20261122.md)
found that `verify` accepts 18/18 valid-looking but incorrect source/output
hash substitutions. To prevent that from becoming a false provenance
certificate, use the **strong local replay** command:

```sh
python3 scripts/nightfall_agent_tasks.py replay /tmp/nightfall-passport-receipt.json
```

This validates the receipt structure, requires the *current clean Git checkout*
to have the **same commit** and exact recorded source-anchor bytes, reruns
the same allowlisted verifier, and checks its exit status, output SHA-256
and byte lengths. Any source mismatch or output mismatch fails closed.
Nushell's `task-verify` now uses this strong replay path; `task-structure`
is the explicitly weaker offline-format inspection. Replays use the **same
checker source**—therefore a green result is reproducible process evidence,
not an independent mathematical proof, reviewer identity, or priority check.
External results from another commit cannot be replay-attested in a different
checkout; inspect their structure and retrieve the exact original source first.


## Certification authorities — unchanged

| Question | Authoritative gate |
| --- | --- |
| Is a theorem kernel-checked? | Pinned Lean 4.36.0-rc2 source build, exact statement, `#print axioms`, strict Lean bridge receipt, independent semantic review |
| Did a finite result replay exactly? | Frozen input and independent implementation with exact arithmetic/checker |
| Is evidence provenance sound? | Git source/blob hashes, Proof Passport v2, archived output artifacts |
| Is a research result original and significant? | Dated worldwide prior-art and independent specialist review |
| Did an agent orchestration command finish? | The task dispatcher receipt, **only** within its declared metadata scope |

Lean's existing per-theorem interface remains direct, not rewritten:

```sh
python3 scripts/lean_bridge.py PATH_TO_THEOREM.lean \
  --decl Fully.Qualified.theorem --strict \
  --contract PATH_TO_REVIEWED_CONTRACT.json
```

Use the repo's pinned toolchain setup and source-specific CI; never take a
PASS from `just compiler-lock` or `just lake-manifest` as kernel replay.
Existing exact checkers continue to be called from their original source;
the dispatcher currently exposes their **contract self-tests**, not the
substantive frozen-data replay of arbitrary submissions.

## Adoption controls, independent agents, and failure cases

For each task, share one frozen problem definition and exact source
commit. Have a constructor produce an artifact and a distinct auditor
reconstruct the checker from the specification. They may invoke the same
command contract, but **must not share their source-checker implementation**
where independence is required. Aggregate exact evidence and disagreements
in the corresponding proof passport. Never self-promote a PASS.

CI: `.github/workflows/nightfall-nushell-agent-pilot.yml` pins `just`
and Nu, runs all task contracts, compares Nu and Python structured results,
retains the original passport self-tests, and checks forged proof flags,
forged PASS status, bad source identifiers and duplicate passport IDs.
The controls test orchestration, not mathematical correctness.

Rollback a command on hidden exit failure, source mismatch, accidental
nonzero-to-PASS conversion, malformed JSON, altered checker scope or a
spurious proof-certification flag. Track time/setup benchmarks separately.
No performance gain has yet been measured: this standard is justified by
interface consistency and fail-closed behavior, not an asserted speedup.
