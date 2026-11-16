"""Historical representation demonstration: exact dated joins, no inferred vote positions."""
from copy import deepcopy
from datetime import date

from fastapi.testclient import TestClient
import pytest

from app.history import CATALOGUE, canonical_hash, report, validate_catalogue
from app.main import create_app

TODAY=date(2026,11,15)


def query(**kw):
    kw.setdefault('page_size',100)
    return report(CATALOGUE,today=TODAY, **kw)


def test_fixture_is_fictional_and_valid():
    validate_catalogue(CATALOGUE)
    assert CATALOGUE['assertions']=={'synthetic_only':True,'official_data':False,'complete_archive':False,'real_identity':False}
    assert len(CATALOGUE['rollcalls'])==38
    assert len(CATALOGUE['terms'])==21
    assert all(v['source_url'] is None for v in CATALOGUE['rollcalls'])


def test_default_birth_date_excludes_prebirth_and_respects_today():
    q=query()
    assert q['date_range']=={'from':'1998-08-24','to':'2026-11-15'}
    assert q['data_complete'] is False
    assert all('1998-08-24'<=r['date']<='2026-11-15' for r in q['rows'])
    assert not any(r['rollcall_id'].endswith('-V001') for r in q['rows'] if r['group']=='US_SENATE')


def test_custom_prebirth_does_not_invent_residence():
    q=query(from_date='1993-01-01',to_date='1995-01-01',mode='PERSONAL_HISTORY')
    assert q['total_matched_rows']==0
    assert q['officials']==[]


def test_current_seat_browsing_before_birth_is_labeled_not_representative():
    q=query(from_date='1993-01-01',to_date='1995-01-01',mode='CURRENT_SEATS',group='US_SENATE')
    assert q['total_matched_rows']==2
    assert {r['official_name'] for r in q['rows']}=={'Elena Vale','Hollis Reed'}
    assert {r['relationship'] for r in q['rows']}=={'HISTORICAL_HOLDER_OF_CURRENT_SEAT'}


def test_senate_dual_seats_and_successive_officeholders():
    pre=query(from_date='1999-01-01',to_date='1999-12-31',group='US_SENATE')
    post=query(from_date='2023-01-01',to_date='2026-11-15',group='US_SENATE')
    assert {r['official_id'] for r in pre['rows']}=={'sen-a0','sen-b0'}
    assert {r['official_id'] for r in post['rows']}=={'sen-a1','sen-b2'}


def test_congressional_district_changes_and_move_join_historical_seat():
    expected={'2011':'EX-HOUSE-01','2015':'EX-HOUSE-02','2019':'EX-HOUSE-04','2023':'EX-HOUSE-05'}
    for year,seat in expected.items():
        q=query(from_date=year+'-01-01',to_date=year+'-12-31',group='US_HOUSE')
        assert len(q['rows'])==1
        assert q['rows'][0]['seat']==seat


def test_city_officeholder_changes_after_move():
    early=query(from_date='2016-01-01',to_date='2016-12-31',group='CITY_COUNCIL')
    late=query(from_date='2019-01-01',to_date='2019-12-31',group='CITY_COUNCIL')
    assert early['rows'][0]['official_name']=='Lena Marsh'
    assert late['rows'][0]['official_name']=='Micah Quinn'


def test_missing_member_position_is_unknown_not_nonvoting():
    q=query(from_date='2023-10-09',to_date='2023-10-09',group='US_SENATE')
    m=next(r for r in q['rows'] if r['official_id']=='sen-b2')
    assert m['member_position']=='NO_INDIVIDUAL_RECORD'
    assert m['position_status']=='NOT_IN_SOURCE'
    assert q['total_missing_member_positions']==1
    assert q['total_recorded_member_positions']==1


def test_explicit_not_voting_distinct_from_absent_record():
    q=query(from_date='2026-03-18',to_date='2026-03-18',group='US_SENATE')
    m=next(r for r in q['rows'] if r['official_id']=='sen-b2')
    assert m['member_position']=='NOT_VOTING' and m['position_status']=='RECORDED'


def test_amendment_and_procedural_are_not_relabelled_final_passage():
    q=query(group='US_HOUSE')
    assert any(r['motion_type']=='AMENDMENT' for r in q['rows'])
    assert any(r['motion_type']=='PROCEDURAL' for r in q['rows'])
    assert all(r['motion_type'] in {'AMENDMENT','PROCEDURAL','FINAL_PASSAGE'} for r in q['rows'])


def test_no_overall_personalized_alignment_ranking():
    q=query()
    assert not any(k in q for k in ('alignment','ranking','official_score','best_representative'))
    assert q['coverage_notice'].startswith('Synthetic sample only')


def test_group_filters_and_page_slices_are_stable():
    a=report(CATALOGUE,today=TODAY,page=1,page_size=7)
    b=report(CATALOGUE,today=TODAY,page=2,page_size=7)
    full=query()
    assert a['total_matched_rows']==b['total_matched_rows']==full['total_matched_rows']
    assert [r['rollcall_id']+r['official_id'] for r in a['rows']+b['rows']]==[r['rollcall_id']+r['official_id'] for r in full['rows'][:14]]


def test_filter_member_spanning_multiple_terms():
    q=query(group='US_SENATE',official_id='sen-a1')
    assert all(r['official_id']=='sen-a1' for r in q['rows'])
    assert {t['term_id'] for t in q['officials']}=={'sen-a1-2007-01-03','sen-a1-2015-01-03'}


def test_invalid_range_and_calendar_dates_fail_closed():
    for kw in [{'from_date':'2025-02-30'}, {'from_date':'2027-01-01'},
               {'from_date':'2022-01-01','to_date':'2021-12-31'},
               {'group':'NOT_A_GROUP'}, {'mode':'OFFICIAL'},
               {'page':0},{'page_size':101}, {'from_date':'2025/01/01'}]:
        with pytest.raises(ValueError):query(**kw)


def test_forged_official_source_status_not_accepted():
    d=deepcopy(CATALOGUE);d['rollcalls'][0]['source_status']='OFFICIAL_VERIFIED'
    with pytest.raises(ValueError):validate_catalogue(d)


def test_vote_position_of_member_outside_service_rejected():
    d=deepcopy(CATALOGUE);d['rollcalls'][-1]['positions']={'sen-b0':'YEA'}
    with pytest.raises(ValueError):validate_catalogue(d)


def test_overlapping_two_officeholders_same_seat_rejected():
    d=deepcopy(CATALOGUE)
    d['terms'][0]['until']='2008-01-03'
    with pytest.raises(ValueError):validate_catalogue(d)


def test_transferring_old_vote_to_successor_not_permitted():
    d=deepcopy(CATALOGUE)
    # At 1994-05-02 the member "sen-a1" is not yet serving.
    senate=next(x for x in d['rollcalls'] if x['id']=='US_SENATE-V001')
    senate['positions']['sen-a1']='YEA'
    with pytest.raises(ValueError):validate_catalogue(d)


def test_all_groups_and_provenance_identifiers():
    q=query()
    assert len(q['available_groups'])==7
    for r in q['rows']:
        assert len(r['fixture_digest'])==64
        assert r['source_status']=='SYNTHETIC_UNVERIFIED'
        assert r['source_url'] is None
        assert r['source_record_id'].startswith('FICTIONAL-')


def test_api_rejects_anonymous_history_and_future_date(tmp_path):
    c=TestClient(create_app(str(tmp_path/'demo.sqlite3')))
    assert c.get('/api/history/representation').status_code==401
    assert c.get('/api/history/catalogue').status_code==401
    assert c.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'tenant':'demo-campus','actor':'author'}).status_code==200
    result=c.get('/api/history/representation')
    assert result.status_code==200
    assert result.json()['mode']=='FICTIONAL_DEMO'
    assert c.get('/api/history/representation',params={'to':'2035-01-01'}).status_code==422
    assert c.get('/api/history/catalogue').json()['official_records_imported'] is False


def test_api_group_filter_is_not_tenant_authority(tmp_path):
    c=TestClient(create_app(str(tmp_path/'demo.sqlite3')))
    c.post('/api/demo/login',headers={'X-CW-Action':'demo'},json={'tenant':'demo-hoa','actor':'auditor'})
    q=c.get('/api/history/representation',params={'group':'CITY_COUNCIL','from':'2018-01-01','to':'2020-01-01'})
    assert q.status_code==200
    assert all(r['group']=='CITY_COUNCIL' for r in q.json()['rows'])
    assert not q.json()['data_complete']


def test_residence_gap_cannot_claim_representation():
    d=deepcopy(CATALOGUE)
    d['profiles'][0]['residences']=[{'from':'1998-08-24','until':'2010-01-01','label':'fictional early residence'},
                                  {'from':'2024-01-01','until':None,'label':'fictional later residence'}]
    validate_catalogue(d)
    q=report(d,today=TODAY,from_date='2011-01-01',to_date='2011-12-31',group='US_SENATE')
    assert q['total_matched_rows']==0 and q['officials']==[]


def test_multi_member_group_assignment_supported():
    d=deepcopy(CATALOGUE)
    p=d['profiles'][0]
    p['assignments'].append({'group':'CITY_COUNCIL','seat':'EX-CITY-N1', 'from':'2018-07-01',
                            'until':None,'basis':'fictional at-large election overlap'})
    validate_catalogue(d)  # Councils can include separately assigned at-large seats.
    r=report(d,today=TODAY,from_date='2019-01-01',to_date='2019-12-31',group='CITY_COUNCIL')
    assert r['total_matched_rows']==1  # old seat holder's term ended: no invented successor
