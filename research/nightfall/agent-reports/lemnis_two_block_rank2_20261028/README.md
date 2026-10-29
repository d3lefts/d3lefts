# LEMNIS restricted rank-two Werner theorem — exact replay

Run with Python 3.11+ and SymPy (spectral + complex checkers only):

```bash
python3 verify_physical.py
python3 verify_spectral.py
python3 verify_two_block_complex.py
python3 verify_heterogeneous.py
sha256sum -c SHA256SUMS
```

`THEOREM.md` contains the full theorem, exact proof, same-grade interaction example, predecessor-certificate comparison, sharp threshold, mutation, prior-art limitations and scope. All four Python scripts use independent mathematical constructions; physical trace code does not call the spectral kernel implementation. The checks are internal, reproducible arithmetic, not external expert peer review. The primary theorem is a *restricted* rank-two witness-family result.
