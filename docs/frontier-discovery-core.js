/* Canonical Frontier → Discovery adapter. Research planning only; no evidence promotion. */
"use strict";
(function(root,factory){
  const api=factory();
  if(typeof module==="object"&&module.exports)module.exports=api;
  else root.NightfallFrontierDiscovery=api;
})(typeof globalThis==="object"?globalThis:this,function(){
  const VERSION="nightfall-frontier-discovery-handoff-v1";
  function build(packet,frontier){
    if(!frontier||typeof frontier.validatePacket!=="function")
      throw Error("Frozen Frontier verifier unavailable.");
    const checked=frontier.validatePacket(packet);
    const root=checked.root,assignment=checked.assignment;
    const scope=frontier.predicate(assignment);
    const branchId=assignment.id;
    const checker=root.id==="NF-156-184-9"
      ?"Independently check 45 distinct unordered pair sums, all omitted insertions, and any complete branch exclusion. The 30-point finite Sidon Referee checker is a different problem."
      :"Rebuild all 128 vertices, 448 cube edges, 672 coordinate squares and the exact six-deletion/seven-insertion lineage. No Q7 browser oracle is provided.";
    const cheap=root.id==="NF-156-184-9"
      ?"Recheck the published nine-mark near-candidate at N=184 and its two addable marks before a new exact SAT attempt."
      :"Independently reproduce one published 304-edge representative and its known five-deletion exclusion before extending to six deletions.";
    return {
      id:"custom-frontier-"+encodeURIComponent(branchId),
      title:"Frontier / "+root.parent+" / "+scope,
      area:root.parent,
      status:"Unreviewed scoped research assignment; no scientific result",
      source:packet.source,
      repo:packet.source,
      task:branchId,
      goal:root.question+" Restricted to "+scope+".",
      representation:"Exact bounded branch: "+scope,
      mode:"external",
      contract:{
        objective:root.question+" Restricted to "+scope+".",
        assumptions:"Frozen Frontier snapshot "+packet.snapshot+". Preserve branch predicate "+scope+". No inherited numerical finding.",
        prior:"Read "+root.source+" and "+root.data+"; compare "+root.evidence+" against the dated external baseline. Source URLs are references, not immutable source-blob hashes.",
        gap:"Neither a verified YES witness nor an independently checked exhaustive NO proof for this exact branch has been imported.",
        threshold:"YES requires "+root.closureYes+" NO requires "+root.closureNo,
        audit:"Independent reproduction, both closure directions, exact quantifier and interval checks, source priority, and adversarial tests. Never infer the unrestricted parent result from one negative branch.",
        checker,
        budget:"Bound the first experiment; freeze input and operator cost. "+root.stop,
        stop:root.stop,
        cheap
      },
      representations:[{id:"r0",parent:null,name:"Frozen Frontier branch",mechanism:"Define exact feasible set before choosing a solver or representation.",assumptions:scope,created:packet.snapshot,bits:null}],
      selectedRep:"r0",
      runs:[],
      frontier:{
        schema:packet.schema,snapshot:packet.snapshot,assignmentId:branchId,
        rootId:packet.rootId,parentId:packet.parentId,lo:packet.lo,hi:packet.hi,
        depth:packet.depth,scope,source:packet.source,sourceProblem:packet.sourceProblem,
        positive:packet.positive,negative:packet.negative,
        reviewStatus:"unreviewed"
      }
    };
  }
  function checkUnique(projects,project){
    if(!Array.isArray(projects)||!project||!project.frontier)
      throw Error("Invalid Discovery portfolio.");
    if(projects.some(p=>p.id===project.id||p.frontier?.assignmentId===project.frontier.assignmentId))
      throw Error("This exact Frontier assignment is already in Discovery.");
    return true;
  }
  return Object.freeze({VERSION,build,checkUnique});
});
