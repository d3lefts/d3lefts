-- PostgreSQL 16+; run as trusted migration owner, NOT the application role.
-- Synthetic-only release candidate. DDL is not legal election authority.
BEGIN;
CREATE SCHEMA IF NOT EXISTS cwos;
CREATE TABLE IF NOT EXISTS cwos.schema_migrations (version integer PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE cwos.institutions (
  id text PRIMARY KEY CHECK (id ~ '^[a-z][a-z0-9-]{1,63}$'),
  name text NOT NULL,policy_version bigint NOT NULL DEFAULT 1 CHECK (policy_version>0),
  eligibility_version bigint NOT NULL DEFAULT 1 CHECK (eligibility_version>0));
CREATE TABLE cwos.actors (
  institution_id text NOT NULL REFERENCES cwos.institutions(id), actor_id text NOT NULL,
  role text NOT NULL CHECK(role IN ('admin','chair','clerk','member','auditor','release-reviewer')),
  eligible boolean NOT NULL DEFAULT false,active boolean NOT NULL DEFAULT true,
  PRIMARY KEY(institution_id,actor_id));
CREATE TABLE cwos.policies (
  institution_id text NOT NULL REFERENCES cwos.institutions(id),version bigint NOT NULL,
  policy jsonb NOT NULL,policy_hash text NOT NULL CHECK(policy_hash ~ '^[0-9a-f]{64}$'),
  created_at timestamptz NOT NULL DEFAULT now(),PRIMARY KEY(institution_id,version));
CREATE TABLE cwos.items (
  institution_id text NOT NULL REFERENCES cwos.institutions(id),item_id text NOT NULL,
  state text NOT NULL,version bigint NOT NULL CHECK(version>0),current_revision bigint NOT NULL CHECK(current_revision>0),
  proposer text NOT NULL,locked_revision bigint,locked_policy_version bigint,locked_eligibility_version bigint,
  reviewer text,outcome text,PRIMARY KEY(institution_id,item_id),
  FOREIGN KEY(institution_id,proposer) REFERENCES cwos.actors(institution_id,actor_id));
CREATE TABLE cwos.revisions (
  institution_id text NOT NULL,item_id text NOT NULL,revision bigint NOT NULL,
  body text NOT NULL,previous_hash text NOT NULL,body_hash text NOT NULL,author text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),PRIMARY KEY(institution_id,item_id,revision),
  FOREIGN KEY(institution_id,item_id) REFERENCES cwos.items(institution_id,item_id));
CREATE TABLE cwos.events (
  institution_id text NOT NULL,item_id text NOT NULL,seq bigint NOT NULL,
  event jsonb NOT NULL,previous_hash text NOT NULL,event_hash text NOT NULL,
  PRIMARY KEY(institution_id,item_id,seq),FOREIGN KEY(institution_id,item_id) REFERENCES cwos.items(institution_id,item_id));
CREATE TABLE cwos.authority_events (
  institution_id text NOT NULL REFERENCES cwos.institutions(id),seq bigint NOT NULL,
  event jsonb NOT NULL,previous_hash text NOT NULL,event_hash text NOT NULL,
  PRIMARY KEY(institution_id,seq));
CREATE TABLE cwos.attendance (
  institution_id text NOT NULL,item_id text NOT NULL,actor_id text NOT NULL,
  PRIMARY KEY(institution_id,item_id,actor_id),FOREIGN KEY(institution_id,item_id) REFERENCES cwos.items(institution_id,item_id));
CREATE TABLE cwos.rollcall_votes (
  institution_id text NOT NULL,item_id text NOT NULL,actor_id text NOT NULL,choice text NOT NULL CHECK (choice IN ('yes','no','abstain')),
  PRIMARY KEY(institution_id,item_id,actor_id),FOREIGN KEY(institution_id,item_id) REFERENCES cwos.items(institution_id,item_id));
CREATE TABLE cwos.requests (
  institution_id text NOT NULL REFERENCES cwos.institutions(id),actor_id text NOT NULL,
  command_key text NOT NULL,request_hash text NOT NULL,response jsonb NOT NULL,
  PRIMARY KEY(institution_id,actor_id,command_key));
CREATE TABLE cwos.sources (
  institution_id text NOT NULL REFERENCES cwos.institutions(id),source_id text NOT NULL,version bigint NOT NULL,
  body text NOT NULL,status text NOT NULL,uri text NOT NULL,previous_hash text NOT NULL,body_hash text NOT NULL,
  PRIMARY KEY(institution_id,source_id,version));
CREATE TABLE cwos.source_links (
  institution_id text NOT NULL,item_id text NOT NULL,source_id text NOT NULL,version bigint NOT NULL,body_hash text NOT NULL,
  PRIMARY KEY(institution_id,item_id,source_id),FOREIGN KEY(institution_id,item_id) REFERENCES cwos.items(institution_id,item_id));
CREATE TABLE cwos.projections (
  institution_id text NOT NULL,item_id text NOT NULL,revision bigint NOT NULL,
  content text NOT NULL,previous_hash text NOT NULL,body_hash text NOT NULL,reason text NOT NULL,
  PRIMARY KEY(institution_id,item_id,revision),FOREIGN KEY(institution_id,item_id) REFERENCES cwos.items(institution_id,item_id));
CREATE TABLE cwos.publication_approvals (
  institution_id text NOT NULL,item_id text NOT NULL,revision bigint NOT NULL,actor_id text NOT NULL,
  PRIMARY KEY(institution_id,item_id,revision,actor_id));
-- Opaque encrypted ballots are never readable by the generic application role.
-- A separately scrutinized ballot subsystem/DB role is required before any actual ballot storage.
CREATE SCHEMA IF NOT EXISTS cwos_ballot_vault;
CREATE TABLE cwos_ballot_vault.sealed_ballot (
  institution_id text NOT NULL,ballot_id text NOT NULL,ciphertext bytea NOT NULL,
  receipt_digest bytea NOT NULL,PRIMARY KEY(institution_id,ballot_id));

CREATE FUNCTION cwos.reject_immutable_change() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN RAISE EXCEPTION 'IMMUTABLE_LEDGER_RECORD' USING ERRCODE='23000'; END; $$;
DO $$ DECLARE tab text; BEGIN
FOREACH tab IN ARRAY ARRAY['policies','revisions','events','authority_events','rollcall_votes','requests','sources','projections','publication_approvals'] LOOP
EXECUTE format('CREATE TRIGGER %I_immutable BEFORE UPDATE OR DELETE ON cwos.%I FOR EACH ROW EXECUTE FUNCTION cwos.reject_immutable_change()',tab,tab);
END LOOP; END $$;

-- FORCE RLS even for table owners; a superuser/BYPASSRLS could still circumvent it.
DO $$ DECLARE tab text; BEGIN
FOREACH tab IN ARRAY ARRAY['actors','policies','items','revisions','events','authority_events','attendance','rollcall_votes','requests','sources','source_links','projections','publication_approvals'] LOOP
EXECUTE format('ALTER TABLE cwos.%I ENABLE ROW LEVEL SECURITY',tab);
EXECUTE format('ALTER TABLE cwos.%I FORCE ROW LEVEL SECURITY',tab);
EXECUTE format('CREATE POLICY %I_tenant ON cwos.%I USING (institution_id = current_setting(''app.tenant_id'',true)) WITH CHECK (institution_id = current_setting(''app.tenant_id'',true))',tab,tab);
END LOOP; END $$;
ALTER TABLE cwos.institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE cwos.institutions FORCE ROW LEVEL SECURITY;
CREATE POLICY institutions_tenant ON cwos.institutions USING (id = current_setting('app.tenant_id',true)) WITH CHECK (id = current_setting('app.tenant_id',true));
INSERT INTO cwos.schema_migrations(version) VALUES (5);
COMMIT;
