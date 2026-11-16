"""Synthetic fixtures only. Includes independent negative checks of invariant boundaries."""
from copy import deepcopy
from dataclasses import replace
import sqlite3

import pytest
from fastapi.testclient import TestClient

from historical.adapters import FixtureAdapter, SyntheticOnlyError, load_all
from historical.api import create_app
from historical.engine import HistoricalEngine, connect, digest, ingest, initialize


@pytest.fixture
def env(tmp_path):
    path = str(tmp_path / 'historical.sqlite3')
    engine = HistoricalEngine(path)
    return engine, path, TestClient(create_app(path))


def modified(index, fn):
    snapshots = load_all()
    data = deepcopy(snapshots[index].payload)
    fn(data)
    snapshots[index] = replace(snapshots[index], payload=data, digest=digest(data))
    return snapshots


def test_only_four_fictional_sources_and_idempotent_replay(env):
    engine, path, client = env
    assert {s['system'] for s in engine.sources()} == {
        'SYNTH_HOUSE', 'SYNTH_SENATE', 'SYNTH_MUNICIPAL', 'SYNTH_ISSUES'}
    with connect(path) as conn:
        assert ingest(conn, load_all()) == {'status': 'UNCHANGED', 'source_count': 4}
        assert conn.execute('SELECT COUNT(*) FROM sources').fetchone()[0] == 4
        assert conn.execute('SELECT COUNT(*) FROM votes').fetchone()[0] == 14
    health = client.get('/api/v1/historical/health').json()
    assert health['real_government_data_connected'] is False
    assert health['official_ballots_supported'] is False
    assert client.get('/api/v1/historical/sources').headers['x-commonwealth-data-mode'] == 'SYNTHETIC_ONLY'
    assert len(client.get('/api/v1/historical/issues').json()['issues']) == 3


def test_tenure_boundary_not_present_day_after_exit(env):
    _, _, client = env
    base = '/api/v1/historical/representatives?chamber=HOUSE&district=07&as_of='
    before = client.get(base + '2025-01-02').json()['representatives']
    after = client.get(base + '2025-01-03').json()['representatives']
    assert [x['person_id'] for x in before] == ['fx-house-morgan']
    assert [x['person_id'] for x in after] == ['fx-house-sam']
    assert client.get(base + '2027-01-03').json()['representatives'] == []
    assert len(client.get('/api/v1/historical/representatives?chamber=SENATE&district=ALL').json()['representatives']) == 2


def test_dashboard_all_chambers_correct_vote_date_not_current_member(env):
    _, _, client = env
    rows = client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront').json()
    assert rows['total'] == 5
    questions = {x['question_id']: x for x in rows['entries']}
    house = questions['fx-house-roll-001']
    assert house['representatives_at_vote_date'][0]['person_id'] == 'fx-house-morgan'
    assert house['representatives_at_vote_date'][0]['position'] == 'YEA'
    assert house['direct_vote_comparison_permitted'] is True
    assert questions['fx-senate-roll-001']['relation'] == 'TOPIC_ONLY'
    assert questions['fx-senate-roll-001']['direct_vote_comparison_permitted'] is False
    senate = questions['fx-senate-roll-002']
    assert [r['position'] for r in senate['representatives_at_vote_date']] == ['YEA', 'NO_RECORDED_POSITION']
    assert all(e['source_completeness'].startswith('CURATED_SYNTHETIC') for e in rows['entries'])
    assert rows['historical_votes_are_user_ballots'] is False


def test_voice_vote_has_no_attributed_member_position(env):
    _, _, client = env
    row = next(x for x in client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront').json()['entries']
               if x['question_id'] == 'fx-city-voice-002')
    assert row['rollcall_type'] == 'VOICE'
    assert row['representatives_at_vote_date'][0]['position'] == 'VOICE_VOTE_NO_NAMED_POSITION'
    assert row['representatives_at_vote_date'][0]['vote_record_id'] is None


def test_missing_constituency_not_misreported_as_nay(env):
    _, _, client = env
    rows = client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront&house_district=99&municipal_ward=99').json()['entries']
    assert any(r['position'] == 'NO_MATCHING_TENURE'
               for item in rows for r in item['representatives_at_vote_date'])
    assert all(r['position'] != 'NAY' for item in rows
               for r in item['representatives_at_vote_date'] if r['person_id'] is None)
    after = client.get('/api/v1/historical/dashboard?issue_id=fx-issue-riverfront&as_of=2024-07-01').json()
    assert after['total'] == 1


def test_pagination_stability_unknown_issue_and_no_record(env):
    _, _, client = env
    a = client.get('/api/v1/historical/dashboard?limit=2&offset=0').json()
    b = client.get('/api/v1/historical/dashboard?limit=2&offset=2').json()
    assert a['total'] == 8 and b['total'] == 8 and a['next_offset'] == 2
    assert set(x['link_id'] for x in a['entries']).isdisjoint(x['link_id'] for x in b['entries'])
    assert client.get('/api/v1/historical/dashboard?issue_id=fx-issue-transit').json()['total'] == 0
    assert client.get('/api/v1/historical/dashboard?issue_id=fx-unknown').status_code == 404
    assert client.get('/api/v1/historical/dashboard?limit=101').status_code == 422
    assert client.get('/api/v1/historical/dashboard?house_district=not-a-district').status_code == 422
    assert client.get('/api/v1/historical/dashboard?as_of=2025-02-30').status_code == 422


def test_vote_immutability_and_exact_source_fingerprint(env):
    _, path, client = env
    vote = client.get('/api/v1/historical/votes/fx-s-vote-001a').json()['record']
    assert vote['choice'] == 'YEA'
    assert len(vote['digest']) == 64 and len(vote['source_digest']) == 64
    with connect(path) as conn:
        with pytest.raises(sqlite3.IntegrityError, match='immutable'):
            conn.execute("UPDATE votes SET choice='NAY' WHERE record_id='fx-s-vote-001a'")
        with pytest.raises(sqlite3.IntegrityError, match='immutable'):
            conn.execute("DELETE FROM votes WHERE record_id='fx-s-vote-001a'")
        assert conn.execute("SELECT choice FROM votes WHERE record_id='fx-s-vote-001a'").fetchone()[0] == 'YEA'


def test_adapter_rejects_non_allowlisted_and_url_inputs():
    with pytest.raises(SyntheticOnlyError):
        FixtureAdapter('https://clerk.house.gov')
    with pytest.raises(SyntheticOnlyError):
        FixtureAdapter('../real-records')


def test_invalid_overlap_fails_without_partial_commits(tmp_path):
    def attack(p):
        p['tenures'][1]['from'] = '2024-12-31'
    path = str(tmp_path/'bad.sqlite3')
    initialize(path)
    with connect(path) as conn:
        with pytest.raises(SyntheticOnlyError, match='Overlapping tenure'):
            ingest(conn, modified(0, attack))
        assert conn.execute('SELECT count(*) FROM sources').fetchone()[0] == 0


def test_wrong_date_vote_fails_closed(tmp_path):
    def attack(p):
        p['votes'][0]['person_id'] = 'fx-house-sam'  # successor, not in office in 2024
    path = str(tmp_path/'bad.sqlite3'); initialize(path)
    with connect(path) as conn:
        with pytest.raises(SyntheticOnlyError, match='Member not in office'):
            ingest(conn, modified(0, attack))
        assert conn.execute('SELECT count(*) FROM votes').fetchone()[0] == 0


def test_exaggerated_exact_mapping_rejected(tmp_path):
    def attack(p):
        p['correspondence'][1]['relation'] = 'EXACT_QUESTION'  # cloture is procedural
    path = str(tmp_path/'bad.sqlite3'); initialize(path)
    with connect(path) as conn:
        with pytest.raises(SyntheticOnlyError, match='EXACT_QUESTION'):
            ingest(conn, modified(3, attack))
        assert conn.execute('SELECT count(*) FROM correspondence').fetchone()[0] == 0


def test_voice_vote_cannot_gain_named_positions(tmp_path):
    def attack(p):
        p['votes'].append({'record_id': 'fx-illegal-voice-vote', 'question_id': 'fx-city-voice-002',
                           'person_id': 'fx-city-casey', 'choice': 'YEA'})
    path = str(tmp_path/'bad.sqlite3'); initialize(path)
    with connect(path) as conn:
        with pytest.raises(SyntheticOnlyError, match='recorded question'):
            ingest(conn, modified(2, attack))


def test_frozen_source_conflict_requires_version(tmp_path):
    path = str(tmp_path/'conflict.sqlite3')
    HistoricalEngine(path)
    snapshots = modified(1, lambda p: p['questions'][0].update({'title': 'Altered fixture!'}))
    with connect(path) as conn:
        with pytest.raises(SyntheticOnlyError, match='Frozen source changed'):
            ingest(conn, snapshots)
        assert conn.execute('SELECT count(*) FROM sources').fetchone()[0] == 4


def test_different_member_stances_do_not_imply_support(env):
    _, _, client = env
    rows = client.get('/api/v1/historical/dashboard?issue_id=fx-issue-stormwater').json()['entries']
    assert {x['relation'] for x in rows} == {'EXACT_QUESTION', 'SUBSTANTIVE_REVIEWED', 'UNREVIEWED'}
    assert sum(bool(x['direct_vote_comparison_permitted']) for x in rows) == 1
    assert all('inferred_support' not in x and 'party' not in x for x in rows)
