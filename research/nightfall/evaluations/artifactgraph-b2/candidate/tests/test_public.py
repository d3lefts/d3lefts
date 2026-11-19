"""Agent-visible smoke tests. The portfolio grader is intentionally withheld."""
import json
import tempfile
import unittest
from pathlib import Path

from artifactgraph import Builder, GraphError


class PublicSmoke(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        (self.root / "src").mkdir()
        (self.root / "src" / "core.txt").write_bytes(b"core")
        (self.root / "src" / "ui.txt").write_bytes(b"ui")
        (self.root / "graph.json").write_text(json.dumps({"version": 1, "nodes": {
            "core": {"source": "core.txt", "deps": []},
            "ui": {"source": "ui.txt", "deps": ["core"]},
        }}))

    def test_first_build_returns_ordered_closure(self):
        r = Builder(self.root).build(["ui"])
        self.assertEqual(r.built, ("core", "ui"))
        self.assertEqual(set(r.outputs), {"core", "ui"})

    def test_second_build_reuses_cache(self):
        Builder(self.root).build(["ui"])
        r = Builder(self.root).build(["ui"])
        self.assertEqual(r.built, ())
        self.assertEqual(r.reused, ("core", "ui"))

    def test_unknown_target_is_error(self):
        with self.assertRaises(GraphError):
            Builder(self.root).build(["does_not_exist"])


if __name__ == "__main__":
    unittest.main()
