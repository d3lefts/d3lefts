/* Commonwealth OS participation v1.3 — optional localhost-only SQLite mode; no official authority. */
import {INSTITUTIONS,STATUS,CHOICES,BUDGET_PROJECTS,MEETINGS,seededBoard,transact,budgetSlate,publicDossier,validateBoard} from './participation-core.mjs';
const byId=id=>document.getElementById(id);
const element=(tag,cls,txt)=>{const n=document.createElement(tag);if(cls)n.className=cls;if(txt!==undefined)n.textContent=String(txt);return n;};
const append=(parent,...children)=>{parent.append(...children);return parent;};
const empty=node=>{node.replaceChildren();return node;};
const choiceLabel={SUPPORT:'Support',OPPOSE:'Do not support',NO_PREFERENCE:'No preference',NEED_INFORMATION:'Need information'};
let board=seededBoard();let institution='UAH';let selected='P-UAH-01';let budgetChoices=new Set();let mode='VISITOR';
let remote=null,offlineBoard=board,sending=false;
const localStances=new Map();
const stanceKey=(p)=>institution+':'+p.id+':'+p.revision;
async function api(path,options={}){
 const response=await fetch(path,{...options,headers:{Authorization:'Bearer '+remote.token,...(options.body?{'Content-Type':'application/json'}:{})},cache:'no-store',credentials:'omit',redirect:'error'});
 let data;try{data=await response.json();}catch{throw Error('INVALID_LOCAL_SERVER_RESPONSE');}
 if(!response.ok)throw Error(data.error||'LOCAL_SERVER_REQUEST_FAILED');
 return data;
}
async function refreshRemote(){
 const data=await api('/api/v1/participation/'+remote.institution);
 remote.version=data.version;board=data.board;validateBoard(board);
 if(!board.proposals.some(p=>p.id===selected))selected=board.proposals[0]?.id||null;
 renderAll();
}
async function connectRemote(){
 if(remote)return;
 const input=byId('cwpart-token'),token=input.value.trim();input.value='';
 if(!/^[a-f0-9]{64}$/.test(token)){notice('Use a fictional 64-character token from npm run seed on localhost.','error');return;}
 try{
  const response=await fetch('/api/v1/me',{headers:{Authorization:'Bearer '+token},cache:'no-store',credentials:'omit',redirect:'error'});
  if(!response.ok)throw Error('LOCAL_TOKEN_NOT_AUTHENTICATED');
  const me=await response.json();
  const target={'student-demo':'UAH','hoa-demo':'HOA','municipal-demo':'HSV'}[me.institutionId];
  if(!target)throw Error('NO_PARTICIPATION_ADAPTER_FOR_THIS_FICTIONAL_TENANT');
  offlineBoard=board;remote={token,institution:target,actor:me,version:0};
  institution=target;selected=null;budgetChoices.clear();
  mode=['admin','chair','clerk'].includes(me.role)?'STEWARD':'VISITOR';
  await refreshRemote();
  byId('cwpart-institution').disabled=true;byId('cwpart-role').disabled=true;byId('cwpart-reset').disabled=true;
  byId('cwpart-connect').disabled=true;byId('cwpart-disconnect').disabled=false;
  notice('Connected to local SQLite as fictional '+me.role+'. This is not institutional authorization.','ok');
 }catch(e){remote=null;board=offlineBoard;institution='UAH';selected='P-UAH-01';mode='VISITOR';renderAll();notice('Connection failed: '+e.message+'. Browser-only mode retained.','error');}
}
function disconnectRemote(){
 if(!remote)return;
 remote=null;board=offlineBoard;institution='UAH';selected='P-UAH-01';mode='VISITOR';budgetChoices.clear();localStances.clear();
 for(const id of ['cwpart-institution','cwpart-role','cwpart-reset','cwpart-connect'])byId(id).disabled=false;
 byId('cwpart-disconnect').disabled=true;
 notice('Disconnected. Server changes retained on localhost; local-only demo restored.','ok');renderAll();
}

const label=(id,txt)=>{if(byId(id))byId(id).textContent=String(txt);};
const message=(text,kind='')=>element('p','cwpart-message '+kind,text);
function button(text,action,{secondary=false,disabled=false}={}){
 const el=element('button','cwpart-btn '+(secondary?'cwpart-btn-quiet':''),text);el.type='button';el.disabled=disabled;el.addEventListener('click',action);return el;
}
function notice(text,kind=''){label('cwpart-feedback',text);const node=byId('cwpart-feedback');if(node)node.dataset.kind=kind;}
function current(){return board.proposals.find(x=>x.id===selected&&x.institution===institution)||null;}
async function apply(cmd){
 if(remote){
  if(cmd.type==='ADVISE'){
   const p=current();if(!p)return false;
   localStances.set(stanceKey(p),cmd.choice);
   notice('Your practice answer stays in browser memory. It was not sent to the server or counted as a vote.','ok');
   renderDetail();return true;
  }
  if(sending)return false;
  sending=true;
  try{
   const data=await api('/api/v1/participation/'+remote.institution+'/commands',{method:'POST',body:JSON.stringify({key:'participation-'+crypto.randomUUID(),expectedVersion:remote.version,command:{...cmd,institution:remote.institution}})});
   remote.version=data.version;board=data.board;
   if(cmd.type==='CREATE')selected=board.proposals[0]?.id;
   notice('Saved fictional action in SQLite v'+remote.version+'. No official authority.','ok');renderAll();return true;
  }catch(e){
   const cause=e.message;try{await refreshRemote();}catch{}
   notice('Backend rejected action: '+cause+'. Refresh attempted to reconcile state.','error');return false;
  }finally{sending=false;}
 }
 const result=transact(board,{...cmd,institution});
 if(result.ok){board=result.board;offlineBoard=board;notice(result.reason,'ok');renderAll();return true;}
 notice(result.reason,'error');return false;
}
function setInstitution(value){if(remote||!INSTITUTIONS[value])return;institution=value;selected=board.proposals.find(x=>x.institution===institution)?.id||null;budgetChoices=new Set();renderAll();}
function renderDirectory(){
 const list=empty(byId('cwpart-list'));
 const needle=byId('cwpart-search').value.toLowerCase().trim(),filter=byId('cwpart-filter').value;
 const proposals=board.proposals.filter(p=>p.institution===institution&&(!filter||filter==='ALL'||p.stage===filter)&&(!needle||(p.title+' '+p.text+' '+p.category).toLowerCase().includes(needle)));
 label('cwpart-proposal-count',`${proposals.length} shown · ${board.proposals.filter(p=>p.institution===institution).length} local fictional cases`);
 if(!proposals.length)list.append(message('No proposals match this filter. Try clearing search.'));
 for(const p of proposals){
  const n=element('button','cwpart-proposal'+(selected===p.id?' is-selected':''));n.type='button';n.setAttribute('aria-pressed',String(selected===p.id));
  append(n,element('span','cwpart-meta',p.id+' · '+p.category),element('strong','',p.title),element('span','cwpart-meta','Revision '+p.revision+' · '+p.stage.replaceAll('_',' ')),element('span','cwpart-tiny',p.response?'Reasoned example response available':'Institutional response: pending'));
  n.addEventListener('click',()=>{selected=p.id;renderDirectory();renderDetail();});list.append(n);
 }
}
function field(id,title,tag='input'){const wrap=element('div','cwpart-field');const lab=element('label','',title);lab.htmlFor=id;const input=element(tag,'');input.id=id;if(tag==='textarea')input.rows=3;append(wrap,lab,input);return wrap;}
function renderDetail(){
 const panel=empty(byId('cwpart-detail'));const p=current();if(!p){panel.append(message('Select a proposal.'));return;}
 const header=element('div','cwpart-between');append(header,element('span','cwpart-meta',p.id+' · '+INSTITUTIONS[p.institution].label),element('span','cwpart-pill',p.stage.replaceAll('_',' ')));
 const title=element('h3','',p.title),text=element('p','cwpart-proposition',p.text);
 const meta=element('p','cwpart-meta','Exact displayed revision '+p.revision+' · '+p.sourceStatus+' · '+p.source);
 append(panel,header,title,text,meta);
 const statusLine=element('div','cwpart-statusline');for(const stage of ['OPEN','REVIEW','ACCEPTED','IMPLEMENTING','COMPLETED']){
  const x=element('span',stage===p.stage?'cwpart-stage-current':'',stage==='ACCEPTED'?'DECISION':stage.replaceAll('_',' '));statusLine.append(x);
 }panel.append(statusLine);
 const response=element('div','cwpart-response');append(response,element('strong','',p.response?'Institution response · '+p.response.decision:'Institutional response pending'),element('p','',p.response?.reason||'No simulated institution has issued a reasoned decision for this proposal. Feedback remains advisory.'));
 if(p.stage==='DECLINED')response.append(message('This fictional proposal was declined; the recorded rationale remains visible.'));
 panel.append(response);
 if(p.issueId){const link=button('Inspect related historical motions',()=>{
  const control=byId('cwui-issue-filter');if(control){control.value=p.issueId;control.dispatchEvent(new Event('change'));byId('cwui-representation')?.scrollIntoView({behavior:'smooth'});}else notice('Historical workspace is unavailable','error');
 },{secondary:true});panel.append(link);panel.append(message('This is a topic link only. It does not assert any actual official endorsed this proposal.'));}
 const feedback=element('section','cwpart-subsection');feedback.append(element('h4','','Your advisory response · current revision'));
 const choices=element('div','cwpart-buttons');const previous=remote?localStances.get(stanceKey(p)):p.positions.find(x=>x.author==='FICTIONAL_VISITOR'&&x.revision===p.revision)?.choice;
 for(const choice of CHOICES){const b=button(choiceLabel[choice],()=>apply({type:'ADVISE',id:p.id,choice}),{secondary:previous!==choice,disabled:!['OPEN','REVIEW'].includes(p.stage)});b.setAttribute('aria-pressed',String(choice===previous));choices.append(b);}
 feedback.append(choices);feedback.append(message(previous?'Your current response: '+choiceLabel[previous]+' (not a vote)':'No response recorded for this text version. Unknown ≠ No preference.'));
 const older=remote?[...localStances.keys()].filter(k=>k.startsWith(institution+':'+p.id+':')&&k!==stanceKey(p)):p.positions.filter(x=>x.revision!==p.revision);if(older.length)feedback.append(message(`${older.length} older-version response(s) explicitly excluded from this revision.`));panel.append(feedback);
 const discussion=element('section','cwpart-subsection');discussion.append(element('h4','','Deliberation · comments and concerns'));
 if(!p.comments.length)discussion.append(message('No fictional visitor contributions yet; unreviewed comments do not become an institutional finding.'));
 for(const c of p.comments){
  const entry=append(element('div','cwpart-discussion'),element('span','cwpart-meta',c.stance+' · revision '+c.revision+' · '+c.status),element('p','',c.text));
  if(c.response)entry.append(append(element('div','cwpart-response'),element('strong','','Reviewer response · fictional only'),element('p','',c.response)));
  if(mode==='STEWARD'&&c.status==='UNANSWERED_FICTIONAL'){
   const rf=field('cwpart-reply-'+c.id,'Written response for '+c.id);
   append(entry,rf,button('Answer this question/concern',()=>apply({type:'RESPOND_COMMENT',id:p.id,commentId:c.id,reason:rf.querySelector('input').value,role:'DEMO_STEWARD'}),{secondary:true}));
  }
  discussion.append(entry);
 }
 const unanswered=p.comments.filter(x=>x.status!=='ANSWERED_IN_SIMULATION').length;
 discussion.append(message(unanswered+' unresolved fictional contribution(s); unanswered concerns remain visible.'));

 const commentForm=element('form','cwpart-form');const stance=field('cwpart-comment-stance','Contribution type','select');for(const opt of ['QUESTION','SUPPORT','CONCERN']){const o=element('option','',opt);o.value=opt;stance.querySelector('select').append(o);}const comment=field('cwpart-comment-text','Your reasoned contribution (10–500 characters)','textarea');
 append(commentForm,stance,comment,button('Add local contribution',()=>{const val=comment.querySelector('textarea').value;const st=stance.querySelector('select').value;apply({type:'COMMENT',id:p.id,text:val,stance:st});},{disabled:!['OPEN','REVIEW'].includes(p.stage)}));discussion.append(commentForm);panel.append(discussion);
 const amendments=element('section','cwpart-subsection');amendments.append(element('h4','','Collaborative amendments · text version history'));
 for(const rev of p.revisions){const d=element('details','cwpart-amend');append(d,element('summary','','Immutable displayed version '+rev.revision),element('p','',rev.text),element('p','cwpart-meta',rev.reason));amendments.append(d);}
 for(const a of p.amendments){append(amendments,append(element('details','cwpart-amend'),element('summary','',a.id+' · '+a.status+' · proposed from v'+a.fromRevision),element('p','',a.text),element('p','cwpart-meta',a.reviewReason||'No review decision yet')));}
 const amendForm=element('form','cwpart-form');const alternative=field('cwpart-amend-text','Propose replacement motion text (30–600 characters)','textarea');const reason=field('cwpart-amend-reason','Why is the amendment needed?');
 append(amendForm,alternative,reason,button('Submit amendment for fictional review',()=>apply({type:'AMEND',id:p.id,text:alternative.querySelector('textarea').value,reason:reason.querySelector('input').value}),{disabled:!['OPEN','REVIEW'].includes(p.stage)}));amendments.append(amendForm);panel.append(amendments);
 if(mode==='STEWARD'){
  const steward=element('section','cwpart-subsection cwpart-steward');steward.append(element('h4','','Fictional steward simulation · no legal authority'));
  const pending=p.amendments.filter(x=>x.status==='PENDING');for(const a of pending){const f=field('cwpart-amendreason-'+a.id,'Review reason for '+a.id);const row=element('div','cwpart-buttons');append(row,button('Accept · new revision',()=>apply({type:'REVIEW_AMEND',id:p.id,amendmentId:a.id,decision:'ACCEPT',reason:f.querySelector('input').value,role:'DEMO_STEWARD'})),button('Decline amendment',()=>apply({type:'REVIEW_AMEND',id:p.id,amendmentId:a.id,decision:'DECLINE',reason:f.querySelector('input').value,role:'DEMO_STEWARD'}),{secondary:true}));append(steward,f,row);}
  const target=field('cwpart-target','Next simulated process state','select');const allowed={OPEN:['REVIEW'],REVIEW:['OPEN','ACCEPTED','DECLINED'],ACCEPTED:['IMPLEMENTING'],IMPLEMENTING:['COMPLETED']};for(const st of allowed[p.stage]||[]){const o=element('option','',st.replaceAll('_',' '));o.value=st;target.querySelector('select').append(o);}
  const r=field('cwpart-decision-reason','Reason for this change (15–400 characters)');
  append(steward,target,r,button('Record simulated institutional response',()=>apply({type:'STAGE',id:p.id,target:target.querySelector('select').value,reason:r.querySelector('input').value,role:'DEMO_STEWARD'}),{disabled:!target.querySelector('select').options.length}));
  if(p.stage==='IMPLEMENTING'){
   const percent=field('cwpart-milestone-percent','Implementation percent (must not decrease)');percent.querySelector('input').type='number';percent.querySelector('input').min=String(p.progress);percent.querySelector('input').max='100';percent.querySelector('input').value=String(p.progress);
   const why=field('cwpart-milestone-text','Milestone evidence description');append(steward,percent,why,button('Record fictional progress milestone',()=>apply({type:'MILESTONE',id:p.id,percent:Number(percent.querySelector('input').value),text:why.querySelector('input').value,role:'DEMO_STEWARD'})));
  }
  panel.append(steward);
 }
 const accountability=element('section','cwpart-subsection');accountability.append(element('h4','','Accountability · implementation and corrections'));
 if(p.response)accountability.append(message('Fictional decision: '+p.response.decision+' · rationale retained above.'));
 if(['IMPLEMENTING','COMPLETED'].includes(p.stage)){const progress=element('progress','');progress.max=100;progress.value=p.progress;append(accountability,progress,message('Documented fictional implementation: '+p.progress+'%'));}
 for(const m of p.milestones)accountability.append(append(element('div','cwpart-discussion'),element('strong','',m.percent+'% · '+m.id),element('p','',m.description)));
 const correction=field('cwpart-correction','Request correction of an alleged factual/procedural error');append(accountability,correction,button('Record an unreviewed correction request',()=>apply({type:'CORRECTION',id:p.id,reason:correction.querySelector('input').value}),{secondary:true}));
 const own=board.corrections.filter(x=>x.proposalId===p.id);for(const c of own)accountability.append(message(c.id+' · '+c.status+' · '+c.reason));panel.append(accountability);
 const audit=element('section','cwpart-subsection');audit.append(element('h4','',remote?'Transparent synthetic event history (replayed in local SQLite)':'Transparent event history (locally editable demo state)'));
 const eventList=element('ol','cwpart-events');for(const e of p.events)eventList.append(append(element('li',''),element('strong','',e.type+' · v'+e.revision),element('span','',e.detail)));audit.append(eventList);
 audit.append(button('Export public-facing fictional case dossier',()=>exportCase(p),{secondary:true}));audit.append(message('Exports include proposal title/text and all publicly displayed version text. Review anything you entered before sharing the JSON file. Private advisory positions and comment bodies are excluded.'));panel.append(audit);
}
function exportCase(p){
 const content=JSON.stringify(publicDossier(p),null,2);const blob=new Blob([content],{type:'application/json'});const url=URL.createObjectURL(blob),a=element('a');a.href=url;a.download='commonwealth-fictional-'+p.id+'.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),5000);
 notice('Fictional public dossier downloaded without individual preference or comment bodies. It is not a signed Proof Passport.','ok');
}
function renderBudget(){
 const list=empty(byId('cwpart-budget-projects'));
 for(const p of BUDGET_PROJECTS[institution]){
  const row=element('label','cwpart-budget-project'),box=element('input');box.type='checkbox';box.checked=budgetChoices.has(p.id);box.addEventListener('change',()=>{box.checked?budgetChoices.add(p.id):budgetChoices.delete(p.id);renderBudget();});
  append(row,box,append(element('span',''),element('strong','',p.title),element('small','',p.cost.toLocaleString()+' fictional credits')));list.append(row);
 }
 const data=budgetSlate(institution,[...budgetChoices]);label('cwpart-budget-total',`${data.total.toLocaleString()} / ${data.limit.toLocaleString()} fictional credits`);
 label('cwpart-budget-result',data.feasible?`Within the sample ceiling · ${data.remaining.toLocaleString()} credits unallocated`:`Over the sample ceiling by ${Math.abs(data.remaining).toLocaleString()} credits; slate is invalid`);
 byId('cwpart-budget-result').dataset.kind=data.feasible?'ok':'error';
 label('cwpart-budget-caveat',remote?'Local budget draft. Only a fictional steward may save this nonbinding plan; never a vote or appropriation.':'Your local budget slate only. Not a collective allocation, fiscal appropriation, grant, or ballot.');
 const save=byId('cwpart-budget-submit');save.hidden=!(remote&&mode==='STEWARD');save.disabled=!data.feasible;
 label('cwpart-budget-saved',remote&&board.budgetSubmission?'Stored fictional steward slate: '+board.budgetSubmission.total.toLocaleString()+' credits, no funding allocated.':'No persisted fictional budget plan.');
}
function renderAccountability(){
 const boardElm=empty(byId('cwpart-accountability-list'));
 for(const p of board.proposals.filter(x=>x.institution===institution)){
  const row=element('article','cwpart-accountability-row');
  append(row,element('span','cwpart-meta',p.id+' · '+p.sourceStatus),element('h4','',p.title),element('p','',p.response?.reason||'Awaiting a reasoned simulated institution response'),element('span','cwpart-pill',p.stage));
  if(p.milestones.length)row.append(message(p.progress+'% · '+p.milestones[p.milestones.length-1].description));
  const open=button('Open complete case and version trail',()=>{selected=p.id;renderDirectory();renderDetail();byId('cwpart-detail')?.scrollIntoView({behavior:'smooth'});},{secondary:true});row.append(open);boardElm.append(row);
 }
 const meeting=empty(byId('cwpart-meetings'));
 for(const m of MEETINGS.filter(x=>x.institution===institution)){
  const x=element('article','cwpart-meeting');append(x,element('strong','',m.title),element('p','',m.when+' · '+m.location),element('p','',m.access),element('small','',m.items.join(', ')+' · Minutes: '+m.minutes));meeting.append(x);
 }
}
function renderAll(){validateBoard(board);label('cwpart-mode-status',remote?'LOCAL SQLITE / '+remote.actor.role+' / VERSION '+remote.version:'BROWSER MEMORY / NOT PERSISTED');label('cwpart-active-institution',INSTITUTIONS[institution].label);byId('cwpart-institution').value=institution;byId('cwpart-role').value=mode;renderDirectory();renderDetail();renderBudget();renderAccountability();}
function boot(){
 if(!byId('cwpart-app'))return;
 const sel=byId('cwpart-institution');for(const [code,v] of Object.entries(INSTITUTIONS)){const opt=element('option','',v.label);opt.value=code;sel.append(opt);}sel.addEventListener('change',()=>setInstitution(sel.value));
 const stage=byId('cwpart-filter');for(const st of STATUS){const opt=element('option','',st.replaceAll('_',' '));opt.value=st;stage.append(opt);}stage.addEventListener('change',renderDirectory);byId('cwpart-search').addEventListener('input',renderDirectory);
 byId('cwpart-role').addEventListener('change',e=>{if(remote)return;mode=e.target.value;notice(mode==='STEWARD'?'Fictional reviewer simulation only; no permissions or identities are authenticated.':'Visitor preview enabled; no server or identity is connected.');renderDetail();});
 byId('cwpart-new-form').addEventListener('submit',async e=>{e.preventDefault();const succeeded=await apply({type:'CREATE',title:byId('cwpart-new-title').value,text:byId('cwpart-new-text').value});if(succeeded){byId('cwpart-new-title').value='';byId('cwpart-new-text').value='';selected=board.proposals[0]?.id;renderAll();}});
 byId('cwpart-budget-clear').addEventListener('click',()=>{budgetChoices.clear();renderBudget();});
 byId('cwpart-reset').addEventListener('click',()=>{if(remote)return;board=seededBoard();offlineBoard=board;institution='UAH';selected='P-UAH-01';budgetChoices.clear();mode='VISITOR';byId('cwpart-search').value='';byId('cwpart-filter').value='ALL';notice('Demo restored; all local contributions, answers, milestones and corrections cleared.','ok');renderAll();});
 byId('cwpart-connect').addEventListener('click',()=>{void connectRemote();});
 byId('cwpart-disconnect').addEventListener('click',disconnectRemote);
 byId('cwpart-budget-submit').addEventListener('click',()=>{if(remote&&mode==='STEWARD')void apply({type:'BUDGET',selected:[...budgetChoices]});});
 byId('cwpart-disconnect').disabled=true;
 renderAll();
}
boot();
