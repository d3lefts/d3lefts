# NIGHTFALL — operational trusted-boundary obligations, v0.4

**Status:** measured assertions for a Linux local-artifact effect boundary. No real AWS deployment, physical actuator, or arbitrary multi-agent substrate is under this monitor. Lean proves an implication from trusted-boundary assumptions; this document records the separate evidence needed to *instantiate* that implication.

| Lean/model hypothesis | Actual source-matched integration evidence | Decision |
| --- | --- | --- |
| Initially safe baseline | Pinned ControlArena IaC Fast 20.1.1 CDK baseline, independent baseline/promotion effect oracles and negative controls | TESTED for specific CloudFormation fixture |
| Actual-state compatible with certified observation | Trusted admitted source snapshot + source, policy and baseline SHA-256 stamps checked; service checks signed ticket against authority state | TESTED for local artifact identifiers; NOT complete physical-state observation |
| Epoch current **at effect time** | Source/policy version and revoke handled by serial service; stale and revoked tickets denied by 10-event replay | TESTED for protected local JSON record |
| Accepted action admissible for all modeled effects | Independent CloudFormation policy verifier rejects harmful template even with valid signature | TESTED over specified fixture and negative controls; verifier semantic completeness NOT proved |
| All consequential agent effects mediated | Distinct service UID owns 0700/0600 store; untrusted UID cannot read key/write record, and Docker guest lacks host trust path, Docker socket and AWS credentials | TESTED for one local JSON effect; NOT established for AWS, other host paths, native root, network or physical effects |
| Rejected action has no effect | Test receipt observes committed digest unchanged after every tested denial | TESTED for local JSON record; no crash-fault atomicity guarantee |
| Environment preserves invariant | No actual external environment steps, other agents or real plant are included | UNVERIFIED / OUT OF SCOPE |
| Monotone, ABA-free, complete source changes | Trusted source and policy epoch updates and nonce replay tested; source admission includes snapshot digest and local updates | TESTED for participating trusted writers only; unregistered change channels NOT ruled out |
| Trusted code isolation and authentication | Kernel SO_PEERCRED, HMAC, separate UID, denied forged request, source matched Docker probes | TESTED against listed probes; privileged issuer/host kernel/Docker daemon remain trusted |
| Handler availability under one adversarial request | Kernel UID tested before parsing; all authenticated request parsing/evaluation and local persistence enclosed in a disposable worker with monotone 2s service deadline; timeout worker killed without blocking parent; response send capped | TESTED for idle/drip, expensive verifier and slow-persistence cases. No service-level availability under floods/scheduler starvation |
| Replay ledger bounded | At 256 accepted ticket nonces, service rotates epoch atomically before forgetting the old nonce set, so every old ticket is stale | IMPLEMENTED, with forced-small-cap finite regression; no unbounded-long-run model proof |

## Exact safety statement justified by integration

If the real-world effect is *exactly* the local service-owned JSON replacement, the trusted service account and key are uncompromised, Linux/FS semantics conform to the model, and all source/policy changes use this service, then the tested gate rejects the enumerated unauthorized and stale requests and only publishes templates admitted by the independent effect verifier. Other effects are **not** claimed to be protected.

The source fence theorem uses a separate explicit hypothesis: every unsafe permitted transition must produce a detectable, authenticated source-version change. The checker proves a missing-source counterexample is fundamentally unprotectable with version-only guards, even if all observed counters appear current.

## Critical timeout / transaction boundary

The timeout bounds how long a *single accepted* socket request can occupy the service loop, subject to kernel scheduling. It does not establish that a timed-out request rolled back: the worker can be killed immediately after an atomic rename. Clients must query current committed digest/epoch to reconcile. A service crash, kernel I/O hang, malicious trusted caller, or sustained flooding is not excluded from the threat model. The service uses a serialized, fsynced single-file replacement, not a consensus transaction or a cloud deployment.

## Stop/go gates for claiming actual autonomous-system safety

1. Define the real consequential effect interface (AWS API, orchestrator, actuator or multi-agent capability), and instrument every route to it. Demonstrate unauthorized direct-route attempts fail outside the toy JSON writer.
2. Authenticate current source snapshots, versioning and observations under independent agents and external changes, with negative controls for omitted change channels and ABA.
3. Check the actual effect relation or safety shield's soundness against downstream semantics (e.g. CloudFormation deployments and IAM rights), not only synthesized templates.
4. Introduce explicit environment-step and failure models, then prove or measure preservation of the stated invariant for those models.
5. Run an independent red-team campaign (kernel/service compromise, issuer tampering, crash during persistence, sustained flooding) and repeat the proof-to-implementation mapping after any material update.

**Certification disposition:** scoped local boundary validation, not trusted-boundary discharge for arbitrary physical, cloud, or superintelligent agents. No external human safety review or historical priority is claimed.

**Reproduction:** `bash research/nightfall/assurance/semantic-fencing-v0.3/run_all.sh`, pinned semantic-fence Lean workflow, and `right-to-act-controlarena-promotion.yml` on the exact PR head. Archive the exact source SHA, CI run IDs, positive and negative test receipts.
