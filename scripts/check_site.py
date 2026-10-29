#!/usr/bin/env python3
"""Static NIGHTFALL site regression guard. Standard library only.

Checks navigation, anchors, source links, public no-JS research catalogue,
document metadata and external-link safety without a live browser/network.
"""
from __future__ import annotations
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"
PREFIX = "https://github.com/d3lefts/d3lefts"
FAILURES: list[str] = []

class Page(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()
        self.links: list[tuple[str, dict[str, str]]] = []
        self.title = False
        self.desc = False
        self.canonical = False
        self.main = False
        self.research_rows: list[str] = []

    def handle_starttag(self, tag, attrs):
        at = dict(attrs)
        if "id" in at:
            if at["id"] in self.ids:
                FAILURES.append("Duplicate HTML id: " + at["id"])
            self.ids.add(at["id"])
        if tag == "a" and "href" in at:
            self.links.append((at["href"], at))
            if "research-row" in at.get("class", "").split():
                self.research_rows.append(at["href"])
        if tag == "title":
            self.title = True
        if tag == "main":
            self.main = True
        if tag == "meta" and at.get("name") == "description":
            self.desc = True
        if tag == "link" and at.get("rel") == "canonical":
            self.canonical = True

def check_ref(src: Path, href: str, props: dict, pages: dict[Path, Page]):
    if props.get("target") == "_blank" and "noopener" not in props.get("rel", "").split():
        FAILURES.append(f"{src}: target=_blank missing rel=noopener: {href}")
    if href.startswith(("#", "./", "../")) or not re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", href):
        u = urlsplit(href)
        file = (src.parent / unquote(u.path)).resolve() if u.path else src.resolve()
        if file.is_dir():
            file = file / "index.html"
        if not file.is_file():
            FAILURES.append(f"{src}: missing local link: {href}")
            return
        if u.fragment and file.suffix == ".html":
            p = pages.get(file)
            if p and unquote(u.fragment) not in p.ids:
                FAILURES.append(f"{src}: missing anchor: {href}")
        return
    u = urlsplit(href)
    if u.scheme not in ("https", "http"):
        return
    if u.netloc == "github.com" and u.path.startswith("/d3lefts/d3lefts/"):
        m = re.match(r"^/d3lefts/d3lefts/(?:blob|tree)/main/(.+)$", u.path)
        if m:
            file = (ROOT / unquote(m.group(1))).resolve()
            if not file.exists():
                FAILURES.append(f"{src}: missing linked repository source: {href}")

def main() -> int:
    pages: dict[Path, Page] = {}
    for src in DOCS.glob("*.html"):
        p = Page()
        p.feed(src.read_text(encoding="utf-8"))
        pages[src.resolve()] = p
        for name, success in (("title", p.title), ("description", p.desc),
                              ("main", p.main), ("canonical", p.canonical)):
            if not success:
                FAILURES.append(f"{src}: missing {name}")
    for src, p in pages.items():
        for href, props in p.links:
            check_ref(src, href, props, pages)
    js = (DOCS / "site.js").read_text(encoding="utf-8")
    sources = set("https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/" + path
                  for path in re.findall(r'(?:\bpath|"path")\s*:\s*"([^"]+)"', js))
    homepage = pages[DOCS.joinpath("index.html").resolve()]
    static = set(homepage.research_rows)
    # The current editorial layout keeps the verified original-finding catalogue in
    # site.js and moves the homepage body to a separately curated library invitation.
    # Preserve the original whitelist even when that gallery is absent from HTML.
    homepage_text = (DOCS / "index.html").read_text(encoding="utf-8")
    new_library_invite = ('id="work"' in homepage_text and 'sf-library-invite' in homepage_text
                          and 'href="research.html"' in homepage_text
                          and 'href="passport.html"' in homepage_text)
    if static != sources and not (not static and new_library_invite):
        FAILURES.append(f"Research catalogue mismatch: static-only={sorted(static - sources)}, js-only={sorted(sources - static)}")
    # Public website originality rule: source archives remain broader than this list.
    allowed_originals = {
        PREFIX + "/blob/main/research/nightfall/projects/erdos-overlap-paper.md",
        PREFIX + "/blob/main/research/nightfall/projects/sidon-finite-30/README.md",
        PREFIX + "/blob/main/research/nightfall/projects/pas-overview.md",
    }
    if sources != allowed_originals or (static and static != allowed_originals) or (not static and not new_library_invite):
        FAILURES.append("ORIGINALITY GATE: public findings differ from three approved primary artifacts. "
                        "Any change requires a new dated prior-art audit and evidence review.")
    homepage_text = (DOCS / "index.html").read_text(encoding="utf-8")
    # A public, guided claim-to-replay walkthrough must use real local verifier routes.
    hub = (DOCS / "exact-research.html").read_text(encoding="utf-8")
    if ('id="guided-replay"' not in hub or
        'referee.html?domain=sidon#workbench' not in hub or
        "RESEARCH_INSTRUMENT_HANDOFF_20261028.md" not in hub or
        hub.count('class="rt-stage"') != 4):
        FAILURES.append("RESEARCH JOURNEY: source-to-replay evidence walkthrough incomplete")
    ref_js = (DOCS / "referee-app.js").read_text(encoding="utf-8")
    if 'requestedDomain === "sidon"' not in ref_js:
        FAILURES.append("RESEARCH JOURNEY: allowlisted Sidon verifier deep link absent")
    if '<b>33</b><span>Curated research documents' not in homepage_text:
        FAILURES.append("EDITORIAL: 33-document curated homepage inventory mismatch")
    # Separate working-research library: preserve originality whitelist and evidence boundaries.
    library = (DOCS / "research.html").read_text(encoding="utf-8")
    entries = re.findall(r'<article class="atlas-card" data-domain="([^"]+)" data-evidence="([^"]+)"', library)
    # Dated 33-entry ledger extends and preserves the 2026-10-28 owner-curated snapshot.
    # Check exact category/status sequence, uniqueness and every promised source.
    import json
    snapshot = ROOT / "research/nightfall/SITE_CURATED_33_20261029.json"
    curated = json.loads(snapshot.read_text(encoding="utf-8"))
    records = curated.get("entries", [])
    if len(records) < 30 or curated.get("original_findings_whitelist_count") != 3:
        FAILURES.append("RESEARCH LIBRARY: owner-curated 30+ entry source inventory or originality gate changed")
    expected = [(item.get("category"), item.get("evidence")) for item in records]
    if entries != expected:
        FAILURES.append("RESEARCH LIBRARY: HTML discipline/evidence sequence differs from owner curated ledger")
    if len({item.get("id") for item in records}) != len(records):
        FAILURES.append("RESEARCH LIBRARY: duplicate curated source identifier")
    expected_domains = {"mathematics", "quantum", "safety", "systems"}
    if {d for d, _ in entries} != expected_domains:
        FAILURES.append("RESEARCH LIBRARY: scope unexpectedly lost a research field")
    permitted_evidence = {"finite", "conditional", "working", "empirical", "software", "proposal"}
    if any(state not in permitted_evidence for _, state in entries):
        FAILURES.append("RESEARCH LIBRARY: unrecognized evidence tier")
    link_paths = re.findall(r'href="https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/([^"]+)"', library)
    if len(link_paths) < len(records) or len(set(link_paths)) < len(records):
        FAILURES.append("RESEARCH LIBRARY: each curated document needs one unique source-linked dossier")
    linked = set(link_paths)
    for row in records:
        if row.get("source") not in linked:
            FAILURES.append("RESEARCH LIBRARY: curated source missing in public HTML: " + str(row.get("source")))
    for path in link_paths:
        if not (ROOT / "research/nightfall" / path).is_file():
            FAILURES.append("RESEARCH LIBRARY: source dossier missing: " + path)
    if library.count("Evidence boundary") < len(records) or "Only three entries qualify" not in library:
        FAILURES.append("RESEARCH LIBRARY: scoped claim boundaries or original-finding distinction missing")
    if homepage_text.count('class="flagship-card ') != 4 or 'href="research.html"' not in homepage_text:
        FAILURES.append("FLAGSHIPS: four explicitly scoped research programs and library navigation required")
    if "conditional tail target" not in homepage_text or "IMPORTED THEOREMS" not in homepage_text:
        FAILURES.append("FLAGSHIPS: source-conditional theorem boundaries absent")
    if "SITE_ORIGINALITY_AUDIT_20261028.md" not in homepage_text:
        FAILURES.append("Homepage missing original-results inclusion policy")
    for removed in ("ai-safety.html", "werner.html"):
        if (DOCS / removed).exists():
            FAILURES.append(f"Removed unverified-priority portfolio page republished: {removed}")
        if 'href="' + removed + '"' in homepage_text or 'href="' + removed + '"' in js:
            FAILURES.append(f"Unoriginal promotional link returned: {removed}")
    if "research-proposal" in homepage_text or 'kind:"proposal"' in js or '"kind":"proposal"' in js:
        FAILURES.append("Untested proposals cannot appear in the public original-findings catalogue")
    # The Research Agenda is separate from the original-findings whitelist.
    agenda = (DOCS / "agenda.html").read_text(encoding="utf-8")
    proposal_source = (ROOT / "research/nightfall/projects/discovery-proposals-2026-10-28/README.md").read_text(encoding="utf-8")
    agenda_rows = re.findall('data-agenda-category="([^"]+)" href="([^"]+)"', agenda)
    agenda_categories = ["mathematics", "quantum", "super-intelligence", "safety", "systems"]
    if len(agenda_rows) != 10 or any(sum(k == cat for k, _ in agenda_rows) != 2 for cat in agenda_categories):
        FAILURES.append("AGENDA GATE: expected exactly two proposals per discipline")
    if re.findall('data-agenda-filter="([^"]+)"', agenda) != ["all", *agenda_categories]:
        FAILURES.append("AGENDA GATE: five discipline filters missing")
    if agenda.count("Research proposal · untested") != 10:
        FAILURES.append("AGENDA GATE: missing untested status")
    if proposal_source.count("## P") != 10:
        FAILURES.append("AGENDA GATE: source must have ten headings")
    if len({href for _, href in agenda_rows}) != 10:
        FAILURES.append("AGENDA GATE: proposal links must be unique")
    for code_num in range(1, 11):
        if "#p" + str(code_num).zfill(2) + "-" not in agenda:
            FAILURES.append("AGENDA GATE: missing numbered proposal anchor")
    if 'href="agenda.html"' not in homepage_text or 'src="agenda.js"' not in agenda:
        FAILURES.append("AGENDA GATE: public navigation missing")
    # Discovery Engine seeded presets are part of the public presentation.
    # Legacy locally saved browser work can survive without being featured.
    core = (DOCS / "discovery-core.js").read_text(encoding="utf-8")
    seeds = core.split("const PROJECTS=[", 1)[-1].split("].map(([id,title", 1)[0]
    ids = re.findall(r'^\["([^"]+)"', seeds, re.M)
    if ids != ["ea36", "sidon", "pas"]:
        FAILURES.append(f"ORIGINALITY GATE: Discovery presets must be ea36/sidon/pas; found {ids!r}")
    # Every public HTML page must be discoverable, and mobile menus must be wired.
    sitemap = (DOCS / "sitemap.xml").read_text(encoding="utf-8")
    actual_urls = set(re.findall(r"<loc>([^<]+)</loc>", sitemap))
    expected_urls = {
        "https://d3lefts.github.io/d3lefts/" + ("" if p.name == "index.html" else p.name)
        for p in pages
    }
    if actual_urls != expected_urls:
        FAILURES.append(f"Sitemap mismatch: missing={sorted(expected_urls - actual_urls)}, extra={sorted(actual_urls - expected_urls)}")
    for page_path, parsed in pages.items():
        src = page_path.read_text(encoding="utf-8")
        if page_path.name == "referee.html":
            # Standalone exact finite-verification tool with its own accessible
            # interaction contract. It must ship all local source dependencies.
            required = (
                'id="run-overlap"', 'id="run-sidon"', 'id="result"',
                'id="export-receipt"', 'referee-core.js',
                'referee-app.js', 'id="tab-overlap"', 'id="tab-sidon"',
                'Exact', 'finite',
            )
            if not all(token in src for token in required):
                FAILURES.append(f"{page_path}: standalone Referee evidence/workbench contract broken")
            if re.search(r'<script[^>]+src="https?://', src):
                FAILURES.append(f"{page_path}: external code not permitted in Referee")
            for script in ("referee-core.js", "referee-app.js"):
                if not (DOCS / script).is_file():
                    FAILURES.append(f"{page_path}: missing Referee local script {script}")
            continue
        if page_path.name == "claim-lab.html":
            # Claim Lab is a standalone browser-local workspace. Its own tab
            # interface intentionally has no shared global menu or site.js.
            required = (
                'id="content"', 'id="claimForm"', 'id="expForm"',
                'id="importFile"', 'id="exportBtn"',
                'aria-label="Sections"', 'nightfall_claim_lab_v1',
                'localStorage.getItem', 'localStorage.setItem',
                'illustrative demo data', 'no automated mathematical verification',
            )
            if not all(token in src for token in required):
                FAILURES.append(f"{page_path}: standalone local-first workspace contract broken")
            if re.search(r'<script[^>]+src="https?://', src):
                FAILURES.append(f"{page_path}: unexpected remotely loaded script")
            if src.find('const num=') > src.find('data=raw?normalize('):
                FAILURES.append(f"{page_path}: storage hydration precedes normalization helper")
            continue
        if page_path.name == "discovery.html":
            if not all(k in src for k in ("discovery-core.js", "discovery-app.js", "discovery.css", 'id="app"')):
                FAILURES.append("Discovery Engine dependencies / mount missing")
            continue
        if "menu-button" not in parsed.ids or "site-nav" not in parsed.ids:
            FAILURES.append(f"{page_path}: missing responsive navigation control or target")
        if not re.search(r'<script\s+src="site.js"\s+defer\s*></script>', src):
            FAILURES.append(f"{page_path}: missing shared navigation JavaScript")
    # Public source scope and verified metadata baseline.
    excluded = ("research/nightfall/projects/xi-dossier.md",
                "research/nightfall/projects/xi-continuous-shift-rank22.md",
                "research/nightfall/projects/quantum-prime-geometry/README.md")
    public_index_files = (DOCS / "index.html", DOCS / "site.js", ROOT / "research/nightfall/README.md")
    for rel in excluded:
        if (ROOT / rel).exists():
            FAILURES.append("Out-of-program source still present: " + rel)
        for page in public_index_files:
            if rel.split("research/nightfall/")[-1] in page.read_text(encoding="utf-8"):
                FAILURES.append(f"Out-of-program link in {page}: {rel}")
    pas = (ROOT / "research/nightfall/projects/pas-overview.md").read_text(encoding="utf-8")
    if not all(k in pas for k in ("8 of 20", "11 of 20", "802", "2027-04-06")):
        FAILURES.append("PAS claims/freeze protocol missing")
    rank = ROOT / "research/nightfall/projects/pas/openai_math_priority_ranking_2026-10-06.csv"
    if len(rank.read_text(encoding="utf-8").splitlines()) != 373:
        FAILURES.append("PAS frozen metadata ranking must have 372 entries")
    # Independent Python standard-library verification of the JS-generated public ranking.
    import hashlib
    import csv
    import io
    blob = rank.read_bytes()
    checksum = hashlib.sha256(blob).hexdigest()
    recorded = (rank.parent / "SHA256SUMS.txt").read_text(encoding="utf-8").split()[0]
    if checksum != recorded or checksum != "3e303b69ef8e530b5c618e61f9cb5c4527ea717b0588c59f2fb75b4afd5924e7":
        FAILURES.append("PAS public CSV SHA-256 mismatch")
    ranked = list(csv.DictReader(io.StringIO(blob.decode("utf-8"), newline="")))
    seq = ",".join(row["id"] for row in ranked)
    fnv = 0xcbf29ce484222325
    for b in seq.encode("ascii"):
        fnv = ((fnv ^ b) * 0x100000001b3) & 0xffffffffffffffff
    if len(ranked) != 372 or f"{fnv:016x}" != "c429732aac46eae9":
        FAILURES.append("PAS historical FNV ranking fingerprint mismatch")
    # User-approved October 28 Werner registry is the authoritative comparison source.
    from fractions import Fraction
    import csv as wcsv
    atlas_dir = ROOT / "research/nightfall/projects/werner-atlas"
    with (atlas_dir / "werner_registry_4_to_20.csv").open(encoding="utf-8",newline="") as stream:
        reg = list(wcsv.DictReader(stream))
    with (atlas_dir / "bounds_1_to_24.csv").open(encoding="utf-8",newline="") as stream:
        early = list(wcsv.DictReader(stream))
    with (atlas_dir / "bounds_1_to_100.csv").open(encoding="utf-8",newline="") as stream:
        hundred = list(wcsv.DictReader(stream))
    approved = [[4,"0.49791","0.49790","0.49375"],[5,"0.47189","0.47000","0.45000"],[6,"0.44819","≥0.36872","0.36872"],[7,"0.43140","0.42980","0.31429"],[8,"0.41889","0.41750","0.27973"],[9,"0.40920","0.40800","0.24932"],[10,"0.40148","0.40030","0.22472"],[11,"0.39500","0.39420","0.20441"],[12,"0.38980","0.38900","0.18744"],[13,"0.38540","0.38470","0.17304"],[14,"0.38160","0.38090","0.16067"],[15,"0.37849","0.37752","0.14996"],[16,"0.37564","0.37492","0.14059"],[17,"0.37313","0.37226","0.13176"],[18,"0.37089","0.37007","0.12444"],[19,"0.36812","0.36812","0.11789"],[20,"0.36636","0.36636","0.11200"]]
    if [int(row["k"]) for row in reg] != list(range(4,21)):
        FAILURES.append("Werner 4–20 registry is missing copy counts")
    else:
        for row,values in zip(reg,approved):
            k,q,t,u = values
            if (row["best_qutrit_t"],row["theorem_only_qutrit_t"],row["best_all_dimension_t"]) != (q,t,u):
                FAILURES.append(f"Werner current comparison mismatch at k={k}")
            if row["best_qutrit_evidence"] != ("quantitative source margins" if k<=18 else "published theorem statements"):
                FAILURES.append(f"Werner source-tier mismatch at k={k}")
    latest = {21:Fraction(36119,100000),22:Fraction(36119,100000),23:Fraction(35151,100000),24:Fraction(34001,100000)}
    if [int(row["k"]) for row in early] != list(range(1,25)):
        FAILURES.append("Werner 1–24 exact registry missing rows")
    else:
        for row in early:
            k=int(row["k"])
            exact=Fraction(row["t_exact"])
            if exact != Fraction(row["t_decimal"]):
                FAILURES.append(f"Werner k={k} exact rational/decimal mismatch")
            if k<=3 and exact != Fraction(1,2):
                FAILURES.append(f"Werner published sharp input incorrect at k={k}")
            if 4<=k<=20 and exact != Fraction(reg[k-4]["best_qutrit_t"]):
                FAILURES.append(f"Werner k={k} 1–24 exact registry differs from 4–20")
            if k in latest and exact != latest[k]:
                FAILURES.append(f"Werner k={k} later exact threshold changed")
            if k>3 and exact<=Fraction(1,3):
                FAILURES.append(f"Werner k={k} fails qutrit NPT threshold")
    if [int(row["k"]) for row in hundred] != list(range(1,101)):
        FAILURES.append("Werner 1–100 complete registry missing rows")
    else:
        for row in hundred:
            k=int(row["k"])
            if k<=24 and row["qutrit_t_exact_or_symbolic"] != early[k-1]["t_exact"]:
                FAILURES.append(f"Werner 1–100 early consistency failure at k={k}")
            if k>=25:
                expected=f"1/3+(121/20)/(6*{k})*(B24/(121/20))^(2^({k}-24))"
                if row["qutrit_t_exact_or_symbolic"] != expected:
                    FAILURES.append(f"Werner analytic 25–100 expression changed at k={k}")
                if row["all_dimension_t_exact"] != f"56/(25*{k})":
                    FAILURES.append(f"Werner all-dimension published fallback changed at k={k}")
    atlas=(atlas_dir / "README.md").read_text(encoding="utf-8")
    if "0.448760" not in atlas or "historical" not in atlas.lower():
        FAILURES.append("Werner historical higher alternative was silently lost")
    if "25–100" not in atlas:
        FAILURES.append("Werner 1–100 symbolic boundary missing")
    if not (atlas_dir / "ANALYTIC_CONTINUATION.md").is_file():
        FAILURES.append("Werner analytic proof note missing")
    if FAILURES:
        print("SITE AUDIT FAILED")
        for err in FAILURES:
            print(" -", err)
        return 1
    print(f"PASS: {len(pages)} pages, {sum(len(p.links) for p in pages.values())} anchors/links, "
          f"{len(static)} static research entries aligned with JavaScript.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
