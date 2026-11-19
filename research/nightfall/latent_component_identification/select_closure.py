#!/usr/bin/env python3
"""Select exact transitive source import closure of a named Lean flat-module root.

Uses committed 179-module source registry without adding axioms or generating theorems.
Fails closed on missing custom imports. Preserves registry's compiler-verified order.
"""
from pathlib import Path
import re
import sys
ROOT = Path(__file__).resolve().parents[3]
REGISTRY = ROOT / "research/nightfall/formalization/aa_product/CLOSURE.txt"
pairs = []
for line in REGISTRY.read_text().splitlines():
    line = line.strip()
    if not line:
        continue
    name, path = line.split()
    source = ROOT / path
    if not source.is_file():
        raise SystemExit(f"Missing registered source {name}: {source}")
    pairs.append((name, path))
by_name = dict(pairs)
if len(by_name) != len(pairs):
    raise SystemExit("Duplicate module in closure registry")
external = ("Mathlib", "Lean", "Std", "Batteries", "Aesop", "Qq")
target = sys.argv[1] if len(sys.argv) > 1 else "MixtureSimulation"
if target not in by_name:
    raise SystemExit(f"Missing root: {target}")
visited = set()
def visit(name):
    if name in visited:
        return
    visited.add(name)
    lines = (ROOT / by_name[name]).read_text().splitlines()
    for line in lines:
        match = re.match(r"^\s*import\s+(.+?)\s*(?:--.*)?$", line)
        if not match:
            continue
        for dep in match.group(1).split():
            if dep in by_name:
                visit(dep)
            elif dep in external or any(dep.startswith(prefix + ".") for prefix in external):
                continue
            else:
                raise SystemExit(f"Missing custom import {dep!r} in {name}")
if target != "MixtureSimulation":
    raise SystemExit("Only the explicitly audited MixtureSimulation root is allowed")
visit(target)
if not {"MixtureSimulation", "ProductSimulation"}.issubset(visited):
    raise SystemExit("Expected certified product modules absent from closure")
for name, path in pairs:
    if name in visited:
        print(name, path)
print(f"Exact source reachability: {len(visited)} modules / {len(pairs)} registered", file=sys.stderr)
