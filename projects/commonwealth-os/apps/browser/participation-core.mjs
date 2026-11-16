/* Commonwealth OS v1.2 — pure, fictional and nonbinding participation engine.
   NO institution, public source or member identity is authenticated here. */
export const INSTITUTIONS=Object.freeze({
 UAH:{label:'University student government · fictional',budget:50000,unit:'demo credits'},
 HOA:{label:'Residential association · fictional',budget:25000,unit:'demo credits'},
 HSV:{label:'Municipal council · fictional',budget:100000,unit:'demo credits'}
});
export const STATUS=Object.freeze(['OPEN','REVIEW','ACCEPTED','DECLINED','IMPLEMENTING','COMPLETED']);
export const CHOICES=Object.freeze(['SUPPORT','OPPOSE','NO_PREFERENCE','NEED_INFORMATION']);
const FIXTURES=[
 {id:'P-UAH-01',institution:'UAH',title:'Evening campus shuttle trial',text:'Evaluate adding one campus shuttle route after 9 p.m. on weekdays during the academic term.',category:'Mobility',issueId:null,stage:'OPEN',source:'fixture://commonwealth/participation/uah/1'},
 {id:'P-UAH-02',institution:'UAH',title:'Publish student organization grant outcomes',text:'Publish the criteria, funding decisions and review deadlines used for fictional student organization grants.',category:'Transparency',issueId:null,stage:'REVIEW',source:'fixture://commonwealth/participation/uah/2'},
 {id:'P-HOA-01',institution:'HOA',title:'Common-area solar installation',text:'Evaluate installing solar panels on shared facilities subject to a fictional cost and maintenance analysis.',category:'Property',issueId:null,stage:'OPEN',source:'fixture://commonwealth/participation/hoa/1'},
 {id:'P-HOA-02',institution:'HOA',title:'Quarterly maintenance disclosures',text:'Publish quarterly maintenance progress, itemized costs and correction notices for shared property.',category:'Accountability',issueId:null,stage:'ACCEPTED',source:'fixture://commonwealth/participation/hoa/2',response:{decision:'ACCEPTED',reason:'The fictional board accepted a demonstration reporting pilot; no real association adopted it.',at:'2026-11-15'}},
 {id:'P-HSV-01',institution:'HSV',title:'Riverfront pedestrian access study',text:'Evaluate a fictional public-access improvement study near a riverfront corridor; no actual zoning or project decision is represented.',category:'Public space',issueId:'fx-issue-riverfront',stage:'OPEN',source:'fixture://commonwealth/participation/municipal/1'},
 {id:'P-HSV-02',institution:'HSV',title:'Stormwater inspection information',text:'Publish a fictional plain-language inspection schedule and add a documented request-for-correction route.',category:'Services',issueId:'fx-issue-stormwater',stage:'IMPLEMENTING',source:'fixture://commonwealth/participation/municipal/2',response:{decision:'ACCEPTED',reason:'Fictional staff agreed to test a public explanation and correction workflow, not a real government policy.',at:'2026-11-15'},progress:40,milestones:[{id:'M-1',percent:40,description:'Fictional first-draft explanation completed; awaiting review.',at:'2026-11-15'}]}
];
export const BUDGET_PROJECTS=Object.freeze({
 UAH:[{id:'B-U1',title:'Evening shuttle evaluation',cost:24000},{id:'B-U2',title:'Open student grants dashboard',cost:9000},{id:'B-U3',title:'Bike parking feasibility study',cost:18000},{id:'B-U4',title:'Student meeting-room upgrades',cost:15000}],
 HOA:[{id:'B-H1',title:'Shared-area lighting',cost:7000},{id:'B-H2',title:'Storm drain maintenance',cost:11000},{id:'B-H3',title:'Common-area garden',cost:5000},{id:'B-H4',title:'Pool accessibility review',cost:12000}],
 HSV:[{id:'B-M1',title:'Walkability concept study',cost:42000},{id:'B-M2',title:'Bus-stop shelter study',cost:35000},{id:'B-M3',title:'Public records interface',cost:27000},{id:'B-M4',title:'Stormwater outreach pilot',cost:19000}]
});
export const MEETINGS=Object.freeze([
 {id:'AG-01',institution:'UAH',when:'2026-11-18',title:'Student senate research agenda',location:'Fictional campus meeting room',items:['P-UAH-01','P-UAH-02'],minutes:'NOT_RECORDED',access:'In-person and accessible notes channel proposed'},
 {id:'AG-02',institution:'HOA',when:'2026-11-19',title:'Association committee open forum',location:'Fictional common room',items:['P-HOA-01','P-HOA-02'],minutes:'DRAFT_ONLY',access:'In-person / paper comment path modeled'},
 {id:'AG-03',institution:'HSV',when:'2026-11-20',title:'Municipal shadow hearing',location:'Fictional meeting room',items:['P-HSV-01','P-HSV-02'],minutes:'NOT_RECORDED',access:'Nonbinding paper and digital routes modeled'}
]);
const clean=(v,min,max)=>typeof v==='string'&&v.trim().length>=min&&v.trim().length<=max&& !/[\u0000-\u0008\u000b\u000c\u000e-\u001f]/.test(v.trim());
const clone=o=>JSON.parse(JSON.stringify(o));
const event=(p,type,detail)=>{p.events.push({sequence:p.events.length+1,type,detail,revision:p.revision,demo:true});};
export function seededBoard(){
 const proposals=FIXTURES.map(x=>({revision:1,comments:[],amendments:[],positions:[],events:[],progress:0,milestones:[],response:null,sourceStatus:'FICTIONAL_UNVERIFIED',...clone(x),revisions:[{revision:1,text:x.text,reason:'Fictional initial version'}]}));
 for(const p of proposals){event(p,'CREATED','Fictional seed proposal');if(p.response)event(p,'SAMPLE_INSTITUTION_RESPONSE',p.response.decision+' · '+p.response.reason);if(p.milestones.length)for(const m of p.milestones)event(p,'SAMPLE_MILESTONE',m.percent+'% · '+m.description);}
 return {schemaVersion:'1.2',mode:'SYNTHETIC_ONLY',officialVoting:false,realImport:false,proposals,nextId:1,corrections:[]};
}
export function validateBoard(board){
 if(board?.mode!=='SYNTHETIC_ONLY'||board.officialVoting!==false||board.realImport!==false||!Array.isArray(board.proposals))throw Error('Invalid demo board scope');
 const ids=new Set();
 for(const p of board.proposals){
  if(ids.has(p.id)||!INSTITUTIONS[p.institution]||!STATUS.includes(p.stage)||!Number.isSafeInteger(p.revision)||p.revision<1||p.sourceStatus!=='FICTIONAL_UNVERIFIED')throw Error('Invalid proposal fixture');
  ids.add(p.id);if(p.events.some((e,i)=>e.sequence!==i+1||!e.demo))throw Error('Invalid demo event sequence');
  if(!Array.isArray(p.revisions)||p.revisions.length!==p.revision||p.revisions.some((r,i)=>r.revision!==i+1)||p.revisions[p.revision-1]?.text!==p.text)throw Error('Inconsistent immutable revision trail');
 }
 return true;
}
const good=(ok,reason,board)=>({ok,reason,board});
export function transact(input,cmd){
 validateBoard(input);
 if(!cmd||!INSTITUTIONS[cmd.institution])return good(false,'Unknown fictional institution',input);
 const next=clone(input);const institution=cmd.institution;
 if(cmd.type==='CREATE'){
  if(!clean(cmd.title,10,110)||!clean(cmd.text,30,600))return good(false,'Provide a 10–110 character title and 30–600 character proposal',input);
  const id='P-NEW-'+String(next.nextId++).padStart(3,'0');
  const proposal={id,institution,title:cmd.title.trim(),text:cmd.text.trim(),category:'Participant draft',issueId:null,stage:'OPEN',revision:1,source:'fixture://commonwealth/participation/local-draft',sourceStatus:'FICTIONAL_UNVERIFIED',comments:[],amendments:[],positions:[],events:[],progress:0,milestones:[],response:null,revisions:[{revision:1,text:cmd.text.trim(),reason:'Voluntary fictional draft created in memory'}]};
  event(proposal,'CREATED','Voluntary in-memory fictional draft');next.proposals.unshift(proposal);return good(true,'Draft created in this browser session only',next);
 }
 const p=next.proposals.find(x=>x.id===cmd.id&&x.institution===institution);
 if(!p)return good(false,'Proposal not found in this institution',input);
 if(cmd.type==='COMMENT'){
  if(!['OPEN','REVIEW'].includes(p.stage))return good(false,'Discussion is closed in this example',input);
  if(!clean(cmd.text,10,500)||!['SUPPORT','QUESTION','CONCERN'].includes(cmd.stance))return good(false,'A 10–500 character contribution and stance are required',input);
  const entry={id:'C-'+(p.comments.length+1),revision:p.revision,text:cmd.text.trim(),stance:cmd.stance,author:'FICTIONAL_VISITOR',status:'VISIBLE_UNREVIEWED'};
  p.comments.push(entry);event(p,'COMMENT',entry.id+' · '+entry.stance);return good(true,'Comment added locally; it is not published or moderated by an institution',next);
 }
 if(cmd.type==='ADVISE'){
  if(!['OPEN','REVIEW'].includes(p.stage)||!CHOICES.includes(cmd.choice))return good(false,'Advisory response unavailable or invalid',input);
  p.positions=p.positions.filter(x=>!(x.author==='FICTIONAL_VISITOR'&&x.revision===p.revision));
  p.positions.push({revision:p.revision,author:'FICTIONAL_VISITOR',choice:cmd.choice});event(p,'ADVISORY_RESPONSE','Response to revision '+p.revision+' (not a ballot)');
  return good(true,'Voluntary advisory position recorded only in this page',next);
 }
 if(cmd.type==='AMEND'){
  if(!['OPEN','REVIEW'].includes(p.stage)||!clean(cmd.text,30,600)||!clean(cmd.reason,10,300)||cmd.text.trim()===p.text)return good(false,'Provide distinct 30–600 character amendment text and a reason of at least 10 characters while review is open',input);
  p.amendments.push({id:'A-'+(p.amendments.length+1),fromRevision:p.revision,text:cmd.text.trim(),reason:cmd.reason.trim(),status:'PENDING',author:'FICTIONAL_VISITOR'});
  event(p,'AMENDMENT_SUBMITTED','Proposed revision requires steward review');return good(true,'Amendment proposed; current motion text unchanged',next);
 }
 if(cmd.type==='REVIEW_AMEND'){
  const a=p.amendments.find(x=>x.id===cmd.amendmentId&&x.status==='PENDING');
  if(!a||cmd.role!=='DEMO_STEWARD'||!['ACCEPT','DECLINE'].includes(cmd.decision)||!clean(cmd.reason,12,400))return good(false,'Demo steward review and a 12–400 character reason are required',input);
  if(cmd.decision==='ACCEPT'){
   if(a.fromRevision!==p.revision)return good(false,'Stale amendment does not target current revision',input);
   a.status='ACCEPTED';a.reviewReason=cmd.reason.trim();p.text=a.text;p.revision++;p.revisions.push({revision:p.revision,text:p.text,reason:'Accepted fictional amendment '+a.id+' · '+cmd.reason.trim()});p.stage='OPEN';p.response=null;p.progress=0;p.milestones=[];
   for(const other of p.amendments)if(other.status==='PENDING')other.status='SUPERSEDED';
   event(p,'AMENDMENT_ACCEPTED','Revision advanced; prior responses are not transferred');
  }else{a.status='DECLINED';a.reviewReason=cmd.reason.trim();event(p,'AMENDMENT_DECLINED',a.id);}
  return good(true,'Demo steward amendment review recorded',next);
 }
 if(cmd.type==='STAGE'){
  if(cmd.role!=='DEMO_STEWARD'||!clean(cmd.reason,15,400))return good(false,'Demo steward and written justification required',input);
  const transitions={OPEN:['REVIEW'],REVIEW:['OPEN','ACCEPTED','DECLINED'],ACCEPTED:['IMPLEMENTING'],IMPLEMENTING:['COMPLETED']};
  if(!transitions[p.stage]?.includes(cmd.target))return good(false,'Unsupported lifecycle transition',input);
  const before=p.stage;p.stage=cmd.target;
  if(['ACCEPTED','DECLINED'].includes(cmd.target))p.response={decision:cmd.target,reason:cmd.reason.trim(),at:'FICTIONAL_DEMO_EVENT'};
  if(cmd.target==='COMPLETED'&&p.progress!==100){p.stage=before;return good(false,'Implementation must reach 100% with documented milestones before completion',input);}
  event(p,'STAGE_CHANGED',before+' → '+cmd.target+' · '+cmd.reason.trim());return good(true,'Fictional institutional response logged, not authoritative',next);
 }
 if(cmd.type==='MILESTONE'){
  if(cmd.role!=='DEMO_STEWARD'||p.stage!=='IMPLEMENTING'||!Number.isInteger(cmd.percent)||cmd.percent<p.progress||cmd.percent>100||!clean(cmd.text,12,400))return good(false,'Progress must be monotonic 0–100 with documentary explanation',input);
  p.progress=cmd.percent;p.milestones.push({id:'M-'+(p.milestones.length+1),percent:cmd.percent,description:cmd.text.trim(),at:'FICTIONAL_DEMO_EVENT'});
  event(p,'MILESTONE','Progress '+cmd.percent+'%');return good(true,'Fictional implementation evidence recorded',next);
 }
 if(cmd.type==='CORRECTION'){
  if(!clean(cmd.reason,12,400))return good(false,'A specific correction request is required',input);
  next.corrections.push({id:'R-'+(next.corrections.length+1),proposalId:p.id,revision:p.revision,reason:cmd.reason.trim(),status:'UNREVIEWED_LOCAL_DEMO'});
  event(p,'CORRECTION_REQUEST','Fictional correction request, not submitted');return good(true,'Correction recorded only in this browser session',next);
 }
 return good(false,'Unknown or unauthorized synthetic action',input);
}
export function budgetSlate(institution,selected){
 if(!INSTITUTIONS[institution]||!Array.isArray(selected)||new Set(selected).size!==selected.length)throw Error('Invalid budget selection');
 const projects=BUDGET_PROJECTS[institution],valid=new Set(projects.map(p=>p.id));
 if(selected.some(id=>!valid.has(id)))throw Error('Unknown budget item');
 const total=projects.filter(p=>selected.includes(p.id)).reduce((sum,p)=>sum+p.cost,0);
 return {mode:'SYNTHETIC_ONLY',institution,limit:INSTITUTIONS[institution].budget,selected:[...selected],total,remaining:INSTITUTIONS[institution].budget-total,feasible:total<=INSTITUTIONS[institution].budget,authority:'NONE',funding:'NOT_ALLOCATED'};
}
export function publicDossier(p){
 return {kind:'COMMONWEALTH_SYNTHETIC_DOSSIER_V1',id:p.id,title:p.title,institution:p.institution,text:p.text,revision:p.revision,stage:p.stage,source:p.source,sourceStatus:p.sourceStatus,response:p.response,revisions:clone(p.revisions),milestones:clone(p.milestones),events:clone(p.events),commentCount:p.comments.length,amendmentCount:p.amendments.length,official:false,verifiedSource:false,recordCompleteness:'NOT_ASSESSED',warnings:['No real vote, institution response, public release or government source.','Local browser data is mutable and unauthenticated; this dossier is not a Proof Passport.']};
}
