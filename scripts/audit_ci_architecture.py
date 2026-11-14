#!/usr/bin/env python3
"""Fail-closed checks for NIGHTFALL Q2 CI architecture; no Lean installation.

Checks workflow triggers, concurrency, the exact terminal certificate order,
and protections against accidental reintroduction of dozens of overlapping
source builds. This is a governance test, NOT a mathematical proof.
"""
from __future__ import annotations

import argparse
import ast
import re
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PIPELINE = "nightfall-q2-consolidated-lean.yml"
EXPECTED = (
    "01-original-pair-fourth",
    "02-owned-pair-energy",
    "03-original-projection-jensen",
    "04-source-owned-fourth",
    "05-singleton-pair-parseval",
    "06-variance-owned-moment",
    "07-first-norm-L2-cap",
    "08-exact-Q2-terminal",
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def top_block(source: str, name: str) -> str:
    """Read one unindented YAML mapping key, without a YAML dependency."""
    lines = source.splitlines()
    matches = [i for i, line in enumerate(lines)
               if line.strip() == name + ":" and not line.startswith((" ", "\t"))]
    require(len(matches) == 1, f"Missing or ambiguous top-level {name}")
    start = matches[0] + 1
    end = start
    while end < len(lines):
        line = lines[end]
        if re.match(r"^[A-Za-z][A-Za-z0-9_-]*:", line):
            break
        end += 1
    return "\n".join(lines[start:end])


def trigger_events(source: str) -> set[str]:
    block = top_block(source, "on")
    events = set(re.findall(r"^  ([a-z_]+):", block, flags=re.MULTILINE))
    require(events, "Expected explicit YAML event mapping")
    return events


def proof_stages(source: str) -> tuple[tuple[str, str, tuple[str, ...]], ...]:
    tree = ast.parse(source)
    assignments = [n for n in tree.body
                   if isinstance(n, ast.Assign)
                   and any(isinstance(t, ast.Name) and t.id == "STAGES"
                           for t in n.targets)]
    require(len(assignments) == 1, "Missing or duplicated STAGES manifest")
    stages = ast.literal_eval(assignments[0].value)
    require(isinstance(stages, tuple), "STAGES must be a frozen tuple")
    for entry in stages:
        require(isinstance(entry, tuple) and len(entry) == 3
                and isinstance(entry[0], str)
                and isinstance(entry[1], str)
                and isinstance(entry[2], tuple) and entry[2],
                "Malformed stage in canonical certificate manifest")
    return stages


def audit(root: Path) -> dict:
    workflows = root / ".github" / "workflows"
    require(workflows.is_dir(), "Missing GitHub workflows directory")

    legacy = sorted(workflows.glob("nightfall-q2-*-v436.yml"))
    for path in legacy:
        events = trigger_events(path.read_text(encoding="utf-8"))
        require(events == {"workflow_dispatch"},
                f"Legacy Q2 kernel job auto-starts: {path.name}: {sorted(events)}")

    path = workflows / PIPELINE
    require(path.is_file(), "Missing consolidated Q2 pipeline")
    source = path.read_text(encoding="utf-8")
    events = trigger_events(source)
    require(events == {"pull_request", "workflow_dispatch"},
            "Q2 pipeline must be PR/explicit-dispatch only (no push duplicates)")
    concurrency = top_block(source, "concurrency")
    require("cancel-in-progress: true" in concurrency,
            "Q2 pipeline must cancel superseded commits")
    require("github.event.pull_request.head.ref" in concurrency,
            "Q2 concurrency must be keyed to the source PR branch")
    require("branches: [main]" in top_block(source, "on"),
            "Q2 PR gate must target canonical main")
    require("startsWith(github.event.pull_request.head.ref, 'nightfall-q2-')" in source,
            "Q2 runner must be restricted to a Q2 source branch")
    require("head.repo.full_name == github.repository" in source,
            "Q2 cleanup requires same-repository PR ownership")
    require("run.id === context.runId" in source,
            "Q2 cleanup may not cancel its own run")
    require("run.head_sha === head" in source,
            "Q2 cleanup must protect current-source-head runs")
    require("actions: write" in source and "contents: read" in source,
            "Q2 cleanup requires explicitly scoped Actions permissions")
    require("scripts/nightfall_q2_certify.py" in source,
            "Consolidated workflow must invoke source manifest compiler")

    script_path = root / "scripts" / "nightfall_q2_certify.py"
    require(script_path.is_file(), "Missing single DAG compilation script")
    script = script_path.read_text(encoding="utf-8")
    stages = proof_stages(script)
    require(tuple(s[0] for s in stages) == EXPECTED,
            "Q2 source proof stage ordering changed without review")
    require(stages[-1][1] == "ActualSourceQ2Terminal"
            and stages[-1][2] == ("actual_source_q2_terminal",),
            "Terminal declaration changed without explicit proof review")
    require(len(set(s[1] for s in stages)) == len(stages),
            "Duplicated source module in Q2 proof stage manifest")
    require("compiled.add(name)" in script and "if name in compiled:" in script,
            "Q2 compiler must memoize transitive module compilation")
    require("check_receipts.py" in script and "--strict" in script,
            "Every certificate stage must use strict declaration receipts")

    return {
        "legacy_manual_only": len(legacy),
        "automatic_q2_kernel_pipelines": 1,
        "pinned_declaration_stages": len(stages),
        "terminal": "ActualSourceQ2Terminal.actual_source_q2_terminal",
        "policy_certifies_math": False,
    }


def self_test() -> None:
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        wf = root / ".github/workflows"
        scripts = root / "scripts"
        wf.mkdir(parents=True)
        scripts.mkdir()
        good = (ROOT / ".github/workflows" / PIPELINE).read_text()
        good_script = (ROOT / "scripts/nightfall_q2_certify.py").read_text()
        (wf / PIPELINE).write_text(good)
        (scripts / "nightfall_q2_certify.py").write_text(good_script)
        old = wf / "nightfall-q2-old-v436.yml"
        old.write_text("name: old\non:\n  workflow_dispatch:\njobs:\n  smoke:\n    runs-on: ubuntu-latest\n")
        require(audit(root)["legacy_manual_only"] == 1, "Good fixture rejected")

        for event in ("push", "pull_request", "workflow_run", "schedule"):
            old.write_text("name: old\non:\n  workflow_dispatch:\n  "
                           + event + ":\njobs:\n  smoke:\n    runs-on: ubuntu-latest\n")
            try:
                audit(root)
            except ValueError:
                pass
            else:
                raise AssertionError("Missed legacy autostart: " + event)
        old.write_text("name: old\non:\n  workflow_dispatch:\njobs:\n  smoke:\n    runs-on: ubuntu-latest\n")

        (wf / PIPELINE).write_text(good.replace(
            "cancel-in-progress: true", "cancel-in-progress: false", 1))
        try:
            audit(root)
        except ValueError:
            pass
        else:
            raise AssertionError("Missed lost stale-run cancellation")

        (wf / PIPELINE).write_text(good)
        (scripts / "nightfall_q2_certify.py").write_text(good_script.replace(
            '"08-exact-Q2-terminal"', '"08-exact-Q2-UNVERIFIED"', 1))
        try:
            audit(root)
        except ValueError:
            pass
        else:
            raise AssertionError("Missed terminal certificate manifest drift")
    print("PASS: 7 Q2 CI governance negative/positive controls")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
    print("PASS Q2 CI governance:", audit(ROOT))
