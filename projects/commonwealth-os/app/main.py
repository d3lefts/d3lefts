"""Commonwealth OS: runnable *fictional-only* legislative PWA backend.

All consequential transitions reuse the versioned workflow_model reducer, then
persist with an optimistic version check inside a SQLite BEGIN IMMEDIATE txn.
Demo identity selection is NOT authentication and must never be reused for live voting.
"""
from __future__ import annotations

from dataclasses import asdict
from hashlib import sha256
from pathlib import Path
import json
import os
import secrets
import sqlite3
import sys
import time
from typing import Annotated
from uuid import uuid4

from fastapi import Cookie, FastAPI, Header, HTTPException, Request
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, ConfigDict, Field

CONTRACT = Path(__file__).resolve().parents[1] / "workflow"
sys.path.insert(0, str(CONTRACT))
from workflow_model import (Actor, Event, Rules, Workflow, establish, amend,
                            advance, cast, certify, prepare_publication,
                            approve_publication, abort, check_log, passport)
from independent_checker import verify
from app import civic, attest, authority, history

ROOT = Path(__file__).resolve().parent
DEMO_TENANTS = {
    "demo-campus": {"label": "Fictional Student Senate", "kind": "University", "item_id": "SB-014", "jurisdiction": "synthetic-university", "initial": "Resolve to extend the operating hours of fictional campus study spaces on weekdays."},
    "demo-hoa": {"label": "Fictional Neighborhood Board", "kind": "HOA", "item_id": "HOA-008", "jurisdiction": "synthetic-residential", "initial": "Approve a fictional common-garden maintenance plan with quarterly expense reporting."},
    "demo-city": {"label": "Fictional Municipal Council", "kind": "Municipality", "item_id": "CIV-021", "jurisdiction": "synthetic-municipality", "initial": "Approve a fictional sidewalk accessibility study with a public reporting requirement."},
}
ROLES = {
    "author": ("AUTHOR",), "clerk": ("CLERK",), "presider": ("PRESIDER",),
    "member1": ("MEMBER",), "member2": ("MEMBER",), "member3": ("MEMBER",),
    "reviewer1": ("RELEASE_REVIEWER",), "reviewer2": ("RELEASE_REVIEWER",),
    "auditor": ("AUDITOR",),
    "institution_admin": ("INSTITUTION_ADMIN",),
    **{f"constituent{i}": ("CONSTITUENT",) for i in range(1,13)},
}
ACTION_LABELS = {
    "AMEND": "Propose amendment", "SUBMIT_REVIEW": "Submit for review",
    "SET_AGENDA": "Place on agenda", "OPEN_DEBATE": "Open deliberation",
    "LOCK_MOTION": "Lock exact motion", "OPEN_BALLOT": "Open demo ballot",
    "CAST": "Cast demo vote", "CLOSE_BALLOT": "Close demo ballot",
    "CERTIFY": "Certify demo result", "PREPARE_PUBLICATION": "Prepare public preview",
    "REVIEW_PUBLICATION": "Review public preview", "APPROVE_PUBLICATION_PREVIEW": "Approve public preview",
    "VOID": "Void motion (reason required)",
}
MUTATION_HEADER = "demo"


def actors(tenant: str) -> dict[str, Actor]:
    return {name: Actor(name, tenant, frozenset(role)) for name, role in ROLES.items()}


def encode(w: Workflow) -> str:
    d = asdict(w)
    d["roster"] = sorted(w.roster)
    d["attendance"] = sorted(w.attendance)
    return json.dumps(d, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


def decode(raw: str) -> Workflow:
    d = json.loads(raw)
    d["rules"] = Rules(**d["rules"])
    d["roster"] = frozenset(d["roster"])
    d["attendance"] = frozenset(d["attendance"])
    d["casts"] = tuple(tuple(pair) for pair in d["casts"])
    d["tally"] = None if d["tally"] is None else tuple(d["tally"])
    d["release_reviewers"] = tuple(d["release_reviewers"])
    d["events"] = tuple(Event(**event) for event in d["events"])
    return Workflow(**d)


def evidence(w: Workflow) -> dict:
    return {
        "tenant": w.tenant, "jurisdiction": w.jurisdiction,
        "item_id": w.item_id, "mode": w.mode, "rules": asdict(w.rules),
        "roster": sorted(w.roster), "attendance": sorted(w.attendance),
        "events": [asdict(e) for e in w.events],
        "actors": {k: {"tenant": w.tenant, "roles": sorted(a.roles),
                        "is_human": a.is_human} for k, a in actors(w.tenant).items()},
        "status": w.status, "text": w.text, "revision": w.revision,
        "author": w.author, "casts": [list(pair) for pair in w.casts],
        "tally": list(w.tally) if w.tally is not None else None,
        "release_reviewers": list(w.release_reviewers),
    }


def connect(db_path: str) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path, timeout=10, isolation_level=None)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys=ON")
    conn.execute("PRAGMA busy_timeout=10000")
    return conn


def prepare_db(db_path: str) -> None:
    Path(db_path).parent.mkdir(parents=True, exist_ok=True)
    with connect(db_path) as conn:
        conn.execute("PRAGMA journal_mode=WAL")
        conn.executescript("""
        CREATE TABLE IF NOT EXISTS items (
          tenant TEXT NOT NULL, id TEXT NOT NULL, version INTEGER NOT NULL,
          state_json TEXT NOT NULL, PRIMARY KEY(tenant, id)
        );
        CREATE TABLE IF NOT EXISTS sessions (
          token_hash TEXT PRIMARY KEY, tenant TEXT NOT NULL, actor TEXT NOT NULL,
          created_at INTEGER NOT NULL
        );
        CREATE TABLE IF NOT EXISTS creation_commands (
          tenant TEXT NOT NULL, token_hash TEXT NOT NULL, command_id TEXT NOT NULL,
          request_hash TEXT NOT NULL, item_id TEXT NOT NULL,
          PRIMARY KEY(tenant,token_hash,command_id));
        CREATE TABLE IF NOT EXISTS commands (
          tenant TEXT NOT NULL, item_id TEXT NOT NULL, token_hash TEXT NOT NULL,
          command_id TEXT NOT NULL, request_hash TEXT NOT NULL, response_json TEXT NOT NULL,
          PRIMARY KEY(tenant,item_id,token_hash,command_id)
        );
        """)
        # Schema upgrades retain existing fictional item and command data.
        columns={row["name"] for row in conn.execute("PRAGMA table_info(commands)")}
        if "request_hash" not in columns:
            conn.execute("ALTER TABLE commands ADD COLUMN request_hash TEXT NOT NULL DEFAULT ''")
        for tenant, d in DEMO_TENANTS.items():
            w = establish(d["item_id"], tenant, d["jurisdiction"], "DEMO",
                          actors(tenant)["author"], d["initial"],
                          Rules("fictional-rules-v1", quorum=2),
                          {"member1", "member2", "member3"},
                          {"member1", "member2", "member3"})
            conn.execute("INSERT OR IGNORE INTO items(tenant,id,version,state_json) VALUES(?,?,?,?)",
                         (tenant, w.item_id, len(w.events), encode(w)))


def available(w: Workflow, actor: Actor) -> list[dict]:
    role = actor.roles
    s = w.status
    actions = []
    def add(condition: bool, name: str):
        if condition:
            actions.append({"action": name, "label": ACTION_LABELS[name]})
    add("AUTHOR" in role and s in ("DRAFT", "IN_REVIEW", "AGENDA_SET", "DELIBERATING"), "AMEND")
    add("AUTHOR" in role and s == "DRAFT", "SUBMIT_REVIEW")
    add("CLERK" in role and s == "IN_REVIEW", "SET_AGENDA")
    add("PRESIDER" in role and s == "AGENDA_SET", "OPEN_DEBATE")
    add("PRESIDER" in role and s == "DELIBERATING", "LOCK_MOTION")
    add("PRESIDER" in role and s == "MOTION_LOCKED", "OPEN_BALLOT")
    add("MEMBER" in role and s == "BALLOT_OPEN" and actor.id in w.roster and
        actor.id in w.attendance and actor.id not in dict(w.casts), "CAST")
    add("PRESIDER" in role and s == "BALLOT_OPEN", "CLOSE_BALLOT")
    add("CLERK" in role and s == "BALLOT_CLOSED" and actor.id != w.author and
        actor.id not in w.roster, "CERTIFY")
    add("CLERK" in role and s in ("CERTIFIED", "REJECTED"), "PREPARE_PUBLICATION")
    add("RELEASE_REVIEWER" in role and s == "PUBLICATION_REVIEW" and
        actor.id not in w.release_reviewers and actor.id not in (w.author, w.certifier),
        "REVIEW_PUBLICATION" if not w.release_reviewers else "APPROVE_PUBLICATION_PREVIEW")
    add("PRESIDER" in role and s in ("DRAFT", "IN_REVIEW", "AGENDA_SET", "DELIBERATING", "MOTION_LOCKED", "BALLOT_OPEN", "BALLOT_CLOSED"), "VOID")
    return actions


def private_view(w: Workflow, version: int, actor: Actor) -> dict:
    counts = None if w.tally is None else dict(zip(("aye", "nay", "abstain"), w.tally))
    return {
        "id": w.item_id, "tenant": w.tenant, "institution": DEMO_TENANTS[w.tenant]["label"],
        "kind": DEMO_TENANTS[w.tenant]["kind"], "version": version,
        "status": w.status, "revision": w.revision, "text": w.text,
        "motion_hash": w.motion_hash, "locked_motion_hash": w.locked_motion_hash,
        "rules_version": w.rules.version, "quorum": w.rules.quorum,
        "roster_count": len(w.roster), "attendance_count": len(w.attendance),
        "cast_count": len(w.casts), "my_cast": dict(w.casts).get(actor.id),
        "tally": counts, "certifier": w.certifier or None,
        "review_count": len(w.release_reviewers),
        "event_root": w.log_root, "event_count": len(w.events),
        "events": [{"seq": e.seq, "name": e.name, "actor": e.actor, "hash": e.hash}
                   for e in w.events],
        "actions": available(w, actor), "legal_authority": False,
        "independent_review": False, "official_voting_enabled": False,
    }


def public_view(w: Workflow) -> dict:
    if w.status != "PUBLISHED" or not w.publication_hash:
        raise HTTPException(status_code=404, detail="Public preview not approved")
    return {
        "label": "FICTIONAL PUBLIC PREVIEW — NOT OFFICIAL",
        "institution": DEMO_TENANTS[w.tenant]["label"],
        "item_id": w.item_id, "jurisdiction": w.jurisdiction,
        "revision": w.revision, "text": w.text, "outcome": "PASSED" if w.tally[0]>w.tally[1] and sum(w.tally[:2])>0 else "FAILED",
        "tally": {"aye": w.tally[0], "nay": w.tally[1], "abstain": w.tally[2]},
        "source_root": w.log_root, "motion_hash": w.locked_motion_hash,
        "publication_hash": w.publication_hash, "verified_publication": "demo-only",
        "legal_authority": False,
    }


class Login(BaseModel):
    model_config = ConfigDict(extra="forbid")
    tenant: str
    actor: str


class NewItem(BaseModel):
    model_config = ConfigDict(extra="forbid")
    text: str = Field(min_length=10,max_length=30000)
    command_id: str = Field(min_length=8,max_length=128)


class Command(BaseModel):
    model_config = ConfigDict(extra="forbid")
    action: str
    expected_version: int = Field(ge=1)
    command_id: str = Field(min_length=8, max_length=128)
    text: str | None = Field(None, max_length=30000)
    choice: str | None = None
    reason: str | None = Field(None, max_length=1000)


def create_app(db_path: str | None = None) -> FastAPI:
    db_path = db_path or os.getenv("CW_DB_PATH", str(ROOT / "commonwealth-demo.sqlite3"))
    prepare_db(db_path)
    attest.prepare_attest(connect,db_path)
    civic.install_tables(connect,db_path)
    authority.prepare_authority(connect,db_path,DEMO_TENANTS,ROLES)
    app = FastAPI(title="Commonwealth OS — Fictional Legislative Demo", version="0.3.0", docs_url=None, redoc_url=None)
    app.mount("/static", StaticFiles(directory=str(ROOT / "static")), name="static")

    @app.middleware("http")
    async def headers(req: Request, call_next):
        response = await call_next(req)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Cache-Control"] = "no-store"
        response.headers["Content-Security-Policy"] = "default-src 'self'; style-src 'self'; script-src 'self'; img-src 'self' data:; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'"
        return response

    def identity(token: str | None) -> tuple[Actor, str]:
        if not token:
            raise HTTPException(401, "Select a fictional role to enter the demo")
        h = sha256(token.encode()).hexdigest()
        with connect(db_path) as conn:
            row = conn.execute("SELECT tenant,actor,created_at FROM sessions WHERE token_hash=?", (h,)).fetchone()
        if row is None:
            raise HTTPException(401, "Demo session expired")
        if int(time.time()) - row["created_at"] > 3600:
            with connect(db_path) as conn:
                conn.execute("DELETE FROM sessions WHERE token_hash=?",(h,))
            raise HTTPException(401,"Demo session expired")
        active=authority.active_roles(connect,db_path,row["tenant"],row["actor"])
        if not active:
            raise HTTPException(403,"This fictional role grant has been revoked")
        return Actor(row["actor"],row["tenant"],active),h

    def get_item(tenant: str, item_id: str) -> tuple[Workflow, int]:
        with connect(db_path) as conn:
            row = conn.execute("SELECT version,state_json FROM items WHERE tenant=? AND id=?", (tenant, item_id)).fetchone()
        if row is None:
            raise HTTPException(404, "Unknown fictional legislative item")
        w=decode(row["state_json"])
        with connect(db_path) as conn:
            if not attest.check_custody(conn,w) or not check_log(w):
                raise HTTPException(503,"Ledger custody verification failed")
        return w, row["version"]

    @app.get("/healthz")
    def health():
        return {"status": "ok", "mode": "FICTIONAL_DEMO", "official_voting_enabled": False,
                "municipal_record_ingestion_enabled": False}

    @app.get("/")
    def index():
        return FileResponse(str(ROOT / "static" / "index.html"))

    @app.get("/api/demo/tenants")
    def tenants():
        return [{"id": k, "label": v["label"], "kind": v["kind"], "item_id": v["item_id"]}
                for k, v in DEMO_TENANTS.items()]

    @app.get("/api/demo/actors")
    def actor_list():
        return [{"id": k, "roles": list(v)} for k, v in ROLES.items()]

    @app.post("/api/demo/login")
    def login(body: Login, x_cw_action: Annotated[str | None, Header()] = None):
        if x_cw_action != MUTATION_HEADER:
            raise HTTPException(403, "Missing action-intent header")
        if body.tenant not in DEMO_TENANTS or body.actor not in ROLES:
            raise HTTPException(404, "Unknown fictional institution or role")
        token = secrets.token_urlsafe(32)
        with connect(db_path) as conn:
            conn.execute("INSERT INTO sessions(token_hash,tenant,actor,created_at) VALUES(?,?,?,?)",
                         (sha256(token.encode()).hexdigest(), body.tenant, body.actor, int(time.time())))
        response = JSONResponse({"tenant": body.tenant, "actor": body.actor,
                                 "roles": ROLES[body.actor], "real_identity_verified": False})
        response.set_cookie("cw_demo", token, httponly=True, samesite="strict", secure=False, max_age=3600)
        return response

    @app.post("/api/demo/logout")
    def logout(cw_demo: Annotated[str | None, Cookie()] = None,
               x_cw_action: Annotated[str | None, Header()] = None):
        if x_cw_action != MUTATION_HEADER:
            raise HTTPException(403, "Missing action-intent header")
        if cw_demo:
            with connect(db_path) as conn:
                conn.execute("DELETE FROM sessions WHERE token_hash=?", (sha256(cw_demo.encode()).hexdigest(),))
        response = JSONResponse({"ok": True})
        response.delete_cookie("cw_demo")
        return response

    @app.get("/api/me")
    def me(cw_demo: Annotated[str | None, Cookie()] = None):
        actor, _ = identity(cw_demo)
        return {"id": actor.id, "roles": sorted(actor.roles), "tenant": actor.tenant,
                "institution": DEMO_TENANTS[actor.tenant]["label"],
                "identity_mode": "UNVERIFIED_ROLE_SIMULATOR"}

    @app.get("/api/items")
    def items(cw_demo: Annotated[str | None, Cookie()] = None):
        actor, _ = identity(cw_demo)
        with connect(db_path) as conn:
            rows = conn.execute("SELECT state_json,version FROM items WHERE tenant=? ORDER BY id", (actor.tenant,)).fetchall()
        views=[]
        with connect(db_path) as conn:
            for row in rows:
                w=decode(row["state_json"])
                if not attest.check_custody(conn,w) or not check_log(w):
                    raise HTTPException(503,"Ledger custody verification failed")
                views.append(private_view(w,row["version"],actor))
        return views

    @app.post("/api/items")
    def create_item(body: NewItem, cw_demo: Annotated[str | None, Cookie()] = None,
                    x_cw_action: Annotated[str | None, Header()] = None):
        if x_cw_action != MUTATION_HEADER:
            raise HTTPException(403,"Missing action-intent header")
        actor, token_hash=identity(cw_demo)
        if "AUTHOR" not in actor.roles:raise HTTPException(403,"Only a human fixture author may create a proposal")
        payload_hash=sha256(body.model_dump_json().encode()).hexdigest()
        with connect(db_path) as conn:
            try:
                conn.execute("BEGIN IMMEDIATE")
                old=conn.execute("SELECT request_hash,item_id FROM creation_commands WHERE tenant=? AND token_hash=? AND command_id=?",
                                 (actor.tenant,token_hash,body.command_id)).fetchone()
                if old is not None:
                    if old["request_hash"] != payload_hash:
                        raise HTTPException(409,"Idempotency key reused for different proposal")
                    item_id=old["item_id"]
                    conn.commit()
                    w,v=get_item(actor.tenant,item_id)
                    return private_view(w,v,actor)
                prefix={"demo-campus":"SB","demo-hoa":"HOA","demo-city":"CIV"}[actor.tenant]
                item_id=f"{prefix}-{uuid4().hex[:10].upper()}"
                w=establish(item_id,actor.tenant,DEMO_TENANTS[actor.tenant]["jurisdiction"],"DEMO",
                            actor,body.text,Rules("fictional-rules-v1",quorum=2),
                            {"member1","member2","member3"},{"member1","member2","member3"})
                conn.execute("INSERT INTO items(tenant,id,version,state_json) VALUES (?,?,?,?)",
                             (actor.tenant,item_id,len(w.events),encode(w)))
                attest.add_journal(conn,w)
                conn.execute("INSERT INTO creation_commands VALUES (?,?,?,?,?)",
                             (actor.tenant,token_hash,body.command_id,payload_hash,item_id))
                conn.commit()
                return private_view(w,len(w.events),actor)
            except HTTPException:
                conn.rollback();raise
            except sqlite3.Error as exc:
                conn.rollback();raise HTTPException(500,"Failed to create proposal") from exc

    @app.get("/api/items/{item_id}")
    def item(item_id: str, cw_demo: Annotated[str | None, Cookie()] = None):
        actor, _ = identity(cw_demo)
        w, version = get_item(actor.tenant, item_id)
        return private_view(w, version, actor)

    @app.post("/api/items/{item_id}/commands")
    def command(item_id: str, body: Command,
                cw_demo: Annotated[str | None, Cookie()] = None,
                x_cw_action: Annotated[str | None, Header()] = None):
        if x_cw_action != MUTATION_HEADER:
            raise HTTPException(403, "Missing action-intent header")
        actor, token_hash = identity(cw_demo)
        if body.action not in ACTION_LABELS:
            raise HTTPException(422, "Unknown workflow action")
        with connect(db_path) as conn:
            try:
                conn.execute("BEGIN IMMEDIATE")
                idem = conn.execute("SELECT response_json,request_hash FROM commands WHERE tenant=? AND item_id=? AND token_hash=? AND command_id=?",
                                    (actor.tenant, item_id, token_hash, body.command_id)).fetchone()
                request_hash=sha256(body.model_dump_json().encode()).hexdigest()
                if idem is not None:
                    if idem["request_hash"] != request_hash:
                        raise HTTPException(409,"Idempotency key already used for a different command")
                    conn.commit()
                    return json.loads(idem["response_json"])
                row = conn.execute("SELECT state_json,version FROM items WHERE tenant=? AND id=?",
                                   (actor.tenant, item_id)).fetchone()
                if row is None:
                    raise HTTPException(404, "Unknown item in institution")
                version = row["version"]
                if version != body.expected_version:
                    raise HTTPException(409, f"Stale revision; current state version is {version}")
                w = decode(row["state_json"])
                if body.action in ("LOCK_MOTION","OPEN_BALLOT","CAST","CLOSE_BALLOT","CERTIFY") and not authority.rule_is_current(connect,db_path,w):
                    raise HTTPException(409,"Institution fixture rule authority revoked or obsolete")
                if not attest.check_custody(conn,w) or not check_log(w):
                    raise HTTPException(503,"Ledger custody verification failed")
                try:
                    if body.action == "AMEND":
                        w2 = amend(w, actor, (body.text or "").strip())
                    elif body.action == "CAST":
                        w2 = cast(w, actor, body.choice or "")
                    elif body.action == "CERTIFY":
                        w2 = certify(w, actor)
                    elif body.action == "PREPARE_PUBLICATION":
                        w2 = prepare_publication(w, actor)
                    elif body.action in ("REVIEW_PUBLICATION", "APPROVE_PUBLICATION_PREVIEW"):
                        # The underlying reducer decides first vs second reviewer.
                        if body.action != ("REVIEW_PUBLICATION" if not w.release_reviewers else "APPROVE_PUBLICATION_PREVIEW"):
                            raise ValueError("Wrong publication review stage")
                        w2 = approve_publication(w, actor)
                    elif body.action == "VOID":
                        w2 = abort(w, actor, (body.reason or "").strip())
                    else:
                        w2 = advance(w, actor, body.action)
                except PermissionError as exc:
                    raise HTTPException(403, str(exc)) from exc
                except ValueError as exc:
                    raise HTTPException(422, str(exc)) from exc
                if not check_log(w2) or len(w2.events) != len(w.events) + 1:
                    raise HTTPException(500, "Contract journal inconsistency")
                after = len(w2.events)
                result = private_view(w2, after, actor)
                updated=conn.execute("UPDATE items SET state_json=?,version=? WHERE tenant=? AND id=? AND version=?",
                             (encode(w2), after, actor.tenant, item_id, version))
                if updated.rowcount != 1:
                    raise HTTPException(409,"Concurrent modification rejected")
                attest.add_journal(conn,w2)
                if body.action in ("CERTIFY","APPROVE_PUBLICATION_PREVIEW"):
                    attest.issue_attestation(conn,w2,db_path)
                conn.execute("INSERT INTO commands(tenant,item_id,token_hash,command_id,request_hash,response_json) VALUES(?,?,?,?,?,?)",
                             (actor.tenant, item_id, token_hash, body.command_id,request_hash,
                              json.dumps(result, separators=(",", ":"))))
                conn.commit()
                return result
            except HTTPException:
                conn.rollback()
                raise
            except sqlite3.Error as exc:
                conn.rollback()
                raise HTTPException(500, "Transaction failure") from exc

    @app.get("/api/items/{item_id}/passport")
    def proof(item_id: str, cw_demo: Annotated[str | None, Cookie()] = None):
        actor, _ = identity(cw_demo)
        if not actor.roles.intersection({"CLERK", "AUDITOR", "PRESIDER", "RELEASE_REVIEWER"}):
            raise HTTPException(403, "Evidence export requires an authorized internal review role")
        w, _ = get_item(actor.tenant, item_id)
        if w.status not in ("CERTIFIED", "REJECTED", "PUBLICATION_REVIEW", "PUBLISHED"):
            raise HTTPException(409, "No decision to verify yet")
        claim, proof_data = passport(w), evidence(w)
        ok, failures = verify(claim, proof_data)
        with connect(db_path) as conn:
            signatures=attest.attestation_bundle(conn,w)
        return {"passport": claim, "evidence": proof_data,
                "local_attestations": signatures,
                "local_signature_consistent": bool(signatures) and all(x["verified_local_signature"] for x in signatures),
                "checker": {"consistent": ok, "errors": failures,
                            "source": "independent_checker.py (internal, unaudited)"},
                "classification": "FICTIONAL_DEMO_NOT_LEGALLY_BINDING"}

    @app.get("/api/public/decisions")
    def public_decisions():
        with connect(db_path) as conn:
            rows = conn.execute("SELECT state_json FROM items").fetchall()
        views=[]
        with connect(db_path) as conn:
            for row in rows:
                w=decode(row["state_json"])
                if not attest.check_custody(conn,w) or not check_log(w):
                    raise HTTPException(503,"Public record custody mismatch")
                if w.status=="PUBLISHED":
                    bundle=attest.attestation_bundle(conn,w)
                    if not bundle or not bundle[-1]["verified_local_signature"] or bundle[-1]["scope"]!="PUBLIC_PREVIEW":
                        raise HTTPException(503,"Public record missing demo release attestation")
                    views.append({**public_view(w),"demo_attestation":{k:bundle[-1][k] for k in ("signature","public_key","payload")}})
        return views

    @app.get("/api/public/decisions/{tenant}/{item_id}")
    def public_decision(tenant: str, item_id: str):
        if tenant not in DEMO_TENANTS:
            raise HTTPException(404, "Unknown fictional tenant")
        w, _ = get_item(tenant, item_id)
        with connect(db_path) as conn:
            bundle=attest.attestation_bundle(conn,w)
        if w.status!="PUBLISHED" or not bundle or not bundle[-1]["verified_local_signature"] or bundle[-1]["scope"]!="PUBLIC_PREVIEW":
            raise HTTPException(404,"No reviewed synthetic public record")
        return {**public_view(w),"demo_attestation":{k:bundle[-1][k] for k in ("signature","public_key","payload")}}

    civic.install_routes(app,connect,db_path,identity,DEMO_TENANTS)
    authority.install_routes(app,connect,db_path,identity,ROLES)
    history.install_routes(app,identity)
    return app


app = create_app()
