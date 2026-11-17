"use strict";
/* Read the same published records as the Proof Passport and Lean provenance
 * pages. A parsed JSON record is never itself a compiler run or revalidation. */
(() => {
  const API = window.NightfallTheoryEvidence;
  const map = window.NightfallTheoryData;
  const $ = id => document.getElementById(id);
  if (!API || !map || !$("theory-evidence-detail")) return;
  const registryFiles = {
    links: "theory-evidence-links.json",
    active: "active-proof-passport.json",
    overlay: "lean-proof-passport-overlay.json",
    provenance: "lean-certificate-provenance.json"
  };
  const docs = {historical: window.NightfallRegistry || null};
  let selectedCollection = "active";
  let search = "";
  const el = (name, cls, value) => {
    const e = document.createElement(name);
    if (cls) e.className = cls;
    if (value !== undefined) e.textContent = String(value);
    return e;
  };
  function safeLink(url, title, cls) {
    if (typeof url !== "string" || !(
      /^https:\/\/github\.com\/d3lefts\/d3lefts\/(?:blob\/main\/|actions\/runs\/|pull\/)/.test(url) ||
      /^(?:active-proof-passport|passport|lean-certificate-provenance|theory)\.html(?:[?#][a-z0-9_=%&-]+)?$/i.test(url)
    )) return null;
    const a = el("a", cls || "theory-evidence-link", title);
    a.href = url;
    if (url.startsWith("https://")) {
      a.target = "_blank";
      a.rel = "noopener noreferrer";
    }
    return a;
  }
  function appendLink(root, url, label, css) {
    const a = safeLink(url, label, css);
    if (a) root.append(a);
  }
  function note(p, text) {
    p.append(el("p", "theory-evidence-note", text));
  }
  function registryBanner() {
    const good = ["active","historical","overlay","provenance"].filter(k => API.checkShape(k, docs[k]));
    const missing = ["active","historical","overlay","provenance"].filter(k => !good.includes(k));
    const banner = $("theory-registry-status");
    banner.textContent = good.length + "/4 source registries loaded from this website revision." +
      (missing.length ? " UNAVAILABLE: " + missing.join(", ") + "; unavailable claims are not certified." : "");
    banner.dataset.complete = String(missing.length === 0);
    const dates = [
      docs.active && "active passports " + docs.active.as_of + " (v" + docs.active.version + ")",
      docs.overlay && "Lean overlay " + docs.overlay.created,
      docs.provenance && "Lean custody " + docs.provenance.as_of
    ].filter(Boolean);
    $("theory-registry-dates").textContent = dates.join(" · ") +
      " · Earlier source snapshots are not current CI checks.";
  }
  function card(kind, data, index) {
    const article = el("article", "theory-evidence-record");
    article.append(el("span", "theory-evidence-kind", kind + " / " + String(index + 1).padStart(2,"0")));
    article.append(el("h5", "", data.title));
    article.append(el("p", "theory-evidence-status", data.status || "Recorded / separate scope"));
    const detail = data.note || data.scope || "";
    if (detail) article.append(el("p", "theory-evidence-small", detail));
    const row = el("div", "theory-evidence-actions");
    if (kind === "Active Proof Passport") {
      appendLink(row, API.links.active(data.id), "Open full passport ↗");
    } else if (kind === "Historical Proof Passport") {
      appendLink(row, API.links.historical(data.id), "Open historical passport ↗");
    } else if (kind === "Lean overlay") {
      appendLink(row, API.links.overlay(), "Open exact overlay JSON ↗");
    }
    article.append(row);
    return article;
  }
  function renderSelected() {
    const box = $("theory-evidence-detail");
    box.replaceChildren();
    const node = $("theory-inspector")?.dataset.theoryNode || null;
    if (!node) {
      note(box, "Select a research-map node to load its explicitly mapped passport and Lean-source receipts. The full source registries are also available below.");
      return;
    }
    const r = API.collect(node, docs);
    if (r.errors.length) {
      const warn = el("div", "theory-evidence-warning");
      warn.append(el("strong", "", "UNVERIFIED OR INCOMPLETE REGISTRY LINK"));
      for (const error of r.errors) note(warn, error);
      box.append(warn);
    }
    if (!r.hasLinks) {
      note(box, "No claim-specific passport or Lean certificate is asserted for this selected entry. Its primary scholarly source remains available above.");
    }
    if (r.binding.note) note(box, r.binding.note);
    const sections = [
      {name:"Active Proof Passport", key:"active"},
      {name:"Historical Proof Passport", key:"historical"},
      {name:"Lean overlay (scope-gated)", key:"overlay"}
    ];
    sections.forEach(({name,key}) => {
      for (const [i,record] of r[key].entries()) {
        const d = key === "overlay" ?
          {id:record.id,title:record.theorem_declaration || record.id,
            status:"REGISTERED GATES: " + Object.values(record.gates || {}).join(" / "),
            note: "Complete certificate for global target: " + (record.complete_certification ? "reported" : "NO") +
              ". " + (record.limitations || []).join(" ")}
          : {id:record.id,title:record.title,status:record.status ||
              record.validity?.label || record.validity?.level || "Historical / scoped",
            note: (record.limitations || []).join(" ") || record.short || record.claim || ""};
        const entry = card(name, d, i);
        const actions = entry.querySelector(".theory-evidence-actions");
        if (key === "overlay") {
          appendLink(actions, API.links.source(record.source_path), "Read theorem source ↗");
          appendLink(actions, API.links.run(record.evidence?.ci_run), "Original CI receipt ↗");
          const pin = el("code", "theory-evidence-sha", record.git_blob_sha1 || "no source blob");
          entry.append(pin);
        }
        box.append(entry);
      }
    });
    for (const cert of r.certificates) {
      const c = el("article", "theory-evidence-record theory-evidence-certificate");
      c.append(el("span", "theory-evidence-kind", cert.conditional ?
        "LEAN / CONDITIONAL SOURCE RECEIPT" : "LEAN / EXACT-SOURCE SCOPED RECEIPT"));
      c.append(el("h5", "", cert.declaration));
      c.append(el("p", "theory-evidence-small", cert.scope));
      const meta = el("dl", "theory-evidence-certificate-meta");
      for (const [k,v] of [["SOURCE GIT BLOB",cert.sha],["DECLARATION",cert.declaration],
        ["ORIGINAL PR", "#" + cert.pr],["PIN", docs.links?.toolchain?.lean || "repository-defined"]]) {
        const pair = el("div");
        pair.append(el("dt", "", k));
        pair.append(el("dd", "", v));
        meta.append(pair);
      }
      c.append(meta);
      const row = el("div", "theory-evidence-actions");
      appendLink(row, API.links.source(cert.path), "Read exact Lean source ↗");
      appendLink(row, API.links.run(cert.run), "Open named CI receipt ↗");
      appendLink(row, "https://github.com/d3lefts/d3lefts/pull/" + cert.pr, "Source PR ↗");
      c.append(row);
      box.append(c);
    }
    // Direct graph edges are epistemic dependencies, NOT automatically valid
    // theorem implications. Expose their open status in a separate view.
    const open = map.edges.filter(e => e.kind === "open" &&
      (e.from === node || e.to === node));
    if (open.length) {
      const warning = el("div", "theory-evidence-warning theory-evidence-open");
      warning.append(el("strong", "", open.length + " UNPROVED GRAPH BRIDGE" +
        (open.length === 1 ? "" : "S") + " TOUCH THIS NODE"));
      open.forEach(edge => {
        const other = map.nodes.find(n => n.id === (edge.to === node ? edge.from : edge.to));
        note(warning, (other?.title || "Another research node") + ": " + edge.note);
      });
      box.append(warning);
    }
    note(box, "Source receipts above are immutable historical references, not live compiler execution. A change in source or assumptions requires a new exact-head check and independent statement review.");
  }
  function catalogRow(item, kind) {
    const row = el("article", "theory-catalog-item");
    row.append(el("span", "theory-evidence-kind", kind === "provenance" ?
      "HISTORICAL SOURCE / NOT A THEOREM CERTIFICATE" :
      kind === "overlay" ? "OVERLAY / SCOPED GATE RECORD" :
      kind === "historical" ? "FROZEN HISTORICAL PASSPORT" : "ACTIVE PASSPORT"));
    row.append(el("h4", "", item.title || item.id));
    row.append(el("p", "theory-evidence-status", item.status || "Source metadata"));
    if (item.note) row.append(el("p", "theory-evidence-small",
      String(item.note).slice(0,360) + (String(item.note).length > 360 ? "…" : "")));
    if (item.blob) row.append(el("code", "theory-evidence-sha", "Blob: " + item.blob));
    if (kind === "overlay" && item.full === false)
      row.append(el("p", "theory-evidence-limitation", "NOT a complete global theorem certificate"));
    const actions = el("div", "theory-evidence-actions");
    if (kind === "active") appendLink(actions, API.links.active(item.id), "Open passport ↗");
    if (kind === "historical") appendLink(actions, API.links.historical(item.id), "Open passport ↗");
    if (kind === "overlay") appendLink(actions, API.links.overlay(), "Source overlay ↗");
    if (kind === "provenance") appendLink(actions, API.links.provenance(), "Read custody policy ↗");
    if (kind === "overlay" || kind === "provenance") {
      appendLink(actions, API.links.source(item.path), "Lean source ↗");
      appendLink(actions, API.links.run(item.run), "Pinned CI ↗");
    }
    row.append(actions);
    return row;
  }
  function renderCatalog() {
    const catalog = API.catalog(docs);
    const tabs = $("theory-register-tabs");
    const results = $("theory-register-results");
    tabs.replaceChildren();
    const current = catalog.find(x => x.kind === selectedCollection) || catalog[0];
    for (const group of catalog) {
      const btn = el("button", "", group.title + " / " + (group.valid ? group.items.length : "unavailable"));
      btn.type = "button";
      btn.dataset.collection = group.kind;
      btn.setAttribute("aria-pressed", String(group.kind === selectedCollection));
      btn.addEventListener("click", () => {
        selectedCollection = group.kind;
        renderCatalog();
      });
      tabs.append(btn);
    }
    results.replaceChildren();
    if (!current?.valid) {
      note(results, "This published registry could not be loaded or failed schema checks. No fallback claims were invented.");
      return;
    }
    const matching = current.items.filter(x => !search ||
      [x.id,x.title,x.status,x.path,x.note].filter(Boolean).join(" ").toLowerCase().includes(search));
    $("theory-register-count").textContent = matching.length + " of " + current.items.length +
      " " + current.title.toLowerCase() + " shown" +
      " · snapshot " + current.date;
    if (!matching.length) note(results, "No records matched this search.");
    for (const item of matching) results.append(catalogRow(item,current.kind));
  }
  function triggerNode() { renderSelected(); }
  document.addEventListener("nightfall:theory-node-change", triggerNode);
  $("theory-register-search")?.addEventListener("input", e => {
    search = e.target.value.trim().toLowerCase();
    renderCatalog();
  });
  const load = async ([key,file]) => {
    try {
      const res = await fetch(file, {cache: "no-store"});
      if (!res.ok) throw Error("HTTP " + res.status);
      const json = await res.json();
      if (!API.checkShape(key,json)) throw Error("Schema does not match " + key);
      docs[key] = json;
    } catch (e) {
      docs[key] = null;
      // Explicitly fail closed. A missing registry never changes a theorem
      // into a verified node or supplies a speculative fallback receipt.
    }
  };
  Promise.all(Object.entries(registryFiles).map(load)).then(() => {
    const errors = API.validateLinks(map,docs.links,docs);
    if (errors.length) {
      docs.links = null;
      const banner = $("theory-registry-status");
      banner.textContent = "Evidence crosswalk failed integrity validation. No matching proof status is asserted.";
      banner.dataset.complete = "false";
    } else registryBanner();
    renderSelected();
    renderCatalog();
  }).catch(() => {
    $("theory-registry-status").textContent =
      "Evidence registries unavailable; proof certification cannot be inferred from the map.";
    $("theory-registry-status").dataset.complete = "false";
    renderSelected();
    renderCatalog();
  });
})();