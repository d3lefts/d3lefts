#!/usr/bin/env python3
"""Exhaustive bounded interleaving model of a source-version guarded commit.

No physical guarantee: atomicity, provenance and full source coverage are
assumptions. Counterexamples demonstrate failure if checks are weakened.
"""
from collections import deque
from dataclasses import dataclass
from semantic_fence import min_fence

N = 3
SAFE = tuple(x != 7 for x in range(8))
MAX_EDITS = 4

@dataclass(frozen=True)
class State:
    vals: int = 0
    vers: tuple = (0, 0, 0)
    edits: int = 0
    snap: int = -1
    basevers: tuple = (-1, -1, -1)
    fence: int = -1
    checked: bool = False
    committed: bool = False

def moves(s, mode):
    if s.committed:
        return
    if s.edits < MAX_EDITS:
        for i in range(N):
            vals = s.vals ^ (1 << i)
            vs = list(s.vers)
            vs[i] += 1
            yield f"update(source={i},value={(vals >> i) & 1})", State(vals, tuple(vs), s.edits+1, s.snap, s.basevers, s.fence, s.checked), False
    if s.snap < 0:
        yield "coherent_snapshot", State(s.vals, s.vers, s.edits, s.vals, s.vers, -1, False), False
    if s.snap >= 0 and s.fence < 0:
        if SAFE[s.snap]:
            J = min_fence(1 << s.snap, SAFE, N, (1, 1, 1))[1]
            if mode == "missing_fence":
                J = 0
            yield f"certify(minimal_fence={J:03b})", State(s.vals, s.vers, s.edits, s.snap, s.basevers, J, False), False
        else:
            yield "deny_unsafe_snapshot", State(s.vals, s.vers, s.edits, s.snap, s.basevers, -2, False), False
    if s.fence >= 0:
        valid = all(s.vers[i] == s.basevers[i] for i in range(N) if s.fence & (1 << i))
        if mode == "split_validate_commit":
            if not s.checked:
                yield f"non_atomic_check(pass={valid})", State(s.vals, s.vers, s.edits, s.snap, s.basevers, s.fence, valid), False
            else:
                yield "effect_after_earlier_check", State(s.vals, s.vers, s.edits, s.snap, s.basevers, s.fence, True, True), not SAFE[s.vals]
        else:
            if mode == "stale_no_guard":
                valid = True
            if valid:
                yield "atomic_compare_and_effect", State(s.vals, s.vers, s.edits, s.snap, s.basevers, s.fence, False, True), not SAFE[s.vals]
            else:
                yield "reject_changed_fence", State(s.vals, s.vers, s.edits, s.snap, s.basevers, -2, False), False

def audit(mode):
    q = deque([(State(), tuple())])
    visited = {State()}
    transitions = 0
    unsafe = 0
    shortest = None
    commits = 0
    while q:
        s, path = q.popleft()
        for desc, t, bad in moves(s, mode):
            transitions += 1
            if t.committed:
                commits += 1
            if bad:
                unsafe += 1
                if shortest is None:
                    shortest = path + (desc,)
            if t not in visited:
                visited.add(t)
                q.append((t, path + (desc,)))
    return dict(mode=mode, states=len(visited), transitions=transitions,
                commit_edges=commits, unsafe_effect_edges=unsafe, shortest_counterexample=shortest)

if __name__ == "__main__":
    for m in ("atomic", "stale_no_guard", "missing_fence", "split_validate_commit"):
        result = audit(m)
        print(result)
        assert (result["unsafe_effect_edges"] == 0) == (m == "atomic")
    print("BOUNDED_ATOMIC_GATE_AUDIT_PASS")
