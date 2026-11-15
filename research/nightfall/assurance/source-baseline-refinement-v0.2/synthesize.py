#!/usr/bin/env python3
"""NIGHTFALL finite adversarial partially-observed authority synthesis.

No external dependencies. Input schema is in README.md. Exact rational costs.
Proof-carrying output is checked INDEPENDENTLY by audit.py.
"""
import argparse
import hashlib
import json
from collections import defaultdict
from fractions import Fraction
from pathlib import Path


def parse_model(path):
    raw = Path(path).read_bytes()
    model = json.loads(raw)
    names = model['states']
    if not names or len(set(names)) != len(names) or len(names) > 16:
        raise ValueError('model requires 1..16 distinct states (implementation guard)')
    index = {s: i for i, s in enumerate(names)}
    goal = sum(1 << index[s] for s in model['goal_states'])
    initial = sum(1 << index[s] for s in model['initial_belief'])
    if initial == 0:
        raise ValueError('initial_belief must be nonempty')
    actions = []
    for a in model['actions']:
        cost = Fraction(str(a['cost']))
        if cost <= 0:
            raise ValueError('strictly positive action costs required')
        transitions = []
        for s in names:
            entries = []
            for rec in a['transitions'].get(s, []):
                if len(rec) != 3 or type(rec[2]) is not bool:
                    raise ValueError('transition must be [observation, successor, bool_safe]')
                o, nxt, safe = rec
                if not isinstance(o, str) or nxt not in index:
                    raise ValueError('unknown successor or non-string observation')
                entries.append((o, index[nxt], safe))
            transitions.append(entries)
        actions.append((a['name'], cost, transitions))
    if len({a[0] for a in actions}) != len(actions):
        raise ValueError('duplicate action names')
    return raw, names, goal, initial, actions


def outcomes(belief, action, n):
    by_o = defaultdict(int)
    for s in range(n):
        if belief & (1 << s):
            if not action[2][s]:
                return None
            for obs, target, safe in action[2][s]:
                if not safe:
                    return None
                by_o[obs] |= 1 << target
    return tuple(sorted(by_o.values())) if by_o else None


def synthesize(names, goal, actions):
    n = len(names)
    masks = range(1, 1 << n)
    value = {b: Fraction(0) if (b & ~goal == 0) else None for b in masks}
    # Every sure-winning finite-state reachability strategy has an acyclic belief plan.
    # The total number of nonempty beliefs therefore bounds policy depth.
    for _ in range((1 << n) - 1):
        new = value.copy()
        changed = False
        for b in masks:
            if b & ~goal == 0:
                continue
            candidates = []
            for action in actions:
                nxts = outcomes(b, action, n)
                if nxts is not None and all(value[c] is not None for c in nxts):
                    candidates.append(action[1] + max(value[c] for c in nxts))
            cand = min(candidates) if candidates else None
            if cand is not None and (new[b] is None or cand < new[b]):
                new[b] = cand
                changed = True
        value = new
        if not changed:
            break
    policy = {}
    for b in masks:
        if b & ~goal == 0 or value[b] is None:
            continue
        matches = []
        for a in actions:
            succ = outcomes(b, a, n)
            if succ is not None and all(value[x] is not None for x in succ):
                v = a[1] + max(value[x] for x in succ)
                if v == value[b] and all(value[x] < value[b] for x in succ):
                    matches.append(a[0])
        if not matches:
            raise RuntimeError('finite value without a strict-descent policy')
        policy[str(b)] = sorted(matches)[0]
    return value, policy


def perpetual_safety_kernel(names, actions):
    """Greatest fixpoint of finite nonblocking always-safe operation."""
    n=len(names)
    region=set(range(1,1<<n))
    for _ in range((1<<n)-1):
        smaller=set()
        for b in region:
            if any((succ:=outcomes(b,a,n)) is not None and all(t in region for t in succ)
                   for a in actions):
                smaller.add(b)
        if smaller==region:
            break
        region=smaller
    policy={}
    for b in sorted(region):
        matches=[a[0] for a in actions if (succ:=outcomes(b,a,n)) is not None
                 and all(t in region for t in succ)]
        if not matches:
            raise RuntimeError('invalid safety greatest-fixpoint witness')
        policy[str(b)]=sorted(matches)[0]
    return sorted(region),policy


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('model')
    ap.add_argument('--out', default='certificate.json')
    args = ap.parse_args()
    raw, names, goal, initial, actions = parse_model(args.model)
    v, policy = synthesize(names, goal, actions)
    kernel,kernel_policy=perpetual_safety_kernel(names,actions)
    certificate = {
        'schema': 'nightfall-belief-authority-v1',
        'input_sha256': hashlib.sha256(raw).hexdigest(),
        'state_order': names,
        'goal_mask': goal,
        'initial_mask': initial,
        'values': {str(k): str(x) if x is not None else None for k,x in v.items()},
        'policy': policy,
        'perpetual_kernel': kernel,
        'perpetual_policy': kernel_policy,
        'initial_cost': None if v[initial] is None else str(v[initial]),
        'num_winning_beliefs': sum(x is not None for x in v.values()),
    }
    Path(args.out).write_text(json.dumps(certificate, indent=2, sort_keys=True)+'\n')
    print(json.dumps({'initial_cost': certificate['initial_cost'], 'winning_beliefs': certificate['num_winning_beliefs'], 'perpetual_beliefs': len(kernel), 'certificate': args.out}))


if __name__ == '__main__':
    main()