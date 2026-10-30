"use strict";
/* Shared ownership and navigation behavior, independent of full-browser visual
 * checks. The source registry remains authoritative for claim identities. */
const assert=require("node:assert/strict");
const fs=require("node:fs");
const vm=require("node:vm");
const read=p=>fs.readFileSync(p,"utf8");
const js=read("docs/site.js");
const researchJS=read("docs/research.js");
const library=read("docs/research.html");
const siteCSS=read("docs/site.css");
const agendaCSS=read("docs/agenda-catalog.css");
const agenda=read("docs/agenda.html");

for(const retired of ["project-list","project-search","research-row","index-subhead","entries=["]){
 assert.ok(!js.includes(retired),"Global navigation reintroduced a shadow research catalogue: "+retired);
}
assert.ok(!siteCSS.includes(".research-row{")&&!siteCSS.includes(".index-subhead{")&&!siteCSS.includes(".agenda-teaser{"),
 "Proposal catalogue styles should not load on every page");
for(const rule of [".research-row{",".index-subhead{",".agenda-teaser{",".agenda-page .research-proposal","@media(max-width:760px)"]){
 assert.ok(agendaCSS.includes(rule),"Agenda-owned style missing "+rule);
}
assert.ok(agenda.includes('href="agenda-catalog.css"'),"Agenda missing its dedicated stylesheet");
assert.equal([...read("docs/index.html").matchAll(/href="agenda-catalog.css"/g)].length,0,"Homepage should not load agenda stylesheet");

const claimMatches=[...library.matchAll(/<article class="atlas-card" data-claim-id="([^"]+)"[^>]*>/g)].map(x=>x[1]);
assert.deepEqual([...claimMatches].sort(),["adaptive","erdos36","pas","phase","sidon30","werner"].sort(),
 "Exactly six library dossiers must have explicit, unique Proof Passport claim IDs");
assert.ok(researchJS.includes('card.dataset.claimId')&&researchJS.includes('registry.claimById(id)'));
assert.ok(!researchJS.includes('cards.find(')&&!researchJS.includes('const match=['),
 "Passport references must be identity-based, not matched against editorial titles");
const context={};vm.runInNewContext(read("docs/research-registry.js"),context);
for(const id of claimMatches){
 const record=context.NightfallRegistry.claimById(id);
 assert.ok(record&&record.validity?.detail&&record.conditions,
  "Missing canonical evidence-scoped record: "+id);
}
assert.equal([...library.matchAll(/<article class="atlas-card"/g)].length,33,"33 selected dossiers remain published");

// Lightweight DOM simulation: test navigation without an additional runtime,
// network fetch, or coupling to implementation-specific CSS class ordering.
class Element{
 constructor(tag){this.tagName=tag;this.children=[];this.attributes={};this.listeners={};this.dataset={};this.className="";this.classList={
   classes:new Set(),toggle:n=>{if(this.classList.classes.has(n)){this.classList.classes.delete(n);return false}this.classList.classes.add(n);return true},
   remove:n=>this.classList.classes.delete(n),contains:n=>this.classList.classes.has(n)
  };}
 setAttribute(k,v){this.attributes[k]=String(v)}
 getAttribute(k){return this.attributes[k]??null}
 addEventListener(name,fn){this.listeners[name]=fn}
 append(...items){items.forEach(x=>this.children.push(x))}
 before(x){this.beforeItems??=[];this.beforeItems.push(x)}
 insertAdjacentElement(pos,x){this.insertions??=[];this.insertions.push({pos,x})}
 prepend(x){this.children.unshift(x)}
 querySelectorAll(selector){return selector==="a"?this.children.filter(c=>c.tagName==="a"):[]}
 querySelector(selector){return selector===".join-hero"?this.hero:null}
 closest(){return null}
 contains(other){return this===other}
 focus(){this.focused=true}
 }
function simulate(page,{saved={},app=false,joinHero=false,twice=false}={}){
 const main=new Element("main"),menu=new Element("button"),nav=new Element("nav"),docListeners={},assets=[];
 const headerLinks=[new Element("a"),new Element("a"),new Element("a")];nav.append(...headerLinks);
 if(joinHero)main.hero=new Element("section");
 let rail=null,thread=null;
 const document={
  head:{append:x=>assets.push(x)},
  getElementById:id=>id==="menu-button"?menu:id==="site-nav"?nav:null,
  querySelector:sel=>sel==="main"?main:sel==="#app"&&app?new Element("div"):sel===".app"&&app?new Element("div"):sel===".nf-journey-rail"?rail:sel===".nf-process-thread"?thread:sel==='link[data-nf-rail-style]'?assets.find(x=>x.dataset?.nfRailStyle!==undefined)||null:null,
  createElement:tag=>new Element(tag),
  addEventListener:(name,fn)=>{docListeners[name]=fn}
 };
 const originalBefore=main.before.bind(main);
 main.before=x=>{if(x.className==="nf-journey-rail")rail=x;if(x.className==="nf-process-thread")thread=x;originalBefore(x)};
 const oldInsert=main.hero?.insertAdjacentElement?.bind(main.hero);
 if(oldInsert)main.hero.insertAdjacentElement=(pos,x)=>{if(x.className==="nf-process-thread")thread=x;oldInsert(pos,x)};
 const localStorage={getItem:k=>saved[k]??null};
 const global={document,location:{pathname:"/d3lefts/"+page},localStorage};
 function run(){vm.runInNewContext(js,global,{timeout:1000});if(rail){const orig=rail.insertAdjacentElement.bind(rail);rail.insertAdjacentElement=(pos,x)=>{if(x.className==="nf-process-thread")thread=x;orig(pos,x)}}}
 run();if(twice)run();
 return {main,menu,nav,rail,thread,assets,docListeners,headerLinks};
}
let p=simulate("index.html");
assert.equal(p.rail,null);assert.equal(p.thread,null);
p.menu.listeners.click();assert.equal(p.menu.attributes["aria-expanded"],"true");
p.docListeners.keydown({key:"Escape"});assert.equal(p.menu.attributes["aria-expanded"],"false");
assert.equal(p.menu.focused,true);
p=simulate("join.html",{joinHero:true});
assert.equal(p.rail,null,"Join has no duplicate return rail");
assert.ok(p.main.hero.insertions.some(x=>x.x.className==="nf-process-thread"),"Join trail follows its hero");
assert.equal(p.thread.children.filter(x=>x.attributes["aria-current"]==="page").length,1);
p=simulate("passport.html",{saved:{"nightfall.claim.journey.v1":JSON.stringify({
 version:1,selected:{claimId:"erdos36",index:0}
})}});
assert.ok(p.rail&&p.thread,"Specialist needs return and destination path");
assert.match(p.rail.children.find(x=>x.tagName==="a").href,/claim=erdos36&obligation=0#claim-investigation/);
assert.equal(p.thread.children.find(x=>x.attributes["aria-current"]==="page").href,"review.html#priority");
assert.ok(p.assets.some(x=>x.href==="journey-rail.css"));
p=simulate("passport.html",{saved:{"nightfall.claim.journey.v1":JSON.stringify({
 version:1,selected:{claimId:"javascript:attack",index:2}
})}});
assert.equal(p.rail.children.find(x=>x.tagName==="a").href,"join.html#results","Reject unrecognized saved claim IDs");
p=simulate("frontier.html",{saved:{"nightfall.journey.v1":"{invalid JSON"}});
assert.equal(p.rail.children.find(x=>x.tagName==="a").href,"join.html#results","Malformed saved state falls back safely");
assert.equal(p.thread.children.find(x=>x.attributes["aria-current"]==="page").href,"constellation.html#map");
p=simulate("exact-research.html",{app:true});
assert.equal(p.rail,null);assert.equal(p.thread,null);
console.log("PASS shared architecture: agenda owns proposal styles, six explicit claim links; homepage/static menu, join, review, saved claim, malformed state, and app chrome isolated");
