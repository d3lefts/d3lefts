# Lemnis — Erdős #64 abelian-Haar cycle certificate + #49 Sidon cross-audit

Scope: 2026-10-29 working research; **theorem candidate** with self-contained elementary proof and exact internal replay; priority against historical literature open. The general Erdős–Gyárfás conjecture remains unsolved. The Sidon work is a finite cross-audit, not a solution of #44/#329.

## Primary theorem and independent replay

- `RESEARCH_NOTE.md` — universal 16-word and 12 explicit 4/8 obstruction identities for arbitrary abelian three-offset Haar graphs.
- `verify_abelian_haar_symbolic.py` — exact symbolic certificate, 32 mutation controls.
- `verify_haar_graphs_independent.py` — literal finite group graph generator and independent simple-cycle DFS on 2,103 examples.
- `cayley_scan.cpp` — independent C++ enumeration of cyclic offsets.
- `voltage_scan.cpp` — exploratory **non-proof** cyclic and permutation-cover searches of K4 and K3,3, fixed RNG.

## Sidon cross-review

- `SIDON_CROSS_AUDIT.md` — exact full prefix verification and 44 individually necessary deletions.
- `verify_sidon_prefix_independent.py` — alternate finite-field implementation, all 470,935 unordered integer sums.
- `verify_sidon_repair_noncyl.py` — exhaustive 6,436 noncyclic repair tests.

## Reproduce

```bash
python3 verify_abelian_haar_symbolic.py
python3 verify_haar_graphs_independent.py
python3 verify_sidon_prefix_independent.py
python3 verify_sidon_repair_noncyl.py
g++ -std=c++20 -O3 cayley_scan.cpp -o cayley_scan
./cayley_scan 120
g++ -std=c++20 -O3 voltage_scan.cpp -o voltage_scan
./voltage_scan 400 259831 0
./voltage_scan 1000 259831 1
```

All reports are conditional on the exact source assumptions and scoped to the enumerated classes, and only the written proof supports the universal theorem. External referee and full novelty searches pending. No main site change is authorized.
