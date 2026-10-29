/* CONSTELLATION investigation handoff.
   Visited stages are personal navigation markers, never proof credentials. */
(function(){
"use strict";
const KEY="nightfall.investigation.v1",IDS=["sidon","cycles","audit"],ROLES=["construct","challenge","verify"];
const $=id=>document.getElementById(id);
function get(){try{return JSON.parse(localStorage.getItem(KEY)||"null")}catch{return null}}
function put(s){try{if(s)localStorage.setItem(KEY,JSON.stringify(s));else localStorage.removeItem(KEY);return true}catch{return false}}
const challenges={
 sidon:{name:"A small maximal Sidon set",question:"Erdős #156 · prescribed N=184, k=9",issue:"https://github.com/d3lefts/d3lefts/issues/46",
  result:"passport.html?claim=sidon30",source:"https://www.erdosproblems.com/156",
  prior:"A 30-point finite Sidon witness has a certified 17-point maximum Sidon subset. That is a different finite problem from this unresolved nine-mark maximality question.",
  gap:"Produce a nine-mark maximal Sidon witness at N=184, or an exact exclusion certificate. Search outcomes without complete coverage are provisional.",
  build:"frontier.html",buildTitle:"Open Frontier's nine-mark bounded task",experiment:"discovery.html",
  challenge:"adversary.html?domain=sidon#workbench",verification:"https://github.com/d3lefts/d3lefts/issues/46",
  verificationTitle:"Inspect the source certificate obligations"},
 cycles:{name:"Power-of-two cycles",question:"Erdős #64 · lift and cycle obstruction",issue:"https://github.com/d3lefts/d3lefts/issues/47",
  result:"findings-20261029.html#graph-3port",source:"https://www.erdosproblems.com/64",
  prior:"The existing finite negative study rules out two three-port gadget families on 27 fixed graphs. A separate uniform K3,3 cyclic-cover construction moves the first power-of-two cycle to length 32.",
  gap:"Find a genuinely new graph-family transfer invariant, a verified small counterexample, or a sharp obstruction. Existing K4 and abelian 3-offset families have been exhausted.",
  build:"orchestrator.html",buildTitle:"Freeze a new graph-family claim",experiment:"discovery.html",
  challenge:"orchestrator.html",verification:"https://github.com/d3lefts/d3lefts/pull/57",
  verificationTitle:"Inspect exact cycle checkers and graph inputs"},
 audit:{name:"Finite witness under attack",question:"30-point Sidon · scoped exact replay",issue:"review.html#sidon",
  result:"passport.html?claim=sidon30",source:"https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md",
  prior:"The 30-integer finite construction has a verified maximum Sidon subset of 17. The published asymptotic 5/9 baseline belongs to previous researchers.",
  gap:"Independent arithmetic reproduction, a legal mutation, or a full proof attack on the finite 18-point exclusion are meaningful. A passing toy test cannot establish a new asymptotic claim.",
  build:"referee.html?domain=sidon#workbench",buildTitle:"Replay Referee's exact integer witness",experiment:"referee.html?domain=sidon#workbench",
  challenge:"adversary.html?domain=sidon#workbench",verification:"referee.html?domain=sidon#workbench",
  verificationTitle:"Run the independent finite replay"}
};
const steps=[
 {short:"Read the result",title:"Start with something established.",detail:c=>c.prior,link:c=>c.result,action:"Inspect the published evidence",boundary:"Read the scoped finding as written. A finite witness establishes the listed finite property only."},
 {short:"Take the missing piece",title:"Name the unresolved obligation.",detail:c=>c.gap,link:c=>c.issue,action:"Read the active assignment",boundary:"Assignments are public source snapshots. Confirm the issue's latest comments before attempting a claim."},
 {short:"Construct a test",title:"Choose a representation that can fail.",detail:c=>"Move from question to a reproducible search contract. Select an operator, specify its input and an explicit stop or kill criterion.",link:(c,s)=>s.role==="verify"?c.experiment:c.build,action:(c,s)=>s.role==="verify"?"Open the finite experiment":"Open the construction instrument",boundary:"Discovery Engine is a bounded laboratory. Its toy finite checks cannot decide the general parent problem."},
 {short:"Attack the assumption",title:"Give doubt a precise target.",detail:c=>"Try a legal perturbation, duplicate-support collision, omitted cycle, incorrect symmetry transfer, or a missing premise. A serious falsifier is more valuable than an unqualified pass.",link:c=>c.challenge,action:"Open the adversarial instrument",boundary:"A generated attack idea is a hypothesis until a literal counterexample or independently checked derivation exists."},
 {short:"Reproduce the arithmetic",title:"Verify exactly what was claimed.",detail:c=>"Retrieve the primary object. Check its arithmetic with a separate path, include corrupted-input controls and preserve scope. When the browser tool lacks the right model, use the primary source checker.",link:c=>c.verification,action:c=>c.verificationTitle,boundary:"A pass validates a bounded object and stated assumptions. It does not automatically establish novelty or a general theorem."},
 {short:"Preserve and hand off",title:"Make the next investigation possible.",detail:c=>"Record the source version, tested claim, failure conditions, exact inputs, verifier, observations and the next open question. Export your local brief and share evidence through the active issue after review.",link:c=>"claim-lab.html",action:"Open Claim Lab's evidence ledger",boundary:"Export and stage navigation are private organizational actions. No submission, independent review or mathematical approval occurs automatically."}
];
let session=get();if(!session||!IDS.includes(session.id)||!ROLES.includes(session.role)||!Number.isInteger(session.step)||session.step<0||session.step>=steps.length){session=null}
let chosen=session?.id||"sidon";let chosenRole=session?.role||"construct";
function paintChoices(){
 document.querySelectorAll("[data-issue]").forEach(b=>b.setAttribute("aria-pressed",String(b.dataset.issue===chosen)));
 const role=chosenRole;
 document.querySelectorAll('input[name="iv-role"]').forEach(r=>{r.checked=r.value===role});
}
function stamp(t){$("iv-save-status").textContent=t}
function render(){
 paintChoices();const nav=$("iv-steps"),main=$("iv-step-content"),status=$("iv-session-status");
 if(!session){status.textContent="No active session · choose an entry point above";nav.innerHTML='<p class="iv-placeholder">A selected obligation reveals six connected stages, each with exact source links and a specific falsifier.</p>';
 main.innerHTML='<span class="section-id">READY / NO ACTIVE SESSION</span><h3>The research starts with a question.</h3><p>Choose an obligation and a method, then begin. Nothing is submitted merely by visiting a stage.</p>';
 $("iv-note").value="";return}
 const c=challenges[session.id],step=steps[session.step];
 status.textContent=c.question+" · "+session.role.toUpperCase()+" · STAGE "+(session.step+1)+"/"+steps.length;
 nav.replaceChildren();
 steps.forEach((s,i)=>{
   const b=document.createElement("button");b.type="button";b.className="iv-step";b.setAttribute("aria-current",session.step===i?"step":"false");
   const n=document.createElement("span");n.className="iv-step-num";n.textContent=String(i+1).padStart(2,"0");
   const t=document.createElement("span");const st=document.createElement("strong");st.textContent=s.short;
   const v=document.createElement("small");v.textContent=(session.visited||[]).includes(i)?"INSPECTED / SELF-REPORTED":i===session.step?"CURRENT STEP":"AVAILABLE";
   t.append(st,v);b.append(n,t);b.addEventListener("click",()=>{session.step=i;put(session);render()});
   nav.appendChild(b);
 });
 main.replaceChildren();
 const kicker=document.createElement("span");kicker.className="section-id";kicker.textContent="STAGE "+String(session.step+1).padStart(2,"0")+" / "+c.name.toUpperCase();
 const title=document.createElement("h3");title.textContent=step.title;
 const p=document.createElement("p");p.textContent=step.detail(c,session);
 const dep=document.createElement("div");dep.className="iv-dependency";
 const dstrong=document.createElement("strong");dstrong.textContent="The proof boundary";
 const dtext=document.createElement("span");dtext.textContent=step.boundary;
 dep.append(dstrong,dtext);
 const caution=document.createElement("p");caution.className="iv-caveat";caution.textContent="Source and tool remain independent of this navigation wrapper. A stage marked inspected is self-reported, never a certificate.";
 const actions=document.createElement("div");actions.className="iv-step-actions";
 const link=document.createElement("a");link.href=step.link(c,session);link.textContent=typeof step.action==="function"?step.action(c,session):step.action;
 if(link.href.startsWith("https://github.com")||link.href.startsWith("https://www.erdosproblems.com")){link.target="_blank";link.rel="noopener"}
 const btn=document.createElement("button");btn.type="button";btn.textContent=session.step===steps.length-1?"Mark the handoff inspected":"Mark inspected / next stage →";
 btn.addEventListener("click",()=>{
  session.visited=Array.from(new Set([...(session.visited||[]),session.step]));
  session.step=Math.min(steps.length-1,session.step+1);put(session);render();
 });
 actions.append(link,btn);main.append(kicker,title,p,dep,caution,actions);
 $("iv-note").value=session.note||"";
}
document.querySelectorAll("[data-issue]").forEach(b=>b.addEventListener("click",()=>{chosen=b.dataset.issue;session=null;render();paintChoices()}));
document.querySelectorAll('input[name="iv-role"]').forEach(input=>input.addEventListener("change",()=>{if(input.checked)chosenRole=input.value}));
$("iv-start-button").addEventListener("click",()=>{
 const role=chosenRole;
 session={schema:"nightfall-investigation-v1",id:chosen,role:ROLES.includes(role)?role:"construct",step:0,visited:[],note:""};
 put(session);render();stamp("Session created locally; no submission made.");
 $("iv-workspace").scrollIntoView({behavior:window.matchMedia("(prefers-reduced-motion: reduce)").matches?"instant":"smooth",block:"start"});
});
$("iv-note").addEventListener("input",()=>{
 if(!session)return;session.note=$("iv-note").value.slice(0,1200);
 stamp(put(session)?"Working note saved in this browser.":"Local storage unavailable; export your brief.");
});
$("iv-reset").addEventListener("click",()=>{session=null;put(null);chosen="sidon";chosenRole="construct";render();stamp("Local investigation reset.");});
$("iv-export").addEventListener("click",()=>{
 if(!session){stamp("Choose an investigation before exporting.");return}
 const c=challenges[session.id];
 const data={schema:"nightfall-navigation-brief-v1",scientific_status:"UNREVIEWED_NAVIGATION_NOT_PROOF",
  problem:c.question,source:c.issue,selected_role:session.role,active_stage:session.step+1,
  self_reported_inspected_stages:session.visited||[],note:session.note||"",
  caution:"A personal research brief only. No math check, authorship, identity or external review verified."};
 const url=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)+"\n"],{type:"application/json"}));
 const a=document.createElement("a");a.href=url;a.download="nightfall-investigation-brief.json";document.body.append(a);a.click();a.remove();
 setTimeout(()=>URL.revokeObjectURL(url),1000);stamp("Local brief exported; no external submission.");
});
render();
})();
