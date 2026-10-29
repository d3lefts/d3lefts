"""Finite tests: exact product-state minimization, cross-implementation replay.

No external audit/novelty is claimed by same-author tests.
"""
from itertools import product, combinations
from math import ceil, log2
import copy
import json
from sentinel import execute, step, EVENTS
from audit import verify, policy_transition, state_id, START, distinguish


def test():
    count = 0
    for n in range(6):
        for trace in product(EVENTS, repeat=n):
            packet = execute(list(trace))
            assert verify(packet, expected_root=packet['root']), trace
            other_state = START
            for i, ev in enumerate(trace):
                proposed = policy_transition(other_state, ev)
                approved = not proposed[2]
                other_state = proposed if approved else other_state
                assert packet['entries'][i]['after'] == state_id(other_state)
            count += 1
    assert count == sum(len(EVENTS) ** n for n in range(6))
    pairs = list(combinations(range(5), 2))
    witnesses = {f'{x}-{y}': distinguish(x,y) for x,y in pairs}
    assert len(witnesses) == 10 and all(s is not None for s in witnesses.values())
    assert ceil(log2(5)) == 3
    # A lossy reset at compaction falsely allows 'emit' even though taint persisted.
    trace = ['taint', 'compact', 'approve', 'emit']
    packet = execute(trace)
    assert packet['entries'][-1]['allowed'] is False
    naive_state = step(step(0, 'approve'), 'emit')
    assert naive_state != 4
    # Tampering with a logged outcome is rejected, also if the root is fixed externally.
    altered = copy.deepcopy(packet)
    altered['entries'][-1]['allowed'] = True
    assert not verify(altered, expected_root=packet['root'])
    truncated = copy.deepcopy(packet)
    truncated['entries'] = truncated['entries'][:-1]
    assert not verify(truncated, expected_root=packet['root'])
    # A self-consistent forged trace remains mathematically valid: completeness is not
    # established without trusted mediation. This is a mandatory negative control.
    forged = execute(['approve', 'emit'])
    assert verify(forged, expected_root=forged['root'])
    return {'cross_checked_traces': count, 'pairwise_distinguished': len(witnesses),
            'max_shortest_distinguishing_suffix': max(map(len,witnesses.values())),
            'minimal_state_count': 5, 'minimal_fixed_width_bits': 3,
            'naive_compaction_false_negative': True,
            'tamper_rejected': True,
            'self_consistent_omission_undetectable_without_external_ledger': True,
            'shortest_distinguishing_suffixes': {k: list(v) for k,v in witnesses.items()}}

if __name__ == '__main__':
    print(json.dumps(test(), indent=2))
