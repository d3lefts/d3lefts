#!/usr/bin/env node
"use strict";
/* Separate Node replayer for Commonwealth's browser-only synthetic Passport envelope.
 * A digest match means payload integrity only, NOT signed or official evidence. */
const fs=require("node:fs");
const crypto=require("node:crypto");
const {resolve}=require("node:path");
const SCOPE="UTF8(JSON.stringify(payload,null,2))";
function verifyEnvelope(envelope){
  if(!envelope || typeof envelope!=="object" || Array.isArray(envelope) ||
     envelope.schemaVersion!==1 || envelope.digestScope!==SCOPE ||
     typeof envelope.sha256OfPayload!=="string" ||
     !/^[0-9a-f]{64}$/.test(envelope.sha256OfPayload) ||
     !envelope.payload || typeof envelope.payload!=="object" || Array.isArray(envelope.payload))
    return {ok:false,reason:"INVALID_ENVELOPE"};
  const report=envelope.payload.report;
  if(!report || report.mode!=="SYNTHETIC" ||
     report.officialCertification!==false || report.legalAuthorization!=="NOT_ASSESSED")
    return {ok:false,reason:"UNSUPPORTED_SCOPE"};
  const raw=JSON.stringify(envelope.payload,null,2);
  const computed=crypto.createHash("sha256").update(Buffer.from(raw,"utf8")).digest("hex");
  const ok=crypto.timingSafeEqual(Buffer.from(computed,"hex"),Buffer.from(envelope.sha256OfPayload,"hex"));
  return {ok,reason:ok?"PAYLOAD_DIGEST_MATCH":"PAYLOAD_DIGEST_MISMATCH",computed,scope:SCOPE,
    caution:"No signature, government authentication, legal certification, or proof of semantic correctness."};
}
function verifyFile(file){
  const stat=fs.statSync(file);
  if(stat.size>2_000_000) return {ok:false,reason:"FILE_TOO_LARGE"};
  return verifyEnvelope(JSON.parse(fs.readFileSync(file,"utf8")));
}
if(require.main===module){
  const path=process.argv[2];
  if(!path){console.error("Usage: node scripts/verify_commonwealth_export.cjs exported-passport.json");process.exitCode=2;}
  else{
    try{
      const result=verifyFile(resolve(path));
      console.log(JSON.stringify(result,null,2));
      if(!result.ok)process.exitCode=1;
    }catch(e){console.error("INVALID_FILE: "+e.message);process.exitCode=1;}
  }
}
module.exports={verifyEnvelope,verifyFile,SCOPE};
