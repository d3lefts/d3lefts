#!/usr/bin/env python3
"""Prepare a source-minimized public development bundle, excluding the reference proof.

NOT a secrecy claim: the original solution is in the public GitHub history.
For genuine blind evaluation, disable network and use an unpublished held-out task.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import shutil
from grade_research_q2 import BERNSTEIN, TARGET, TOOLCHAIN, verify_trusted

STUB = """import ShiftedC4Bernstein

namespace Nightfall.ShiftedC4Scalar

theorem shifted_c4_from_strong_moments
    (a s c u e q : ℝ)
    (ha : 0 ≤ a) (hs : 0 ≤ s) (hc : 0 ≤ c) (hu : 0 ≤ u)
    (he : e = a^2+s)
    (hholder : e^3 ≤ u^2*q)
    (hfourth : q ≤ 3*e^2-2*a^4+4*a*c*s+c^2*s) :
    Real.sqrt e ≤ Real.sqrt 3*u+c/4 := by
  -- Candidate: replace this incomplete proof with a valid Lean derivation.
  -- The evaluator freezes the theorem statement in NightfallPolarisQ2Target.lean.

end Nightfall.ShiftedC4Scalar
"""
TASK = """# Research Q2 scalar proof integration — agent task

Prove the theorem already stated in ShiftedC4Scalar.lean without changing its
statement, hypotheses, import, namespace, or theorem name.

The trusted input ShiftedC4Bernstein.lean proves a sharp polynomial
nonnegativity fact on the square [0,1]^2; use it to deduce the c/4 bound from
the Holder condition and the fourth-moment upper bound.

Only ShiftedC4Scalar.lean is a candidate-editable file.
NightfallPolarisQ2Target.lean freezes the target statement. No extra axioms,
sorry, unsafe constructs, changes to imports, or external references.
Target compiler: leanprover/lean4:v4.36.0-rc2 with pinned Mathlib.
Return the completed .lean proof and a list of substantive unsuccessful
approaches; do not claim that a local compile proves historical novelty.

This public development task is not an unseen research discovery benchmark.
"""


def prepare(output: Path) -> dict:
    trusted = verify_trusted()
    if output.exists() and any(output.iterdir()):
        raise ValueError("output directory must be empty")
    output.mkdir(parents=True, exist_ok=True)
    for src in (BERNSTEIN, TARGET):
        shutil.copyfile(src, output / src.name)
        if hashlib.sha256((output / src.name).read_bytes()).hexdigest() != trusted[src.name]["sha256"]:
            raise ValueError("trusted copy mismatch")
    (output / "ShiftedC4Scalar.lean").write_text(STUB, encoding="utf-8")
    (output / "AGENT_TASK.md").write_text(TASK, encoding="utf-8")
    (output / "lean-toolchain").write_text(TOOLCHAIN + "\n", encoding="utf-8")
    manifest = {"schema": "nightfall.polaris.agent-input.v1",
                "editable_only": ["ShiftedC4Scalar.lean"],
                "toolchain": TOOLCHAIN,
                "public_development_task": True,
                "not_blind_or_uncontaminated": True,
                "files": {}}
    for p in sorted(output.iterdir()):
        if p.is_file():
            manifest["files"][p.name] = hashlib.sha256(p.read_bytes()).hexdigest()
    (output / "INPUT_MANIFEST.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    return manifest


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    print(json.dumps(prepare(args.output), indent=2, sort_keys=True))
