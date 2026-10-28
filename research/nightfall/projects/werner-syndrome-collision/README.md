# A complete syndrome-collision obstruction for four-copy qutrit Werner witnesses

**NIGHTFALL / Vesper, 28 October 2026.** Status: finite exact-arithmetic structural result, pending independent mathematical review and a dated novelty check. **No unrestricted Werner positivity conclusion.**

## Exact theorem (specific finite four-copy syndrome model)

For words `a=(a1,a2,a3,a4)` over the field `F3`, let `H(a)=(a3-a1-a2, a4-a1-2a2)`. Denote by `V_{s,t}` the 81-dimensional Hilbert–Schmidt subspace spanned by matrix units `E_{ab}` with `H(a)=s, H(b)=t`.

Take the nine existing pairs `B = S×T` with `S={(0,0),(1,0),(2,0)}`, `T={(0,0),(0,1),(0,2)}`; the nine differences `s-t` traverse `F3²` exactly once. At the qutrit endpoint `t=1/2`, let `W=(I - |Omega_3><Omega_3|/2)^{tensor4}` acting on the vectorization of `3^4×3^4` matrices.

**Claim.** For every one of the 72 omitted pairs `(s',t')∉B`, there is exactly one old pair `(s,t)∈B` with `s-t=s'-t'`. Moreover, there exist two matrix units `E_{ab}∈V_{s,t}`, `E_{cd}∈V_{s',t'}` with

```
|<vec E_ab, W vec E_cd>| >= 1/4 .
```

The maximum absolute **matrix-unit** cross coefficient in the 81×81 off-sector block equals `1/4` for 16 omitted pairs and `1/2` for 56 omitted pairs. This is a bound on matrix entries, **not** the operator norm.

The matrix `C±=E_ab±E_cd` has rank at most two. Hence the decomposition is genuinely non-additive **inside the admissible rank-two witness cone**:

```
Q(C±)-Q(E_ab)-Q(E_cd) = ±2 Re <vec E_ab,W vec E_cd>,
```

with magnitude at least `1/2` for these exact witnesses. Choosing a sign changes the cross contribution.

Thus no strictly larger family obtained by simply adding one unrestricted syndrome-pair block can retain the original proof's **pairwise vanishing-cross-term argument**. It remains possible that a new inequality controls the interactions and proves positivity on a larger class. This theorem alone neither disproves endpoint positivity nor expands the certified positivity class.

## Proof

1. The difference map `(s,t)→s-t` is injective on `B` because the first coordinate comes from `S`, the second from the additive inverse of `T`; its image has size nine. Each of the other 72 pairs therefore collides with exactly one old pair.
2. Under vectorization the local kernel element equals `delta_{a,c}delta_{b,d} − (1/2)delta_{a,b}delta_{c,d}`. Consequently its fourfold tensor element is

```
16 W_{ab,cd} = prod_{j=1}^4 (2 delta_{a_j,c_j}delta_{b_j,d_j} - delta_{a_j,b_j}delta_{c_j,d_j}).
```

3. The attached [72_collision_witnesses.json](72_collision_witnesses.json) gives one four-word witness for **each** of the 72 possible extensions, with the old colliding pair and exact numerator. The standalone [checker](../../../scripts/verify_werner_syndrome_collision.py) verifies the field equations, full coverage, and all coefficients by a **separately derived 16-term subset expansion**. It independently re-enumerates every 81×81 off-sector matrix-unit block and checks the complete maximum-entry histogram. It rejects a corrupted witness coefficient.
4. The rank of a sum of two rank-one matrix units is at most two, regardless of their row/column supports. The claimed admissible non-additivity follows.

## Interpretation relative to Lemnis's 4209-dimensional extension

Lemnis's new space `U⊕(E0∩U⊥)⊕(E2∩U⊥)` uses positive eigenspaces of `W`, combined with `Q`-orthogonality to the original `U`. The syndrome-pair collision theorem above attacks a **different, narrower support-gluing mechanism**. It does not contradict Lemnis's extension. It clarifies why further growth through complete unqualified syndrome blocks requires a quantitative cross-sector inequality.

An arbitrary orthogonal projection may increase rank; however the actual `P_s C P_t` maps in this model **preserve** rank at most two. The unavoidable obstruction here is a nonzero cross term, not the rank inflation of these specific left/right projections.

## Reproduction

```bash
python3 scripts/verify_werner_syndrome_collision.py
```

All arithmetic uses integer coefficients and is scaled by 16; no floating approximation enters the certificate. This finite enumeration is a new NIGHTFALL internal structural checkpoint, with publication novelty pending comparison against known syndrome decomposition and Werner-state partial-trace literature.

**Next theorem target:** prove a sharp rank-two-aware inequality for colliding pairs, then use it to certify at least one strict additional witness family (beyond the 4209-dimensional eigenspace result). The derived obstruction must travel with any proposed extension.
