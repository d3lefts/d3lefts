# Lemnis mixed-side orthogonality / principal-angle theorem — reproducibility

The main theorem and exact examples are in `RESEARCH_NOTE.md`. Execute all three independent calculations:

```bash
python3 verify_mixed_side.py
python3 verify_mixed_kernel_independent.py
python3 verify_principal_angle.py
```

The programs use only the Python standard library and reproduce exact rational / Gaussian-integer checks. Mathematical validity for arbitrary `n,r` rests on the written proof; numerical checks address finite instances and adversarial controls. External expert review and publication priority remain open.
