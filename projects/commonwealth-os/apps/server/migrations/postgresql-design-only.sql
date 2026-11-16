-- Commonwealth OS 0.4 POSTGRESQL DESIGN CONTRACT, NOT EXECUTED OR DEPLOYED.
-- Must be reviewed against the SQLite reference and actual PostgreSQL in a later gate.
-- Application role must NOT own these tables or possess BYPASSRLS.
BEGIN;
CREATE SCHEMA IF NOT EXISTS commonwealth;
CREATE TABLE IF NOT EXISTS commonwealth.institutions (
 id text PRIMARY KEY CHECK (id ~ '^[a-z][a-z0-9-]{1,63}$'),
 name text NOT NULL,
 policy_version bigint NOT NULL DEFAULT 1 CHECK(policy_version > 0),
 eligibility_version bigint NOT NULL DEFAULT 1 CHECK(eligibility_version > 0)
);
CREATE TABLE IF NOT EXISTS commonwealth.actors (
 institution_id text NOT NULL REFERENCES commonwealth.institutions(id),
 actor_id text NOT NULL,
 role text NOT NULL CHECK(role IN ('admin','chair','clerk','member','auditor','release-reviewer')),
 eligible boolean NOT NULL DEFAULT false,
 active boolean NOT NULL DEFAULT true,
 token_hash bytea UNIQUE NOT NULL,
 PRIMARY KEY(institution_id,actor_id)
);
CREATE TABLE IF NOT EXISTS commonwealth.items (
 institution_id text NOT NULL REFERENCES commonwealth.institutions(id),
 item_id text NOT NULL,
 state text NOT NULL,
 version bigint NOT NULL CHECK(version > 0),
 current_revision bigint NOT NULL CHECK(current_revision > 0),
 proposer_id text NOT NULL,
 locked_revision bigint,
 locked_policy_version bigint,
 locked_eligibility_version bigint,
 reviewer_id text,
 outcome text,
 PRIMARY KEY(institution_id,item_id),
 FOREIGN KEY(institution_id,proposer_id) REFERENCES commonwealth.actors(institution_id,actor_id)
);
CREATE TABLE IF NOT EXISTS commonwealth.item_revisions (
 institution_id text NOT NULL,item_id text NOT NULL,revision bigint NOT NULL,
 body text NOT NULL,previous_hash bytea NOT NULL,body_hash bytea NOT NULL,
 author_id text NOT NULL,created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(institution_id,item_id,revision),
 FOREIGN KEY(institution_id,item_id) REFERENCES commonwealth.items(institution_id,item_id)
);
CREATE TABLE IF NOT EXISTS commonwealth.events (
 institution_id text NOT NULL,item_id text NOT NULL,seq bigint NOT NULL,
 event_json jsonb NOT NULL,previous_hash bytea NOT NULL,event_hash bytea NOT NULL,
 PRIMARY KEY(institution_id,item_id,seq),
 FOREIGN KEY(institution_id,item_id) REFERENCES commonwealth.items(institution_id,item_id)
);
CREATE TABLE IF NOT EXISTS commonwealth.authority_events (
 institution_id text NOT NULL REFERENCES commonwealth.institutions(id),
 seq bigint NOT NULL,event_json jsonb NOT NULL,previous_hash bytea NOT NULL,event_hash bytea NOT NULL,
 PRIMARY KEY(institution_id,seq)
);
CREATE TABLE IF NOT EXISTS commonwealth.idempotency (
 institution_id text NOT NULL REFERENCES commonwealth.institutions(id),
 actor_id text NOT NULL,command_key text NOT NULL,request_hash bytea NOT NULL,response_json jsonb NOT NULL,
 PRIMARY KEY(institution_id,actor_id,command_key)
);
-- Important: per-request trusted tenant context must be set with SET LOCAL inside
-- a DB transaction following server authentication; never accept from an HTTP parameter.
-- Keep all application tables behind server RLS + independently tested authorization.
ALTER TABLE commonwealth.actors ENABLE ROW LEVEL SECURITY;
ALTER TABLE commonwealth.actors FORCE ROW LEVEL SECURITY;
CREATE POLICY actors_tenant ON commonwealth.actors USING (institution_id = current_setting('app.tenant_id',true)) WITH CHECK (institution_id = current_setting('app.tenant_id',true));
ALTER TABLE commonwealth.items ENABLE ROW LEVEL SECURITY;
ALTER TABLE commonwealth.items FORCE ROW LEVEL SECURITY;
CREATE POLICY items_tenant ON commonwealth.items USING (institution_id = current_setting('app.tenant_id',true)) WITH CHECK (institution_id = current_setting('app.tenant_id',true));
ALTER TABLE commonwealth.item_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE commonwealth.item_revisions FORCE ROW LEVEL SECURITY;
CREATE POLICY item_revisions_tenant ON commonwealth.item_revisions USING (institution_id = current_setting('app.tenant_id',true)) WITH CHECK (institution_id = current_setting('app.tenant_id',true));
ALTER TABLE commonwealth.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE commonwealth.events FORCE ROW LEVEL SECURITY;
CREATE POLICY events_tenant ON commonwealth.events USING (institution_id = current_setting('app.tenant_id',true)) WITH CHECK (institution_id = current_setting('app.tenant_id',true));
ALTER TABLE commonwealth.authority_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE commonwealth.authority_events FORCE ROW LEVEL SECURITY;
CREATE POLICY authority_tenant ON commonwealth.authority_events USING (institution_id = current_setting('app.tenant_id',true)) WITH CHECK (institution_id = current_setting('app.tenant_id',true));
ALTER TABLE commonwealth.idempotency ENABLE ROW LEVEL SECURITY;
ALTER TABLE commonwealth.idempotency FORCE ROW LEVEL SECURITY;
CREATE POLICY idempotency_tenant ON commonwealth.idempotency USING (institution_id = current_setting('app.tenant_id',true)) WITH CHECK (institution_id = current_setting('app.tenant_id',true));
-- No database role, isolation level, workflow, or tenancy correctness is established
-- merely by executing this DDL. SQL above is an incomplete production skeleton.
COMMIT;
