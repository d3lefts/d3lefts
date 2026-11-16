"use strict";
/* Audit the actual SHA-256 export envelope with a separate Node implementation. */
const assert=require("node:assert/strict");
const crypto=require("node:crypto");
const {verifyEnvelope,SCOPE}=require("./verify_commonwealth_export.cjs");
const payload={report:{mode:"SYNTHETIC",officialCertification:false,
  legalAuthorization:"NOT_ASSESSED",proceduralOutcome:"SUPPORTED_IN_SIMULATION"},profileId:"fictional-uah"};
const digest=x=>crypto.createHash("sha256").update(JSON.stringify(x,null,2),"utf8").digest("hex");
const obj={schemaVersion:1,digestScope:SCOPE,sha256OfPayload:digest(payload),payload};
assert.equal(verifyEnvelope(obj).reason,"PAYLOAD_DIGEST_MATCH");
assert.equal(verifyEnvelope({...obj,payload:{...payload,profileId:"changed"}}).reason,"PAYLOAD_DIGEST_MISMATCH");
assert.equal(verifyEnvelope({...obj,sha256OfPayload:"0".repeat(64)}).reason,"PAYLOAD_DIGEST_MISMATCH");
assert.equal(verifyEnvelope({...obj,digestScope:"whole file"}).reason,"INVALID_ENVELOPE");
assert.equal(verifyEnvelope({...obj,payload:{report:{mode:"OFFICIAL"}}}).reason,"UNSUPPORTED_SCOPE");
assert.notEqual(digest(obj),obj.sha256OfPayload,"the envelope hash is not the payload hash");
console.log("PASS Commonwealth exported payload digest: positive, tamper, scope and envelope boundaries");
