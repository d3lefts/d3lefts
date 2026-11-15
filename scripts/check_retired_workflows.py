#!/usr/bin/env python3
"""Fail closed on loss/tampering/reactivation of archived Q2 diagnostic workflows.

The historical YAML is preserved byte-for-byte as a Git blob outside
.github/workflows/ so it cannot occupy the live Actions menu. This checks
source custody, not mathematical proof or CI success.
"""
from __future__ import annotations

import argparse
import hashlib
import re
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARCHIVE = Path("research/archive/workflows/q2-lean436")
ACTIVE = Path(".github/workflows")
EXPECTED = {
    "nightfall-q2-actual-matching-v436.yml": "6a54f4634f39d91eccb1887c6a2915c9c83ffab5",
    "nightfall-q2-anova-current-pin-v436.yml": "3ab2be49978400157986a5fdad6e8fc0d720beb2",
    "nightfall-q2-attained-matching-cover-v436.yml": "6d81938d9d5d5d6c57431f921be7f477d65c4e94",
    "nightfall-q2-integrated-hilbert-jensen-v436.yml": "f3ef1fd3e981da355611fae8471b552d97129286",
    "nightfall-q2-pair-amplitudes-v436.yml": "8c7e6e3dadadb0108b74ea2459423877af7ef3cb",
    "nightfall-q2-pair-source-v436.yml": "47a47dec30fcac5404bfac31f8d58398321d9464",
    "nightfall-q2-quantitative-v436.yml": "3414f88d5eed6196338bc19abef2080de08753eb",
    "nightfall-q2-soft-source-noise-v436.yml": "5ac4c40fc1826f33ced867db8e9ff1ccb0fb389a",
    "nightfall-q2-source-degree-two-sections-v436.yml": "54f9f2d83a86c483a8ed671f810dd42789b98255",
    "nightfall-q2-source-finite-pair-moment-v436.yml": "5e7c2dccdb28797af48a2b3bca5a43cd4878dd7b",
    "nightfall-q2-source-merge-tower-v436.yml": "bf4987f4ebde87d3270d5171ce85475a6caddfc0",
    "nightfall-q2-source-rectangle-v436.yml": "2218f89975405ef5fc7a5565bee84ba9b60abdd6",
    "nightfall-q2-source-sample-law-v436.yml": "520dc0322df084c22790a68adbfc40681ddbdffe",
    "nightfall-q2-source-variance-energy-v436.yml": "79d287b0a9d04ec2c7a85a1a1d37505d5e3d60c2",
}

def require(ok: bool, reason: str) -> None:
    if not ok:
        raise AssertionError(reason)

def git_blob_sha(payload: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(payload)).encode() + b"\0" + payload).hexdigest()

def events(source: str) -> set[str]:
    match = re.search(r"(?ms)^on:\s*\n(.*?)(?=^[A-Za-z][\w-]*:|\Z)", source)
    require(match is not None, "No top-level 'on' event block")
    return set(re.findall(r"(?m)^  ([a-z_]+):", match.group(1)))

def verify_archive(root: Path, expected: dict[str, str] = EXPECTED) -> dict:
    archive_dir = root / ARCHIVE
    require(archive_dir.is_dir(), "Missing retired workflow archive")
    found = {p.name for p in archive_dir.glob("*.yml")}
    require(found == set(expected), f"Archive inventory drift: missing={sorted(set(expected)-found)} extra={sorted(found-set(expected))}")
    total = 0
    for filename, original_sha in expected.items():
        retired = archive_dir / filename
        require(not (root / ACTIVE / filename).exists(),
                f"Retired Q2 job reactivated in GitHub Actions: {filename}")
        payload = retired.read_bytes()
        require(git_blob_sha(payload) == original_sha,
                f"Historical exact-source custody mismatch: {filename}")
        require(events(payload.decode("utf-8")) == {"workflow_dispatch"},
                f"Archived job was not manual-only: {filename}")
        total += len(payload)
    return {"archived_manual_only": len(expected),
            "exact_original_bytes": total,
            "active_reactivated": 0,
            "canonical_runner": "nightfall-q2-consolidated-lean.yml",
            "proof_certification": False}

def self_test() -> None:
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        d = root / ARCHIVE
        live = root / ACTIVE
        d.mkdir(parents=True)
        live.mkdir(parents=True)
        filename = "example-v436.yml"
        original = b"name: historical\non:\n  workflow_dispatch:\njobs:\n  smoke:\n    runs-on: ubuntu-latest\n"
        (d / filename).write_bytes(original)
        digest = git_blob_sha(original)
        expected = {filename: digest}
        assert verify_archive(root, expected)["archived_manual_only"] == 1
        (d / filename).write_bytes(original + b"# accidental rewrite\n")
        try:
            verify_archive(root, expected)
        except AssertionError:
            pass
        else:
            raise AssertionError("Failed to detect source tampering")
        (d / filename).write_bytes(original)
        (live / filename).write_bytes(original)
        try:
            verify_archive(root, expected)
        except AssertionError:
            pass
        else:
            raise AssertionError("Failed to detect reactivation")
        (live / filename).unlink()
        try:
            verify_archive(root, {"missing-v436.yml": digest})
        except AssertionError:
            pass
        else:
            raise AssertionError("Failed to detect inventory drift")
        assert events("name: unsafe\non:\n  push:\n") == {"push"}
        assert verify_archive(root, expected)["active_reactivated"] == 0
    print("PASS: archived workflow source / trigger / reactivation negative controls")

if __name__ == "__main__":
    cli = argparse.ArgumentParser()
    cli.add_argument("--self-test", action="store_true")
    args = cli.parse_args()
    if args.self_test:
        self_test()
    print("PASS: retired Q2 diagnostic custody", verify_archive(ROOT))
