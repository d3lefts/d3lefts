#!/usr/bin/env python3
"""Advisory pre-publication ZIP scope and credential-risk inventory.

Use locally BEFORE uploading release assets. A clean report is not a complete
confidentiality review: PDFs, executables, huge files, and deeper nested ZIPs
need separate inspection. No data is sent to external services.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import re
import sys
import zipfile
from pathlib import Path

TEXT_SUFFIXES = {".txt", ".md", ".json", ".jsonl", ".py", ".tex", ".log", ".csv", ".yaml", ".yml", ".html", ".xml", ".ini", ".cfg", ".sh"}
PRIVATE_NAMES = {".env", ".env.local", "id_rsa", "id_ed25519", "credentials.json", "client_secret.json"}
PRIVATE_SUFFIXES = {".p12", ".pfx", ".pem", ".key"}
SCOPE_SEGMENTS = {"critical-line", "prime-frequency", "xi"}
SCOPE_FILENAMES = {"phaseshift_quantum_interference_referee_draft_20261027.pdf"}
SECRET_PATTERNS = {
    "github-token": re.compile(rb"(?:ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{70,})"),
    "openai-token": re.compile(rb"sk-(?:proj-)?[A-Za-z0-9_-]{20,}"),
    "slack-token": re.compile(rb"xox[baprs]-[A-Za-z0-9-]{20,}"),
    "private-key-block": re.compile(rb"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
}
TEXT_LIMIT = 1024 * 1024
NESTED_LIMIT = 32 * 1024 * 1024


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def inspect_zip(z: zipfile.ZipFile, prefix: str, depth: int, report: dict) -> None:
    names = set()
    for info in z.infolist():
        name = info.filename
        label = prefix + name
        normalized = name.replace("\\", "/")
        segments = normalized.lower().split("/")
        basename = segments[-1]
        report["entries_examined"] += 1
        if normalized in names:
            report["findings"].append({"path": label, "flag": "duplicate-zip-path"})
        names.add(normalized)
        if name.startswith("/") or ".." in segments or ":" in segments[0]:
            report["findings"].append({"path": label, "flag": "unsafe-zip-path"})
        if info.is_dir():
            continue
        if basename in PRIVATE_NAMES or Path(basename).suffix in PRIVATE_SUFFIXES:
            report["findings"].append({"path": label, "flag": "sensitive-filename-review"})
        if basename in SCOPE_FILENAMES or bool(SCOPE_SEGMENTS.intersection(segments)):
            report["findings"].append({"path": label, "flag": "research-publication-scope-review"})
        if info.file_size > NESTED_LIMIT:
            report["uninspected"].append({"path": label, "reason": "size-over-inspection-limit"})
            continue
        if basename.endswith(".zip"):
            if depth >= 1:
                report["uninspected"].append({"path": label, "reason": "nested-zip-depth-limit"})
                continue
            try:
                with zipfile.ZipFile(io.BytesIO(z.read(info))) as child:
                    inspect_zip(child, label + "::", depth + 1, report)
            except (ValueError, OSError, zipfile.BadZipFile, RuntimeError) as exc:
                report["findings"].append({"path": label, "flag": "nested-archive-unreadable", "error_type": type(exc).__name__})
            continue
        if Path(basename).suffix not in TEXT_SUFFIXES and basename not in PRIVATE_NAMES:
            report["uninspected"].append({"path": label, "reason": "non-text-content"})
            continue
        if info.file_size > TEXT_LIMIT:
            report["uninspected"].append({"path": label, "reason": "text-size-limit"})
            continue
        try:
            data = z.read(info)
        except (ValueError, OSError, RuntimeError, zipfile.BadZipFile):
            report["findings"].append({"path": label, "flag": "unreadable-member"})
            continue
        report["text_files_scanned"] += 1
        for kind, pattern in SECRET_PATTERNS.items():
            if pattern.search(data):
                report["findings"].append({"path": label, "flag": kind})


def audit(paths: list[Path]) -> dict:
    report = {
        "status": "PENDING",
        "scope": "advisory lexical and limited text scan; human approval required",
        "archives": [],
        "entries_examined": 0,
        "text_files_scanned": 0,
        "findings": [],
        "uninspected": [],
    }
    for path in paths:
        if not path.is_file():
            report["findings"].append({"path": str(path), "flag": "archive-missing"})
            continue
        report["archives"].append({"file": path.name, "sha256": digest(path), "bytes": path.stat().st_size})
        try:
            with zipfile.ZipFile(path) as z:
                inspect_zip(z, path.name + "::", 0, report)
                failure = z.testzip()
                if failure:
                    report["findings"].append({"path": path.name + "::" + failure, "flag": "zip-crc-failure"})
        except (ValueError, OSError, RuntimeError, zipfile.BadZipFile) as exc:
            report["findings"].append({"path": path.name, "flag": "archive-unreadable", "error_type": type(exc).__name__})
    report["status"] = "REVIEW_REQUIRED" if report["findings"] else "NO_FLAGS_IN_SCANNED_MATERIAL"
    return report


def self_test() -> None:
    import tempfile
    with tempfile.TemporaryDirectory() as folder:
        a = Path(folder) / "clean.zip"
        b = Path(folder) / "flags.zip"
        with zipfile.ZipFile(a, "w") as z:
            z.writestr("research/README.md", "Public research note")
        with zipfile.ZipFile(b, "w") as z:
            z.writestr("private/.env", "fake placeholder")
            z.writestr("research/PHASESHIFT_Quantum_Interference_Referee_Draft_20261027.pdf", b"%PDF-placeholder")
        clean, flagged = audit([a]), audit([b])
        assert clean["status"] == "NO_FLAGS_IN_SCANNED_MATERIAL", clean
        assert clean["entries_examined"] == 1, clean
        flags = {item["flag"] for item in flagged["findings"]}
        assert flags == {"research-publication-scope-review", "sensitive-filename-review"}, flags
        print("PASS: clean and flagged synthetic archives, scoped status and inventory")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archives", nargs="*", type=Path)
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    if not args.archives:
        parser.error("Provide at least one ZIP file, or use --self-test")
    report = audit(args.archives)
    print(json.dumps(report, indent=2))
    return 2 if report["findings"] else 0


if __name__ == "__main__":
    sys.exit(main())
