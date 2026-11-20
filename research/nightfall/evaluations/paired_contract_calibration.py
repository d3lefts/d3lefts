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


def build_pair(root, change_bytes, change_stamp):
    from artifactgraph import Builder

    (root / "src").mkdir(parents=True)
    source = root / "src" / "a"
    manifest = {"version": 1, "nodes": {"a": {"source": "a", "deps": []}}}
    (root / "graph.json").write_text(json.dumps(manifest))
    stamp = 1600000000
    source.write_bytes(b"A")
    os.utime(source, (stamp, stamp))
    first = Builder(root).build(["a"])
    if change_bytes:
        source.write_bytes(b"B")
    if change_stamp:
        stamp += 10
    os.utime(source, (stamp, stamp))
    second = Builder(root).build(["a"])
    return first, second


def build_case(root, targeted):
    original, changed = build_pair(root / "edit", True, not targeted)
    clean, unchanged = build_pair(root / "reuse", False, targeted)
    return {"changed_bytes_rebuilt": changed.built == ("a",),
            "output_changed": original.outputs["a"] != changed.outputs["a"],
            "same_bytes_reused": unchanged.reused == ("a",),
            "output_stable": clean.outputs["a"] == unchanged.outputs["a"]}


def main():
    tasks = (("dispatchq-b1", queue_case), ("artifactgraph-b2", build_case))
    errors = 0
    for task, case in tasks:
        sys.path.insert(0, str(ROOT / task / "candidate"))
        for repeat in range(3):
            for arm in (False, True):
                with tempfile.TemporaryDirectory() as directory:
                    start = time.perf_counter_ns()
                    try:
                        checks = case(Path(directory), arm)
                        error = None
                    except Exception as exc:
                        checks = {}
                        error = f"{type(exc).__name__}: {exc}"
                        errors += 1
                    print(json.dumps(dict(task=task, repeat=repeat, arm="targeted" if arm else "baseline",
                                          checks=checks, passed=error is None and all(checks.values()), error=error,
                                          elapsed_ns=time.perf_counter_ns()-start)))

    return int(errors > 0)


if __name__ == "__main__":
    sys.exit(main())
