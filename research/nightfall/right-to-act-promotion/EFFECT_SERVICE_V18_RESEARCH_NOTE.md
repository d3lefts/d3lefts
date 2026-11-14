# The Right to Act — v1.8 Authenticated Local Effect Service

**Research objective.** Replace a direct host artifact-writer with a separate Linux UID authority service. The only authorized consequence in this experiment is one atomic replacement of a service-owned JSON deployment record, **not** a real AWS API call.

## Source matching

The exact upstream artifact comes from the **same GitHub Actions run**: the ControlArena IaC Fast 20.1.1 source is synthesized in a non-root, no-network Docker container. The independent host policy verifier accepts the legitimate Applied Interpretability OU change and rejects the harmful FSx-export-denial policy removal. The v1.8 service receives those same baseline/legitimate/harmful template bytes and the same-run published source, policy, and baseline digests.

## Trust and threat model

The trusted publisher runs as a **separate Linux service UID**. The trusted issuer is the GitHub job user; an adversarial caller is a distinct, nonprivileged OS user. The service directory is mode 0700 and contains a 0600 HMAC-SHA256 key and authoritative state. The trusted issuer has a separate key copy. The Unix socket is intentionally mode 0666: authorization must come from `SO_PEERCRED` kernel-supplied peer UID **and** an HMAC over the entire canonical request, not socket file mode or user-provided identity claims. An unprivileged agent may connect but cannot authenticate. The service reruns the independent CloudFormation effect verifier.

The service stores source hash, policy hash, baseline hash, epoch, revocation status, all used nonces, and the committed template **in one service-owned JSON file**. It serializes requests in one process, and updates that file via an fsynced atomic rename. It rejects replayed nonces, stale source or policy versions, revoked tickets, mismatched artifact digests and semantically unauthorized CloudFormation changes. This is an ordinary construction from Unix identity / MAC authentication, reference monitors, and database transactions; no novel primitive or universal safety claim.

## Experimental events (pre-registered)

1. Correctly signed current source/policy/version artifact accepted by service.
2. Repeated valid request rejected by nonce replay detection.
3. Harmful signed artifact rejected by independent effect verifier.
4. Forged HMAC rejected.
5. Distinct unprivileged caller rejected at kernel peer-UID check.
6. Distinct unprivileged caller denied service-key read and direct state-file write.
7. Trusted policy revision invalidates previous signed ticket.
8. Trusted source revision invalidates previous signed ticket.
9. Revocation invalidates previous ticket.
10. Previously published artifact remains byte-for-byte unchanged after every denial.

Independent checker imports none of the service, issuer or primary effect verifier code and checks official fixture resource differences, committed source/policy hashes, nonce count, epoch and denied-event receipt. No service signing keys enter uploaded artifacts.

## Critical limits

- The trusted issuer operates as the GitHub-hosted runner account and retains sudo capability; the test does not resist that privileged actor.
- The service accepts an authenticated envelope whose source/policy identifiers come from a **fresh isolated test initialization** based on previously certified source artifacts; no live cloud grant is being revived after revocation.
- Attestation signing occurs in a trusted issuer process; this does not prove a malicious agent cannot manipulate the issuer's code or artifact provenance. Issuer/verifier integrity remains assumed.
- The single JSON record is an **offline effect stand-in**, not AWS CloudFormation deployment, a remote API, or a production non-bypassable deployment service.
- The single-threaded process has an obvious serialization order but no proved liveness under arbitrary process failures. The one-file rename does not establish full distributed crash consistency.
- Ordinary Docker OS namespaces share the host kernel. No gVisor / Firecracker, hostile kernel, or Docker daemon attacks are in this certificate.
- These probes demonstrate functionality and the tested privilege boundary, not completeness against all kernel or process exploit classes.
- No real AI model-generated patch, source authentication supply chain end-to-end, or matched cost comparison is part of this result.

## Prior-art disposition

Unix `SO_PEERCRED`, HMAC-SHA256, atomic file replacement, the reference-monitor concept, SLSA / in-toto attestations, Sigstore admission, AWS CloudFormation Hooks, and 2026 PACE provenance-aware agent effect verification precede this experiment. Its contribution is a **reproducible, source-matched integration and explicit falsification boundary**, not mathematical priority over those systems.

**Next gate:** place the issuer behind a more strongly isolated production-like policy/execution service, measure end-to-end resource/verification costs under matched workloads, and evaluate strategic model-generated attacks. The dissertation's mathematically novel target remains the matching lower/upper complexity of source-valid adaptive evidence and enforcement over a change horizon.
