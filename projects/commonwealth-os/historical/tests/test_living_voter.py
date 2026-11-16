"""Synthetic UI/API integration gates; does not certify voter identity or legal records."""
from pathlib import Path
from fastapi.testclient import TestClient
import pytest
from historical.api import create_app

@pytest.fixture
def client(tmp_path):
    with TestClient(create_app(str(tmp_path / 'historical.sqlite3'))) as c:
        yield c


def test_same_origin_living_voter_assets_and_policy(client):
    page = client.get('/living-voter')
    assert page.status_code == 200
    assert 'FICTIONAL DEMO' in page.text
    assert 'No location detection' in page.text
    assert '/living-voter/assets/app.mjs' in page.text
    assert "connect-src 'self'" in page.headers['content-security-policy']
    assert "frame-ancestors 'none'" in page.headers['content-security-policy']
    assert 'no-store' in page.headers['cache-control']
    for asset in ('app.mjs','model.mjs','styles.css'):
        r=client.get('/living-voter/assets/'+asset)
        assert r.status_code==200
        assert r.headers['x-commonwealth-data-mode']=='SYNTHETIC_ONLY'
    assert client.post('/api/v1/historical/dashboard').status_code==405
    assert client.get('/api/v1/historical/dashboard').headers['content-security-policy'] == "default-src 'none'; frame-ancestors 'none'"


def test_chamber_filter_applies_before_pagination(client):
    endpoint='/api/v1/historical/dashboard?chamber=HOUSE&limit=1&offset='
    zero=client.get(endpoint+'0').json()
    assert zero['total']==3
    assert len(zero['entries'])==1
    assert zero['entries'][0]['chamber']=='HOUSE'
    first=client.get(endpoint+'1').json()
    assert first['entries'][0]['chamber']=='HOUSE'
    assert zero['entries'][0]['question_id'] != first['entries'][0]['question_id']
    assert client.get('/api/v1/historical/dashboard?chamber=STATE').status_code==422


def test_issue_filter_and_chamber_filter_restrict_records(client):
    all_issues=client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront').json()
    assert all_issues['total']==5
    senate=client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront&chamber=SENATE').json()
    assert senate['total']==2
    assert {r['relation'] for r in senate['entries']}=={'TOPIC_ONLY','EXACT_QUESTION'}
    house=client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront&chamber=HOUSE').json()
    assert house['total']==1 and house['entries'][0]['relation']=='EXACT_QUESTION'
    none=client.get('/api/v1/historical/dashboard?issue_id=fx-issue-transit&chamber=HOUSE').json()
    assert none['total']==0


def test_disallowed_real_sources_and_private_profile_writes_are_absent(client):
    r=client.get('/api/v1/historical/health').json()
    assert r['data_mode']=='SYNTHETIC_ONLY'
    assert r['external_source_adapters_enabled'] is False
    assert r['real_government_data_connected'] is False
    assert client.post('/api/v1/historical/issues',json={'issue':'real'}).status_code==405
    assert client.post('/api/v1/historical/profile',json={'preference':'yes'}).status_code==404
    assert client.get('/api/v1/historical/dashboard?house_district=real').status_code==422
