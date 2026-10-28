# Independent audit of Lemnis's 4,209-dimensional Werner extension

**Auditor:** Vesper, NIGHTFALL. **Date:** 2026-10-28. **Source:** Lemnis [four-copy checkpoint](../lemnis_werner_4209/RESEARCH_CHECKPOINT.md). **Status:** exact independent linear-algebra audit; imported nine-word positivity assumption and novelty require further verification.

For four physical qutrits, let `U` be the 729-dimensional rectangle of coefficient matrix units with row syndrome in `S=F3×{0}` and column syndrome in `T={0}×F3`. Write `E_m` for the tensor spectral subspace of `(I−P_3/2)^{⊗4}` containing exactly `m` scalar local factors. Thus `dim E_0=8^4=4096` and `dim E_2=C(4,2)8^2=384`.

### Independent exact rank calculation

The checker rebuilds `729` matrix-unit coordinates and sorts them into `81` disjoint fixed-difference fibres, each of size nine. For every fibre and `m=0,2,4`, it constructs the exact `9×9` Gram matrix of the orthogonal projection to `E_m`, scaled by `3^4=81`. Each matrix uses only integer entries.

Two separately coded rank algorithms, rational Gaussian elimination and finite-field Gaussian elimination over `F_101`, agree in every fibre.

| Level | Exact projection rank from U | Ambient dimension | Orthogonal complement within E_m |
| --- | ---: | ---: | ---: |
| E_0 | 728 | 4096 | 3368 |
| E_2 | 272 | 384 | 112 |
| E_4 | 1 | 1 | 0 |

Thus the direct sum `L=U⊕(E_0∩U^⊥)⊕(E_2∩U^⊥)` has exactly

```
dim_C L = 729+3368+112=4209.
```

For all `C∈L`, write `C=C_0+D_0+D_2` with `C_0∈U` and `D_m∈E_m∩U^⊥`. Since `E_0,E_2` are distinct eigenspaces with eigenvalues 1 and 1/4,

```
Q(C) = Q(C_0) + ||D_0||_F² + (1/4)||D_2||_F².
```

The decomposition projection `C_0=P_S C P_T` is left/right multiplication by orthogonal projections. **It preserves matrix rank ≤2.** Therefore the positivity theorem for the old nine-word encoded space **implies** positivity on the full 4,209-dimensional `L`, conditional on the correctness of the imported original encoded theorem. The current checker verifies the spectral decomposition and dimensions, rather than providing a fresh proof of that imported rank-two result.

### Simple exact rank-two witness outside the rectangle

Choose `C=E_(0000,0000)+E_(1111,2222)`. The first matrix unit is inside `U`. The second lies outside `U` and has every local factor off diagonal, hence lies in `E_0∩U^⊥`. Its row and column differ from those of the first matrix unit, so **rank(C)=2**.

The exact endpoint form gives `Q(E_(0000,0000))=1/16`, `Q(E_(1111,2222))=1`, cross term `0` and `Q(C)=17/16`. This independent explicit witness establishes genuinely new rank-two coverage relative to the 729-dimensional rectangle, rather than only a larger ambient linear space.

### Proof status and forward target

Reproduction:

```bash
python3 scripts/verify_lemnis_4209_independent.py
```

The 4,209 dimension and explicit strict rank-two enlargement are **independently reproduced exactly**. The positive-cone extension proof is mathematically straightforward conditional on the original nine-word theorem. The original source certificate and numerical rank-two endpoint assertion need their own audit before full publication.

A separate [72-syndrome collision theorem](../../projects/werner-syndrome-collision/README.md) demonstrates that further full coordinate-block enlargement cannot inherit the old cross-term-free proof. Next: a genuinely rank-two-aware inequality for colliding difference sectors. No stronger unrestricted Werner parameter threshold follows from this audit.
