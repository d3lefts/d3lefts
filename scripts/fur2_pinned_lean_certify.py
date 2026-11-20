#!/usr/bin/env python3
"""Pinned, dependency-ordered finite FUR(2) Lean certificate.

Compile only the vendored AA dependency closure, original ProductRowBound,
and a new conditional FUR2AnchoredRow. This checks actual source statements,
not mere arithmetic output; the full FUR(2) analytic assumptions remain open.
"""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
VENDOR = ROOT / "research/nightfall/formalization/vendor/aaronson_ambainis"
PRODUCT = ROOT / "research/nightfall/formalization/product_space/ProductRowBound.lean"
OBSERVER = ROOT / "research/nightfall/formalization/observability"
RANGE = ROOT / "research/nightfall/formalization/fur/FUR2RangeEight.lean"
TARGET = ROOT / "research/nightfall/formalization/fur/FUR2AnchoredRow.lean"
WORK = Path("/tmp/mathlib4")
MATHLIB = "9d581dfff2e41de989072ea63abf3daf69311520"
TOOLCHAIN = "leanprover/lean4:v4.36.0-rc2"
NAMES = [
    "Nightfall.MixtureAA.FUR2.quadratic_coordinate_range_eight",
    "Nightfall.MixtureAA.FUR2.disagree_inactive_transitions",
    "Nightfall.MixtureAA.FUR2.anchored_transition_row",
    "Nightfall.MixtureAA.FUR2.fiber_uniform_row_of_quadratic_transition",
]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_map() -> dict[str, Path]:
    files = {
        p.relative_to(VENDOR).with_suffix("").as_posix().replace("/", "."): p
        for p in VENDOR.rglob("*.lean")
    }
    files.update({p.stem:p for p in OBSERVER.rglob("*.lean") if p.stem not in files})
    files.update({"ProductRowBound": PRODUCT, "FUR2AnchoredRow": TARGET,
                  "FUR2RangeEight": RANGE})
    if any(not path.is_file() for path in (PRODUCT, TARGET, RANGE)):
        raise RuntimeError("required source file absent")
    return files


def dependency_order(files: dict[str, Path]) -> list[str]:
    visited = {}
    order = []
    def visit(name):
        if name not in files:
            return
        if visited.get(name) == "done":
            return
        if visited.get(name) == "visiting":
            raise ValueError("import cycle: " + name)
        visited[name] = "visiting"
        for line in files[name].read_text().splitlines():
            if line.startswith("import "):
                for dep in line.split("--", 1)[0].split()[1:]:
                    visit(dep)
        visited[name] = "done"
        order.append(name)
    visit("FUR2RangeEight")
    visit("FUR2AnchoredRow")
    assert order[-1] == "FUR2AnchoredRow"
    assert "QuadraticRealizedRangeBudget" in order and "ProductRowBound" in order
    return order


def check_workspace():
    if (WORK/"lean-toolchain").read_text().strip() != TOOLCHAIN:
        raise RuntimeError("wrong Lean release")
    commit = subprocess.check_output(["git", "-C", str(WORK), "rev-parse", "HEAD"], text=True).strip()
    if commit != MATHLIB:
        raise RuntimeError("wrong Mathlib source")
    version = subprocess.check_output(["lake", "env", "lean", "--version"], cwd=WORK, text=True)
    if "version 4.36.0-rc2" not in version or "b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a" not in version:
        raise RuntimeError("compiler binary source identity mismatch")


def compile_order(order: list[str], files: dict[str,Path], receipt:Path):
    receipt.mkdir(parents=True, exist_ok=True)
    output = {"schema":"nightfall.fur2.anchored-lean.v1",
              "status":"unverified", "target":"FUR2AnchoredRow",
              "toolchain":TOOLCHAIN,"mathlib_commit":MATHLIB,
              "sources":[],"named_declarations":NAMES}
    out=WORK/".lake/build/lib/lean"
    for mod in order:
        relative=Path(*mod.split("."))
        dest=WORK/relative.with_suffix(".lean")
        dst_olean=out/relative.with_suffix(".olean")
        dest.parent.mkdir(parents=True, exist_ok=True)
        dst_olean.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(files[mod],dest)
        assert sha(files[mod]) == sha(dest)
        print("BUILD",mod,flush=True)
        subprocess.run(["lake","env","lean","-o",str(dst_olean),str(relative.with_suffix(".lean"))],
                       cwd=WORK,check=True,timeout=1000)
        output["sources"].append({"module":mod,"original_path":str(files[mod].relative_to(ROOT)),"sha256":sha(files[mod])})
    probe=WORK/"FUR2AxiomAudit.lean"
    probe.write_text(
       "import FUR2AnchoredRow\nimport FUR2RangeEight\n" +
       "\n".join("#print axioms "+name for name in NAMES) + "\n" +
       "\n".join("#check "+name for name in NAMES) + "\n")
    p=subprocess.run(["lake","env","lean",probe.name],cwd=WORK,text=True,
                     capture_output=True,timeout=1200)
    (receipt/"axiom-audit.txt").write_text(p.stdout+"\n"+p.stderr)
    if p.returncode:
        raise RuntimeError("Lean axiom audit did not compile; see receipt")
    permitted={"propext","Classical.choice","Quot.sound"}
    axlines=[line for line in p.stdout.splitlines() if "axioms:" in line]
    if len(axlines)!=len(NAMES):
        raise RuntimeError(f"expected {len(NAMES)} named axiom reports, got {len(axlines)}")
    for line in axlines:
        line=line.split("axioms:",1)[1].strip()
        if line.startswith("[") and line.endswith("]"):
            names={x.strip() for x in line[1:-1].split(",") if x.strip()}
        else:
            raise RuntimeError("unknown Lean axiom report format: "+line)
        if not names <= permitted:
            raise RuntimeError("nonstandard axioms: "+str(names-permitted))
    for mod in ("FUR2AnchoredRow","FUR2RangeEight"):
        p=subprocess.run(["lake","env","leanchecker",mod],cwd=WORK,
                         text=True,capture_output=True,timeout=900)
        (receipt/(mod+"-kernel-replay.txt")).write_text(p.stdout+"\n"+p.stderr)
        if p.returncode:
            raise RuntimeError("leanchecker rejected compiled terminal: "+mod)
    output["status"]="pinned-kernel-pass-conditional-theorem"
    output["compiled_modules"]=len(order)
    output["allowed_axioms"]=sorted(permitted)
    output["limitation"]="Only anchored-row and assembly with analytic hypotheses; not unconditional degree-two FUR"
    (receipt/"manifest.json").write_text(json.dumps(output,sort_keys=True,indent=2)+"\n")
    print("PASS",output["status"],len(order),"source modules")


if __name__=="__main__":
    files=source_map()
    order=dependency_order(files)
    if len(sys.argv)>1 and sys.argv[1]=="--plan":
        print(json.dumps({"modules":order,"count":len(order),
                          "new_source":str(TARGET.relative_to(ROOT)),
                          "full_FUR2":False},indent=2))
    else:
        check_workspace()
        compile_order(order,files,Path(sys.argv[1] if len(sys.argv)>1 else "lean-receipts/fur2"))
