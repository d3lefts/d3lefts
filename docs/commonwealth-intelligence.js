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
  let quizInsight = null;
  const setGuide = (stage, message) => {
    const notice = document.querySelector("#cw-guide-status");
    if (notice) notice.textContent = message;
    document.querySelectorAll("[data-cw-guide-link]").forEach(link => {
      if (link.dataset.cwGuideLink === stage) link.setAttribute("aria-current","step");
      else link.removeAttribute("aria-current");
    });
  };
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
    qs("#cw-profile-insight").textContent = quizInsight ||
      "No quiz result added. Your answers to policies stay separate from archetype descriptions.";
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
      setGuide("profile","PROFILE UPDATED · Explicit hypothetical preference recorded in this page only; no ballot was cast.");
    }));
    qs("#cw-clear-preferences").addEventListener("click",() => {
      Object.keys(userAnswers).forEach(key => delete userAnswers[key]);
      quizInsight = null;
      renderProfile();
      setGuide("profile","PROFILE CLEARED · No policy answers or Discover insight remain in this page.");
    });
    renderHistory();
  }

  /* Illustrative political THEMES, not a psychological diagnosis or policy-vote prediction.
   * Source catalog: docs/commonwealth-archetypes.js; no fetch, no storage or external profile API. */
  const profiles=window.COMMONWEALTH_ARCHETYPES||[];
  const quiz=[
  {
    "tags": [
      "tech-reformist"
    ],
    "text": "Should a fictional city put permit applications and their status online for public inspection?"
  },
  {
    "tags": [
      "civic-creator"
    ],
    "text": "Should a fictional student assembly let volunteers propose items for a public agenda?"
  },
  {
    "tags": [
      "climate-guardian"
    ],
    "text": "Should a fictional municipality offer incentives for energy-efficient public buildings?"
  },
  {
    "tags": [
      "liberty-defender"
    ],
    "text": "Should a fictional institution require independent authorization before accessing private digital messages?"
  },
  {
    "tags": [
      "equality-champion"
    ],
    "text": "Should a fictional transit service prioritize accessibility for people with disabilities?"
  },
  {
    "tags": [
      "working-american"
    ],
    "text": "Should a fictional city co-fund apprenticeships with local employers?"
  },
  {
    "tags": [
      "community-builder"
    ],
    "text": "Should a fictional neighborhood choose some street improvements through participatory budgeting?"
  },
  {
    "tags": [
      "global-minded"
    ],
    "text": "Should a fictional national agency join international disaster-preparedness exercises?"
  },
  {
    "tags": [
      "security-sentinel"
    ],
    "text": "Should a fictional municipality routinely practice emergency response and cybersecurity drills?"
  },
  {
    "tags": [
      "care-advocate"
    ],
    "text": "Should a fictional county fund a clinic with extended evening hours?"
  },
  {
    "tags": [
      "opportunity-builder"
    ],
    "text": "Should a fictional city simplify licensing for small, low-risk businesses?"
  },
  {
    "tags": [
      "balanced-pragmatist"
    ],
    "text": "Should a fictional public program have a published evaluation and a scheduled review date?"
  },
  {
    "tags": [
      "tech-reformist",
      "balanced-pragmatist"
    ],
    "text": "Should a fictional city publish budget data in a machine-readable format with independent audits?"
  },
  {
    "tags": [
      "civic-creator",
      "community-builder"
    ],
    "text": "Should a fictional student government allocate a small budget through an open campus proposal process?"
  },
  {
    "tags": [
      "climate-guardian",
      "security-sentinel"
    ],
    "text": "Should a fictional coastal town reinforce stormwater systems against future flooding?"
  },
  {
    "tags": [
      "liberty-defender"
    ],
    "text": "Should a fictional city require judicial approval before police access sensitive personal location records?"
  },
  {
    "tags": [
      "equality-champion",
      "care-advocate"
    ],
    "text": "Should a fictional public clinic offer services in formats accessible to people with different needs?"
  },
  {
    "tags": [
      "working-american",
      "community-builder"
    ],
    "text": "Should a fictional municipality offer locally delivered skills training with public reporting on outcomes?"
  },
  {
    "tags": [
      "global-minded",
      "liberty-defender"
    ],
    "text": "Should a fictional international research partnership share public data only under explicit privacy protections?"
  },
  {
    "tags": [
      "opportunity-builder",
      "balanced-pragmatist"
    ],
    "text": "Should a fictional city pilot a simpler business registration rule and publicly evaluate its effects?"
  }
];
  const defaultKey="balanced-pragmatist"; // A sample badge when no supported issue-theme alignment exists.
  let quizIndex=0,answers=[],resultSummary="";
  function qualifyQuiz(samples) {
    const counts={directional:0,neutral:0,skipped:0};
    const supportedTopics=new Set();
    quiz.forEach((q,i)=>{
      const a=samples[i];
      if (a===1||a===-1){counts.directional++;q.tags.forEach(t=>supportedTopics.add(t));}
      else if(a===0)counts.neutral++;
      else counts.skipped++;
    });
    return {eligible:counts.directional>=12&&supportedTopics.size>=6,
      answered:counts.directional,counts,topics:supportedTopics.size,
      coverage:counts.directional===0?"starter":counts.directional<12?"early-preview":"exploratory"};
  }
  function pickArchetype(samples) {
    const quality=qualifyQuiz(samples);
    // Only explicit directional responses are counted. Missing and neutral do not become positions.
    const totals=new Map(profiles.map(p=>[p.key,{sum:0,opportunities:0}]));
    quiz.forEach((q,i)=>{
      const a=samples[i];if(a!==1&&a!==-1)return;
      for(const key of q.tags){const row=totals.get(key);if(row){row.sum+=a;row.opportunities++;}}
    });
    let ranked=profiles.map(p=>({p,...(totals.get(p.key)||{sum:0,opportunities:0})}))
      .filter(x=>x.sum>0);
    ranked.sort((a,b)=>(b.sum-b.sum)-(a.sum-a.sum)||b.sum-a.sum||b.opportunities-a.opportunities||a.p.key.localeCompare(b.p.key));
    const winner=ranked[0]?.p||profiles.find(p=>p.key===defaultKey);
    if(!winner)throw new Error("Missing Commonwealth archetype catalog");
    const tieCount=ranked.filter(x=>x.sum===ranked[0]?.sum).length;
    return {profile:winner,starter:!ranked.length,quality,tieCount,
      mode:!ranked.length?"STARTER BADGE":quality.eligible?"ILLUSTRATIVE MATCH":"EARLY PREVIEW"};
  }
  function initArchetypeGallery(){
    const grid=qs("#cw-archetype-gallery");
    if(!grid)return;
    for(const p of profiles){
      const card=document.createElement("article");
      card.className="cw-archetype-card";
      card.style.setProperty("--cw-card",p.color);
      const img=document.createElement("img");
      img.loading="lazy";img.decoding="async";img.src=p.art;img.alt=p.name+" illustration";
      const copy=document.createElement("div");copy.className="cw-archetype-copy";
      const category=document.createElement("span");category.className="cw-archetype-category";category.textContent=p.category;
      const h=document.createElement("h3");h.textContent=p.name;
      const desc=document.createElement("p");desc.textContent=p.description;
      copy.append(category,h,desc);card.append(img,copy);grid.append(card);
    }
  }
  function showQuizStep() {
    qs("#cw-quiz-start").hidden = true;
    qs("#cw-quiz-result").hidden = true;
    qs("#cw-quiz-step").hidden = false;
    qs("#cw-quiz-number").textContent = "Question " + (quizIndex + 1) + " of " + quiz.length;
    qs("#cw-quiz-progress-label").textContent = String(Math.round(100*quizIndex/quiz.length))+"% complete";
    qs("#cw-quiz-progress").value = quizIndex;
    qs("#cw-quiz-question").textContent = quiz[quizIndex].text;
    qs("#cw-quiz-back").disabled = quizIndex === 0;
  }
  function startQuiz() {
    quizIndex = 0;answers = [];
    resultSummary = "";
    showQuizStep();
    setGuide("discover","DISCOVER IN PROGRESS · Answer, skip, or revisit any question. No responses leave this page.");
  }
  function completeQuiz() {
    const result = pickArchetype(answers);
    const quality = result.quality;
    const answered = quality.answered;
    qs("#cw-quiz-step").hidden = true;
    qs("#cw-quiz-result").hidden = false;
    const name=result.profile.name;
    qs("#cw-quiz-archetype").textContent=name;
    qs("#cw-quiz-art").src=result.profile.art;
    qs("#cw-quiz-art").alt=result.profile.name+" illustrated civic sticker";
    qs("#cw-quiz-result-card").style.setProperty("--cw-card",result.profile.color);
    qs("#cw-quiz-mode").textContent=result.mode;
    qs("#cw-quiz-description").textContent=result.profile.description;
    qs("#cw-quiz-coverage").textContent=answered+" directional answer(s) of "+quiz.length+
      " · "+quality.counts.neutral+" no-preference · "+quality.counts.skipped+
      " skipped. "+(result.starter?"No thematic match is asserted. This is a sample collectible badge.":
      quality.eligible?"An illustrative topical match, not a validated political identity.":
      "An early preview; unanswered topics have not been inferred.");
    qs("#cw-quiz-scope").textContent=result.starter?
      "STARTER PICK · No position was inferred. All 12 cards are available to explore.":
      "ILLUSTRATIVE · "+(result.tieCount>1?"Other themes also matched. ":"")+
      "Only answers you explicitly gave were scored. Not a real vote, scientific diagnosis, or official political classification.";
    resultSummary="Commonwealth Discover: "+name+
      " — "+result.profile.tagline+" Illustrative civic sticker, not a vote or validated political profile.";
    qs("#cw-apply-archetype").disabled=false; // user may explicitly save even a clearly identified starter badge
    setGuide("discover",result.starter?
      "DISCOVER COMPLETE · Your sample sticker is ready. No political preference was inferred.":
      "DISCOVER COMPLETE · Your illustrative sticker is ready; optional profile addition requires a click.");
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
    qs("#cw-quiz-back").addEventListener("click",() => {
      if (quizIndex === 0) return;
      quizIndex -= 1;
      answers.pop();
      showQuizStep();
    });
    qs("#cw-quiz-again").addEventListener("click",startQuiz);
    qs("#cw-apply-archetype").addEventListener("click",() => {
      if (qs("#cw-apply-archetype").disabled || !resultSummary) return;
      quizInsight = resultSummary;
      renderProfile();
      setGuide("profile","PROFILE INSIGHT ADDED · The quiz provides a provisional descriptor, NOT a vote or an inferred policy position.");
      qs("#profile").scrollIntoView({behavior:"auto",block:"start"});
    });
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
  function initMenu(){
    const button=qs("#menu-button"),nav=qs("#site-nav");
    if(!button||!nav)return;
    const close=()=>{
      nav.classList.remove("open");
      button.setAttribute("aria-expanded","false");
      button.textContent="MENU +";
    };
    button.addEventListener("click",()=>{
      const open=nav.classList.toggle("open");
      button.setAttribute("aria-expanded",String(open));
      button.textContent=open?"CLOSE −":"MENU +";
    });
    nav.querySelectorAll("a").forEach(link=>link.addEventListener("click",close));
    document.addEventListener("keydown",event=>{
      if(event.key==="Escape"&&nav.classList.contains("open")){close();button.focus();}
    });
    document.addEventListener("click",event=>{
      if(nav.classList.contains("open")&&!nav.contains(event.target)&&!button.contains(event.target))close();
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
  window.COMMONWEALTH_DEMO_LOGIC = Object.freeze({tenureAt,recordPosition,questionLinks,resolveMembers,qualifyQuiz,pickArchetype,quizCount:quiz.length,archetypeCount:profiles.length});
  // Allow DOM-free, independent model tests; no hidden network or storage setup.
  if (typeof document === "undefined" || !document.querySelector || !document.querySelector("#cw-issue")) return;
  initMenu();initHistory();initQuiz();initWorkflow();initArchetypeGallery();
})();
