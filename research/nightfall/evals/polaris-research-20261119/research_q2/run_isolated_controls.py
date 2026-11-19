#!/usr/bin/env python3
"""Positive/negative *real Docker* smoke matrix for the Polaris Q2 proof grader.

The 3 controls check actual execution and expected rejection in a dedicated
ephemeral Docker runtime. They do not certify container escape resistance,
novel mathematics, or frontier-agent performance.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
from datetime import datetime, timezone

from grade_research_q2 import ROOT, DECL

Q2 = Path(__file__).resolve().parent
CONTROLS = (
    ("positive_public_reference",
     ROOT / "research/nightfall/formalization/observability/ShiftedC4Scalar.lean",
     "pass", None),
    ("negative_weakened_statement", Q2 / "examples/weakened_to_true.lean",
     "reject", "NightfallPolarisQ2Target.lean"),
    ("negative_incorrect_proof_term", Q2 / "examples/invalid_proof_term.lean",
     "reject", "ShiftedC4Scalar.lean"),
)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def execute(image: str, out: Path, timeout: int) -> int:
    out.mkdir(parents=True, exist_ok=False)
    report = {
        "schema": "nightfall.polaris.isolated-controls.v1",
        "run_time_utc": datetime.now(timezone.utc).isoformat(),
        "image": image,
        "target": DECL,
        "benchmark_status": "development-runtime-smoke-only",
        "controls": [],
    }
    failures = []
    for name, candidate, expected, marker in CONTROLS:
        folder = out / name
        cmd = [
            sys.executable, str(Q2 / "sandbox_runner.py"),
            "--candidate", str(candidate), "--image", image,
            "--output", str(folder),
        ]
        try:
            result = subprocess.run(cmd, cwd=ROOT, text=True, capture_output=True,
                                    timeout=timeout, encoding="utf-8", errors="replace")
            success_receipt = folder / "proofgraph-q2.json"
            if expected == "pass":
                data = json.loads(success_receipt.read_text()) if success_receipt.is_file() else {}
                valid = (result.returncode == 0 and data.get("status") == "pass"
                         and data.get("target") == DECL
                         and data.get("host_sandbox_wrapper", {}).get("image") == image
                         and len(data.get("steps", [])) == 6)
            else:
                valid = (result.returncode != 0 and not success_receipt.exists()
                         and "sandbox candidate rejected:" in result.stderr
                         and "Lean command failure" in result.stderr
                         and marker in result.stderr)
            outcome = {
                "name": name,
                "candidate_sha256": sha(candidate),
                "expected": expected,
                "exit_code": result.returncode,
                "rejection_marker": marker,
                "passed": valid,
                "stderr_tail": result.stderr[-2500:],
                "stdout_sha256": hashlib.sha256(result.stdout.encode()).hexdigest(),
                "host_receipt_path": str(success_receipt.relative_to(out)) if success_receipt.exists() else None,
            }
            if not valid:
                failures.append(name)
        except (OSError, ValueError, subprocess.TimeoutExpired) as exc:
            outcome = {"name": name, "passed": False, "error": repr(exc)}
            failures.append(name)
        report["controls"].append(outcome)
        print(f"{'PASS' if outcome['passed'] else 'FAIL'} {name}", flush=True)
    report["status"] = "pass" if not failures else "fail"
    report["failures"] = failures
    report["controls_passed"] = sum(c["passed"] for c in report["controls"])
    (out / "control-matrix.json").write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(json.dumps({"status": report["status"], "controls_passed": report["controls_passed"],
                      "total": len(CONTROLS)}, indent=2))
    return 0 if not failures else 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--image", required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--timeout", type=int, default=1500)
    args = parser.parse_args()
    return execute(args.image, args.output, args.timeout)


if __name__ == "__main__":
    raise SystemExit(main())
