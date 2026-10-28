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
    # Reconciled Werner ledger: 24 exact rational rows, preservation of stronger old certificates,
    # an honest evidence-tier split, public presentation, and rejected-25 firewall.
    from fractions import Fraction
    atlas_dir = ROOT / "research/nightfall/projects/werner-atlas"
    import csv as werner_csv
    with (atlas_dir / "bounds_1_to_24.csv").open(encoding="utf-8", newline="") as f:
        werner_rows = list(werner_csv.DictReader(f))
    expected_werner = {6: Fraction(11219,25000), 7: Fraction(10807,25000),
        8: Fraction(4199,10000), 9: Fraction(256,625),
        15: Fraction(37849,100000), 16: Fraction(9391,25000),
        17: Fraction(37313,100000), 18: Fraction(37089,100000),
        21: Fraction(36119,100000), 22: Fraction(36119,100000),
        23: Fraction(35151,100000), 24: Fraction(34001,100000)}
    if len(werner_rows) != 24 or [int(r["k"]) for r in werner_rows] != list(range(1,25)):
        FAILURES.append("Werner copy ledger must contain k=1..24 exactly once")
    else:
        for row in werner_rows:
            k = int(row["k"])
            exact = Fraction(row["t_exact"])
            displayed = Fraction(row["t_decimal"])
            if exact != displayed:
                FAILURES.append(f"Werner exact/decimal mismatch at k={k}")
            if k > 3 and exact <= Fraction(1,3):
                FAILURES.append(f"Werner qutrit NPT threshold not strictly above 1/3 at k={k}")
            if k in expected_werner and exact != expected_werner[k]:
                FAILURES.append(f"Werner strongest-archive checkpoint changed at k={k}")
            tier = row["evidence_tier"]
            if k<=3 and tier != "published sharp" or 4<=k<=18 and tier != "quantitative source margins" or k>=19 and tier != "published theorem statements":
                FAILURES.append(f"Werner source tier mismatch at k={k}")
    atlas = (atlas_dir / "README.md").read_text(encoding="utf-8")
    continuation = (atlas_dir / "ANALYTIC_CONTINUATION.md").read_text(encoding="utf-8")
    asset = (atlas_dir / "REVIEW_AND_ASSETS.md").read_text(encoding="utf-8")
    webpage = (DOCS / "werner.html").read_text(encoding="utf-8")
    if "0.34001" not in webpage or "0.35151" not in webpage or "0.36119" not in webpage:
        FAILURES.append("Werner public page missing final k=22–24 results")
    if "0.448760" not in webpage or "0.432280" not in webpage or "0.419900" not in webpage:
        FAILURES.append("Werner public page lost stronger k=6–8 checkpoints")
    if any(s not in atlas + continuation + asset for s in ("source margins", "every-finite-k", "failed", "pending")):
        FAILURES.append("Werner dossier missing source caveat or failed experiment")
    if "t=0.34" in (atlas_dir / "bounds_1_to_24.csv").read_text(encoding="utf-8"):
        FAILURES.append("Failed 25-copy LP candidate accidentally promoted")
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
