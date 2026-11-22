# High Wyner information without a classical query penalty: parity-appended oracle

**NIGHTFALL research continuation · 2026-11-22 · v1.0**

**Status:** exact all-r algebraic construction and paper-level simulation corollary from already established product-space simulation plus classical k-wise moment matching; local independent finite enumeration and sharp negative control pass. **Not** a new all-T Lean terminal, independent novelty certificate, quantum-state simulator, or unrestricted correlated-source theorem. Unlike the conditional general binary-label T2 principle in draft #1068, the dimension-independent query consequence here does **not** depend on the unverified T2 Hilbert energy proof.

## 1. Source and legal original quantum/classical oracle

Let r≥8 and V=F₂^r. Let e₁,...,e_r be its coordinate basis, and let p=e₁+...+e_r (all ones). The **distinct original query-address set** is

```
  R_r = {e₁,...,e_r,p}          (|R_r|=r+1).
```

The secret s is uniform on V*. Every actual classical query to one label a∈R_r returns χ_a(s)=(-1)^{a·s}. The corresponding *physical* phase oracle for a quantum algorithm is `O_s=Π_0+Σ_{a∈R_r}χ_a(s)Π_a` with arbitrary finite complex workspace and orthogonal projectors summing to I. Querying p reveals the product of all basis bits with **one legal original query**. Do not charge r queries for this address or silently replace the available oracle.

The raw table `X=(χ_{e_1}(s),...,χ_{e_r}(s),χ_p(s))` is the uniform **even-parity** law on r+1 bits:
`X_{r+1}=∏_{i=1}^r X_i`. Every proper coordinate marginal is uniform and independent; the unique relation uses all r+1 addresses. There are **no deterministic duplicate characters**, and the canonical source-support quotient from `AFFINE_CHARACTER_ORACLE_QUOTIENT_20261122.md` removes nothing because the secret is uniform on the entire dual space and its annihilator is zero.

## 2. Exact structural facts (all r)

**Theorem A (Wyner information).** `C_W(X)=r ln2` nats (r bits). The table has 2^r equiprobable distinct values. Its support contains no Hamming-distance-one pair because flipping one sign destroys the product parity relation. If any product conditional law supported in this parity code contained two different words, its rectangular support would also contain a one-coordinate hybrid, a contradiction. Thus every conditional product measure is a point mass, for any supplied measurable Wyner latent W, so `H(X|W)=0` and `I(X;W)=H(X)=r ln2`. Taking W=X achieves equality. This is the classical support-rectangle mechanism, also recorded more generally in repo #987; not asserted as original here.

**Theorem B (orthogonal-array moment order).** The raw parity law ν_r and the independent fair-sign product law Q_r on r+1 coordinates agree on **every marginal of size ≤r**, exactly. Proof: each proper subset of the r+1 labels in R_r is linearly independent over F₂ (the only nonempty XOR-zero subset is all R_r). Hence its character-evaluation map from the uniform secret to the selected signs is surjective with equal-sized fibers. The order r is sharp: E_{ν_r}∏_{a∈R_r}X_a=1, whereas E_{Q_r}∏_{a∈R_r}X_a=0. This is classical k-wise independence, not original to NIGHTFALL.

**Theorem C (low primitive XOR multiplicity, but no quotient).** For r≥8,

```
  M₂(R_r) = 2,       K₄(R_r)=24,
```

where both are the exact ordered pair/primitive four-slot invariants of the **original** query set from #1068. Proof: any two distinct label subsets of sizes≤4 with equal XOR would have a nonempty symmetric-difference dependency of size≤8. The unique relation contains all r+1≥9 labels, impossible. Thus the support of each attainable nonzero XOR is unique at size≤4. An independent k-element support has exactly `4!/(4-k)!` ordered four slots padded with zero (k=1,2,3,4); the maximum is 24. Each nonzero pair XOR has precisely two ordered lifts (including (0,a),(a,0)). There is no a≠b with a source-constant ratio `χ_a/χ_b` because H⊥=0. For r=3,...,7 the invariants differ; no stronger threshold is claimed.

## 3. Unconditional *paper* corollary: all fixed T, no r-dependent query cost

**Statement.** Fix d≥1, ε,δ∈(0,1). Let f:{−1,1}^{r+1}→[0,1] have interaction degree≤d in the **original raw addressed characters**, and let `q=q_product(d, ε√(δ/2), ε²δ/2)` be any product-input classical decision-tree depth guaranteed by the merged NIGHTFALL product/Route1 theorem (e.g. #858/#970), for high-probability approximation with that tighter accuracy and failure budget. Put

```
 K=max{2d,d+q}.
```

Then a deterministic adaptive classical whole-original-label query tree t exists for the parity law ν_r with depth **at most K**, independent of r, and

```
    Pr_{ν_r}(|f(X)-t(X)|>ε) ≤ δ.                       (*)
```

This remains true even though `C_W(ν_r)=r ln2`, and it does not require the proposed rank-free T2 theorem.

**Proof.**

1. Apply the already kernel-checked product-input simulator to f under Q_r to obtain a depth-q tree t₀. Clip each output to [0,1], which cannot increase its error relative to f. Since squared error≤1, its product-source mean squared error is at most `ε²δ/2+ε²δ/2=ε²δ`.
2. If r≥K, the parity law ν_r and Q_r agree on every marginal through K (Theorem B). For any degree-d f and depth-q tree t₀, `f²` has locality≤2d; `f·t₀` has locality≤d+q; **t₀² is still a depth-q leaf function**, not a generic degree-2q polynomial. The polynomial identity `(f−t₀)²=f²−2ft₀+t₀²` therefore has exactly matching expectation under the two laws. This is the classical local-moment risk-transfer operator, formalized at the finite leaf-system algebraic level in merged #1065 and developed with complete paper tree arguments in #988. Thus `E_{ν_r}(f−t₀)²=E_{Q_r}(f−t₀)²≤ε²δ`. Markov proves (*).
3. If r<K, simply query every one of the r+1 actual original labels and output f exactly. Since r<K are integers, `r+1≤K`. In both cases depth≤K, independent of r.

For a normalized **T-query** quantum circuit using the legal phase oracle above, define its acceptance probability on **every** raw sign assignment, including off-promise assignments, by replacing χ_a(s) in the phase oracle with the corresponding independent sign x_a. This is physically unitary for all such x. Each amplitude has raw interaction degree≤T and the Born acceptance probability has degree≤2T, bounded globally in [0,1]. Consequently (*) applies with `d=max(1,2T)`, obtaining `poly(T,ε^{-1},δ^{-1})` classical **original-oracle queries independent of r**. This is acceptance-value approximation under ν_r, not full quantum state/output-distribution simulation, preprocessing-time control, or worst-case exact computation. The physical phase/path polynomial statement is the standard Beals et al. ingredient and matches the scope of archived Lean #974; a named **source-exact** Lean terminal for the entire parity-source corollary is still open.

### Why this is a sharper resource separation than duplicating bits

This family has (i) `C_W=r ln2` growing without bound; (ii) **no repeated original oracle characters** or nontrivial source-support quotient; (iii) one genuinely global parity *original address*; (iv) fixed `K4=24,M2=2` for r≥8; and (v) an unconditional paper-level *all-T* classical query guarantee from product simulation plus exact moment matching. Simply replacing the parity address with a fixed number of independent-coordinate raw queries would cost r and fail to preserve the same oracle interface. It is therefore a **meaningfully stronger falsifier of “raw Wyner CI characterizes simulation cost”** than the trivial duplicate-address example.

But the ingredients (k-wise independent even-parity law, local-moment transfer, classical product AA) already occur in prior literature and merged NIGHTFALL work; this composition is not yet a cleared standalone novelty claim.

## 4. Exact test and sharp failure fixture

`scripts/check_parity_oracle_separation_exact.py` independently computes ordered XOR fiber maxima for r=3,...,10, verifies `K4=24,M2=2` from r=8 onward; enumerates all r-wise marginals of the actual even-parity source for r=3,...,7, checks no support Hamming edges and 2^r tables; and compares exact fractional squared risks for the legal depth-2 tree

```
  f(x) = 1/2 + x₂x₃/4         (degree 2, bounded),
  t(x) = (1+x₀x₁)/2         (depth 2 decision tree).
```

With r=3 (four raw symbols), `K=max(2d,d+q)=4>r`; the risks differ sharply: `E_{ν_3}(f−t)²=1/16` but `E_{Q_3}(f−t)²=5/16`. For r≥4, the tested risks are **exactly equal** `5/16` in both laws. Thus the checker includes a genuine boundary failure, not just positive examples. Finite enumeration is not an all-r proof or novel information-theory theorem.

## 5. Status and next genuinely decisive experiments

**Established algebraically on paper:** all-r high-CW/no-quotient support facts, exact parity moment matching, and conditional-case/exact-fallback proof giving (*). **Existing kernel scope:** product theorem #858/#970; scoped `LocalMomentRisk` and `LocalMomentAtoms` bridge in merged #1065, which has **not** yet formalized every recursive adaptive DTree→leaf-system connection. **New exact finite evidence:** this note's checker and pinned CI (observe exact current-head run before claiming it passed). **No independently dated same-claim novelty clearance, human proof review, or full Lean terminal.**

**Next decisive priority:** identify a source with genuine *low-order* dependencies (not just a length-r+1 parity check) where neither (a) Wyner common information, (b) source-support character quotient, nor (c) k-wise moment matching transfers a constant-depth product simulator, yet a bounded K4/M2 **generic** quantum simulator works. This would demonstrate new reach for the still-unproved #1068 operator theorem rather than a consequence of established pseudorandomness. Alternatively derive a sharp converse/lower bound for one of these three resource mechanisms and prove a strict separation with **legal original queries**.

**References / credit:** Wyner 1975; classical orthogonal arrays/k-wise independence; Beals–Buhrman–Cleve–Mosca–de Wolf quantum polynomial method; NIGHTFALL #858, #970, #974 (unmerged historical proof), #987, #988 and merged scoped #1065; generic binary T2 paper program #1016/#1059/#1068. A priority-search failure to locate exact words does not certify new mathematics.
