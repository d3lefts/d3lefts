# Conjecture E without global doubling: direct sums of binary circuits

**Date:** 2026-11-19 (US Eastern); **version:** 0.1. **Status:** self-contained author-side theorem and independent exact XOR tests. Not Lean-kernel certified, not independently human reviewed, not priority-cleared. **Unrestricted Conjecture E remains OPEN.**

## Objective and provenance

Target from `LINEAR_DISTRIBUTIONS_20261119.md`, `LINEAR_NECESSITY_20261119.md`: for a row set `R⊂F₂^m`, short-sum subspace number `N_r(R)`, and a `(c,c',h(2cT))` frame `B`, prove `Λ_T(R)=min cc'≤poly(N_{a(T)}(R),T)` without a doubling parameter. We explicitly work under the repo's existing finite-query smoothing threshold `h(q)=h(q,ε,δ)`, which is integer-valued and depends polynomially on the requested parameters.

Parallel input: `MERGING_DIRECT_SUMS_20261119.md` (Theorem F) proves a different, paper-level **simulation theorem** for direct sums of balanced blocks by merging dependent blocks into huge-alphabet product coordinates. `SMALL_DOUBLING_FRAME_AUDIT_20261119.md` and `SMALL_DOUBLING_FRAMES_20261119.md` use PFR/Bogolyubov and bound the cost via rank; this loses global K on independent rows. The present operator **constructs a genuine frame** and never uses K, PFR or an alphabet-merged simulator. Preserve Theorem F's credit and scope; neither paper argument closes general Conjecture E.

**Cheapest decisive test:** take disjoint binary cycles of lengths straddling `H=h(4T)` and a growing count of short cycles, check the actual row-to-frame words, frame-to-row words and all short B dependencies. The exact checker below does that and includes an interacting-grid negative control.

## Theorem G — K-independent frame for arbitrary independent circuit components

Let the nonzero distinct rows have a direct-sum partition

    R = F ⊔ C₁ ⊔ ... ⊔ C_b,

such that `F` consists of independent singleton components, and each `C_j={r_{j,1},...,r_{j,L_j}}` is a **binary circuit** of length `L_j≥3`: `xor_{i=1}^{L_j} r_{j,i}=0` and its only nonempty dependence is the entire circuit. The spans of different components are linearly independent; repeated rows can be deduplicated and zero rows are always constant.

For any integer `H≥0`, **one explicit frame** exists with parameters

    c=2,  c'=max(1,H−1),  girth(B)>H,
    so cost c*c'≤2 max(1,H−1).

Set `H=h(4T,ε,δ)` and use the frame definition's `h(2cT)=h(4T)`. Then, for **every T,ε,δ**,

    Λ_T(R) ≤ 2 max(1,h(4T,ε,δ)−1).                      (G1)

There is **no global doubling constant K, no number-of-blocks, ambient-dimension or rank dependence**. The quantitative bound follows the same smoothing convention as the source and is polynomial in `T,1/ε,log(1/δ)`.

### Complete constructive proof

Work separately on one component `C={r₁,...,r_L}`.

- **Long circuit `L>H`:** retain `B_C=C` unchanged. Every original row is one frame element (forward cost 1); every frame element is one original row (reverse cost 1). The unique dependence among `B_C` has size L>H, so this component is H-wise independent.
- **Short circuit `L≤H`:** define for `1≤j<L`

      b_j = r₁ + ⋯ + r_j  ∈ span(C).

  The `L−1` cumulative sums are linearly independent: the map from the basis `r₁,...,r_{L−1}` is triangular with unit diagonal. In terms of B,
  
      r₁=b₁,  r_j=b_{j−1}+b_j (2≤j<L),  r_L=b_{L−1}.

  Thus every original row costs at most 2 B queries; each b_j is a sum of j≤L−1≤H−1 original rows, giving reverse locality c'≤H−1. There is **no dependence at any length** within this frame block.
- **Free singleton:** retain it in B, costing (1,1) and having no dependence.

Because all component spans are in direct sum, **every dependence among the union B is a disjoint union of component dependences**. Every nonempty dependence has size >H, so the union B is an H-wise independent frame with global c≤2, c'≤max(1,H−1). This proves (G1), including any mixture of short and long cycle lengths: the potentially circular `h(2cT)` stays fixed because the construction has **c=2 regardless of L**. End proof.

### No long-sum subspace is needed: N_r ≤2r

Every binary circuit of length L is linearly isomorphic to the L graph-edge incidence vectors of a cycle `C_L`, each a Hamming-weight-2 word on L vertices; map the first L−1 independent rows to the first L−1 cyclic edges, and the last automatically maps to the last edge. Free singleton components map to distinct one-hot coordinates. The direct sum therefore embeds linearly and injectively in a Boolean coordinate space with **every row of Hamming weight≤2**.

Consequently every vector in sums of at most r rows has Hamming weight≤2r. Any k-dimensional binary subspace contains a vector of weight≥k: choose k coordinate pivot positions giving an isomorphism on the subspace, then take the vector whose pivot coordinates are all 1. Therefore

    N_r(R) ≤2r                                                       (G2)

for every r. This family is **firmly in the small-subspace regime**, not rescued by a hidden large subspace. No ambient physical Hamming-weight assumption is needed, because an invertible linear change of representation preserves subspace inclusion and dimension.

### Explicit unbounded-doubling, constant-frame separation

Let `R_t` be the direct sum of t triangles, with each triangle's three edges as independent vertex-pair incidence vectors except for the unique length-three circuit. Then

    |R_t|=3t,
    |R_t+R_t|=1+3t+9*binom(t,2),
    K(R_t)=(1+3t+9*binom(t,2))/(3t) ~ (3/2)t →∞,
    N_r(R_t)≤2r,
    Λ_T(R_t)≤4  for every T with h(4T)≥3.                 (G3)

For the last claim use each triangle's two cumulative basis vectors; c=2 and c'=2. If `h(4T)<3`, retaining every triangle gives a cost-1 frame (girth 3>h(2T)). Thus **Λ_T(R_t)≤4 for all T**, independent of t, while global doubling diverges.

## Critical obstacle revealed by the parallel rank-only proofs

For one circuit C_L, *every* basis `B⊂R` must omit exactly one row, and that omitted row is the XOR of all L−1 basis rows. Hence the minimum worst-case **basis-only** forward locality is `L−1`, despite `N_r(C_L)≤2r`. But if `L>h(2T)`, the redundant set `B=R` is already a valid `(1,1,h(2T))` frame.

**Formal no-go:** no inequality of the form `min_{basis B⊂R} max_{r∈R} word_B(r) ≤poly(N_{a(T)}(R),T)` can hold for arbitrary rows, even one circuit, because the left side grows as L and `N_{a(T)}≤2a(T)` is bounded independent of L. This does **not** refute Conjecture E: the conjecture allows redundant high-girth frames, which are essential.

The global `c` in the frame controls the required girth `h(2cT)`. A naive componentwise merge that chooses each component's own c and h(2c_i T) **may fail** when the maximum c is larger. The fixed-c=2 construction is specifically designed to resolve that coupling for circuit blocks. Theorem F's product-coordinate block merging is a distinct mechanism and should not be silently treated as a frame proof.

## Exact certificate and next operator

`dichotomy_tests/check_kfree_circuit_frames_exact.py` independently generates literal F₂ bitvectors for many disjoint cycles/free rows, verifies every source-to-frame and frame-to-source XOR word and budget, certifies the unique-circuit girth by rank and all single-edge deletions, replays exact triangle doubling at t up to 40, checks the basis-only obstruction on L up to 64, and extracts fundamental-circuit blocks of a basis. It also verifies that a 3×3 grid has a single interacting matroid core with multiple fundamental circuits; **it does not claim that grid is a counterexample to E**.

Next high-value attack: apply the same `c=2` / reverse-locality budget to **overlapping circuits**. A 3×3 grid is the smallest meaningful stress-test of circuit overlap, while larger grids have N_r≤2r independent of size. A proof for grid-like interacting cores or a verified lower bound on *all* (c,c') frames (not just bases) would materially change Conjecture E. Consider circuit overlap graphs, bounded-treewidth decomposition, quotient-by-short-circuit towers, and Theorem F's large-alphabet merging. Preserve the distinction between rank-only failure and actual frame counterexample.

**Status gates:** G1–G3 are short elementary paper proofs with exact finite witnesses; no named Lean terminal, no human adversarial referee or dated new-theorem priority clearance. The unrestricted E statement remains open. Do not merge or advertise a global breakthrough on the basis of this subcase.
