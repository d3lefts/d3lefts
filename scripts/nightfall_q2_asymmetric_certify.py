#!/usr/bin/env python3
"""Strict asymmetric-product c/5 audit. Never upgrades the unrestricted shifted claim."""
from __future__ import annotations
import hashlib
import json
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from nightfall_q2_certify import local_sources, closure  # noqa: E402

WORK = Path("/tmp/mathlib4")
OUT = ROOT / "lean-receipts/q2-asymmetric-c5"
OUT.mkdir(parents=True, exist_ok=True)
SOURCE_DIR = ROOT / "research/nightfall/formalization"
DECLS = {
  "Q2ShiftedPureC5": [
    "Nightfall.Q2Shifted.PureC5.fifth_interpolation_of_fourth",
    "Nightfall.Q2Shifted.PureC5.fifth_of_zero_odd_term_moments",
    "Nightfall.Q2Shifted.PureC5.fifth_for_pure_centered_sum",
    "Nightfall.Q2Shifted.PureC5.fifth_from_centered_cubic",
  ],
  "Q2ShiftedConditionalTargets": [
    "Nightfall.Q2Shifted.ConditionalTargets.conditional_shifted_budget",
    "Nightfall.Q2Shifted.ConditionalTargets.conditional_coefficient_99",
    "Nightfall.Q2Shifted.ConditionalTargets.fifth_envelope_counterexample_exact",
    "Nightfall.Q2Shifted.ConditionalTargets.fifth_envelope_not_universal",
  ],
  "ActualSourcePureQ2Fifth": [
    "Nightfall.Observability.ActualSourcePureQ2Fifth.actual_source_pure_q2_given_section_budget",
    "Nightfall.Observability.ActualSourcePureQ2Fifth.actual_source_pure_q2_239_unconditional",
    "Nightfall.Observability.ActualSourcePureQ2Fifth.actual_source_pure_q2_105_given_five_section",
    "Nightfall.Observability.ActualSourcePureQ2Fifth.actual_source_pure_q2_99_given_sharp_section",
  ],
}

def git_sha(folder: Path) -> str:
    return subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=folder, text=True).strip()

def run(cmd: list[str], cwd: Path = ROOT, timeout: int = 1200):
    print("RUN", " ".join(map(str, cmd)), flush=True)
    subprocess.run(cmd, cwd=cwd, check=True, timeout=timeout)

def main():
    manifest = {
      "status": "NOT_CERTIFIED", "repository_sha": git_sha(ROOT),
      "decls": DECLS, "compiled": [], "source_sha256": {},
      "mathematical_scope": "FINITE arbitrary heterogeneous asymmetric nonnegative normalized product laws; zero atoms allowed; pure degree <=2 with zero singleton sectors only",
      "excluded_claim": "general shifted c/5 with nonzero singleton; unrestricted coefficient 99.263",
    }
    try:
        pin = (WORK / "lean-toolchain").read_text().strip()
        assert pin == "leanprover/lean4:v4.36.0-rc2", ("incorrect Lean pin", pin)
        manifest["lean_pin"] = pin
        mathlib = git_sha(WORK)
        assert mathlib == "9d581dfff2e41de989072ea63abf3daf69311520", ("incorrect Mathlib pin", mathlib)
        manifest["mathlib_sha"] = mathlib
        files = local_sources()
        orders = {root: closure(root, files) for root in DECLS}
        ordered = list(dict.fromkeys(name for root in DECLS for name in orders[root]))
        out = WORK / ".lake/build/lib/lean"
        out.mkdir(parents=True, exist_ok=True)
        for name in ordered:
            src = files[name]
            dst = WORK / (name + ".lean")
            shutil.copyfile(src, dst)
            assert hashlib.sha256(src.read_bytes()).digest() == hashlib.sha256(dst.read_bytes()).digest()
            manifest["source_sha256"][str(src.relative_to(ROOT))] = hashlib.sha256(src.read_bytes()).hexdigest()
            run(["lake", "env", "lean", "-o", str(out / (name+".olean")), name+".lean"], cwd=WORK)
            manifest["compiled"].append(name)
        for name, decls in DECLS.items():
            src = files[name]
            receipt = OUT / (name + ".json")
            cmd = [sys.executable, "scripts/lean_bridge.py", str(src.relative_to(ROOT)),
                   "--workspace", str(WORK), "--timeout", "900", "--strict"]
            for ax in ["Classical.choice", "Quot.sound", "propext"]:
                cmd += ["--allow-axiom", ax]
            for decl in decls:
                cmd += ["--decl", decl]
            cmd += ["--json-out", str(receipt)]
            run(cmd)
            run([sys.executable, "research/nightfall/formalization/product_space/check_receipts.py", str(receipt)])
        manifest["status"] = "STRICT_C5_PURE_SOURCE_CERTIFIED"
        return 0
    except Exception as exc:
        manifest["failure"] = repr(exc)
        print("FAIL-CLOSED:", repr(exc), file=sys.stderr, flush=True)
        return 1
    finally:
        manifest["completed_at_utc"] = datetime.now(timezone.utc).isoformat()
        (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2, sort_keys=True)+"\n")

if __name__ == "__main__":
    raise SystemExit(main())
