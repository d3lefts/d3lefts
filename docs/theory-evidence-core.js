"use strict";
/* The Theory Atlas evidence bridge is a READ-ONLY crosswalk.
 * It NEVER upgrades a theorem from a successful job, shared name, connected
 * graph edge, or stale editorial record. The caller owns verified registries.
 */
(function(root, createModule) {
  const api = createModule();
  if (typeof module === "object" && module.exports) module.exports = api;
  if (root) root.NightfallTheoryEvidence = api;
})(typeof window === "object" ? window : null, function() {
  const requiredSchemas = Object.freeze({
    links: "nightfall.theory-evidence-links.v1",
    active: "nightfall-active-proof-passports-v1",
    overlay: "nightfall.lean-proof-passport-overlay.v1",
    provenance: "nightfall-lean-provenance-v1"
  });
  const gitRoot = "https://github.com/d3lefts/d3lefts/blob/main/";
  const safeSha = /^[0-9a-f]{40}$/;
  const safeRel = /^(?:[a-z0-9._-]+\/)*[a-z0-9._-]+$/i;
  const safeId = /^[a-z0-9][a-z0-9-]*$/;
  const links = Object.freeze({
    active: id => "active-proof-passport.html#" + encodeURIComponent(id),
    historical: id => "passport.html?claim=" + encodeURIComponent(id),
    overlay: () => gitRoot + "docs/lean-proof-passport-overlay.json",
    provenance: () => "lean-certificate-provenance.html",
    source: path => safeRel.test(path) && !path.split("/").includes("..") ? gitRoot + path : null,
    run: run => Number.isSafeInteger(run) && run > 0 ? "https://github.com/d3lefts/d3lefts/actions/runs/" + run : null
  });
  function checkShape(name, value) {
    if (name === "historical") return !!value && Array.isArray(value.claims) &&
      value.claims.every(x => safeId.test(x.id || ""));
    return !!value && value.schema === requiredSchemas[name] &&
      (name === "links" ? !!value.bindings && Array.isArray(value.certificates) :
      name === "active" ? Array.isArray(value.claims) :
      name === "overlay" ? Array.isArray(value.records) :
      name === "provenance" && Array.isArray(value.modules));
  }
  function indexById(items) {
    return new Map(Array.isArray(items) ? items.filter(x => x && safeId.test(x.id || ""))
      .map(x => [x.id, x]) : []);
  }
  function collect(nodeId, docs) {
    const sources = docs || {};
    const linkRecord = checkShape("links", sources.links) ? sources.links : null;
    const binding = linkRecord && linkRecord.bindings[nodeId] || {};
    const errors = [];
    const fetchIds = (kind, ids) => {
      const doc = sources[kind];
      const array = kind === "overlay" ? doc?.records : doc?.claims;
      if (!checkShape(kind, doc)) {
        if (ids?.length) errors.push(kind + " registry missing or incompatible");
        return [];
      }
      const index = indexById(array);
      return (ids || []).flatMap(id => {
        const entry = index.get(id);
        if (!entry) {
          errors.push(kind + " record not found: " + id);
          return [];
        }
        return [{...entry, registry: kind, registryDate: doc.as_of || doc.created || doc.snapshot || "undated"}];
      });
    };
    if (!linkRecord) errors.push("Evidence crosswalk is missing or incompatible");
    const active = fetchIds("active", binding.active);
    const historical = fetchIds("historical", binding.historical);
    const overlay = fetchIds("overlay", binding.overlay);
    const certificates = [];
    for (const id of binding.certificates || []) {
      const record = linkRecord?.certificates.find(x => x.id === id && x.node === nodeId);
      if (!record || !safeSha.test(record.sha) ||
          !links.source(record.path) || !links.run(record.run)) {
        errors.push("Exact-source receipt not available for " + id);
        continue;
      }
      certificates.push({...record, status: "referenced-immutable-source-receipt"});
    }
    // A differently scoped record is never made to serve as a substitute.
    for (const r of overlay) {
      const certificate = certificates.find(c => c.path === r.source_path &&
        c.declaration === r.theorem_declaration && c.sha === r.git_blob_sha1);
      if (!certificate && certificates.some(c => c.path === r.source_path)) {
        errors.push("Overlay/declaration or source hash mismatch: " + r.id);
      }
    }
    return {
      nodeId,
      binding,
      active,
      historical,
      overlay,
      certificates,
      errors,
      hasLinks: !!(active.length || historical.length || overlay.length || certificates.length),
      scope: "Read-only registry metadata; no automatic kernel, novelty, terminal-theorem or live-source status promotion."
    };
  }
  function catalog(docs) {
    const known = [
      {key: "active", list: "claims", label: "Active Proof Passports"},
      {key: "historical", list: "claims", label: "Historical Proof Passports"},
      {key: "overlay", list: "records", label: "Lean passport overlay"},
      {key: "provenance", list: "modules", label: "Historical Lean source custody"}
    ];
    return known.map(t => {
      const doc = docs?.[t.key];
      const valid = checkShape(t.key, doc);
      const arr = valid ? doc[t.list] : [];
      return {kind: t.key, title: t.label, valid, date: doc?.as_of || doc?.created || "not dated",
        items: arr.map(x => t.key === "provenance" ?
          {id: x.path, title: x.path.split("/").pop(), status: x.classification || "source custody",
            path: x.path, note: x.note, run: x.ci_run, blob: x.source_blob_sha,
            sourceMatch: x.ci_source_match_status, passport: x.passport} :
          t.key === "overlay" ?
          {id: x.id, title: x.theorem_declaration || x.id, status: x.kernel_replay?.status ||
            "overlay record", path: x.source_path, run: x.evidence?.ci_run,
            blob: x.git_blob_sha1, note: Array.isArray(x.limitations) ? x.limitations.join(" ") : String(x.limitations || ""), full: x.complete_certification} :
          {id: x.id, title: x.title, status: x.status || x.validity?.label || x.validity?.level ||
            "recorded", source: x.source, note: x.claim || x.short ||
            x.statement || x.conditions || ""})};
    });
  }
  function validateLinks(map, linksFile, docs) {
    const errors = [];
    if (!checkShape("links", linksFile)) return ["Missing or invalid crosswalk schema"];
    const nodeIds = new Set((map?.nodes || []).map(n => n.id));
    const certIds = new Set();
    for (const c of linksFile.certificates) {
      if (!safeId.test(c.id) || certIds.has(c.id)) errors.push("Certificate id duplicate or invalid: " + c.id);
      certIds.add(c.id);
      if (!nodeIds.has(c.node)) errors.push("Certificate with unknown node: " + c.id);
      if (!safeSha.test(c.sha) || !links.source(c.path) ||
        !links.run(c.run) || !c.declaration || !c.scope) errors.push("Invalid source receipt: " + c.id);
      if (c.conditional && !/conditional|assuming|does not/i.test(c.scope))
        errors.push("Conditional certificate scope is obscured: " + c.id);
    }
    for (const [nodeId, b] of Object.entries(linksFile.bindings)) {
      if (!nodeIds.has(nodeId)) errors.push("Unknown atlas node: " + nodeId);
      for (const c of b.certificates || [])
        if (!linksFile.certificates.some(x => x.id === c && x.node === nodeId))
          errors.push("Unmatched receipt: " + nodeId + "/" + c);
      for (const k of ["active","historical","overlay"]) {
        if (docs && checkShape(k, docs[k])) {
          const idx = indexById(docs[k][k === "overlay" ? "records" : "claims"]);
          for (const id of b[k] || []) if (!idx.has(id))
            errors.push("Unknown " + k + " id: " + nodeId + "/" + id);
        }
      }
    }
    if (linksFile.certificates.some(c => c.declaration?.includes("source_q2_quadratic_limit") && !c.conditional))
      errors.push("The infinite-product limit must remain conditional");
    const finiteOverlay = linksFile.bindings["q2-finite"]?.overlay || [];
    if (finiteOverlay.includes("q2-finite-current"))
      errors.push("Historical C23802 overlay is not the native heterogeneous C105 source");
    return errors;
  }
  return Object.freeze({checkShape, collect, catalog, validateLinks, links, requiredSchemas});
});