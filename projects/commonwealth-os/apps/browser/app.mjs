import {profiles,syntheticCase,scenarios} from "./fixtures.mjs";
import {evaluate} from "./core.mjs";
const byId=(id)=>document.getElementById(id);
let selected=profiles[0];
let current=null;
const tabs=byId("pilot-tabs");
for(const p of profiles){
  const button=document.createElement("button");
  button.type="button";button.textContent=p.short;button.dataset.id=p.id;
  button.addEventListener("click",()=>{selected=p;render();});
  tabs.append(button);
}
for(const [id,label] of scenarios){
  const opt=document.createElement("option");
  opt.value=id;opt.textContent=label;byId("scenario").append(opt);
}
const presentText=(id,value)=>{byId(id).textContent=String(value)};
function render(){
  for(const b of tabs.querySelectorAll("button")) b.setAttribute("aria-pressed",String(b.dataset.id===selected.id));
  presentText("pilot-name",selected.name);presentText("pilot-description",selected.subheading);
  presentText("authority",selected.authority);presentText("scope",selected.scope);
  presentText("rule-revision",selected.ruleRevision);presentText("quorum",selected.quorum+" of "+selected.eligible.length);
  presentText("threshold",(selected.threshold.strict?"More than ":"At least ")+selected.threshold.numerator+"/"+selected.threshold.denominator+" of yes/no ballots");
  presentText("motion-heading",selected.motion.title);presentText("motion-summary",selected.motion.summary);
  run();
}
function run(){
 const {motion,evidence}=syntheticCase(selected,byId("scenario").value);
 const report=evaluate(selected,motion,evidence);
 current={report,motion,evidence,profileId:selected.id};
 const status=byId("result");
 status.textContent=report.proceduralOutcome.replaceAll("_"," ")+" — NOT OFFICIAL";
 status.className="result "+(report.proceduralOutcome==="SUPPORTED_IN_SIMULATION"?"pass":report.proceduralOutcome==="REJECTED_IN_SIMULATION"?"fail":"unknown");
 const c=report.counts;
 presentText("tally",c?"Synthetic yes "+c.yes+" · no "+c.no+" · abstain "+c.abstain:"No tally available");
 const list=byId("checks");list.replaceChildren();
 for(const item of report.checks){
  const li=document.createElement("li"),title=document.createElement("strong"),flag=document.createElement("span"),detail=document.createElement("p");
  title.textContent=item.code.replaceAll("_"," ");flag.textContent=item.status;flag.className=item.status;detail.textContent=item.detail;
  li.append(title,flag,detail);list.append(li);
 }
}
async function exportPassport(){
 if(!current)return;
 const raw=JSON.stringify(current,null,2);
 const digest=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(raw));
 const hex=[...new Uint8Array(digest)].map(v=>v.toString(16).padStart(2,"0")).join("");
 const bundle=JSON.stringify({warning:"Synthetic demonstration; digest is not a signature or proof of legal authority.",sha256OfPayload:hex,payload:current},null,2);
 const blob=new Blob([bundle],{type:"application/json"});
 const url=URL.createObjectURL(blob),link=document.createElement("a");
 link.href=url;link.download="commonwealth-"+current.profileId+"-demo-passport.json";link.click();
 setTimeout(()=>URL.revokeObjectURL(url),5000);
}
byId("scenario").addEventListener("change",run);
byId("run").addEventListener("click",run);
byId("download").addEventListener("click",()=>{exportPassport().catch(()=>{alert("Export failed: WebCrypto requires a secure context, such as localhost or HTTPS.");});});
render();
