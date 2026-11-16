"""Create purely fictional historical service/roll-call fixture. Not government data."""
import json
from pathlib import Path

DATA = {
 "schema_version":"0.3-synthetic",
 "assertions":{"synthetic_only":True,"official_data":False,"complete_archive":False,"real_identity":False},
 "profiles":[{
  "id":"fictional-resident", "label":"Fictional resident (example profile)","birth_date":"1998-08-24",
  "residences":[{"from":"1998-08-24","until":"2018-07-01","label":"Northbank (fictional)"},{"from":"2018-07-01","until":None,"label":"Southport (fictional)"}],
  "assignments":[
   {"group":"US_SENATE","seat":"EX-SEN-A","from":"1998-08-24","until":None,"basis":"fictional state residence"},
   {"group":"US_SENATE","seat":"EX-SEN-B","from":"1998-08-24","until":None,"basis":"fictional state residence"},
   {"group":"US_HOUSE","seat":"EX-HOUSE-01","from":"1998-08-24","until":"2012-01-03","basis":"fictional district map v1"},
   {"group":"US_HOUSE","seat":"EX-HOUSE-02","from":"2012-01-03","until":"2018-07-01","basis":"fictional redistricting v2"},
   {"group":"US_HOUSE","seat":"EX-HOUSE-04","from":"2018-07-01","until":"2022-01-03","basis":"fictional change of residence"},
   {"group":"US_HOUSE","seat":"EX-HOUSE-05","from":"2022-01-03","until":None,"basis":"fictional redistricting v3"},
   {"group":"STATE_HOUSE","seat":"EX-STATE-LOWER-1","from":"1998-08-24","until":"2018-07-01","basis":"fictional state district"},
   {"group":"STATE_HOUSE","seat":"EX-STATE-LOWER-2","from":"2018-07-01","until":None,"basis":"fictional state district"},
   {"group":"STATE_SENATE","seat":"EX-STATE-UPPER-1","from":"1998-08-24","until":None,"basis":"fictional state district"},
   {"group":"COUNTY_COMMISSION","seat":"EX-COUNTY-D1","from":"1998-08-24","until":"2018-07-01","basis":"fictional county"},
   {"group":"COUNTY_COMMISSION","seat":"EX-COUNTY-D2","from":"2018-07-01","until":None,"basis":"fictional county"},
   {"group":"CITY_COUNCIL","seat":"EX-CITY-N1","from":"1998-08-24","until":"2018-07-01","basis":"fictional municipality"},
   {"group":"CITY_COUNCIL","seat":"EX-CITY-S2","from":"2018-07-01","until":None,"basis":"fictional municipality"},
   {"group":"SCHOOL_BOARD","seat":"EX-SCHOOL-A","from":"1998-08-24","until":None,"basis":"fictional school district"}
  ]
 }],
 "groups":[
  {"id":"US_HOUSE","label":"U.S. House (fictional)"},
  {"id":"US_SENATE","label":"U.S. Senate (fictional)","multi_member":True},
  {"id":"STATE_HOUSE","label":"State House (fictional)"},
  {"id":"STATE_SENATE","label":"State Senate (fictional)"},
  {"id":"COUNTY_COMMISSION","label":"County Commission (fictional)","multi_member":True},
  {"id":"CITY_COUNCIL","label":"City Council (fictional)","multi_member":True},
  {"id":"SCHOOL_BOARD","label":"School Board (fictional)","multi_member":True}
 ],"terms":[],"rollcalls":[]
}

def add_term(oid, name, group, seat, start, until=None):
    DATA['terms'].append(dict(term_id=oid+'-'+start,official_id=oid,official_name=name,group=group,seat=seat,start=start,until=until))

for t in [
 ('sen-a0','Elena Vale','US_SENATE','EX-SEN-A','1989-01-03','2007-01-03'),
 ('sen-a1','Morgan Hall','US_SENATE','EX-SEN-A','2007-01-03','2015-01-03'),
 ('sen-a1','Morgan Hall','US_SENATE','EX-SEN-A','2015-01-03',None),
 ('sen-b0','Hollis Reed','US_SENATE','EX-SEN-B','1989-01-03','2003-01-03'),
 ('sen-b1','Ren Lee','US_SENATE','EX-SEN-B','2003-01-03','2023-01-03'),
 ('sen-b2','Amara Stone','US_SENATE','EX-SEN-B','2023-01-03',None),
 ('house-1a','Taylor Wren','US_HOUSE','EX-HOUSE-01','1990-01-03','2005-01-03'),
 ('house-1b','Rowan Park','US_HOUSE','EX-HOUSE-01','2005-01-03','2012-01-03'),
 ('house-2','Inez Cole','US_HOUSE','EX-HOUSE-02','2012-01-03','2018-07-01'),
 ('house-4','Sasha Reed','US_HOUSE','EX-HOUSE-04','2018-07-01','2022-01-03'),
 ('house-5','Avery Chen','US_HOUSE','EX-HOUSE-05','2022-01-03',None),
 ('lower-1','Kiran Holt','STATE_HOUSE','EX-STATE-LOWER-1','1990-01-03','2018-07-01'),
 ('lower-2','Jules North','STATE_HOUSE','EX-STATE-LOWER-2','2018-07-01',None),
 ('upper-1','Cameron Bell','STATE_SENATE','EX-STATE-UPPER-1','1990-01-03','2012-01-03'),
 ('upper-2','Riley Gray','STATE_SENATE','EX-STATE-UPPER-1','2012-01-03',None),
 ('county-1','Nadia Brooks','COUNTY_COMMISSION','EX-COUNTY-D1','1990-01-03','2018-07-01'),
 ('county-2','Sol Kim','COUNTY_COMMISSION','EX-COUNTY-D2','2018-07-01',None),
 ('city-1','Lena Marsh','CITY_COUNCIL','EX-CITY-N1','1990-01-03','2018-07-01'),
 ('city-2','Micah Quinn','CITY_COUNCIL','EX-CITY-S2','2018-07-01',None),
 ('school-1','Dana Fields','SCHOOL_BOARD','EX-SCHOOL-A','1990-01-03','2015-01-03'),
 ('school-2','Alex Rivera','SCHOOL_BOARD','EX-SCHOOL-A','2015-01-03',None)
]: add_term(*t)

def active(d, group):
    return [x['official_id'] for x in DATA['terms'] if x['group']==group and x['start']<=d and (x['until'] is None or d<x['until'])]

def vote(record_id,date,group,question,action,topic,positions=None, missing=(), source_ref=None):
    positions = dict(positions or {})
    for p in missing:
        positions.pop(p,None)
    DATA['rollcalls'].append(dict(id=record_id,date=date,group=group,question=question,
        motion_type=action,issue=topic,source_record_id=source_ref or f'FICTIONAL-{record_id}',
        source_status='SYNTHETIC_UNVERIFIED',source_url=None,positions=positions))

# Federal votes are per chamber, with named positions for all mocked members; no inference for absent names.
for i,(dt,topic,act,question) in enumerate([
 ('1994-05-02','Transport','FINAL_PASSAGE','Fictional intercity service authorization'),
 ('1999-06-17','Housing','AMENDMENT','Fictional zoning amendment (not final bill passage)'),
 ('2004-11-19','Education','FINAL_PASSAGE','Fictional scholarship bill'),
 ('2011-03-14','Infrastructure','FINAL_PASSAGE','Fictional bridge maintenance act'),
 ('2015-07-08','Energy','PROCEDURAL','Fictional motion to proceed to debate'),
 ('2019-02-20','Housing','FINAL_PASSAGE','Fictional housing funding bill'),
 ('2023-10-09','Healthcare','AMENDMENT','Fictional healthcare amendment'),
 ('2026-03-18','Transportation','FINAL_PASSAGE','Fictional accessible transit proposal')
]):
    for group in ('US_SENATE','US_HOUSE'):
        members=active(dt,group)
        positions={p:('YEA' if (i+j)%3==0 else 'NAY' if (i+j)%3==1 else 'NOT_VOTING') for j,p in enumerate(members)}
        if dt=='2023-10-09' and group=='US_SENATE': positions.pop('sen-b2',None)  # no specific record, not a guessed vote
        vote(f'{group}-V{i+1:03}',dt,group,question,act,topic,positions)

for i,(dt,topic,action,question) in enumerate([
 ('2001-06-12','Education','FINAL_PASSAGE','Fictional classroom resources authorization'),
 ('2009-09-30','Housing','FINAL_PASSAGE','Fictional housing financing act'),
 ('2014-10-23','Roads','PROCEDURAL','Fictional committee referral'),
 ('2020-01-15','Utilities','FINAL_PASSAGE','Fictional utility infrastructure bill'),
 ('2025-08-01','Healthcare','AMENDMENT','Fictional clinic appropriation amendment')]):
    for group in ('STATE_HOUSE','STATE_SENATE'):
        members=active(dt,group)
        vote(f'{group}-V{i+1:03}',dt,group,question,action,topic,{p:('YEA' if i%2==0 else 'NAY') for p in members})

for group, topic in [('COUNTY_COMMISSION','Budget'),('CITY_COUNCIL','Land use'),('SCHOOL_BOARD','Education')]:
    for i,dt in enumerate(['2004-05-04','2016-09-06','2019-08-21','2024-04-11']):
        members=active(dt,group)
        vote(f'{group}-V{i+1:03}',dt,group,f'Fictional {topic.lower()} motion {i+1}',
             'FINAL_PASSAGE' if i%2 else 'AMENDMENT',topic,{p:('NAY' if i%2 else 'YEA') for p in members})

OUT=Path(__file__).with_name('history_synthetic.json')
OUT.write_text(json.dumps(DATA,ensure_ascii=False,sort_keys=True,indent=2)+'\n')
print('Generated',OUT,'terms',len(DATA['terms']),'rollcalls',len(DATA['rollcalls']))
