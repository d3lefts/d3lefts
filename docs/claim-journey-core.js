"use strict";
/* Claim-continuity contracts: sourced solely from the canonical Proof Passport registry.
 * A browser research note is a draft, never proof, publication, or an assignment grant. */
(function(root,factory){
 const api=factory();
 if(typeof module!=="undefined"&&module.exports)module.exports=api;
 else root.NFClaimJourney=api;
})(typeof globalThis!=="undefined"?globalThis:this,function(){
 const VERSION=1,KEY="nightfall.claim.journey.v1",MAX=4000;
 const isClaim=(R,id)=>!!(R&&Array.isArray(R.claims)&&R.claims.some(x=>x.id===id&&Array.isArray(x.open)&&x.open.length));
 const get=(R,id,index)=>{
  if(!isClaim(R,id))return null;
  const claim=R.claims.find(x=>x.id===id);
  if(!Number.isSafeInteger(index)||index<0||index>=claim.open.length)return null;
  return {claim,index,obligation:claim.open[index],snapshot:R.asOf+" | "+claim.id+" | "+claim.open[index],
   key:claim.id+"|"+index};
 };
 const url=(id,index=0)=>"join.html?claim="+encodeURIComponent(id)+"&obligation="+index+"#claim-investigation";
 const passport=id=>"passport.html?claim="+encodeURIComponent(id);
 const parse=(R,search)=>{
  const params=new URLSearchParams(search),has=params.has("claim"),id=params.get("claim");
  if(!has)return {requested:false,contract:null};
  if(!isClaim(R,id))return {requested:true,contract:null,reason:"Unknown claim ID. Use the published Proof Passports to choose a supported investigation."};
  const raw=params.get("obligation");
  if(raw!==null&&!/^(0|[1-9][0-9]*)$/.test(raw))return {requested:true,contract:null,reason:"Invalid obligation index. Choose a listed research obligation."};
  const contract=get(R,id,raw===null?0:Number(raw));
  return contract?{requested:true,contract}:{requested:true,contract:null,reason:"This obligation is absent from the current source registry. Choose a listed obligation."};
 };
 const sanitize=(R,obj)=>{
  const result={version:VERSION,selected:null,entries:{}};
  if(!obj||obj.version!==VERSION||typeof obj!=="object")return result;
  const selected=obj.selected;
  if(selected&&get(R,selected.claimId,selected.index))result.selected={claimId:selected.claimId,index:selected.index};
  const entries=obj.entries;
  if(!entries||typeof entries!=="object"||Array.isArray(entries))return result;
  for(const [key,item] of Object.entries(entries).slice(0,100)){
   const parts=/^([a-z0-9_-]{1,40})\|(0|[1-9][0-9]*)$/.exec(key);
   if(!parts)continue;
   const contract=get(R,parts[1],Number(parts[2]));
   if(!contract||contract.key!==key||item?.snapshot!==contract.snapshot||typeof item.note!=="string")continue;
   result.entries[key]={snapshot:contract.snapshot,note:item.note.slice(0,MAX),savedAt:typeof item.savedAt==="string"?item.savedAt.slice(0,40):null};
  }
  return result;
 };
 const issue=(contract,note)=>{
  if(!contract)return null;
  const text="Claim: "+contract.claim.title+" ("+contract.claim.id+")\n"+
   "Canonical registry snapshot: "+contract.snapshot+"\n"+
   "Exact unresolved obligation: "+contract.obligation+"\n"+
   "Conditions: "+contract.claim.conditions+"\n"+
   "Proof Passport: https://d3lefts.github.io/d3lefts/"+passport(contract.claim.id)+"\n\n"+
   "Proposed test, source bytes/checksums, reproducible commands, negative controls, and results:\n"+
   (note.trim()||"[Provide a falsifiable method and a reproducible artifact.]")+"\n\n"+
   "Status: contributor proposal, unreviewed. No theorem, novelty, competition status, or publication promotion is implied.";
  return "https://github.com/d3lefts/d3lefts/issues/new?title="+encodeURIComponent("External review: "+contract.claim.id+" / obligation "+(contract.index+1))+"&body="+encodeURIComponent(text);
 };
 const brief=(contract,note)=>{
  if(!contract)return "";
  return "NIGHTFALL / UNREVIEWED RESEARCH NOTE\nClaim: "+contract.claim.title+" ("+contract.claim.id+")"+
   "\nRegistry: "+contract.snapshot+"\nObligation: "+contract.obligation+"\nConditions: "+contract.claim.conditions+
   "\nStatement: "+contract.claim.statement+"\nProof Passport: https://d3lefts.github.io/d3lefts/"+passport(contract.claim.id)+
   "\n\nAUTHOR NOTES / UNREVIEWED\n"+(note.trim()||"No notes recorded.")+
   "\n\nBOUNDARY: Local source-linked note only. No exact checker, external review, priority, proof or publication status has been conferred.\n";
 };
 return Object.freeze({VERSION,KEY,MAX,isClaim,get,url,passport,parse,sanitize,issue,brief});
});
