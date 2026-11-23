#!/usr/bin/env python3
"""Conservative import-closure drift guard for eight headline Lean entrypoints.

Resolves local Lean module imports by path suffix / basename; conservatively
includes EVERY ambiguous same-basename candidate. Unresolved external modules
remain outside this checker and must be protected by a pinned toolchain lock.
Only the existing main branch can approve a changed dependency closure.
"""
import argparse
import json
import re
import subprocess
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = "research/nightfall/verification/HEADLINE_TRUST_BOUNDARIES_V1.json"
PIN_FILES = {"lean-toolchain", "lakefile.toml", "lakefile.lean", "docs/lean-compiler-lock.json"}


def header_imports(source: str) -> list[str]:
    imports, block_depth = [], 0
    for original in source.splitlines():
        s = original.strip()
        if block_depth:
            block_depth += s.count("/-") - s.count("-/")
            if block_depth < 0:
                raise ValueError("malformed block comment")
            continue
        if not s or s.startswith("--"):
            continue
        if s.startswith("/-"):
            block_depth = s.count("/-") - s.count("-/")
            if block_depth < 0:
                raise ValueError("bad comment")
            continue
        if s == "prelude":
            continue
        if s.startswith("import "):
            parts = s.split("--", 1)[0].split()[1:]
            if not parts or any(not re.fullmatch(r"[A-Za-z_][\w.']*", p) for p in parts):
                raise ValueError("malformed Lean import header")
            imports.extend(parts)
            continue
        break
    return imports


def local_modules(root: Path):
    index = defaultdict(list)
    for path in root.rglob("*.lean"):
        if ".lake" in path.parts or ".git" in path.parts:
            continue
        rel = path.relative_to(root).as_posix()
        index[path.stem].append(rel)
    return index


def closure(root: Path, entrypoints: list[str]):
    index = local_modules(root)
    stack = list(entrypoints)
    visited = set()
    unresolved = set()
    while stack:
        path = stack.pop()
        if path in visited:
            continue
        visited.add(path)
        source = (root / path).read_text(encoding="utf-8")
        for module in header_imports(source):
            candidates = index.get(module.split(".")[-1], [])
            # When a qualified module name exists, never trust the same basename
            # at the wrong qualified path as a complete resolution.
            if "." in module:
                suffix = module.replace(".", "/") + ".lean"
                selected = [p for p in candidates if p.endswith("/" + suffix) or p == suffix]
                candidates = selected if selected else candidates
            if not candidates:
                unresolved.add(module)
            else:
                stack.extend(candidates)
        if len(visited) > 2500:
            raise ValueError("import closure exceeds reviewable limit")
    return visited, unresolved


def changed_paths(root: Path, trusted_ref: str):
    if not re.fullmatch(r"[A-Za-z0-9_./-]+", trusted_ref) or trusted_ref.startswith("-") or ".." in trusted_ref:
        raise ValueError("unsafe trusted ref")
    cmd = ["git", "-C", str(root), "diff", "--name-only", "--diff-filter=ACMRT",
           f"{trusted_ref}...HEAD"]
    p = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if p.returncode != 0:
        raise ValueError("trusted ref not available")
    return set(p.stdout.splitlines())


def validate(root: Path, manifest: dict, changed: set[str]):
    entry = []
    for r in manifest["records"]:
        entry.append(r["source"]["path"])
        entry.extend(s["path"] for s in r.get("supporting", []))
    paths, unresolved = closure(root, entry)
    drift = sorted(changed.intersection(paths | PIN_FILES))
    if drift:
        raise ValueError("HEADLINE_DEPENDENCY_OR_TOOLCHAIN_DRIFT_REQUIRES_REPLAY: " + ", ".join(drift[:25]))
    return {
        "status": "NO_BRANCH_LOCAL_IMPORT_CLOSURE_DRIFT",
        "entrypoints": len(entry), "local_modules_covered": len(paths),
        "unresolved_external_imports": sorted(unresolved),
        "external_dependency_pin_review": "separate",
        "semantic_equivalence_checked": False,
        "full_kernel_replayed": False,
    }


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    p.add_argument("--trusted-ref", required=True)
    p.add_argument("--json-out", type=Path)
    a = p.parse_args()
    root = a.root.resolve()
    manifest = json.loads((root / MANIFEST).read_text())
    out = validate(root, manifest, changed_paths(root, a.trusted_ref))
    if a.json_out:
        a.json_out.parent.mkdir(parents=True, exist_ok=True)
        a.json_out.write_text(json.dumps(out, indent=2) + "\n")
    print(json.dumps(out, indent=2))


if __name__ == "__main__":
    main()
