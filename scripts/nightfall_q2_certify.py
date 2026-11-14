#!/usr/bin/env python3
"""One-run, dependency-ordered, fail-closed Q2 Lean certificate.

A stage is certified only if the pinned Lean compiler, the source bridge,
and the declaration-specific standard-axiom receipt checker ALL succeed.
No source file, numeric replay, or independent partial pass certifies Q2.
This script never modifies original research sources.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ROOT / "research/nightfall/formalization"
OBSERVER = SOURCE_ROOT / "observability"
RECEIPT_CHECKER = ROOT / "research/nightfall/formalization/product_space/check_receipts.py"
BRIDGE = ROOT / "scripts/lean_bridge.py"
ALLOWED_AXIOMS = ("Classical.choice", "Quot.sound", "propext")

# Order is deliberately *structural*, not based on which theorem passes.
# Source modules are transitively compiled at most once per run.
STAGES = (
    ("01-original-pair-fourth", "ActualSourceFinitePairMoment",
     ("original_source_distinct_pair_fourth_endpoint",)),
    ("02-owned-pair-energy", "ActualSourceOwnedMomentEnergy",
     ("original_owned_neighbor_moment2_le_influence",)),
    ("03-original-projection-jensen", "ActualSourceOwnedProjectedMomentJensen",
     ("source_generated_owned_moment_projection_jensen",)),
    ("04-source-owned-fourth", "ActualSourceOwnedFourthClosure",
     ("original_source_generated_fourth_and_jensen_package",)),
    ("05-singleton-pair-parseval", "ActualSourceQuadraticSectorSplit",
     ("source_variance_eq_singleton_plus_pair_energy",)),
    ("06-variance-owned-moment", "ActualSourceSingletonEnergyBridge",
     ("original_source_variance_eq_singleton_plus_owned_moment2",)),
    ("07-first-norm-L2-cap", "ActualSourceOwnedFirstMomentCap",
     ("original_owned_first_norm_le_sqrt_source_influence",)),
    ("08-exact-Q2-terminal", "ActualSourceQ2Terminal",
     ("actual_source_q2_terminal",)),
    # Conditional numerical coefficient only: this declaration still
    # REQUIRES the sharp source additive budget as an explicit premise.
    # Success here NEVER certifies the stronger source-only theorem.
    ("09-strong-coefficient-conditional", "ActualSourceQ2StrongConditional",
     ("actual_source_q2_strong_given_additive_budget",)),
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def local_sources() -> dict[str, Path]:
    files = {}
    for path in sorted(SOURCE_ROOT.rglob("*.lean")):
        if path.stem in files and files[path.stem] != path:
            raise ValueError(
                f"Ambiguous Lean basename {path.stem}: {files[path.stem]} vs {path}"
            )
        files[path.stem] = path
    return files


def imports(path: Path) -> list[str]:
    # Imports in the repository are line-start 'import A.B' or 'import A'.
    # Unknown names are Mathlib/external imports, already in pinned workspace.
    ans = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.split("--", 1)[0].strip()
        if line.startswith("import "):
            ans.extend(line[len("import "):].split())
    return ans


def closure(module: str, files: dict[str, Path]) -> list[str]:
    state, order = {}, []

    def visit(m: str):
        if m not in files:
            return
        if state.get(m) == 2:
            return
        if state.get(m) == 1:
            raise ValueError(f"Cycle in local Lean imports: {m}")
        state[m] = 1
        for imported in imports(files[m]):
            visit(imported)
        state[m] = 2
        order.append(m)

    if module not in files:
        raise FileNotFoundError(f"Missing required source module: {module}")
    visit(module)
    return order


def verify_declarations(path: Path, names: tuple[str, ...]) -> None:
    # This is only a preflight, never a substitute for Lean.
    source = path.read_text(encoding="utf-8")
    for name in names:
        if not any(
            line.startswith(prefix + name + " ")
            or line.startswith(prefix + name + "\n")
            or line.strip() == prefix.strip() + " " + name
            for line in source.splitlines()
            for prefix in ("theorem ", "lemma ", "def ", "abbrev ")
        ):
            raise ValueError(f"Missing expected declaration {name} in {path}")


def run(args: argparse.Namespace) -> int:
    files = local_sources()
    stages = []
    all_modules = set()
    for label, module, names in STAGES:
        target = files.get(module)
        if target is None:
            raise FileNotFoundError(f"Missing endpoint: {module}")
        verify_declarations(target, names)
        ordered = closure(module, files)
        stages.append((label, module, names, ordered))
        all_modules.update(ordered)
    if args.plan:
        print(json.dumps({
            "stage_names": [x[0] for x in stages],
            "distinct_source_modules": len(all_modules),
            "terminal": "Nightfall.Observability.ActualSourceQ2Terminal.actual_source_q2_terminal",
            "all_stage_roots_present": True,
            "compiler_invoked": False,
        }, indent=2))
        return 0

    receipt_dir = Path(args.receipt_dir).resolve()
    receipt_dir.mkdir(parents=True, exist_ok=True)
    workspace = Path(args.workspace).resolve()
    if not (workspace / "lean-toolchain").exists():
        raise FileNotFoundError("Pinned Lean workspace missing: " + str(workspace))
    if (workspace / "lean-toolchain").read_text().strip() != "leanprover/lean4:v4.36.0-rc2":
        raise ValueError("Lean toolchain pin mismatch")
    out = workspace / ".lake/build/lib/lean"
    out.mkdir(parents=True, exist_ok=True)
    compiled: set[str] = set()
    manifest = {
        "status": "PROVISIONAL",
        "repository_commit": subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
        ).strip(),
        "compiler_pin": (workspace / "lean-toolchain").read_text().strip(),
        "mathlib_commit": subprocess.check_output(
            ["git", "rev-parse", "HEAD"], cwd=workspace, text=True
        ).strip(),
        "stages": [],
        "source_sha256": {},
        "failure": None,
    }
    expected_mathlib = "9d581dfff2e41de989072ea63abf3daf69311520"
    if manifest["mathlib_commit"] != expected_mathlib:
        raise ValueError("Pinned Mathlib commit mismatch: " + manifest["mathlib_commit"])

    try:
        for label, module, names, ordered in stages:
            stage = {"label": label, "module": module,
                     "declarations": list(names), "status": "NOT_CERTIFIED"}
            manifest["stages"].append(stage)
            print(f"::group::{label}", flush=True)
            for name in ordered:
                if name in compiled:
                    continue
                source_path = files[name]
                module_path = workspace / f"{name}.lean"
                shutil.copyfile(source_path, module_path)
                if sha256(source_path) != sha256(module_path):
                    raise ValueError(f"Source copy hash mismatch: {name}")
                manifest["source_sha256"][str(source_path.relative_to(ROOT))] = sha256(source_path)
                print("BUILD " + name, flush=True)
                subprocess.run(
                    ["lake", "env", "lean", "-o", str(out / f"{name}.olean"),
                     f"{name}.lean"],
                    cwd=workspace, timeout=1200, check=True,
                )
                compiled.add(name)
            ns = "Nightfall.Observability." + module
            receipt = receipt_dir / (label + ".json")
            command = [
                sys.executable, str(BRIDGE), str(files[module].relative_to(ROOT)),
                "--workspace", str(workspace), "--timeout", "900", "--strict",
            ]
            for axiom in ALLOWED_AXIOMS:
                command.extend(["--allow-axiom", axiom])
            for name in names:
                command.extend(["--decl", ns + "." + name])
            command.extend(["--json-out", str(receipt)])
            print("AUDIT " + ", ".join(ns + "." + n for n in names), flush=True)
            subprocess.run(command, cwd=ROOT, check=True, timeout=1200)
            subprocess.run(
                [sys.executable, str(RECEIPT_CHECKER), str(receipt)],
                cwd=ROOT, check=True, timeout=100,
            )
            stage["status"] = "STRICT_LEAN_CERTIFIED"
            stage["receipt"] = str(receipt.relative_to(receipt_dir))
            print(f"PASS {label}", flush=True)
            print("::endgroup::", flush=True)
        manifest["status"] = "STRICT_TERMINAL_CERTIFIED"
        return 0
    except (Exception, KeyboardInterrupt) as exc:
        manifest["failure"] = repr(exc)
        print(f"::error::Q2 certificate stopped at {manifest['stages'][-1]['label']}: {exc}",
              file=sys.stderr, flush=True)
        return 1
    finally:
        manifest["compiled_module_count"] = len(compiled)
        manifest["completed_at_utc"] = datetime.now(timezone.utc).isoformat()
        path = receipt_dir / "manifest.json"
        path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
        summary = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary:
            with open(summary, "a", encoding="utf-8") as f:
                f.write("## Original-source Q2 pinned Lean certificate\n\n")
                f.write(f"Status: **{manifest['status']}** — original source commit "
                        f"\`{manifest['repository_commit']}\`.\n\n")
                f.write("| Stage | Evidence |\n|---|---|\n")
                for row in manifest["stages"]:
                    f.write(f"| {row['label']} | {row['status']} |\n")
                if manifest["failure"]:
                    f.write("\n**First failure:** \`" + manifest["failure"] + "\`\n")
                f.write("\nSource hashes, toolchain, Mathlib commit and receipts are retained in the artifact.\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace", default="/tmp/mathlib4")
    parser.add_argument("--receipt-dir", default="lean-receipts/q2-consolidated")
    parser.add_argument("--plan", action="store_true")
    sys.exit(run(parser.parse_args()))
