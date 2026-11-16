"""Historical representation and recorded roll-call explorer (FICTIONAL-only v0.3).

Canonical join is service term x district assignment x residence date x exact roll-call.
Never fill missing member positions or infer support for the underlying bill from a vote
on an amendment/procedural motion. This module has no external network/data importer.
"""
from __future__ import annotations

from collections import Counter, defaultdict
from datetime import date, datetime
from zoneinfo import ZoneInfo
from hashlib import sha256
from pathlib import Path
import json
from typing import Annotated, Any, Literal

from fastapi import APIRouter, Cookie, HTTPException, Query

FIXTURE = Path(__file__).resolve().parent / 'data' / 'history_synthetic.json'


def canonical_hash(value: Any) -> str:
    return sha256(json.dumps(value,ensure_ascii=False,sort_keys=True,separators=(',',':')).encode('utf-8')).hexdigest()


def date_value(value: str) -> date:
    try:
        if not isinstance(value,str) or len(value)!=10 or date.fromisoformat(value).isoformat()!=value:
            raise ValueError('expected YYYY-MM-DD')
        return date.fromisoformat(value)
    except (TypeError,ValueError) as exc:
        raise ValueError('invalid calendar date') from exc


def in_interval(day: str, start: str, until: str|None) -> bool:
    # ISO-8601 dates preserve chronological ordering. Intervals are [start,until).
    return start<=day and (until is None or day<until)


def overlap(start: str, until: str|None, left: str, right_inclusive: str) -> bool:
    return start<=right_inclusive and (until is None or until>left)


def validate_catalogue(d: dict) -> dict:
    if d.get('schema_version') != '0.3-synthetic' or d.get('assertions',{}).get('synthetic_only') is not True or d.get('assertions',{}).get('official_data') is not False:
        raise ValueError('invalid fixture mode: real-record ingestion prohibited')
    groups={g['id'] for g in d['groups']}
    parallel_groups={g['id'] for g in d['groups'] if g.get('multi_member') is True}
    if len(groups)!=len(d['groups']):raise ValueError('duplicate groups')
    profile_ids=set()
    for p in d['profiles']:
        if p['id'] in profile_ids:raise ValueError('duplicate profile')
        profile_ids.add(p['id']);date_value(p['birth_date'])
        for r in p['residences']:
            date_value(r['from']);
            if r['until'] is not None:
                date_value(r['until'])
                if r['until']<=r['from']:raise ValueError('reversed residence')
        for a in p['assignments']:
            if a['group'] not in groups:raise ValueError('unknown group assignment')
            date_value(a['from']);
            if a['until'] is not None:
                date_value(a['until'])
                if a['until']<=a['from']:raise ValueError('reversed district period')
        for i,a in enumerate(p['assignments']):
            if a['group'] in parallel_groups:continue  # Explicit multi-member/at-large constituencies
            for b in p['assignments'][i+1:]:
                if a['group']==b['group'] and overlap(a['from'],a['until'],b['from'],b['until'] or '9999-12-31') and overlap(b['from'],b['until'],a['from'],a['until'] or '9999-12-31'):
                    # Adjacent [start,end) intervals are permitted and don't overlap.
                    if (a['until'] is None or b['from']<a['until']) and (b['until'] is None or a['from']<b['until']):
                        raise ValueError('overlapping competing district assignments')
    terms_ids=set()
    member_ids=set()
    for term in d['terms']:
        if term['term_id'] in terms_ids:raise ValueError('duplicate term ID')
        terms_ids.add(term['term_id'])
        if term['group'] not in groups:raise ValueError('unknown official group')
        member_ids.add(term['official_id'])
        date_value(term['start'])
        if term['until'] is not None:
            date_value(term['until'])
            if term['until']<=term['start']:raise ValueError('reversed term')
    for i,a in enumerate(d['terms']):
        for b in d['terms'][i+1:]:
            if a['group']==b['group'] and a['seat']==b['seat'] and (a['until'] is None or b['start']<a['until']) and (b['until'] is None or a['start']<b['until']):
                raise ValueError('overlapping incumbents for one seat')
    ids=set()
    for v in d['rollcalls']:
        if v['id'] in ids:raise ValueError('duplicate roll-call identifier')
        ids.add(v['id']);date_value(v['date'])
        if v['group'] not in groups or v['motion_type'] not in {'FINAL_PASSAGE','AMENDMENT','PROCEDURAL','OTHER'}:
            raise ValueError('invalid motion metadata')
        if v['source_status']!='SYNTHETIC_UNVERIFIED' or v.get('source_url') is not None:
            raise ValueError('external source incorrectly advertised as verified in fixture')
        if not v['question'].strip() or not v['source_record_id'].strip():raise ValueError('missing motion/source')
        for member, position in v['positions'].items():
            if position not in {'YEA','NAY','PRESENT','ABSTAIN','NOT_VOTING','EXCUSED'}:raise ValueError('unknown vote choice')
            if member not in member_ids:raise ValueError('unrecognized member in roll call')
            members=[t for t in d['terms'] if t['official_id']==member and t['group']==v['group'] and in_interval(v['date'],t['start'],t['until'])]
            if len(members)!=1:raise ValueError('rollcall position must resolve to exactly one active service term')
    for p in d['profiles']:
        for a in p['assignments']:
            if not any(t['seat']==a['seat'] and t['group']==a['group'] for t in d['terms']):
                raise ValueError('unresolvable assigned seat')
    return d


def read_fixture() -> dict:
    return validate_catalogue(json.loads(FIXTURE.read_text()))


CATALOGUE = read_fixture()


def report(d:dict, *, profile_id:str='fictional-resident', from_date:str|None=None,
           to_date:str|None=None, group:str|None=None,
           mode:Literal['PERSONAL_HISTORY','CURRENT_SEATS']='PERSONAL_HISTORY',
           page:int=1,page_size:int=20, official_id:str|None=None, issue:str|None=None,
           today:date|None=None) -> dict:
    today=today or datetime.now(ZoneInfo('America/New_York')).date()
    prof=next((p for p in d['profiles'] if p['id']==profile_id),None)
    if prof is None:raise ValueError('unknown synthetic profile')
    if mode not in {'PERSONAL_HISTORY','CURRENT_SEATS'}:raise ValueError('unknown historical representation mode')
    if group is not None and group not in {g['id'] for g in d['groups']}:raise ValueError('unknown representative group')
    if page<1 or not 1<=page_size<=100:raise ValueError('invalid pagination')
    start=date_value(from_date or prof['birth_date'])
    end=date_value(to_date or today.isoformat())
    if end<start:raise ValueError('end date precedes start date')
    if end>today:raise ValueError('historical range cannot extend into future')
    if issue and len(issue)>100:raise ValueError('issue filter too long')
    if official_id and len(official_id)>100:raise ValueError('invalid member filter')
    groups={g['id']:g['label'] for g in d['groups']}
    assignments=prof['assignments']
    if mode=='CURRENT_SEATS':
        now=today.isoformat()
        assignments=[dict(a, **{'from':'0001-01-01','until':None}) for a in assignments if in_interval(now,a['from'],a['until'])]
    matches=[];unattributed=[];rows=[]
    def has_residence(day):
        return any(in_interval(day,r['from'],r['until']) for r in prof['residences'])
    def intersects_all(intervals):
        lo=max([start.isoformat()]+[a for a,b in intervals])
        return lo<=end.isoformat() and all(b is None or lo<b for a,b in intervals)
    for v in d['rollcalls']:
        if not start.isoformat()<=v['date']<=end.isoformat():continue
        if group and v['group']!=group:continue
        if issue and v['issue'].casefold()!=issue.casefold():continue
        if mode=='PERSONAL_HISTORY' and not has_residence(v['date']):continue
        seats={a['seat'] for a in assignments if a['group']==v['group'] and in_interval(v['date'],a['from'],a['until'])}
        if not seats:continue
        matched=False
        for term in d['terms']:
            if term['group']!=v['group'] or term['seat'] not in seats or not in_interval(v['date'],term['start'],term['until']):continue
            if official_id and term['official_id']!=official_id:continue
            matched=True
            recorded=term['official_id'] in v['positions']
            result={
                'rollcall_id':v['id'], 'date':v['date'], 'group':v['group'], 'group_label':groups[v['group']],
                'official_id':term['official_id'],'official_name':term['official_name'],
                'seat':term['seat'],'term_id':term['term_id'],'term_start':term['start'],'term_until':term['until'],
                'question':v['question'],'issue':v['issue'],'motion_type':v['motion_type'],
                'member_position':v['positions'].get(term['official_id'],'NO_INDIVIDUAL_RECORD'),
                'position_status':'RECORDED' if recorded else 'NOT_IN_SOURCE',
                'source_record_id':v['source_record_id'],'source_status':v['source_status'],
                'source_url':v['source_url'],
                'fixture_digest':canonical_hash({k:v[k] for k in v if k!='positions'} | {'positions':v['positions']}),
                'relationship':'REPRESENTED_DURING_VOTE' if mode=='PERSONAL_HISTORY' else 'HISTORICAL_HOLDER_OF_CURRENT_SEAT'
            }
            rows.append(result)
        if not matched and not official_id:
            unattributed.append({'rollcall_id':v['id'],'date':v['date'],'group':v['group'],
                                  'reason':'NO_MATCHING_SERVICE_TERM_IN_SYNTHETIC_CATALOGUE'})
    # Distinct official roster does not depend on whether that official appears on any recorded roll call.
    official_roster=[]
    for term in d['terms']:
        if group and term['group']!=group:continue
        if official_id and term['official_id']!=official_id:continue
        relevant=[a for a in assignments if a['group']==term['group'] and a['seat']==term['seat']]
        periods=[(a['from'],a['until']) for a in relevant]
        residence_periods=[(r['from'],r['until']) for r in prof['residences']] if mode=='PERSONAL_HISTORY' else [('0001-01-01',None)]
        if any(intersects_all([(term['start'],term['until']),a,r]) for a in periods for r in residence_periods):
            official_roster.append({k:term[k] for k in ('term_id','official_id','official_name','group','seat','start','until')})
    rows.sort(key=lambda x:(x['date'],x['group'],x['rollcall_id'],x['official_id']),reverse=True)
    selected=rows[(page-1)*page_size:page*page_size]
    by_group=Counter(r['group'] for r in rows)
    unknown=sum(r['position_status']=='NOT_IN_SOURCE' for r in rows)
    return {
        'mode':'FICTIONAL_DEMO','data_complete':False,'profile_label':prof['label'],
        'default_from_birth':prof['birth_date'],'scope':mode,
        'date_range':{'from':start.isoformat(),'to':end.isoformat()},
        'available_groups':[{'id':k,'label':v,'matched_record_count':by_group[k]} for k,v in groups.items()],
        'officials':official_roster,
        'total_recorded_member_positions':len(rows)-unknown,
        'total_missing_member_positions':unknown,
        'total_matched_rows':len(rows), 'unattributed':unattributed,
        'page':page,'page_size':page_size,'total_pages':(len(rows)+page_size-1)//page_size,
        'rows':selected,
        'coverage_notice':('Synthetic sample only: not a complete list of public votes or officials. '
          'Voice votes, unavailable records, and historical district gaps cannot be reconstructed as individual positions.'),
        'privacy_notice':'Only fictional residency/birth-date data is used. No real identity or residence is inferred.',
    }


def install_routes(app, identity):
    r=APIRouter()
    @r.get('/api/history/representation')
    def representation(
        cw_demo: Annotated[str|None,Cookie()]=None,
        from_date: Annotated[str|None,Query(alias='from')]=None,
        to_date: Annotated[str|None,Query(alias='to')]=None,
        group: str|None=None,mode: str='PERSONAL_HISTORY',
        page: int=1,page_size:int=20,official_id:str|None=None,issue:str|None=None,
    ):
        # Session is required to prevent exposing a future private user profile via anonymous queries.
        identity(cw_demo)
        try:return report(CATALOGUE,from_date=from_date,to_date=to_date,group=group,mode=mode,
                          page=page,page_size=page_size,official_id=official_id,issue=issue)
        except ValueError as exc:raise HTTPException(status_code=422,detail=str(exc)) from exc
    @r.get('/api/history/catalogue')
    def catalogue(cw_demo: Annotated[str|None,Cookie()]=None):
        identity(cw_demo)
        return {'mode':'FICTIONAL_DEMO','fixture_sha256':sha256(FIXTURE.read_bytes()).hexdigest(),
                'synthetic_only':True,'official_records_imported':False,
                'groups':CATALOGUE['groups'],'record_count':len(CATALOGUE['rollcalls']),
                'source_integrity':'locally hashed fixture only; no official external custody'}
    app.include_router(r)
