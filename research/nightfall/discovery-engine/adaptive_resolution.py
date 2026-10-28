"""NIGHTFALL prototype: lossless evidence-aware, two-stage dynamic segmentation.

Inspired by adaptive granularity in hierarchical networks. This module is a
non-ML baseline, separate from Cartesia's trained H-Net.
"""
from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import Mapping, Iterable


def digest(data: bytes) -> str:
    return sha256(data).hexdigest()


@dataclass(frozen=True)
class Chunk:
    start: int
    end: int
    digest: str
    children: tuple[int, ...] = ()


@dataclass(frozen=True)
class Hierarchy:
    source_sha256: str
    source_length: int
    fine: tuple[Chunk, ...]
    coarse: tuple[Chunk, ...]
    hard_boundaries: frozenset[int]
    policy_version: str = "evidence-router-v1"

    def audit(self, source: bytes) -> None:
        if len(source) != self.source_length or digest(source) != self.source_sha256:
            raise ValueError("source changed; hierarchy and certificates are stale")
        if not source:
            if self.fine or self.coarse:
                raise ValueError("empty source must have empty hierarchy")
            return
        for level in (self.fine, self.coarse):
            offset = 0
            for c in level:
                if not (c.start == offset < c.end <= len(source)):
                    raise ValueError("gap, overlap, or invalid chunk")
                if c.digest != digest(source[c.start:c.end]):
                    raise ValueError("chunk digest mismatch")
                offset = c.end
            if offset != len(source):
                raise ValueError("incomplete coverage")
            cuts = {c.end for c in level[:-1]}
            if not self.hard_boundaries.issubset(cuts):
                raise ValueError("hard evidence boundary was collapsed")
        covered = []
        for c in self.coarse:
            if not c.children:
                raise ValueError("missing fine-level links")
            children = [self.fine[i] for i in c.children]
            if children[0].start != c.start or children[-1].end != c.end:
                raise ValueError("invalid parent-child span")
            covered.extend(c.children)
        if covered != list(range(len(self.fine))):
            raise ValueError("lost or duplicated fine-level child")

    def dechunk(self, source: bytes, level: str = "coarse") -> bytes:
        self.audit(source)
        chunks = self.coarse if level == "coarse" else self.fine if level == "fine" else None
        if chunks is None:
            raise ValueError("unknown hierarchy level")
        return b"".join(source[x.start:x.end] for x in chunks)

    def affected(self, boundary: int) -> tuple[int, ...]:
        """Return coarse chunks whose closure contains an evidence boundary."""
        if not 0 <= boundary <= self.source_length:
            raise ValueError("boundary outside source")
        return tuple(i for i, c in enumerate(self.coarse)
                     if c.start <= boundary <= c.end)


def _chunks_from_cuts(raw: bytes, cuts: list[int]) -> tuple[Chunk, ...]:
    return tuple(Chunk(a, b, digest(raw[a:b])) for a, b in zip(cuts, cuts[1:]))


def build_hierarchy(raw: bytes, *, signals: Mapping[int, float] | None = None,
                    hard_boundaries: Iterable[int] = (),
                    fine_threshold: float = 0.65,
                    coarse_threshold: float = 0.9,
                    max_fine_bytes: int = 32,
                    max_coarse_children: int = 5) -> Hierarchy:
    """Generate dynamic contiguous boundaries from context-dependent signal scores.

    signals is an injectable router output: a heuristic, uncertainty estimator,
    downstream exact-check failure, or a future learned boundary policy.
    All offsets are original raw-byte offsets.
    """
    if max_fine_bytes < 1 or max_coarse_children < 1:
        raise ValueError("chunk budgets must be positive")
    if not 0 <= fine_threshold <= coarse_threshold <= 1:
        raise ValueError("thresholds must satisfy 0 <= fine <= coarse <= 1")
    n = len(raw)
    force = frozenset(hard_boundaries)
    if any(not isinstance(p, int) or isinstance(p, bool) or p < 1 or p >= n for p in force):
        raise ValueError("hard boundary must be an interior byte offset")
    scores = {} if signals is None else dict(signals)
    if any(not isinstance(i, int) or isinstance(i, bool) or i < 1 or i >= n
           or not isinstance(s, (float, int)) or not 0 <= s <= 1
           for i, s in scores.items()):
        raise ValueError("signals require valid positions and finite scores in [0,1]")
    if not raw:
        return Hierarchy(digest(raw), 0, (), (), frozenset())
    fine_cuts = [0]
    for i in range(1, n):
        if i in force or scores.get(i, 0) >= fine_threshold or i-fine_cuts[-1] >= max_fine_bytes:
            fine_cuts.append(i)
    fine_cuts.append(n)
    fine = _chunks_from_cuts(raw, fine_cuts)
    coarse = []
    start_idx = 0
    for idx in range(1, len(fine)):
        pos = fine[idx].start
        if pos in force or scores.get(pos, 0) >= coarse_threshold or idx-start_idx >= max_coarse_children:
            group = tuple(range(start_idx, idx))
            coarse.append(Chunk(fine[start_idx].start, fine[idx-1].end,
                                digest(raw[fine[start_idx].start:fine[idx-1].end]), group))
            start_idx = idx
    group = tuple(range(start_idx, len(fine)))
    coarse.append(Chunk(fine[start_idx].start, n, digest(raw[fine[start_idx].start:]), group))
    tree = Hierarchy(digest(raw), n, fine, tuple(coarse), force)
    tree.audit(raw)
    return tree


def refine_after_failure(raw: bytes, tree: Hierarchy, failure_offset: int,
                         *, signals: Mapping[int, float] | None = None,
                         fine_threshold: float = 0.65,
                         coarse_threshold: float = 0.9,
                         max_fine_bytes: int = 32,
                         max_coarse_children: int = 5) -> Hierarchy:
    """Promote a failed exact-check location to an immutable boundary."""
    tree.audit(raw)
    if not 0 < failure_offset < len(raw):
        raise ValueError("failure must identify an interior raw offset")
    return build_hierarchy(raw, signals=signals,
                           hard_boundaries=tree.hard_boundaries | {failure_offset},
                           fine_threshold=fine_threshold,
                           coarse_threshold=coarse_threshold,
                           max_fine_bytes=max_fine_bytes,
                           max_coarse_children=max_coarse_children)


def assert_source_provenance(tree: Hierarchy, *, submitted_source_sha256: str,
                             exact_checker_passed: bool) -> None:
    """Minimal source identity gate; this alone establishes no theorem."""
    if not exact_checker_passed or tree.source_sha256 != submitted_source_sha256:
        raise ValueError("missing exact replay or changed source identity")
