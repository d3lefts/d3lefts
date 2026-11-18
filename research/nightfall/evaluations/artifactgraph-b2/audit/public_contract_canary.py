#!/usr/bin/env python3
"""Independent public-API canary for ArtifactGraph-B2; not a hidden grader."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest

def manifest(root, nodes):
    (root / "graph.json").write_text(json.dumps({"version": 1, "nodes": nodes}), encoding="utf-8")

def node(source, deps=()):
    return {"source": source, "deps": list(deps)}

class ContractCanary(unittest.TestCase):
    def setUp(self):
        from artifactgraph import Builder, GraphError
        self.Builder, self.GraphError = Builder, GraphError
        self.temp = tempfile.TemporaryDirectory(prefix="nightfall-b2-audit-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "workspace"
        (self.root / "src").mkdir(parents=True)

    def put(self, name, value=b"data"):
        p = self.root / "src" / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(value)
        return p

    def basic(self):
        self.put("a.txt", b"alpha")
        manifest(self.root, {"a": node("a.txt")})
        return self.Builder(self.root)

    def test_01_unmodified_reuse_across_instances(self):
        b = self.basic()
        first = b.build(["a"])
        self.assertEqual(first.built, ("a",))
        second = self.Builder(self.root).build(["a"])
        self.assertEqual(second.reused, ("a",))
        self.assertEqual(first.outputs, second.outputs)

    def test_02_changed_bytes_same_mtime(self):
        b = self.basic()
        old = b.build(["a"]).outputs["a"]
        p = self.root / "src" / "a.txt"
        st = p.stat()
        p.write_bytes(b"bravo")
        os.utime(p, ns=(st.st_atime_ns, st.st_mtime_ns))
        updated = self.Builder(self.root).build(["a"])
        self.assertEqual(updated.built, ("a",))
        self.assertNotEqual(updated.outputs["a"], old)

    def test_03_touch_same_bytes(self):
        b = self.basic()
        b.build(["a"])
        p = self.root / "src" / "a.txt"
        st = p.stat()
        os.utime(p, ns=(st.st_atime_ns, st.st_mtime_ns + 3_000_000_000))
        updated = self.Builder(self.root).build(["a"])
        self.assertEqual(updated.reused, ("a",))
        self.assertEqual(updated.built, ())

    def test_04_dependency_reordering(self):
        self.put("a.txt", b"A")
        self.put("b.txt", b"B")
        self.put("root.txt", b"root")
        nodes = {"a": node("a.txt"), "b": node("b.txt"),
                 "root": node("root.txt", ["a", "b"])}
        manifest(self.root, nodes)
        old = self.Builder(self.root).build(["root"]).outputs["root"]
        nodes["root"]["deps"].reverse()
        manifest(self.root, nodes)
        updated = self.Builder(self.root).build(["root"])
        self.assertIn("root", updated.built)
        self.assertNotEqual(updated.outputs["root"], old)

    def test_05_dependency_plan_order(self):
        for name in ("a", "b", "c", "top"):
            self.put(name + ".txt", name.encode())
        manifest(self.root, {"a": node("a.txt"), "b": node("b.txt"),
                             "c": node("c.txt", ["a"]),
                             "top": node("top.txt", ["b", "c"])})
        self.assertEqual(self.Builder(self.root).build(["top"]).built, ("b", "a", "c", "top"))

    def test_06_unreachable_cycle(self):
        for name in ("a", "x", "y"):
            self.put(name + ".txt")
        manifest(self.root, {"a": node("a.txt"), "x": node("x.txt", ["y"]),
                             "y": node("y.txt", ["x"])})
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_07_unreachable_missing_dependency(self):
        self.put("a.txt")
        self.put("x.txt")
        manifest(self.root, {"a": node("a.txt"), "x": node("x.txt", ["missing"])})
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_08_external_symlink(self):
        outside = self.root / "private.txt"
        outside.write_bytes(b"secret")
        (self.root / "src" / "link.txt").symlink_to(outside)
        manifest(self.root, {"a": node("link.txt")})
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_09_parent_traversal(self):
        (self.root / "private.txt").write_bytes(b"secret")
        manifest(self.root, {"a": node("../private.txt")})
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_10_corrupt_object_regeneration(self):
        b = self.basic()
        original = b.build(["a"]).outputs["a"]
        obj = self.root / ".artifactgraph" / "objects" / original
        obj.write_bytes(b"bad object")
        updated = self.Builder(self.root).build(["a"])
        self.assertEqual(updated.built, ("a",))
        self.assertEqual(updated.outputs["a"], original)
        self.assertEqual(hashlib.sha256(obj.read_bytes()).hexdigest(), original)

    def test_11_corrupt_object_read(self):
        b = self.basic()
        sha = b.build(["a"]).outputs["a"]
        (self.root / ".artifactgraph" / "objects" / sha).write_bytes(b"invalid")
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).read_output("a")

    def test_12_missing_object_regeneration(self):
        b = self.basic()
        sha = b.build(["a"]).outputs["a"]
        (self.root / ".artifactgraph" / "objects" / sha).unlink()
        updated = self.Builder(self.root).build(["a"])
        self.assertEqual(updated.built, ("a",))
        self.assertEqual(hashlib.sha256(self.Builder(self.root).read_output("a")).hexdigest(), sha)

    def test_13_invalid_source_preserves_index(self):
        self.put("a.txt", b"alpha")
        self.put("b.txt", b"bravo")
        manifest(self.root, {"a": node("a.txt"), "b": node("b.txt")})
        b = self.Builder(self.root)
        b.build(["a", "b"])
        index = self.root / ".artifactgraph" / "index.json"
        old_index, old_a = index.read_bytes(), b.read_output("a")
        self.put("a.txt", b"changed-alpha-longer")
        (self.root / "src" / "b.txt").unlink()
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a", "b"])
        self.assertEqual(index.read_bytes(), old_index)
        self.assertEqual(self.Builder(self.root).read_output("a"), old_a)

    def test_14_corrupt_index_fails_closed(self):
        b = self.basic()
        b.build(["a"])
        index = self.root / ".artifactgraph" / "index.json"
        index.write_bytes(b"{invalid json\n")
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])
        self.assertEqual(index.read_bytes(), b"{invalid json\n")

    def test_15_unsafe_digest_in_index(self):
        b = self.basic()
        b.build(["a"])
        index = self.root / ".artifactgraph" / "index.json"
        data = json.loads(index.read_text())
        data["entries"]["a"]["digest"] = "../../private"
        index.write_text(json.dumps(data))
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_16_boolean_manifest_version(self):
        self.put("a.txt")
        (self.root / "graph.json").write_text(
            json.dumps({"version": True, "nodes": {"a": node("a.txt")}}))
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_17_boolean_index_version(self):
        b = self.basic()
        b.build(["a"])
        index = self.root / ".artifactgraph" / "index.json"
        data = json.loads(index.read_text())
        data["version"] = True
        index.write_text(json.dumps(data))
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_18_binary_clean_rebuild(self):
        self.put("a.bin", bytes(range(256)))
        manifest(self.root, {"a": node("a.bin")})
        first = self.Builder(self.root).build(["a"]).outputs["a"]
        self.assertEqual(hashlib.sha256(self.Builder(self.root).read_output("a")).hexdigest(), first)
        import shutil
        shutil.rmtree(self.root / ".artifactgraph")
        second = self.Builder(self.root).build(["a"]).outputs["a"]
        self.assertEqual(first, second)

    def test_19_requested_subgraph_only(self):
        self.put("a.txt")
        self.put("b.txt")
        manifest(self.root, {"a": node("a.txt"), "b": node("b.txt")})
        result = self.Builder(self.root).build(["a"])
        self.assertEqual(result.built, ("a",))
        self.assertEqual(set(result.outputs), {"a"})

    def test_20_repeated_target_once(self):
        self.put("a.txt")
        self.put("b.txt")
        manifest(self.root, {"a": node("a.txt"), "b": node("b.txt", ["a"])})
        self.assertEqual(self.Builder(self.root).build(["b", "a", "b"]).built, ("a", "b"))

    def test_21_unrelated_source_no_invalidation(self):
        self.put("a.txt")
        self.put("b.txt")
        manifest(self.root, {"a": node("a.txt"), "b": node("b.txt")})
        self.Builder(self.root).build(["a"])
        self.put("b.txt", b"different")
        self.assertEqual(self.Builder(self.root).build(["a"]).reused, ("a",))

    def test_22_cli_unknown_target_fails(self):
        import subprocess
        self.basic()
        process = subprocess.run(
            [sys.executable, "-m", "artifactgraph", str(self.root), "unknown"],
            capture_output=True, text=True, timeout=10)
        self.assertNotEqual(process.returncode, 0)
        self.assertFalse(process.stdout.strip())

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--package-root", required=True, type=Path)
    parser.add_argument("--json-out", type=Path)
    parser.add_argument("--require-seed-violations", type=int)
    parser.add_argument("--require-all-pass", action="store_true")
    args = parser.parse_args()
    root = args.package_root.resolve()
    if not (root / "artifactgraph" / "__init__.py").is_file():
        parser.error("invalid package-root")
    sys.path.insert(0, str(root))
    os.environ["PYTHONPATH"] = str(root)
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ContractCanary)
    passed, failures = [], []
    class Result(unittest.TestResult):
        def addSuccess(self, test):
            super().addSuccess(test)
            passed.append(test._testMethodName)
        def addFailure(self, test, err):
            super().addFailure(test, err)
            failures.append({"test": test._testMethodName,
                             "reason": self._exc_info_to_string(err, test)[-1200:]})
        def addError(self, test, err):
            super().addError(test, err)
            failures.append({"test": test._testMethodName,
                             "reason": self._exc_info_to_string(err, test)[-1200:]})
    result = Result()
    suite.run(result)
    output = {"schema": "nightfall-artifactgraph-b2-public-canary-v1",
              "tests": result.testsRun, "passed": len(passed), "failed": len(failures),
              "passed_cases": passed, "failures": failures,
              "scope": "public contract canary, not the author grader or blind model scoring"}
    print(json.dumps(output, indent=2, sort_keys=True))
    if args.json_out:
        args.json_out.write_text(json.dumps(output, indent=2, sort_keys=True) + "\n")
    if args.require_all_pass:
        return 1 if failures else 0
    if args.require_seed_violations is not None:
        # Pin identities as well as the failure count: a changed failure mix
        # must not be misreported as the old source-exact calibration.
        expected = {
            "test_02_changed_bytes_same_mtime",
            "test_03_touch_same_bytes",
            "test_04_dependency_reordering",
            "test_06_unreachable_cycle",
            "test_08_external_symlink",
            "test_09_parent_traversal",
            "test_10_corrupt_object_regeneration",
            "test_11_corrupt_object_read",
            "test_13_invalid_source_preserves_index",
            "test_16_boolean_manifest_version",
            "test_17_boolean_index_version",
        }
        actual = {failure["test"] for failure in failures}
        return 0 if result.testsRun == 22 and len(failures) == args.require_seed_violations == 11 and actual == expected else 1
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
