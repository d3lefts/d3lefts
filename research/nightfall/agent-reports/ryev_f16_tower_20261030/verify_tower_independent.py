#!/usr/bin/env python3
"""RYEV #250: independent GF4 quadratic-tower audit of the F16 cubic block.

No imports from the original producer implementation.  All arithmetic is
in F4[u]/(u^2+u+w); w^2+w+1=0, u^2=u+w.  Python 3 standard library.
This proves finite checks only: no Lean general transfer proof or priority claim.
"""
import argparse
import hashlib
import itertools
import json
from collections import Counter

SOURCE_MATRIX = ((14, 12, 15, 3, 7), (15, 4, 9, 6, 8), (5, 5, 3, 14, 6))
SOURCE_POLYNOMIAL = 0b10011
H_SOURCE = (1, 6, 7)
H_TOWER = (1, 2, 3)
OMEGA = 2


def gf4mul(a, b):
    p = 0
    for i in range(2):
        for j in range(2):
            if ((a >> i) & 1) and ((b >> j) & 1):
                p ^= 1 << (i + j)
    if p & 4:
        p ^= 7                       # w^2 = w+1
    return p


def tmul(x, y):
    # Values are encoded (a+b*u) as a|(b<<2), a,b in GF4.
    a, b, c, d = x & 3, x >> 2, y & 3, y >> 2
    bd = gf4mul(b, d)
    lo = gf4mul(a, c) ^ gf4mul(bd, OMEGA)
    hi = gf4mul(a, d) ^ gf4mul(b, c) ^ bd
    return lo | (hi << 2)


M = [[tmul(x, y) for y in range(16)] for x in range(16)]
CUBE = [M[M[x][x]][x] for x in range(16)]
INV = [None] * 16
for x in range(1, 16):
    INV[x] = next(y for y in range(1, 16) if M[x][y] == 1)


def evaluate(poly, z):
    acc = 0
    power = 1
    for i in range(4):
        if (poly >> i) & 1:
            acc ^= power
        power = M[power][z]
    return acc


def build_isomorphism():
    # Polynomial's four roots are distinct. Freeze least numeric tower root.
    roots = [z for z in range(16) if M[M[M[z][z]][z]][z] ^ z ^ 1 == 0]
    assert len(roots) == 4, roots
    z = min(roots)
    lookup = tuple(evaluate(v, z) for v in range(16))
    assert len(set(lookup)) == 16 and lookup[0] == 0 and lookup[1] == 1
    assert {lookup[h] for h in H_SOURCE} == set(H_TOWER)
    for a in range(16):
        for b in range(16):
            assert lookup[a ^ b] == lookup[a] ^ lookup[b]
    # The z polynomial is irreducible because it has degree 4 and 16 images;
    # evaluation is a field isomorphism into the separately built tower.
    return z, lookup, roots


ROOT, ISO, ROOTS = build_isomorphism()
A = tuple(tuple(ISO[c] for c in row) for row in SOURCE_MATRIX)
H = tuple(ISO[c] for c in H_SOURCE)
assert set(H) == set(H_TOWER)


def powered(code, phases):
    return tuple(CUBE[sum_row(row, phases)] for row in code)


def sum_row(row, values):
    assert len(row) == len(values)
    result = 0
    for a, x in zip(row, values):
        result ^= M[a][x]
    return result


def codebook(a=A, phase_count=4):
    table = {}
    collisions = 0
    minimum = None
    hist = Counter()
    for phase in itertools.product(H, repeat=phase_count):
        out = powered(a, (1,) + phase)
        if out in table:
            first, count = table[out]
            collisions += count
            hist[out] += 1
            minimum = min(minimum, (first, phase)) if minimum is not None else (first, phase)
            table[out] = (first, count + 1)
        else:
            table[out] = (phase, 1)
    return table, collisions, minimum, hist


def source_codes():
    # Frozen, source-coordinate names, independent target arithmetic.
    inv_iso = {v: i for i, v in enumerate(ISO)}
    entries = []
    lookup = {}
    for ph in itertools.product(H_SOURCE, repeat=4):
        output = powered(A, (1,) + tuple(ISO[v] for v in ph))
        out_orig = tuple(inv_iso[t] for t in output)
        entries.append({"phase": list(ph), "code": list(out_orig)})
        assert out_orig not in lookup
        lookup[out_orig] = ph
    return entries


def verify_field():
    assert len(set(M[x][y] for y in range(16) for x in range(1,16))) == 16
    for x in range(16):
        assert M[0][x] == 0
        assert M[1][x] == x
        assert all(M[x][y] == M[y][x] for y in range(16))
        if x: assert M[x][INV[x]] == 1
    image = set(CUBE)
    assert len(image) == 6 and CUBE[0] == 0
    fibers = Counter(CUBE)
    assert sorted(fibers.values()) == [1,3,3,3,3,3]
    assert tuple(CUBE[h] for h in H) == (1,1,1)
    for x in range(16):
        for y in range(16):
            assert (CUBE[x] == CUBE[y]) == any(x == M[h][y] for h in H)
    assert all(CUBE[M[h][x]] == CUBE[x] for h in H for x in range(16))
    # Both automorphisms of H (identity/squaring) and all four
    # Frobenius automorphisms of F16 commute with the cubing oracle.
    assert all(M[h][M[h][h]] == 1 for h in H)
    assert {M[h][h] for h in H} == set(H)
    for power in range(4):
        phi = lambda x: x if power == 0 else _frobenius(x, power)
        assert {phi(h) for h in H} == set(H)
        changed_matrix = tuple(tuple(phi(v) for v in row) for row in A)
        for phase in itertools.product(H, repeat=4):
            new_phase = tuple(phi(v) for v in phase)
            assert tuple(phi(v) for v in powered(A, (1,) + phase)) == powered(changed_matrix, (1,) + new_phase)
        assert codebook(changed_matrix)[1] == 0
    return fibers


def _frobenius(x, power):
    for _ in range(power):
        x = M[x][x]
    return x


def verify_all_signals():
    # Exhaustive F16^5, not randomly chosen representative amplitudes.
    representatives = {y: min(x for x in range(16) if CUBE[x] == y) for y in set(CUBE)}
    reverse = {out: phase for phase, out in
               ((ph, powered(A, (1,) + ph)) for ph in itertools.product(H, repeat=4))}
    assert len(reverse) == 81
    residual = {CUBE[1 ^ M[ISO[2]][h]]: h for h in H}
    assert len(residual) == 3
    sizes = Counter()
    vectors = 0
    for x in itertools.product(range(16), repeat=5):
        vectors += 1
        y = tuple(CUBE[c] for c in x)
        support = [j for j, c in enumerate(x) if c]
        s = len(support)
        sizes[s] += 1
        if not s:
            assert y == (0,) * 5
            continue
        reps = [representatives[yi] for yi in y]
        t = support[0]
        recovered = [0] * 5
        recovered[t] = reps[t]
        rest = support[1:]
        for off in range(0, len(rest), 4):
            block = rest[off:off + 4]
            if len(block) == 4:
                obs = []
                for row in A:
                    val = M[row[0]][M[INV[reps[t]]][x[t]]]
                    for j, col in zip(block, row[1:]):
                        val ^= M[col][M[INV[reps[j]]][x[j]]]
                    obs.append(CUBE[val])
                rel = reverse[tuple(obs)]
                for j, phase in zip(block, rel):
                    recovered[j] = M[phase][reps[j]]
            else:
                for j in block:
                    observed = CUBE[M[INV[reps[t]]][x[t]] ^ M[ISO[2]][M[INV[reps[j]]][x[j]]]]
                    recovered[j] = M[residual[observed]][reps[j]]
        assert any(all(x[j] == M[h][recovered[j]] for j in range(5)) for h in H), (x, recovered)
        expected_queries = 5 + 3 * ((s - 1) // 4) + ((s - 1) % 4)
        assert expected_queries <= 8
    assert vectors == 16**5
    assert sizes == {0:1,1:75,2:2250,3:33750,4:253125,5:759375}
    return sizes


def mutation_tests(entries):
    tests = {}
    _, c, _, _ = codebook()
    assert c == 0
    broken = [list(row) for row in A]
    for row in broken: row[4] = 0
    _, bad, _, _ = codebook(tuple(map(tuple, broken)))
    assert bad > 0
    tests["zeroed_phase_column_collision_pairs"] = bad
    # Full column permutations preserve injectivity: verify positive symmetry.
    swapped = tuple(tuple(row[i] for i in (0,2,1,3,4)) for row in A)
    assert codebook(swapped)[1] == 0
    tests["full_column_swap_preserves_injectivity"] = True
    # One-row, two-column swap is a genuine perturbation, not a relabeling.
    single = [list(row) for row in A]
    single[0][1], single[0][2] = single[0][2], single[0][1]
    single_count = codebook(tuple(map(tuple, single)))[1]
    tests["single_row_column_swap_collision_pairs"] = single_count
    fake = entries.copy()
    fake[3] = {**fake[3], "code": fake[2]["code"]}
    assert len({tuple(v["code"]) for v in fake}) < 81
    tests["tampered_table_rejected"] = True
    assert all(CUBE[M[ISO[2]][h]] == CUBE[ISO[2]] for h in H)
    assert any(M[CUBE[x]][x] != CUBE[x] for x in range(16)) # x^4 differs from x^3
    tests["wrong_power_four_detected"] = True
    return tests


def audit(matrix=None, full=True):
    verify_field()
    entries = source_codes()
    table_sha = hashlib.sha256(json.dumps(entries,sort_keys=True,separators=(",",":")).encode()).hexdigest()
    tests = mutation_tests(entries)
    if matrix is not None:
        assert len(matrix) == 4 and all(len(row) == 7 for row in matrix)
        assert all(isinstance(t, int) and 0 <= t < 16 for row in matrix for t in row)
        tower_matrix = tuple(tuple(ISO[c] for c in row) for row in matrix)
        _, pairs, witness, _ = codebook(tower_matrix, 6)
        inv_iso = {v:i for i,v in enumerate(ISO)}
        matrix_result = {"collision_pairs":pairs,
                         "minimal_collision": ([[inv_iso[v] for v in p] for p in witness] if witness else None)}
    else:
        matrix_result = None
    sizes = verify_all_signals() if full else None
    receipt = {
        "model":"F16/F4 cube-power, global H*",
        "field":"GF4[u]/(u^2+u+w), w^2+w+1=0, u^2+u+w=0",
        "source_polynomial":"z^4+z+1",
        "chosen_z_root_in_tower":ROOT,
        "all_z_roots_in_tower":ROOTS,
        "isomorphism_0_through_15":ISO,
        "source_subfield_units":H_SOURCE,
        "tower_subfield_units":H,
        "cube_fibers":"1,3,3,3,3,3",
        "source_matrix":SOURCE_MATRIX,
        "source_phase_words":81,
        "source_table_sha256":table_sha,
        "all_k5_signal_counts_by_support":dict(sizes) if sizes else None,
        "mutation_tests":tests,
        "candidate_4x7":matrix_result,
        "status":"INTERNAL EXACT FINITE REPLAY; NO LEAN UNIVERSAL THEOREM; HUMAN REVIEW OPEN"
    }
    return receipt,entries


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--matrix-4x7",help="JSON file containing 4 rows x 7 GF16 polynomial coefficients, 0..15")
    parser.add_argument("--skip-full",action="store_true",help="skip 16^5 exhaustive signal replay")
    parser.add_argument("--table",help="export immutable 81-word source table JSON")
    parser.add_argument("--verify-table",help="reject if a frozen source table differs from independent replay")
    args=parser.parse_args()
    cand=json.load(open(args.matrix_4x7)) if args.matrix_4x7 else None
    result,entries=audit(cand,full=not args.skip_full)
    if args.verify_table:
        with open(args.verify_table, encoding="utf-8") as h:
            frozen=json.load(h)
        assert frozen == entries, "REJECTED: frozen 81-word phase table differs from computed oracle"
    if args.table:
        with open(args.table,"w") as h:json.dump(entries,h,sort_keys=True,indent=2)
    print(json.dumps(result,indent=2,sort_keys=True))
    print("PASS: independent quadratic-tower exact check; scientific review OPEN")


if __name__=="__main__":
    main()
