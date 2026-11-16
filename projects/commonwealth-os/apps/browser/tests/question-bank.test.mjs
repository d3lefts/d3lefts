import test from 'node:test';
import assert from 'node:assert/strict';
import {QUESTION_BANK} from '../question-data.mjs';
test('three pilot banks have 24 distinct research draft items',()=>{
 assert.deepEqual(Object.keys(QUESTION_BANK).sort(),['HOA','HSV','UAH']);
 const all=Object.values(QUESTION_BANK).flatMap(x=>x.questions);
 assert.equal(all.length,72);assert.equal(new Set(all.map(x=>x.id)).size,72);
 for(const bank of Object.values(QUESTION_BANK))assert.equal(bank.questions.length,24);
 for(const row of all){assert.equal(row.source,'UNVERIFIED_RESEARCH_DRAFT');assert.equal(row.certification,'unvalidated');assert.ok(row.question.endsWith('?'));}
});