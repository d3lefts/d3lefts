#!/usr/bin/env python3
"""Independent complex multi-rank adversarial checks for T=2 grouped energy.

A finite falsifier, NOT an all-dimensional proof or Lean kernel certificate.
Does not import the Gaussian-rational single-sector checker.
"""
from collections import Counter, defaultdict
from itertools import combinations, product
import numpy as np

D = tuple(range(8))  # F_2^3, including zero; dependent labels and XOR triples
R = D[1:]
WIDTHS = (1, 2, 1, 3, 2, 1, 2, 2)
TOL = 1.e-9


def make_unitary(rng, n):
    z = rng.normal(size=(n, n)) + 1j * rng.normal(size=(n, n))
    q, h = np.linalg.qr(z)
    d = np.diag(h)
    return q @ np.diag(np.conj(d) / np.abs(d))


def xor_span(vectors):
    w = {0}
    for a in vectors:
        w |= {x ^ a for x in tuple(w)}
    return w


def primitive(w):
    nz = [a for a in w if a]
    if len(nz) != len(set(nz)):
        return False
    for mask in range(1, 1 << len(nz)):
        z = 0
        for j, a in enumerate(nz):
            if mask & (1 << j):
                z ^= a
        if not z:
            return False
    return True


def check_trial(seed):
    rng = np.random.default_rng(seed)
    n = sum(WIDTHS)
    sector, off = {}, 0
    for a, width in zip(D, WIDTHS):
        sector[a] = slice(off, off + width)
        off += width
    U = make_unitary(rng, n)
    psi = rng.normal(size=n) + 1j * rng.normal(size=n)
    psi /= np.linalg.norm(psi)
    V = make_unitary(rng, n)
    spectrum = rng.uniform(.01, .99, size=n)
    P = (V * spectrum) @ V.conj().T
    assert np.linalg.norm(P @ P - P) > .01  # nonprojective
    assert np.allclose(P, P.conj().T)
    assert np.min(np.linalg.eigvalsh(P)) >= -TOL
    assert np.max(np.linalg.eigvalsh(P)) <= 1+TOL
    psi_a = {}
    for a in D:
        x = np.zeros(n, complex)
        x[sector[a]] = psi[sector[a]]
        psi_a[a] = x
    path = {}
    for a, b in product(D, repeat=2):
        x = np.zeros(n, complex)
        x[sector[b]] = (U @ psi_a[a])[sector[b]]
        path[a, b] = x
    p = {a: np.vdot(x, x).real for a, x in psi_a.items()}
    q = {b: sum(np.vdot(path[a, b], path[a, b]).real for a in D)
         for b in D}
    assert abs(sum(p.values()) - 1) < TOL
    assert abs(sum(q.values()) - 1) < TOL
    pairs = list(product(D, repeat=2))
    idx = {ab: i for i, ab in enumerate(pairs)}
    T = np.column_stack([path[ab] for ab in pairs])
    C = T.conj().T @ P @ T

    def c(a, b, ap, bp):
        return C[idx[ap, bp], idx[a, b]]

    coeff = defaultdict(complex)
    part = defaultdict(lambda: defaultdict(complex))
    for w in product(D, repeat=4):
        z = w[0] ^ w[1] ^ w[2] ^ w[3]
        coeff[z] += c(*w)
        if z:
            if len(set(w)) < 4:
                kind = "B"
            elif primitive(w):
                kind = "A"
            else:
                assert all(w)
                assert sum(x ^ y ^ t == 0 for x, y, t in combinations(w, 3)) == 1
                kind = "C"
            part[kind][z] += c(*w)
    for z in R:
        assert abs(coeff[z] - sum(part[k][z] for k in "ABC")) < TOL
    for s in range(8):
        signs = {a: (-1 if (a & s).bit_count() % 2 else 1) for a in D}
        state = sum((signs[a]*signs[b]*path[a,b] for a,b in pairs),
                    start=np.zeros(n, complex))
        actual = np.vdot(state, P @ state)
        symbolic = sum(((-1 if (z&s).bit_count() % 2 else 1) * v
                        for z, v in coeff.items()), 0j)
        assert abs(actual - symbolic) < TOL
        assert -TOL <= actual.real <= 1+TOL

    # Independently group the six equality events before summing their energies.
    eq = [
        {(x,y): sum(c(a,x,a,y) for a in D) for x,y in pairs},
        {(x,y): sum(c(x,b,y,b) for b in D) for x,y in pairs},
        {(x,y): sum(c(a,a,x,y) for a in D) for x,y in pairs},
        {(x,y): sum(c(x,y,a,a) for a in D) for x,y in pairs},
        {(x,y): sum(c(a,x,y,a) for a in D) for x,y in pairs},
        {(x,y): sum(c(x,b,b,y) for b in D) for x,y in pairs}
    ]
    M = max(Counter(a^b for a,b in pairs if a^b).values())
    assert M == 8
    extended = [defaultdict(complex) for _ in range(4)]
    distinct = [defaultdict(complex) for _ in range(4)]
    for w in product(D, repeat=4):
        for position in range(4):
            d = w[position]
            triple = [w[j] for j in range(4) if j != position]
            if d and all(triple) and triple[0] ^ triple[1] ^ triple[2] == 0:
                extended[position][d] += c(*w)
                if len(set(w)) == 4:
                    distinct[position][d] += c(*w)
    assert all(any(abs(x)>1e-10 for x in e.values()) for e in extended)
    for eta in (.025, .08, .13, .22, .38, .6):
        heavy = {a for a in R if p[a]>=eta or q[a]>=eta}
        outside = set(D) - xor_span(heavy)
        assert len(heavy) <= 2/eta + TOL
        if not outside:
            continue
        first = [idx[a,b] for a,b in pairs if p[a]<eta]
        second = [idx[a,b] for a,b in pairs if q[b]<eta]
        for selection in (first, second):
            Gl = T[:,selection] @ T[:,selection].conj().T
            assert np.max(np.linalg.eigvalsh(Gl)) <= eta+TOL
            assert np.linalg.norm(C[:,selection])**2 <= eta+TOL
        for j, group in enumerate(eq):
            energy = sum(abs(v)**2 for (x,y),v in group.items() if x^y in outside)
            assert energy <= 2*eta + TOL, (seed,eta,j,energy)
        for pos in range(4):
            energy = sum(abs(extended[pos][d])**2 for d in outside)
            assert energy <= eta*M + TOL, (seed,eta,pos,energy)
            corrected = sum(abs(extended[pos][d]-distinct[pos][d])**2
                            for d in outside)
            assert corrected <= 12*M*eta + TOL
    return n


def negative_control():
    # Substituting first-stage p_b for the *second-stage* q_b is invalid.
    psi = np.array([1.,0.], complex)
    swap = np.array([[0,1],[1,0]], complex)
    p1 = abs(psi[1])**2
    q1 = abs((swap @ psi)[1])**2
    assert p1 == 0 and q1 == 1
    assert q1 > .5 > p1
    print("PASS mutated wrong-stage frame premise detected: p_1=0, q_1=1")


if __name__ == "__main__":
    for seed in range(12):
        print("PASS", seed, "complex Hilbert dimension", check_trial(seed))
    negative_control()
    print("12 independent seeded finite tests; NO universal or Lean certification")
