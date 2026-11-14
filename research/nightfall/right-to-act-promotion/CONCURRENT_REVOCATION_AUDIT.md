# The Right to Act — Concurrent Revocation Audit (v1.5.1)

Date: 2026-11-14. Status: deterministic counterexample to the original local prototype; independently testable scope-limited repair. No new mathematical priority or production/cloud containment claim.

## Baseline defect (original PR #499 prototype)

The original `promote` read `self.blocked` and `self.epoch` before synthesizing and before `os.replace`. In contrast `revoke` wrote those two process-local fields without acquiring the publication file lock. A deterministic execution schedule exists:

1. `promote` takes a `flock` and sees no revocation.
2. `promote` verifies the proposal and prepares a staged CloudFormation artifact.
3. `revoke` returns after updating its local fields.
4. `promote` executes `os.replace` and returns `True`.

Local reproduction observed **revoked=True**, **published=True**, **promote_ok=True**, and a revocation invoked immediately *before* the artifact replacement. This falsifies a claimed common serialization order for revocation and publication. The prior sequential CI was valid but did not cover this interleaving.

## Repair and proof obligation

Trusted state is moved to a persistent JSON record in the trusted output directory (`authority_state.json`) containing `epoch`, `revoked`, and `baseline_hash`. Gate initialization, ticket epoch capture, publication, and revocation all acquire the *same* exclusive `flock` (`promotion.lock`) before accessing the trusted state. State updates are atomically replaced and fsynced. The commit result template is also atomically replaced and fsynced.

**Conditional linearization lemma.** Suppose every authority-state change and every protected artifact publication by cooperating processes occurs while holding the same exclusive lock; the lock is effective and the trusted state/output directory are not externally editable. Then each `promote` and `revoke` operation is serializable by lock acquisition. If `revoke` acquires the lock before `promote`, the latter rejects on the durable revoked state. If `promote` acquires first, its local publication may succeed, and revocation becomes effective afterward. This does **not** imply an in-flight promotion is cancellable at arbitrary times: concurrent operations may linearize in either order.

**Independent test:** `test_concurrent_authority.py` tests cross-instance durable revocation, state baseline mismatch, corrupted authority state, and a deterministic two-process critical-section interleaving. Existing 8 verifier checks continue passing; **12 local tests passed** in Python. PR CI must separately pass before calling this GitHub-certified.

## Remaining gaps / next negative controls

- `fcntl.flock` is advisory; external processes must cooperate and the trusted directory must prohibit agent writes. The test is not an operating-system confinement proof.
- Candidate source and mission policy remain externally mutable outside the lock. A malicious process can modify either after its last hash read but before publication; robust source-bound authorization must promote an immutable, content-addressed snapshot or use a trusted source-version compare-and-swap.
- The local published template is not an actual AWS CloudFormation deployment. A production backend requires independent enforcement at the cloud API or change-set execution boundary, with separately verified credentials and version binding.
- The effect verifier assumes AWS CDK synthesis and `Resources` diff adequately capture the intended typed policy effects; this does not establish full AWS IAM semantics or network consequences.
- Final artifact replay can verify template content but cannot reconstruct unlogged prior revocations/source races from only the final file. An append-only authenticated event log and a separately checked event-order witness are further requirements.

## Reproduce

`python -m pytest -q test_effect_verifier.py test_concurrent_authority.py`

No network, cloud credentials, or model calls required. `promotion_runner.py` still exercises the source-matched official ControlArena fixture in the existing CI job; tests here isolate the race without conflating those two mechanisms.

## Additional independently reproduced write races (not fixed here)

A deterministic final-replacement hook in the *patched* local prototype mutated either (a) the candidate source after its last digest check or (b) the mission policy after its last digest check. In both schedules, `promote` returned success and the local template was published, even though the current source or policy digest no longer matched the ticket. This is **not** a failure of the lock's revocation linearizability theorem: source and policy writers were outside its synchronization domain. It falsifies any stronger claim of linearizable source/policy freshness against arbitrary external writers.

**Indistinguishability argument (standard TOCTOU).** For any protocol whose final source/policy inspection and publication are separate operations not serialized with all permitted writers, an adversarial writer can change an input after its last inspection but before publication. From the promoter's observed transcript the changed and unchanged executions can remain identical, so it cannot guarantee that every effect is justified by the source/policy current at publication. An atomic version comparison with the protected effect, or a trusted lock enclosing *all* relevant writers, is necessary for that guarantee; an immutable snapshot suffices only when policy semantics explicitly authorize the snapshot version irrespective of later changes.

Next engineering target: explicit trusted `source_version` and `policy_version` CAS in the promotion backend, with version changes and publication serialized against all authorized writers, and a negative control that modifies versions just before the commit. No general historical novelty claim (this is the classical check-then-use race).