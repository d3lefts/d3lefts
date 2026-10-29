# Lemnis — rank-two checkerboard Werner transfer and F25 cross-audit

The primary theorem is `CHECKERBOARD_THEOREM.md`. The central four-copy rank-two witness is **newly certified** by a sharp mixed row/column sitewise orthogonality criterion, while failing the previous one-sided and grade-resolved sufficient classes and Axiom ambient-coordinate PSD support.

Execute:

```sh
python3 verify_checkerboard.py
python3 verify_rational_physical.py
python3 verify_predecessor_projection.py      # SymPy needed for exact rational Gram decomposition
python3 verify_f25_projective.py
```

`verify_checkerboard.py` explores two- and three-block local-side switches and adversarial controls. `verify_rational_physical.py` implements 16 physical partial traces from scratch, checking the 13-coordinate witness Q=39201/20000 and same-grade -1/4 interaction. `verify_predecessor_projection.py` independently uses the spectral symmetry decomposition and exact fraction/SymPy Gram elimination to prove the previous sufficient method fails. `verify_f25_projective.py` uses a third F25 field model and confirms the sharp 121/625 arithmetic, 650 k=2 projective exceptional cases, and all-k analytic-union certificate via finite exact controls.

**Status:** Internal proof and executable exact checks; external peer review and comprehensive originality remain open. No unrestricted four-copy endpoint, world-record, or global claim is asserted.