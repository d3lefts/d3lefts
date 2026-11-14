#!/usr/bin/env python3
"""NIGHTFALL MSSE: source-explicit finite engineering benchmark.

Reproduces the two-bit architecture, posterior-noise, and change-recheck
baselines using exact fractions and exhaustive finite state search.
Not a universal theorem, academic grade, faculty review or novelty claim.
Run: python3 research/nightfall/2026-11-msse-readiness/pilot_checker.py
"""
from fractions import Fraction as F
from functools import lru_cache
from itertools import combinations, product
import json

STATES = tuple(product((0, 1), repeat=2))
SENSORS = {
    'x0': lambda x: x[0],
    'x1': lambda x: x[1],
    'parity': lambda x: x[0] ^ x[1],
}
TASKS = {
    'parity': lambda x: x[0] ^ x[1],
    'x0': lambda x: x[0],
}
INSTALL = {'x0': 1, 'x1': 1, 'parity': 4}


def subsets(items):
    return tuple(c for k in range(len(items) + 1) for c in combinations(items, k))


def separates(chosen, task):
    """Direct task-fiber criterion."""
    return all(task(a) == task(b) or any(SENSORS[s](a) != SENSORS[s](b) for s in chosen)
               for a, b in combinations(STATES, 2))


def covers(chosen, task):
    """Independently structured pair-cover criterion."""
    different_pairs = {(i, j) for i in range(4) for j in range(i + 1, 4)
                       if task(STATES[i]) != task(STATES[j])}
    sensor_pairs = set()
    for sensor in chosen:
        outputs = [SENSORS[sensor](x) for x in STATES]
        for i in range(4):
            for j in range(i + 1, 4):
                if outputs[i] != outputs[j]:
                    sensor_pairs.add((i, j))
    return different_pairs.issubset(sensor_pairs)


def minimax_depth(chosen, task):
    """Unweighted exact adaptive decision tree, separate from pair-cover code."""
    @lru_cache(None)
    def recurse(rows):
        if len({task(STATES[i]) for i in rows}) == 1:
            return 0
        candidates = []
        for s in chosen:
            groups = {}
            for i in rows:
                groups.setdefault(SENSORS[s](STATES[i]), []).append(i)
            if len(groups) > 1:
                candidates.append(1 + max(recurse(tuple(group)) for group in groups.values()))
        return min(candidates) if candidates else float('inf')
    return recurse(tuple(range(4)))


def certificate(chosen, task):
    return {(i, j): next((s for s in chosen if SENSORS[s](STATES[i]) != SENSORS[s](STATES[j])), None)
            for i in range(4) for j in range(i + 1, 4)
            if task(STATES[i]) != task(STATES[j])}


def check_certificate(chosen, task, proof):
    required = {(i, j) for i in range(4) for j in range(i + 1, 4)
                if task(STATES[i]) != task(STATES[j])}
    return (set(proof) == required and
            all(s in chosen and SENSORS[s](STATES[i]) != SENSORS[s](STATES[j])
                for (i, j), s in proof.items()))


def run():
    count = 0
    archs = subsets(tuple(SENSORS))
    for arch in archs:
        for task in TASKS.values():
            assert separates(arch, task) == covers(arch, task)
            assert (minimax_depth(arch, task) != float('inf')) == separates(arch, task)
            count += 2
            if separates(arch, task):
                cert = certificate(arch, task)
                assert check_certificate(arch, task, cert)
                assert not check_certificate(arch, task, {**cert, next(iter(cert)): 'inexistent'})
                count += 2
    assert min(sum(INSTALL[s] for s in arch) for arch in archs
               if all(separates(arch, task) for task in TASKS.values())) == 2
    count += 1

    A = ('x0', 'x1')
    B = ('x0', 'parity')
    assert [minimax_depth(A, task) for task in TASKS.values()] == [2, 1]
    assert [minimax_depth(B, task) for task in TASKS.values()] == [1, 1]
    count += 2

    for numerator in range(5):
        p = F(numerator, 4)
        for T in range(17):
            cost_A = 2 + T * (1 + p)
            cost_B = 7 + T
            assert (cost_B < cost_A) == (T * p > 5)
            assert (cost_B == cost_A) == (T * p == 5)
            count += 2
    p, T = F(3, 4), 8
    assert 2 + T * (1 + p) == 16
    assert 7 + T == 15
    assert F(5, 1) / p == F(20, 3)
    count += 3

    # Source and model uncertainty must be distinguished.
    values = [F(theta1 * theta2 * (x - xp)**2, 2)
              for theta1, theta2, x, xp in product((-1, 1), repeat=4)]
    assert F(sum(values), len(values)) == 0
    assert F(sum(y*y for y in values), len(values)) == 2
    model_influence = F(sum((theta * (x-xp))**2 for theta,x,xp
                             in product((-1,1), repeat=3)), 16)
    assert model_influence == 1
    count += 3

    # A changed mission invalidates an old adequate certificate.
    assert separates(('parity',), TASKS['parity'])
    assert not separates(('parity',), TASKS['x0'])
    count += 2

    # For N finite states, exactly kN-k(k+1)/2 unordered pairs touch k changed rows.
    n = len(STATES)
    for k in range(n + 1):
        altered = set(range(k))
        actual = sum((i in altered or j in altered) for i, j in combinations(range(n), 2))
        assert actual == k*n - k*(k+1)//2
        count += 1

    result = {
        'status': 'EXACT_FINITE_BENCHMARK_PASSED',
        'assertion_groups': count,
        'state_count': n,
        'architecture_A': {'installed': A, 'initial_cost': 2, 'expected_read_cost': '7/4', '8_cycle_total': 16},
        'architecture_B': {'installed': B, 'initial_plus_audit': 7, 'expected_read_cost': '1', '8_cycle_total': 15},
        'break_even_cycles_at_p_3_over_4': '20/3',
        'model_influence': '1',
        'posterior_mean_influence': '0',
        'cross_posterior_estimator_variance': '2',
        'university_credit_and_grade_awarded': False,
    }
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    run()
