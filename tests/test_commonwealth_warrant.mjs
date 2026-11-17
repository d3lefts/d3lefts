import test from "node:test";
import assert from "node:assert/strict";
import {WARRANT_LAYERS,EVIDENCE_VOCABULARY,EXAMPLE_WARRANT,inspectExample,sourceTransition} from "../docs/commonwealth-warrant.mjs";
test("Public Warrant cannot promote a fictional example into a legal instrument",()=>{
 assert.deepEqual(WARRANT_LAYERS,["authority","evidence","assurance"]);
 assert.deepEqual(EVIDENCE_VOCABULARY,["VERIFIED_EVIDENCE","UNVERIFIED","CONTESTED","ILLUSTRATIVE"]);
 assert.equal(EXAMPLE_WARRANT.synthetic,true);
 assert.equal(EXAMPLE_WARRANT.legalEffect,false);
 assert.equal(inspectExample().evidenceClass,"ILLUSTRATIVE");
 assert.equal(inspectExample().legalEffect,false);
 assert.equal(inspectExample().sourceAuthenticated,false);
 assert.throws(()=>inspectExample({...EXAMPLE_WARRANT,synthetic:false}),TypeError);
 assert.throws(()=>inspectExample({...EXAMPLE_WARRANT,evidenceClass:"VERIFIED_EVIDENCE"}),TypeError);
});
test("Source version changes require recheck without legal authorization",()=>{
 assert.equal(sourceTransition(false).source,"v1 / fictional baseline");
 assert.equal(sourceTransition(true).review,"RECHECK_REQUIRED");
 assert.match(sourceTransition(true).explanation,/no actual source/i);
 assert.throws(()=>sourceTransition("true"),TypeError);
});
