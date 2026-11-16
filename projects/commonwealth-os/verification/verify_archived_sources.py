#!/usr/bin/env python3
"""Verify the frozen Commonwealth archive and scoped finite-model tests.

No claim about real election secrecy, legal authority, human agency/equality
or operational coverage follows from passing these tests.
"""
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
OS_ROOT = REPO_ROOT / "projects" / "commonwealth-os"
MANIFEST = OS_ROOT / "SOURCE_ARCHIVE_MANIFEST_20261115.json"

def verify_manifest():
    records = json.loads(MANIFEST.read_text(encoding="utf-8"))["files"]
    assert len(records) == 81, f"expected 81 frozen records; found {len(records)}"
    seen = set()
    for item in records:
        path = Path(item["path"])
        assert not path.is_absolute() and ".." not in path.parts, item["path"]
        assert path.as_posix().startswith("projects/commonwealth-os/"), item["path"]
        assert path.as_posix() not in seen, f"duplicate source path {path}"
        seen.add(path.as_posix())
        source = REPO_ROOT / path
        assert source.is_file(), f"missing source {path}"
        blob = source.read_bytes()
        assert len(blob) == item["bytes"], f"size mismatch {path}"
        assert hashlib.sha256(blob).hexdigest() == item["sha256"], f"SHA-256 mismatch {path}"
    print(f"PASS: {len(records)} frozen source files match manifest")

def verify_mobile_fallback():
    html = (OS_ROOT / "prepilot/v1.3.1/living_voter_mobile_v1_3_1.html").read_text(encoding="utf-8")
    for marker in (
        'id="preview-survey"', 'id="preview-dashboard"', 'id="preview-issue"',
        'id="preview-vote"', 'id="preview-compare"', "Not Voting",
        "clerk.house.gov", "<script", "</html>",
    ):
        assert marker in html, f"missing fallback or source marker: {marker}"
    print("PASS: mobile JavaScript-off walkthrough and script markers")

def verify_finite_models():
    tasks = (
        [sys.executable, "-m", "unittest", "discover", "-s",
         "projects/commonwealth-os/architecture/v1.1/tests", "-p", "test_reference_guard.py"],
        [sys.executable, "projects/commonwealth-os/research/democratic-assurance/v0.3/audit_semantic_reuse_independent.py"],
        [sys.executable, "projects/commonwealth-os/research/democratic-assurance/v0.3/validate_passport_schema.py"],
    )
    for cmd in tasks:
        print("RUN:", " ".join(cmd), flush=True)
        subprocess.run(cmd, cwd=REPO_ROOT, check=True)

    # The archived v1.2 test assumes the original source-package layout.
    # Recreate that layout temporarily, never modifying the frozen files.
    with tempfile.TemporaryDirectory(prefix="commonwealth-replay-") as temp:
        root = Path(temp)
        sources = {
            "tests/test_prepilot.py": OS_ROOT / "prepilot/v1.2/tests/test_prepilot.py",
            "fixtures/official_rollcalls_2026.json": OS_ROOT / "prepilot/v1.2/fixtures/official_rollcalls_2026.json",
            "prepilot/living_voter_demo.html": OS_ROOT / "prepilot/v1.2/reference/living_voter_demo.html",
        }
        for rel, source in sources.items():
            target = root / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
        print("RUN: historical v1.2 assertions in isolated fixture layout", flush=True)
        subprocess.run([sys.executable, str(root / "tests/test_prepilot.py")], cwd=root, check=True)
    print("PASS: scoped finite, schema and prepilot checks")

if __name__ == "__main__":
    verify_manifest()
    verify_mobile_fallback()
    verify_finite_models()
