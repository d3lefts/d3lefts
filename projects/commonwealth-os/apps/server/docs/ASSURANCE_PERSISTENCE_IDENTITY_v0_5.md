# Commonwealth OS — Backend Assurance/Persistence/Identity Gate v0.5

2026-11-15 (EST). **Status: additional tested synthetic backend modules, NOT a complete or certified production/election system.** These files are a *stacked* increment on v0.4. No frontend was edited.

## Scientific objective and assumptions

Objective: verify, using independent code and real PostgreSQL transactions, that a portable synthetic legislative trace conforms to the specified versioned authority, attendance, threshold and review protocol; refuse any attempt to infer real legal voting authorization from cryptographic evidence.

Feasible set: synthetic institutions with explicit actors/roles, bounded rule fractions and named mock roll-call choices. No human subjects, public elections, physical effects, real ordinances or secrets. All proofs and tests are conditional on issuer key custody and complete/true source data.

Strongest already available foundation: Commonwealth OS formal workflow v1.1 (Python), Lean conditional Democratic Assurance results in draft PR #613, v0.4 SQLite state machine and independently authored signed verifier (stacked PR #618). None is an implementation-level proof for all arbitrary JS/Python/PostgreSQL traces.

## Concrete delivered components

| Component | Implemented | Verified scope |
|---|---|---|
| OIDC token validator | `security/oidc-bridge.mjs` validates fixed-config issuer, audience, signature algorithm/key, time, nonce, azp; consumes a nonce through an injected ledger; ignores asserted role/eligibility; caller must map subject in trusted institution registry | Synthetic signed-token tests; NOT a complete OIDC authorization-code client or a configured IdP |
| Ballot admission boundary | `security/ballot-boundary.mjs` refuses CONFIDENTIAL or OFFICIAL modes; permits only named synthetic roll-call mode; strictly allowlists public aggregate projection | Negative ballot/privacy tests; NOT actual secret ballot, E2E crypto, coercion resistance or election certification |
| PostgreSQL command store | `postgres/ledger.mjs` implements subset of the v0.4 command sequence with SERIALIZABLE transactions, institution lock, optimistic item version, idempotency and versioned actor/policy epochs | PostgreSQL service CI with real DB checks; SQLite v0.4 remains the broader reference, **not all v0.4 transitions have PostgreSQL parity** |
| PostgreSQL schema | `postgres/001_ledger.sql` includes RLS for every operational tenant table, immutability triggers, isolated ballot vault schema with no app grants, tenant-scoped writes | SQL syntax, role grants and tenant isolation only when CI passes; needs backup/recovery and operator audit |
| Independent replay | `postgres/verify-ledger.mjs`, separately authored; replays event and authority chains, actor roles, roster/epoch pins, revision chains and tallies; optional signed bundle requires externally pinned Ed25519 key | Internal independent source and adversarial mutation tests; NOT mathematical compiler/runtime refinement |
| Bounded model tests | `assurance/generate-cases.mjs` + `assurance/check_cases.py` check all 216 3-member choice configurations for 4 denominator bases × strict/non-strict thresholds | Complete over stated finite domain; NOT a universal theorem |

## Invariants with test coverage

- **I1 atomicity**: each PG `SERIALIZABLE` command has expectedVersion and an idempotency key; institution row is locked before reading actor state. Corrupted/stale requests fail closed. Retry should be explicit on SQLSTATE 40001, using the same idempotency key.
- **I2 immutable history**: PG event, revision, authority, policy, requests, and ballot receipts reject UPDATE/DELETE via triggers; database owner/superuser still controls the store.
- **I3 scoped authority**: PG RLS is forced on all tenant tables, policies compare `institution_id` with trusted transaction-local `app.tenant_id`; deployment role must not own tables or hold BYPASSRLS. This is *defense in depth*: a compromised SQL execution context with arbitrary `set_config` remains a problem. Never expose arbitrary SQL or tenant selection to clients.
- **I4 decision lock**: LOCK records actor grants, eligible roster, policy hash/epoch and item revision. OPEN/CAST/CLOSE/REVIEW refuse changed policy or eligibility epochs.
- **I5 identity source separation**: an ID token authenticates only subject binding to a configured issuer. It does not authorize a governmental role or cast. The institution must bind that subject separately, and should assess identity assurance level under NIST 800-63-4.
- **I6 no implicit official voting**: the ballot-admission interface rejects official or confidential elections rather than inventing an unreviewed cryptographic protocol. No real ballots or protected personal preferences belong in these fixtures.
- **I7 evidence limits**: signed exporter plus independent checker establishes consistency with a pinned *key*, conditional on trustworthy key custody, event completeness and a valid authority model; it cannot prove source-law truth.

## Independent audit design (before seeing implementation changes)

Auditor: independent Python exact-integer model with fixed 216-case input universe, and separate PG replay verifier (no import from PG adapter). Attack suites include signing-key substitution, re-signed malicious payloads, stale authority/version, duplicate voters, role spoofing, RLS tenant crossover, immutable record mutation, failed transaction rollback and concurrency.

Stop on mismatch, missing configured issuer, untrusted identity subject mapping, unsigned or unpinned external evidence, PostgreSQL SQLSTATE 40001 without safe client retry, invalid RLS tenant context, secret ballot request, or official action request.

## Unclosed external and deeper engineering gates

1. **Formal refinement theorem**: write an actual simulation relation between the production runtime and Lean model, prove each step and independent non-bypassable effect completeness. Runtime tests, even exhaustive finite ones, cannot prove arbitrary JS/native/postgres behavior. External formal reviewer required.
2. **Production persistence**: deploy maintained PG with backup/PITR, restore exercises, TLS/mTLS, KMS/HSM-managed signing keys, migrations/rollback, monitoring, quotas, connection-pool isolation, HA/failover and admin threat controls. PostgreSQL adapter currently covers the core synthetic sequence but not full publish/correction/source transitions.
3. **Production identity**: authorization-code + PKCE integration, HTTPS redirect/session protection, persistent replay prevention, revocation, federation trust agreements, authenticator management and WebAuthn independent review. This OIDC adapter is offline token verification, not a complete login system.
4. **Secret-ballot protocol**: independent election cryptographers must review a mature software-independent end-to-end verifiable protocol or legally required paper records, ballot secrecy, anti-coercion, voter-verifiable receipts, election operations and incident recovery. Avoid building custom ballots from encryption alone. Public governmental election authority is entirely out of scope until statutory authorization.
5. **Human and legal prerequisites**: real source owners, lawful electronic governance procedures, institutional approval, consent/privacy review, accessible independent usability testing and public procurement/records policies.

## Standards checked 2026-11-15

- NIST SP 800-63-4 / 800-63C-4 (final July 2025) for identity and federation: https://csrc.nist.gov/pubs/sp/800/63/4/final
- OpenID Connect Core 1.0 errata set 2 ID Token validation: https://openid.net/specs/openid-connect-core-1_0.html
- U.S. Election Assistance Commission VVSG 2.0 and E2E protocol evaluation criteria: https://www.eac.gov/voting-equipment/end-end-e2e-protocol-evaluation-process
- PostgreSQL current documentation on Row Security Policies: https://www.postgresql.org/docs/current/ddl-rowsecurity.html

**Certificate status**: bounded tests and source-level replay only; no production-release, election-security, legal or full Lean-implementation certificate issued.
