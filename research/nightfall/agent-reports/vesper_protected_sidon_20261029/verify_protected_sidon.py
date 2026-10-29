#!/usr/bin/env python3
"""Independent protected-point Sidon repair audit.

Checks exact matching reduction against direct exhaustive deletion searches.
Only Python standard library. Distinct from the Axiom PR #62 checkers.
"""
import itertools

def group(moduli):
    elems = list(itertools.product(*(range(q) for q in moduli)))
    def add(a, b):
        return tuple((x + y) % q for x, y, q in zip(a, b, moduli))
    return elems, add

def sidon(D, add):
    sums = set()
    for i, a in enumerate(D):
        for b in D[i:]:
            z = add(a, b)
            if z in sums:
                return False
            sums.add(z)
    return True

def direct(D, a, protected, add):
    deletable = [x for x in D if x not in protected]
    for k in range(len(deletable) + 1):
        for removal in itertools.combinations(deletable, k):
            if sidon([x for x in D if x not in removal] + [a], add):
                return k
    return None

def matching_formula(D, a, protected, add):
    pair_sums = {add(x, y): (x, y) for i, x in enumerate(D) for y in D[i:]}
    supports = {
        frozenset((z, *pair_sums[add(a, z)]))
        for z in D if add(a, z) in pair_sums
    }
    exceptional = pair_sums.get(add(a, a))
    choices = [None] if exceptional is None else [
        x for x in set(exceptional) if x not in protected
    ]
    if not choices:
        return None

    answer = None
    for forced in choices:
        remaining = sorted(
            (s for s in supports if forced is None or forced not in s),
            key=lambda s: tuple(sorted(D.index(x) for x in s)),
        )
        available = [x for x in D if x not in protected and x != forced]
        if any(not any(x in s for x in available) for s in remaining):
            continue
        adjacent = [set() for _ in remaining]
        for x in available:
            incident = [i for i, s in enumerate(remaining) if x in s]
            assert len(incident) <= 2, "Sidon degree-two lemma violated"
            if len(incident) == 2:
                u, v = incident
                adjacent[u].add(v)
                adjacent[v].add(u)

        from functools import lru_cache
        @lru_cache(None)
        def max_matching(mask):
            if mask == 0:
                return 0
            bit = mask & -mask
            i = bit.bit_length() - 1
            best = max_matching(mask ^ bit)
            for j in adjacent[i]:
                if mask & (1 << j):
                    best = max(best, 1 + max_matching(mask ^ bit ^ (1 << j)))
            return best

        m = len(remaining)
        cost = m - max_matching((1 << m) - 1) + (forced is not None)
        answer = cost if answer is None else min(answer, cost)
    return answer

def main():
    total = 0
    families = (
        (4,), (6,), (8,), (9,), (10,), (12,),
        (2, 2), (2, 3), (2, 4), (3, 3), (2, 2, 2),
        (3, 4), (4, 4),
    )
    expected = (56, 252, 1328, 3744, 3700, 11304,
                24, 252, 496, 4608, 112, 11304, 44768)
    for mods, expected_count in zip(families, expected):
        elems, add = group(mods)
        cases = 0
        for mask in range(1, 1 << len(elems)):
            if mask.bit_count() > 5:
                continue
            D = [x for i, x in enumerate(elems) if mask & (1 << i)]
            if not sidon(D, add):
                continue
            for a in elems:
                if a in D:
                    continue
                for protected_mask in range(1 << len(D)):
                    protected = [
                        x for i, x in enumerate(D)
                        if protected_mask & (1 << i)
                    ]
                    observed = direct(D, a, protected, add)
                    predicted = matching_formula(D, a, protected, add)
                    assert observed == predicted, (
                        "counterexample", mods, D, a, protected,
                        observed, predicted
                    )
                    cases += 1
        assert cases == expected_count, (mods, cases, expected_count)
        total += cases
        print(mods, cases)
    assert total == 81948
    print("PASS: 81948 protected-point exact repair instances")

if __name__ == "__main__":
    main()
