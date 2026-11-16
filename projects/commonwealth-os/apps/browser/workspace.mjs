/* Commonwealth OS comprehensive browser workspace (synthetic source only).
   No fetch, storage, analytics, identity, government-data import, or voting authority. */
import {QUESTION_BANK} from './question-data.mjs';
import {DEMO_PERSON, CHAMBERS, historicalRows, compareDirectAnswer, validateCorpus} from './history-core.mjs';

const $ = id => document.getElementById(id);
const F = window.COMMONWEALTH_SYNTHETIC;
const state = {pilot:'UAH',index:0,answers:new Map(),issueAnswers:new Map(),issue:null,page:1};
const answerLabels = Object.freeze({support:'Support',oppose:'Do not support',no_preference:'No preference',need_information:'Need more information',not_applicable:'Not applicable',skip:'Skipped'});
const make = (tag,className,text) => {const n=document.createElement(tag);if(className)n.className=className;if(text!==undefined)n.textContent=String(text);return n;};
const add = (parent,...nodes) => {for(const node of nodes)parent.append(node);return parent;};
const empty = id => {const node=$(id);node?.replaceChildren();return node;};
const label = (id,text)=>{if($(id))$(id).textContent=String(text);};
function note(text,level='info'){const n=make('p','cwui-note cwui-'+level,text);return n;}
function option(value,text){const o=document.createElement('option');o.value=value;o.textContent=text;return o;}
function buildSelects(){
  const pilot=$('cwui-pilot');
  for(const [code,bank] of Object.entries(QUESTION_BANK))pilot?.append(option(code,bank.name+' · 24 draft questions'));
  if(pilot)pilot.value=state.pilot;
  const group=$('cwui-group');if(group){group.append(option('ALL','All covered groups'));for(const [code,title] of Object.entries(CHAMBERS))group.append(option(code,title));}
  const issue=$('cwui-issue-filter'),practice=$('cwui-practice-issue');
  issue?.append(option('ALL','All recorded issues and motions'));
  for(const x of F.issues.issues){issue?.append(option(x.issue_id,x.title));practice?.append(option(x.issue_id,x.title));}
  state.issue=F.issues.issues[0]?.issue_id||null;
  if(practice&&state.issue)practice.value=state.issue;
}
function renderQuestion(){
 const bank=QUESTION_BANK[state.pilot], q=bank.questions[state.index];
 label('cwui-question-count',`Question ${state.index+1} of ${bank.questions.length}`);
 label('cwui-question-label',q.id+' · '+q.domain+' · RESEARCH DRAFT / UNVALIDATED');
 label('cwui-question-text',q.question);
 label('cwui-question-source','Not tied to a verified enacted rule; no legal or vote inference.');
 const answer=state.answers.get(q.id)||null;
 for(const button of document.querySelectorAll('[data-cwui-answer]'))button.setAttribute('aria-pressed',String(button.dataset.cwuiAnswer===answer));
 const total=bank.questions.reduce((n,x)=>n+(state.answers.has(x.id)?1:0),0);
 label('cwui-answered',`${total} of ${bank.questions.length} answered / skipped in this browser session`);
 label('cwui-answer-state',answer?`Current item: ${answerLabels[answer]}`:'Current item: Unknown — not assessed');
 $('cwui-question-prev').disabled=state.index===0;
 $('cwui-question-next').disabled=state.index===bank.questions.length-1;
 $('cwui-question-progress').value=total;
 $('cwui-question-progress').max=bank.questions.length;
}
function answerQuestion(value){const q=QUESTION_BANK[state.pilot].questions[state.index];state.answers.set(q.id,value);renderQuestion();}
function renderPractice(){
 const issue=F.issues.issues.find(x=>x.issue_id===state.issue);
 if(!issue)return;
 label('cwui-practice-text',issue.proposition);
 label('cwui-practice-note',`Synthetic issue ${issue.issue_id}; answer is a fictional practice preference, never a cast ballot.`);
 const ans=state.issueAnswers.get(issue.issue_id)||null;
 for(const button of document.querySelectorAll('[data-cwui-practice-answer]'))button.setAttribute('aria-pressed',String(button.dataset.cwuiPracticeAnswer===ans));
 label('cwui-practice-state',ans?`Practice answer: ${answerLabels[ans]}`:'Practice answer: Unknown');
}
function answerPractice(value){if(state.issue)state.issueAnswers.set(state.issue,value);renderPractice();renderHistory();}
function nodeResult(row){
 const article=make('article','cwui-record');article.setAttribute('role','listitem');
 const head=make('div','cwui-record-head');
 add(head,make('span','cwui-kicker',row.date+' · '+row.chamber.toUpperCase()+' · '+row.type),make('span','cwui-status',row.choice.replaceAll('_',' ')));
 const title=make('h4','',row.title);
 const by=make('p','cwui-person',row.person+' · seat '+row.seat+' · term '+row.termFrom+' to '+row.termTo);
 const exact=make('p','cwui-proposition','Exact motion: '+row.proposition);
 const details=make('details','cwui-record-details');
 const summary=make('summary','', 'Source, record gaps and issue correspondence');
 const list=make('dl','cwui-facts');
 const facts={
   'Question ID':row.motionId,'Vote kind':row.rollcallType,
   'Recorded member position':row.choice.replaceAll('_',' '),
   'Motion outcome':row.result,'Source':row.sourceId,
   'Custody':row.sourceStatus,
   'Issue mapping':row.correspondence.replaceAll('_',' '),
   'Interpretation':row.interpretation.replaceAll('_',' ')
 };
 for(const [k,v] of Object.entries(facts)){const dt=make('dt','',k),dd=make('dd','',v);list.append(dt,dd);}
 add(details,summary,list);
 if(row.relationRationale)details.append(note('Reviewer rationale (fictional): '+row.relationRationale));
 add(article,head,title,by,exact,details);
 const compared=compareDirectAnswer(state.issueAnswers.get(row.issueId),row);
 if(compared){const box=make('p','cwui-comparison','Your explicit practice answer: '+compared.citizen+' · Official source position: '+compared.official+' · '+compared.scope);article.append(box);}
 if(row.rollcallType!=='RECORDED')article.append(note('This motion was not a named roll call; no individual vote is reconstructed.','caution'));
 else if(row.choice==='NO_INDIVIDUAL_RECORD')article.append(note('No named position for this official exists in the supplied synthetic roll-call record.','caution'));
 return article;
}
function renderHistory(){
 const panel=empty('cwui-history-results');if(!panel)return;
 const from=$('cwui-from').value,to=$('cwui-to').value,group=$('cwui-group').value,
   mode=$('cwui-mode').value,issue=$('cwui-issue-filter').value;
 try{
  const data=historicalRows(F,{from,to,chamber:group,mode,issue});
  const rows=data.rows;const perPage=12;let pages=Math.max(1,Math.ceil(rows.length/perPage));state.page=Math.max(1,Math.min(state.page,pages));
  label('cwui-history-count',`${rows.length} fixture member-position rows · ${Object.values(data.coverage).reduce((n,x)=>n+x.motions,0)} source motions across 3 chambers`);
  label('cwui-history-context',mode==='PERSONAL_HISTORY'?'Fictional residence at each motion date; no unknown residence is imputed.':mode==='CURRENT_SEATS'?'Earlier occupants of the synthetic resident’s current seats. These people need not have represented them in the past.':'Research mode lists all known fictional seats, not the resident’s representatives.');
  label('cwui-history-page',`Page ${state.page} of ${pages}`);
  $('cwui-page-prev').disabled=state.page===1;
  $('cwui-page-next').disabled=state.page===pages;
  if(!rows.length){panel.append(note('No supplied fixture records match these filters. This does not establish that no real vote occurred.','caution'));return;}
  for(const row of rows.slice((state.page-1)*perPage,state.page*perPage))panel.append(nodeResult(row));
 }catch(err){label('cwui-history-count','Invalid or unsupported history filter');panel.append(note(err.message,'caution'));label('cwui-history-page','No pages');$('cwui-page-prev').disabled=true;$('cwui-page-next').disabled=true;}
}
function renderSources(){
 const box=empty('cwui-source-list');if(!box)return;
 for(const [code,title] of Object.entries(CHAMBERS)){
  const s=F[code];const card=make('article','cwui-source-card');
  add(card,make('strong','',title),make('p','',`${s.questions.length} source motions · ${s.votes.length} named position rows · ${s.tenures.length} tenure fixtures`),
    make('code','',s.source_id),note('SYNTHETIC_UNVERIFIED · sampled corpus, no official archive completeness.'));
  box.append(card);
 }
}
function renderSteward(){
 label('cwui-steward-mode','SYNTHETIC ONLY — admin effects disabled');
 const box=empty('cwui-gates');if(!box)return;
 for(const [status,title,detail] of [
  ['OFF','Official voting','No institutional legal authorization or election integration'],
  ['OFF','Real-record import','No network adapter, source custodian, or municipal connector'],
  ['OFF','Identity service','No actual accounts, DOB collection, eligibility or address lookups'],
  ['OFF','AI with write authority','No model may cast, certify, publish or transact'],
  ['DEMO','Constituent answers','Voluntary transient browser-state research responses'],
  ['DEMO','Proof Passport','Procedural fixture checks without authenticated custody']
 ]){const row=make('div','cwui-gate');add(row,make('span','cwui-status',status),make('strong','',title),make('small','',detail));box.append(row);}
}
function wire(){
  $('cwui-pilot').addEventListener('change',e=>{state.pilot=e.target.value;state.index=0;renderQuestion();});
  $('cwui-question-prev').addEventListener('click',()=>{state.index--;renderQuestion();});
  $('cwui-question-next').addEventListener('click',()=>{state.index++;renderQuestion();});
  $('cwui-question-clear').addEventListener('click',()=>{state.answers.delete(QUESTION_BANK[state.pilot].questions[state.index].id);renderQuestion();});
  $('cwui-answer-reset').addEventListener('click',()=>{for(const item of QUESTION_BANK[state.pilot].questions)state.answers.delete(item.id);renderQuestion();});
  for(const button of document.querySelectorAll('[data-cwui-answer]'))button.addEventListener('click',()=>answerQuestion(button.dataset.cwuiAnswer));
  $('cwui-practice-issue').addEventListener('change',e=>{state.issue=e.target.value;renderPractice();});
  $('cwui-practice-clear').addEventListener('click',()=>{state.issueAnswers.delete(state.issue);renderPractice();renderHistory();});
  for(const button of document.querySelectorAll('[data-cwui-practice-answer]'))button.addEventListener('click',()=>answerPractice(button.dataset.cwuiPracticeAnswer));
  for(const id of ['cwui-from','cwui-to','cwui-group','cwui-mode','cwui-issue-filter'])$(id).addEventListener('change',()=>{state.page=1;renderHistory();});
  $('cwui-page-prev').addEventListener('click',()=>{state.page--;renderHistory();});
  $('cwui-page-next').addEventListener('click',()=>{state.page++;renderHistory();});
}
function boot(){
 try{validateCorpus(F);if(Object.values(QUESTION_BANK).some(b=>b.questions.length!==24))throw new Error('Incomplete standardized question fixtures.');}
 catch(err){label('cwui-fatal','The synthetic fixture could not be verified: '+err.message);return;}
 if($('cwui-fatal'))$('cwui-fatal').hidden=true;
 buildSelects();
 $('cwui-from').value=DEMO_PERSON.birthDate; $('cwui-to').value='2026-11-15';
 label('cwui-resident-note',`Default: fictional birth date ${DEMO_PERSON.birthDate}. Fictional residence intervals 2024–2027 only. No real DOB or address used.`);
 wire();renderQuestion();renderPractice();renderHistory();renderSources();renderSteward();
}
boot();