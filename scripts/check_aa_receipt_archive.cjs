"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const crypto=require("node:crypto");
const root=path.resolve(__dirname,".."),dir=path.join(root,"docs/nightfall-aa-receipts-20261118");
const sha=p=>crypto.createHash("sha256").update(fs.readFileSync(p)).digest("hex");
const r=JSON.parse(fs.readFileSync(path.join(dir,"register.json"),"utf8"));
assert.equal(r.schema,"nightfall-aa-lean-receipt-register-v1");
assert.equal(r.source_workflow_run,44433153026);
assert.equal(r.source_workflow_head,"771d11af21896aa83f481b332d21d7d706b56927");
assert.equal(r.toolchain,"leanprover/lean4:v4.36.0-rc2");
const allowed=new Set(["propext","Classical.choice","Quot.sound"]);
const expected={"receipt.json":"Nightfall.InfinitePiAAProductTerminal.infinitePi_aa_product","printed-receipt.json":"Nightfall.ProductSpace.CubeAA.printedConjecture","simulation-receipt.json":"Nightfall.ProductSpace.Simulation.simulation_degree"};
for(const [name,target] of Object.entries(expected)){
  const file=path.join(dir,name),v=JSON.parse(fs.readFileSync(file,"utf8"));
  assert.equal(sha(file),r.raw_sha256[name],name+" original receipt drift");
  assert.equal(r.certifies[name],target,name+" named source changed");
  assert.equal(v.status,"COMPILED",name+" uncompiled");
  assert.equal(v.compiler_exit_code,0,name+" compiler failure");
  assert.equal(v.version_matches_pin,true,name+" toolchain mismatch");
  assert.ok(v.declarations_requested.includes(target),name+" terminal declaration missing");
  assert.equal(v.axiom_audit[target],"allowlisted_dependencies",name+" axiom audit");
  assert.ok((v.axiom_dependencies[target]||[]).every(x=>allowed.has(x)),name+" unexpected axiom");
  assert.ok(v.source_relpath.startsWith("research/nightfall/formalization/"),name+" unexpected source location");
  const source=path.join(root,v.source_relpath);
  assert.equal(sha(source),v.source_sha256,name+" declared source hash disagrees with main");
}
console.log("PASS: 3 historical named source receipts, byte-exact hashes and current source identity; NOT new Lean compilation");
