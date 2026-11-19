#!/usr/bin/env python3
"""Validate the exact pinned AA integration scope before invoking Lake.

This is an import-custody check, not a proof or a compiler certificate.
"""
from pathlib import Path
from generate_nightfall_lake import ROOT, SOURCE, discover, closure

AA_SEEDS = ("InfinitePiAAProductTerminal", "CubePrintedAA", "ProductSimulation")
DENIED_UPSTREAM_TERMINALS = {
    "AaronsonAmbainis.Chain",
    "AaronsonAmbainis.Main",
    "AaronsonAmbainis.MainTheorem",
}


def audit() -> None:
    by_name, imports = discover()
    actual = set(closure(by_name, imports))
    manifest_path = SOURCE / "aa_product/CLOSURE.txt"
    if not manifest_path.is_file():
        raise ValueError("Missing immutable AA source-closure inventory")
    declared = {}
    for line in manifest_path.read_text("utf-8").splitlines():
        if not line.strip():
            continue
        parts = line.split()
        if len(parts) != 2:
            raise ValueError("Malformed AA closure inventory line")
        module, path = parts
        if module in declared:
            raise ValueError("Duplicate module in AA closure inventory: " + module)
        declared[module] = path
        if module not in by_name:
            raise ValueError("Missing AA source module: " + module)
        if by_name[module].relative_to(ROOT).as_posix() != path:
            raise ValueError("AA source path changed for " + module)
    # The named AA terminal sources must recursively depend only on material
    # inside the inventory (and the explicitly admitted third-party libraries).
    todo = list(AA_SEEDS)
    seen = set()
    external = ("Mathlib", "Lean", "Std", "Batteries", "Qq", "Aesop",
                "Cli", "ProofWidgets", "Plausible", "LeanSearchClient",
                "ImportGraph", "Lake")
    while todo:
        name = todo.pop()
        if name in seen:
            continue
        if name not in by_name:
            raise ValueError("AA dependency not present: " + name)
        seen.add(name)
        for dep in imports[name]:
            if dep in by_name:
                todo.append(dep)
            elif dep == "Mathlib" or any(dep.startswith(p + ".") for p in external):
                continue
            else:
                raise ValueError(name + ": unresolved source dependency " + dep)
    if seen != set(declared):
        raise ValueError("AA inventory drift: missing=" +
                         repr(sorted(seen - set(declared))) + ", stale=" +
                         repr(sorted(set(declared) - seen)))
    if not seen <= actual:
        raise ValueError("AA inventory missing from unified Lake source closure")
    if seen & DENIED_UPSTREAM_TERMINALS:
        raise ValueError("Upstream original cube terminal included as shortcut")
    print(f"PASS: {len(seen)} AA module sources in unified {len(actual)}-module Lake closure;"
          " vendored theorem shortcut absent; this does not certify Lean theorems")


if __name__ == "__main__":
    audit()
