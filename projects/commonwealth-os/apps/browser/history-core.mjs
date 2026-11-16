// Commonwealth OS synthetic recorded-vote explorer — pure date-effective joins.
// This module has no user identity, network, authority or persistence interfaces.
export const DEMO_PERSON = Object.freeze({
  label: 'Illustrative resident (not an account)',
  birthDate: '2000-05-09',
  residence: Object.freeze([
    {from:'2024-01-01',to:'2025-06-01',house:'07',municipal:'02'},
    {from:'2025-06-01',to:'2027-01-01',house:'08',municipal:'03'}
  ])
});
export const CHAMBERS = Object.freeze({house:'U.S. House analogue',senate:'U.S. Senate analogue',municipal:'City council analogue'});
export const MODES = Object.freeze(['PERSONAL_HISTORY','CURRENT_SEATS','RESEARCH']);
export const ISO = /^\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])$/;
export function validDate(s) {
  if(typeof s!=='string'||!ISO.test(s))return false;
  const [y,m,d]=s.split('-').map(Number),day=new Date(Date.UTC(y,m-1,d));
  return day.getUTCFullYear()===y&&day.getUTCMonth()===m-1&&day.getUTCDate()===d;
}
export function inHalfOpen(date,from,to){return date>=from&&(!to||date<to);}
export function validateCorpus(F){
  if(!F||!F.house||!F.senate||!F.municipal||!F.issues||
     ![F.house,F.senate,F.municipal,F.issues].every(s=>s.synthetic===true)) throw new Error('Only declared synthetic fixture sources are accepted.');
  for(const c of ['house','senate','municipal']){
    const src=F[c];
    if(!Array.isArray(src.tenures)||!Array.isArray(src.questions)||!Array.isArray(src.votes)) throw new Error('Incomplete synthetic fixture: '+c);
    const qid=new Set(),tids=new Set();
    for(const q of src.questions){if(!validDate(q.date)||qid.has(q.question_id))throw new Error('Duplicate or malformed source motion');qid.add(q.question_id);}
    for(const t of src.tenures){if(!validDate(t.from)||!validDate(t.to)||t.to<=t.from||tids.has(t.tenure_id))throw new Error('Malformed synthetic tenure');tids.add(t.tenure_id);}
    for(let i=0;i<src.tenures.length;i++)for(let j=i+1;j<src.tenures.length;j++){
      const a=src.tenures[i],b=src.tenures[j];
      if(a.seat===b.seat&&a.from<b.to&&b.from<a.to)throw new Error('Overlapping service terms for the same seat');
    }
    for(const v of src.votes){if(!qid.has(v.question_id))throw new Error('Position without source motion');}
  }
  return true;
}
export function seatFor(residence,chamber){return chamber==='house'?residence?.house:chamber==='municipal'?residence?.municipal:chamber==='senate'?'ALL':null;}
export function sourceCoverage(F){const out={};for(const c of Object.keys(CHAMBERS)){
  const dates=F[c].questions.map(q=>q.date).sort();
  out[c]={motions:dates.length,earliest:dates[0]||null,latest:dates.at(-1)||null,verified:false,complete:false};
}return out;}
export function historicalRows(F,{from=DEMO_PERSON.birthDate,to='2026-11-15',chamber='ALL',mode='PERSONAL_HISTORY',issue='ALL',profile=DEMO_PERSON,asOf='2026-11-15'}={}){
  validateCorpus(F);
  if(!validDate(from)||!validDate(to)||from>to||!validDate(asOf)||!MODES.includes(mode)||
     (chamber!=='ALL'&&!Object.hasOwn(CHAMBERS,chamber)))throw new Error('Invalid history filter');
  const selected=chamber==='ALL'?Object.keys(CHAMBERS):[chamber];
  const relations=new Map(F.issues.correspondence.map(r=>[r.question_id,r]));
  const currentResidence=profile.residence.find(r=>inHalfOpen(asOf,r.from,r.to))||null;
  const rows=[];
  for(const c of selected){const src=F[c];
    for(const motion of src.questions){if(motion.date<from||motion.date>to)continue;
      const rel=relations.get(motion.question_id);
      if(issue!=='ALL'&&rel?.issue_id!==issue)continue;
      const applicableResidence=profile.residence.find(r=>inHalfOpen(motion.date,r.from,r.to))||null;
      const allowedSeat=mode==='PERSONAL_HISTORY'?seatFor(applicableResidence,c):mode==='CURRENT_SEATS'?seatFor(currentResidence,c):null;
      // In PERSONAL_HISTORY and CURRENT_SEATS, lack of documented seat is an explicit uncertainty, not a match to all seats.
      if(mode!=='RESEARCH'&&!allowedSeat)continue;
      const tenures=src.tenures.filter(t=>inHalfOpen(motion.date,t.from,t.to)&&
        (mode==='RESEARCH'||t.district===allowedSeat));
      for(const term of tenures){const member=src.people.find(p=>p.person_id===term.person_id);
        const record=src.votes.find(v=>v.person_id===term.person_id&&v.question_id===motion.question_id);
        const choice=motion.rollcall_type==='RECORDED'?(record?.choice||'NO_INDIVIDUAL_RECORD'):'NO_NAMED_VOTE';
        rows.push({id:c+':'+motion.question_id+':'+term.tenure_id,chamber:c,date:motion.date,
          person:member?.name||'Unknown fictional officeholder',personId:term.person_id,termId:term.tenure_id,
          termFrom:term.from,termTo:term.to,seat:term.seat,district:term.district,
          motionId:motion.question_id,title:motion.title,proposition:motion.proposition,
          type:motion.kind,rollcallType:motion.rollcall_type,choice,result:motion.result,
          sourceId:src.source_id,sourceStatus:'SYNTHETIC_UNVERIFIED',
          correspondence:rel?.relation||'NONE',issueId:rel?.issue_id||null,
          relationRationale:rel?.rationale||'',residenceVerified:false,
          interpretation:mode==='PERSONAL_HISTORY'?'PERSONAL_SYNTHETIC_MATCH':mode==='CURRENT_SEATS'?'SEAT_HISTORY_ONLY':'PUBLIC_RESEARCH_ONLY'});
      }
    }
  }
  rows.sort((a,b)=>b.date.localeCompare(a.date)||a.chamber.localeCompare(b.chamber)||a.seat.localeCompare(b.seat)||a.motionId.localeCompare(b.motionId));
  return {rows,mode,from,to,coverage:sourceCoverage(F),warning:'Synthetic partial corpus only. No real residence, completeness, public source verification or named vote beyond the fixture is established.'};
}
export function compareDirectAnswer(answer,row){
  if(!answer||!['support','oppose'].includes(answer))return null;
  if(row.correspondence!=='EXACT_QUESTION'||!['FINAL_PASSAGE','MOTION'].includes(row.type)||
     !['YEA','NAY'].includes(row.choice))return null;
  return {citizen:answer==='support'?'Support':'Do not support',official:row.choice==='YEA'?'Yea':'Nay',scope:'EXACT QUESTION — SYNTHETIC ONLY'};
}