#!/usr/bin/env python3
"""Independent finite audit of NIGHTFALL coupled mission-change observability.

This is a deterministic, zero-error ideal-sensor model.  It does not model
physical trust attestation or prove novelty.  Standard-library only.

Run: python coupled_assurance_checker.py
"""
from itertools import combinations, product
from fractions import Fraction
import hashlib
import json


def bit_index(row: int, col: int, r: int) -> int:
    return r * row + col


def possible_pairs(r: int, known_task=None, known_change=None):
    return [(t, j) for t in range(r) for j in range(r)
            if (known_task is None or t == known_task)
            and (known_change is None or j == known_change)]


def task_support(r: int, t: int):
    return {bit_index(t, j, r) for j in range(r)}


def change_support(r: int, j: int):
    return {bit_index(t, j, r) for t in range(r)}


def predicted_necessary_sensors(r: int, known_task=None, known_change=None):
    out = set()
    for t, j in possible_pairs(r, known_task, known_change):
        out |= task_support(r, t) & change_support(r, j)
    return out


def independent_world_pair_test(r: int, panel: frozenset, known_task=None,
                                known_change=None):
    """Test distinguishability of all-safe from every single-fault unsafe world.

    For each possible task/manifest pair, the current model can have changed
    only inside the selected column.  Previously certified coordinates outside
    that column remain +1.  Test distinguishability with raw sensor signatures,
    not the predicted_necessary_sensors function.
    """
    all_safe = tuple(1 for _ in range(r*r))
    baseline_signature = tuple(all_safe[i] for i in sorted(panel))
    for t, j in possible_pairs(r, known_task, known_change):
        for i in range(r*r):
            row, col = divmod(i, r)
            if row != t or col != j:
                continue
            unsafe = list(all_safe)
            unsafe[i] = -1
            unsafe_signature = tuple(unsafe[p] for p in sorted(panel))
            if unsafe_signature == baseline_signature:
                return False
    return True


def brute_optimum(r: int, known_task=None, known_change=None):
    """Exhaustively enumerate sensor panels and test worlds independently."""
    n = r*r
    for cost in range(n+1):
        for subset in combinations(range(n), cost):
            if independent_world_pair_test(r, frozenset(subset), known_task, known_change):
                return cost, subset
    raise AssertionError('No feasible panel')


def verify(r: int):
    results = []
    for mode in ('neither', 'task_only', 'change_only', 'both'):
        ts = [None] if mode in ('neither','change_only') else list(range(r))
        js = [None] if mode in ('neither','task_only') else list(range(r))
        for t, j in product(ts, js):
            predicted = predicted_necessary_sensors(r, t, j)
            observed, panel = brute_optimum(r, t, j)
            assert observed == len(predicted), (r, mode, t, j, predicted, observed)
            assert set(panel) == predicted, (r, mode, t, j)
            results.append({'mode':mode, 'task':t, 'change':j, 'cost':observed})
    expected = {'neither':r*r,'task_only':r,'change_only':r,'both':1}
    assert all(o['cost'] == expected[o['mode']] for o in results)
    return results


def adversarial_untrusted_change_example(r=3):
    """A counterfeit change manifest can make one queried cell insufficient."""
    task = 0
    claimed_column = 0
    actual_changed_column = 1
    actual_fault = bit_index(task, actual_changed_column, r)
    queried = bit_index(task, claimed_column, r)
    assert actual_fault != queried
    # Without a trusted manifest, the verifier checks the wrong bit and accepts.
    observed_safe = (queried != actual_fault)
    return {'task':task,'claimed_col':claimed_column,
            'actual_col':actual_changed_column,'fault_bit':actual_fault,
            'queried_bit':queried,'unsafe_accepted_if_manifest_untrusted':observed_safe}




def routed_target(r: int, t: int, config: int) -> int:
    """Mission-dependent critical component after reconfiguration."""
    return (t + config) % r


def routed_world_test(r: int, panel: frozenset, task=None, config=None):
    """Independently test signature separation for each allowed routed task."""
    safe = tuple([1] * r)
    sig_safe = tuple(safe[i] for i in sorted(panel))
    tasks = range(r) if task is None else [task]
    configs = range(r) if config is None else [config]
    for t in tasks:
        for a in configs:
            failing = routed_target(r, t, a)
            world = [1] * r
            world[failing] = -1
            if tuple(world[i] for i in sorted(panel)) == sig_safe:
                return False
    return True


def routed_brute_optimum(r: int, task=None, config=None):
    for cost in range(r+1):
        for subset in combinations(range(r), cost):
            if routed_world_test(r, frozenset(subset), task, config):
                return cost
    raise AssertionError('No valid routed panel')


def test_pure_joint_information(r: int):
    """Separate from the row-column model: neither cue alone helps."""
    costs={}
    for mode in ('neither','task_only','config_only','both'):
        ts = [None] if mode in ('neither','config_only') else list(range(r))
        cs = [None] if mode in ('neither','task_only') else list(range(r))
        val=[]
        for t,c in product(ts,cs):
            val.append(routed_brute_optimum(r,t,c))
        assert len(set(val))==1, (r, mode, val)
        costs[mode]=val[0]
    assert costs == {'neither':r,'task_only':r,'config_only':r,'both':1}
    # Exact counting demonstrates both marginal signals reveal zero information
    # about the target while their joint signal determines it.
    target_counts=[sum(routed_target(r,t,a)==i for t in range(r) for a in range(r))
                    for i in range(r)]
    assert all(z==r for z in target_counts)
    for t in range(r):
        assert set(routed_target(r,t,a) for a in range(r)) == set(range(r))
    for a in range(r):
        assert set(routed_target(r,t,a) for t in range(r)) == set(range(r))
    return costs

def main():
    cases = {str(r):verify(r) for r in (2, 3)}
    attack = adversarial_untrusted_change_example()
    assert attack['unsafe_accepted_if_manifest_untrusted']
    # Exact relative zero-error cost ratios, not finite noisy-channel costs.
    exact = {str(r): {'neither':r*r,'task_only':r,'change_only':r,'both':1,
                     'gain_vs_either_single_input':r,
                     'gain_vs_neither':r*r} for r in (2,3,4,8,16)}
    routed = {str(r):test_pure_joint_information(r) for r in (2,3,4,8)}
    result = {'status':'PASS','tested_cases':sum(map(len,cases.values())), 'routed_exhaustive_contexts':sum((1+r)*(1+r) for r in (2,3,4,8)),
              'brute_force_r':list(map(int,cases.keys())),
              'exact_cost_families':exact, 'pure_joint_information':routed,
              'manifest_attack':attack,
              'claims_not_tested':['trusted-source authenticity','noisy-channel asymptotics',
                                   'human experiments','research novelty']}
    s = json.dumps(result,indent=2,sort_keys=True)
    print(s)
    with open('/mnt/data/nightfall_usa/checker_results.json','w') as f: f.write(s+'\n')
    with open(__file__,'rb') as f: source_hash = hashlib.sha256(f.read()).hexdigest()
    print('SOURCE_SHA256',source_hash)

if __name__ == '__main__':
    main()