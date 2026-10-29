"""Independent algorithmic audit path (same-author, NOT outside peer review)."""
from __future__ import annotations
from collections import deque
import hashlib
import json

ALPHABET = ('approve', 'revoke', 'taint', 'sanitize', 'emit', 'compact')
START = (False, False, False)
GENESIS = hashlib.sha256(b'NIGHTFALL-SENTINEL-V0-GENESIS').hexdigest()


def policy_transition(s: tuple[bool,bool,bool], e: str) -> tuple[bool,bool,bool]:
    a, t, bad = s
    if bad:
        return s
    return {'approve': (True,t,False), 'revoke': (False,t,False),
            'taint': (a,True,False), 'sanitize': (a,False,False),
            'compact': s, 'emit': (a,t, (not a) or t)}[e]


def state_id(s: tuple[bool,bool,bool]) -> int:
    return 4 if s[2] else 2 * int(s[0]) + int(s[1])


def verify(packet: dict, expected_root: str | None = None) -> bool:
    if packet.get('protocol') != 'nightfall-sentinel-v0' or packet.get('genesis') != GENESIS:
        return False
    entries = packet.get('entries')
    if not isinstance(entries, list):
        return False
    state, prev = START, GENESIS
    for i, entry in enumerate(entries):
        if not isinstance(entry, dict) or set(entry) != {'seq','event','before','after','allowed','prev','digest'}:
            return False
        ev = entry.get('event')
        if ev not in ALPHABET or type(entry.get('seq')) is not int or entry['seq'] != i:
            return False
        proposed = policy_transition(state, ev)
        allowed = not proposed[2]
        after = proposed if allowed else state
        if (entry['before'] != state_id(state) or
            entry['after'] != state_id(after) or
            type(entry.get('allowed')) is not bool or entry['allowed'] != allowed or
            entry['prev'] != prev):
            return False
        row = {k: entry[k] for k in ('seq','event','before','after','allowed','prev')}
        actual = hashlib.sha256(b'NIGHTFALL-SENTINEL-V0-RECORD\0' +
                json.dumps(row, sort_keys=True, separators=(',', ':'), ensure_ascii=True).encode()).hexdigest()
        if actual != entry['digest']:
            return False
        prev, state = actual, after
    return (packet.get('root') == prev and packet.get('final_state') == state_id(state)
            and (expected_root is None or expected_root == prev))


def distinguish(x: int, y: int) -> tuple[str, ...] | None:
    """Find shortest suffix distinguishing 5 monitor states; finite product BFS."""
    def decode(i):
        return (False, False, True) if i == 4 else (bool(i & 2), bool(i & 1), False)
    queue = deque([(decode(x), decode(y), ())]); seen = set()
    while queue:
        p, q, suffix = queue.popleft()
        if (p, q) in seen:
            continue
        seen.add((p,q))
        if p[2] != q[2]:
            return suffix
        for ev in ALPHABET:
            queue.append((policy_transition(p, ev), policy_transition(q, ev), suffix+(ev,)))
    return None


if __name__ == '__main__':
    from itertools import combinations
    for a, b in combinations(range(5), 2):
        print(a, b, distinguish(a,b))
