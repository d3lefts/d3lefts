"use strict";
/* NIGHTFALL Research Desk: editorial proof metadata + local research-session planning.
   No remote submission, automatic proof verification, or scientific status mutation. */
(() => {
  const R = window.NightfallRegistry;
  const $ = id => document.getElementById(id);
  if (!R || !Array.isArray(R.claims) || !R.claims.length) {
    if ($("desk-detail")) $("desk-detail").textContent = "Canonical research registry unavailable. Use the source-linked Proof Passports.";
    return;
  }
  const KEY = "nightfall_research_desk_v1";
  const MAX_STEPS = 40;
  const claims = R.claims;
  const byId = id => R.claimById(id);
  const known = new Set(claims.map(c => c.id));
  let selected = byId(new URLSearchParams(location.search).get("claim"))?.id || claims[0].id;
  let filter = "all", search = "";
  const node = (tag, cls, content) => {
    const e = document.createElement(tag);
    if (cls) e.className = cls;
    if (content !== undefined) e.textContent = String(content);
    return e;
  };
  const safeHref = href => /^(https:\/\/github\.com\/d3lefts\/d3lefts\/[^"<\s]+|[a-z0-9][a-z0-9._/?#=&-]*\.html(?:[?#][^"<\s]*)?)$/i.test(href) ? href : "#";
  const attachLink = (container, title, href, cls) => {
    const a = node("a", cls || "", title);
    a.href = safeHref(href);
    if (a.href.startsWith("https://github.com/")) { a.target = "_blank"; a.rel = "noopener"; }
    container.append(a);
    return a;
  };
  function restore() {
    let raw;
    try { raw = localStorage.getItem(KEY); } catch { return {items:[], notes:""}; }
    if (!raw) return {items:[], notes:""};
    try {
      const v = JSON.parse(raw);
      if (!v || v.version !== 1 || !Array.isArray(v.items)) return {items:[], notes:""};
      const seen = new Set(), items = [];
      for (const x of v.items.slice(0,MAX_STEPS)) {
        if (!x || !known.has(x.claimId) || typeof x.task !== "string") continue;
        const task = x.task.trim().slice(0,500);
        if (!task || seen.has(x.claimId+"\u0000"+task)) continue;
        seen.add(x.claimId+"\u0000"+task);
        items.push({claimId:x.claimId,task,done:x.done === true});
      }
      return {items,notes:typeof v.notes === "string" ? v.notes.slice(0,4000) : ""};
    } catch { return {items:[],notes:""}; }
  }
  const state = restore();
  function persist() {
    try {
      localStorage.setItem(KEY,JSON.stringify({version:1,items:state.items,notes:state.notes}));
      $("desk-save-state").textContent = "Saved to this browser only. Export a brief to carry the work elsewhere.";
    } catch {
      $("desk-save-state").textContent = "Browser storage unavailable or full. Export a session brief to preserve work.";
    }
  }
  const key = (id,task) => id + "\u0000" + task;
  const isQueued = (id,task) => state.items.some(x => key(x.claimId,x.task) === key(id,task));
  function renderList() {
    const host = $("desk-claim-list"); host.replaceChildren();
    const q = search.trim().toLocaleLowerCase();
    const matches = claims.filter(c => {
      const classMatch = filter === "all" || c.validity.level === filter;
      const textMatch = !q || [c.title,c.short,c.field,c.conditions,c.statement,...c.open].join(" ").toLocaleLowerCase().includes(q);
      return classMatch && textMatch;
    });
    matches.forEach((c,i) => {
      const b = node("button","desk-claim-button");
      b.type = "button";
      b.dataset.claimId = c.id;
      b.setAttribute("aria-pressed",String(selected === c.id));
      const n = node("span","",String(claims.indexOf(c)+1).padStart(2,"0"));
      const wrap = node("div");
      wrap.append(node("strong","",c.title),node("small","",c.validity.label + " · " + c.field));
      b.append(n,wrap);
      b.addEventListener("click",() => {
        selected = c.id;
        const u = new URL(location.href);
        u.searchParams.set("claim",selected);
        history.replaceState(null,"",u);
        renderList();
        renderDetails();
      });
      host.append(b);
    });
    if (!matches.length) host.append(node("p","desk-empty","No matching claims. Reset the filter to see all canonical records."));
    $("desk-list-count").textContent = matches.length + " / " + claims.length + " current claims visible";
  }
  function renderDetails() {
    const c = byId(selected); if (!c) return;
    const host = $("desk-detail"); host.replaceChildren();
    host.append(node("span","desk-detail-field",c.field.toUpperCase()+" / "+c.kind.toUpperCase()));
    host.append(node("h3","desk-detail-heading",c.title));
    host.append(node("p","desk-statement",c.statement));
    const cond = node("div","desk-condition");
    cond.append(node("strong","","SCOPE / REQUIRED CONDITIONS"),node("span","",c.conditions));
    host.append(cond);
    const dims = node("div","desk-dimensions");
    for (const dimension of R.dimensions) {
      const value = c[dimension];
      const card = node("article","desk-dimension");
      card.append(node("span","",dimension.toUpperCase()+" / "+value.level.toUpperCase()),node("strong","",value.label),node("p","",value.detail));
      dims.append(card);
    }
    host.append(dims);
    const head = node("div","desk-open-header");
    head.append(node("h3","","Next independent attacks"),node("span","",c.open.length+" open obligations"));
    host.append(head);
    const open = node("div","desk-open");
    c.open.forEach((task,idx) => {
      const row = node("div","desk-open-row");
      row.append(node("p","",task));
      const b = node("button","desk-add",isQueued(c.id,task)?"Added ✓":"Add to session +");
      b.type="button";
      b.disabled=isQueued(c.id,task) || state.items.length>=MAX_STEPS;
      b.dataset.openIndex=String(idx);
      b.addEventListener("click",() => {
        if (isQueued(c.id,task) || state.items.length>=MAX_STEPS) return;
        state.items.push({claimId:c.id,task,done:false});
        persist(); renderDetails(); renderQueue();
      });
      row.append(b);open.append(row);
    });
    host.append(open);
    const path = node("div","desk-path");
    path.append(node("h3","","Primary evidence"));
    c.sources.forEach(s => attachLink(path,s.label+" ↗",s.url));
    host.append(path);
    const actions = node("div","desk-quick-actions");
    attachLink(actions,"Open Proof Passport ↗","passport.html?claim="+encodeURIComponent(c.id));
    attachLink(actions,"Trace the mechanism ↗","atlas.html?claim="+encodeURIComponent(c.id));
    c.tools.slice(0,2).forEach((url,i)=>attachLink(actions,i===0?"Open research tool ↗":"Open review pathway ↗",url));
    host.append(actions);
  }
  function renderQueue() {
    const host = $("desk-queue-list");host.replaceChildren();
    if (!state.items.length) host.append(node("p","desk-empty","No checks selected. Choose a claim above and add an open research obligation."));
    state.items.forEach((x,i) => {
      const c = byId(x.claimId);
      const row = node("div","desk-queue-row"+(x.done?" done":""));
      const check = node("input");
      check.type = "checkbox"; check.checked = x.done;
      check.setAttribute("aria-label","Mark task complete in local session: "+x.task);
      check.addEventListener("change",()=>{x.done=check.checked;persist();renderQueue()});
      const t = node("div");
      t.append(node("strong","",(c?.title||x.claimId).toUpperCase()),node("p","",x.task));
      if (!c?.open.includes(x.task)) t.append(node("small","","Archived session item — absent from current registry obligations"));
      const remove = node("button","desk-queue-remove","Remove");
      remove.type="button"; remove.setAttribute("aria-label","Remove task "+(i+1));
      remove.addEventListener("click",()=>{state.items.splice(i,1);persist();renderQueue();renderDetails()});
      row.append(check,t,remove);host.append(row);
    });
    $("desk-count").textContent = state.items.length+" step"+(state.items.length===1?"":"s")+" · "+state.items.filter(x=>x.done).length+" marked complete";
    $("desk-queued-total").textContent = String(state.items.length).padStart(2,"0");
    $("desk-export-md").disabled = !state.items.length && !state.notes.trim();
    $("desk-export-json").disabled = !state.items.length && !state.notes.trim();
    const shortcut=$("desk-session-shortcut");
    shortcut.hidden=state.items.length===0;
    shortcut.textContent="Review "+state.items.length+" selected check"+(state.items.length===1?"":"s")+" in your session ↓";
  }
  function snapshotItems() {
    return state.items.map(x => {
      const c = byId(x.claimId);
      return {claimId:x.claimId,title:c?.title||x.claimId,task:x.task,done:x.done,
        registryTaskCurrent:!!c?.open.includes(x.task),scope:c?.conditions||"",
        validity:c?.validity.label||"",passport:"passport.html?claim="+encodeURIComponent(x.claimId)};
    });
  }
  function exportPayload() {
    return {format:"nightfall-research-session-v1",exportedAt:new Date().toISOString(),
      registrySnapshot:R.asOf,scientificStatus:"LOCAL PLANNING ONLY — no scientific evidence promotion",
      items:snapshotItems(),notes:state.notes};
  }
  function markdown() {
    const payload = exportPayload();
    const groups = [...new Set(payload.items.map(x=>x.claimId))];
    let text = "# NIGHTFALL — Independent research session\n\n"
      +"Registry snapshot: "+payload.registrySnapshot+"\n"
      +"Exported: "+payload.exportedAt+"\n"
      +"Status: Research planning only; no proof certificate, theorem promotion, or external reviewer approval.\n\n";
    for (const id of groups) {
      const c=byId(id);
      text += "## "+c.title+"\n\n";
      text += "**Exact scope:** "+c.conditions+"\n\n";
      text += "**Current validity:** "+c.validity.label+"\n\n";
      text += "**Primary record:** passport.html?claim="+encodeURIComponent(id)+"\n\n";
      for (const x of payload.items.filter(i=>i.claimId===id))
        text += "- ["+(x.done?"x":" ")+"] "+x.task.replace(/[\r\n]+/g," ") + (x.registryTaskCurrent?"":" [archive-only task]")+"\n";
      text+="\n**Unresolved source dependencies:**\n";
      for(const item of c.open)text+="- "+item+"\n";
      text+="\n";
    }
    text+="## Session strategy\n\n"+(state.notes.trim()||"No additional notes.")+"\n\n";
    text+="---\nChecks complete in this planning UI are not certified scientific results.\n";
    return text;
  }
  function download(filename,content,type) {
    const url = URL.createObjectURL(new Blob([content],{type}));
    const a = node("a");
    a.href = url; a.download=filename; document.body.append(a);a.click();a.remove();
    setTimeout(()=>URL.revokeObjectURL(url),1000);
  }
  $("desk-claim-total").textContent = String(claims.length).padStart(2,"0");
  $("desk-snapshot").textContent = "Canonical snapshot: "+R.asOf;
  $("desk-notes").value = state.notes;
  $("desk-notes").addEventListener("input",e=>{state.notes=e.target.value.slice(0,4000);persist();renderQueue()});
  $("desk-search").addEventListener("input",e=>{search=e.target.value;renderList()});
  $("desk-filter").addEventListener("change",e=>{filter=e.target.value;renderList()});
  $("desk-export-md").addEventListener("click",()=>download("NIGHTFALL_research_session.md",markdown(),"text/markdown"));
  $("desk-export-json").addEventListener("click",()=>download("NIGHTFALL_research_session.json",JSON.stringify(exportPayload(),null,2)+"\n","application/json"));
  $("desk-clear").addEventListener("click",()=>{
    if (!state.items.length&&!state.notes.trim()) return;
    if (!confirm("Clear this browser's Research Desk session? Export a backup first if needed."))return;
    state.items=[];state.notes="";$("desk-notes").value="";
    persist();renderQueue();renderDetails();
  });
  renderList(); renderDetails(); renderQueue();
})();