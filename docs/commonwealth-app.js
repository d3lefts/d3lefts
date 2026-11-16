"use strict";
/* Commonwealth OS: synthetic, browser-local product exploration.
   Do not add network requests, persistent storage, identity inference, or official vote submission. */
(function () {
  const ROOT = "https://github.com/d3lefts/d3lefts/blob/main/projects/commonwealth-os/historical/fixtures/";
  const F = window.COMMONWEALTH_SYNTHETIC;
  if (!F || !F.house || !F.senate || !F.municipal || !F.issues ||
      ![F.house, F.senate, F.municipal, F.issues].every(item => item.synthetic === true)) {
    document.body.textContent = "Synthetic fixture data is missing. This demonstration is disabled.";
    return;
  }
  const collections = [F.house, F.senate, F.municipal];
  const sources = {HOUSE: F.house, SENATE: F.senate, MUNICIPAL: F.municipal};
  const issues = F.issues.issues;
  const byId = new Map();
  collections.forEach(source => source.questions.forEach(question => {
    if (byId.has(question.question_id)) throw new Error("Duplicate question fixture identifier");
    byId.set(question.question_id, Object.assign({chamber:source.chamber,source_id:source.source_id},question));
  }));
  const qs = selector => document.querySelector(selector);
  const el = (tag, className, text) => {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = String(text);
    return node;
  };
  const appendPair = (parent, label, value) => {
    const d = el("div");
    d.append(el("dt", "", label), el("dd", "", value));
    parent.append(d);
  };
  const config = {issue:issues[0].issue_id,seat:"ALL",onlyExact:false};
  const userAnswers = Object.create(null);
  const questionLinks = (issueId, onlyExact) => F.issues.correspondence
    .filter(link => link.issue_id === issueId && (!onlyExact || link.relation === "EXACT_QUESTION"))
    .map(link => ({link,question:byId.get(link.question_id)}))
    .filter(item => item.question !== undefined)
    .sort((a,b) => b.question.date.localeCompare(a.question.date) ||
          a.question.question_id.localeCompare(b.question.question_id));
  const tenureAt = (source, date, district) => source.tenures.filter(t =>
    t.from <= date && date < t.to && (district === null || t.district === district));
  const recordPosition = (source, question, tenure) => {
    if (question.rollcall_type !== "RECORDED") return "NO NAMED VOTE (VOICE)";
    const row = source.votes.find(v => v.question_id === question.question_id && v.person_id === tenure.person_id);
    return row ? row.choice : "NO_RECORDED_POSITION";
  };
  const resolveMembers = (question, seat) => {
    const source = sources[question.chamber];
    if (!source) return [];
    if (seat !== "ALL") {
      const parts = seat.split(":");
      if (question.chamber !== parts[0]) return [];
      const members = tenureAt(source,question.date,parts[1]);
      return members.map(t => {
        const person = source.people.find(p => p.person_id === t.person_id);
        return {name:person ? person.name : "Unknown fictional member",status:recordPosition(source,question,t),seat:t.seat,tenure_id:t.tenure_id};
      });
    }
    return tenureAt(source,question.date,null).map(t => {
      const person = source.people.find(p => p.person_id === t.person_id);
      return {name:person ? person.name : "Unknown fictional member",status:recordPosition(source,question,t),seat:t.seat,tenure_id:t.tenure_id};
    });
  };
  const getVisible = () => questionLinks(config.issue,config.onlyExact).filter(({question}) =>
    config.seat === "ALL" || question.chamber === config.seat.split(":")[0]);
  const relationText = {
    EXACT_QUESTION:"EXACT QUESTION",
    SUBSTANTIVE_REVIEWED:"DIFFERENT QUESTION / REVIEWED",
    TOPIC_ONLY:"TOPIC ONLY",
    UNREVIEWED:"UNREVIEWED CANDIDATE"
  };
  function renderHistory() {
    const issue = issues.find(v => v.issue_id === config.issue);
    qs("#cw-issue-proposition").textContent = issue.proposition;
    qs("#cw-profile-issue").textContent = issue.title;
    const rows = getVisible();
    const list = qs("#cw-history-list");
    list.replaceChildren();
    qs("#cw-history-summary").textContent =
      String(rows.length) + " linked proceeding(s) in this limited fictional corpus. " +
      (config.onlyExact ? "Exact-question filter active." : "Topic-only and unreviewed links are visibly separated.") +
      " No completeness claim.";
    if (!rows.length) {
      list.append(el("p","cw-muted","No matching recorded proceeding in this selected fixture scope. That does not establish that no real-world vote exists."));
    }
    rows.forEach(({question,link}) => {
      const article = el("article","cw-record");
      const head = el("div","cw-record-head");
      head.append(el("strong","",question.title));
      const pills = el("div","cw-pills");
      const relation = el("span","cw-pill" + (link.relation === "EXACT_QUESTION" ? "" : " cw-warn"),relationText[link.relation] || "UNDETERMINED");
      pills.append(relation,el("span","cw-pill",question.kind),el("span","cw-pill",question.rollcall_type));
      head.append(pills);
      article.append(head,el("p","",question.proposition));
      const dl = el("dl");
      dl.append(el("div"));
      appendPair(dl,"Date / fictional",question.date);
      appendPair(dl,"Chamber",question.chamber);
      appendPair(dl,"Recorded procedure result",question.result);
      article.append(dl);
      const members = resolveMembers(question,config.seat);
      const memberList = el("div");
      if (members.length) {
        members.forEach(member => memberList.append(el("p","cw-member",
          member.seat + " · " + member.name + " · " + member.status)));
      } else {
        memberList.append(el("p","cw-muted",config.seat === "ALL" ?
          "No matching fictional tenure at the question date." :
          "No active fictional tenure for this selected seat at the question date; no successor vote is inferred."));
      }
      article.append(memberList);
      article.append(el("small","", "Correspondence: " + link.rationale +
        " Reviewer: " + link.reviewer + " (fictional)."));
      const sourceName = {HOUSE:"house",SENATE:"senate",MUNICIPAL:"municipal"}[question.chamber];
      const sourceLink = el("a","cw-fixture-link","Inspect fixture source ↗");
      sourceLink.href = ROOT + sourceName + ".json";
      article.append(el("p","cw-muted","Source: " + question.source_id + " · reference dataset only."), sourceLink);
      list.append(article);
    });
    renderProfile();
    renderPassport();
  }
  function renderProfile() {
    const value = userAnswers[config.issue];
    const labels = {SUPPORT:"Support",OPPOSE:"Do not support",NO_PREFERENCE:"No preference",NEED_INFO:"Need more information"};
    qs("#cw-profile-status").textContent = value ? labels[value] : "Unanswered / unknown";
    qs("#cw-profile-note").textContent = value ?
      "You explicitly selected a hypothetical preference. It is not a historical vote, a predicted stance or an official ballot." :
      "No response recorded. Unknown is not the same as opposition, abstention or no preference.";
    document.querySelectorAll("[data-choice]").forEach(button =>
      button.setAttribute("aria-pressed",String(button.dataset.choice === value)));
    const history = qs("#cw-profile-history");
    history.replaceChildren();
    Object.keys(userAnswers).sort().forEach(id => {
      const issue = issues.find(i => i.issue_id === id);
      if (!issue) return;
      const row = el("div","cw-profile-row");
      row.append(el("span","",issue.title),el("strong","",labels[userAnswers[id]]));
      history.append(row);
    });
  }
  function renderPassport() {
    const issue = issues.find(item => item.issue_id === config.issue);
    const links = questionLinks(config.issue,false);
    const exact = links.filter(({link}) => link.relation === "EXACT_QUESTION").length;
    const corpus = new Set(links.map(({question}) => question.chamber));
    const dl = qs("#cw-passport-facts");
    dl.replaceChildren();
    appendPair(dl,"Issue ID",issue.issue_id);
    appendPair(dl,"Source","fixture://commonwealth/issues/v1");
    appendPair(dl,"Linked questions",String(links.length)+" fictional source links");
    appendPair(dl,"Exact-question links",String(exact));
    appendPair(dl,"Chambers in this mapping",[...corpus].join(", ") || "None");
    appendPair(dl,"Semantic status",links.length ? "MIXED / SEE EACH LINK" : "NO_REVIEWED_RECORD_IN_CORPUS");
    appendPair(dl,"Legal authority","NOT ESTABLISHED");
    appendPair(dl,"Certificate","NOT ISSUED FOR THIS PAGE");
  }
  function initHistory() {
    const select = qs("#cw-issue");
    issues.forEach(issue => {
      const opt = el("option","",issue.title);
      opt.value = issue.issue_id;
      select.append(opt);
    });
    select.value = config.issue;
    select.addEventListener("change", () => { config.issue = select.value; renderHistory(); });
    qs("#cw-seat").addEventListener("change",event => {
      config.seat = event.target.value;
      renderHistory();
    });
    qs("#cw-exact").addEventListener("change",event => {
      config.onlyExact = event.target.checked;
      renderHistory();
    });
    document.querySelectorAll("[data-choice]").forEach(button => button.addEventListener("click", () => {
      userAnswers[config.issue] = button.dataset.choice;
      renderProfile();
    }));
    qs("#cw-clear-preferences").addEventListener("click",() => {
      Object.keys(userAnswers).forEach(key => delete userAnswers[key]);
      renderProfile();
    });
    renderHistory();
  }

  /* Deliberately unvalidated archetype exercise: descriptive only, no persuasion or prediction. */
  const quiz = [
    ["gov", 1,"Should a fictional municipality operate public recreation facilities using its budget?"],
    ["level", 1,"Should a fictional city decide how its own parks are managed?"],
    ["change",1,"Should a fictional institution pilot a revised public meeting process?"],
    ["gov",-1,"Should a fictional municipality limit its direct role in operating commercial venues?"],
    ["level",-1,"Should a fictional national body set one uniform infrastructure reporting format?"],
    ["gov",1,"Should a fictional government invest in publicly operated transit routes?"],
    ["change",-1,"Should a fictional institution retain its existing committee rules until a scheduled review?"],
    ["level",1,"Should fictional municipal departments choose local approaches to accessibility upgrades?"],
    ["gov",-1,"Should fictional public facilities be managed through private contracts when feasible?"],
    ["change",1,"Should a fictional student council experiment with a new participatory budgeting process?"],
    ["gov",1,"Should a fictional government directly fund community housing services?"],
    ["level",-1,"Should a fictional national law specify uniform requirements for government data publication?"],
    ["change",-1,"Should a fictional institution make small procedural changes before considering a complete redesign?"],
    ["gov",-1,"Should a fictional municipality prefer voluntary agreements to new public service programs?"],
    ["level",1,"Should a fictional city decide its own street-design priorities?"],
    ["gov",1,"Should a fictional government offer a public broadband service?"],
    ["change",1,"Should a fictional legislative body replace manual amendment tracking with a new audited workflow?"],
    ["level",-1,"Should a fictional national authority establish consistent public-record accessibility rules?"],
    ["gov",-1,"Should a fictional government minimize direct operation of new facilities?"],
    ["change",-1,"Should a fictional charter be amended only after a lengthy public review period?"]
  ];
  const archetypes = {
    "limited-local-gradual":"The Local Steward",
    "limited-local-reform":"The Local Reformer",
    "limited-national-gradual":"The Constitutional Minimalist",
    "limited-national-reform":"The Lean-System Reformer",
    "mixed-local-gradual":"The Community Pragmatist",
    "mixed-local-reform":"The Community Builder",
    "mixed-national-gradual":"The Institutional Balancer",
    "mixed-national-reform":"The Civic Modernizer",
    "active-local-gradual":"The Municipal Steward",
    "active-local-reform":"The Local Investment Advocate",
    "active-national-gradual":"The Public Program Steward",
    "active-national-reform":"The National Renewal Advocate"
  };
  let quizIndex = 0;
  let answers = [];
  let resultSummary = "";
  const axisMean = axis => {
    const relevant = quiz.map((q,i) => ({q,a:answers[i]}))
      .filter(row => row.q[0] === axis && typeof row.a === "number" && row.a !== 0);
    if (!relevant.length) return null;
    return relevant.reduce((total,row) => total + row.a * row.q[1],0)/relevant.length;
  };
  const classify = values => {
    if (values.gov === null || values.level === null || values.change === null) return null;
    const gov = values.gov <= -0.25 ? "limited" : values.gov >= 0.25 ? "active" : "mixed";
    const level = values.level >= 0 ? "local" : "national";
    const change = values.change >= 0 ? "reform" : "gradual";
    return {gov,level,change,key:gov+"-"+level+"-"+change};
  };
  function showQuizStep() {
    qs("#cw-quiz-start").hidden = true;
    qs("#cw-quiz-result").hidden = true;
    qs("#cw-quiz-step").hidden = false;
    qs("#cw-quiz-number").textContent = "Question " + (quizIndex + 1) + " of " + quiz.length;
    qs("#cw-quiz-progress-label").textContent = String(Math.round(100*quizIndex/quiz.length))+"% complete";
    qs("#cw-quiz-progress").value = quizIndex;
    qs("#cw-quiz-question").textContent = quiz[quizIndex][2];
  }
  function startQuiz() {
    quizIndex = 0;answers = [];
    showQuizStep();
  }
  function completeQuiz() {
    const scores = {gov:axisMean("gov"),level:axisMean("level"),change:axisMean("change")};
    const result = classify(scores);
    const answered = answers.filter(a => typeof a === "number" && a !== 0).length;
    qs("#cw-quiz-step").hidden = true;
    qs("#cw-quiz-result").hidden = false;
    if (!result) {
      qs("#cw-quiz-archetype").textContent = "Insufficient information";
      resultSummary = "My Commonwealth Discover result was inconclusive. This fictional exercise does not infer missing positions.";
      qs("#cw-quiz-description").textContent =
        "At least one dimension has no directional responses. No archetype is assigned from missing evidence.";
    } else {
      const label = archetypes[result.key];
      qs("#cw-quiz-archetype").textContent = label;
      qs("#cw-quiz-description").textContent =
        "Your answers suggest a " + result.gov + " government role, " + result.level +
        " decision-making emphasis, and a " + result.change + "-oriented approach to institutional change. These are illustrative categories, not validated traits or legislative vote predictions.";
      resultSummary = "My fictional Commonwealth Discover archetype: " + label +
        ". Illustrative, unvalidated civic exercise. No vote cast.";
    }
    qs("#cw-quiz-coverage").textContent = answered+" directional answer(s) / "+quiz.length+
      " questions. Missing and neutral answers do not become inferred preferences. No results were saved.";
    qs("#cw-quiz-feedback").textContent = "";
  }
  function chooseQuiz(value) {
    answers.push(value === "skip" ? null : Number(value));
    quizIndex += 1;
    if (quizIndex === quiz.length) completeQuiz();
    else showQuizStep();
  }
  function initQuiz() {
    qs("#cw-start-quiz").addEventListener("click",startQuiz);
    qs("#cw-quiz-restart").addEventListener("click",startQuiz);
    qs("#cw-quiz-again").addEventListener("click",startQuiz);
    document.querySelectorAll("[data-quiz-choice]").forEach(button =>
      button.addEventListener("click",() => chooseQuiz(button.dataset.quizChoice)));
    qs("#cw-copy-archetype").addEventListener("click", async () => {
      try {
        if (!navigator.clipboard) throw new Error("Clipboard unavailable");
        await navigator.clipboard.writeText(resultSummary+" "+location.href);
        qs("#cw-quiz-feedback").textContent = "Result label copied. Individual answers were not included.";
      } catch (_) {
        qs("#cw-quiz-feedback").textContent = "Clipboard unavailable in this browser. You can select and copy your archetype above.";
      }
    });
    qs("#cw-share-archetype").addEventListener("click",async () => {
      if (navigator.share) {
        try {
          await navigator.share({title:"Commonwealth Discover",text:resultSummary,url:location.href});
          qs("#cw-quiz-feedback").textContent = "Only the archetype summary was offered for sharing.";
        } catch (_) {
          qs("#cw-quiz-feedback").textContent = "Sharing cancelled or unavailable. No answers were submitted.";
        }
      } else qs("#cw-quiz-feedback").textContent = "Native sharing is unavailable. Use Copy result summary instead.";
    });
  }
  const stages = [
    "A fictional human representative drafts a proposal. Source and version are identified.",
    "The text is amended. Prior versions remain inspectable, and authorizations are reconsidered.",
    "A fictional assembly deliberates under its declared procedural rules.",
    "Only a version-locked, eligible DEMO ballot is shown. No binding or secret election happens on this page.",
    "A separate checker replays the fictional evidence and reports its limits.",
    "Two fictional reviewers authorize a sanitized publication preview; there is no real-world effect."
  ];
  let step = 0;
  function renderWorkflow() {
    qs("#cw-workflow-copy").textContent = stages[step];
    document.querySelectorAll("#cw-workflow-steps li").forEach((item,i)=>
      item.setAttribute("data-active",String(i===step)));
    qs("#cw-next-step").disabled = step===stages.length-1;
  }
  function initWorkflow() {
    qs("#cw-next-step").addEventListener("click",() => {step=Math.min(stages.length-1,step+1);renderWorkflow();});
    qs("#cw-reset-steps").addEventListener("click",() => {step=0;renderWorkflow();});
    renderWorkflow();
  }
  window.COMMONWEALTH_DEMO_LOGIC = Object.freeze({tenureAt,recordPosition,questionLinks,resolveMembers,classify,quizCount:quiz.length,archetypeCount:Object.keys(archetypes).length});
  // Allow DOM-free, independent model tests; no hidden network or storage setup.
  if (typeof document === "undefined" || !document.querySelector || !document.querySelector("#cw-issue")) return;
  initHistory();initQuiz();initWorkflow();
})();
