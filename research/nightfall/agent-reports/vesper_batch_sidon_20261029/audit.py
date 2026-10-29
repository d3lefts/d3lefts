#!/usr/bin/env python3
"""Independent exhaustive finite-group audit of batch_core.solve.

Oracle never constructs collisions or uses matching: it simply enumerates
deletions and recomputes all unordered pair sums, diagonals included.
"""
from itertools import combinations, product
import hashlib
from batch_core import solve, collision_system


def directly_sidon(moduli, marks):
    sums = []
    for i, a in enumerate(marks):
        for b in marks[i:]:
            sums.append(tuple((x + y) % q for x, y, q in zip(a, b, moduli)))
    return len(sums) == len(set(sums))


def brute(moduli, D, E, protected):
    free = [x for x in D if x not in protected]
    for count in range(len(free) + 1):
        for removed in combinations(free, count):
            if directly_sidon(moduli, tuple(x for x in D if x not in removed) + E):
                return count
    return None


def run():
    families = ((4,), (5,), (6,), (7,), (8,), (2, 2), (2, 3),
                (2, 4), (3, 3))
    all_cases = 0
    high_degree_cases = 0
    unique_counts = {}
    digest = hashlib.sha256()
    for moduli in families:
        elems = tuple(product(*(range(q) for q in moduli)))
        count = 0
        for n in range(1, min(3, len(elems)-1) + 1):
            for D in combinations(elems, n):
                if not directly_sidon(moduli, D):
                    continue
                outside = tuple(x for x in elems if x not in D)
                for k in range(1, min(3, len(outside)) + 1):
                    for E in combinations(outside, k):
                        families2 = collision_system(moduli, D, E)
                        if families2 is not None:
                            ordinary, special = families2
                            if any(sum(i in s for s in ordinary) >= 3 for i in range(len(D))):
                                high_degree_cases += 1
                        for mask in range(1 << n):
                            protected = tuple(D[j] for j in range(n) if mask & (1 << j))
                            expected = brute(moduli, D, E, protected)
                            ans = solve(moduli, D, E, protected)
                            actual = len(ans) if ans is not None else None
                            assert actual == expected, (
                                "wrong minimum", moduli, D, E, protected,
                                expected, actual
                            )
                            if ans is not None:
                                assert not set(ans) & set(protected)
                                assert directly_sidon(
                                    moduli, tuple(x for x in D if x not in ans) + E
                                ), ("bad returned witness", moduli, D, E, protected, ans)
                            digest.update((str((moduli, D, E, protected, actual))+'\n').encode())
                            count += 1
        unique_counts[str(moduli)] = count
        all_cases += count
        print(f"{moduli}: {count} exact cases")

    # Deliberate negative control: omitting 2a=x+y permits an incorrect
    # one-point optimum. This tests a genuine source of false reductions.
    moduli=(13,)
    D=((0,), (1,), (3,), (9,))
    E=((7,),)
    assert directly_sidon(moduli,D)
    genuine=solve(moduli,D,E)
    broken=solve(moduli,D,E,omit_special=True)
    assert genuine is not None and broken is not None
    assert len(genuine)==2 and len(broken)==1, (genuine, broken)
    assert not directly_sidon(moduli,tuple(x for x in D if x not in broken)+E)

    # Intrinsic failure of a non-Sidon insertion batch: old deletions
    # cannot repair collisions within E.
    assert solve((101,),((50,),),((0,),(1,),(2,))) is None

    # Full protection can make an otherwise viable batch infeasible.
    assert solve(moduli,D,E,D) is None

    assert all_cases > 1000
    print("COUNTS",unique_counts)
    print("HIGH-DEGREE INPUTS",high_degree_cases)
    print("TOTAL",all_cases)
    print("SHA256",digest.hexdigest())
    print("PASS: independent direct sum oracle, minimality, witness validation, negative controls")


if __name__ == "__main__":
    run()
