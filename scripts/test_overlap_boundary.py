#!/usr/bin/env python3
"""Exact boundary contract for signed-translation minimum-overlap research.

Two independent Fraction implementations check the separately zero-extended
complement at all tested lags. This is a finite regression oracle, not a
continuum lower-bound proof or an independent publication referee.
"""
from fractions import Fraction as Q
from itertools import product
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LEDGER = ROOT / "research/nightfall/CERTIFICATE_TRANSPORT_LEDGER_20261029.md"


def segments(values):
    n = len(values)
    return [(Q(2*i, n), Q(2*(i+1), n), Q(v))
            for i, v in enumerate(values)]


def intersection(a, b, c, d):
    return max(Q(0), min(b, d) - max(a, c))


def direct_pair_overlap(values, shift):
    """Independent interval-pair intersection of f and the supported 1-f."""
    cells = segments(values)
    return sum((v * (1-w) * intersection(a, b, c-shift, d-shift)
                for a, b, v in cells for c, d, w in cells), Q(0))


def partition_overlap(values, shift):
    """Separate midpoint-partition oracle over all translated cell boundaries."""
    cuts = sorted(set([Q(0), Q(2)] +
                      [a for a, _, _ in segments(values)] +
                      [b for _, b, _ in segments(values)] +
                      [a-shift for a, _, _ in segments(values)] +
                      [b-shift for _, b, _ in segments(values)]))
    def sample(x):
        if x < 0 or x >= 2:
            return Q(0), False
        return Q(values[min(len(values)-1, (x*len(values)//2))]), True
    total = Q(0)
    for a, b in zip(cuts, cuts[1:]):
        mid = (a+b)/2
        f, in_f = sample(mid)
        f_shift, in_shift = sample(mid+shift)
        if in_f and in_shift:
            total += (b-a)*f*(1-f_shift)
    return total


def mass_and_autocorrelation(values, shift):
    cells = segments(values)
    # The mass term is integrated over the overlap of the two *supports*.
    mass = sum((v*intersection(a,b,-shift,Q(2)-shift)
                for a,b,v in cells), Q(0))
    auto = sum((v*w*intersection(a,b,c-shift,d-shift)
                for a,b,v in cells for c,d,w in cells), Q(0))
    return mass, auto


def check_contract():
    note = LEDGER.read_text(encoding="utf8")
    assert "Separately zero-extend the complement" in note
    assert "former unconditional identity" in note
    shifts = [Q(-3), Q(-2), Q(-3,2), Q(-1), Q(-1,3), Q(0),
              Q(1,3), Q(1), Q(3,2), Q(2), Q(3)]
    # Every profile is admissible: h * sum(values) == 1.
    profiles = [[Q(1,2)], [Q(1),Q(0)], [Q(0),Q(1)],
                [Q(1,4),Q(3,4)]]
    profiles += [list(p) for p in product([Q(0),Q(1,2),Q(1)], repeat=4)
                 if sum(p, Q(0)) == 2]
    count = 0
    for values in profiles:
        assert sum(values, Q(0))*Q(2,len(values)) == 1
        for t in shifts:
            direct = direct_pair_overlap(values, t)
            partition = partition_overlap(values, t)
            mass, auto = mass_and_autocorrelation(values, t)
            assert direct == partition == mass-auto, (values,t,direct,partition,mass,auto)
            assert 0 <= direct <= 1, (values,t,direct)
            if abs(t) >= 2:
                assert direct == 0, (values,t)
            count += 1

    f = [Q(1,2)]
    assert direct_pair_overlap(f, Q(3)) == 0
    mass, auto = mass_and_autocorrelation(f, Q(3))
    assert mass == 0 and auto == 0
    assert 1-auto == 1  # Explicitly reject the retracted formula.
    assert direct_pair_overlap(f, Q(1)) == Q(1,4)
    print(f"PASS overlap boundary: {count} exact rational (profile, lag) checks, "
          "two independent overlap oracles, retracted formula rejected")


if __name__ == "__main__":
    check_contract()
