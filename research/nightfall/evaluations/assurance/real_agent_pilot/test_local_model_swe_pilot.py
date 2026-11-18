"""Static and fake-model safety controls. NO model inference and NO grader scores."""
from __future__ import annotations

import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parent))
import local_model_swe_pilot as p


class PublicPilotContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)/"candidate"
        (self.root/"dispatchq").mkdir(parents=True)
        (self.root/"tests").mkdir(parents=True)
        (self.root/"ISSUE.md").write_text("Repair queue\n")
        (self.root/"dispatchq"/"queue.py").write_text("VALUE=0\n")
        (self.root/"tests"/"test_public.py").write_text("test body\n")

    def test_model_cannot_edit_public_test_or_issue(self):
        for name in ("tests/test_public.py", "ISSUE.md",
                     "dispatchq/missing.py", "../secrets.py", "/etc/passwd",
                     "dispatchq/../tests/test_public.py"):
            with self.subTest(name=name), self.assertRaises(p.PilotFailure):
                p.guarded_file(self.root,name,write=True,package="dispatchq")

    def test_symlink_not_read(self):
        outside=Path(self.temp.name)/"secret.py"
        outside.write_text("secret")
        (self.root/"dispatchq"/"leak.py").symlink_to(outside)
        with self.assertRaises(p.PilotFailure):
            p.guarded_file(self.root,"dispatchq/leak.py")
        with self.assertRaises(p.PilotFailure):
            p.list_files(self.root)

    def test_source_overwrite_allowlist(self):
        out=p.tool_action(self.root,{"tool":"write_file","path":"dispatchq/queue.py",
                                     "content":"VALUE=12345\n"},"dispatchq","unused")
        self.assertEqual(out["result"],"implementation file overwritten")
        self.assertEqual((self.root/"dispatchq"/"queue.py").read_text(),"VALUE=12345\n")
        with self.assertRaises(p.PilotFailure):
            p.tool_action(self.root,{"tool":"run_shell","command":"cat /etc/passwd"},
                          "dispatchq","unused")

    def test_patch_is_git_apply_compatible(self):
        src={"dispatchq/queue.py":b"VALUE=0\n"}
        dst={"dispatchq/queue.py":b"VALUE=2\n"}
        diff=p.make_patch(src,dst).decode()
        self.assertIn("diff --git a/dispatchq/queue.py b/dispatchq/queue.py",diff)
        self.assertIn("-VALUE=0",diff)
        self.assertIn("+VALUE=2",diff)

    def test_fake_model_end_to_end_remains_explicitly_unscored(self):
        source=self.root
        output=Path(self.temp.name)/"result"
        steps=iter([
            ({"tool":"read_file","path":"dispatchq/queue.py"},
             '{"tool":"read_file","path":"dispatchq/queue.py"}',{"eval_tokens":12}),
            ({"tool":"write_file","path":"dispatchq/queue.py",
              "content":"VALUE=12345\n"},
             '{"tool":"write_file","path":"dispatchq/queue.py","content":"VALUE=12345\\n"}',
             {"eval_tokens":15}),
            ({"tool":"finish"},"{\"tool\":\"finish\"}",{"eval_tokens":4}),
        ])
        with patch.object(p,"model_meta",return_value={"model":p.MODEL,"digest":"e"*64}),\
             patch.object(p,"inference",side_effect=lambda *args: next(steps)),\
             patch.object(p,"docker_smoke",return_value={
                "status":"completed","exit_code":0,"tail":"synthetic smoke PASS"}):
            receipt=p.run("DispatchQ-B1",source,output,
                          "sha256:"+"f"*64,"mocked",steps=4)
        self.assertEqual(receipt["tool_calls_executed"],3)
        self.assertEqual(receipt["source_writes_executed"],1)
        self.assertIsNone(receipt["blind_agent_score"])
        self.assertTrue(receipt["no_private_grader_executed"])
        self.assertEqual(receipt["finish_reason"],"model_finished")
        self.assertIn("dispatchq/queue.py",receipt["changed_files"])
        self.assertNotEqual(receipt["patch_sha256"],p.sha(b""))
        self.assertIn("not",receipt["ceiling"].lower())
        self.assertTrue((output/"PRIVATE_RAW_TRANSCRIPT.json").exists())
        self.assertTrue((output/"PRIVATE_CANDIDATE_PATCH.diff").exists())
        self.assertEqual((source/"dispatchq"/"queue.py").read_text(),"VALUE=0\n")

    def test_malformed_tool_action_fails_closed(self):
        with self.assertRaises(p.PilotFailure):
            p.tool_action(self.root,{"tool":"write_file",
                        "path":"dispatchq/queue.py","content":"x"},
                          "dispatchq","unused")
        with self.assertRaises(p.PilotFailure):
            p.tool_action(self.root,{"tool":"read_file","path":"../secret"},
                          "dispatchq","unused")


if __name__=="__main__":
    unittest.main()
