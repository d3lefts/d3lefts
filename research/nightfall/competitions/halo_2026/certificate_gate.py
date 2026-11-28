"""HALO CPU preflight: exact finite-field feasibility certificates (not a Lean kernel)."""
import json
import itertools

PRIMES = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31}


def grade(task, response):
    """1 iff a canonical primal or dual witness verifies; never execute model code."""
    try:
        p, A, b = task['p'], task['A'], task['b']
        if type(p) is not int or p not in PRIMES or not A or not A[0]:
            return 0
        m, n = len(A), len(A[0])
        if m > 64 or n > 64 or len(b) != m:
            return 0
        def vector(v, length):
            return isinstance(v, list) and len(v) == length and all(type(x) is int and 0 <= x < p for x in v)
        if not all(vector(row, n) for row in A) or not vector(b, m):
            return 0
        if not isinstance(response, str) or len(response) > 8192:
            return 0
        def unique(pairs):
            d = {}
            for k, v in pairs:
                if k in d:
                    raise ValueError('duplicate key')
                d[k] = v
            return d
        ans = json.loads(response, object_pairs_hook=unique)
        if not isinstance(ans, dict) or set(ans) != {'kind', 'witness'}:
            return 0
        w = ans['witness']
        if ans['kind'] == 'solution' and vector(w, n):
            return int(all(sum(a*x for a, x in zip(row, w)) % p == v for row, v in zip(A,b)))
        if ans['kind'] == 'inconsistent' and vector(w, m):
            return int(all(sum(w[i]*A[i][j] for i in range(m)) % p == 0 for j in range(n)) and sum(x*y for x,y in zip(w,b)) % p != 0)
        return 0
    except (ValueError, TypeError, KeyError, IndexError, RecursionError, OverflowError):
        return 0


def selftest():
    # Exhaustive independent oracle: brute force existence, then enumerate both certificate types.
    cases = checks = 0
    for p in (2,3):
        for entries in itertools.product(range(p), repeat=4):
            A = [list(entries[:2]), list(entries[2:])]
            vectors = list(itertools.product(range(p), repeat=2))
            for b in vectors:
                b = list(b)
                t = dict(p=p, A=A, b=b)
                feasible = any([sum(a*x for a,x in zip(row,w))%p for row in A] == b for w in vectors)
                accepted = {'solution':0, 'inconsistent':0}
                for w in vectors:
                    for k in accepted:
                        accepted[k] += grade(t, json.dumps(dict(kind=k, witness=list(w))))
                        checks += 1
                assert bool(accepted['solution']) == feasible
                assert bool(accepted['inconsistent']) != feasible
                cases += 1
    t = dict(p=2,A=[[1]],b=[1])
    bad = ['{}','null','{"kind":"solution","witness":[true]}','{"kind":"solution","witness":[1.0]}','{"kind":"solution","witness":[3]}','{"kind":"solution","witness":[1],"witness":[1]}','{"kind":"solution","witness":[1]} trailing','{"kind":"inconsistent","witness":[1]}','{"kind":"solution","witness":[0]}']
    assert all(grade(t,s)==0 for s in bad)
    print(json.dumps(dict(systems=cases, certificate_checks=checks, rejected_malformed=len(bad), status='pass'),sort_keys=True))

if __name__ == '__main__':
    selftest()
