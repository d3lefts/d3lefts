"""Commonwealth OS civic layer for SYNTHETIC research participants only.

All prompts are unvalidated research drafts, all financial amounts fictional,
all participant responses generated, and no response can produce a ballot cast.
"""
from __future__ import annotations
from collections import Counter
from hashlib import sha256
import json
from pathlib import Path
import sqlite3
import time
from typing import Annotated

from fastapi import APIRouter, Cookie, Header, HTTPException
from pydantic import BaseModel, ConfigDict, Field

DATA = Path(__file__).resolve().parent / 'data'
PILOT = {'demo-campus':'UAH','demo-hoa':'HOA','demo-city':'HSV'}
ANSWERS = frozenset({'support','oppose','no_preference','need_information','not_applicable'})
K_ANON = 5

BUDGETS = {
 'demo-campus': {'fiscal_year':'Fictional year 1','currency':'USD','approved_budget':185000,
     'spent_to_date':94000,'lines':[('Student organization grants',68000,34200),('Community events',47000,26300),('Operations',40000,18300),('Reserve',30000,15200)]},
 'demo-hoa': {'fiscal_year':'Fictional year 1','currency':'USD','approved_budget':230000,
     'spent_to_date':124000,'lines':[('Landscaping',78000,43000),('Common area maintenance',69000,34500),('Utilities',48000,29000),('Reserve',35000,17500)]},
 'demo-city': {'fiscal_year':'Fictional year 1','currency':'USD','approved_budget':2500000,
     'spent_to_date':1015000,'lines':[('Sidewalk program',820000,290000),('Transportation',670000,300000),('Parks',510000,225000),('Reserve',500000,200000)]},
}
QUESTION_BANK = {k:json.loads((DATA/(p+'.json')).read_text()) for k,p in PILOT.items()}
assert all(len(x['questions']) == 24 for x in QUESTION_BANK.values())


def install_tables(connect, db_path):
    """Idempotent installation and deterministic fictional seed. Does not create real users."""
    with connect(db_path) as conn:
        conn.executescript('''
        CREATE TABLE IF NOT EXISTS civic_consents (
          tenant TEXT NOT NULL, actor TEXT NOT NULL, enabled INTEGER NOT NULL CHECK(enabled IN (0,1)),
          updated_at INTEGER NOT NULL, synthetic INTEGER NOT NULL CHECK(synthetic=1),
          PRIMARY KEY(tenant,actor));
        CREATE TABLE IF NOT EXISTS civic_responses (
          tenant TEXT NOT NULL, actor TEXT NOT NULL, question_id TEXT NOT NULL,
          question_version TEXT NOT NULL, answer TEXT NOT NULL,
          revised_at INTEGER NOT NULL, PRIMARY KEY(tenant,actor,question_id),
          FOREIGN KEY(tenant,actor) REFERENCES civic_consents(tenant,actor));
        CREATE TABLE IF NOT EXISTS civic_audit (
          seq INTEGER PRIMARY KEY AUTOINCREMENT, tenant TEXT NOT NULL, actor TEXT NOT NULL,
          action TEXT NOT NULL, question_id TEXT, ts INTEGER NOT NULL, digest TEXT NOT NULL);
        CREATE TRIGGER IF NOT EXISTS civic_audit_no_update BEFORE UPDATE ON civic_audit
          BEGIN SELECT RAISE(ABORT,'immutable audit'); END;
        CREATE TRIGGER IF NOT EXISTS civic_audit_no_delete BEFORE DELETE ON civic_audit
          BEGIN SELECT RAISE(ABORT,'immutable audit'); END;
        ''')
        # Generated, fictional profiles only; not consenting human subjects.
        for tenant,bank in QUESTION_BANK.items():
            for i in range(1,13):
                actor=f'constituent{i}'
                new_identity=conn.execute('INSERT OR IGNORE INTO civic_consents VALUES (?,?,?,?,?)',
                             (tenant,actor,1,0,1))
                if new_identity.rowcount != 1:
                    continue  # Never repopulate a fixture that later withdrew consent.
                for j,q in enumerate(bank['questions']):
                    # Deterministic fixtures: 12 virtual respondents and 24 questions.
                    answer=('support','support','oppose','no_preference','need_information')[(i*7+j*3)%5]
                    conn.execute('INSERT OR IGNORE INTO civic_responses VALUES (?,?,?,?,?,?)',
                                 (tenant,actor,q['id'],bank['version'],answer,0))


def _audit(conn,tenant,actor,action,question_id,answer=''):
    n=conn.execute('SELECT digest FROM civic_audit ORDER BY seq DESC LIMIT 1').fetchone()
    previous=n['digest'] if n else '0'*64
    ts=int(time.time())
    value=sha256(json.dumps([previous,tenant,actor,action,question_id,answer,ts],separators=(',',':')).encode()).hexdigest()
    conn.execute('INSERT INTO civic_audit(tenant,actor,action,question_id,ts,digest) VALUES(?,?,?,?,?,?)',
                 (tenant,actor,action,question_id,ts,value))


def bank_public(tenant):
    b=QUESTION_BANK[tenant]
    return {'pilot':b['pilot'],'version':b['version'],'certification':'UNVALIDATED_RESEARCH_DRAFT',
            'binding_vote':False,'legal_sources_verified':False,
            'questions':[{'id':q['id'],'domain':q['domain'],'question':q['question'],
                          'legal_status':q['legal_status'],'certification':q['certification']} for q in b['questions']]}


def budget(tenant):
    b=BUDGETS[tenant]
    return {**{k:v for k,v in b.items() if k!='lines'},
            'lines':[{'category':c,'appropriated':a,'spent':s} for c,a,s in b['lines']],
            'data_classification':'GENERATED_FICTIONAL_FINANCIAL_FIXTURE',
            'external_accounting_verified':False}


def summary(connect,db_path,tenant):
    with connect(db_path) as conn:
        respondents=conn.execute('SELECT COUNT(*) n FROM civic_consents WHERE tenant=? AND enabled=1 AND synthetic=1',(tenant,)).fetchone()['n']
        rows=conn.execute('''SELECT question_id,answer,COUNT(*) n FROM civic_responses
            JOIN civic_consents USING(tenant,actor)
            WHERE tenant=? AND enabled=1 AND synthetic=1
            GROUP BY question_id,answer''',(tenant,)).fetchall()
    tallies={}
    for row in rows:
        tallies.setdefault(row['question_id'],Counter())[row['answer']]=row['n']
    bank=QUESTION_BANK[tenant]
    qs=[]
    for q in bank['questions']:
        counts=tallies.get(q['id'],Counter())
        n=sum(counts.values())
        # A small cell is never published. In production use a formally reviewed
        # suppression strategy (including differencing attacks across versions).
        qs.append({'id':q['id'],'domain':q['domain'],'question':q['question'],
                   'respondents':n if n>=K_ANON else None,
                   'counts':dict(counts) if n>=K_ANON else None,
                   'suppressed':n<K_ANON})
    return {'tenant':tenant,'survey_mode':'FULLY_SYNTHETIC_NONBINDING',
            'participant_type':'GENERATED_TEST_FIXTURES_NOT_REAL_PEOPLE',
            'respondent_count':respondents if respondents>=K_ANON else None,
            'denominator':'12 generated fixture identities; not a population estimate',
            'sample_method':'deterministic_fixture','k_anonymity_threshold':K_ANON,
            'no_binding_votes':True,'question_version':bank['version'],'questions':qs}


class ConsentUpdate(BaseModel):
    model_config=ConfigDict(extra='forbid')
    enabled: bool

class AnswerUpdate(BaseModel):
    model_config=ConfigDict(extra='forbid')
    question_id: str=Field(min_length=3,max_length=40)
    answer: str=Field(min_length=3,max_length=32)
    question_version: str=Field(min_length=2,max_length=40)


def install_routes(app,connect,db_path,identity,demo_tenants):
    r=APIRouter()
    def constituent(token):
        actor,_=identity(token)
        if 'CONSTITUENT' not in actor.roles:
            raise HTTPException(403,'A fictional constituent role is required')
        return actor
    def authorize_post(header):
        if header!='demo':
            raise HTTPException(403,'Missing simulated action-intent header')

    @r.get('/api/civic/questions')
    def questions(cw_demo: Annotated[str|None,Cookie()]=None):
        actor,_=identity(cw_demo)
        return bank_public(actor.tenant)

    @r.get('/api/civic/finance')
    def finance(cw_demo: Annotated[str|None,Cookie()]=None):
        actor,_=identity(cw_demo)
        return budget(actor.tenant)

    @r.get('/api/civic/summary')
    def aggregate(cw_demo: Annotated[str|None,Cookie()]=None):
        actor,_=identity(cw_demo)
        return summary(connect,db_path,actor.tenant)

    @r.get('/api/civic/profile')
    def profile(cw_demo: Annotated[str|None,Cookie()]=None):
        actor=constituent(cw_demo)
        with connect(db_path) as conn:
            consent=conn.execute('SELECT enabled,updated_at FROM civic_consents WHERE tenant=? AND actor=?',(actor.tenant,actor.id)).fetchone()
            responses=conn.execute('SELECT question_id,answer,question_version FROM civic_responses WHERE tenant=? AND actor=? ORDER BY question_id',(actor.tenant,actor.id)).fetchall()
        return {'tenant':actor.tenant,'actor':actor.id,'synthetic_person':True,'consent_enabled':bool(consent['enabled']) if consent else False,
                'responses':[dict(row) for row in responses] if consent and consent['enabled'] else [],
                'scope':'NONBINDING_SURVEY_ONLY','delegation':None,'automated_vote_authority':False}

    @r.post('/api/civic/consent')
    def consent(body:ConsentUpdate,cw_demo: Annotated[str|None,Cookie()]=None,
                x_cw_action: Annotated[str|None,Header()]=None):
        authorize_post(x_cw_action)
        actor=constituent(cw_demo)
        with connect(db_path) as conn:
            conn.execute('BEGIN IMMEDIATE')
            conn.execute('INSERT INTO civic_consents(tenant,actor,enabled,updated_at,synthetic) VALUES(?,?,?,?,1) ON CONFLICT(tenant,actor) DO UPDATE SET enabled=excluded.enabled,updated_at=excluded.updated_at',
                         (actor.tenant,actor.id,int(body.enabled),int(time.time())))
            if not body.enabled:
                conn.execute('DELETE FROM civic_responses WHERE tenant=? AND actor=?',(actor.tenant,actor.id))
            _audit(conn,actor.tenant,actor.id,'CONSENT_ENABLED' if body.enabled else 'CONSENT_WITHDRAWN',None)
            conn.commit()
        return {'consent_enabled':body.enabled,'deleted_old_responses':not body.enabled,'scope':'NONBINDING_ONLY'}

    @r.post('/api/civic/responses')
    def respond(body:AnswerUpdate,cw_demo: Annotated[str|None,Cookie()]=None,
                x_cw_action: Annotated[str|None,Header()]=None):
        authorize_post(x_cw_action)
        actor=constituent(cw_demo)
        if body.answer not in ANSWERS: raise HTTPException(422,'Invalid survey answer')
        bank=QUESTION_BANK[actor.tenant]
        if body.question_version!=bank['version']: raise HTTPException(409,'Question revision has changed')
        if not any(q['id']==body.question_id for q in bank['questions']):
            raise HTTPException(404,'Question not in jurisdiction')
        with connect(db_path) as conn:
            conn.execute('BEGIN IMMEDIATE')
            row=conn.execute('SELECT enabled FROM civic_consents WHERE tenant=? AND actor=?',(actor.tenant,actor.id)).fetchone()
            if row is None or not row['enabled']:raise HTTPException(403,'Consent required')
            conn.execute('INSERT INTO civic_responses VALUES (?,?,?,?,?,?) ON CONFLICT(tenant,actor,question_id) DO UPDATE SET answer=excluded.answer,question_version=excluded.question_version,revised_at=excluded.revised_at',
                         (actor.tenant,actor.id,body.question_id,body.question_version,body.answer,int(time.time())))
            _audit(conn,actor.tenant,actor.id,'ANSWER_CHANGED',body.question_id,body.answer)
            conn.commit()
        return {'question_id':body.question_id,'answer':body.answer,'vote_cast':False,'authority':'ADVISORY_NONE'}

    @r.get('/api/public/commonwealth')
    def public_commonwealth():
        return {'classification':'ALL_VALUES_GENERATED_FICTIONAL','institutions':[
            {'id':tenant,'name':details['label'],'budget':budget(tenant),
             'survey':summary(connect,db_path,tenant)} for tenant,details in demo_tenants.items()],
            'public_data_only':True,'no_real_people':True,'no_real_municipal_records':True}

    app.include_router(r)
