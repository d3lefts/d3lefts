"""SQLite work-queue implementation requiring production correctness repairs.

Issue report: duplicate submissions overwrite jobs; concurrent workers sometimes
lease the same job; stale workers can finish retried jobs; retry exhaustion and
scheduled delivery are unreliable. Repair this module without changing the API.
"""
from __future__ import annotations

import sqlite3
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


@dataclass(frozen=True)
class Lease:
    job_id: str
    payload: str
    token: str
    attempts: int
    lease_until: float


class WorkQueue:
    def __init__(self, db_path: str | Path, *, clock: Callable[[], float] = time.time,
                 lease_seconds: float = 30.0, max_attempts: int = 3) -> None:
        self.db_path = str(db_path)
        self.clock = clock
        self.lease_seconds = lease_seconds
        self.max_attempts = max_attempts
        with self._connect() as conn:
            conn.execute("""CREATE TABLE IF NOT EXISTS jobs (
                job_id TEXT PRIMARY KEY, payload TEXT NOT NULL,
                due_at REAL NOT NULL, created_at REAL NOT NULL,
                state TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0,
                token TEXT, lease_until REAL
            )""")

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path, timeout=10.0)
        conn.row_factory = sqlite3.Row
        return conn

    def submit(self, job_id: str, payload: str, *, due_at: float = 0.0) -> bool:
        with self._connect() as conn:
            existed = conn.execute("SELECT 1 FROM jobs WHERE job_id=?", (job_id,)).fetchone()
            conn.execute("""INSERT OR REPLACE INTO jobs
                (job_id,payload,due_at,created_at,state,attempts)
                VALUES(?,?,?,?,'ready',0)""", (job_id, payload, due_at, self.clock()))
            return existed is None

    def claim(self, worker: str, *, limit: int = 1) -> list[Lease]:
        now = self.clock()
        # Known race: read work list before the transaction that marks it leased.
        with self._connect() as conn:
            rows = conn.execute("""SELECT * FROM jobs WHERE
                (state='ready' AND due_at <= ?) OR
                (state='leased' AND lease_until <= ?)
                ORDER BY job_id LIMIT ?""", (now, now, limit)).fetchall()
        leased = []
        for row in rows:
            token = uuid.uuid4().hex
            with self._connect() as conn:
                conn.execute("""UPDATE jobs SET state='leased',token=?,attempts=?,
                    lease_until=? WHERE job_id=?""", (token, row['attempts']+1,
                     now + self.lease_seconds, row['job_id']))
            leased.append(Lease(row['job_id'], row['payload'], token,
                                row['attempts']+1, now + self.lease_seconds))
        return leased

    def finish(self, job_id: str, token: str) -> bool:
        with self._connect() as conn:
            cur = conn.execute("""UPDATE jobs SET state='done' WHERE job_id=?
                AND token=?""", (job_id, token))
            return cur.rowcount == 1

    def fail(self, job_id: str, token: str, *, delay: float = 0.0) -> bool:
        with self._connect() as conn:
            cur = conn.execute("""UPDATE jobs SET state='ready',due_at=?,token=NULL
                WHERE job_id=? AND token=?""", (self.clock() + delay, job_id, token))
            return cur.rowcount == 1

    def status(self, job_id: str) -> dict | None:
        with self._connect() as conn:
            row = conn.execute("""SELECT job_id,payload,due_at,state,attempts,
                token,lease_until FROM jobs WHERE job_id=?""", (job_id,)).fetchone()
            return dict(row) if row is not None else None
