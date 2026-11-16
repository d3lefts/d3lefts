import test from 'node:test';
import assert from 'node:assert/strict';
import {DATA_MODE, PAGE_SIZE, isSyntheticHealth, validateDashboard, dashboardPath, relationInfo, canCompare, namedPositions, coverageLabel} from '../model.mjs';
const member={name:'Avery Example',seat:'H-07',person_id:'fx-p',position:'YEA',vote_record_id:'fx-v',direct_vote_comparison_permitted:true,valid_from:'2024-01-03',valid_to:'2025-01-03'};
const exact={relation:'EXACT_QUESTION',kind:'FINAL_PASSAGE',rollcall_type:'RECORDED',direct_vote_comparison_permitted:true,representatives_at_vote_date:[member]};
const health={data_mode:DATA_MODE,real_government_data_connected:false,external_source_adapters_enabled:false,official_ballots_supported:false};
const dash={mode:DATA_MODE,official_data_connected:false,historical_votes_are_user_ballots:false,coverage:{complete_legislative_history:false},entries:[],total:0};
test('rejects non-synthetic or enabled live data',()=>{
 assert.ok(isSyntheticHealth(health));
 for(const key of ['real_government_data_connected','external_source_adapters_enabled','official_ballots_supported']){
  assert.equal(isSyntheticHealth({...health,[key]:true}),false);
 }
 assert.equal(isSyntheticHealth({...health,data_mode:'LIVE'}),false);
});
test('fails closed on incomplete or modified historical contract',()=>{
 assert.equal(validateDashboard(dash),dash);
 for(const bad of [{...dash,mode:'LIVE'},{...dash,historical_votes_are_user_ballots:true},{...dash,coverage:{complete_legislative_history:true}}]){
  assert.throws(()=>validateDashboard(bad));
 }
});
test('only an exact recorded direct decision can present comparison',()=>{
 assert.equal(canCompare(exact),true);
 for(const patch of [
  {relation:'TOPIC_ONLY'},{relation:'SUBSTANTIVE_REVIEWED'},{relation:'UNREVIEWED'},
  {kind:'CLOTURE'},{kind:'AMENDMENT'},{kind:'NOMINATION'},
  {rollcall_type:'VOICE'},{direct_vote_comparison_permitted:false},
  {representatives_at_vote_date:[{...member,position:'NO_RECORDED_POSITION',vote_record_id:null}]},
  {representatives_at_vote_date:[]}])assert.equal(canCompare({...exact,...patch}),false,JSON.stringify(patch));
});
test('voice, missing tenure, and missing vote stay distinct',()=>{
 const bad={...exact,rollcall_type:'VOICE',representatives_at_vote_date:[
  {...member,position:'VOICE_VOTE_NO_NAMED_POSITION',vote_record_id:null},
  {person_id:null,position:'NO_MATCHING_TENURE',seat:null},
  {...member,position:'NO_RECORDED_POSITION',vote_record_id:null}]};
 const statuses=namedPositions(bad);
 assert.deepEqual(statuses.map(x=>x.position),[
  'Voice vote — no named position','No matching tenure at vote date','No recorded position']);
 assert.ok(statuses.every(x=>!x.eligibleForDirectComparison));
});
test('safe URL builder validates exact fixture-only inputs and pagination',()=>{
 const path=dashboardPath({issueId:'fx-issue-riverfront',chamber:'HOUSE',houseDistrict:'08',municipalWard:'02',asOf:'2025-09-03'},4);
 assert.ok(path.startsWith('/api/v1/historical/dashboard?'));
 const q=new URLSearchParams(path.split('?')[1]);
 assert.equal(q.get('issue_id'),'fx-issue-riverfront');assert.equal(q.get('chamber'),'HOUSE');
 assert.equal(q.get('house_district'),'08');assert.equal(q.get('offset'),'4');assert.equal(q.get('limit'),String(PAGE_SIZE));
 for(const bad of [{issueId:'https://other.example'}, {chamber:'STATE'}, {houseDistrict:'999'}, {municipalWard:'03&flag=true'}])
  assert.throws(()=>dashboardPath(bad));
 assert.throws(()=>dashboardPath({},-1));
});
test('correspondence labels and coverage cannot imply certified legal equivalence',()=>{
 assert.match(relationInfo(exact).explanation,/fixture-level/);
 assert.match(relationInfo({relation:'TOPIC_ONLY'}).explanation,/does not establish/);
 assert.match(relationInfo({relation:'NOT_A_REAL_RELATION'}).explanation,/cannot support/);
 assert.match(coverageLabel(dash),/not comprehensive/);
});
