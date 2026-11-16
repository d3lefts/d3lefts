/* Commonwealth OS participation & accountability workspace v1.2.
   All actions are voluntary, synthetic, in-memory and nonbinding. */
import {INSTITUTIONS,STATUS,CHOICES,BUDGET_PROJECTS,MEETINGS,seededBoard,transact,budgetSlate,publicDossier,validateBoard} from './participation-core.mjs';
const byId=id=>document.getElementById(id);
const element=(tag,cls,txt)=>{const n=document.createElement(tag);if(cls)n.className=cls;if(txt!==undefined)n.textContent=String(txt);return n;};
const append=(parent,...children)=>{parent.append(...children);return parent;};
const empty=node=>{node.replaceChildren();return node;};
const choiceLabel={SUPPORT:'Support',OPPOSE:'Do not support',NO_PREFERENCE:'No preference',NEED_INFORMATION:'Need information'};
let board=seededBoard();let institution='UAH';let selected='P-UAH-01';let budgetChoices=new Set();let mode='VISITOR';
let backend=null;let remoteSequence=0;let remoteHead='GENESIS';
const serverScopes={'student-demo':'UAH','union-demo':'HOA','municipal-demo':'HSV'};
const label=(id,txt)=>{if(byId(id))byId(id).textContent=String(txt);};
const message=(text,kind='')=>element('p','cwpart-message '+kind,text);
function button(text,action,{secondary=false,disabled=false}={}){
 const el=element('button','cwpart-btn '+(secondary?'cwpart-btn-quiet':''),text);el.type='button';el.disabled=disabled;el.addEventListener('click',action);return el;
}
function notice(text,kind=''){label('cwpart-feedback',text);const node=byId('cwpart-feedback');if(node)node.dataset.kind=kind;}
function current(){return board.proposals.find(x=>x.id===selected&&x.institution===institution)||null;}
async function refreshServer(){
 if(!backend)return;
 const response=await fetch('/api/v1/participation/'+backend.institutionId+'/board',{headers:{Authorization:'Bearer '+backend.token},cache:'no-store'});
 const data=await response.json();
 if(!response.ok)throw Error(data.error||'SERVER_READ_FAILED');
 board=data.board;remoteSequence=data.sequence;remoteHead=data.headHash;
 if(!board.proposals.some(p=>p.id===selected&&p.institution===institution))selected=board.proposals[0]?.id||null;
 renderAll();
}
async function apply(cmd){
 if(backend){
  try{
   const p=board.proposals.find(x=>x.id===cmd.id&&x.institution===institution);
   const request={institutionId:backend.institutionId,command:cmd,expectedSequence:remoteSequence,expectedRevision:cmd.type==='CREATE'?0:(p?.revision??0),key:'cw-part-'+crypto.randomUUID()};
   const response=await fetch('/api/v1/participation/commands',{method:'POST',headers:{Authorization:'Bearer '+backend.token,'Content-Type':'application/json'},body:JSON.stringify(request)});
   const data=await response.json();
   if(!response.ok){notice('Server rejected command: '+(data.error||response.status),'error');if(response.status===409)await refreshServer();return false;}
   await refreshServer();notice('Committed to LOCAL synthetic ledger · sequence '+remoteSequence,'ok');return true;
  }catch(e){notice('Local server unavailable: '+e.message,'error');return false;}
 }
 const result=transact(board,{...cmd,institution});
 if(result.ok){board=result.board;notice(result.reason,'ok');renderAll();}else notice(result.reason,'error');
 return result.ok;
}
function setInstitution(value){if(!INSTITUTIONS[value])return;if(backend&&value!==institution){byId('cwpart-institution').value=institution;notice('Disconnect from the synthetic server before changing tenant.','error');return;}institution=value;selected=board.proposals.find(x=>x.institution===institution)?.id||null;budgetChoices=new Set();renderAll();}
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
 if(backend)panel.append(message('Durable local demonstration · ledger sequence '+remoteSequence+' · chain head '+remoteHead.slice(0,16)+'… · no institutional authority'));
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
 const choices=element('div','cwpart-buttons');const previous=p.positions.find(x=>x.author==='FICTIONAL_VISITOR'&&x.revision===p.revision)?.choice;
 for(const choice of CHOICES){const b=button(choiceLabel[choice],()=>apply({type:'ADVISE',id:p.id,choice}),{secondary:previous!==choice,disabled:!['OPEN','REVIEW'].includes(p.stage)});b.setAttribute('aria-pressed',String(choice===previous));choices.append(b);}
 feedback.append(choices);feedback.append(message(previous?'Your current response: '+choiceLabel[previous]+' (not a vote)':'No response recorded for this text version. Unknown ≠ No preference.'));
 const older=p.positions.filter(x=>x.revision!==p.revision);if(older.length)feedback.append(message(`${older.length} older-version response(s) explicitly excluded from this revision.`));panel.append(feedback);
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
 const audit=element('section','cwpart-subsection');audit.append(element('h4','','Transparent event history (locally editable demo state)'));
 const eventList=element('ol','cwpart-events');for(const e of p.events)eventList.append(append(element('li',''),element('strong','',e.type+' · v'+e.revision),element('span','',e.detail)));audit.append(eventList);
 audit.append(button('Export public-facing fictional case dossier',()=>exportCase(p),{secondary:true}));audit.append(message('Exports include proposal title/text and all publicly displayed version text. Review anything you entered before sharing the JSON file. Private advisory positions and comment bodies are excluded.'));panel.append(audit);
}
async function exportCase(p){
 let dossier=publicDossier(p);
 if(backend){
  try{
   const r=await fetch('/api/v1/participation/'+backend.institutionId+'/receipts/'+encodeURIComponent(p.id),{headers:{Authorization:'Bearer '+backend.token}});
   const j=await r.json();
   if(!r.ok)throw Error(j.error||'DOSSIER_UNAVAILABLE');
   dossier=j;
  }catch(e){notice('No dossier exported: '+e.message,'error');return;}
 }
 const content=JSON.stringify(dossier,null,2);const blob=new Blob([content],{type:'application/json'});const url=URL.createObjectURL(blob),a=element('a');a.href=url;a.download='commonwealth-fictional-'+p.id+'.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),5000);
 notice(backend?'Synthetic receipt signed by an UNVERIFIED local key; no legal authority or independent proof of source authenticity.':'Fictional public dossier downloaded without individual preference or comment bodies. It is not a signed Proof Passport.','ok');
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
 label('cwpart-budget-caveat','Your local budget slate only. Not a collective allocation, fiscal appropriation, grant, or ballot.');
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
function renderAll(){validateBoard(board);label('cwpart-active-institution',INSTITUTIONS[institution].label);byId('cwpart-institution').value=institution;byId('cwpart-role').value=mode;renderDirectory();renderDetail();renderBudget();renderAccountability();}
function boot(){
 if(!byId('cwpart-app'))return;
 const serverBox=element('section','cwpart-subsection cwpart-server');
 serverBox.append(element('h4','','Optional persistent LOCAL server · never official'));
 serverBox.append(message('Static Pages runs entirely in memory. For a durable synthetic demo, run the existing localhost server and visit http://127.0.0.1:4180/browser/. No real identities or civic records.'));
 const tokenField=field('cwpart-server-token','Locally seeded fictional bearer token (never saved)','input');
 tokenField.querySelector('input').type='password';tokenField.querySelector('input').autocomplete='off';serverBox.append(tokenField);
 serverBox.append(button('Connect to local synthetic ledger',async()=>{
  if(!['127.0.0.1','localhost'].includes(location.hostname)||location.port!=='4180'){
   notice('Connect only from the locally hosted browser at http://127.0.0.1:4180/browser/.','error');return;
  }
  const token=tokenField.querySelector('input').value.trim();
  try{
   const r=await fetch('/api/v1/me',{headers:{Authorization:'Bearer '+token}});
   const identity=await r.json();
   if(!r.ok||!serverScopes[identity.institutionId])throw Error(identity.error||'UNCONFIGURED_DEMO_TENANT');
   backend={token,institutionId:identity.institutionId};
   institution=serverScopes[identity.institutionId];selected=null;budgetChoices.clear();
   await refreshServer();tokenField.querySelector('input').value='';
   notice('Connected to local demo tenant '+identity.institutionId+' as '+identity.role+'. Authorization is server-controlled.','ok');
  }catch(e){backend=null;notice('Connection failed: '+e.message,'error');}
 },{secondary:true}));
 serverBox.append(button('Refresh server ledger',async()=>{if(!backend){notice('Not connected to a local server.','error');return;}try{await refreshServer();notice('Durable synthetic state refreshed.','ok');}catch(e){notice(e.message,'error');}},{secondary:true}));
 serverBox.append(button('Disconnect (keep server events)',()=>{backend=null;board=seededBoard();institution='UAH';selected='P-UAH-01';remoteSequence=0;remoteHead='GENESIS';budgetChoices.clear();renderAll();notice('Disconnected. Local durable events were not deleted.','ok');},{secondary:true}));
 byId('cwpart-app').prepend(serverBox);
 const sel=byId('cwpart-institution');for(const [code,v] of Object.entries(INSTITUTIONS)){const opt=element('option','',v.label);opt.value=code;sel.append(opt);}sel.addEventListener('change',()=>setInstitution(sel.value));
 const stage=byId('cwpart-filter');for(const st of STATUS){const opt=element('option','',st.replaceAll('_',' '));opt.value=st;stage.append(opt);}stage.addEventListener('change',renderDirectory);byId('cwpart-search').addEventListener('input',renderDirectory);
 byId('cwpart-role').addEventListener('change',e=>{mode=e.target.value;notice(mode==='STEWARD'?'Fictional reviewer simulation only; no permissions or identities are authenticated.':'Visitor preview enabled; no server or identity is connected.');renderDetail();});
 byId('cwpart-new-form').addEventListener('submit',async e=>{e.preventDefault();const saved=await apply({type:'CREATE',title:byId('cwpart-new-title').value,text:byId('cwpart-new-text').value});if(saved){byId('cwpart-new-title').value='';byId('cwpart-new-text').value='';selected=board.proposals[0]?.id;renderAll();}});
 byId('cwpart-budget-clear').addEventListener('click',()=>{budgetChoices.clear();renderBudget();});
 byId('cwpart-reset').addEventListener('click',()=>{if(backend){notice('Disconnect before resetting local state. Server data cannot be reset from this button.','error');return;}board=seededBoard();institution='UAH';selected='P-UAH-01';budgetChoices.clear();mode='VISITOR';byId('cwpart-search').value='';byId('cwpart-filter').value='ALL';notice('Demo restored; all local contributions, answers, milestones and corrections cleared.','ok');renderAll();});
 renderAll();
}
boot();
