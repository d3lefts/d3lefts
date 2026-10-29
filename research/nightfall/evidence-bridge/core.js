/* NIGHTFALL Evidence Bridge v0 — preview-only strict adapters. JS/browser & Node. */
"use strict";
(function(root,factory){
  const api=factory();
  if(typeof module!=="undefined"&&module.exports)module.exports=api;
  else root.NightfallEvidenceBridge=api;
})(typeof globalThis!=="undefined"?globalThis:this,function(){
 const VERSION="0.1.0",FORMAT="nightfall-evidence-bridge-preview-v0";
 const REFEREE="nightfall-referee-receipt-v1",EXACT="nightfall-exact-local-receipt-v1";
 const acceptedTop={
  [REFEREE]:new Set(["format","verifier","version","createdAt","domain","source","claimedScore","claimedMaximum","inputSha256","verdict","result","negativeControls","notes","sourceDossier","receiptId"]),
  [EXACT]:new Set(["format","createdAt","computedBy","input","result","receiptId"])
 };
 const labels={
  "weak-sidon-4-5-finite":"Finite Sidon (4,5) bound on one integer set",
  "continuous-step-overlap":"Finite continuous step-overlap objective",
  "exact-four-qutrit-werner-v1":"Fixed four-qutrit coefficient arithmetic",
  "exhaustive-f25-fourth-power-v1":"One fixed F25 sensing instance"
 };
 function refuse(code,why){const e=new Error(why);e.code=code;throw e}
 function plain(o){return o!==null&&typeof o==="object"&&!Array.isArray(o)&&Object.getPrototypeOf(o)===Object.prototype}
 function requireKeys(o,keys,path){if(!plain(o))refuse("SHAPE",path+" must be a plain JSON object.");
   for(const k of Object.keys(o))if(!keys.has(k))refuse("UNKNOWN_FIELD","Unsupported "+path+" field: "+k+". Extra authority or cross-scope claims are refused.");
 }
 function rejectAuthority(o){
  const reserved=/^(?:approval|approved|approvedBy|independently_checked|independentlyChecked|reviewed|reviewer|reviewerSignoff|signed|signature|scientificStatus|publicationStatus|proofStatus|asymptoticBound|claimedAsymptoticBound|unrestrictedTheorem|theoremClaim|priorityClaim|competitiveRecord|codeVersion|producerVersion)$/i;
  let nodes=0;
  function walk(x,depth){if(++nodes>10000||depth>22)refuse("COMPLEXITY","Excessive receipt structure.");
   if(Array.isArray(x)){for(const y of x)walk(y,depth+1)}
   else if(plain(x)){for(const [k,v] of Object.entries(x)){if(reserved.test(k))refuse("AUTHORITY_SPOOF","Receipt supplied an unauthorized authority, novelty, or cross-scope field: "+k+".");walk(v,depth+1)}}
  }walk(o,0)
 }
 function equal(a,b){return JSON.stringify(a)===JSON.stringify(b)}
 function shaHex(hexBytes){return Array.from(hexBytes,b=>b.toString(16).padStart(2,"0")).join("")}
 async function digest(value){
  const text=JSON.stringify(value);
  if(typeof module!=="undefined"&&module.exports)return require("node:crypto").createHash("sha256").update(text,"utf8").digest("hex");
  if(!globalThis.crypto?.subtle)refuse("CRYPTO","SHA-256 requires a secure browser context.");
  return shaHex(new Uint8Array(await globalThis.crypto.subtle.digest("SHA-256",new TextEncoder().encode(text))));
 }
 function bounded(json){
  if(typeof json==="string"){
   if(new TextEncoder().encode(json).length>1000000)refuse("SIZE","Receipt exceeds the 1 MB safe input bound.");
   let data;try{data=JSON.parse(json)}catch(e){refuse("JSON","Receipt is not valid JSON.")}
   if(!plain(data))refuse("SHAPE","Receipt must contain one JSON object.");
   return data
  }
  if(!plain(json))refuse("SHAPE","Receipt must contain one JSON object.");
  if(JSON.stringify(json).length>1000000)refuse("SIZE","Receipt exceeds the 1 MB safe input bound.");
  return json
 }
 function failIfDuplicate(id,seen){
  if(seen instanceof Set&&seen.has(id))refuse("DUPLICATE","This exact receipt fingerprint already exists in the local experiment ledger.");
 }
 async function preview(input,options={}){
  const r=bounded(input);
  if(typeof r.format!=="string"||!acceptedTop[r.format])refuse("VERSION","Unknown receipt family/version. No implicit converter is permitted.");
  rejectAuthority(r);
  requireKeys(r,acceptedTop[r.format],"receipt");
  const C=options.refereeCore||((typeof module!=="undefined"&&module.exports)?require("../../../docs/referee-core.js"):globalThis.RefereeCore);
  const X=options.exactCore||((typeof module!=="undefined"&&module.exports)?require("../../../docs/research-tools-core.js"):globalThis.NIGHTFALL_EXACT);
  let engine,scope,result,canonicalInput,sourceVersion,reportStatus,negativeControls;
  if(r.format===REFEREE){
   if(r.version!=="1.0.0"||!C||r.version!==C.VERSION)refuse("CODE_VERSION","Referee engine version differs from the supported v1.0.0 implementation.");
   if(!plain(r.source)||!plain(r.result)||!plain(r.negativeControls))refuse("SHAPE","Referee requires exact source, result and negative controls.");
   if(r.verifier!=="NIGHTFALL Referee")refuse("SOURCE_METADATA","Referee producer metadata differs from the canonical first-party label.");
   const canonicalDossier="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md";
   if(Object.hasOwn(r,"sourceDossier")&&(r.domain!=="weak-sidon-4-5-finite"||r.sourceDossier!==canonicalDossier))refuse("SOURCE_METADATA","Source dossier path disagrees with the allowlisted finite witness.");
   if(Object.hasOwn(r,"notes")&&(!Array.isArray(r.notes)||r.notes.some(x=>typeof x!=="string"||x.length>450||/\b(?:independently certified|externally verified|peer reviewed|global theorem proven|official record)\b/i.test(x))))refuse("AUTHORITY_SPOOF","Receipt notes contain unsupported source-review authority.");

   if(typeof r.inputSha256!=="string"||!/^[a-f0-9]{64}$/.test(r.inputSha256))refuse("INPUT_HASH","Referee input fingerprint is missing or malformed.");
   engine=r.domain;sourceVersion=r.version;
   if(engine==="weak-sidon-4-5-finite"){
    if(!Array.isArray(r.source.points)||!Array.isArray(r.source.subset)||!Number.isSafeInteger(r.claimedMaximum))refuse("INPUT","Finite Sidon coordinates and integer maximum are required.");
    canonicalInput={domain:engine,input:r.source,claimedMaximum:r.claimedMaximum};
    if(!equal(Object.keys(r.source).sort(),["points","subset"]))refuse("INPUT","Finite Sidon input contains unsupported fields.");
   }else if(engine==="continuous-step-overlap"){
    if(!Array.isArray(r.source.heights)||r.source.denominator===undefined||!Object.hasOwn(r,"claimedScore"))refuse("INPUT","Exact overlap heights, denominator and claimed score are required.");
    canonicalInput={domain:engine,input:r.source,claimedScore:r.claimedScore};
    if(!equal(Object.keys(r.source).sort(),["denominator","heights"]))refuse("INPUT","Overlap input contains unsupported fields.");
   }else refuse("DOMAIN","Unsupported Referee mathematical domain.");
   const hash=await digest(canonicalInput);
   if(hash!==r.inputSha256)refuse("INPUT_HASH","Canonical finite input SHA-256 differs; the witness or claim was changed.");
   if(r.receiptId&&r.receiptId!==hash)refuse("RECEIPT_ID","Receipt identifier conflicts with canonical input fingerprint.");
   try{
    result=engine==="weak-sidon-4-5-finite"?C.checkSidon(r.source,r.claimedMaximum):C.checkOverlap(r.source,r.claimedScore);
    negativeControls=engine==="weak-sidon-4-5-finite"?C.sidonAttacks(r.source,r.claimedMaximum):C.overlapAttacks(r.source,result);
   }catch(e){refuse("REPLAY_INPUT","Finite receipt input fails replay: "+e.message)}
   if(!equal(result,r.result))refuse("RESULT_REPLAY","Referee result differs from a local exact-core recomputation.");
   if(!equal(negativeControls,r.negativeControls))refuse("NEGATIVE_CONTROLS","Referee negative controls differ from a local recomputation.");
   const passed=result.status==="FINITE_CHECK_PASSED" && (engine==="weak-sidon-4-5-finite"?
      negativeControls.understatedMaximumRejected&&negativeControls.corruptedSubsetRejected:
      result.dualPathAgreement&&negativeControls.scoreTamperRejected&&negativeControls.massPreservingWitnessMutation?.rejected===true);
   const expected=engine==="weak-sidon-4-5-finite"?(passed?"FINITE_CHECK_PASSED":"REJECTED_OR_INCONCLUSIVE"):
      passed?"FINITE_CHECK_PASSED":result.status==="REJECT"?"REJECTED":"INCONCLUSIVE";
   if(r.verdict!==expected)refuse("VERDICT","Claimed Referee verdict differs from the scoped local replay.");
   reportStatus=expected;
   scope=engine==="weak-sidon-4-5-finite"?"Specific published integer set; exact weak (4,5) and Sidon subset checks; never a bound for all set sizes.":"2–256 uniform cells; mass-normalized signed real-shift maximum; distinct from the archived 131072-cell construction.";
  }else{
   if(!plain(r.result)||r.input===undefined||r.computedBy!=="local browser arithmetic; no independent signoff")refuse("FORMAT","Unsupported Exact Tools receipt payload and producer identity.");
   engine=r.result.engine;sourceVersion=engine;
   if(!["exact-four-qutrit-werner-v1","exhaustive-f25-fourth-power-v1"].includes(engine))refuse("CODE_VERSION","Unknown exact arithmetic implementation version.");
   if(!X)refuse("CORE_UNAVAILABLE","Exact Tools arithmetic engine unavailable. Import remains read-only.");
   if(r.receiptId!==undefined)refuse("RECEIPT_ID","Legacy exact-local format has no canonical receiptId field.");
   try{result=engine==="exact-four-qutrit-werner-v1"?X.werner(r.input):X.f25(r.input)}catch(e){refuse("REPLAY_INPUT","Exact-local receipt input fails replay: "+e.message)}
   if(!equal(result,r.result))refuse("RESULT_REPLAY","Exact-local receipt result differs from deterministic local arithmetic.");
   canonicalInput={engine,input:r.input};negativeControls=null;reportStatus="LOCAL_CALCULATION";
   scope=engine==="exact-four-qutrit-werner-v1"?"One explicitly specified four-qutrit coefficient matrix; rank and rational evaluation only.":"One explicitly specified F25, k=2 sensing design; finite preimage enumeration only.";
  }
  const inputHash=await digest(canonicalInput);
  const receiptHash=await digest(r);
  failIfDuplicate(inputHash,options.seenInputHashes);
  failIfDuplicate(receiptHash,options.seenReceiptHashes);
  return Object.freeze({
   format:FORMAT,adapterVersion:VERSION,receiptId:inputHash,receiptSha256:receiptHash,inputSha256:inputHash,
   sourceFormat:r.format,producerVersion:sourceVersion,domain:engine,scope,
   resultStatus:reportStatus,verification:"Local exact recomputation in the same research codebase; no external referee or signature.",
   reviewStatus:"unreviewed",promotionAllowed:false,claimsTouched:[],authoritativeReviewer:null,
   title:"Evidence Bridge / "+labels[engine],explanation:"Input and exact result agree with local first-party code. An independent cross-language replay and scientific review remain separate.", 
   proposedExperiment:{title:"Evidence Bridge / "+labels[engine],operator:"Source-linked receipt / local recomputation",prediction:"Imported input and result are internally consistent under the source domain.",falsifier:"Run independent Python replay for Referee or independently implement the bounded exact calculator.",status:"tested",cost:0,result:"LOCAL RECOMPUTATION / UNREVIEWED: "+reportStatus+"; "+scope,evidence:"BRIDGE-ID:"+inputHash+" RECEIPT-SHA256:"+receiptHash+"; Original receipt must be archived separately."}
  })
 }
 return Object.freeze({VERSION,FORMAT,preview});
});
