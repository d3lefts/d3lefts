"""Synthetic-only questionnaire, financial transparency and local custody tests."""
import json
from pathlib import Path
import os
import sqlite3
from uuid import uuid4
from fastapi.testclient import TestClient
import pytest
from app.main import create_app
from app import attest
from app.verify_receipt import check

@pytest.fixture
def env(tmp_path):
    db=tmp_path/'cw.sqlite'
    app=create_app(str(db))
    def login(actor='constituent1',tenant='demo-campus'):
        c=TestClient(app)
        r=c.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'tenant':tenant,'actor':actor})
        assert r.status_code==200,r.text
        return c
    return app,db,login

def cmd(c,action,id='SB-014',**kwargs):
    v=c.get('/api/items/'+id).json()['version']
    return c.post(f'/api/items/{id}/commands',headers={'X-CW-Action':'demo'},json={'action':action,'command_id':str(uuid4()),'expected_version':v,**kwargs})

def post(c,path,obj):
    return c.post(path,headers={'X-CW-Action':'demo'},json=obj)

@pytest.mark.parametrize('tenant,item,prefix',[
 ('demo-campus','SB-014','UAH'),('demo-hoa','HOA-008','HOA'),('demo-city','CIV-021','HSV')])
def test_three_pilots_questionnaire_and_budget(env,tenant,item,prefix):
    _,_,login=env
    c=login('clerk',tenant)
    q=c.get('/api/civic/questions').json()
    assert len(q['questions'])==24
    assert len({x['id'] for x in q['questions']})==24
    assert all(x['id'].startswith(prefix) and x['certification']=='unvalidated' for x in q['questions'])
    assert q['binding_vote'] is False and q['legal_sources_verified'] is False
    b=c.get('/api/civic/finance').json()
    assert sum(x['appropriated'] for x in b['lines'])==b['approved_budget']
    assert sum(x['spent'] for x in b['lines'])==b['spent_to_date']
    assert b['external_accounting_verified'] is False
    assert c.get('/api/items/'+item).json()['id']==item
    assert c.get('/api/civic/summary').json()['respondent_count']==12

def test_private_profile_and_nonbinding_response(env):
    _,_,login=env
    c=login()
    p=c.get('/api/civic/profile').json()
    assert len(p['responses'])==24 and p['automated_vote_authority'] is False
    v=c.get('/api/items/SB-014').json()['version']
    q=c.get('/api/civic/questions').json(); qid=q['questions'][0]['id']
    r=post(c,'/api/civic/responses',{'question_id':qid,'answer':'oppose','question_version':q['version']})
    assert r.status_code==200 and r.json()['vote_cast'] is False
    assert c.get('/api/items/SB-014').json()['version']==v
    assert next(x['answer'] for x in c.get('/api/civic/profile').json()['responses'] if x['question_id']==qid)=='oppose'
    assert 'actor' not in json.dumps(c.get('/api/civic/summary').json())
    admin=login('author')
    assert admin.get('/api/civic/profile').status_code==403
    assert post(admin,'/api/civic/responses',{'question_id':qid,'answer':'oppose','question_version':q['version']}).status_code==403

def test_withdrawal_erasure_persists_across_restart(env):
    _,db,login=env
    c=login('constituent2')
    r=post(c,'/api/civic/consent',{'enabled':False});assert r.status_code==200
    assert c.get('/api/civic/profile').json()['responses']==[]
    q=c.get('/api/civic/questions').json();qid=q['questions'][0]['id']
    assert post(c,'/api/civic/responses',{'question_id':qid,'answer':'support','question_version':q['version']}).status_code==403
    new=create_app(str(db))
    cli=TestClient(new)
    cli.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'tenant':'demo-campus','actor':'constituent2'})
    assert cli.get('/api/civic/profile').json()['responses']==[]
    assert post(cli,'/api/civic/consent',{'enabled':True}).status_code==200
    assert cli.get('/api/civic/profile').json()['responses']==[]

def test_invalid_questions_and_cross_tenant(env):
    _,_,login=env
    c=login('constituent1','demo-hoa')
    q=c.get('/api/civic/questions').json()
    for obj,status in [({'question_id':'UAH-G01','answer':'support','question_version':q['version']},404),
                       ({'question_id':'HOA-G01','answer':'support','question_version':'stale-v0'},409),
                       ({'question_id':'HOA-G01','answer':'UNSAFE','question_version':q['version']},422)]:
        assert post(c,'/api/civic/responses',obj).status_code==status
    assert c.post('/api/civic/consent',json={'enabled':False}).status_code==403
    assert c.post('/api/civic/consent',headers={'X-CW-Action':'demo'},json={'enabled':False,'admin':True}).status_code==422

def test_aggregate_threshold_and_public_privacy(env):
    _,_,login=env
    for i in range(1,9):
        c=login(f'constituent{i}')
        assert post(c,'/api/civic/consent',{'enabled':False}).status_code==200
    a=login('clerk')
    s=a.get('/api/civic/summary').json()
    assert s['respondent_count'] is None
    assert all(x['suppressed'] and x['counts'] is None for x in s['questions'])
    with TestClient(env[0]) as public:
        d=public.get('/api/public/commonwealth').json()
        assert d['no_real_people'] is True and d['no_real_municipal_records'] is True
        assert 'constituent1' not in json.dumps(d)
        assert 'member1' not in json.dumps(d)
        assert 'civic_responses' not in json.dumps(d)
        assert d['institutions'][0]['survey']['questions'][0]['counts'] is None

def _complete(env):
    _,_,login=env
    a=login('author');k=login('clerk');p=login('presider')
    for actor,action in [(a,'SUBMIT_REVIEW'),(k,'SET_AGENDA'),(p,'OPEN_DEBATE'),(p,'LOCK_MOTION'),(p,'OPEN_BALLOT')]:
        assert cmd(actor,action).status_code==200
    for i,v in [(1,'AYE'),(2,'AYE'),(3,'NAY')]:
        assert cmd(login(f'member{i}'),'CAST',choice=v).status_code==200
    for actor,action in [(p,'CLOSE_BALLOT'),(k,'CERTIFY'),(k,'PREPARE_PUBLICATION'),(login('reviewer1'),'REVIEW_PUBLICATION'),(login('reviewer2'),'APPROVE_PUBLICATION_PREVIEW')]:
        assert cmd(actor,action).status_code==200
    return login('auditor')

def test_local_attestation_and_offline_verifier(env):
    _,db,login=env
    c=_complete(env)
    r=c.get('/api/items/SB-014/passport').json()
    assert r['checker']['consistent'] is True
    assert r['local_signature_consistent'] is True
    assert len(r['local_attestations'])==2
    assert all(x['verified_local_signature'] for x in r['local_attestations'])
    assert check(r)==(True,())
    r['local_attestations'][-1]['signature']='invalid'
    assert not check(r)[0]
    assert os.stat(str(db)+'.demo-ed25519').st_mode & 0o077 == 0

def test_append_only_custody_ledger_and_tampering(env):
    _,db,login=env
    c=login('author')
    assert cmd(c,'SUBMIT_REVIEW').status_code==200
    with sqlite3.connect(str(db)) as sql:
        with pytest.raises(sqlite3.DatabaseError):
            sql.execute("UPDATE journal_entries SET event_hash='fake' WHERE seq=1")
        with pytest.raises(sqlite3.DatabaseError):
            sql.execute('DELETE FROM journal_entries')
    with sqlite3.connect(str(db)) as sql:
        sql.execute('DELETE FROM items WHERE 0')
        sql.execute("UPDATE items SET state_json=replace(state_json,'IN_REVIEW','DRAFT') WHERE tenant='demo-campus'")
    assert c.get('/api/items').status_code==503
    assert c.get('/api/items/SB-014').status_code==503

def test_idempotency_key_reuse_with_different_body_rejected(env):
    _,_,login=env
    c=login('author')
    key='same-command-id-but-not-same-payload'
    v=c.get('/api/items/SB-014').json()['version']
    def send(txt):return post(c,'/api/items/SB-014/commands',{'action':'AMEND','text':txt,'expected_version':v,'command_id':key})
    assert send('Original content').status_code==200
    assert send('Different content').status_code==409
    assert send('Original content').status_code==200

def test_synthetic_role_cannot_cast_official_ballot(env):
    _,_,login=env
    c=login('constituent1')
    assert c.get('/api/me').json()['identity_mode']=='UNVERIFIED_ROLE_SIMULATOR'
    assert cmd(c,'CAST',choice='AYE').status_code in (403,422)
    assert cmd(c,'OPEN_BALLOT').status_code in (403,422)
    assert c.get('/healthz').json()['official_voting_enabled'] is False
