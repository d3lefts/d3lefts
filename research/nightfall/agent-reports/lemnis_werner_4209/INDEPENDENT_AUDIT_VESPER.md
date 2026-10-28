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

## Maximality within the original orthogonal-positive method

**Additional exact structural theorem.** Let `W` denote the fourfold Werner endpoint operator. Its positive spectral subspace is `E_+=E_0⊕E_2⊕E_4`, with respective positive eigenvalues `1,1/4,1/16`. Consider every candidate extra space

```
D = E_+ ∩ U^⊥ ∩ (W U)^⊥.
```

The first orthogonality constraint keeps the projection onto the original rectangle equal to `P_S C P_T), hence rank-preserving. The second eliminates all cross terms with the original rectangle in the quadratic form.

**Exact claim:** `D=(E_0∩U^⊥)⊕(E_2∩U^⊥)` and `dim_C D=3480`. Thus **4,209** is maximal among *this specific type* of positive-spectral, Hilbert–Schmidt-orthogonal, quadratic-form-decoupled linear extension. This is a conditional-method maximality theorem, **not** maximality among all rank-two positive witness subspaces.

**Proof.** Let `K=ker H` (nine words), and `Z=Σ_{a∈K}E_{aa}∈U`. The independent integer Gram matrices verify `P_{E_0}Z=P_{E_2}Z=0` while `P_{E_4}Z≠0`. These identities also follow from Fourier analysis of the four-coordinate linear code: its nonzero dual words have weight three, so the diagonal-code indicator has spectral support in `E_1⊕E_4`.

For any `D=D_0+D_2+D_4∈E_+∩(W U)^⊥`, pair `W D` with `Z`. The `E_0,E_2` pairings vanish, leaving `(1/16)⟨Z,D_4⟩=0`. Since `E_4` is one-dimensional and `P_{E_4}Z≠0`, we have `D_4=0`.

Now `D∈U^⊥` and `D∈(W U)^⊥` give, after projection to `U`,

```
P_U D_0 + P_U D_2 = 0,
P_U D_0 + (1/4) P_U D_2 = 0.
```

Their difference forces `P_U D_2=0`, then `P_U D_0=0`. Conversely, every vector in `(E_0∩U^⊥)⊕(E_2∩U^⊥)` satisfies both constraints. The exact projection ranks `728` and `272` give `3368+112=3480`. QED.

**Research consequence:** further strictly larger *linear* theorem classes require an altered decoupling condition, a controlled mixture involving negative eigenlevels, or a genuinely rank-two-aware inequality for interacting sectors. Increasing the number of positive spectral basis vectors within the old orthogonal method is exhausted.

### Proof status and forward target

Reproduction:

```bash
python3 scripts/verify_lemnis_4209_independent.py
```

The 4,209 dimension and explicit strict rank-two enlargement are **independently reproduced exactly**. The positive-cone extension proof is mathematically straightforward conditional on the original nine-word theorem. The original source certificate and numerical rank-two endpoint assertion need their own audit before full publication.

A separate [72-syndrome collision theorem](../../projects/werner-syndrome-collision/README.md) demonstrates that further full coordinate-block enlargement cannot inherit the old cross-term-free proof. Next: a genuinely rank-two-aware inequality for colliding difference sectors. No stronger unrestricted Werner parameter threshold follows from this audit.
