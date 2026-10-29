"use strict";
const assert=require("node:assert/strict");
const fs=require("node:fs");
const vm=require("node:vm");
const path=require("node:path");
const root=path.resolve(__dirname,"..");
const core=require(path.join(root,"docs/referee-core.js"));
class Element{
 constructor(tag="div"){this.tagName=tag;this.children=[];this.callbacks={};this.attrs={};this.textContent="";this.value="";this.disabled=false;this.className="";}
 append(...nodes){this.children.push(...nodes)}
 appendChild(node){this.children.push(node);return node}
 replaceChildren(...nodes){this.children=nodes}
 setAttribute(key,value){this.attrs[key]=value}
 addEventListener(name,fn){this.callbacks[name]=fn}
 emit(name){assert.ok(this.callbacks[name],"missing "+name+" handler");return this.callbacks[name]()}
 click(){this.clicked=true}
 remove(){this.removed=true}
}
function runFixture(source=core){
 const elements=new Map();
 const document={
  getElementById(id){if(!elements.has(id))elements.set(id,new Element());return elements.get(id)},
  createElement(tag){return new Element(tag)},
  createDocumentFragment(){return new Element("fragment")},
  body:new Element("body")
 };
 const ctx=vm.createContext({window:{RefereeCore:source},document,console,
  Blob,URL:{createObjectURL:()=> "blob:local-test",revokeObjectURL:()=>{}},
  setTimeout:()=>0,Date,Number,Set,Map,Array,String,Boolean});
 for(const file of ["docs/research-registry.js","docs/living-paper.js"])
   vm.runInContext(fs.readFileSync(path.join(root,file),"utf8"),ctx,{filename:file,timeout:15000});
 return {get:id=>document.getElementById(id),ctx};
}
const q=runFixture();
assert.equal(q.get("lp-edge-select").children.length,28);
assert.equal(q.get("lp-points").children[0].children.length,30);
assert.equal(q.get("lp-points").children[0].children.filter(n=>n.className.includes("is-on")).length,17);
const select=q.get("lp-edge-select");
for(let i=0;i<28;i++){
 select.value=String(i);select.emit("change");q.get("lp-delete").emit("click");
 assert.equal(q.get("lp-points").children[0].children.filter(n=>n.className.includes("is-on")).length,18);
 assert.equal(q.get("lp-points").children[0].children.filter(n=>n.className.includes("is-edge")).length,3);
 assert.match(q.get("lp-output").textContent,/Uncovered progression constraints: 1 of 28/);
}
q.get("lp-reset").emit("click");
assert.equal(q.get("lp-points").children[0].children.filter(n=>n.className.includes("is-on")).length,17);
q.get("lp-run").emit("click");
assert.match(q.get("lp-output").textContent,/LOCAL FINITE CHECK PASSED/);
assert.match(q.get("lp-output").textContent,/Edge-deletion witnesses checked: 28\/28/);
assert.match(q.get("lp-output").textContent,/Negative controls: passed/);
assert.equal(q.get("lp-export").disabled,false);
assert.equal(q.get("lp-history-items").children[0].children.length,3);
const broken={...core,SIDON_WITNESS:core.SIDON_WITNESS.slice(1)};
const damaged=runFixture(broken);
assert.equal(damaged.get("lp-run").disabled,true);
assert.equal(damaged.get("lp-delete").disabled,true);
assert.match(damaged.get("lp-output").textContent,/SOURCE INVARIANT MISMATCH/);
console.log("Living Paper exact finite replay: 28/28 edge witnesses; full finite certificate, mutation controls and tamper fail-close PASS");
