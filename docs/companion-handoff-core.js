/* NIGHTFALL Referee ↔ Imaginary Adversary: input-only, one-shot same-origin handoff.
   Never transfers a proof verdict or a claim-status upgrade. */
(function(root,factory){
 const api=factory();if(typeof module==="object"&&module.exports)module.exports=api;
 else root.NightfallCompanionHandoff=api;
})(typeof globalThis==="object"?globalThis:this,function(){
"use strict";
const FORMAT="nightfall-companion-input-handoff-v1";
const KEY="nightfall.companion.input.v1";
function fail(s){throw Error(s)}
function tokens(v){return Array.isArray(v)?v.map(String):String(v??"").trim().split(/[\s,;]+/).filter(Boolean)}
function num(x,max=1000000000){
 const s=String(x).trim();
 if(!/^-?(0|[1-9]\d*)$/.test(s))fail("Noncanonical exact integer.");
 const n=Number(s);if(!Number.isSafeInteger(n)||Math.abs(n)>max)fail("Coordinate exceeds supported bound.");
 return n;
}
function parseInput(target,domain,raw){
 if(!raw||typeof raw!=="object")fail("Missing finite editor input.");
 if(domain==="sidon"){
  const points=tokens(raw.points).map(x=>num(x));const n=points.length;
  if(n<4||n>(target==="referee"?30:40))fail("This destination supports 4–"+(target==="referee"?30:40)+" marks. Reduce the input, or keep it in the original tool.");
  if(new Set(points).size!==n)fail("Repeated integer coordinates.");
  const sorted=points.slice().sort((a,b)=>a-b).map(String);
  return{points:sorted};
 }
 if(domain==="overlap"){
  const d=num(raw.denominator,1000000),heights=tokens(raw.heights).map(x=>num(x,1000000));
  if(d<=0||heights.length<2||heights.length>(target==="adversary"?64:256))fail("Destination accepts 2–"+(target==="adversary"?64:256)+" cells and a positive denominator.");
  if(heights.some(x=>x<0||x>d))fail("Cell height outside the allowed range.");
  if(2n*heights.reduce((a,b)=>a+BigInt(b),0n)!==BigInt(heights.length)*BigInt(d))fail("Exact unit-mass invariant failed.");
  const upper=String(raw.claimedUpper??"").trim();
  if(upper&&!/^\d{1,22}(?:\/[1-9]\d{0,21})?$/.test(upper))fail("Expected a nonnegative rational p/q upper claim.");
  return{denominator:String(d),heights:heights.map(String),claimedUpper:upper};
 }
 fail("Unsupported finite companion domain.");
}
function build(from,to,domain,raw){
 if(!((from==="referee"&&to==="adversary")||(from==="adversary"&&to==="referee")))fail("Unsupported companion direction.");
 if(!["sidon","overlap"].includes(domain))fail("General theory questions have no finite Referee handoff.");
 return{format:FORMAT,from,to,domain,input:parseInput(to,domain,raw),
  reviewStatus:"unreviewed",scientificStatus:"INPUT ONLY: rerun before any exact verdict",
  scope:domain==="sidon"?"Transfers marks for a four-point (4,5) challenge. Referee's h(B) maximal-Sidon-subset proof requires separately supplied subset and bound.":"Transfers integer equal-width cells for an exact bounded attack; no arithmetic result, claim priority or status travels with this handoff."};
}
function parse(text,to){
 if(typeof text!=="string"||text.length>40000)fail("Missing or oversized companion handoff.");
 let p;try{p=JSON.parse(text)}catch{fail("Malformed handoff JSON.")}
 if(!p||p.format!==FORMAT||p.to!==to||p.reviewStatus!=="unreviewed"||p.scientificStatus!=="INPUT ONLY: rerun before any exact verdict")fail("Unsupported or status-upgraded companion handoff.");
 const clean=build(p.from,p.to,p.domain,p.input);
 if(JSON.stringify(clean.input)!==JSON.stringify(p.input))fail("Handoff input violates the canonical finite source contract.");
 return clean;
}
return{FORMAT,KEY,build,parse,parseInput};
});
