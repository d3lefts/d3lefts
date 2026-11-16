"use strict";
/* Synthetic Commonwealth website contract: source parity and independent fixture-model tests. */
const assert = require("node:assert/strict");
const fs = require("node:fs");
const vm = require("node:vm");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const read = file => fs.readFileSync(path.join(root,file),"utf8");
const sandbox = {window:{},document:{querySelector:() => null}};
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
assert.equal(L.classify({gov:null,level:1,change:1}),null,"Missing evidence cannot produce an archetype");
const labels = new Set();
for (const gov of [-1,0,1]) for (const level of [-1,1]) for (const change of [-1,1])
  labels.add(L.classify({gov,level,change}).key);
assert.equal(labels.size,12);
const app = read("docs/commonwealth-intelligence.js");
for(const prohibited of [/\bfetch\s*\(/,/\bXMLHttpRequest\b/,/\blocalStorage\b/,/\bsessionStorage\b/,/\bsendBeacon\b/])
  assert(!prohibited.test(app),"Public demo must not retrieve or persist private data: "+prohibited);
const html=read("docs/commonwealth-intelligence.html");
for(const label of ["SYNTHETIC ONLY","NOT SAVED","NOT LEGAL CERTIFICATION","NOT AUTHORIZED","commonwealth-intelligence-fixtures.js","commonwealth-intelligence.js"])
  assert(html.includes(label),"Missing explicit boundary: "+label);
assert(read("docs/commonwealth.html").includes('href="commonwealth-intelligence.html"'),"Canonical Commonwealth product page must link to the intelligence lab");
console.log("PASS: Commonwealth public demo fixture parity, tenure boundaries, procedure separation, 12 archetypes, and site links");
