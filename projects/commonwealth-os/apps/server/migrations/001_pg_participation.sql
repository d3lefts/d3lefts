-- Commonwealth v1.4: synthetic participation-only PostgreSQL store.
-- Existing procedural/voting SQLite simulator is deliberately NOT migrated.
-- Run with a restricted demo database account, never on production civic data.
BEGIN;
CREATE TABLE IF NOT EXISTS cw_pg_actors (
 tenant TEXT NOT NULL,
 actor_id TEXT NOT NULL,
 role TEXT NOT NULL CHECK (role IN ('admin','chair','clerk','member','auditor')),
 eligible BOOLEAN NOT NULL,
 active BOOLEAN NOT NULL DEFAULT TRUE,
 token_hash CHAR(64) NOT NULL UNIQUE,
 PRIMARY KEY (tenant,actor_id)
);
CREATE TABLE IF NOT EXISTS cw_pg_streams (
 tenant TEXT PRIMARY KEY,
 seq INTEGER NOT NULL DEFAULT 0 CHECK (seq>=0),
 head_hash TEXT NOT NULL DEFAULT 'GENESIS'
);
CREATE TABLE IF NOT EXISTS cw_pg_events (
 tenant TEXT NOT NULL REFERENCES cw_pg_streams(tenant),
 seq INTEGER NOT NULL CHECK (seq>=1),
 previous_hash TEXT NOT NULL,
 hash CHAR(64) NOT NULL,
 nonce BYTEA NOT NULL CHECK (octet_length(nonce)=12),
 tag BYTEA NOT NULL CHECK (octet_length(tag)=16),
 ciphertext BYTEA NOT NULL,
 PRIMARY KEY (tenant,seq)
);
CREATE TABLE IF NOT EXISTS cw_pg_requests (
 tenant TEXT NOT NULL,
 actor_id TEXT NOT NULL,
 request_key TEXT NOT NULL,
 request_hash CHAR(64) NOT NULL,
 response_json JSONB NOT NULL,
 PRIMARY KEY (tenant,actor_id,request_key),
 FOREIGN KEY (tenant,actor_id) REFERENCES cw_pg_actors(tenant,actor_id)
);
CREATE OR REPLACE FUNCTION cw_pg_immutable_event() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
 RAISE EXCEPTION 'IMMUTABLE_PG_PARTICIPATION_EVENT';
END $$;
DO $$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname='cw_pg_events_immutable') THEN
   CREATE TRIGGER cw_pg_events_immutable BEFORE UPDATE OR DELETE ON cw_pg_events
   FOR EACH ROW EXECUTE FUNCTION cw_pg_immutable_event();
 END IF;
END $$;
COMMIT;
