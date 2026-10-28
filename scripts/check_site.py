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
                  for path in re.findall(r'path:"([^"]+)"', js))
    homepage = pages[DOCS.joinpath("index.html").resolve()]
    static = set(homepage.research_rows)
    if sources != static:
        FAILURES.append(f"Research catalogue mismatch: static-only={sorted(static - sources)}, js-only={sorted(sources - static)}")
    if len(static) < 10:
        FAILURES.append("Static research catalogue has fewer than 10 entries")
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
