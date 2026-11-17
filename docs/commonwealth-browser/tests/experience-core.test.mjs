import test from "node:test";
import assert from "node:assert/strict";
import {readFileSync} from "node:fs";
import {ROLES,RESPONSES,FICTIONAL_ISSUE,FICTIONAL_VIEWPOINTS,FICTIONAL_STEPS,
 fictionalTotal,chooseResponse,validateRole,stepAt} from "../experience-core.mjs";
const html=readFileSync(new URL("../index.html",import.meta.url),"utf8");
const js=readFileSync(new URL("../experience.mjs",import.meta.url),"utf8");
test("role and preference enumeration rejects invalid states",()=>{
 assert.deepEqual(ROLES,["resident","representative","developer"]);
 for(const r of ROLES)assert.equal(validateRole(r),r);
 assert.throws(()=>validateRole("official"),RangeError);
 for(const r of RESPONSES) {
   const answer=chooseResponse(r.id);
   assert.equal(answer.officialVote,false);
   assert.equal(answer.persisted,false);
   assert.equal(answer.label,r.label);
 }
 assert.throws(()=>chooseResponse("vote_yes"),RangeError);
});
test("fictional counts are coherent and never presented as actual public opinion",()=>{
 assert.equal(fictionalTotal(),24);
 assert.deepEqual(FICTIONAL_VIEWPOINTS.map(x=>x.count),[11,7,6]);
 assert.throws(()=>fictionalTotal([{count:-1}]),TypeError);
 assert.equal(FICTIONAL_ISSUE.sourceStatus,"SYNTHETIC_UNVERIFIED");
 for(const phrase of ["invented example positions","not respondents","not detected consensus","No login","No real"])
   assert.ok(html.toLowerCase().includes(phrase.toLowerCase()),"missing caveat: "+phrase);
});
test("five distinct stages expose gaps and never assert implementation",()=>{
 assert.equal(FICTIONAL_STEPS.length,5);
 for(let i=0;i<5;i++)assert.equal(stepAt(i),FICTIONAL_STEPS[i]);
 assert.match(stepAt(4).evidence,/UNKNOWN/);
 assert.throws(()=>stepAt(5),RangeError);
 assert.throws(()=>stepAt(-1),RangeError);
});
test("progressive UI retains explicit entry and never stores or transmits preferences",()=>{
 for(const id of ["cwexp","cwexp-choose","cwexp-perspectives","cwexp-reveal-button","cwexp-clear-button","cwexp-next-step"])
   assert.ok(html.includes('id="'+id+'"'),id);
 assert.ok(html.indexOf('id="cwexp"')<html.indexOf('id="cwui-chamber"'));
 assert.match(html,/\.\/experience\.mjs/);
 assert.match(html,/\.\/experience\.css/);
 assert.doesNotMatch(js,/localStorage|sessionStorage|indexedDB|sendBeacon|XMLHttpRequest|fetch\s*\(|document\.cookie/);
 assert.doesNotMatch(js,/innerHTML\s*=/);
 for(const role of ROLES)assert.ok(html.includes('data-cwexp-role="'+role+'"'));
});
