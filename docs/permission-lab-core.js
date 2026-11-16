"use strict";
/* Finite educational model — NOT a production authorization engine. */
(function(root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  if (root) root.NFPermissionCore = api;
})(typeof globalThis !== "undefined" ? globalThis : this, function() {
  function nat(v, name) {
    const n = Number(v);
    if (!Number.isSafeInteger(n) || n < 0) throw new RangeError(name + " must be a nonnegative safe integer");
    return n;
  }
  function price(input) {
    const p = {};
    for (const name of ["N", "initialCache", "invalidated", "workers", "slotsPerWorker", "spentSlots",
      "guards", "rawBaseCost", "rawDisclosure", "directBaseCost", "directDisclosure",
      "verifierFee", "guardFee", "effectFee", "sunkCost"]) p[name] = nat(input[name], name);
    if (p.initialCache > p.N || p.invalidated > p.initialCache)
      throw new RangeError("Cache/invalidation counts exceed their scope");
    const capacity = p.workers * p.slotsPerWorker;
    if (!Number.isSafeInteger(capacity) || p.spentSlots > capacity)
      throw new RangeError("Checkpoint slots cannot exceed installed capacity");
    const K = capacity - p.spentSlots;
    const R = p.N - p.initialCache + p.invalidated;
    const pairedPrice = 2 * (p.rawBaseCost + p.rawDisclosure);
    const directPrice = p.directBaseCost + p.directDisclosure;
    if (![K,R,pairedPrice,directPrice].every(Number.isSafeInteger))
      throw new RangeError("Model values exceed exact integer precision");
    const feasible = K >= R && p.guards >= p.N;
    if (!feasible) return {feasible:false, R, K, requiredGuards:p.N,
      reason:K < R ? "Insufficient remaining verification slots" : "Insufficient final-effect guards"};
    const minimumDirect = Math.max(0,2*R-K);
    const direct = directPrice < pairedPrice ? R : minimumDirect;
    const paired = R-direct;
    const evidence = paired*pairedPrice+direct*directPrice;
    const installation = p.verifierFee*p.workers + p.guardFee*p.guards + p.effectFee*p.N;
    const total = p.sunkCost+installation+evidence;
    const allDirectEvidence = R*directPrice;
    if (![evidence,installation,total,allDirectEvidence].every(Number.isSafeInteger))
      throw new RangeError("Cost exceeds exact integer precision");
    return {feasible:true,R,K,pairedPrice,directPrice,minimumDirect,paired,direct,
      evidence,installation,sunkCost:p.sunkCost,total,allDirectEvidence,
      savingsAgainstAllDirect:allDirectEvidence-evidence};
  }
  const allWorlds = Object.freeze([
    Object.freeze({id:"00",left:0,right:0,safe:true}),
    Object.freeze({id:"01",left:0,right:1,safe:false}),
    Object.freeze({id:"10",left:1,right:0,safe:false}),
    Object.freeze({id:"11",left:1,right:1,safe:true})
  ]);
  function worlds(changed) {
    const ids = changed ? ["00","01","10"] : ["00","01"];
    return ids.map(id=>allWorlds.find(w=>w.id===id));
  }
  function observation(name, world) {
    if (name==="left") return world.left;
    if (name==="right") return world.right;
    if (name==="direct") return world.safe ? 1 : 0;
    throw new RangeError("Unknown evidence channel");
  }
  function checkCertificate(candidate, currentWorlds, selected) {
    if (!candidate || !candidate.safe || !currentWorlds.some(w=>w.id===candidate.id))
      throw new RangeError("Candidate must be a safe current possible world");
    const bad = currentWorlds.filter(w=>!w.safe && selected.every(name=>observation(name,w)===observation(name,candidate)));
    return {valid:bad.length===0, indistinguishable:bad.map(w=>w.id)};
  }
  function leastDisclosure(changed, enabled, costs) {
    const possible = worlds(changed);
    const nominal = possible[0];
    const options=["left","right","direct"].filter(name=>Boolean(enabled[name]));
    let best=null;
    for(let mask=0;mask<(1<<options.length);mask++){
      const chosen=options.filter((_,i)=>Boolean(mask & (1<<i)));
      const check=checkCertificate(nominal, possible, chosen);
      if (!check.valid) continue;
      let cost=0;
      for(const name of chosen) cost+=nat(costs[name], name+" cost");
      if (!Number.isSafeInteger(cost)) throw new RangeError("Cost exceeds integer precision");
      const candidate={channels:chosen,cost,check};
      if(!best || candidate.cost<best.cost ||
        (candidate.cost===best.cost && candidate.channels.length<best.channels.length)) best=candidate;
    }
    const rightOnly=checkCertificate(nominal,possible,["right"]);
    return {worlds:possible.map(w=>w.id),validRightOnly:rightOnly.valid,
      rightOnlyIndistinguishable:rightOnly.indistinguishable,best,
      status:best?"CERTIFIED IN FINITE MODEL":"NO AVAILABLE SUFFICIENT EVIDENCE"};
  }
  return Object.freeze({price,worlds,observation,checkCertificate,leastDisclosure});
});
