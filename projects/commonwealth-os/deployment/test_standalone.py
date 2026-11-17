#!/usr/bin/env python3
"""Independent static closure and provenance audit for a Commonwealth release."""
from __future__ import annotations
from html.parser import HTMLParser
import hashlib
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET
from urllib.parse import unquote, urlsplit

class Links(HTMLParser):
    def __init__(self):
        super().__init__()
        self.local = []
        self.canonicals = []
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "link" and a.get("rel") == "canonical":
            self.canonicals.append(a.get("href", ""))
        for prop in ("href", "src", "poster", "data-src"):
            if a.get(prop):
                self.local.append((tag, prop, a[prop]))
        if tag == "script" and a.get("src", "").startswith(("http:", "https:", "//")):
            raise AssertionError("Remote execution dependency: " + a["src"])

def audit(root: Path):
    site = root / "site"
    assert (root / ".github/workflows/pages.yml").is_file(), "Missing independent deploy pipeline"
    assert (site / ".nojekyll").is_file(), "Pages needs .nojekyll"
    manifest = json.loads((site / "build-manifest.json").read_text())
    assert manifest["format"] == "commonwealth-static-release/v1"
    origin = manifest["site_origin"]
    assert origin.startswith("https://") and origin.endswith("/")
    assert manifest["is_real_election_service"] is False
    required = ["index.html", "commonwealth.html", "commonwealth-os.html",
                "commonwealth-warrant.html", "commonwealth-warrant.css", "commonwealth-warrant.mjs",
                "commonwealth-intelligence.html", "commonwealth-browser/index.html",
                "commonwealth-demos/living-voter.html", "commonwealth-shell.css",
                "commonwealth-shell.js", "commonwealth-mark.svg",
                "commonwealth-archetypes/balanced-pragmatist.svg"]
    for name in required:
        assert (site / name).is_file(), "Missing runtime asset: " + name
    for name, meta in manifest["files"].items():
        f = site / name
        assert f.is_file(), name
        assert hashlib.sha256(f.read_bytes()).hexdigest() == meta["published_sha256"], "Digest mismatch: " + name
    assert (site / "index.html").read_bytes() == (site / "commonwealth.html").read_bytes()
    assert (site / "index.html").read_text().count("<h1") == 1
    assert "Research prototypes, not a voting service." in (site / "index.html").read_text()
    assert "SYNTHETIC" in (site / "commonwealth-browser/index.html").read_text()
    all_links = 0
    for html in site.rglob("*.html"):
        page = html.read_text(encoding="utf-8")
        assert not re.search(r'(?:href="site.css"|src="site.js")', page), "NIGHTFALL dependency: " + str(html)
        assert not re.search(r'(?:href="index.html"|href="permission-lab.html")', page), "Unresolved research route: " + str(html)
        parsed = Links()
        parsed.feed(page)
        if html.relative_to(site).as_posix() in (
            "index.html", "commonwealth.html", "commonwealth-os.html", "commonwealth-intelligence.html", "commonwealth-warrant.html"
        ):
            assert parsed.canonicals and parsed.canonicals[0].startswith(origin), "Wrong canonical: " + str(html)
        for tag, prop, raw in parsed.local:
            if raw.startswith(("#", "mailto:", "tel:", "data:", "javascript:")):
                continue
            u = urlsplit(raw)
            if u.scheme or u.netloc:
                assert u.scheme == "https", "Insecure external link: " + raw
                continue
            if "$" + "{" in raw or raw.startswith(("open:", "survey:", "filter:", "compare:", "delete:")):
                continue
            dest = unquote(u.path)
            if not dest or dest == "/":
                continue
            target = ((site / dest.lstrip("/")) if dest.startswith("/") else (html.parent / dest)).resolve()
            assert target == site.resolve() or site.resolve() in target.parents, "Escaped site: " + raw
            assert target.exists(), "Broken local ref " + str(html.relative_to(site)) + " -> " + raw
            all_links += 1
    for js in list(site.rglob("*.js")) + list(site.rglob("*.mjs")):
        data = js.read_text(encoding="utf-8")
        for ref in re.findall(r'(?:(?:import|export)[^\n;]*?from\s*|import\s*)["\'](\.[^"\']+)["\']', data):
            target = (js.parent / ref).resolve()
            assert target.is_file(), "Missing module dependency: " + str(js.relative_to(site)) + " -> " + ref
    ET.parse(site / "sitemap.xml")
    assert not (site / "site.js").exists() and not (site / "site.css").exists()
    assert not list(site.rglob("*test*")), "Test-only files must not ship"
    print(json.dumps({"status": "PASS", "assets": len(manifest["files"]),
                      "checked_local_links": all_links, "origin": origin}, sort_keys=True))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 test_standalone.py RELEASE_DIR")
    audit(Path(sys.argv[1]).resolve())
