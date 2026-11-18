"""Contract-derived preliminary scorer for NIGHTFALL external-model trials.

Not the authors' private grader; not independently peer-reviewed. Run only on
a disposable, network-disabled container with NO credentials.
"""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import tempfile
import unittest

class DispatchQ(unittest.TestCase):
    def setUp(self):
        from dispatchq import WorkQueue
        self.WorkQueue = WorkQueue
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.db = Path(self.tmp.name) / "jobs.sqlite"
        self.now = 100.0
        self.q = WorkQueue(self.db, clock=lambda: self.now)

    def test_idempotent_submit(self):
        self.assertTrue(self.q.submit("a", "original", due_at=30))
        before = self.q.status("a")
        self.assertFalse(self.q.submit("a", "changed", due_at=1))
        self.assertEqual(before, self.q.status("a"))

    def test_due_and_order(self):
        self.q.submit("b", "b", due_at=80)
        self.q.submit("a", "a", due_at=80)
        self.q.submit("z", "z", due_at=70)
        self.assertEqual([x.job_id for x in self.q.claim("w", limit=3)], ["z", "a", "b"])

    def test_not_due(self):
        self.q.submit("later", "{}", due_at=120)
        self.assertEqual(self.q.claim("w"), [])
        self.now = 120
        self.assertEqual(self.q.claim("w")[0].job_id, "later")

    def test_fencing_and_expiry(self):
        self.q.submit("a", "a")
        one, = self.q.claim("w")
        self.now += 31
        self.assertFalse(self.q.finish("a", one.token))
        two, = self.q.claim("w2")
        self.assertNotEqual(one.token, two.token)
        self.assertFalse(self.q.fail("a", one.token))
        self.assertTrue(self.q.finish("a", two.token))
        self.assertEqual(self.q.status("a")["state"], "done")

    def test_dead_after_max_attempts(self):
        self.q.submit("a", "a")
        for i in range(3):
            leases = self.q.claim("w")
            self.assertEqual(len(leases), 1)
            self.assertEqual(leases[0].attempts, i + 1)
            self.now += 31
        self.assertEqual(self.q.claim("w"), [])
        self.assertEqual(self.q.status("a")["state"], "dead")

    def test_retry_after_delay(self):
        self.q.submit("a", "a")
        x, = self.q.claim("w")
        self.assertTrue(self.q.fail("a", x.token, delay=15))
        self.assertFalse(self.q.fail("a", x.token))
        self.assertEqual(self.q.claim("w"), [])
        self.now += 15
        y, = self.q.claim("w")
        self.assertEqual(y.attempts, 2)

    def test_final_fail(self):
        q = self.WorkQueue(self.db, clock=lambda: self.now, max_attempts=1)
        q.submit("a", "a")
        x, = q.claim("w")
        self.assertTrue(q.fail("a", x.token))
        self.assertEqual(q.status("a")["state"], "dead")
        self.assertEqual(q.claim("w"), [])

    def test_finish_terminal_and_clear(self):
        self.q.submit("a", "a")
        x, = self.q.claim("w")
        self.assertTrue(self.q.finish("a", x.token))
        self.assertFalse(self.q.finish("a", x.token))
        self.assertEqual(self.q.claim("w"), [])
        self.assertIsNone(self.q.status("a")["token"])
        self.assertIsNone(self.q.status("a")["lease_until"])

    def test_constructor_validation(self):
        for lease in (0, -2, float("nan"), float("inf")):
            with self.subTest(lease=lease), self.assertRaises(Exception):
                self.WorkQueue(self.db, lease_seconds=lease)
        for attempts in (0, -1, True, 2.5):
            with self.subTest(attempts=attempts), self.assertRaises(Exception):
                self.WorkQueue(self.db, max_attempts=attempts)

    def test_method_validation(self):
        for args in (("", "x"), ("a", 12)):
            with self.subTest(args=args), self.assertRaises(Exception):
                self.q.submit(*args)
        for due in (float("nan"), float("inf")):
            with self.subTest(due=due), self.assertRaises(Exception):
                self.q.submit("x", "v", due_at=due)
        for w, limit in (("", 1), ("w", 0), ("w", True)):
            with self.subTest(worker=w, limit=limit), self.assertRaises(Exception):
                self.q.claim(w, limit=limit)
        with self.assertRaises(Exception):
            self.q.fail("a", "unknown", delay=-1)

    def test_persistence_across_objects(self):
        self.q.submit("a", "body")
        other = self.WorkQueue(self.db, clock=lambda: self.now)
        x, = other.claim("w")
        self.assertTrue(self.q.finish("a", x.token))
        self.assertEqual(other.status("a")["state"], "done")

    def test_cross_object_single_claim(self):
        from concurrent.futures import ThreadPoolExecutor
        import threading
        for i in range(10):
            self.q.submit("job"+str(i), "v")
            b = threading.Barrier(2)
            def race():
                x = self.WorkQueue(self.db, clock=lambda: self.now)
                b.wait(timeout=3)
                return x.claim("w")
            with ThreadPoolExecutor(max_workers=2) as ex:
                a = ex.submit(race)
                c = ex.submit(race)
                ids = [v.job_id for leases in (a.result(), c.result()) for v in leases]
            self.assertEqual(ids.count("job"+str(i)), 1)

class ArtifactGraph(unittest.TestCase):
    def setUp(self):
        from artifactgraph import Builder, GraphError
        self.Builder, self.GraphError = Builder, GraphError
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root/"src").mkdir()
        (self.root/"src"/"a.bin").write_bytes(b"first\x00\xff")
        (self.root/"src"/"b.bin").write_bytes(b"second")
        self.nodes = {
            "a": {"source": "a.bin", "deps": []},
            "b": {"source": "b.bin", "deps": ["a"]}
        }
        self.manifest()

    def manifest(self, version=1, nodes=None):
        data = {"version": version, "nodes": self.nodes if nodes is None else nodes}
        (self.root/"graph.json").write_text(json.dumps(data))

    def test_first_build_then_reuse_new_instance(self):
        self.assertEqual(self.Builder(self.root).build(["b"]).built, ("a","b"))
        out = self.Builder(self.root).build(["b"])
        self.assertEqual(out.built, ())
        self.assertEqual(out.reused, ("a","b"))

    def test_unrelated_source_unchanged(self):
        self.Builder(self.root).build(["b"])
        (self.root/"src"/"unrelated").write_bytes(b"z")
        out = self.Builder(self.root).build(["b"])
        self.assertEqual(out.reused, ("a","b"))

    def test_same_mtime_modified_bytes_invalidates(self):
        self.Builder(self.root).build(["b"])
        src=self.root/"src"/"a.bin"
        st=src.stat()
        src.write_bytes(b"new__\x00\xff")
        os.utime(src,ns=(st.st_atime_ns,st.st_mtime_ns))
        out = self.Builder(self.root).build(["b"])
        self.assertEqual(out.built, ("a","b"))

    def test_corrupt_object_rebuilt(self):
        out=self.Builder(self.root).build(["b"])
        obj=self.root/".artifactgraph"/"objects"/out.outputs["a"]
        obj.write_bytes(b"tampered")
        out2=self.Builder(self.root).build(["b"])
        self.assertIn("a", out2.built)

    def test_corrupt_read_output_error(self):
        out=self.Builder(self.root).build(["a"])
        (self.root/".artifactgraph"/"objects"/out.outputs["a"]).write_bytes(b"tampered")
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).read_output("a")

    def test_reject_boolean_manifest_version(self):
        self.manifest(version=True)
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_reject_boolean_index_version(self):
        self.Builder(self.root).build(["a"])
        index=self.root/".artifactgraph"/"index.json"
        data=json.loads(index.read_text())
        data["version"]=True
        index.write_text(json.dumps(data))
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_reject_unknown_unreachable_cycle(self):
        nodes=dict(self.nodes)
        nodes["x"]={"source":"a.bin","deps":["y"]}
        nodes["y"]={"source":"b.bin","deps":["x"]}
        self.manifest(nodes=nodes)
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_reject_duplicate_dependencies(self):
        nodes=dict(self.nodes)
        nodes["b"]={"source":"b.bin","deps":["a","a"]}
        self.manifest(nodes=nodes)
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["b"])

    def test_order_preserved_and_shared_once(self):
        nodes=dict(self.nodes)
        nodes["b"]={"source":"b.bin","deps":[]}
        nodes["c"]={"source":"a.bin","deps":["b","a"]}
        self.manifest(nodes=nodes)
        out=self.Builder(self.root).build(["c","b"])
        self.assertEqual(out.built, ("b","a","c"))

    def test_source_parent_traversal_rejected(self):
        (self.root/"escape").write_bytes(b"outside")
        nodes=dict(self.nodes);nodes["a"]={"source":"../escape","deps":[]}
        self.manifest(nodes=nodes)
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_escaping_symlink_rejected(self):
        outside=self.root/"outside";outside.write_bytes(b"outside")
        (self.root/"src"/"alias.bin").symlink_to(outside)
        nodes=dict(self.nodes);nodes["a"]={"source":"alias.bin","deps":[]}
        self.manifest(nodes=nodes)
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_index_not_partially_published_on_failure(self):
        before=self.Builder(self.root).build(["a"])
        index=self.root/".artifactgraph"/"index.json"
        prior=index.read_bytes()
        # Force a legitimate rebuild of a BEFORE a later expected source error.
        # The committed index must still reflect only the earlier valid build.
        (self.root/"src"/"a.bin").write_bytes(b"changed source for a")
        nodes=dict(self.nodes)
        nodes["b"]={"source":"missing_source.bin","deps":[]}
        self.manifest(nodes=nodes)
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a","b"])
        self.assertEqual(index.read_bytes(),prior)

    def test_missing_index_bad_json(self):
        index=self.root/".artifactgraph"/"index.json"
        index.parent.mkdir(exist_ok=True)
        index.write_text("not-json")
        with self.assertRaises(self.GraphError):
            self.Builder(self.root).build(["a"])

    def test_empty_targets_noop(self):
        out=self.Builder(self.root).build([])
        self.assertEqual(out.built, ())
        self.assertEqual(out.reused, ())

def run():
    parser=argparse.ArgumentParser()
    parser.add_argument("--task",required=True,choices=["dispatchq","artifactgraph"])
    parser.add_argument("--out",required=True)
    args=parser.parse_args()
    import sys
    sys.path.insert(0,"/task")
    cls=DispatchQ if args.task=="dispatchq" else ArtifactGraph
    suite=unittest.defaultTestLoader.loadTestsFromTestCase(cls)
    total=suite.countTestCases()
    import io
    buf=io.StringIO()
    result=unittest.TextTestRunner(stream=buf,verbosity=2).run(suite)
    failures=[{"test":str(t),"reason":str(msg)[-600:]} for t,msg in result.failures+result.errors]
    # unittest subTest produces multiple errors for one parent test method.
    # Never count more failed tests than the frozen suite denominator.
    bad_methods={getattr(t,"_testMethodName",str(t)) for t,_ in result.failures+result.errors}
    skipped_methods={getattr(t,"_testMethodName",str(t)) for t,_ in result.skipped}
    failed_count=len(bad_methods | skipped_methods)
    assert 0 <= failed_count <= total
    passed=total-failed_count
    receipt={"task":args.task,"tests_total":total,"tests_passed":passed,
       "tests_failed":failed_count,"max_points":100,
       "points":round(100*passed/total,4),
       "scorer_kind":"contract_derived_preliminary_not_author_hidden",
       "independent_human_audit":False,"failures":failures,"report":buf.getvalue()[-5000:]}
    Path(args.out).write_text(json.dumps(receipt,indent=2,sort_keys=True)+"\n")
    print(json.dumps({k:v for k,v in receipt.items() if k not in ("report","failures")},sort_keys=True))
if __name__=="__main__":run()
