"""Synthetic institutional authority, multiple docket items and release checks."""
import json
from pathlib import Path
from uuid import uuid4
import pytest
from fastapi.testclient import TestClient
from app.main import create_app
from app.verify_receipt import check

@pytest.fixture
def actors(tmp_path):
    app=create_app(str(tmp_path/'demo.db'))
    def user(role='author',tenant='demo-campus'):
        cli=TestClient(app)
        r=cli.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'actor':role,'tenant':tenant})
        assert r.status_code==200
        return cli
    return user

def post(cli,url,payload):return cli.post(url,headers={'X-CW-Action':'demo'},json=payload)

def run(cli,action,item='SB-014',**kw):
    state=cli.get('/api/items/'+item).json()
    return post(cli,f'/api/items/{item}/commands',{'action':action,'expected_version':state['version'],'command_id':str(uuid4()),**kw})

def test_create_many_items_and_access_boundary(actors):
    author=actors('author');other=actors('author','demo-hoa');constituent=actors('constituent1')
    created=[]
    for idx in range(3):
        r=post(author,'/api/items',{'text':f'Fictional proposal about community space {idx}','command_id':str(uuid4())})
        assert r.status_code==200,r.text
        assert r.json()['status']=='DRAFT'
        created.append(r.json()['id'])
    assert len(set(created))==3
    assert len(author.get('/api/items').json())==4
    assert other.get('/api/items/'+created[0]).status_code==404
    assert post(constituent,'/api/items',{'text':'A fictional public petition','command_id':str(uuid4())}).status_code==403
    assert post(author,'/api/items',{'text':'short','command_id':str(uuid4())}).status_code==422
    assert author.get('/api/items/'+created[0]).json()['event_count']==1

def test_create_idempotency_and_conflict(actors):
    a=actors('author')
    key='stable-create-key-for-test'
    same={'text':'A fictional new sports facility resolution','command_id':key}
    r=post(a,'/api/items',same); assert r.status_code==200
    assert post(a,'/api/items',same).json()['id']==r.json()['id']
    assert post(a,'/api/items',{**same,'text':'A completely different resolution'}).status_code==409
    assert len(a.get('/api/items').json())==2

def test_admin_revokes_and_restores_capability(actors):
    admin=actors('institution_admin');a=actors('author')
    assert 'INSTITUTION_ADMIN' in admin.get('/api/me').json()['roles']
    authority=admin.get('/api/admin/authority').json()
    assert authority['source']=='GENERATED_AUTHORITY_FIXTURES'
    assert len(authority['grants'])>=8
    assert a.get('/api/items/SB-014').status_code==200
    assert post(admin,'/api/admin/grants',{'actor':'author','capability':'AUTHOR','enabled':False}).status_code==200
    assert a.get('/api/me').status_code==403
    assert post(a,'/api/items',{'text':'A fictional proposal for testing','command_id':str(uuid4())}).status_code==403
    assert post(admin,'/api/admin/grants',{'actor':'author','capability':'AUTHOR','enabled':True}).status_code==200
    assert a.get('/api/me').status_code==200
    assert admin.get('/api/admin/authority').json()['audit'][0]['event']=='GRANT_CHANGE'

def test_admin_actions_isolated_and_protected(actors):
    admin=actors('institution_admin');c=actors('clerk');other=actors('institution_admin','demo-hoa')
    assert c.get('/api/admin/authority').status_code==403
    assert c.post('/api/admin/rules',headers={'X-CW-Action':'demo'},json={'enabled':False}).status_code==403
    assert post(admin,'/api/admin/grants',{'actor':'institution_admin','capability':'INSTITUTION_ADMIN','enabled':False}).status_code==422
    assert post(admin,'/api/admin/grants',{'actor':'member1','capability':'AUTHOR','enabled':False}).status_code==422
    assert post(other,'/api/admin/rules',{'enabled':False}).status_code==200
    assert admin.get('/api/admin/authority').json()['rule']['enabled']==1
    assert other.get('/api/admin/authority').json()['rule']['enabled']==0

def test_rule_revocation_blocks_ballot_and_restoration(actors):
    admin=actors('institution_admin');a=actors('author');clerk=actors('clerk');chair=actors('presider')
    for c,act in [(a,'SUBMIT_REVIEW'),(clerk,'SET_AGENDA'),(chair,'OPEN_DEBATE')]:
        assert run(c,act).status_code==200
    assert post(admin,'/api/admin/rules',{'enabled':False}).status_code==200
    result=run(chair,'LOCK_MOTION')
    assert result.status_code==409 and 'revoked' in result.json()['detail']
    assert post(admin,'/api/admin/rules',{'enabled':True}).status_code==200
    assert run(chair,'LOCK_MOTION').status_code==200
    assert run(chair,'OPEN_BALLOT').status_code==200
    member=actors('member1')
    assert post(admin,'/api/admin/grants',{'actor':'member1','capability':'MEMBER','enabled':False}).status_code==200
    assert member.get('/api/me').status_code==403
    assert run(chair,'CLOSE_BALLOT').status_code==200

def test_fake_receipt_public_boundary(actors):
    a=actors('author');clerk=actors('clerk');chair=actors('presider')
    for cli,action in [(a,'SUBMIT_REVIEW'),(clerk,'SET_AGENDA'),(chair,'OPEN_DEBATE'),(chair,'LOCK_MOTION'),(chair,'OPEN_BALLOT')]:
        assert run(cli,action).status_code==200
    for i,v in [(1,'AYE'),(2,'NAY'),(3,'ABSTAIN')]:
        assert run(actors('member'+str(i)),'CAST',choice=v).status_code==200
    for cli,action in [(chair,'CLOSE_BALLOT'),(clerk,'CERTIFY'),(clerk,'PREPARE_PUBLICATION'),(actors('reviewer1'),'REVIEW_PUBLICATION'),(actors('reviewer2'),'APPROVE_PUBLICATION_PREVIEW')]:
        assert run(cli,action).status_code==200
    with TestClient(a.app) as public:
        r=public.get('/api/public/decisions/demo-campus/SB-014');assert r.status_code==200
        p=r.json();assert p['legal_authority'] is False
        assert p['demo_attestation']['payload']['external_key_custody'] is False
        assert 'member1' not in json.dumps(p) and 'roster' not in json.dumps(p)
    exported=actors('auditor').get('/api/items/SB-014/passport').json()
    assert check(exported)==(True,())
    exported['evidence']['events'][2]['payload']['motion']='tampered'
    assert not check(exported)[0]
