"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const test = require("node:test");
const root = path.resolve(__dirname, "..");
const data = require(path.join(root, "docs/theory-map-data.js"));
const html = fs.readFileSync(path.join(root, "docs/theory.html"), "utf8");
const js = fs.readFileSync(path.join(root, "docs/theory.js"), "utf8");
const css = fs.readFileSync(path.join(root, "docs/theory.css"), "utf8");
const categories = new Set(["published","kernel","finite","analytic","conditional","open","method"]);
const relationKinds = new Set(["context","method","comparison","open"]);
const localSource = /^[a-z0-9][a-z0-9-]*\.html(?:#[a-z0-9-]+)?$/i;
const externalSource = /^https:\/\/(github\.com|arxiv\.org|mathlib\.org|en\.wikipedia\.org)\//i;

test("the atlas is openly described as curated, not a corpus-wide audit", () => {
  assert.match(data.scope, /not an exhaustive survey/i);
  assert.match(html, /not a claim to have read or audited the entire field/i);
  assert.match(html, /does not contain a citation crawl/i);
  assert.match(html, /Claimed field-wide audits/);
});

test("all six disciplines have a complete four-stage structure", () => {
  assert.equal(data.fields.length, 6);
  assert.equal(data.stages.length, 4);
  const fields = new Set(data.fields.map(f => f.id));
  const stages = new Set(data.stages.map(s => s.id));
  assert.equal(fields.size, data.fields.length);
  assert.equal(stages.size, data.stages.length);
  assert.equal(data.nodes.length, fields.size * stages.size);
  assert.equal(new Set(data.nodes.map(n => n.id)).size, data.nodes.length);
  for (const field of data.fields) {
    for (const stage of data.stages) {
      assert.equal(data.nodes.filter(n => n.field === field.id && n.stage === stage.id).length, 1,
        field.id + " / " + stage.id + " must have one curated entry");
    }
  }
});

test("every entry exposes evidence, a concrete limit and a safe source link", () => {
  for (const n of data.nodes) {
    for (const key of ["id","title","scope","evidence","limit","next","sourceLabel","source"]) {
      assert.equal(typeof n[key], "string", n.id + " missing " + key);
      assert.ok(n[key].length >= 4, n.id + " has empty " + key);
    }
    assert.ok(categories.has(n.status), n.id + " invalid status");
    assert.ok(externalSource.test(n.source) || localSource.test(n.source),
      n.id + " has unsafe or unlinked primary source: " + n.source);
    if (n.status === "open") assert.match(n.limit + " " + n.next, /not|must|remain|need|pending|check|certif|unknown|unproved|prove/i);
    if (n.status === "kernel") assert.match(n.evidence, /Lean|kernel|compiler/i);
  }
});

test("all 24 relationships have real endpoints and explicit epistemic types", () => {
  const nodes = new Set(data.nodes.map(n => n.id));
  assert.equal(data.edges.length, 24);
  const relationships = new Set();
  for (const edge of data.edges) {
    assert.ok(nodes.has(edge.from), "missing source " + edge.from);
    assert.ok(nodes.has(edge.to), "missing target " + edge.to);
    assert.notEqual(edge.from, edge.to);
    assert.ok(relationKinds.has(edge.kind), "invalid relation kind " + edge.kind);
    assert.ok(edge.note.length > 30, "edge needs explanatory caveat");
    const id = [edge.from, edge.to, edge.kind].join("→");
    assert.ok(!relationships.has(id), "duplicate relationship " + id);
    relationships.add(id);
  }
  assert.ok(data.edges.some(e => e.kind === "open"));
});

test("page controls, accessible inspector and canonical source scripts exist", () => {
  const required = ["theory-search","theory-field","theory-status","theory-reset","theory-canvas",
    "theory-nodes","theory-connectors","theory-inspector","theory-inspector-title",
    "theory-inspector-scope","theory-inspector-evidence","theory-inspector-limit",
    "theory-inspector-next","theory-inspector-source","theory-related","theory-corridor-list"];
  for (const id of required) assert.ok(html.includes('id="' + id + '"'), "missing " + id);
  for (const name of ["theory.css","theory-map-data.js","theory.js"]) assert.ok(html.includes('"' + name + '"'));
  assert.match(html, /aria-live="polite"/);
  assert.match(html, /Skip to theory/);
  assert.match(css, /prefers-reduced-motion/);
  assert.match(css, /focus-visible/);
  assert.match(css, /@media \(max-width:650px\)/);
  assert.doesNotMatch(html, /\bon[a-z]+="/i, "no inline JS event handlers");
  assert.doesNotMatch(js, /\.innerHTML\s*=/);
  new vm.Script(js, {filename:"theory.js"});
});

test("published NIGHTFALL links stay on canonical source paths", () => {
  assert.ok(data.nodes.find(n => n.id === "q2-finite").source.endsWith("InfinitePiQ2NativeSupportedTerminal.lean"));
  assert.ok(data.nodes.find(n => n.id === "q2-l2").source.endsWith("InfinitePiQ2AllL2LabelIntertwining.lean"));
  assert.equal(data.nodes.find(n => n.id === "q2-infinite").status, "open");
  assert.equal(data.nodes.find(n => n.id === "effect").status, "open");
  assert.equal(data.nodes.find(n => n.id === "camel").status, "published");
});
