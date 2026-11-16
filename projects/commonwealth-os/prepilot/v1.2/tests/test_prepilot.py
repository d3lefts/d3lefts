from pathlib import Path
import json, re
base=Path(__file__).resolve().parents[1]
data=json.loads((base/'fixtures/official_rollcalls_2026.json').read_text())
records=data['rollcalls']; assert len(records)==3
assert len({r['id'] for r in records})==len(records)
assert {r['chamber'] for r in records}=={'House','Senate'}
allowed={'Yea','Nay','Present','Not Voting','Unavailable'}
for rec in records:
  assert rec['source_url'].startswith('https://')
  assert rec['question'] and rec['date'] and rec['action_type']
  assert rec['relation_to_referendum']=='exact_rollcall_question_only'
  assert all(v['position'] in allowed for v in rec['member_votes'])
  assert not any('policy_support' in v for v in rec['member_votes'])
r={x['number']:x for x in records}
assert r[297]['member_votes'][0]['position']=='Nay'
assert [v['position'] for v in r[259]['member_votes']]==['Yea','Yea']
assert [v['position'] for v in r[262]['member_votes']]==['Yea','Not Voting']
html=(base/'prepilot/living_voter_demo.html').read_text()
for term in ['Nonbinding','No preference','Not Voting','Need more information','refreshing clears','Retrospective','exact roll-call']:
  assert term.casefold() in html.casefold(),term
assert 'localStorage' not in html and 'fetch(' not in html and 'navigator.geolocation' not in html
assert 'state.choices[r.id]' in html and 'state.survey[state.surveyIndex]' in html
print('PASS: 15 data, privacy, claim-type and demo-integrity assertions')
