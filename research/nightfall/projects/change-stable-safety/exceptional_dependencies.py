"""Branch certificates for at most s exceptional non-tree component dependencies.

Each original dependency is nonempty. After removing the s exceptional nodes,
the residual support is either empty or a connected subtree of the supplied
host tree. Return a complete bounded-k resilience proof or a concrete update
that defeats every row. Authentication is out of scope.
"""
from itertools import combinations
from tree_certificate import parents_and_depth, valid_subtrees, subtree_packing_greedy


def analyze_modulator(parent, rows, s, k):
    n = len(parent)
    assert s >= 0 and k >= 0
    parents_and_depth(parent)
    universe = set(range(n+s))
    assert all(set(r['support']) and set(r['support']) <= universe for r in rows)
    assert len({r['id'] for r in rows}) == len(rows)
    cores = []
    for r in rows:
        core = frozenset(set(r['support']) & set(range(n)))
        cores.append(core)
        if core:
            valid_subtrees(parent, [dict(r, support=core, delta=0, e=0, t=0)])
    proofs = []
    for j in range(min(s, k)+1):
        for A0 in combinations(range(n, n+s), j):
            A = set(A0)
            unhit = [(r, core) for r, core in zip(rows, cores)
                     if not A.intersection(r['support'])]
            budget = k - j
            if not unhit:
                return {'resilient': False, 'attack': sorted(A), 'branch_proofs': proofs}
            permanent = next((r['id'] for r, core in unhit if not core), None)
            if permanent is not None:
                proofs.append({'exceptional_changed': sorted(A),
                               'kind': 'outside_exception_witness',
                               'witness_id': permanent})
                continue
            core_rows = [dict(r, support=core, delta=0, e=0, t=0) for r, core in unhit]
            pack, hitting = subtree_packing_greedy(parent, core_rows)
            if len(hitting) <= budget:
                return {'resilient': False,
                        'attack': sorted(A | set(hitting)), 'branch_proofs': proofs}
            proofs.append({'exceptional_changed': sorted(A),
                           'kind': 'disjoint_tree_witnesses',
                           'witness_ids': pack[:budget+1]})
    return {'resilient': True, 'attack': None, 'branch_proofs': proofs}


def check_branch_certificate(parent, rows, s, k, cert):
    n = len(parent)
    parents_and_depth(parent)
    by_id = {r['id']:r for r in rows}
    if len(by_id) != len(rows):
        return False
    if not cert['resilient']:
        T = set(cert['attack'])
        return (len(T) <= k and T <= set(range(n+s)) and
                all(T.intersection(r['support']) for r in rows))
    needed = {tuple(A) for z in range(min(k,s)+1)
              for A in combinations(range(n,n+s), z)}
    seen = set()
    for item in cert['branch_proofs']:
        A0 = item['exceptional_changed']
        A = set(A0)
        key = tuple(sorted(A))
        if len(A) != len(A0) or key not in needed or key in seen:
            return False
        seen.add(key)
        budget = k-len(A)
        if item['kind'] == 'outside_exception_witness':
            i = item['witness_id']
            if i not in by_id or A.intersection(by_id[i]['support']):
                return False
            if set(by_id[i]['support']) & set(range(n)):
                return False
        elif item['kind'] == 'disjoint_tree_witnesses':
            ids = item['witness_ids']
            if len(ids) != budget+1 or len(set(ids)) != len(ids):
                return False
            used = set()
            for i in ids:
                if i not in by_id or A.intersection(by_id[i]['support']):
                    return False
                core = set(by_id[i]['support']) & set(range(n))
                if not core or core & used:
                    return False
                valid_subtrees(parent,[dict(by_id[i],support=core,delta=0,e=0,t=0)])
                used |= core
        else:
            return False
    return seen == needed
