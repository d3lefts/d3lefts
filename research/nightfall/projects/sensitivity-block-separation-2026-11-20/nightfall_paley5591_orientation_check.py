#!/usr/bin/env python3
"""Orientation-aware exact triple intersection check for Paley T_5591.

Requires nightfall_paley5591_triple_audit.py in the same directory.
This is geometry only, not a Lean or exponent certificate.
"""
from collections import Counter
from nightfall_paley5591_triple_audit import P, method_a, method_b

def main():
    counts = method_a()
    assert counts == method_b()
    residues = {x*x % P for x in range(1, P)}
    groups = {0: [], 1: []}
    for (b,c), value in counts.items():
        tri = (0,b,c)
        t = sum(all((root-other)%P in residues for other in tri if other!=root)
                for root in tri)
        assert t in groups
        groups[t].append(value)
    assert counts[(1, 838)] == 717  # sharp directed-cycle witness
    assert counts[(1, 75)] == 716   # sharp transitive-triple witness
    assert len(groups[0]) == 2796 and len(groups[1]) == 8382
    assert min(groups[0]) == min(groups[1]) == 680
    assert max(groups[0]) == 717 and max(groups[1]) == 716
    assert Counter(groups[0])[717] == 12
    assert Counter(groups[1])[716] == 96
    for t in (0,1):
        print(f't={t}: cases={len(groups[t])}, min={min(groups[t])}, '
              f'max={max(groups[t])}, achievers={Counter(groups[t])[max(groups[t])]}')
    print('PASS: exact orientation-aware geometry; endpoint recurrence unchecked')

if __name__ == '__main__':
    main()
