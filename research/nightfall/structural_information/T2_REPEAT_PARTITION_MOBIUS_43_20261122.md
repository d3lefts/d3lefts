# Two-query repeated-label Möbius reduction: 145 → 43

**NIGHTFALL · 2026-11-22 · v1.0 · structural proof revision.** This note strengthens the complete *paper* theorem in `TWO_QUERY_COMPLEX_RANKFREE_COMPLETE_PROOF_20261122.md`; it changes **no** oracle/distribution/complex-Hilbert assumptions and does not use a numerical result as proof. Independent complete mathematical referee review, global novelty clearance and end-to-end Lean closure remain open. All earlier source constants/receipts remain as historical checkpoints.

## Exact four-position identity (the new mechanism)

Let the four original ordered oracle labels be `t=(a,b,a',b')∈D^4` in an exponent-two group, and write `z=a+b+a'+b'`. For any nonzero z, define the six pair-equality indicators `E_{ij}(t)=1_{t_i=t_j}` and the four triple-equality indicators `T_I(t)=1_{t_i=t_j=t_k}` over all three-position subsets I⊂{1,2,3,4}. Then **for every t with z≠0**,

```
  1_{t has any repeated label}
   = Σ_{1≤i<j≤4} E_ij(t) − 2 Σ_{I⊂{1,2,3,4}, |I|=3} T_I(t).      (R)
```

**Complete proof by equality partitions, with repeated zero labels allowed.** Partition the four slots by equal label value. If no value repeats (type 1+1+1+1), both sums are zero. If precisely one pair repeats (2+1+1), exactly one of the six E terms is one and none of the T terms is one, so RHS=1. If precisely three slots repeat (3+1), exactly three E terms are one and exactly one T term is one, so RHS=3−2=1. The only remaining types are 2+2 and 4: **in an exponent-two group each has total XOR z=0**, hence these cases cannot appear for z≠0. These five partitions exhaust possibilities and prove (R) for any D, with no linear-independence hypothesis, no hidden rank assumption, no need to treat 0 as an actual query, and no dependence on complex coefficients. QED.

Since the identity is pointwise for each original tuple, multiply by **arbitrary complex** coefficient `c_{a,b,a',b'}` and sum at each frequency z≠0: the *entire repeated-label group B* is exactly

```
  B(z) = Σ_(six pair equalities) B_ij(z) − 2 Σ_(four triple equalities) B_I(z).
```

This is an **exact Fourier coefficient identity**, not a positivity estimate. It eliminates the previous 57-term inclusion–exclusion expansion entirely. The six original single-equality grouped coefficients remain unchanged and already have outside-heavy-span norms ≤√(2Mη) each, using the cross-path contraction and noncommuting P proof in the base paper theorem.

For any one fixed triple-equality event I, a tuple with z≠0 has exactly three labels equal x and the remaining singleton y, with z=x+y. For each z there are at most M **ordered survivor pairs** (x,y). Since z lies outside the heavy-query span, at least one original slot label x or y is light in its stage; Lemma 1's unrestricted complex path frame gives total **ungrouped** energy ≤4η for any such family. Cauchy–Schwarz over ≤M lifts per nonzero z therefore yields

```
  || B_I(outside-heavy-span) ||₂ ≤ 2 √(Mη).
```

The minus-two coefficient on four triple groups costs `4·2·2√(Mη)=16√(Mη)`. Thus the entire repeated-label class obeys the **improved rigorous paper bound**

```
 || B(outside-heavy-span) ||₂ ≤ (6√2 +16) √(Mη).            (B43)
```

Compare the original coarse `(6√2+114)√(Mη)`. No zero-frequency term is projected away or needs an estimate; it belongs to the queried span automatically, including the unqueried `0` label. The unique-zero-triple Class C has **no repeated labels** and its existing four-survivor bound remains exactly `4(1+2√3)√(Mη)`; the disjoint primitive Class A bound remains `2√(Kη)`.

## Improved full rank-free two-query theorem (paper proof, not Lean)

With every hypothesis, symbol and estimator as in the main theorem's frozen source, replacing its Lemma 4 inclusion–exclusion step with (R) gives

```
 ||f−E[f | χ_H]||₂
    ≤ [2√K + (6√2+16+4(1+2√3))√M]√η
    = [2√K + (20+6√2+8√3)√M]√η
    < (2√K + 43√M)√η,
```

where `20+6√2+8√3=42.341687834...` and `K=K₄(R),M=M₂(R)` are original ordered primitive four-XOR and nonzero pair-XOR multiplicities. Choose `η=ε²δ/(2√K+43√M)²`, query the at most 2/η heavy **legal original labels** nonadaptively, and return the conditional acceptance expectation as in the complete source proof. Therefore, for uniform binary dual s, every two-query quantum phase-oracle acceptance function with **arbitrary complex Hilbert space, orthogonal label sectors, arbitrary intermediate unitary and noncommuting effect 0≤P≤I** admits deterministic nonadaptive distributional approximation with

```
 Q_C ≤ min{|R|, ceil[ 2(2√K₄(R)+43√M₂(R))² / (ε²δ) ]}.       (T2-43)
```

The improvement is **source exact** and strictly dominates the prior 145 theorem whenever M>0. In the M-dominated regime the dominant squared coefficient falls by a factor `(145/43)²≈11.37`; that factor is *not* universal when K dominates. The model is a nonuniform classical **query count** guarantee; no polynomial-time construction, output-state simulation, full coherent response-oracle equivalence, nonuniform-secret extension or all-T theorem follows.

This proof replaces a combinatorial inclusion–exclusion loss, not any complex Hilbert-frame premise. The latter still need the independent full proof and Lean formalization already tracked in role issues #1076 and #1077.

## Independent checker, falsifiers, and credit

`scripts/check_t2_repeat_mobius_43_exact.py` enumerates all ordered 4-tuples for D={0,1,2}, D={0,1,2,3}, and D={0,...,7}, keeping **every** tuple with nonzero XOR. It checks (R) as an **integer coefficient identity** with *arbitrary symbolic complex coefficient permitted*: any coefficient assignment inherits the same equality. It also checks all five equality-partition types allowed by the nonzero XOR condition and the numeric bound `20+6√2+8√3<43`. A fail-closed dedicated Actions workflow hashes both source note and checker and reports the exact commit.

**Independent-falsifier scope:** dropping the z≠0 restriction makes (R) false on 2+2 and 4 partitions; replacing the coefficient `−2` by `−1` fails on the 3+1 partition; allowing arbitrary groups instead of exponent-two XOR breaks the cancellation of 2+2/4. These are **real necessary premises**, not implementation artifacts. Finite enumeration validates the coefficient program, not the universal quantum Hilbert inequalities or historical priority.

**Prior-art and source credit:** the six first-order complex grouped contractions and four zero-triple survivor bounds come from the NIGHTFALL #1016/#1059/#1068 author chain, with Lemnis/Axiom having independently rederived two difficult local operators in the role issue. The identity (R) is elementary Möbius arithmetic on four-slot equality partitions; novelty of that identity is **not** asserted. The original theorem's strength comes from combining it with the rank-free quantum frames and character-fiber controls. A claim of mathematical originality in that combination remains blocked on a same-model worldwide priority search and external review.

**Status gate:** strong author-side paper theorem with an exact formal coefficient identity and finite regression, **not** an independent Lean kernel terminal, not a certified external new mathematical breakthrough, not authorized publication. Preserve older 145 value as *superseded upper bound*, never overwrite its historical checksum.
