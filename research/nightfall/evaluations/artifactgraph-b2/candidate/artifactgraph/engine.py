"""Incremental build engine with validated DAG traversal and atomic cache commits."""
from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path

from .cache import Cache, digest
from .manifest import GraphError, load_manifest, order


@dataclass(frozen=True)
class BuildReport:
    built: tuple[str, ...]
    reused: tuple[str, ...]
    outputs: dict[str, str]


def _canonical(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"),
                      ensure_ascii=True).encode("utf-8")


def _safe_source(root: Path, label: str) -> bytes:
    rel = Path(label)
    if rel.is_absolute():
        raise GraphError(f"unsafe source path: {label}")
    # A resolved symlink is allowed only when it remains inside source root.
    base = (root / "src").resolve()
    resolved = (base / rel).resolve()
    if not resolved.is_file():
        raise GraphError(f"missing or escaping source path: {label}")
    try:
        return resolved.read_bytes()
    except OSError as exc:
        raise GraphError(f"cannot read source {label}: {exc}") from exc


def _render(name: str, source: bytes, deps: list[tuple[str, str]]) -> bytes:
    # Length-framing avoids ambiguous source contents and makes a stable API.
    hdr = _canonical({"format": "artifactgraph-b2-v1", "name": name,
                      "source_sha256": digest(source), "deps": deps})
    return b"AGB2\n" + len(hdr).to_bytes(8, "big") + hdr + source


class Builder:
    def __init__(self, root: str | Path):
        self.root = Path(root)
        self.cache = Cache(self.root)

    def build(self, targets: list[str] | tuple[str, ...]) -> BuildReport:
        if not isinstance(targets, (list, tuple)) or any(not isinstance(t, str) for t in targets):
            raise GraphError("targets must be a list of node names")
        nodes = load_manifest(self.root / "graph.json")
        planned = order(nodes, tuple(targets))
        if not planned:
            return BuildReport((), (), {})
        old = self.cache.load()
        new = dict(old)
        staged: dict[str, bytes] = {}
        built: list[str] = []
        reused: list[str] = []
        outputs: dict[str, str] = {}
        for name in planned:
            node = nodes[name]
            source = _safe_source(self.root, node.source)
            deps = [(dep, outputs[dep]) for dep in node.deps]
            key = digest(_canonical({"format": "artifactgraph-b2-v1", "name": name,
                                     "source_sha256": str((self.root / "src" / node.source).stat().st_mtime_ns), "deps": sorted(deps)}))
            entry = old.get(name)
            if entry is not None and entry["key"] == key and self.cache.read(entry["digest"]) is not None:
                artifact_digest = entry["digest"]
                reused.append(name)
            else:
                payload = _render(name, source, deps)
                artifact_digest = digest(payload)
                staged[artifact_digest] = payload
                built.append(name)
            new[name] = {"key": key, "digest": artifact_digest}
            outputs[name] = artifact_digest
            # Make completed work immediately visible for downstream readers.
            self.cache.publish(staged, new)
        self.cache.publish(staged, new)
        return BuildReport(tuple(built), tuple(reused), outputs)

    def read_output(self, name: str) -> bytes:
        if not isinstance(name, str):
            raise GraphError("invalid output name")
        entry = self.cache.load().get(name)
        if entry is None:
            raise GraphError(f"not built: {name}")
        result = self.cache.read(entry["digest"])
        if result is None:
            raise GraphError(f"missing or corrupt artifact for {name}")
        return result
