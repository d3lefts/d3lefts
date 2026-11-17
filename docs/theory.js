"use strict";
/* NIGHTFALL Theory Atlas: static, curated links. All node prose is rendered
 * with textContent; this graph does not infer or certify new theorems. */
(() => {
  const data = window.NightfallTheoryData;
  const $ = id => document.getElementById(id);
  if (!data || !Array.isArray(data.nodes) || !$("theory-nodes")) return;
  const stageIndex = new Map(data.stages.map((x, i) => [x.id, i]));
  const fieldIndex = new Map(data.fields.map((x, i) => [x.id, i]));
  const nodeById = new Map(data.nodes.map(n => [n.id, n]));
  const fieldById = new Map(data.fields.map(f => [f.id, f]));
  const statusNames = {
    published: "PUBLISHED ANTECEDENT",
    kernel: "KERNEL-CHECKED / SCOPED",
    finite: "EXACT FINITE INSTANCE",
    analytic: "ANALYTIC / UNREFEREED",
    conditional: "CONDITIONAL",
    open: "UNRESOLVED",
    method: "DOCUMENTED METHOD"
  };
  const edgeNames = {
    context: "PRIOR CONTEXT",
    method: "DOCUMENTED RELATION",
    comparison: "MODEL COMPARISON",
    open: "UNPROVED BRIDGE"
  };
  const validLink = s => typeof s === "string" &&
    (/^https:\/\/(github\.com|arxiv\.org|mathlib\.org|en\.wikipedia\.org)\//i.test(s) ||
      /^[a-z0-9][a-z0-9-]*\.html(?:#[a-z0-9-]+)?$/i.test(s));
  const create = (tag, className, content) => {
    const element = document.createElement(tag);
    if (className) element.className = className;
    if (content !== undefined) element.textContent = String(content);
    return element;
  };
  let chosen = new URLSearchParams(location.search).get("node");
  if (!nodeById.has(chosen)) chosen = null;
  let activeField = "all", activeStatus = "all", search = "", raf = 0;
  const map = $("theory-nodes");
  const canvas = $("theory-canvas");
  const svg = $("theory-connectors");
  const counts = {
    fields: $("theory-fields-count"),
    nodes: $("theory-node-count"),
    edges: $("theory-edge-count"),
    visible: $("theory-visible-count")
  };
  counts.fields.textContent = data.fields.length.toString().padStart(2, "0");
  counts.nodes.textContent = data.nodes.length.toString().padStart(2, "0");
  counts.edges.textContent = data.edges.length.toString().padStart(2, "0");
  const fieldSelect = $("theory-field");
  data.fields.forEach(f => {
    const option = document.createElement("option");
    option.value = f.id;
    option.textContent = f.title;
    fieldSelect.append(option);
  });
  const isVisible = n => (activeField === "all" || n.field === activeField) &&
    (activeStatus === "all" || n.status === activeStatus) &&
    (!search || [n.title, n.scope, fieldById.get(n.field).title, statusNames[n.status]]
      .join(" ").toLocaleLowerCase().includes(search));
  const setUrl = () => {
    const u = new URL(location.href);
    if (chosen) u.searchParams.set("node", chosen);
    else u.searchParams.delete("node");
    history.replaceState(null, "", u);
  };
  const show = id => {
    chosen = chosen === id ? null : id;
    activeField = "all";
    activeStatus = "all";
    search = "";
    $("theory-field").value = "all";
    $("theory-status").value = "all";
    $("theory-search").value = "";
    setUrl();
    render();
  };
  function renderNodes(visible) {
    map.replaceChildren();
    const chosenNode = nodeById.get(chosen);
    visible.forEach(n => {
      const f = fieldById.get(n.field);
      const button = create("button", "theory-node");
      button.type = "button";
      button.dataset.node = n.id;
      button.dataset.status = n.status;
      button.style.setProperty("--lane-color", f.accent);
      button.style.gridColumn = String(stageIndex.get(n.stage) + 1);
      button.style.gridRow = String(fieldIndex.get(n.field) + 1);
      button.setAttribute("aria-pressed", String(chosen === n.id));
      button.setAttribute("aria-label", n.title + ", " + statusNames[n.status] + ", " + f.title);
      if (chosenNode && chosen !== n.id &&
        !data.edges.some(e => (e.from === chosen && e.to === n.id) ||
                              (e.to === chosen && e.from === n.id))) button.classList.add("theory-node--dim");
      button.append(create("span", "theory-node-corridor", f.title));
      button.append(create("strong", "theory-node-title", n.title));
      button.append(create("small", "theory-node-status", statusNames[n.status]));
      button.addEventListener("click", () => show(n.id));
      map.append(button);
    });
  }
  function renderDetail() {
    const node = nodeById.get(chosen);
    const source = $("theory-inspector-source");
    if (!node) {
      $("theory-inspector-status").textContent = "CURATED MAP";
      $("theory-inspector-title").textContent = "Select a node.";
      $("theory-inspector-intro").textContent =
        "Follow a claim to its actual evidence, assumptions and open gates. Every relationship carries a distinct type.";
      $("theory-inspector-scope").textContent =
        "Choose any of the four stages inside one of the six research corridors.";
      $("theory-inspector-evidence").textContent =
        "Published background, scoped Lean proofs, finite witnesses, analytic work and open questions are kept separate.";
      $("theory-inspector-limit").textContent =
        "An arrow is not proof of a transfer. This is a manually curated reading map, not a whole-field audit.";
      $("theory-inspector-next").textContent =
        "Pick a node and inspect the cited source and its strongest missing premise.";
      source.href = "research.html";
      source.textContent = "Open the public research library ↗";
      $("theory-related").replaceChildren(create("p", "", "Choose a node to display its documented or unresolved relationships."));
      return;
    }
    $("theory-inspector-status").textContent = statusNames[node.status];
    $("theory-inspector-title").textContent = node.title;
    $("theory-inspector-intro").textContent =
      fieldById.get(node.field).title + " / " + data.stages[stageIndex.get(node.stage)].label;
    $("theory-inspector-scope").textContent = node.scope;
    $("theory-inspector-evidence").textContent = node.evidence;
    $("theory-inspector-limit").textContent = node.limit;
    $("theory-inspector-next").textContent = node.next;
    source.href = validLink(node.source) ? node.source : "#method";
    source.textContent = node.sourceLabel + " ↗";
    if (source.href.startsWith("https:")) {
      source.target = "_blank";
      source.rel = "noopener noreferrer";
    } else {
      source.removeAttribute("target");
      source.removeAttribute("rel");
    }
    const related = $("theory-related");
    related.replaceChildren();
    const links = data.edges.filter(e => e.from === chosen || e.to === chosen);
    if (!links.length) related.append(create("p", "", "No curated relationships for this entry."));
    links.forEach(edge => {
      const other = nodeById.get(edge.from === chosen ? edge.to : edge.from);
      if (!other) return;
      const a = create("button", "theory-relation");
      a.type = "button";
      a.append(create("small", "", edgeNames[edge.kind] || "CURATED"));
      a.append(create("strong", "", other.title));
      a.append(create("span", "", edge.note));
      a.addEventListener("click", () => show(other.id));
      related.append(a);
    });
  }
  const svgNS = "http://www.w3.org/2000/svg";
  function drawEdges() {
    const rootRect = canvas.getBoundingClientRect();
    if (!rootRect.width || !rootRect.height) return;
    svg.replaceChildren();
    svg.setAttribute("viewBox", "0 0 " + rootRect.width + " " + rootRect.height);
    svg.setAttribute("preserveAspectRatio", "none");
    const visible = new Map([...map.querySelectorAll("[data-node]")].map(b => [b.dataset.node, b]));
    data.edges.forEach(e => {
      const from = visible.get(e.from), to = visible.get(e.to);
      if (!from || !to) return;
      const a = from.getBoundingClientRect(), b = to.getBoundingClientRect();
      const ax = a.left + a.width / 2 - rootRect.left;
      const ay = a.top + a.height / 2 - rootRect.top;
      const bx = b.left + b.width / 2 - rootRect.left;
      const by = b.top + b.height / 2 - rootRect.top;
      const path = document.createElementNS(svgNS, "path");
      const bend = Math.max(22, Math.abs(bx - ax) * 0.45);
      path.setAttribute("d", "M" + ax + " " + ay +
        " C" + (ax + bend) + " " + ay + " " + (bx - bend) + " " + by +
        " " + bx + " " + by);
      path.setAttribute("fill", "none");
      const isRelated = !chosen || e.from === chosen || e.to === chosen;
      path.setAttribute("stroke", e.kind === "open" ? "#d8a585" : e.kind === "comparison" ? "#a8bcc6" : "#a8a69b");
      path.setAttribute("stroke-opacity", isRelated ? (chosen ? ".76" : ".34") : ".07");
      path.setAttribute("stroke-width", chosen && isRelated ? "2.2" : "1.2");
      if (e.kind === "open") path.setAttribute("stroke-dasharray", "7 5");
      if (e.kind === "comparison") path.setAttribute("stroke-dasharray", "2 6");
      svg.append(path);
    });
  }
  const schedule = () => {
    if (raf) cancelAnimationFrame(raf);
    raf = requestAnimationFrame(drawEdges);
  };
  function render() {
    const visible = data.nodes.filter(isVisible);
    if (chosen && !visible.some(n => n.id === chosen)) {
      chosen = null;
      setUrl();
    }
    renderNodes(visible);
    renderDetail();
    counts.visible.textContent = visible.length + " of " + data.nodes.length + " curated entries visible";
    schedule();
  }
  const changeFilters = () => {
    activeField = fieldSelect.value;
    activeStatus = $("theory-status").value;
    search = $("theory-search").value.trim().toLocaleLowerCase();
    render();
  };
  $("theory-search").addEventListener("input", changeFilters);
  fieldSelect.addEventListener("change", changeFilters);
  $("theory-status").addEventListener("change", changeFilters);
  $("theory-reset").addEventListener("click", () => {
    chosen = null;
    activeField = activeStatus = "all";
    search = "";
    $("theory-search").value = "";
    fieldSelect.value = "all";
    $("theory-status").value = "all";
    setUrl();
    render();
    $("theory-search").focus();
  });
  $("theory-corridor-list").replaceChildren();
  data.fields.forEach((field, index) => {
    const section = create("article", "theory-corridor");
    section.style.setProperty("--lane-color", field.accent);
    section.append(create("span", "theory-corridor-index", String(index + 1).padStart(2, "0")));
    const heading = create("div", "theory-corridor-heading");
    heading.append(create("span", "", field.subtitle));
    heading.append(create("h3", "", field.title));
    section.append(heading);
    const description = create("div", "theory-corridor-question");
    description.append(create("p", "", field.question));
    const button = create("button", "theory-corridor-jump", "Trace this corridor ↗");
    button.type = "button";
    button.addEventListener("click", () => {
      chosen = null;
      activeField = field.id;
      activeStatus = "all";
      search = "";
      fieldSelect.value = field.id;
      $("theory-status").value = "all";
      $("theory-search").value = "";
      setUrl();
      render();
      $("explore").scrollIntoView({behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth"});
    });
    description.append(button);
    section.append(description);
    $("theory-corridor-list").append(section);
  });
  window.addEventListener("resize", schedule, {passive: true});
  if (typeof ResizeObserver !== "undefined") {
    new ResizeObserver(schedule).observe(canvas);
  }
  document.addEventListener("keydown", e => {
    if (e.key === "Escape" && chosen) {
      chosen = null;
      setUrl();
      render();
    }
  });
  const form = document.querySelector(".theory-controls");
  form?.addEventListener("submit", e => e.preventDefault());
  render();
})();