"""NIGHTFALL Sentinel v0: tiny synthetic, compaction-invariant authorization policy.

This module illustrates a trusted-gateway model; the Python program by itself
is NOT a security boundary or a proof that real-world actions are intercepted.
"""
from __future__ import annotations
import hashlib
import json

EVENTS = ('approve', 'revoke', 'taint', 'sanitize', 'emit', 'compact')
BAD = 4
GENESIS = hashlib.sha256(b'NIGHTFALL-SENTINEL-V0-GENESIS').hexdigest()


def step(state: int, event: str) -> int:
    """State 0..3 = 2*authorization + taint, state 4 = absorbing violation."""
    if state not in range(5) or event not in EVENTS:
        raise ValueError('invalid state or event')
    if state == BAD:
        return BAD
    authorized, tainted = divmod(state, 2)
    if event == 'approve':
        authorized = 1
    elif event == 'revoke':
        authorized = 0
    elif event == 'taint':
        tainted = 1
    elif event == 'sanitize':
        tainted = 0  # only an independently trusted declassification event
    elif event == 'emit' and (not authorized or tainted):
        return BAD
    return 2 * authorized + tainted


def canonical(obj: dict) -> bytes:
    return json.dumps(obj, sort_keys=True, separators=(',', ':'), ensure_ascii=True).encode()


def record_digest(entry: dict) -> str:
    return hashlib.sha256(b'NIGHTFALL-SENTINEL-V0-RECORD\0' + canonical(entry)).hexdigest()


def execute(events: list[str]) -> dict:
    """Generates an illustrative trace; in deployment execution needs external gateway.

    Denied emits are recorded as denials and NEVER applied as side effects.
    The simulated policy state remains safe after a denial.
    """
    state, prev, entries = 0, GENESIS, []
    for seq, event in enumerate(events):
        proposed = step(state, event)
        allowed = proposed != BAD
        after = proposed if allowed else state
        row = {'seq': seq, 'event': event, 'before': state, 'after': after,
               'allowed': allowed, 'prev': prev}
        digest = record_digest(row)
        entries.append({**row, 'digest': digest})
        state, prev = after, digest
    return {'protocol': 'nightfall-sentinel-v0', 'genesis': GENESIS,
            'entries': entries, 'root': prev, 'final_state': state}


if __name__ == '__main__':
    import sys
    print(json.dumps(execute(sys.argv[1:] or ['taint', 'compact', 'approve', 'emit']), indent=2))
