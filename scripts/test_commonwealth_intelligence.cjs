"use strict";
/* Synthetic Commonwealth website contract: source parity and independent fixture-model tests. */
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(root,file),"utf8");
const sandbox = {window:{},document:{querySelector:() => null}};
vm.runInNewContext(read("docs/commonwealth-archetypes.js"),sandbox,{filename:"commonwealth-archetypes.js"});
vm.runInNewContext(read("docs/commonwealth-intelligence-fixtures.js"),sandbox,{filename:"commonwealth-fixtures.js"});
vm.runInNewContext(read("docs/commonwealth-intelligence.js"),sandbox,{filename:"commonwealth-app.js"});

const F = sandbox.window.COMMONWEALTH_SYNTHETIC;
const L = sandbox.window.COMMONWEALTH_DEMO_LOGIC;
assert(F && L,"Missing synthetic fixtures or standalone testable logic");
for (const name of ["house","senate","municipal","issues"]) {
  const expected = JSON.parse(read("projects/commonwealth-os/historical/fixtures/"+name+".json"));
  const actual = JSON.parse(JSON.stringify(F[name]));
  assert.deepEqual(actual,expected,name+" public-site source must exactly match backend fixture");
  assert.equal(actual.synthetic,true);
}
const find = (source,id) => Object.assign({chamber:source.chamber},source.questions.find(q => q.question_id === id));
assert.equal(L.quizCount,20);
assert.equal(L.archetypeCount,12);
const profiles=sandbox.window.COMMONWEALTH_ARCHETYPES;
assert.equal(profiles.length,12);
assert.equal(new Set(profiles.map(p=>p.key)).size,12,"stable unique archetype identifiers");
const expected=[
  "The Civic Creator","The Tech Reformist","The Climate Guardian","The Liberty Defender",
  "The Equality Champion","The Working American","The Community Builder","The Global Minded",
  "The Security Sentinel","The Care Advocate","The Opportunity Builder","The Balanced Pragmatist"];
assert.deepEqual(Array.from(profiles.map(p=>p.name)),expected,"12 approved Gen Z identities and order");
for(const profile of profiles){
 assert.ok(profile.description.length>=60,"two-line profile description: "+profile.name);
 assert.ok(profile.description.length<=350,"card-appropriate profile description");
 assert.match(profile.color,/^#[a-f\d]{6}$/i);
 assert.ok(fs.existsSync(path.join(root,"docs",profile.art)),"missing illustration: "+profile.art);
 assert.ok(read("docs/"+profile.art).includes("<svg"),"not a vector sticker");
}
const noAnswers=Array(20).fill(null);
const starter=L.pickArchetype(noAnswers);
assert.equal(starter.starter,true,"no evidence means a clearly labeled starter badge");
assert.equal(starter.mode,"STARTER BADGE");
assert.equal(starter.profile.name,"The Balanced Pragmatist");
assert.equal(starter.quality.answered,0,"missing evidence must not turn into an answer");
assert.equal(L.qualifyQuiz(noAnswers).eligible,false);
assert.equal(L.qualifyQuiz(Array(20).fill(0)).answered,0,"neutral is not directional");
const sparse=Array(20).fill(null);sparse[0]=1;
const first=L.pickArchetype(sparse);
assert.equal(first.profile.name,"The Tech Reformist","one explicit tech answer maps only to its theme");
assert.equal(first.starter,false);
assert.equal(first.quality.eligible,false,"one answer is not a validated profile");
for(let i=0;i<12;i++){
 const sample=Array(20).fill(null);sample[i]=1;
 assert.equal(L.pickArchetype(sample).profile.key,profiles[i].key,
   "each archetype must be reachable from its explicit anchor question: "+profiles[i].name);
}
const complete=L.pickArchetype(Array(20).fill(1));
assert.equal(complete.quality.answered,20);
assert.equal(complete.quality.eligible,true);
assert.ok(expected.includes(complete.profile.name));
assert.ok(!read("docs/commonwealth-intelligence.js").includes("Insufficient information"),
  "no blank inconclusive result UI");
assert.equal(L.tenureAt(F.house,"2025-01-02","07")[0].person_id,"fx-house-morgan");
assert.equal(L.tenureAt(F.house,"2025-01-03","07")[0].person_id,"fx-house-sam");
assert.equal(L.tenureAt(F.house,"2027-01-03","07").length,0);
assert.equal(L.tenureAt(F.municipal,"2024-12-31","02")[0].person_id,"fx-city-avery");
assert.equal(L.tenureAt(F.municipal,"2025-01-01","02")[0].person_id,"fx-city-casey");
const houseOld = find(F.house,"fx-house-roll-001");
const houseNew = find(F.house,"fx-house-roll-002");
assert.equal(L.resolveMembers(houseOld,"HOUSE:07")[0].name,"Morgan Alder (fictional)");
assert.equal(L.resolveMembers(houseNew,"HOUSE:07")[0].name,"Sam Briar (fictional)");
const senate = find(F.senate,"fx-senate-roll-002");
assert.equal(L.resolveMembers(senate,"SENATE:ALL").find(x => x.seat === "S-2").status,"NO_RECORDED_POSITION");
const voice = find(F.municipal,"fx-city-voice-002");
assert.equal(L.resolveMembers(voice,"MUNICIPAL:02")[0].status,"NO NAMED VOTE (VOICE)");
const cloture = find(F.senate,"fx-senate-roll-001");
assert.equal(cloture.kind,"CLOTURE");
assert.equal(L.questionLinks("fx-issue-riverfront",true).length,4);
assert.equal(L.questionLinks("fx-issue-riverfront",false).length,5);
assert.equal(L.questionLinks("fx-issue-stormwater",true).length,1);
assert.equal(L.questionLinks("fx-issue-transit",false).length,0);
const app = read("docs/commonwealth-intelligence.js");
for(const prohibited of [/\bfetch\s*\(/,/\bXMLHttpRequest\b/,/\blocalStorage\b/,/\bsessionStorage\b/,/\bsendBeacon\b/])
  assert(!prohibited.test(app),"Public demo must not retrieve or persist private data: "+prohibited);
const html=read("docs/commonwealth-intelligence.html");
for(const label of ["SYNTHETIC ONLY","NOT SAVED","NOT LEGAL CERTIFICATION","NOT AUTHORIZED","commonwealth-archetypes.js","commonwealth-intelligence-fixtures.js","commonwealth-intelligence.js","cw-archetype-gallery","cw-quiz-result-card"])
  assert(html.includes(label),"Missing explicit boundary: "+label);
assert(read("docs/commonwealth.html").includes('href="commonwealth-intelligence.html"'),"Canonical Commonwealth product page must link to the intelligence lab");
console.log("PASS: Commonwealth public demo fixture parity, tenure boundaries, procedure separation, 12 archetypes, and site links");
