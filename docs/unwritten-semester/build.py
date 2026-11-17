#!/usr/bin/env python3
"""Build static course pages. One-time dependency: mistune (not needed to view)."""
from pathlib import Path
from html import escape
import re
import mistune

BASE = Path(__file__).resolve().parent
LESSONS = [
 ('01','The research problem as a contract','Frame','Write a falsifiable claim, explicit scope, baseline, and disproof condition.','90 min · lab 2h'),
 ('02','Boundaries, actors & the operational world','Frame','Build mission-centered contexts and operational scenarios without losing authority.','90 min · lab 2h'),
 ('03','Requirements that can actually fail','Frame','Translate stakeholder intent into testable, versioned traceability.','90 min · lab 2h'),
 ('04','Architecture is a dependency hypothesis','Model','Expose interfaces, hidden common causes, and change propagation.','90 min · lab 3h'),
 ('05','Models, abstractions & digital threads','Model','Connect analytic, executable, and operational models without false equivalence.','90 min · lab 2h'),
 ('06','Experiments designed to disprove you','Model','Preregister paired experiments and distinguish simulation from replication.','90 min · lab 3h'),
 ('07','Uncertainty, decisions & information value','Model','Compute the value of measurements relative to possible decisions.','90 min · lab 3h'),
 ('08','Optimization beyond the winning score','Model','Map Pareto tradeoffs, constraints, and robustness under uncertainty.','90 min · lab 3h'),
 ('09','Verification, validation & proof passports','Verify','Build scoped claim–argument–evidence chains and independent checks.','90 min · lab 3h'),
 ('10','Safety, security & graceful failure','Verify','Connect hazards, attack models, common causes, and recovery.','90 min · lab 3h'),
 ('11','Causality, observability & impossible knowledge','Verify','Detect observationally indistinguishable worlds before optimizing.','90 min · lab 3h'),
 ('12','Change, provenance & recertification','Verify','Trace exactly which evidence may expire after a system revision.','90 min · lab 3h'),
 ('13','Reproducible research as infrastructure','Transfer','Package sources, data, runtime, checks, and limitations for replay.','90 min · lab 3h'),
 ('14','Dissertation defense as adversarial review','Transfer','Defend the smallest honest contribution and preserve unresolved objections.','90 min · lab 3h'),
]
PHASES = [('Frame','01 / DEFINE','Make the question fit a decision.','What would count as an answer, and who gets to decide?'),
          ('Model','02 / CONSTRUCT','Make assumptions visible.','Build models and experiments whose limits are legible.'),
          ('Verify','03 / ATTACK','Make evidence survive criticism.','Test models, hazards, changing versions, and assurance claims.'),
          ('Transfer','04 / DEFEND','Make results reusable.','Release research that a stranger can reproduce and challenge.')]
PHASE_SLUG = {x[0]:x[0].lower() for x in PHASES}
KEYWORDS = {
 '01':'research thesis doctoral question hypothesis novelty prior art falsification contract',
 '02':'stakeholder authority human social system boundaries conops context mission',
 '03':'requirements traceability verification matrix acceptance',
 '04':'system architecture interface coupling reliability dependency dsm common-mode',
 '05':'model-based systems engineering mbse digital twin modeling simulation abstraction',
 '06':'experiment reproducibility statistical design paired trial science preregistration',
 '07':'decision theory uncertainty bayesian value information voi posterior probability',
 '08':'optimization pareto trade study robust frontier resource allocation',
 '09':'assurance evidence proof passport validation verification certification certificate',
 '10':'safety cybersecurity security resilience hazards threat modeling attack',
 '11':'causal inference identifiability observability impossibility epistemic information',
 '12':'lifecycle change recertification configuration evidence dependency version',
 '13':'reproducibility data management provenance github automation shell python version control',
 '14':'dissertation writing defense committee oral examination peer review novelty' }

MARKDOWN = mistune.create_markdown(plugins=['table','strikethrough','url'])


def render_markdown(md):
    html = MARKDOWN(md)
    count = [0]
    toc = []
    def heading(m):
        tag, inside = m.group(1), m.group(2)
        label = re.sub('<[^>]+>', '', inside).replace('&amp;', '&')
        slug = re.sub(r'[^a-z0-9-]+','-',label.lower()).strip('-')
        count[0] += 1
        slug = slug or 'section-'+str(count[0])
        if tag == 'h2': toc.append((slug, label))
        return f'<{tag} id="{escape(slug)}">{inside}</{tag}>'
    html = re.sub(r'<(h[23])>(.*?)</h[23]>',heading,html,flags=re.DOTALL)
    return html,toc


def header(root, current):
    links=[('Sessions',root+'index.html#sessions','sessions'),('Field exercise',root+'capstone.html','capstone'),
           ('Library',root+'resources.html','resources'),('Toolkit',root+'toolkit.html','toolkit'),('About',root+'about.html','about')]
    nav=''.join(f'<a href="{url}" class="{ "active" if current==target else "" }">{label}</a>' for label,url,target in links)
    return f'''<a class="skip" href="#content">Skip to content</a><header class="site-header"><div class="wrap nav">
    <a href="{root}index.html" class="brand" aria-label="The Unwritten Semester, home"><span class="mark" aria-hidden="true">✳</span><span>UNWRITTEN<small>THE SYSTEMS SEMESTER</small></span></a>
    <nav class="nav-links" aria-label="Main navigation">{nav}</nav></div></header>'''


def footer(root):
    return f'''<footer class="wrap footer"><span>Independent open course · doctoral research-skills supplement · no degree or certification granted</span>
    <span>Format inspired by <a href="https://missing.csail.mit.edu/" target="_blank" rel="noopener noreferrer">MIT's Missing Semester</a> · <a href="{root}LICENSE.md">Licenses</a></span></footer>'''


def page(title, description, root, current, body, script=True):
    return f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>{escape(title)} · The Unwritten Semester</title><meta name="description" content="{escape(description,quote=True)}"><meta name="theme-color" content="#0e1117">
<link rel="stylesheet" href="{root}assets/site.css"></head><body>{header(root,current)}<main id="content">{body}</main>{footer(root)}
{f'<script src="{root}assets/site.js" defer></script>' if script else ''}</body></html>'''


def homepage():
    hero='''<div class="wrap hero"><div><div class="eyebrow">OPEN FIELD COURSE / DOCTORAL SYSTEMS ENGINEERING</div>
<h1>Engineering is hard.<br><em>Knowing</em> is harder.</h1>
<p class="lead">Your degree teaches theory, design, and analysis. But who teaches you to make an assumption auditable, an experiment decisive, a certificate transferable, or a dissertation defensible? This is the unwritten part.</p>
<div class="hero-actions"><a class="button primary" href="#sessions">Explore the 14 sessions <span aria-hidden="true">↗</span></a><a class="button" href="capstone.html">Open the AURORA lab</a></div></div>
<div class="blueprint" role="img" aria-label="Four-part research loop: frame a claim, build a model, challenge evidence, transfer the result">
<div class="blueprint-inner"><div class="bp-head"><span>SYSTEM / RESEARCH METHOD</span><span>R.01—R.14</span></div><div class="bp-label">// CLAIM-TO-CERTIFICATE PIPELINE</div>
<div class="bp-nodes"><div class="bp-node"><span>01 / FRAME</span><b>What is the<br>actual claim?</b></div><div class="bp-node"><span>02 / MODEL</span><b>What assumptions<br>create the answer?</b></div>
<div class="bp-node"><span>03 / VERIFY</span><b>What would<br>break the result?</b></div><div class="bp-node"><span>04 / TRANSFER</span><b>What can another<br>person reuse?</b></div></div>
<div class="bp-footer"><span>OUTPUT: DEFENSIBLE EVIDENCE</span><span>↳ REVISION-AWARE</span></div></div></div></div>'''
    tally='''<div class="wrap tally"><div><b>14</b><span>Source-backed sessions</span></div><div><b>01</b><span>Shared synthetic system</span></div><div><b>0</b><span>External libraries required in the lab</span></div></div>'''
    intro='''<div class="wrap intro-section"><div><div class="section-kicker">THE IDEA</div><h2 class="section-title">The invisible curriculum.</h2></div><div><p>Standards describe what engineers should do. Graduate coursework teaches models and methods. Research is where those abstractions collide with incomplete evidence, organizational authority, shifting assumptions, and hostile scrutiny.</p><p>This independent course trains the connective discipline: how to move from a consequential decision to a bounded claim, from a model to an experiment, and from evidence to a defensible research contribution.</p></div></div>
<div class="wrap principles"><div class="principle"><span>01 / REPRESENT</span><h3>State it exactly.</h3><p>Define the world, units, hypotheses, baseline, and falsifier before solving.</p></div><div class="principle"><span>02 / CHALLENGE</span><h3>Attack your own result.</h3><p>Use paired tests, counterexamples, independent checks, and changes in assumptions.</p></div><div class="principle"><span>03 / PRESERVE</span><h3>Make truth travel.</h3><p>Keep the source, proof or evidence, version, limitations, and next experiment together.</p></div></div>'''
    rows=[]
    for ph, code, tagline, detail in PHASES:
        content=''.join(f'''<a class="lesson-row" href="lectures/{num}.html" data-lesson data-phase="{ph.lower()}" data-search-keywords="{KEYWORDS[num]}">
<span class="num">{num} / 14</span><h4>{escape(name)} <span class="arrow" aria-hidden="true">↗</span></h4><p>{escape(desc)}</p>
<span class="time" data-done-indicator="{num}">○ Open lesson</span></a>''' for num,name,phase,desc,time in LESSONS if phase==ph)
        rows.append(f'''<section class="chapter" data-group><div class="chapter-head"><h3>{escape(code)} <span style="color:var(--mint)">— {escape(tagline)}</span></h3><span>{escape(detail)}</span></div>{content}</section>''')
    catalog='''<div class="wrap catalog" id="sessions"><div class="catalog-heading"><div><div class="section-kicker">COURSE INDEX</div><h2 class="section-title">Choose a fault line.</h2></div>
<div class="progress-box" aria-label="Course completion"><div class="progress-copy"><span>YOUR LOCAL PROGRESS</span><span data-progress-num>0/14</span></div><div class="progress-bar"><div class="progress-fill" data-progress-fill></div></div></div></div>
<div class="catalog-controls"><input class="search" type="search" data-search aria-label="Search sessions" placeholder="Search sessions, methods, artifacts…">
<div class="filters" aria-label="Filter sessions"><button class="filter active" data-filter="all" aria-pressed="true">All</button><button class="filter" data-filter="frame" aria-pressed="false">Frame</button><button class="filter" data-filter="model" aria-pressed="false">Model</button><button class="filter" data-filter="verify" aria-pressed="false">Verify</button><button class="filter" data-filter="transfer" aria-pressed="false">Transfer</button></div></div>'''+''.join(rows)+'''<p data-empty hidden>No sessions match that search.</p>
<div class="landing-capstone"><div><span class="pill">FINAL FIELD EXERCISE</span><h3>AURORA: a research case you can actually audit.</h3><p>Three synthetic sensors. A common-mode fault. Conflicting objectives. One decision, one trace, and many chances to be wrong.</p></div><a class="button" href="capstone.html">View capstone ↗</a></div></div>'''
    toolkit='''<div class="wrap closing field-tools"><div><div class="section-kicker">EXECUTABLE FIELD METHODS</div><h2>Make the reasoning runnable.</h2></div><div><p>Paired policy comparisons, exhaustive finite-state checks, SHA-256 evidence passports, and change-impact analysis. Four linked practicums with explicit failure tests.</p><div class="hero-actions"><a class="button primary" href="toolkit.html">Open research toolkit ↗</a><a class="button" href="math-bridge.html">Doctoral mathematics bridge ↗</a></div></div></div>'''
    closing='''<div class="wrap closing"><div><div class="section-kicker">THE STANDARD</div><h2>Not just a result.<br>A result that survives.</h2></div><div><p>A defensible research result should be explicit enough to reconstruct, narrow enough to falsify, and packaged so its limits survive revision and reuse.</p><p>The course is a graduate research supplement, not an accredited doctoral degree. It assumes mathematical depth and disciplinary supervision outside these pages.</p><a href="about.html" class="button">Read the teaching philosophy ↗</a></div></div>'''
    return page('Systems Engineering at the Research Frontier','A practical, independently authored doctoral-level systems engineering field course. 14 sessions, runnable AURORA capstone, research templates.', '', 'sessions',hero+tally+intro+toolkit+catalog+closing)


def sub_page(filename, title, kicker, description, active):
    source = (BASE / filename).read_text()
    html,toc=render_markdown(source)
    head=f'<div class="wrap pagehead"><div class="breadcrumb"><a href="index.html">HOME</a> / {escape(kicker.upper())}</div><div class="eyebrow" style="margin-top:17px">{escape(kicker)}</div><h1>{escape(title)}</h1><p class="description">{escape(description)}</p></div>'
    aside=''.join(f'<li><a href="#{slug}">{escape(label)}</a></li>' for slug,label in toc)
    body=head+f'<div class="wrap article-layout"><article class="article">{html}</article><aside class="rail"><div class="rail-box"><h3>On this page</h3><ul class="contents">{aside}</ul><a class="button" href="index.html#sessions">← Full course index</a></div></aside></div>'
    (BASE / (filename.replace('.md','.html').lower().replace('_','-'))).write_text(page(title,description,'',active,body),encoding='utf-8')


def lecture_page(i):
    num, title, phase, description, duration=i
    html,toc=render_markdown((BASE/'lectures'/f'{num}.md').read_text())
    ix=LESSONS.index(i)
    prev=f'<a href="{LESSONS[ix-1][0]}.html">← Previous: {escape(LESSONS[ix-1][1])}</a>' if ix else '<a href="../index.html#sessions">← Course index</a>'
    nxt=f'<a href="{LESSONS[ix+1][0]}.html">Next: {escape(LESSONS[ix+1][1])} →</a>' if ix<len(LESSONS)-1 else '<a href="../capstone.html">Final field exercise →</a>'
    head=f'''<div class="wrap pagehead"><div class="breadcrumb"><a href="../index.html#sessions">ALL SESSIONS</a> / {escape(phase.upper())} / {num}</div>
<div class="eyebrow" style="margin-top:17px">SESSION {num} / 14 — {escape(phase.upper())}</div><h1>{escape(title)}</h1>
<p class="description">{escape(description)}</p><div class="tags"><span>{escape(duration)}</span><span>LECTURE + LAB + ADVERSARIAL CHECK</span><span>NO PREREQUISITE INSTALLS</span></div></div>'''
    items=''.join(f'<li><a href="#{slug}">{escape(label)}</a></li>' for slug,label in toc)
    body=f'''{head}<div class="wrap article-layout"><article class="article">{html}
<div class="lesson-nav">{prev}{nxt}</div></article>
<aside class="rail"><div class="rail-box"><h3>Session navigation</h3><ul class="contents">{items}</ul>
<button class="complete" data-toggle-complete="{num}" type="button">Mark this session complete</button>
<p style="font-size:11px;color:var(--dim);margin:13px 0 0">Progress is stored in this browser only. Completing a lesson is self-reported, not a credential.</p>
<div style="border-top:1px solid var(--line);margin:18px 0;padding-top:17px"><h3>Working materials</h3>
<ul><li><a href="../capstone.html">AURORA field exercise ↗</a></li><li><a href="../toolkit.html">Executable toolkit ↗</a></li><li><a href="../math-bridge.html">Quantitative foundations ↗</a></li><li><a href="../resources.html">Reference library ↗</a></li><li><a href="../README.md">Repository instructions ↗</a></li></ul></div></div></aside></div>'''
    (BASE/'lectures'/f'{num}.html').write_text(page(title,description,'../','sessions',body),encoding='utf-8')


def main():
    (BASE/'index.html').write_text(homepage(),encoding='utf-8')
    for lesson in LESSONS: lecture_page(lesson)
    sub_page('CAPSTONE.md','AURORA / The final field exercise','A SHARED SYNTHETIC RESEARCH SYSTEM','Turn the full course into one auditable systems engineering research case.','capstone')
    sub_page('RESOURCES.md','The reference library','PRIMARY SOURCES & WORKING TOOLS','Foundational systems-engineering references, competency map, and method limits.','resources')
    sub_page('TOOLKIT.md','The executable research toolkit','FOUR FIELD PRACTICUMS','From paired comparison to exhaustive checks, manifests, and revalidation.','toolkit')
    sub_page('MATH_BRIDGE.md','The quantitative foundations bridge','DOCTORAL TECHNICAL DEPTH','Mathematical foundations, exact micro-proofs, and oral qualifying exercises.','toolkit')
    sub_page('ABOUT.md','The course behind the course','PEDAGOGY & SCOPE','Why rigorous, independently auditable research skills belong in the systems engineering curriculum.','about')
    (BASE/'assets'/'site.css').write_text((BASE/'assets'/'site.css').read_text()+'\n[hidden]{display:none!important}\n') if '[hidden]' not in (BASE/'assets'/'site.css').read_text() else None
    print('Built',len(LESSONS),'sessions + 6 main pages')


if __name__=='__main__': main()
