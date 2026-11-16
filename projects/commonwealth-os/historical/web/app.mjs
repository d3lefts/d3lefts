// Living Voter · entirely synthetic, read-only historical API integration.
// Issue responses and retrospective practice choices remain distinct in volatile JS memory.
import {DATA_MODE,PAGE_SIZE,RELATIONS,ISSUE_CHOICES,PRACTICE_CHOICES,isSyntheticHealth,
  validateDashboard,dashboardPath,relationInfo,canCompare,namedPositions,coverageLabel} from './model.mjs';
const byId=id=>document.getElementById(id);
const text=(value)=>document.createTextNode(String(value??''));
const create=(tag,cls,value)=>{const x=document.createElement(tag);if(cls)x.className=cls;if(value!==undefined)x.textContent=String(value);return x;};
const el=(parent,tag,cls,value)=>{const child=create(tag,cls,value);parent.append(child);return child;};
const state={issues:[],sources:[],page:null,offset:0,filters:{issueId:'',chamber:'ALL',houseDistrict:'07',municipalWard:'02',asOf:'2025-12-31'},
  issueResponses:new Map(),practiceChoices:new Map(),sequence:0,ready:false};

async function json(path){
  if(!path.startsWith('/api/v1/historical/'))throw new Error('Unapproved source path');
  const response=await fetch(path,{cache:'no-store',credentials:'same-origin'});
  if(!response.ok)throw new Error(`Historical source unavailable (${response.status})`);
  return response.json();
}
function attachNotice(message){byId('loading').textContent=message;byId('loading').hidden=false;}
function explainChoice(key,map){return map[key]??'Unknown';}

function refreshIssue(){
  const issue=state.issues.find(i=>i.issue_id===state.filters.issueId);
  byId('issue-answer').disabled=!issue;
  byId('issue-prompt').textContent=issue?issue.proposition:'Choose a single issue in the selector above to record a provisional, nonbinding view.';
  const answer=issue?state.issueResponses.get(issue.issue_id):null;
  for(const button of document.querySelectorAll('[data-issue-choice]')){
    button.setAttribute('aria-pressed',String(button.dataset.issueChoice===answer));
  }
  byId('issue-status').textContent=issue&&answer?
    `Private session-only issue response: ${explainChoice(answer,ISSUE_CHOICES)}. Not a historical vote or ballot.`:
    'No issue response recorded for this selection.';
}
function drawHistory(){
  const container=byId('practice-history');container.replaceChildren();
  if(!state.practiceChoices.size && !state.issueResponses.size){el(container,'p','muted','No private responses recorded in this session.');return;}
  if(state.issueResponses.size){
    el(container,'h3',null,'Issue responses — not votes');
    const ul=el(container,'ul');
    for(const [id,choice] of state.issueResponses){
      const issue=state.issues.find(x=>x.issue_id===id);
      el(ul,'li',null,`${issue?.title??id}: ${explainChoice(choice,ISSUE_CHOICES)}`);
    }
  }
  if(state.practiceChoices.size){
    el(container,'h3',null,'Retrospective practice choices — not ballots');
    const ul=el(container,'ul');
    for(const [id,choice] of state.practiceChoices){
      el(ul,'li',null,`${choice.title} (${id}): ${explainChoice(choice.choice,PRACTICE_CHOICES)}`);
    }
  }
  el(container,'p','micro muted','Refresh or close this tab to discard the session. No data is transmitted to Commonwealth.');
}
function renderSourceDetails(article,entry){
  const details=el(article,'details');el(details,'summary',null,'Inspect source provenance and correspondence');
  const dl=el(details,'dl');
  const pairs=[
    ['Synthetic source identifier',entry.source_id],
    ['Original question identifier',entry.question_id],
    ['Issue/question correspondence identifier',entry.link_id],
    ['Fixture reviewer (not an independent audit)',entry.reviewer],
    ['Review rationale',entry.rationale],
    ['Source SHA-256',entry.source_digest],
    ['Question SHA-256',entry.question_digest],
    ['Correspondence SHA-256',entry.correspondence_digest],
    ['Corpus coverage',entry.source_completeness]
  ];
  for(const [label,value] of pairs){el(dl,'dt',null,label);el(dl,'dd',label.includes('SHA-256')?'source-digest':'',value??'Unavailable');}
  el(details,'p','micro muted','SHA-256 digests identify local fictional fixture bytes. They are not government signatures, legal authority, or a Proof Passport.');
}
function renderPositions(article,entry){
  const details=el(article,'details');el(details,'summary',null,'Inspect fictional representatives at vote date');
  const people=namedPositions(entry),list=el(details,'ul','positions');
  for(const person of people){
    const item=el(list,'li');const left=el(item,'div');
    el(left,'strong',null,person.name);
    el(left,'div','minor',`${person.seat} · ${person.tenure}`);
    const label=el(item,'div','position',person.position);
    if(person.rawStatus==='NO_RECORDED_POSITION'||person.rawStatus==='NO_MATCHING_TENURE'||person.rawStatus==='VOICE_VOTE_NO_NAMED_POSITION')label.classList.add('unknown');
    if(person.recordId)el(left,'div','micro muted',`Immutable fictional vote ID: ${person.recordId}`);
  }
  el(details,'p','micro muted','People are matched to seats on the date of this fictional vote. Absence of a named record is not a Nay. A voice vote does not establish an individual position.');
}
function renderPractice(article,entry){
  if(!canCompare(entry)){
    el(article,'div','callout','Direct practice-choice versus member comparison is not available: the source question is procedural, not equivalent, not reviewed, a voice vote, or lacks a named roll-call position. Existing votes may still be inspected above with their limitations.');
    return;
  }
  const section=el(article,'div','vote-controls');
  el(section,'h4',null,'How would you have answered this exact fictional question?');
  el(section,'p',null,'Optional retrospective simulation only. The issue response above is not imported. Read the exact proposition and procedural category first.');
  const choices=el(section,'div','choice-row');
  const recorded=state.practiceChoices.get(entry.question_id)?.choice;
  for(const [key,label] of Object.entries(PRACTICE_CHOICES)){
    const b=el(choices,'button',null,label);b.type='button';b.dataset.practiceChoice=key;
    b.setAttribute('aria-pressed',String(recorded===key));
    b.addEventListener('click',()=>{
      state.practiceChoices.set(entry.question_id,{choice:key,title:entry.title});
      drawHistory();renderRecords();
    });
  }
  if(recorded){
    const row=el(section,'div','comparison');
    el(row,'strong',null,`Your nonbinding choice: ${explainChoice(recorded,PRACTICE_CHOICES)}.`);
    el(row,'p',null,'Named rollcall positions on this same fictional question:');
    const comparable=namedPositions(entry).filter(p=>p.eligibleForDirectComparison);
    for(const rep of comparable)el(row,'div','minor',`${rep.name}: ${rep.position}`);
    el(row,'p','micro muted','A comparison describes positions on one exact procedural question; it does not rank representatives or explain motives.');
    const clear=el(section,'button','link-button','Delete this practice choice');clear.type='button';
    clear.addEventListener('click',()=>{state.practiceChoices.delete(entry.question_id);drawHistory();renderRecords();});
  }
}
function renderRecords(){
  const list=byId('records');list.replaceChildren();
  const page=state.page;
  if(!page)return;
  const rows=page.entries;
  byId('empty').hidden=rows.length!==0;
  byId('record-count').textContent=`${page.total} source-linked question${page.total===1?'':'s'}`;
  byId('coverage-summary').textContent=coverageLabel(page);
  byId('page-status').textContent=`${page.total===0?0:page.offset+1}–${Math.min(page.offset+page.entries.length,page.total)} of ${page.total}`;
  byId('previous').disabled=page.offset===0;
  byId('next').disabled=page.next_offset==null;
  for(const entry of rows){
    const article=el(list,'article','record');article.setAttribute('aria-label',entry.title);
    const top=el(article,'div','record-top');
    el(top,'span','pill',entry.chamber==='MUNICIPAL'?'Municipal':entry.chamber==='HOUSE'?'House':'Senate');
    const relation=relationInfo(entry);
    el(top,'span','pill '+relation.className,relation.label);
    el(article,'h3',null,entry.title);
    el(article,'p','minor',`${entry.held_on} · ${entry.kind.replaceAll('_',' ')} · ${entry.rollcall_type} · Result: ${entry.result}`);
    const prompt=el(article,'div','inset');el(prompt,'strong',null,'Exact recorded proposition');
    el(prompt,'p',null,entry.proposition);
    el(article,'p','muted micro',relation.explanation);
    el(article,'p','muted micro',`Issue correspondence: ${entry.issue_title} · ${entry.relation.replaceAll('_',' ')}`);
    renderSourceDetails(article,entry);
    renderPositions(article,entry);
    renderPractice(article,entry);
  }
}
async function reload(){
  const n=++state.sequence;
  byId('previous').disabled=true;byId('next').disabled=true;
  attachNotice('Loading fictional historical questions…');
  try{
    const result=validateDashboard(await json(dashboardPath(state.filters,state.offset)));
    if(n!==state.sequence)return;
    state.page=result;
    byId('loading').hidden=true;
    renderRecords();
  }catch(e){
    if(n!==state.sequence)return;
    state.page=null;
    byId('records').replaceChildren();byId('record-count').textContent='Unavailable';
    byId('empty').hidden=true;
    attachNotice(`Unable to show evidence: ${e.message}. No substitute or inferred voting records will be displayed.`);
  }
}
function syncFilters(){
  state.filters={issueId:byId('issue').value,chamber:byId('chamber').value,
    houseDistrict:byId('house-district').value,municipalWard:byId('municipal-ward').value,asOf:byId('as-of').value};
  refreshIssue();
}
async function startup(){
  try{
    const [health,issues,sources]=await Promise.all([
      json('/api/v1/historical/health'),json('/api/v1/historical/issues'),json('/api/v1/historical/sources')]);
    if(!isSyntheticHealth(health)||issues.data_mode!==DATA_MODE||sources.data_mode!==DATA_MODE||
      !Array.isArray(issues.issues)||!Array.isArray(sources.sources)||sources.sources.length!==4||
      sources.sources.some(s=>!String(s.source_id).startsWith('fixture://commonwealth/'))) {
      throw new Error('Synthetic-only source contract not satisfied');
    }
    state.issues=issues.issues;state.sources=sources.sources;
    const select=byId('issue');
    for(const issue of state.issues){const option=create('option',null,issue.title);option.value=issue.issue_id;select.append(option);}
    state.ready=true;
    refreshIssue();
    await reload();
  }catch(e){
    attachNotice(`Synthetic-only verification failed: ${e.message}. Interactive data access disabled.`);
    byId('filters').querySelectorAll('select,input,button').forEach(x=>x.disabled=true);
  }
}
byId('filters').addEventListener('submit',event=>{event.preventDefault();if(!state.ready)return;syncFilters();state.offset=0;reload();});
byId('issue').addEventListener('change',()=>{if(!state.ready)return;syncFilters();state.offset=0;reload();});
for(const button of document.querySelectorAll('[data-issue-choice]')){
  button.addEventListener('click',()=>{
    if(!state.ready||!state.filters.issueId)return;
    state.issueResponses.set(state.filters.issueId,button.dataset.issueChoice);
    refreshIssue();drawHistory();
  });
}
byId('clear-issue').addEventListener('click',()=>{
  state.issueResponses.delete(state.filters.issueId);refreshIssue();drawHistory();
});
byId('previous').addEventListener('click',()=>{if(!state.page||state.offset===0)return;state.offset=Math.max(0,state.offset-PAGE_SIZE);reload();});
byId('next').addEventListener('click',()=>{if(!state.page||state.page.next_offset==null)return;state.offset=state.page.next_offset;reload();});
byId('clear-all').addEventListener('click',()=>{state.issueResponses.clear();state.practiceChoices.clear();refreshIssue();drawHistory();renderRecords();});
startup();
