"""Content-addressed cache: integrity verification and atomic index replacement."""
from __future__ import annotations

import hashlib
import json
import os
import re
import tempfile
from pathlib import Path

from .manifest import GraphError

_HEX = re.compile(r"[a-f0-9]{64}\Z")


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _atomic_write(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix=".pending-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as file:
            file.write(data)
            file.flush()
            os.fsync(file.fileno())
        os.replace(tmp, path)
    finally:
        if os.path.exists(tmp):
            os.unlink(tmp)


class Cache:
    def __init__(self, root: Path):
        self.root = root / ".artifactgraph"
        self.index_path = self.root / "index.json"
        self.objects = self.root / "objects"

    def load(self) -> dict[str, dict[str, str]]:
        try:
            raw = self.index_path.read_text(encoding="utf-8")
        except FileNotFoundError:
            return {}
        except (OSError, UnicodeError) as exc:
            raise GraphError(f"cannot read index: {exc}") from exc
        try:
            index = json.loads(raw)
        except json.JSONDecodeError as exc:
            raise GraphError("corrupt index") from exc
        if not isinstance(index, dict) or index.get("version") != 1 or not isinstance(index.get("entries"), dict):
            raise GraphError("corrupt index shape")
        result = index["entries"]
        for name, entry in result.items():
            if (not isinstance(name, str) or not isinstance(entry, dict) or
                set(entry) != {"key", "digest"} or
                not isinstance(entry["key"], str) or _HEX.fullmatch(entry["key"]) is None or
                not isinstance(entry["digest"], str) or _HEX.fullmatch(entry["digest"]) is None):
                raise GraphError("unsafe or corrupt index entry")
        return result

    def read(self, sha: str) -> bytes | None:
        if not isinstance(sha, str) or _HEX.fullmatch(sha) is None:
            return None
        try:
            data = (self.objects / sha).read_bytes()
        except (OSError, ValueError):
            return None
        return data  # Legacy store assumes objects are immutable.

    def publish(self, objects: dict[str, bytes], entries: dict[str, dict[str, str]]) -> None:
        # Stage *all* build computations before this method. Object orphans after
        # a crash are harmless; the index remains the sole committed authority.
        for sha, payload in objects.items():
            if digest(payload) != sha:
                raise GraphError("internal digest mismatch")
            if self.read(sha) is None:
                _atomic_write(self.objects / sha, payload)
        body = json.dumps({"version": 1, "entries": entries},
                          sort_keys=True, separators=(",", ":")).encode() + b"\n"
        _atomic_write(self.index_path, body)
