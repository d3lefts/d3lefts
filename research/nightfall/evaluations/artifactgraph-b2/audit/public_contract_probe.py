#!/usr/bin/env python3
"""ArtifactGraph-B2 / independent PUBLIC contract probes.

This is an internal, second-implementation checker constructed from ISSUE.md.
It is NOT the author's 25-case withheld grader, an independent human review,
a blind agent score, or a sandbox. Only run on a trusted source checkout.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
import tempfile
from pathlib import Path

PROJECT = Path(__file__).resolve().parents[1]
CANDIDATE = PROJECT / "candidate"
sys.path.insert(0, str(CANDIDATE))
from artifactgraph import Builder, GraphError  # noqa: E402


class Violation(AssertionError):
    pass


def check(predicate: bool, explanation: str):
    if not predicate:
        raise Violation(explanation)


def must_raise_grapherror(operation, explanation: str):
    try:
        operation()
    except GraphError:
        return
    raise Violation(explanation)


def workspace(home: Path, nodes: dict, sources: dict[str, bytes]) -> Path:
    root = home / "workspace"
    (root / "src").mkdir(parents=True)
    for relative, content in sources.items():
        path = root / "src" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
    manifest(root, nodes)
    return root


def node(source: str, deps=()):
    return {"source": source, "deps": list(deps)}


def manifest(root: Path, nodes: dict, version=1):
    (root / "graph.json").write_text(
        json.dumps({"version": version, "nodes": nodes}, sort_keys=True),
        encoding="utf-8",
    )


def object_path(root: Path, sha: str) -> Path:
    return root / ".artifactgraph" / "objects" / sha


def index_path(root: Path) -> Path:
    return root / ".artifactgraph" / "index.json"


def assert_normal_build(home):
    root = workspace(home, {"core": node("core.txt"), "app": node("app.txt", ["core"])},
                     {"core.txt": b"hello", "app.txt": b"run"})
    result = Builder(root).build(["app"])
    check(result.built == ("core", "app"), "wrong initial dependency order")
    check(set(result.outputs) == {"core", "app"}, "wrong output closure")
    check(Builder(root).read_output("app").startswith(b"AGB2\n"),
          "expected starter framing not preserved")  # informational seed guard


def assert_reopened_cache(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"stable"})
    a = Builder(root).build(["n"])
    b = Builder(root).build(["n"])
    check(a.outputs == b.outputs and b.reused == ("n",) and not b.built,
          "cross-instance cache did not persist")


def assert_unknown_target(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"x"})
    must_raise_grapherror(lambda: Builder(root).build(["missing"]),
                          "unknown target was accepted")


def assert_duplicate_dependencies(home):
    root = workspace(home, {"n": node("n.txt"),
                            "app": node("a.txt", ["n", "n"])},
                     {"n.txt": b"n", "a.txt": b"a"})
    must_raise_grapherror(lambda: Builder(root).build(["app"]),
                          "duplicate dependency names were accepted")


def assert_missing_object_repair(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"one"})
    first = Builder(root).build(["n"])
    object_path(root, first.outputs["n"]).unlink()
    again = Builder(root).build(["n"])
    check(again.built == ("n",), "missing object reused")
    check(object_path(root, again.outputs["n"]).is_file(), "missing object not rebuilt")
    check(Builder(root).read_output("n") == Builder(root).read_output("n"),
          "reopened object did not persist")


def assert_invalid_index_shape(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"one"})
    Builder(root).build(["n"])
    index_path(root).write_text('{"version":1,"entries":"not an object"}', encoding="utf-8")
    must_raise_grapherror(lambda: Builder(root).build(["n"]),
                          "malformed index accepted")


def assert_binary_source(home):
    raw = bytes([0, 255, 10, 128, 13])
    root = workspace(home, {"n": node("n.dat")}, {"n.dat": raw})
    Builder(root).build(["n"])
    check(Builder(root).read_output("n").endswith(raw), "binary source not represented")


def assert_deterministic_clean_rebuild(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"same"})
    a = Builder(root).build(["n"]).outputs["n"]
    shutil.rmtree(root / ".artifactgraph")
    b = Builder(root).build(["n"]).outputs["n"]
    check(a == b, "identical clean source led to different output digest")


def assert_absolute_source_rejected(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"valid"})
    outside = root / "outside.txt"
    outside.write_bytes(b"secret")
    manifest(root, {"n": node(str(outside))})
    must_raise_grapherror(lambda: Builder(root).build(["n"]),
                          "absolute source path was accepted")


def assert_unreachable_cycle_rejected(home):
    root = workspace(home, {"target": node("t.txt"),
                            "x": node("x.txt", ["y"]),
                            "y": node("y.txt", ["x"])},
                     {"t.txt": b"t", "x.txt": b"x", "y.txt": b"y"})
    must_raise_grapherror(lambda: Builder(root).build(["target"]),
                          "unreachable manifest cycle was accepted")


def assert_parent_escape_rejected(home):
    root = workspace(home, {"n": node("../outside.txt")}, {})
    (root / "outside.txt").write_bytes(b"outside source boundary")
    must_raise_grapherror(lambda: Builder(root).build(["n"]),
                          "existing ../ path outside src was admitted")


def assert_symlink_escape_rejected(home):
    root = workspace(home, {"n": node("escape.txt")}, {})
    outside = root / "outside.txt"
    outside.write_bytes(b"outside source boundary")
    (root / "src" / "escape.txt").symlink_to(outside)
    must_raise_grapherror(lambda: Builder(root).build(["n"]),
                          "symlink outside src was admitted")


def assert_source_bytes_not_mtime(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"before"})
    source = root / "src" / "n.txt"
    earlier = Builder(root).build(["n"]).outputs["n"]
    state = source.stat()
    source.write_bytes(b"after")
    os.utime(source, ns=(state.st_atime_ns, state.st_mtime_ns))
    newer = Builder(root).build(["n"])
    check(newer.outputs["n"] != earlier and newer.built == ("n",),
          "modified source bytes with unchanged mtime were wrongly reused")


def assert_touch_only_does_not_rebuild(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"stable"})
    source = root / "src" / "n.txt"
    initial = Builder(root).build(["n"])
    state = source.stat()
    os.utime(source, ns=(state.st_atime_ns, state.st_mtime_ns + 5_000_000_000))
    second = Builder(root).build(["n"])
    check(second.reused == ("n",) and not second.built and
          second.outputs == initial.outputs, "mtime-only touch caused rebuild")


def assert_dependency_permutation_changes_identity(home):
    root = workspace(home, {
        "first": node("a.txt"),
        "second": node("b.txt"),
        "consumer": node("c.txt", ["first", "second"])
    }, {"a.txt": b"A", "b.txt": b"B", "c.txt": b"C"})
    before = Builder(root).build(["consumer"]).outputs["consumer"]
    manifest(root, {"first": node("a.txt"), "second": node("b.txt"),
                    "consumer": node("c.txt", ["second", "first"])})
    after = Builder(root).build(["consumer"])
    check(after.outputs["consumer"] != before and "consumer" in after.built,
          "ordered dependency identity was lost")


def assert_corrupt_cached_object_is_regenerated(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"one"})
    first = Builder(root).build(["n"]).outputs["n"]
    object_path(root, first).write_bytes(b"not-the-content-hash")
    result = Builder(root).build(["n"])
    check(result.built == ("n",) and not result.reused,
          "corrupted cached object was reused")
    check(hashlib.sha256(object_path(root, result.outputs["n"]).read_bytes()).hexdigest()
          == result.outputs["n"], "repaired object digest not valid")


def assert_read_rejects_corrupt_object(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"one"})
    first = Builder(root).build(["n"]).outputs["n"]
    object_path(root, first).write_bytes(b"not-the-content-hash")
    must_raise_grapherror(lambda: Builder(root).read_output("n"),
                          "read_output returned corrupted object")


def assert_validation_failure_preserves_index(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"original"})
    Builder(root).build(["n"])
    before = index_path(root).read_bytes()
    (root / "src" / "n.txt").write_bytes(b"changed")
    manifest(root, {"n": node("n.txt"), "bad": node("missing.txt", ["n"])})
    must_raise_grapherror(lambda: Builder(root).build(["bad"]),
                          "source validation failure was unexpectedly ignored")
    check(index_path(root).read_bytes() == before,
          "failed build committed partial index before checking all sources")


def assert_manifest_bool_version_rejected(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"n"})
    manifest(root, {"n": node("n.txt")}, version=True)
    must_raise_grapherror(lambda: Builder(root).build(["n"]),
                          "JSON true was accepted as the numeric manifest version 1")


def assert_index_bool_version_rejected(home):
    root = workspace(home, {"n": node("n.txt")}, {"n.txt": b"n"})
    Builder(root).build(["n"])
    idx = json.loads(index_path(root).read_text(encoding="utf-8"))
    idx["version"] = True
    index_path(root).write_text(json.dumps(idx), encoding="utf-8")
    must_raise_grapherror(lambda: Builder(root).build(["n"]),
                          "JSON true was accepted as the numeric index version 1")


# Independently preregistered; no hidden grader, reference or author-run outputs
# were used to derive the expected seed profile. CI must fail on any mismatch.
CASES = [
    ("normal_first_build", assert_normal_build, "PASS"),
    ("reopened_cache", assert_reopened_cache, "PASS"),
    ("unknown_target", assert_unknown_target, "PASS"),
    ("duplicate_dependencies", assert_duplicate_dependencies, "PASS"),
    ("missing_object_repair", assert_missing_object_repair, "PASS"),
    ("malformed_index", assert_invalid_index_shape, "PASS"),
    ("binary_source", assert_binary_source, "PASS"),
    ("deterministic_clean_build", assert_deterministic_clean_rebuild, "PASS"),
    ("absolute_path", assert_absolute_source_rejected, "PASS"),
    ("unreachable_cycle", assert_unreachable_cycle_rejected, "VIOLATION"),
    ("parent_escape", assert_parent_escape_rejected, "VIOLATION"),
    ("symlink_escape", assert_symlink_escape_rejected, "VIOLATION"),
    ("source_bytes_no_mtime", assert_source_bytes_not_mtime, "VIOLATION"),
    ("touch_only", assert_touch_only_does_not_rebuild, "VIOLATION"),
    ("ordered_deps", assert_dependency_permutation_changes_identity, "VIOLATION"),
    ("corrupt_cache_rebuild", assert_corrupt_cached_object_is_regenerated, "VIOLATION"),
    ("corrupt_output_read", assert_read_rejects_corrupt_object, "VIOLATION"),
    ("atomic_failure", assert_validation_failure_preserves_index, "VIOLATION"),
    ("manifest_bool_version", assert_manifest_bool_version_rejected, "VIOLATION"),
    ("index_bool_version", assert_index_bool_version_rejected, "VIOLATION"),
]


def run():
    rows = []
    for name, operation, expected in CASES:
        with tempfile.TemporaryDirectory(prefix="nf-b2-") as d:
            try:
                operation(Path(d))
            except Violation as exc:
                status, detail = "VIOLATION", str(exc)
            except Exception as exc:
                status, detail = "ERROR", type(exc).__name__ + ": " + str(exc)
            else:
                status, detail = "PASS", "semantic contract check satisfied"
        rows.append({"id": name, "expected_seed": expected,
                     "observed": status, "detail": detail})
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["seed", "candidate", "observe"], default="observe")
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()
    rows = run()
    mismatches = [
        row["id"] for row in rows if
        (args.mode == "seed" and row["observed"] != row["expected_seed"]) or
        (args.mode == "candidate" and row["observed"] != "PASS")
    ]
    input_paths = [
        CANDIDATE / "artifactgraph" / filename
        for filename in ("manifest.py", "engine.py", "cache.py")
    ]
    report = {
        "schema": "nightfall.artifactgraph.public-audit.v1",
        "mode": args.mode,
        "python": sys.version.split()[0],
        "sources": {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in input_paths},
        "scope": "separately constructed PUBLIC API probe, not hidden grader or sandbox",
        "total": len(rows),
        "positive": sum(x["observed"] == "PASS" for x in rows),
        "violations": sum(x["observed"] == "VIOLATION" for x in rows),
        "errors": sum(x["observed"] == "ERROR" for x in rows),
        "mismatches": mismatches,
        "cases": rows,
    }
    rendered = json.dumps(report, sort_keys=True, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    return int(bool(mismatches))


if __name__ == "__main__":
    raise SystemExit(main())
