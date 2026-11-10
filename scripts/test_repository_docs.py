#!/usr/bin/env python3
"""Read-only public documentation contract. No network, source rewrites or proof promotion.

This check guards entry-point links and factual separation between the curated
research catalogue and the formally verified / independently reviewed claims.
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent.parent
ENTRYPOINTS = [
    Path("README.md"),
    Path("CONTRIBUTING.md"),
    Path("docs/README.md"),
    Path(".github/pull_request_template.md"),
]
HISTORY = ROOT / "docs/SITE_DEVELOPMENT_HISTORY_2026-10.md"
INVENTORY = ROOT / "research/nightfall/SITE_CURATED_40_20261030.json"

def checked(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)

def strip_fences(content: str) -> str:
    return re.sub(r"(?ms)^\s*`{3}.*?^\s*`{3}\s*$", "", content)

def local_markdown_paths(document: Path, text: str) -> list[Path]:
    candidates = []
    # Only Markdown targets, not quoted code or independent remote URLs.
    for match in re.finditer(r"(?<!!)\[[^\n\]]+\]\(([^\s)]+)(?:\s+[^)]*)?\)", strip_fences(text)):
        target = match.group(1)
        if target.startswith(("#", "mailto:", "http://", "https://", "data:")):
            continue
        path = unquote(urlsplit(target).path)
        if not path:
            continue
        candidates.append((document.parent / path).resolve())
    return candidates

def main() -> None:
    docs = {}
    for rel in ENTRYPOINTS:
        path = ROOT / rel
        checked(path.is_file(), f"Missing public guide {rel}")
        docs[str(rel)] = path.read_text(encoding="utf-8")
        for target in local_markdown_paths(path, docs[str(rel)]):
            checked(target.is_relative_to(ROOT), f"External filesystem path referenced in {rel}: {target}")
            checked(target.exists(), f"Broken local link in {rel}: {target.relative_to(ROOT)}")

    checked(HISTORY.is_file(), "The historical website guide was not preserved")
    archive = HISTORY.read_text(encoding="utf-8")
    checked("Historical development record" in archive, "Old site notes must be explicitly dated")

    manifest = json.loads(INVENTORY.read_text(encoding="utf-8"))
    checked(len(manifest["entries"]) == 40, "This snapshot must remain the frozen 40-record inventory")
    checked(manifest["original_findings_whitelist_count"] == 3, "Frozen three-entry core whitelist changed")

    root = docs["README.md"]
    research = (ROOT / "research/nightfall/README.md").read_text(encoding="utf-8")
    for required in ("40 curated", "11", "five", "candidate", "Lean 4.35.0"):
        checked(required.lower() in root.lower(), f"Root evidence scope absent: {required}")
    checked("40 curated" in research and "historical" in research.lower(), "Research history lacks current scope")
    checked("not" in root.lower() and "full" in root.lower(), "No headline theorem status boundary")

    guide = docs["CONTRIBUTING.md"]
    checked("source" in guide.lower() and "reproducib" in guide.lower(), "Evidence/credit procedure missing")
    checked("human" in guide.lower() and "AI-assisted" in guide, "Human/AI attribution boundary missing")

    ignore = (ROOT / ".gitignore").read_text(encoding="utf-8")
    for prohibited in ("*.pdf", "*.zip", "*.json", "*.log"):
        checked(prohibited not in ignore.splitlines(), f"Scientific evidence may be silently ignored: {prohibited}")

    if not (ROOT / "LICENSE").exists():
        checked("no repository-wide" in root.lower(), "Missing explicit no-license disclosure")

    checked((ROOT / "research/nightfall/2026-11-certificate-engine/README.md").is_file(),
            "Merged Claude research candidate is missing")
    checked((ROOT / "research/nightfall/formalization/product_space/LocalizedOptimization.lean").is_file(),
            "Scoped Lean sources missing")

    print(
        "PASS repository guides: 4 entrypoints, local links, archived October notes, "
        "40-record inventory, five finite findings / three core, candidate-vs-Lean scope, "
        "AI attribution, and evidence-preserving ignores"
    )

if __name__ == "__main__":
    main()
