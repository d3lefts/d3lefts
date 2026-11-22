# Zero-triple overlap compression: rank-free two-query constant 35 → 31

**NIGHTFALL · 2026-11-22 · proof revision v1.0.**

**Proven on paper, not kernel-certified or refereed.** This note makes a *strict quantitative* improvement over the **already merged** [#1112](https://github.com/d3lefts/d3lefts/pull/1112) source `TENSOR_T2_MOBIUS_REPEAT_CONSTANT_20261122.md` (`35`, NOT `145`). No claim of originality for its four-slot Möbius cancellation. The new operator is **joint grouping of the four zero-triple overlap corrections**. No new tensor hypothesis, quantum workspace restriction, positive-effect rank assumption or illicit oracle query is introduced. The unrestricted complex T2 grouped-energy theorem is still author-side paper level and awaits full independent review and Lean.

## Exact combinatorial identity for the correction group

Let `D=R∪{0}` be a finite binary-label set. At a nonzero frequency `z=t_0+t_1+t_2+t_3≠0`, define the **four extended zero-triple survivor indicators**

```
  E_i(t)=1[t_i != 0; all three t_j (j!=i) are nonzero;
                 XOR_{j!=i} t_j = 0]
```

and the genuine Class C indicator

```
  C(t)=1[all four labels pairwise distinct and nonzero;
          one of the four triples XORs to zero].
```

Define `R_*(t)` as the indicator that the four labels are all nonzero, have **exactly one repeated pair** `x,x` and two distinct other labels `y,w` satisfying `x+y+w=0`. The three nonzero labels `x,y,w` must be distinct. Then the **pointwise exact identity**

```
      Σ_{i=0}^3 E_i(t) = C(t) + 2 R_*(t),    for total XOR z≠0.     (Z)
```

holds. **Proof:** An XOR-zero triple of nonzero elements has all three entries distinct. If the fourth label is also distinct and nonzero, there is exactly one such triple when total XOR≠0; two different zero triples would force the omitted labels equal. If the fourth label repeats one triple entry x, it can repeat **only one** entry and there are *exactly two* choices of the omitted survivor x, corresponding to the two copies of x. No other tuple type has an extended zero triple: any triple of nonzero labels with its own repeated pair has XOR equal to its remaining nonzero singleton, not zero. Hence the total number of extended zero triples is exactly 1 on Class C, exactly 2 on `R_*`, and zero otherwise. QED.

**Important consequence of (Z):** every tuple counted in `R_*` has **total XOR z=x** (the repeated label). Thus for any fixed z≠0, choose the two positions of repeated z in `binom(4,2)=6` ways, then choose the two ordered survivor labels (y,w) with `y+w=z`. Since `M=M₂(R)` bounds *all* ordered nonzero pair fibers in `D²`, it bounds the restricted nonzero (y,w) choices as well. Therefore

```
   #{t∈R_* : total XOR(t)=z} ≤ 6 M.                         (F6)
```

This is not `12M` because a repeated tuple appears **twice** among the four extended survivor patterns, and that multiplicity has already been extracted as the factor 2 in (Z). For a nonzero z outside the heavy-query span W, the repeated label x=z is light in its respective stages. The original path-frame inequality (3) from the complete #1068 paper proof therefore bounds the total **ungrouped** squared complex coefficient energy of the entire R_* family by `4η`, despite arbitrary complex P not commuting with the projectors. Cauchy–Schwarz per frequency (F6) gives

```
  || Fourier_outsideW(Σ_{t∈R_*} c_t) ||₂
       ≤ √(6M·4η) = 2√(6Mη).                              (E6)
```

Multiply by the exact factor **2** in (Z): the **combined**, not individually estimated, overlap correction costs only `4√(6Mη)`.

## Tightened complete paper-level Fourier tail, same source hypotheses

The **four extended** zero-triple survivor groups are already bounded independently by the base noncommutative Hilbert energy proof at `√(Mη)` each, via the input-light `Uψ_d` frame or output-light `q_d` frame. Summing them costs `4√(Mη)`. Subtracting their *joint correction* using (Z) and (E6) gives

```
   || ClassC_outsideW ||₂ ≤ (4+4√6) √(Mη),                 (C31)
```

rather than the earlier `4(1+2√3)√(Mη)=(4+8√3)√(Mη)` obtained by separately correcting each survivor position.

The **already merged** four-slot Möbius identity in #1112 replaces all 57 higher pair-equality intersections by the four triple-equality patterns, with the *combined* triple correction giving

```
   || ClassB_outsideW ||₂ ≤ (6√2+8) √(Mη).                 (B35)
```

The primitive Class A remains bounded by `2√(Kη)`, where `K=K₄(R)`. Combining these **disjoint** original coefficient classes yields

```
  ||f−E[f|χ_H]||₂
    ≤ [2√K + (12+6√2+4√6)√M]√η
    ≤ (2√K+31√M)√η.
```

The final inequality has a **pure exact-rational certificate**: `√2≤3/2` since `2≤9/4`, and `√6≤5/2` since `6≤25/4`. Hence `12+6√2+4√6≤12+9+10=31`. Numerically the actual intermediate coefficient is `30.283240345...`, but the theorem uses integer 31.

**Rank-free two-query paper theorem, strengthened:** for every finite nonzero binary label set R, uniform dual secret s, any real 0<ε,δ<1, arbitrary finite or infinite-dimensional complex Hilbert space, mutually orthogonal label projectors summing to I (including a potentially nonzero 0-sector), arbitrary intervening unitary and arbitrary terminal effect `0≤P≤I`, there exists a deterministic **nonadaptive classical predictor using only actual original labels** with

```
 Q ≤ min{|R|, ceil[ 2(2√K₄(R)+31√M₂(R))²/(ε²δ) ]}.      (T2-31)
```

The estimator is the conditional expectation given the heavy original labels; uniform-secret Walsh Parseval and Markov convert the strengthened Fourier tail to the displayed distributional guarantee. No classical runtime, exact recovery, full output-distribution or quantum-state simulation, physical destructive-to-coherent-oracle conversion, or arbitrary nonuniform-secret theorem is claimed.

This improves the already merged *paper-level* constant 35 to 31, reducing the **M-dominated** square coefficient by factor `(35/31)²≈1.2747`. It also improves the author's earlier 145 constant, but it is incorrect to present 145→31 as a single previously unachieved gain: the major Möbius reduction **145→35** was already merged and scoped in #1112, with attribution preserved. The 43-only rediscovery from this branch was deleted to avoid an inferior parallel claim; its historical Git commit is available.

## Exact checker and falsification boundary

`scripts/check_t2_zero_triple_overlap_31_exact.py` independently enumerates every ordered four-slot tuple for several D, including D=F₂³. It checks (Z) as an **integer coefficient identity**, including complex coefficient generality automatically (pointwise equality implies equality after multiplication by arbitrary complex coefficients), and that for repeated correction tuples the repeated label equals total nonzero frequency. Intentional wrong cases: (a) include zero in triple, which breaks the unique-nonzero-zero-triple mechanism; (b) forget factor 2 and fail on a 2+1+1 dependency; (c) count 12M rather than the coalesced 6M, losing the improvement. An exact source-hashed Actions workflow provides the finite regression receipt. Neither code nor this paper establishes the Hilbert inequalities in Lean.

**Independent attack priorities (Lemnis/Ryev):** reconstruct (Z) and prove the six-M counting without importing this checker; independently prove `Tr(G_light P G P)≤η` with arbitrary noncommuting 0≤P≤I; independently verify the four extended survivor-group `√(Mη)` estimates, including correct placement of `Π_d P`; then build a full kernel terminal with original-label query bound. If any premise fails, retract the *quantum theorem* while preserving the independently exact combinatorial identity.

**Novelty:** equality-partition Möbius and zero-triple combinatorics are elementary. The revised **operator-bound synthesis** is an original *internal paper derivation* compared to the dated internal #1112 head, not cleared by an exhaustive worldwide prior-art search or external non-author mathematical refereeing. The full T2 quantum theorem remains draft, not certified for public claims or external submission.
