"use strict";
const assert = require("node:assert/strict");
const test = require("node:test");
const fs = require("node:fs");
const vm = require("node:vm");
const crypto = require("node:crypto");
const path = require("node:path");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p), "utf8");
const json = p => JSON.parse(read(p));
const API = require(path.join(root, "docs/theory-evidence-core.js"));
const map = require(path.join(root, "docs/theory-map-data.js"));
const crosswalk = json("docs/theory-evidence-links.json");
const active = json("docs/active-proof-passport.json");
const overlay = json("docs/lean-proof-passport-overlay.json");
const provenance = json("docs/lean-certificate-provenance.json");
const ctx = {};
vm.runInNewContext(read("docs/research-registry.js"),ctx,{filename:"research-registry.js"});
const historical = ctx.NightfallRegistry;
const docs = {links:crosswalk,active,overlay,provenance,historical};
const gitBlobHash = content => crypto.createHash("sha1").update(
  "blob " + Buffer.byteLength(content, "utf8") + "\0" + content, "utf8").digest("hex");

test("validate the exact 4 canonical registries and frozen historical passport data", () => {
  for(const kind of ["links","active","overlay","provenance","historical"]) {
    assert.equal(API.checkShape(kind,docs[kind]),true,kind+" schema");
  }
  assert.equal(active.claims.length,15);
  assert.equal(overlay.records.length,4);
  assert.equal(provenance.modules.length,67);
  assert.equal(historical.claims.length,11);
  assert.deepEqual(API.validateLinks(map,crosswalk,docs),[]);
});

test("all explicit links resolve without name-based theorem substitution", () => {
  for(const id of Object.keys(crosswalk.bindings)) {
    const x = API.collect(id,docs);
    assert.deepEqual(x.errors,[],id);
    assert.equal(x.nodeId,id);
    assert.ok(x.hasLinks || x.binding.note);
  }
  const finite = API.collect("q2-finite",docs);
  assert.equal(finite.active[0].id,"q2-influence");
  assert.equal(finite.overlay.length,0);
  assert.deepEqual(finite.certificates.map(c=>c.id),
    ["finite-heterogeneous-c105","finite-supported-c105"]);
  assert.ok(!JSON.stringify(finite).includes("q2-finite-current"));
  const infinite = API.collect("q2-infinite",docs);
  assert.equal(infinite.overlay[0].id,"q2-infinite-integration");
  assert.equal(infinite.certificates[0].conditional,true);
  assert.equal(infinite.certificates[0].declaration,
    "Nightfall.InfinitePiQ2Limit.source_q2_quadratic_limit");
  assert.match(infinite.certificates[0].scope,/does not|conditional|assuming/i);
  const l2 = API.collect("q2-l2",docs);
  assert.equal(l2.certificates.length,2);
  assert.notEqual(finite.certificates[0].declaration,l2.certificates[0].declaration);
});

test("each curated Lean source object exactly matches checked-in Git blob bytes and named declaration", () => {
  const expected = [
    "finite-heterogeneous-c105","finite-supported-c105","source-all-l2-intertwining",
    "source-residual-transfer","conditional-infinite-limit"
  ];
  assert.deepEqual(crosswalk.certificates.map(c=>c.id),expected);
  for(const c of crosswalk.certificates) {
    const source = read(c.path);
    assert.equal(gitBlobHash(source),c.sha,c.id+" Git source changed: source receipt needs revalidation");
    const name = c.declaration.split(".").at(-1);
    assert.ok(new RegExp("\\b(theorem|lemma)\\s+"+name+"\\b").test(source),
      c.id+" declared theorem absent");
    assert.match(c.scope,/(finite|conditional|all-L²|source|assuming)/i);
    assert.ok(Number.isSafeInteger(c.run)&&c.run>0);
    assert.ok(Number.isSafeInteger(c.pr)&&c.pr>0);
  }
  assert.ok(crosswalk.toolchain.axioms.includes("Classical.choice"));
});

test("the claimed end-to-end Q2 theorem remains OPEN despite all scoped receipt links", () => {
  assert.equal(map.nodes.find(n=>n.id==="q2-infinite").status,"open");
  assert.equal(overlay.records.find(r=>r.id==="q2-infinite-integration").complete_certification,false);
  const q2 = API.collect("q2-infinite",docs);
  assert.equal(q2.overlay[0].complete_certification,false);
  assert.equal(q2.certificates.every(c=>c.conditional),true);
  assert.ok(map.edges.some(e=>e.kind==="open"&&
    (e.from==="q2-infinite"||e.to==="q2-infinite")));
  assert.ok(!crosswalk.bindings["q2-finite"].overlay?.includes("q2-finite-current"));
});

test("fail-closed on bad source schema, disappearing passport and shadowed certificate", () => {
  const deleted = {...docs,active:{...active,claims:active.claims.filter(x=>x.id!=="q2-influence")}};
  const missed = API.collect("q2-finite",deleted);
  assert.ok(missed.errors.some(x=>x.includes("record not found")));
  assert.equal(missed.active.length,0);
  const bad = {...docs,overlay:{schema:"bad-schema",records:overlay.records}};
  const r = API.collect("q2-infinite",bad);
  assert.equal(r.overlay.length,0);
  assert.ok(r.errors.some(x=>x.includes("incompatible")));
  const conflicting = structuredClone(crosswalk);
  conflicting.bindings["q2-finite"].overlay=["q2-finite-current"];
  assert.ok(API.validateLinks(map,conflicting,docs).some(x=>x.includes("C23802")));
  const stale = structuredClone(crosswalk);
  stale.certificates[0].sha = "0".repeat(40);
  assert.notEqual(gitBlobHash(read(stale.certificates[0].path)),stale.certificates[0].sha,
    "A source change must not inherit an old exact-head receipt");
});

test("all active, archived, overlay, and historical source records are discoverable", () => {
  const groups = API.catalog(docs);
  assert.deepEqual(groups.map(g=>g.items.length),[15,11,4,67]);
  for (const g of groups) assert.equal(g.valid,true);
  const historicalWerner = API.collect("werner",docs);
  assert.equal(historicalWerner.historical[0].id,"werner");
  const asua = API.collect("asua",docs);
  assert.equal(asua.historical[0].id,"asua-collateral");
  const source = groups.find(g=>g.kind==="provenance").items[0];
  assert.ok(source.path.endsWith(".lean"));
  assert.ok(API.links.source(source.path).startsWith("https://github.com/d3lefts/d3lefts/"));
});

test("browser page integrates read-only source bundles and keyboard-accessible claim selection", () => {
  const html = read("docs/theory.html"),ui=read("docs/theory-evidence-ui.js"),
    js=read("docs/theory.js"),css=read("docs/theory-evidence.css"),
    workflow=read(".github/workflows/nightfall-theory-atlas.yml");
  for(const file of ["research-registry.js","theory-evidence-core.js","theory-evidence-ui.js","theory-evidence.css"])
    assert.ok(html.includes('"' + file + '"'),file);
  for(const id of ["theory-evidence-detail","theory-registry-status",
    "theory-register-results","theory-register-tabs","theory-register-search"])
    assert.ok(html.includes('id="' + id + '"'),id);
  for(const name of ["active-proof-passport.json","lean-proof-passport-overlay.json",
    "lean-certificate-provenance.json","theory-evidence-links.json"])
    assert.ok(ui.includes(name),name);
  assert.match(js,/nightfall:theory-node-change/);
  assert.match(ui,/addEventListener\("nightfall:theory-node-change"/);
  assert.match(ui,/cache: "no-store"/);
  assert.match(ui,/aria-pressed/);
  assert.match(css,/@media \(max-width:680px\)/);
  assert.match(css,/theory-evidence-warning/);
  assert.doesNotMatch(ui,/\.innerHTML\s*=/);
  assert.doesNotMatch(html,/\bon[a-z]+="/i);
  for(const p of ["docs/active-proof-passport.json","docs/lean-proof-passport-overlay.json",
    "docs/lean-certificate-provenance.json","docs/theory-evidence-links.json",
    "research/nightfall/formalization/universal/"])
    assert.ok(workflow.includes(p),p+" must trigger checks on source update");
  new vm.Script(ui,{filename:"theory-evidence-ui.js"});
});
