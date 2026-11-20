"""Public calibration on trusted fixtures. Run with Python 3.10+."""
import json
import os
from pathlib import Path
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parent


def queue_case(root, targeted):
    from dispatchq import WorkQueue

    now = [100.0]
    queue = WorkQueue(root / "jobs.db", clock=lambda: now[0])
    queue.submit("a", "payload")
    first, = queue.claim("A")
    now[0] = first.lease_until + 1
    second, = queue.claim("B")
    before = queue.status("a")
    if targeted:
        rejected = queue.finish("a", first.token) is False
        preserved = queue.status("a") == before
        completed = queue.finish("a", second.token) is True
    else:
        completed = queue.finish("a", second.token) is True
        preserved = queue.status("a")["state"] == "done"
        rejected = queue.finish("a", first.token) is False
    return {"old_token_rejected": rejected, "intermediate_state": preserved,
            "current_token_accepted": completed, "terminal": queue.status("a")["state"] == "done"}


def build_case(root, targeted):
    from artifactgraph import Builder

    (root / "src").mkdir()
    source = root / "src" / "a"
    source.write_bytes(b"A")
    (root / "graph.json").write_text(json.dumps(
        {"version": 1, "nodes": {"a": {"source": "a", "deps": []}}}))
    stamp = 1600000000
    def build():
        os.utime(source, (stamp, stamp))
        return Builder(root).build(["a"])
    first = build()
    source.write_bytes(b"B")
    if not targeted:
        stamp += 10
    changed = build()
    if targeted:
        stamp += 10
    unchanged = build()
    return {"changed_bytes_rebuilt": changed.built == ("a",),
            "output_changed": first.outputs["a"] != changed.outputs["a"],
            "same_bytes_reused": unchanged.reused == ("a",),
            "output_stable": unchanged.outputs["a"] == changed.outputs["a"]}


def main():
    tasks = (("dispatchq-b1", queue_case), ("artifactgraph-b2", build_case))
    for task, case in tasks:
        sys.path.insert(0, str(ROOT / task / "candidate"))
        for repeat in range(3):
            for arm in (False, True):
                with tempfile.TemporaryDirectory() as directory:
                    start = time.perf_counter_ns()
                    checks = case(Path(directory), arm)
                    print(json.dumps(dict(task=task, repeat=repeat, arm="targeted" if arm else "baseline",
                                          checks=checks, passed=all(checks.values()),
                                          elapsed_ns=time.perf_counter_ns()-start)))


if __name__ == "__main__":
    main()
