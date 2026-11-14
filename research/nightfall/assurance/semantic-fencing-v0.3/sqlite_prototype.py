#!/usr/bin/env python3
"""Three-source SQLite atomic source+effect reference monitor.

All source writes and the 'consequential effect' (a logged DB row) occur in one
database. This is NOT a physical actuator or a distributed atomicity proof.
"""
import sqlite3, tempfile, os, json
from contextlib import contextmanager
from semantic_fence import min_fence

SRC = ("controller", "plant", "policy")
SAFE = tuple(bits != 7 for bits in range(8))

@contextmanager
def fresh_db():
    with tempfile.TemporaryDirectory() as root:
        path = os.path.join(root, "authority.sqlite")
        a = sqlite3.connect(path, isolation_level=None, timeout=2)
        b = sqlite3.connect(path, isolation_level=None, timeout=2)
        for c in (a, b):
            c.execute("PRAGMA journal_mode=WAL")
        a.execute("CREATE TABLE sources (id INTEGER PRIMARY KEY, value INTEGER NOT NULL, version INTEGER NOT NULL)")
        a.executemany("INSERT INTO sources VALUES (?,?,?)", [(i, 0, 0) for i in range(3)])
        a.execute("CREATE TABLE effects (id INTEGER PRIMARY KEY, source_bits INTEGER NOT NULL, permissible INTEGER NOT NULL)")
        try:
            yield a, b
        finally:
            a.close()
            b.close()

def read_snapshot(conn):
    conn.execute("BEGIN")
    rows = conn.execute("SELECT id,value,version FROM sources ORDER BY id").fetchall()
    conn.execute("COMMIT")
    bits = sum(v << i for i, v, ver in rows)
    versions = tuple(ver for i, v, ver in rows)
    return bits, versions

def change(conn, i, value):
    conn.execute("BEGIN IMMEDIATE")
    conn.execute("UPDATE sources SET value=?,version=version+1 WHERE id=?", (value, i))
    conn.execute("COMMIT")

def commit(conn, snapshot, guarded=True, split_check=False, intermediate=None):
    baseline, vers = snapshot
    assert SAFE[baseline], "Never certify an unsafe baseline."
    fence = min_fence(1 << baseline, SAFE, 3, (1, 1, 1))[1]
    def current():
        rows = conn.execute("SELECT id,value,version FROM sources ORDER BY id").fetchall()
        return sum(v << i for i, v, version in rows), tuple(ver for i, v, ver in rows)
    if split_check:
        observed, nowver = current()  # Deliberate bug: check outside transaction.
        assert all(nowver[i] == vers[i] for i in range(3) if fence & (1 << i))
        intermediate()
        conn.execute("BEGIN IMMEDIATE")
    else:
        conn.execute("BEGIN IMMEDIATE")
    actual, nowver = current()
    if guarded and not split_check and any(nowver[i] != vers[i] for i in range(3) if fence & (1 << i)):
        conn.execute("ROLLBACK")
        return dict(accepted=False, fence=fence, current=actual, unsafe_committed=False)
    # Safety value is for audit only, NOT for gate logic.
    conn.execute("INSERT INTO effects(source_bits,permissible) VALUES (?,?)", (actual, int(SAFE[actual])))
    conn.execute("COMMIT")
    return dict(accepted=True, fence=fence, current=actual, unsafe_committed=not SAFE[actual])

def run():
    outcomes = {}
    with fresh_db() as (gate, editor):
        snapshot = read_snapshot(gate)
        change(editor, 1, 1)
        change(editor, 2, 1)
        outcomes["unmonitored_changes_allowed"] = commit(gate, snapshot)
    with fresh_db() as (gate, editor):
        snapshot = read_snapshot(gate)
        for i in range(3):
            change(editor, i, 1)
        outcomes["monitored_change_rejected"] = commit(gate, snapshot)
    with fresh_db() as (gate, editor):
        snapshot = read_snapshot(gate)
        for i in range(3):
            change(editor, i, 1)
        outcomes["stale_guard_missing"] = commit(gate, snapshot, guarded=False)
    with fresh_db() as (gate, editor):
        snapshot = read_snapshot(gate)
        outcomes["check_commit_race"] = commit(gate, snapshot, guarded=True, split_check=True,
             intermediate=lambda: [change(editor, i, 1) for i in range(3)])
    with fresh_db() as (gate, editor):
        snapshot = read_snapshot(gate)
        change(editor, 0, 1)
        change(editor, 0, 0)
        outcomes["ABA_rejected"] = commit(gate, snapshot)
    assert outcomes["unmonitored_changes_allowed"]["accepted"]
    assert not outcomes["unmonitored_changes_allowed"]["unsafe_committed"]
    assert not outcomes["monitored_change_rejected"]["accepted"]
    assert outcomes["stale_guard_missing"]["unsafe_committed"]
    assert outcomes["check_commit_race"]["unsafe_committed"]
    assert not outcomes["ABA_rejected"]["accepted"]
    assert outcomes["unmonitored_changes_allowed"]["fence"].bit_count() == 1
    print(json.dumps(outcomes, indent=2, sort_keys=True))
    print("SQLITE_THREE_SOURCE_REFERENCE_GATE_PASS")

if __name__ == "__main__":
    run()
