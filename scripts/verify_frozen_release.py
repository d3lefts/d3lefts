#!/usr/bin/env python3
"""Verify frozen evidence ZIP identity, ZIP integrity and exact 131072-cell witness.

This tests only claimed finite arithmetic and original archive bytes. Formal proof
of the real-shift reduction and imported source inequalities remain separate gates.
"""
from __future__ import annotations
import hashlib
import io
import json
import sys
import tempfile
import zipfile
from pathlib import Path

from verify_erdos_independent import verify

EXPECTED = {
    "NIGHTFALL_GitHub_Release_2026-10-27.zip": (
        "77665ced561a9ae1d882baffdc5417188166049c27267afd6cb7b408ec9559cb", 214
    ),
    "NIGHTFALL_Expanded_Research_2026-10-28.zip": (
        "fca5dba595475783e3482d72d5e4888e76b91c38052a0589577f0fde578b8275", 226
    ),
}
NESTED = "research/nightfall/artifacts/NIGHTFALL_Meta_Paper_v2.0_Source_and_Evidence.zip"
WITNESS = "release/reproduction/overlap_latest/NIGHTFALL_Erdos_Latest/heights_u70.txt"

def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for data in iter(lambda: f.read(1024 * 1024), b""):
            h.update(data)
    return h.hexdigest()

def assert_safe_zip(z: zipfile.ZipFile):
    paths = z.namelist()
    if len(paths) != len(set(paths)):
        raise ValueError("ZIP contains duplicate names")
    for name in paths:
        parts = name.replace("\\", "/").split("/")
        if name.startswith("/") or ".." in parts or ":" in parts[0]:
            raise ValueError(f"Unsafe ZIP path: {name}")

def check_archive(path: Path, digest: str, entries: int) -> dict[str, object]:
    if not path.is_file():
        raise FileNotFoundError(f"Frozen release asset is missing: {path}")
    actual = sha256(path)
    if actual != digest:
        raise ValueError(f"Archive hash mismatch {path.name}: {actual}")
    with zipfile.ZipFile(path) as z:
        assert_safe_zip(z)
        if len(z.namelist()) != entries:
            raise ValueError(f"ZIP entry count mismatch for {path.name}")
        bad = z.testzip()
        if bad:
            raise ValueError(f"CRC error in {path.name}: {bad}")
    return {
        "filename": path.name,
        "sha256": actual,
        "entry_count": entries,
        "crc": "PASS",
    }

def main(directory: Path) -> dict[str, object]:
    archives = [
        check_archive(directory / name, digest, count)
        for name, (digest, count) in EXPECTED.items()
    ]
    with zipfile.ZipFile(directory / next(iter(EXPECTED))) as z:
        data = z.read(NESTED)
    with zipfile.ZipFile(io.BytesIO(data)) as nested:
        assert_safe_zip(nested)
        raw = nested.read(WITNESS)
    with tempfile.TemporaryDirectory(prefix="nightfall-verify-") as d:
        file = Path(d) / "heights_u70.txt"
        file.write_bytes(raw)
        result = verify(file)
    return {
        "status": "PASS",
        "date_class": "automated finite witness replay; no theorem-status promotion",
        "archives": archives,
        "erdos_exact_131072": result,
        "limitations": [
            "Independent human/specialist peer review has not been claimed",
            "Complete real-shift analytic reduction is outside this script's scope",
            "Werner source SDP inequalities are outside this script's scope",
            "Official Arena accepted-entry identity is a different evidence record",
        ],
    }

if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("Usage: python3 scripts/verify_frozen_release.py ARCHIVE_DIRECTORY")
    try:
        print(json.dumps(main(Path(sys.argv[1])), indent=2))
    except Exception as e:
        print(json.dumps({"status": "FAIL", "error": str(e)}, indent=2), file=sys.stderr)
        raise SystemExit(1)
