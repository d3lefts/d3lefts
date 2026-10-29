"use strict";
const assert=require("node:assert/strict");
const H=require("../docs/companion-handoff-core.js");
const e={denominator:"4",heights:["1","2","2","3"],claimedUpper:"3/4"};
const a=H.build("referee","adversary","overlap",e);
assert.equal(a.reviewStatus,"unreviewed");
assert.equal(a.input.heights.join(","),"1,2,2,3");
assert.deepEqual(H.parse(JSON.stringify(a),"adversary"),a);
const fromBack=H.build("adversary","referee","overlap",a.input);
assert.deepEqual(H.parse(JSON.stringify(fromBack),"referee"),fromBack);
const sidon=H.build("referee","adversary","sidon",{points:"5 1 3 2"});
assert.deepEqual(sidon.input.points,["1","2","3","5"]);
const back=H.build("adversary","referee","sidon",sidon.input);
assert.equal(back.reviewStatus,"unreviewed");
assert.deepEqual(back.input.points,["1","2","3","5"]);
assert.throws(()=>H.build("adversary","referee","sidon",{points:Array.from({length:31},(_,i)=>i)}),/4–30/);
assert.throws(()=>H.build("referee","adversary","overlap",{denominator:2,heights:Array(66).fill(1)}),/2–64/);
assert.throws(()=>H.build("referee","adversary","sidon",{points:"1 1 2 3"}),/Repeated/);
assert.throws(()=>H.build("referee","adversary","overlap",{denominator:4,heights:"1 2 1 2"}),/unit-mass/);
assert.throws(()=>H.build("referee","adversary","overlap",{denominator:4,heights:"0 4",claimedUpper:"3/0"}),/rational/);
for(const bad of [{...a,reviewStatus:"verified"},{...a,scientificStatus:"THEOREM"},{...a,format:"fake"},{...a,to:"referee"}]){
 assert.throws(()=>H.parse(JSON.stringify(bad),"adversary"),/Unsupported/);
}
assert.throws(()=>H.parse(JSON.stringify({...a,input:{...a.input,heights:["1","2","2","3"],claimedUpper:"0/1",verdict:"PROVED"}}),"adversary"),/canonical/);
assert.throws(()=>H.build("adversary","referee","general",{}),/General theory/);
console.log("Companion handoff input-only contract and 15 negative controls PASS");
