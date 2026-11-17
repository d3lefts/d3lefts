#!/usr/bin/env python3
"""Build a deterministic, standalone Commonwealth GitHub Pages repository."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import zipfile
from urllib.parse import urljoin, urlparse

ROOT = Path(__file__).resolve().parents[3]
DOCS = ROOT / "docs"
PACKAGE = Path(__file__).resolve().parent
ROOT_ASSETS = (
    "commonwealth.html", "commonwealth-os.html", "commonwealth-intelligence.html",
    "commonwealth-warrant.html", "commonwealth-warrant.css", "commonwealth-warrant.mjs",
    "commonwealth.css", "commonwealth-republic.css", "commonwealth-family.css",
    "commonwealth-os.css", "commonwealth-intelligence.css",
    "commonwealth-shell.css", "commonwealth-shell.js",
    "commonwealth-os.js", "commonwealth-intelligence.js",
    "commonwealth-intelligence-fixtures.js", "commonwealth-archetypes.js",
    "commonwealth-mark.svg",
)
DIRECTORIES = {
    "commonwealth-archetypes": {".svg"},
    "commonwealth-demos": {".html"},
    "commonwealth-browser": {".html", ".css", ".js", ".mjs"},
}
RESEARCH_ORIGIN = "https://d3lefts.github.io/d3lefts/"
DEFAULT_ORIGIN = "https://d3lefts.github.io/commonwealth/"

def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def normalized_site_url(url: str) -> str:
    v = urlparse(url)
    if v.scheme != "https" or not v.netloc or v.params or v.query or v.fragment:
        raise ValueError("Site origin must be an absolute HTTPS URL without query or fragment")
    return url.rstrip("/") + "/"

def html_transform(content: str, name: str, origin: str, research: str) -> str:
    # Research origins are externally attributed, never part of the civic bundle.
    content = content.replace('href="index.html"', f'href="{research}"')
    content = content.replace('href="permission-lab.html"', f'href="{research}permission-lab.html"')
    content = content.replace('href="commonwealth.html"', 'href="./"')
    destination = "" if name == "commonwealth.html" else name
    canonical = urljoin(origin, destination)
    content = re.sub(r'(<link rel="canonical" href=")[^"]+(")', lambda m: m[1] + canonical + m[2], content)
    content = re.sub(r'(<meta property="og:url" content=")[^"]+(")', lambda m: m[1] + canonical + m[2], content)
    content = content.replace('<title>Commonwealth OS — A More Informed Republic</title>',
                              '<title>Commonwealth — A More Informed Republic</title>')
    return content

def produce(output: Path, origin: str, research: str, source_ref: str, archive: Path | None) -> None:
    release = output.resolve()
    if release == ROOT or release == DOCS or release == PACKAGE:
        raise ValueError("Refusing to overwrite a source directory")
    if release.exists():
        shutil.rmtree(release)
    site = release / "site"
    site.mkdir(parents=True)
    copied = {}
    for name in ROOT_ASSETS:
        src = DOCS / name
        if not src.is_file():
            raise FileNotFoundError(src)
        data = src.read_bytes()
        if name.endswith(".html"):
            data = html_transform(data.decode("utf-8"), name, origin, research).encode("utf-8")
        (site / name).write_bytes(data)
        copied[name] = {"source_sha256": digest(src.read_bytes()), "published_sha256": digest(data)}
    for directory, extensions in DIRECTORIES.items():
        for src in sorted((DOCS / directory).rglob("*")):
            if not src.is_file() or src.suffix not in extensions:
                continue
            if "tests" in src.relative_to(DOCS).parts:
                continue
            rel = src.relative_to(DOCS)
            dest = site / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            data = src.read_bytes()
            if rel.as_posix() == "commonwealth-browser/index.html":
                data = data.replace(b"2027 pilot architecture", b"proposed pilot architecture")
            dest.write_bytes(data)
            copied[rel.as_posix()] = {"source_sha256": digest(src.read_bytes()), "published_sha256": digest(data)}
    shutil.copyfile(site / "commonwealth.html", site / "index.html")
    (site / ".nojekyll").write_bytes(b"")
    (site / "robots.txt").write_text("User-agent: *\nAllow: /\nSitemap: " + urljoin(origin, "sitemap.xml") + "\n", encoding="utf-8")
    pages = ("", "commonwealth-os.html", "commonwealth-intelligence.html", "commonwealth-warrant.html",
             "commonwealth-browser/index.html", "commonwealth-demos/living-voter.html")
    xml = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    for p in pages:
        xml += "  <url><loc>" + urljoin(origin, p).replace("&", "&amp;") + "</loc></url>\n"
    (site / "sitemap.xml").write_text(xml + "</urlset>\n", encoding="utf-8")
    (release / ".github" / "workflows").mkdir(parents=True)
    shutil.copyfile(PACKAGE / "target-repository" / ".github" / "workflows" / "pages.yml",
                    release / ".github" / "workflows" / "pages.yml")
    shutil.copyfile(PACKAGE / "target-repository" / "README.md", release / "README.md")
    (site / "build-manifest.json").write_text(json.dumps({
        "format": "commonwealth-static-release/v1",
        "site_origin": origin, "research_origin": research,
        "source_repository": "d3lefts/d3lefts", "source_ref": source_ref,
        "is_real_election_service": False,
        "assurance": "Synthetic and nonbinding; no production authority or authenticity certificate.",
        "files": dict(sorted(copied.items())),
    }, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    if archive:
        archive = archive.resolve()
        archive.parent.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
            for file in sorted(release.rglob("*")):
                if not file.is_file():
                    continue
                relative = file.relative_to(release).as_posix()
                zi = zipfile.ZipInfo(relative, (1980, 1, 1, 0, 0, 0))
                zi.compress_type = zipfile.ZIP_DEFLATED
                zi.external_attr = 0o100644 << 16
                z.writestr(zi, file.read_bytes())
    print(json.dumps({"status": "BUILT_NOT_DEPLOYED", "origin": origin,
        "source_ref": source_ref, "source_files": len(copied),
        "bundle_files": sum(p.is_file() for p in release.rglob("*")),
        "release": str(release), "zip": str(archive) if archive else None}, sort_keys=True))

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--zip-output", type=Path)
    parser.add_argument("--base-url", default=DEFAULT_ORIGIN)
    parser.add_argument("--research-url", default=RESEARCH_ORIGIN)
    parser.add_argument("--source-ref", default=os.environ.get("GITHUB_SHA", "UNPINNED_LOCAL_CHECKOUT"))
    args = parser.parse_args()
    produce(args.output, normalized_site_url(args.base_url),
            normalized_site_url(args.research_url), args.source_ref, args.zip_output)

if __name__ == "__main__":
    main()
