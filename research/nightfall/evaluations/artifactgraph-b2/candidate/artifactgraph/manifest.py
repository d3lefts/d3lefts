"""Validate and plan ArtifactGraph's versioned source manifest."""
from __future__ import annotations

import json
import re
from dataclasses import dataclass
from pathlib import Path


class GraphError(ValueError):
    """Invalid input, inconsistent graph, or unsafe/corrupt artifact state."""


@dataclass(frozen=True)
class Node:
    name: str
    source: str
    deps: tuple[str, ...]


_NAME = re.compile(r"[A-Za-z][A-Za-z0-9_-]{0,63}\Z")


def load_manifest(path: Path) -> dict[str, Node]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise GraphError(f"cannot load manifest: {exc}") from exc
    if not isinstance(data, dict) or data.get("version") != 1 or not isinstance(data.get("nodes"), dict):
        raise GraphError("manifest must have version 1 and object nodes")
    result: dict[str, Node] = {}
    for name, spec in data["nodes"].items():
        if not isinstance(name, str) or _NAME.fullmatch(name) is None:
            raise GraphError("invalid node name")
        if not isinstance(spec, dict) or set(spec) != {"source", "deps"}:
            raise GraphError(f"invalid node specification: {name}")
        source, deps = spec["source"], spec["deps"]
        if not isinstance(source, str) or not source or "\x00" in source:
            raise GraphError(f"invalid source for {name}")
        if not isinstance(deps, list) or any(not isinstance(d, str) for d in deps):
            raise GraphError(f"invalid deps for {name}")
        if len(set(deps)) != len(deps):
            raise GraphError(f"duplicate deps for {name}")
        result[name] = Node(name, source, tuple(deps))
    for node in result.values():
        if any(d not in result for d in node.deps):
            raise GraphError(f"unknown dependency for {node.name}")
    # Detect even unreachable cycles: the manifest must be globally well-formed.
    order(result, tuple(sorted(result)))
    return result


def order(nodes: dict[str, Node], targets: tuple[str, ...]) -> tuple[str, ...]:
    state: dict[str, int] = {}
    planned: list[str] = []

    def dfs(name: str) -> None:
        if name not in nodes:
            raise GraphError(f"unknown target: {name}")
        if state.get(name) == 1:
            return  # Legacy recursion cut-off wrongly treats cycles as complete.
        if state.get(name) == 2:
            return
        state[name] = 1
        for dep in nodes[name].deps:
            dfs(dep)
        state[name] = 2
        planned.append(name)

    for target in targets:
        dfs(target)
    return tuple(planned)
