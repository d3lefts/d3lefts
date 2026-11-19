#!/usr/bin/env python3
"""Independent exact Gaussian-rational audit of the coherent block oracle.

Finite tests are regression evidence, NOT a proof or substitute for Lean.
Seeds, decoders, and quantum amplitudes are varied independently.
"""
from fractions import Fraction as F
from itertools import product
from random import Random
from hashlib import sha256
from pathlib import Path

rng = Random(20261119)
checks = 0

def check(expr, context):
    global checks
    if not expr:
        raise AssertionError(context)
    checks += 1

def norm2(c):
    return c[0]**2 + c[1]**2

for m, n in product((1, 2, 3), (1, 2, 3)):
    blocks = tuple(range(1 << m))
    source_states = tuple(product(range(n), (0, 1)))
    full_states = tuple(product(range(n), (0, 1), blocks))
    for trial in range(75):
        U = {i: rng.choice(blocks) for i in range(n)}
        D = {(i, w): rng.randrange(2) for i in range(n) for w in blocks}
        # The full compiled circuit and its inverse are the same involution
        # in this exponent-two response and workspace realization.
        def compiled(s):
            i, z, w = s
            return (i, z ^ D[i, w ^ U[i]], w)
        # Independently execute each gate in sequence (not using compiled).
        def fetch(s):
            i, z, w = s
            return (i, z, w ^ U[i])
        def decode(s):
            i, z, w = s
            return (i, z ^ D[i, w], w)
        def uncompute(s):
            return fetch(s)
        for s in full_states:
            check(compiled(s) == uncompute(decode(fetch(s))),
                  ('three stages', m, n, trial, s))
            check(compiled(compiled(s)) == s,
                  ('inverse', m, n, trial, s))
        psi = {s: (F(rng.randrange(-5,6),rng.randrange(1,6)),
                   F(rng.randrange(-5,6),rng.randrange(1,6))) for s in source_states}
        initial = {s: psi[(s[0], s[1])] if s[2] == 0 else (F(0), F(0))
                   for s in full_states}
        evolved = {s: initial[compiled(s)] for s in full_states}
        ideal = {s: psi[(s[0], s[1] ^ D[s[0], U[s[0]]])]
                 if s[2] == 0 else (F(0),F(0)) for s in full_states}
        check(evolved == ideal, ('all amplitudes', m, n, trial))
        check(sum(map(norm2, initial.values())) == sum(map(norm2, evolved.values())),
              ('unitarity', m, n, trial))
        check(sum(map(norm2, initial.values())) == sum(map(norm2, psi.values())),
              ('clean embedding', m, n, trial))
print(f"PASS {checks} exact tests: all-workspace gate, coherent amplitudes, and norms")
print("SHA256",sha256(Path(__file__).read_bytes()).hexdigest())
