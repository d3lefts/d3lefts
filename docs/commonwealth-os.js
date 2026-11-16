"use strict";
/*
 * Commonwealth OS website walkthrough. Static, fictional UI only.
 * NO backend, identity, storage, election, law ingestion, legal verification,
 * official vote, analytics beacon, or delegated authority is invoked here.
 * This is not a port of the standalone app or the independently authored checkers.
 */
(() => {
  const tabs = Array.from(document.querySelectorAll("[data-cw-tab]"));
  const panels = Array.from(document.querySelectorAll("[data-cw-panel]"));
  const details = Array.from(document.querySelectorAll("[data-cw-detail]"));
  const $ = id => document.getElementById(id);
  if (!tabs.length || !panels.length) return;

  function selectTab(id, focus) {
    for (const tab of tabs) {
      const active = tab.dataset.cwTab === id;
      tab.setAttribute("aria-selected", String(active));
      tab.tabIndex = active ? 0 : -1;
      if (active && focus) tab.focus();
    }
    for (const panel of panels) panel.hidden = panel.dataset.cwPanel !== id;
    for (const detail of details) detail.hidden = detail.dataset.cwDetail !== id;
  }
  tabs.forEach((tab, index) => {
    tab.addEventListener("click", () => selectTab(tab.dataset.cwTab, false));
    tab.addEventListener("keydown", event => {
      let next = null;
      if (event.key === "ArrowRight") next = (index + 1) % tabs.length;
      if (event.key === "ArrowLeft") next = (index + tabs.length - 1) % tabs.length;
      if (event.key === "Home") next = 0;
      if (event.key === "End") next = tabs.length - 1;
      if (next === null) return;
      event.preventDefault();
      selectTab(tabs[next].dataset.cwTab, true);
    });
  });

  // Outcomes below are explanatory labels mapped to *fictional* fixture cases.
  // They are not computed by either the browser's real ten-check evaluator,
  // the Python workflow model, or an independent decision verifier.
  const cases = {
    valid: {
      label: "SUPPORTED IN SIMULATION",
      level: "pass",
      detail: "The fixture has five attendees, five eligible ballots, an unchanged rule version and a clerk-review field. This is not an official decision."
    },
    stale: {
      label: "BLOCKED / STALE RULE",
      level: "fail",
      detail: "The evidence cites a superseded rule revision. The synthetic decision must not be presented as currently justified."
    },
    quorum: {
      label: "BLOCKED / NO QUORUM",
      level: "fail",
      detail: "The altered attendance fails the fixture's required five-person quorum. Vote arithmetic alone cannot certify a result."
    },
    review: {
      label: "INDETERMINATE / REVIEW MISSING",
      level: "unknown",
      detail: "The clerk-review assertion is missing, so the source-evidence preview cannot treat the outcome as verified."
    },
    outsider: {
      label: "BLOCKED / INELIGIBLE BALLOT",
      level: "fail",
      detail: "A ballot from a person outside the fictional eligible roster invalidates the proposed result."
    }
  };
  const scenario = $("cw-scenario");
  function setVerdict() {
    if (!scenario || !$("cw-scenario-verdict")) return;
    const result = cases[scenario.value] || cases.valid;
    const verdict = $("cw-scenario-verdict");
    verdict.textContent = result.label;
    verdict.className = "cw-verdict-" + result.level;
    $("cw-scenario-explanation").textContent = result.detail;
  }
  if (scenario) scenario.addEventListener("change", setVerdict);
  setVerdict();

  // In-memory preference; never call localStorage, fetch, or a form submit.
  const choiceButtons = Array.from(document.querySelectorAll("[data-cw-choice]"));
  const choiceLabels = {
    SUPPORT: "SUPPORT / PREVIEW ONLY",
    DO_NOT_SUPPORT: "DON'T SUPPORT / PREVIEW ONLY",
    NO_PREFERENCE: "NO PREFERENCE / PREVIEW ONLY"
  };
  let currentChoice = null;
  function renderChoice() {
    for (const button of choiceButtons) {
      button.setAttribute("aria-pressed", String(button.dataset.cwChoice === currentChoice));
    }
    const summary = $("cw-choice-summary");
    const feedback = $("cw-preference-feedback");
    if (summary) summary.textContent = currentChoice ? choiceLabels[currentChoice] : "UNKNOWN / NOT ASSESSED";
    if (feedback) feedback.textContent = currentChoice
      ? "Selected for this browser preview only. Nothing is recorded or submitted."
      : "No response selected. Unknown is not the same as No preference.";
  }
  for (const button of choiceButtons) {
    button.addEventListener("click", () => {
      currentChoice = button.dataset.cwChoice;
      renderChoice();
    });
  }
  if ($("cw-reset-choice")) $("cw-reset-choice").addEventListener("click", () => {
    currentChoice = null;
    renderChoice();
  });
  renderChoice();

  // Illustrates the need to recheck evidence after a source revision.
  // No actual file, fixture, or law is modified by the control.
  let sourceChanged = false;
  const sourceButton = $("cw-change-source");
  function renderSource() {
    if (!sourceButton || !$("cw-source-verdict")) return;
    sourceButton.setAttribute("aria-pressed", String(sourceChanged));
    sourceButton.firstChild.textContent = sourceChanged ? "Restore original snapshot " : "Simulate a source changing ";
    const verdict = $("cw-source-verdict");
    verdict.textContent = sourceChanged ? "INDETERMINATE / RECHECK REQUIRED" : "MODEL-SUPPORTED AT SNAPSHOT";
    verdict.className = sourceChanged ? "cw-verdict-unknown" : "cw-verdict-pass";
    $("cw-source-explanation").textContent = sourceChanged
      ? "A hypothetical source revision invalidates the previous dependency snapshot. Re-evaluation is required; no legal conclusion follows from this page."
      : "A source-bound derivation is supported in the recorded fictional model on November 15, 2026. No law is authenticated by this page.";
  }
  if (sourceButton) sourceButton.addEventListener("click", () => {
    sourceChanged = !sourceChanged;
    renderSource();
  });
  renderSource();

  // These 2024 entries correspond to the named rows in history_synthetic.json.
  // All are FICTIONAL source_status=SYNTHETIC_UNVERIFIED.
  const historical = {
    city: {
      date: "APR 11, 2024 · FINAL PASSAGE",
      motion: "Fictional land use motion 4",
      official: "Micah Quinn · EX-CITY-S2",
      position: "NAY",
      source: "FICTIONAL-CITY_COUNCIL-V004 · SYNTHETIC_UNVERIFIED"
    },
    county: {
      date: "APR 11, 2024 · FINAL PASSAGE",
      motion: "Fictional budget motion 4",
      official: "Sol Kim · EX-COUNTY-D2",
      position: "NAY",
      source: "FICTIONAL-COUNTY_COMMISSION-V004 · SYNTHETIC_UNVERIFIED"
    },
    school: {
      date: "APR 11, 2024 · FINAL PASSAGE",
      motion: "Fictional education motion 4",
      official: "Alex Rivera · EX-SCHOOL-A",
      position: "NAY",
      source: "FICTIONAL-SCHOOL_BOARD-V004 · SYNTHETIC_UNVERIFIED"
    }
  };
  const historicalSelect = $("cw-history-group");
  function renderHistory() {
    if (!historicalSelect) return;
    const item = historical[historicalSelect.value] || historical.city;
    $("cw-history-date").textContent = item.date;
    $("cw-history-motion").textContent = item.motion;
    $("cw-history-official").textContent = item.official;
    $("cw-history-position").textContent = item.position;
    $("cw-history-source").textContent = item.source;
  }
  if (historicalSelect) historicalSelect.addEventListener("change", renderHistory);
  renderHistory();
})();
