# Experimental PostgreSQL backend — local synthetic data ONLY

The authoritative institutional workflow remains the v0.4 SQLite demo. This PostgreSQL adapter is a portable *production-shaped storage candidate*, not a deployed or fully feature-equivalent election service.

## Local / CI test (requires PostgreSQL 16+ and `pg` for Node)

Create an empty `cwos_test` database and a **disposable** PostgreSQL superuser `postgres` available on localhost. Then:

```bash
npm install --no-save --ignore-scripts pg@8.14.1
CWOS_POSTGRES_TEST_URL='postgresql://postgres:postgres@localhost:5432/cwos_test' node --test postgres/tests/*.test.mjs
```

**Never** run this test suite against an existing database. It creates schemas and a disposable app role. CI uses a PostgreSQL service database and deletes it with the job.

The test runner deploys the SQL migration under the trusted migration owner, creates a nonowner app role without BYPASSRLS, and verifies RLS, serializable commands, append-only restrictions, independent replay, quorum/threshold and epoch invalidation. The app role is explicitly denied access to `cwos_ballot_vault`.

Production requirements are documented in `../docs/ASSURANCE_PERSISTENCE_IDENTITY_v0_5.md`. Additional audit tasks include a real migration from v0.4, safe retries for serialization conflicts, secure network and database configuration, privileges audit, backup/restore and completeness parity with publication/source/corrections.
