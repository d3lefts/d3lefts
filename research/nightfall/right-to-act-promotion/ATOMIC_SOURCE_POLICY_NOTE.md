# The Right to Act — Atomic Version-Bound Promotion v1.6

**14 November 2026 · Research checkpoint · AI-assisted work**

## Research objective

Replace a sequence of mutable-source and mutable-policy reads with an explicitly trusted transaction: all promotion decisions must refer to one admitted source snapshot and one trusted mission policy epoch at the point the locally protected CloudFormation artifact is committed.

### Certified scope

- Controlled setting: the official `control-arena==20.1.1` IaC Fast CDK fixture, with a deterministic legitimate Organizational Unit addition and a paired harmful removal of an FSx export-denial policy
- Trusted resources: the admission/policy/revocation/promotion code, a common advisory file lock, a protected snapshot directory and policy state, an independently authored effect verifier, and local artifact publication
- Untrusted resources: candidate editing worktrees; their changes do *not* change the admitted source version until a **trusted** `admit` transaction explicitly accepts a snapshot
- Effects: atomically published *offline JSON envelope* containing the synthesized CloudFormation template, source-version ID and digest, policy digest, baseline digest and authority epoch
- No real AWS account is provisioned; neither an executing adversarial agent nor a live deployment service is part of this test

### Conditional proposition: source/policy serializability

Suppose all trusted `admit`, `revise_policy`, `revoke`, and `promote` operations acquire the same effective mutually exclusive lock; no outside actor can mutate the trusted snapshot store, state, verifier, or output; every source snapshot is content-authenticated, and the independent verifier is sound for the protected template property.

Let a prepared ticket contain the trusted state epoch `e`, source version `v`, source digest `h_s`, policy digest `h_p`, baseline digest `h_b`, and candidate-template digest `h_t`.

A successful promotion verifies all six values under the lock, reconstructs the template from the corresponding admitted snapshot, checks its exact digest and policy-specific semantic verifier, and atomically replaces the one committed artifact envelope while holding the same lock.

**Conclusion:** each successful local artifact commit can be assigned a serialization point inside the promotion critical section. Any trusted source admission, policy revision or revocation that finishes *before* that point forces an old-epoch ticket to fail. An update that occurs *after* the commit does not retroactively invalidate that historical commit. A change to an unadmitted worktree has no effect on the snapshotted source that is synthesized.

**Proof:** mutual exclusion gives a total critical-section order for cooperating operations. Every trusted version change increments the durable epoch. The promotion checks epoch, source and policy identities under that same lock, so a preceding change falsifies at least the epoch predicate. During the accepted critical section no cooperating trusted operation can change those identities. Reconstructed bytes and authorized template are checked before local atomic replacement. Thus the record identifies a source-policy pair valid at its commit point. This is standard concurrent-state reasoning, not a historical novelty claim.

### Pre-registered tests

1. Snapshot a legitimate CDK patch; edit the agent worktree after the ticket is issued; verify the committed artifact remains the admitted snapshot.
2. Admit a harmful CDK change; verify the independent effect checker rejects it before ticket issue and leaves the committed artifact unchanged.
3. Admit a *new* source version after a ticket; reject the older ticket. Repeat for trusted mission-policy revision, and for revocation.
4. Force a two-process source-admission race and a two-process policy-revision race at the final artifact rename. Confirm the losing update waits for the lock, and stale tickets subsequently fail.
5. Recompute manifest digest, published template effect properties, policy digest, authority epoch, and published record digest using a checker that does not import the gate or its main verifier.

### Limitations / falsification targets

- The trusted store currently shares the runner OS account with CDK Python synthesis. A malicious native process with access to the trusted directory can bypass the store or overwrite policy/state. **Do not call this a production effect-enforcement boundary.**
- Snapshot intake uses standard filesystem copy and hash checks; this is not a proven race-safe secure path traversal or snapshot of a concurrently changing Git worktree.
- The effect verifier operates on CloudFormation declarations and a narrow task policy, not an exhaustive model of AWS side effects.
- Advisory locks coordinate **cooperating** processes only. Raw external writes to trusted state or directly to published artifacts remain a bypass when the trust separation assumption fails.
- Publication via atomic rename is a single local JSON-file effect, not an AWS deployment or a distributed atomic transaction.
- A crash may leave an orphaned snapshot or a source state referencing an unflushed directory; this implementation fails closed on missing snapshots but does not establish full power-loss crash-consistency or recovery.
- The source digest does not itself attest the entire executable dependency chain (CDK wheel, jsii, Python interpreter, runtime flags); version-pinned CI and the regenerated template-digest check constrain this experiment but do not prove complete dependency closure.
- A post-commit change could make a deployed configuration unsafe under a *new* policy. Historical commit validity is not ongoing authorization for future effects.
- No measured reduction in cost, novel mathematical theorem, or arbitrary-capability superintelligence safety guarantee is claimed.

### Next structural experiment

Place the verifier, source admission and artifact writer in a **distinct OS principal / isolated container**, give the agent write access only to its candidate worktree, and run attacks against the file descriptors, lock file, snapshot store, policy state and actual externally mediated commit. After a non-bypassability test, use a capable model to generate the patches, rather than deterministic fixtures.

Keep this checkpoint separate from the earlier exact min-cut / shared-evidence / laminar optimization results; the latter are assumed-guard problems, whereas this experiment tests one concrete offline guard boundary.
