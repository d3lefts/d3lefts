import test from 'node:test';
import assert from 'node:assert/strict';
import {DEMO_PERSON,validDate,validateCorpus,historicalRows,compareDirectAnswer,sourceCoverage} from '../history-core.mjs';
const F={
 house:{synthetic:true,source_id:'fixture://house',people:[{person_id:'m',name:'Morgan (fictional)'},{person_id:'j',name:'Jordan (fictional)'}],tenures:[
 {tenure_id:'h1',person_id:'m',seat:'H-07',district:'07',from:'2024-01-01',to:'2025-01-03'},
 {tenure_id:'h2',person_id:'j',seat:'H-07',district:'07',from:'2025-01-03',to:'2027-01-03'},
 {tenure_id:'h3',person_id:'j',seat:'H-08',district:'08',from:'2024-01-01',to:'2027-01-03'}],
 questions:[{question_id:'qh1',date:'2024-06-10',kind:'FINAL_PASSAGE',rollcall_type:'RECORDED',title:'Fixture passage',proposition:'An example measure',result:'AGREED'},
 {question_id:'qh2',date:'2025-07-02',kind:'AMENDMENT',rollcall_type:'RECORDED',title:'Fixture amendment',proposition:'Amend the measure',result:'AGREED'}],votes:[{question_id:'qh1',person_id:'m',choice:'YEA'},{question_id:'qh2',person_id:'j',choice:'NAY'}]},
 senate:{synthetic:true,source_id:'fixture://senate',people:[{person_id:'s1',name:'Senator A'},{person_id:'s2',name:'Senator B'}],tenures:[
 {tenure_id:'s1t',person_id:'s1',seat:'S-1',district:'ALL',from:'2023-01-03',to:'2029-01-03'},
 {tenure_id:'s2t',person_id:'s2',seat:'S-2',district:'ALL',from:'2023-01-03',to:'2029-01-03'}],
 questions:[{question_id:'qs1',date:'2025-04-03',kind:'CLOTURE',rollcall_type:'RECORDED',title:'Debate limit',proposition:'Limit debate',result:'AGREED'}],votes:[{question_id:'qs1',person_id:'s1',choice:'YEA'}]},
 municipal:{synthetic:true,source_id:'fixture://city',people:[{person_id:'c1',name:'City A'},{person_id:'c2',name:'City B'}],tenures:[
 {tenure_id:'c1t',person_id:'c1',seat:'M-02',district:'02',from:'2023-01-01',to:'2027-01-01'},
 {tenure_id:'c2t',person_id:'c2',seat:'M-03',district:'03',from:'2023-01-01',to:'2027-01-01'}],
 questions:[{question_id:'qc1',date:'2025-04-01',kind:'MOTION',rollcall_type:'VOICE',title:'Voice motion',proposition:'Adopt a measure',result:'AGREED'},
 {question_id:'qc2',date:'2025-07-15',kind:'MOTION',rollcall_type:'RECORDED',title:'City decision',proposition:'A city policy',result:'AGREED'}],votes:[{question_id:'qc2',person_id:'c2',choice:'NOT_VOTING'}]},
 issues:{synthetic:true,issues:[{issue_id:'i1',title:'Issue',proposition:'An example measure'}],correspondence:[{issue_id:'i1',question_id:'qh1',relation:'EXACT_QUESTION'},{issue_id:'i1',question_id:'qs1',relation:'TOPIC_ONLY'}]}
};
const opts={from:'2000-05-09',to:'2026-11-15'};
test('only fictional verified shape admitted',()=>{assert.equal(validateCorpus(F),true);assert.throws(()=>validateCorpus({...F,house:{...F.house,synthetic:false}}),/synthetic/)});
test('date check rejects impossible dates',()=>{assert.equal(validDate('2026-02-30'),false);assert.equal(validDate('2024-02-29'),true);assert.equal(validDate('2025-01-00'),false)});
test('personal history uses time-effective residence and seat',()=>{let x=historicalRows(F,opts).rows;assert.equal(x.find(r=>r.motionId==='qh1').personId,'m');assert.equal(x.find(r=>r.motionId==='qh2').district,'08')});
test('the move changes municipal seat and retains the voice-vote gap',()=>{const x=historicalRows(F,opts).rows;assert.equal(x.find(r=>r.motionId==='qc1').district,'02');assert.equal(x.find(r=>r.motionId==='qc1').choice,'NO_NAMED_VOTE');assert.equal(x.find(r=>r.motionId==='qc2').district,'03');assert.equal(x.find(r=>r.motionId==='qc2').choice,'NOT_VOTING')});
test('simultaneous senators are not collapsed or invented',()=>{const x=historicalRows(F,{...opts,chamber:'senate'}).rows;assert.equal(x.length,2);assert.equal(x.find(r=>r.personId==='s2').choice,'NO_INDIVIDUAL_RECORD')});
test('prior occupants of current seats are not personal historical representatives',()=>{const p=historicalRows(F,{...opts,chamber:'house',mode:'PERSONAL_HISTORY'}).rows;const c=historicalRows(F,{...opts,chamber:'house',mode:'CURRENT_SEATS'}).rows;assert.equal(p[0].district,'08');assert.ok(!c.some(r=>r.district==='07'));assert.ok(p.some(r=>r.district==='07'))});
test('research mode may browse all seats without attributing personal representation',()=>{const x=historicalRows(F,{...opts,mode:'RESEARCH'}).rows;assert.ok(x.some(r=>r.district==='07'));assert.ok(x.every(r=>r.interpretation==='PUBLIC_RESEARCH_ONLY'))});
test('invalid ranges fail closed',()=>{assert.throws(()=>historicalRows(F,{from:'2025-01-01',to:'2024-01-01'}),/Invalid/);assert.throws(()=>historicalRows(F,{from:'2025-01-01',to:'not-a-date'}),/Invalid/)});
test('source gaps are not claims of official inactivity',()=>{const x=historicalRows(F,{from:'1990-01-01',to:'1991-01-01'});assert.equal(x.rows.length,0);assert.ok(x.warning.includes('partial corpus'))});
test('comparison only with explicit exact substantive question',()=>{let x=historicalRows(F,{...opts,mode:'RESEARCH'}).rows;assert.ok(compareDirectAnswer('support',x.find(r=>r.motionId==='qh1')));assert.equal(compareDirectAnswer('support',x.find(r=>r.motionId==='qs1')),null);assert.equal(compareDirectAnswer('no_preference',x.find(r=>r.motionId==='qh1')),null)});
test('coverage reports partial sources only',()=>{const c=sourceCoverage(F);assert.equal(c.house.complete,false);assert.equal(c.senate.motions,1)});
test('overlapping member term records require explicit scrutiny',()=>{const altered=structuredClone(F);altered.house.tenures.push({...altered.house.tenures[0],tenure_id:'bad2'});assert.throws(()=>historicalRows(altered,{...opts,chamber:'house'}),/Overlapping service terms/);});