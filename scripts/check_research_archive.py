#!/usr/bin/env python3
"""Fail-closed editorial archive contract: no mathematical proof or priority certification.

Only checks structured claims, source custody, dependency gates and local links.
No network, source mutation, external judgement, or assumption of peer review.
"""
from __future__ import annotations

import copy
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent.parent
CATALOGUE = ROOT / "research/catalogue/CLAIMS.json"
VALIDITY = {
    "kernel-checked-scoped", "analytic-manuscript-unrefereed",
    "conditional-on-open-premise", "conjecture-open", "finite-exact-replayed",
    "finite-exact-internal", "source-premise-conditional",
    "reproduced-synthetic-experiment", "adverse-retrospective"
}
SOURCES = {
    "public-primary-source", "public-analytic-manuscript",
    "public-synopsis-source-missing", "public-conjecture-note",
    "public-finite-source-checker", "public-release-and-ledger",
    "public-conditional-checker", "public-experiment-code-and-log",
    "public-retrospective"
}
LIFECYCLE = {"active", "archive"}
REVIEW = {"none-recorded", "external-non-author-reported"}
PRIORITY = {"unresolved", "source-derived-priority-unresolved", "not-applicable", "externally-audited"}
SELECTED_GUIDES = [
    "README.md", "CONTRIBUTING.md", "research/README.md",
    "research/REUSE_AND_RIGHTS.md", "research/catalogue/README.md",
    "research/catalogue/DEPENDENCIES.md", "research/referee/README.md",
    "research/archive/README.md", "papers/README.md",
    "papers/universal-observability/README.md",
    "papers/quadratic-observability/README.md",
    "papers/finite-product-influence/README.md",
    "papers/cubic-structures/README.md",
    "papers/exact-recovery/README.md",
    "papers/spectral-adaptive-prediction/README.md",
    "papers/specialized-complexity/README.md",
    "papers/kaczmarz/README.md",
]
REQUIRED = {
    "id", "title", "area", "lifecycle", "validity", "source_status",
    "review", "priority", "primary", "evidence", "dependencies",
    "claim_scope", "open_gates", "inherited"
}


def guard(ok: bool, detail: str) -> None:
    if not ok:
        raise AssertionError(detail)


def repo_file(rel: str) -> Path:
    guard(isinstance(rel, str) and bool(rel) and not rel.startswith("/"),
          "Invalid repository-relative path")
    path = (ROOT / rel).resolve()
    guard(path.is_relative_to(ROOT), f"Path escapes repository: {rel}")
    guard(path.is_file(), f"Missing public primary/evidence source: {rel}")
    return path


def validate_catalogue(doc: dict) -> None:
    guard(doc.get("schema_version") == "1.0", "Unsupported claim catalogue schema")
    guard(doc.get("as_of") == "2026-11-11", "Update dated scope review before bumping checkpoint")
    guard(isinstance(doc.get("claims"), list) and bool(doc["claims"]), "Empty claim catalogue")
    entries = doc["claims"]
    ids = [r.get("id") for r in entries]
    guard(all(isinstance(x, str) and re.fullmatch(r"NF-[A-Z0-9-]+", x) for x in ids),
          "Invalid claim identifier")
    guard(len(ids) == len(set(ids)), "Duplicate claim identifier")
    by_id = {r["id"]: r for r in entries}
    edges = {}

    for r in entries:
        id_ = r["id"]
        guard(REQUIRED <= set(r), f"Missing mandatory fields in {id_}")
        guard(r["validity"] in VALIDITY, f"Unknown validity tier in {id_}")
        guard(r["source_status"] in SOURCES, f"Unknown public source tier in {id_}")
        guard(r["lifecycle"] in LIFECYCLE, f"Unknown lifecycle in {id_}")
        guard(r["review"] in REVIEW, f"Unknown referee tier in {id_}")
        guard(r["priority"] in PRIORITY, f"Unknown priority tier in {id_}")
        for key in ("title", "area", "claim_scope"):
            guard(isinstance(r[key], str) and len(r[key].strip()) > 8,
                  f"Missing quantified scope/metadata: {id_}.{key}")
        for key in ("open_gates", "inherited", "evidence", "dependencies"):
            guard(isinstance(r[key], list), f"Must be a list: {id_}.{key}")
        guard(bool(r["open_gates"]), f"No stated independent stop rule: {id_}")
        repo_file(r["primary"])
        guard(bool(r["evidence"]), f"At least one evidence path required: {id_}")
        for p in r["evidence"]:
            repo_file(p)
        if r["source_status"] == "public-synopsis-source-missing":
            guard(r["validity"] != "kernel-checked-scoped", f"Source gap hidden by formal tier: {id_}")
            guard(any("source" in str(g).lower() or "full" in str(g).lower()
                      for g in r["open_gates"]),
                  f"Missing source-completeness stop rule: {id_}")
        if r["validity"] == "kernel-checked-scoped":
            formal = r.get("formal")
            guard(isinstance(formal, dict), f"No exact formal provenance: {id_}")
            guard(re.fullmatch(r"[0-9a-f]{40}", formal.get("head", "")) is not None,
                  f"Missing pinned theorem commit: {id_}")
            guard(bool(formal.get("declaration")) and bool(formal.get("compiler"))
                  and bool(formal.get("upstream")),
                  f"Formal source statement/toolchain/upstream omitted: {id_}")
            guard(formal.get("receipt", "").startswith("https://github.com/"),
                  f"Missing official compiler receipt: {id_}")
            guard(r["primary"].endswith(".lean"), f"Formal entry must point to source: {id_}")
        if r["validity"] == "conditional-on-open-premise":
            guard(bool(r["dependencies"]), f"Conditional claim has no explicit premise: {id_}")
        if r["validity"] == "finite-exact-replayed":
            guard(any(p.endswith(".py") for p in r["evidence"])
                  and any(p.endswith(".txt") for p in r["evidence"]),
                  f"Finite certificate lacks source checker or witness: {id_}")
        if r["review"] == "external-non-author-reported":
            guard("external_review_report" in r, f"Reviewer report absent: {id_}")
            repo_file(r["external_review_report"])
        if r["priority"] == "externally-audited":
            guard("priority_review" in r, f"Dated priority source missing: {id_}")
            repo_file(r["priority_review"])
        neighbors = []
        for dep in r["dependencies"]:
            guard(isinstance(dep, dict) and set(dep) == {"id", "type"},
                  f"Malformed dependency: {id_}")
            guard(dep["id"] in by_id and dep["id"] != id_,
                  f"Missing/self dependency in {id_}: {dep.get('id')}")
            guard(dep["type"] == "uses-as-premise", f"Dependency must specify premise: {id_}")
            neighbors.append(dep["id"])
        guard(len(set(neighbors)) == len(neighbors), f"Repeated premise: {id_}")
        edges[id_] = neighbors

    state: dict[str, int] = {}
    def visit(v: str) -> None:
        guard(state.get(v) != 1, f"Cyclic mathematical premise chain at {v}")
        if state.get(v) == 2:
            return
        state[v] = 1
        for w in edges[v]:
            visit(w)
        state[v] = 2

    for v in ids:
        visit(v)

    # Paper C synthesizes source-specific regimes: no promotion to a global
    # Lean theorem, and no illicit transfer between whole-coordinate and
    # powered-linear-form oracles.
    paper_c = by_id.get("NF-OBS-SPECIALIZED-20261111")
    guard(paper_c is not None, "Paper C missing from scholarly claim registry")
    guard(paper_c["primary"] == "papers/specialized-complexity/MANUSCRIPT.md",
          "Paper C primary source drift")
    guard(paper_c["validity"] == "analytic-manuscript-unrefereed"
          and paper_c["review"] == "none-recorded"
          and paper_c["priority"] == "unresolved",
          "Paper C promoted without independent mathematical review")
    guard(paper_c["dependencies"] == [
        {"id": "NF-OBS-UNIVERSAL-20261111", "type": "uses-as-premise"}],
          "Paper B rank-linear premise missing or an unproven quadratic premise silently added")
    scopes = paper_c.get("component_scopes", [])
    guard(len(scopes) == 4, "Paper C model separation incomplete")
    guard({item.get("status") for item in scopes} == {
        "analytic-composition-with-scoped-finite-Lean-premises",
        "analytic-corollary-of-paper-b",
        "exact-finite-replay-and-scoped-Lean-branch",
        "conditional-inherited-proposal-not-certified"},
        "Paper C theorem-status categories conflated")
    guard(all("source" in item and "model" in item and "component" in item
              for item in scopes), "Paper C model/source provenance omitted")

    for r in entries:
        # Recorded formal review is never inferred from a formal *premise*.
        if r["validity"] == "kernel-checked-scoped":
            guard(not r["dependencies"], "Extend exact formal statement before adding a premise")
        if r["validity"] == "conditional-on-open-premise":
            guard(any(by_id[d["id"]]["validity"] in {
                "analytic-manuscript-unrefereed", "conditional-on-open-premise", "conjecture-open"
            } for d in r["dependencies"]), "Conditional status must identify an open premise")


def strip_fences(body: str) -> str:
    return re.sub(r"(?ms)^\s*`{3}.*?^\s*`{3}\s*$", "", body)


def validate_guides() -> None:
    pattern = re.compile(r"(?<!!)\[[^\n\]]+\]\(([^\s)]+)(?:\s+[^)]*)?\)")
    for rel in SELECTED_GUIDES:
        source = repo_file(rel)
        body = strip_fences(source.read_text(encoding="utf-8"))
        for m in pattern.finditer(body):
            raw = m.group(1)
            if raw.startswith(("#", "https://", "http://", "mailto:", "data:")):
                continue
            path = unquote(urlsplit(raw).path)
            if not path:
                continue
            dest = (source.parent / path).resolve()
            guard(dest.is_relative_to(ROOT), f"Guide link exits repository: {rel} -> {raw}")
            guard(dest.exists(), f"Broken scholarly guide link: {rel} -> {raw}")


def self_test(doc: dict) -> None:
    validate_catalogue(doc)
    mutations = [
        ("duplicate ID", lambda a: a["claims"].append(copy.deepcopy(a["claims"][0]))),
        ("missing source", lambda a: a["claims"][0].update(primary="research/no-such-paper.md")),
        ("false formal receipt", lambda a: a["claims"][0]["formal"].update(receipt="")),
        ("unrecognized validity", lambda a: a["claims"][0].update(validity="peer-reviewed-because-ci")),
        ("dependency cycle", lambda a: a["claims"][0].update(
            dependencies=[{"id": "NF-OBS-UNIVERSAL-20261111", "type": "uses-as-premise"}])),
    ]
    for label, mutate in mutations:
        copy_doc = copy.deepcopy(doc)
        mutate(copy_doc)
        try:
            validate_catalogue(copy_doc)
        except AssertionError:
            continue
        raise AssertionError(f"Fail-open negative control: {label}")
    print(f"PASS archive mutation controls: {len(mutations)} artificial invalid catalogues rejected")


def main() -> None:
    doc = json.loads(CATALOGUE.read_text(encoding="utf-8"))
    validate_catalogue(doc)
    validate_guides()
    print(f"PASS scholarly catalogue: {len(doc['claims'])} selected claims, "
          f"all primary/evidence paths, dependency DAG, "
          f"{len(SELECTED_GUIDES)} local-link guides; no mathematical status promotion")
    if "--self-test" in sys.argv[1:]:
        self_test(doc)


if __name__ == "__main__":
    main()
