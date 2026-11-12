"use strict";
// Independent integer arithmetic replay of the n=2 addressed-family tester.
// Explicitly enumerates oracle values and BOTH random Z draws; no use of m_k.
const assert = require("node:assert/strict");
const inputs = [];
for (let k = 0; k < 2; k++)
 for (let z0 of [-1, 1]) for (let z1 of [-1, 1])
  inputs.push({k, z: [z0, z1]});
const good = [];
for (let t0 of [-1, 1]) for (let t1 of [-1, 1])
 good.push(inputs.map(x => [t0, t1][x.k] * x.z[x.k]));

let failures = 0, ties = 0, minSlack = Infinity, count = 0;
for (let number = 0; number < 3 ** inputs.length; number++) {
 let code = number, f = [];
 for (let j = 0; j < inputs.length; j++) {
  f.push([-1, 0, 1][code % 3]); code = Math.floor(code / 3);
 }
 // Squared L2 distance is 'distanceNumerator / 8'.
 let distanceNumerator = Infinity;
 for (const g of good) {
  let squaredSum = 0;
  for (let j = 0; j < 8; j++) squaredSum += (f[j] - g[j]) ** 2;
  distanceNumerator = Math.min(distanceNumerator, squaredSum);
 }
 // P(reject) is 'rejectCount / 32'. Hence
 // 4P(reject) - distance^2 = (rejectCount - distanceNumerator) / 8.
 let rejectCount = 0;
 for (let k = 0; k < 2; k++) {
  const ids = inputs.map((x, i) => x.k === k ? i : -1).filter(i => i >= 0);
  for (const i of ids) for (const j of ids)
   if (inputs[i].z[k] * f[i] * inputs[j].z[k] * f[j] < 1) rejectCount++;
 }
 const slackNumerator = rejectCount - distanceNumerator;
 if (slackNumerator < 0) failures++;
 if (slackNumerator === 0) ties++;
 minSlack = Math.min(slackNumerator, minSlack);
 count++;
}
assert.equal(count, 6561);
assert.equal(failures, 0);
assert.equal(minSlack, 0);
assert.equal(ties, 64);
console.log("PASS: independent addressed test n=2, 6561 trivalent oracles, 0 violations, 64 equalities, exact integer arithmetic");
