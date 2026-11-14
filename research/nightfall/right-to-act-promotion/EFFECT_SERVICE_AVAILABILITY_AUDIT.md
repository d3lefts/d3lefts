# NIGHTFALL — Effect-Service Availability Audit (v1.8a)

**Date:** 2026-11-14. **Status:** independently reproducible counterexample to the original single-threaded Unix-socket service, with a narrowly scoped correction. Not a new discovery in operating systems or complexity theory.

## Concrete counterexample

The v1.8 daemon accepts one connection and then blocks on `recv` until a newline, EOF, or its maximum buffer length. An untrusted UID may connect because the socket is deliberately world-accessible (authorization uses `SO_PEERCRED`). When that client sends no bytes and holds the connection open, the server never reaches the next authenticated request. The local checker measured an authenticated request timing out after 6.01 seconds with the original implementation.

This does not contradict v1.8's **safety** tests. It exposes a separate missing **availability/liveness** condition.

## Restricted correction

Use a monotonic **absolute two-second request deadline**, not a resettable per-read idle timeout. Before each receive compute the remaining deadline, set the socket timeout no longer than that remaining duration, and reject the connection when the absolute deadline passes. The service then returns to accepting subsequent requests.

Pre-registered negative controls: (i) a client accepts and sends nothing; (ii) a client slowly drips one byte every 120 ms, thereby defeating naive idle-only timeouts. Under the repaired code a trusted status request must complete in under 3.2 seconds after either deliberately occupied connection. Both passed locally (~1.90 seconds); all original ten effect-service authorization tests and their independent artifact replay passed unchanged.

## Conditional liveness claim

Assuming each read handler completes and the OS continues scheduling the service, **any one accepted client connection can hold the serial service's request parser for at most two seconds** (up to ordinary scheduling/timer tolerance). This follows directly from the monotonic absolute deadline check; it is not a theorem against infinitely many coordinated malicious connections.

## What is *not* solved

- An adversary can repeatedly create connections or exhaust the listening backlog. The server has no global admission rate limit, bounded priority queue, client quota, or separate authenticated fast path.
- No guarantee of response under arbitrary attacker arrival rate, CPU starvation, descriptor exhaustion, host compromise, or process crashes.
- The trusted issuer has sudo power in the GitHub experiment, and the protected effect remains one local JSON commit, not AWS infrastructure.
- The same source-valid evidence, artifact-hash verification and independent CloudFormation semantic checks are retained from v1.8.
- The absolute request timer is a well-known defensive engineering technique; historical novelty is not claimed.

**Next decisive work:** isolate or prioritize trusted authority requests from untrusted workload traffic with measured admission bounds, then test stronger runtime isolation (gVisor/microVM) and an actual external deployment-effect boundary.
