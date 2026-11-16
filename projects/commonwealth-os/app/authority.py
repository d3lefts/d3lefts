"""Institution-controlled DEMO capability registry; NOT verified human identity.

Grants are server-resident and revocable. Seed identities remain selectable by
anyone in this isolated synthetic demo; a real institution must connect an IdP.
"""
from __future__ import annotations
import json
import time
from fastapi import APIRouter, Cookie, Header, HTTPException
from pydantic import BaseModel, ConfigDict
from typing import Annotated


def prepare_authority(connect,db_path,tenants,roles):
    with connect(db_path) as c:
        c.executescript('''
        CREATE TABLE IF NOT EXISTS demo_grants (
          tenant TEXT NOT NULL, actor TEXT NOT NULL, capability TEXT NOT NULL,
          enabled INTEGER NOT NULL CHECK(enabled IN (0,1)), expires_at INTEGER NOT NULL DEFAULT 0,
          revision INTEGER NOT NULL DEFAULT 1, PRIMARY KEY(tenant,actor,capability));
        CREATE TABLE IF NOT EXISTS demo_rule_grants (
          tenant TEXT PRIMARY KEY, rules_version TEXT NOT NULL, enabled INTEGER NOT NULL CHECK(enabled IN(0,1)), revision INTEGER NOT NULL DEFAULT 1);
        CREATE TABLE IF NOT EXISTS demo_authority_audit (
          id INTEGER PRIMARY KEY AUTOINCREMENT, tenant TEXT NOT NULL, admin TEXT NOT NULL,
          event TEXT NOT NULL, subject TEXT NOT NULL, enabled INTEGER NOT NULL,
          revision INTEGER NOT NULL, timestamp INTEGER NOT NULL);
        CREATE TRIGGER IF NOT EXISTS demo_authority_no_update BEFORE UPDATE ON demo_authority_audit
          BEGIN SELECT RAISE(ABORT,'immutable authority audit'); END;
        CREATE TRIGGER IF NOT EXISTS demo_authority_no_delete BEFORE DELETE ON demo_authority_audit
          BEGIN SELECT RAISE(ABORT,'immutable authority audit'); END;
        ''')
        for tenant in tenants:
            c.execute('INSERT OR IGNORE INTO demo_rule_grants VALUES (?,?,1,1)',(tenant,'fictional-rules-v1'))
            for actor,caps in roles.items():
                for capability in caps:
                    c.execute('INSERT OR IGNORE INTO demo_grants(tenant,actor,capability,enabled) VALUES (?,?,?,1)',
                              (tenant,actor,capability))


def active_roles(connect,db_path,tenant,actor):
    with connect(db_path) as c:
        rows=c.execute('SELECT capability,enabled,expires_at FROM demo_grants WHERE tenant=? AND actor=?',(tenant,actor)).fetchall()
    now=int(time.time())
    return frozenset(r['capability'] for r in rows if r['enabled'] and (not r['expires_at'] or r['expires_at']>now))


def rule_is_current(connect,db_path,w):
    with connect(db_path) as c:
        row=c.execute('SELECT enabled,rules_version FROM demo_rule_grants WHERE tenant=?',(w.tenant,)).fetchone()
        return bool(row and row['enabled'] and row['rules_version']==w.rules.version)

class GrantUpdate(BaseModel):
    model_config=ConfigDict(extra='forbid')
    actor: str
    capability: str
    enabled: bool

class RuleUpdate(BaseModel):
    model_config=ConfigDict(extra='forbid')
    enabled: bool


def install_routes(app,connect,db_path,identity,roles):
    router=APIRouter()
    def admin(token,header=None,mutation=False):
        if mutation and header!='demo':raise HTTPException(403,'Missing simulated action-intent header')
        actor,_=identity(token)
        if 'INSTITUTION_ADMIN' not in actor.roles:raise HTTPException(403,'Institution admin fixture capability required')
        return actor

    @router.get('/api/admin/authority')
    def get_authority(cw_demo:Annotated[str|None,Cookie()]=None):
        a=admin(cw_demo)
        with connect(db_path) as c:
            grants=[dict(r) for r in c.execute('SELECT actor,capability,enabled,expires_at,revision FROM demo_grants WHERE tenant=? ORDER BY actor,capability',(a.tenant,))]
            rule=dict(c.execute('SELECT rules_version,enabled,revision FROM demo_rule_grants WHERE tenant=?',(a.tenant,)).fetchone())
            audit=[dict(r) for r in c.execute('SELECT event,subject,enabled,revision,timestamp FROM demo_authority_audit WHERE tenant=? ORDER BY id DESC LIMIT 25',(a.tenant,))]
        return {'tenant':a.tenant,'source':'GENERATED_AUTHORITY_FIXTURES','real_identity_verified':False,'grants':grants,'rule':rule,'audit':audit}

    @router.post('/api/admin/grants')
    def set_grant(body:GrantUpdate,cw_demo:Annotated[str|None,Cookie()]=None,x_cw_action:Annotated[str|None,Header()]=None):
        a=admin(cw_demo,x_cw_action,True)
        if body.actor not in roles or body.capability not in roles[body.actor] or body.actor=='institution_admin':
            raise HTTPException(422,'Fixture actor/capability not assignable')
        with connect(db_path) as c:
            c.execute('BEGIN IMMEDIATE')
            row=c.execute('SELECT revision FROM demo_grants WHERE tenant=? AND actor=? AND capability=?',(a.tenant,body.actor,body.capability)).fetchone()
            if not row:raise HTTPException(404,'Fixture grant not found')
            revision=row['revision']+1
            c.execute('UPDATE demo_grants SET enabled=?,revision=? WHERE tenant=? AND actor=? AND capability=?',(int(body.enabled),revision,a.tenant,body.actor,body.capability))
            c.execute('INSERT INTO demo_authority_audit(tenant,admin,event,subject,enabled,revision,timestamp) VALUES(?,?,?,?,?,?,?)',
                      (a.tenant,a.id,'GRANT_CHANGE',f'{body.actor}:{body.capability}',int(body.enabled),revision,int(time.time())))
            c.commit()
        return {'actor':body.actor,'capability':body.capability,'enabled':body.enabled,'revision':revision,'real_authorization':False}

    @router.post('/api/admin/rules')
    def set_rules(body:RuleUpdate,cw_demo:Annotated[str|None,Cookie()]=None,x_cw_action:Annotated[str|None,Header()]=None):
        a=admin(cw_demo,x_cw_action,True)
        with connect(db_path) as c:
            c.execute('BEGIN IMMEDIATE')
            row=c.execute('SELECT revision FROM demo_rule_grants WHERE tenant=?',(a.tenant,)).fetchone()
            revision=row['revision']+1
            c.execute('UPDATE demo_rule_grants SET enabled=?,revision=? WHERE tenant=?',(int(body.enabled),revision,a.tenant))
            c.execute('INSERT INTO demo_authority_audit(tenant,admin,event,subject,enabled,revision,timestamp) VALUES(?,?,?,?,?,?,?)',
                      (a.tenant,a.id,'RULE_STATUS','fictional-rules-v1',int(body.enabled),revision,int(time.time())))
            c.commit()
        return {'enabled':body.enabled,'revision':revision,'legal_authority':False}
    app.include_router(router)
