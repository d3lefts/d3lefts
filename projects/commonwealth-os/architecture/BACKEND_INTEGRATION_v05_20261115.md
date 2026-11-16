# Commonwealth backend v0.4/v0.5 integration — reproducibility and release boundaries

**Date:** 2026-11-15 Eastern / 2026-11-16 UTC. **Status:** synthetic-only integration. Not a government election, real identity provider, legal certification, deployed municipal system or production authorization.

## Exact provenance

- v0.4 source: [draft PR #618](https://github.com/d3lefts/d3lefts/pull/618), head `b60e04270e56967cdb4e75ee4e1597d8e2d0077a`; original checked run [43781856222](https://github.com/d3lefts/d3lefts/actions/runs/43781856222), completed SUCCESS.
- v0.5 source: [draft PR #627](https://github.com/d3lefts/d3lefts/pull/627), head `03d5dea47759f9704e2224d73885e24a7af4b13d`; original checked run [43784691750](https://github.com/d3lefts/d3lefts/actions/runs/43784691750), completed SUCCESS.
- Stacking history: #627 on #618 on #615/#610; the v0.3 foundation from #615/#610 was already integrated into `main` via merged #617. This integration copies **exact Git blob SHAs** for the later server paths and scoped workflow onto the newer `main`. It does **not** reintegrate the older branch history, overwrite other Commonwealth workstreams, or change the legal knowledge kernel.
- Integration baseline: `main` commit `fe49bedad20d958622c8e96075f5f83faefb3395`; 42 changed paths (34 new, eight updated) from the v0.5 head. No removals.

## What these source files implement (synthetic only)

- v0.4: full fictional motion lifecycle, immutable corrections and two-person publication, source-linked portable signed proof bundles, replayable policy and roster epochs, exact fractional thresholds, conservative recertification.
- v0.5: OIDC ID-token verification boundary (not a real IdP), blocked official/secret ballot transitions, PostgreSQL 16 migration and transactional candidate, forced RLS in tested nonowner access, independently implemented PostgreSQL event/role/authority replay, bounded 216-case model-check oracle.
- Existing Python `app/`, browser prototype `apps/browser/`, Living Voter and `legal/` source-proof work remain separate, unchanged and nonbinding.

## Required validation before considering merge

1. On the **integration branch**, run scoped `.github/workflows/commonwealth-backend-v05.yml`: Node v0.4 server suite, OIDC/ballot tests, 216-case independent Python oracle and real PostgreSQL-16 integration tests.
2. Run preexisting `.github/workflows/commonwealth-browser.yml` and any triggered pin audits, confirming the upgraded backend does not break existing synthetic workflows.
3. Inspect against current `main`; accept only exactly intended server and scoped workflow differences plus this provenance note and README index.
4. Never label the integration as an implementation-level Lean refinement theorem, genuine OIDC deployment, certified privacy-preserving voting, secret ballot security or approved public election.

## Known blockers

- PostgreSQL backend is a **candidate**, not full v0.4 feature parity. The actual PG command path does not cover all publication, correction and source transitions.
- The Python reference app and Node backend are parallel demo implementations. One authoritative command pipeline has **not** yet been selected; see issue [#626](https://github.com/d3lefts/d3lefts/issues/626).
- No institution-approved authentication provider, real voter registry, independently audited secret ballot, external key custody, operational disaster recovery, complete effect-time reference monitor, external security review or qualified legal validation.
- No real municipalities or voters were imported, no live ingestion was enabled, no authority to hold an official election was created.

Keep the implementation's claims within its tested synthetic contracts and retain the consent, transparency and release boundaries in the Commonwealth project charter.
