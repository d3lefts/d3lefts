"""HTTP integration tests for the fictional Commonwealth OS PWA.
No live voting identities or institutional data are used.
"""
from pathlib import Path
import sqlite3
from uuid import uuid4

import pytest
from fastapi.testclient import TestClient

from app.main import create_app

@pytest.fixture
def context(tmp_path):
    app = create_app(str(tmp_path / 'app.sqlite3'))
    def user(role='author',tenant='demo-campus'):
        c = TestClient(app)
        r = c.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'tenant':tenant,'actor':role})
        assert r.status_code == 200,r.text
        return c
    return app,user,tmp_path/'app.sqlite3'

def get(c,item='SB-014'):
    r=c.get('/api/items/'+item)
    assert r.status_code==200, r.text
    return r.json()

def apply(c,action,item='SB-014',version=None,command_id=None,**kwargs):
    body={'action':action,'expected_version':version or get(c,item)['version'],
          'command_id':command_id or str(uuid4()),**kwargs}
    return c.post('/api/items/'+item+'/commands',headers={'X-CW-Action':'demo'},json=body)

def progress_to_ballot(users):
    author,clerk,presider=users
    assert apply(author,'SUBMIT_REVIEW').status_code==200
    assert apply(clerk,'SET_AGENDA').status_code==200
    assert apply(presider,'OPEN_DEBATE').status_code==200
    assert apply(presider,'LOCK_MOTION').status_code==200
    assert apply(presider,'OPEN_BALLOT').status_code==200

def test_page_health_and_policy(context):
    app,user,db=context
    with TestClient(app) as c:
        html=c.get('/').text
        assert 'Legislative Workspace' in html
        assert '/static/app.js' in html
        assert c.get('/healthz').json()['official_voting_enabled'] is False
        assert c.get('/api/public/decisions').json()==[]
        assert c.get('/api/items').status_code==401
        assert c.post('/api/demo/login',json={'tenant':'demo-campus','actor':'author'}).status_code==403
        assert "default-src 'self'" in c.get('/').headers['content-security-policy']

def test_full_ui_to_contract_lifecycle(context):
    _,user,_=context
    a,k,p=user('author'),user('clerk'),user('presider')
    r1,r2=user('reviewer1'),user('reviewer2')
    voters=[user('member'+str(i)) for i in range(1,4)]
    assert get(a)['status']=='DRAFT'
    r=apply(a,'AMEND',text='Fictional expanded study spaces by 10 p.m.');assert r.status_code==200
    assert r.json()['revision']==2
    progress_to_ballot((a,k,p))
    assert get(p)['status']=='BALLOT_OPEN'
    assert [apply(v,'CAST',choice=choice).status_code for v,choice in zip(voters,['AYE','AYE','NAY'])]==[200]*3
    assert apply(p,'CLOSE_BALLOT').status_code==200
    assert apply(k,'CERTIFY').status_code==200
    assert get(k)['tally']=={'aye':2,'nay':1,'abstain':0}
    assert k.get('/api/items/SB-014/passport').json()['checker']['consistent'] is True
    assert apply(k,'PREPARE_PUBLICATION').status_code==200
    assert apply(r1,'REVIEW_PUBLICATION').status_code==200
    assert apply(r2,'APPROVE_PUBLICATION_PREVIEW').status_code==200
    assert len(k.get('/api/public/decisions').json())==1
    public=k.get('/api/public/decisions/demo-campus/SB-014').json()
    assert 'FICTIONAL' in public['label'] and public['outcome']=='PASSED'
    assert 'member1' not in str(public) and not any(k in public for k in ('casts','member','author','roster','attendance'))
    assert get(a)['status']=='PUBLISHED'
    assert a.get('/api/items/SB-014/passport').status_code==403

def test_atomic_versions_idempotency_and_roles(context):
    _,user,_=context
    author,presider,clerk=user('author'),user('presider'),user('clerk')
    start=get(author)['version']
    key='example-command-idempotency-key-001'
    r=apply(author,'SUBMIT_REVIEW',version=start,command_id=key)
    assert r.status_code==200
    assert apply(author,'SUBMIT_REVIEW',version=start,command_id=key).json()==r.json()
    assert get(author)['version']==start+1
    assert apply(author,'AMEND',version=start,text='wrong').status_code==409
    assert apply(presider,'SET_AGENDA').status_code==403
    assert apply(clerk,'SET_AGENDA').status_code==200
    assert apply(author,'AMEND',text='Revisions reset the review!').status_code==200
    assert get(author)['status']=='DRAFT' and get(author)['revision']==2
    assert apply(clerk,'SET_AGENDA').status_code==422

def test_cross_tenant_isolation(context):
    _,user,_=context
    h=user('author','demo-hoa')
    assert h.get('/api/items/SB-014').status_code==404
    assert h.post('/api/items/SB-014/commands',headers={'X-CW-Action':'demo'},json={'action':'SUBMIT_REVIEW','expected_version':1,'command_id':str(uuid4())}).status_code==404
    assert h.get('/api/items/HOA-008').json()['institution']=='Fictional Neighborhood Board'
    c=user('author','demo-city')
    assert c.get('/api/items/HOA-008').status_code==404
    assert c.get('/api/public/decisions').json()==[]

def test_vote_tamper_and_duplicate(context):
    _,user,_=context
    a,k,p=user('author'),user('clerk'),user('presider')
    v=user('member1')
    progress_to_ballot((a,k,p))
    assert apply(a,'AMEND',text='Late tamper').status_code==422
    assert apply(v,'CAST',choice='AYE').status_code==200
    assert apply(v,'CAST',choice='NAY').status_code==422
    assert apply(v,'CAST',choice='FAKE').status_code==422
    assert apply(p,'CLOSE_BALLOT').status_code==200
    assert apply(k,'CERTIFY').status_code==200
    assert get(k)['tally']=={'aye':1,'nay':0,'abstain':0}

def test_role_switch_is_not_authentication(context):
    _,user,_=context
    c=user('presider')
    assert c.get('/api/me').json()['identity_mode']=='UNVERIFIED_ROLE_SIMULATOR'
    assert c.get('/healthz').json()['municipal_record_ingestion_enabled'] is False
    assert c.get('/api/me').json()['tenant']=='demo-campus'

def test_persistence_after_app_restart(context):
    _,user,db=context
    a=user('author'); assert apply(a,'SUBMIT_REVIEW').status_code==200
    after=get(a)['version']
    new_app=create_app(str(db))
    with TestClient(new_app) as client:
        r=client.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'tenant':'demo-campus','actor':'author'})
        assert r.status_code==200
        assert get(client)['version']==after
        assert get(client)['status']=='IN_REVIEW'

def test_no_publication_before_review(context):
    _,user,_=context
    assert user('auditor').get('/api/public/decisions/demo-campus/SB-014').status_code==404

def test_concurrent_stale_version_rejected(context):
    _,user,_=context
    a=user('author'); version=get(a)['version']
    one=apply(a,'SUBMIT_REVIEW',version=version)
    two=apply(a,'SUBMIT_REVIEW',version=version)
    assert one.status_code==200 and two.status_code==409

def test_official_command_cannot_be_sent(context):
    _,user,_=context
    a=user('author'); version=get(a)['version']
    r=a.post('/api/items/SB-014/commands',headers={'X-CW-Action':'demo'},json={
      'action':'SUBMIT_REVIEW','expected_version':version,'command_id':str(uuid4()),'mode':'OFFICIAL'})
    assert r.status_code==422

def test_public_synthetic_riverfront_dossier(context):
    app, _, _ = context
    with TestClient(app) as client:
        page = client.get('/demo/riverfront')
        assert page.status_code == 200
        assert 'Fictional' in page.text and 'not a vote' in page.text
        assert client.get('/static/riverfront.js').status_code == 200
        result = client.get('/api/public/demo/dossiers/riverfront-001')
        assert result.status_code == 200, result.text
        body = result.json()
        assert body['verification']['status'] == 'MODEL_VALID'
        assert body['verification']['legal_authority'] == 'NOT_ASSESSED'
        assert [g['status'] for g in body['verification']['goals']] == [
            'MODEL_DERIVED', 'MODEL_DERIVED', 'INDETERMINATE']
        assert body['preference']['ballot_cast'] is False
        assert body['preference']['stored'] is False
        assert body['evidence'][0]['original_text'].startswith('Fictional ordinance Z-7')
        assert client.get('/api/demo/tenants').status_code == 200
        assert client.get('/api/public/decisions').json() == []
