"use strict";
const el = (tag, text, cls) => {
  const node = document.createElement(tag);
  if (cls) node.className = cls;
  node.textContent = text;
  return node;
};
const addCard = (parent, title, text, secondary) => {
  const card = el("article", "", "card");
  card.append(el("h3", title), el("p", text));
  if (secondary) card.append(el("small", secondary));
  parent.append(card);
};
const sentence = (claim) => claim.predicate.replaceAll("_", " ") + "(" + claim.args.join(", ") + ")";
async function loadDossier() {
  const status = document.getElementById("load");
  try {
    const r = await fetch("/api/public/demo/dossiers/riverfront-001", {cache:"no-store"});
    if (!r.ok) throw new Error("Dossier was not independently replayable");
    const d = await r.json();
    if (d.schema !== "commonwealth.synthetic.dossier.v1" || !d.verification.fictional ||
        d.verification.status !== "MODEL_VALID" || d.preference.ballot_cast ||
        d.preference.stored) throw new Error("Dossier contract or proof failed");
    document.getElementById("question").textContent = d.question;
    const legal = document.getElementById("legal");
    d.verification.goals.forEach(row => addCard(legal,
      sentence(row.goal),
      row.status === "MODEL_DERIVED" ? "Derived under fictional assumed rules" : "INDETERMINATE — not established",
      "Source IDs: " + (row.sources.join(", ") || "none") + " · Real legal authority: NOT ASSESSED"));
    const data = document.getElementById("data");
    const labels = {
      median_home_price_usd: "Median housing price (fabricated)",
      comparable_occupancy_pct: "Comparable occupancy (fabricated)",
      proposed_units: "Units proposed (fictional)",
      developer_name: "Developer name (fictional)"
    };
    d.evidence.forEach(src => src.facts.forEach(f => {
      if (Object.hasOwn(labels, f.proposition.predicate)) {
        const value = f.proposition.args.at(-1);
        const formatted = f.proposition.predicate === "median_home_price_usd" ?
          "USD " + Number(value).toLocaleString("en-US") :
          f.proposition.predicate === "comparable_occupancy_pct" ? value + "%" : String(value);
        addCard(data, labels[f.proposition.predicate], formatted,
          "Synthetic source " + src.source_id + " · NOT REAL DATA");
      }
    }));
    const considerations = document.getElementById("considerations");
    addCard(considerations, "Potential benefits", d.considerations.potential_benefits.join(" · "),
      "Hypotheses, no net benefit calculated");
    addCard(considerations, "Potential costs", d.considerations.potential_costs.join(" · "),
      "Hypotheses, no impact study performed");
    const unanswered = document.getElementById("unanswered");
    d.unanswered.forEach(s => unanswered.append(el("li", s)));
    const sources = document.getElementById("sources");
    d.evidence.forEach(src => {
      const box = document.createElement("details");
      const summary = el("summary", src.source_id + " · " + src.issuer + " · " + src.kind);
      box.append(summary, el("p", src.original_text));
      box.append(el("p", "Source: " + src.source_uri + " · Effective " + src.legal_effective_at +
        " · Observed " + src.observed_at, "meta"));
      box.append(el("p", "SHA-256: " + src.content_sha256, "digest"));
      box.append(el("p", "Formalization: " + src.interpretation_status, "warning-text"));
      sources.append(box);
    });
    status.textContent = "Synthetic sources and modeled proof steps loaded. Nothing here establishes actual legal authority.";
  } catch (err) {
    status.textContent = "Unable to verify and load the synthetic dossier: " + err.message;
    document.querySelector("fieldset").disabled = true;
  }
}
document.querySelectorAll('input[name="preference"]').forEach(input => {
  input.addEventListener("change", () => {
    document.getElementById("selection").textContent =
      "Selected locally: " + input.value + ". This is not a vote and is not stored.";
  });
});
loadDossier();
