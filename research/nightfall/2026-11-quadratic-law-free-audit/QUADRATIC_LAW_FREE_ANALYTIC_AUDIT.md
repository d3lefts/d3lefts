# Arbitrary-law quadratic influence: completed analytic dependency audit

**NIGHTFALL · 2026-11-11 · audit v1.0.** Research program: Devin J. Wright. This audit independently reconstructs, rather than invents, the matching / fourth-moment proof in *NIGHTFALL Adaptive Compression and Quadratic Observability on Product Spaces*, consolidated v4.0 (11 November 2026), Section 5. It makes no claim of independent **non-author human** review, globally established publication priority, or end-to-end Lean kernel certification. The pre-existing Lean PR #359 checks only scoped sublemmas.

## Scope and statement

Let `(Ω_i,μ_i)` be any finite family of probability spaces, initially finite alphabets of positive mass. Let `f: ∏Ω_i→R` have essential range `[-B,B]`, `B>0`, and Hoeffding (ANOVA) degree at most two. Define

- `V = Var f = E|f-Ef|²`,
- `I_i(f) = E|f-E_i f|²`, where `E_i` averages **the i-th input only**,
- `M = max_i I_i(f)`.

Then

> `V ≤ D B √M`, where `D = 15(1+√3)`; equivalently `M ≥ V²/[225(1+√3)² B²]`.

The same scalar theorem transfers to any possibly infinite independent product with its product sigma-field (or completion) for essentially bounded measurable `f` of Hoeffding degree ≤2. No uniform atom bound, common alphabet, coordinate count, or sparse interaction-graph assumption appears.

### 1. Matching mass, including the off-matching terms

Expand orthogonally `f=m+Σ_i h_i(X_i)+Σ_{i<j}h_{ij}(X_i,X_j)` with `E_i h_i=0`, `E_i h_{ij}=E_j h_{ij}=0`. Let `b_{ij}=||h_{ij}||_∞`. For a matching `P`, fix for each edge `(i,j)∈P` an `(a,b)` attaining `|h_{ij}|=b_{ij}`. Since `h_{ij}` is centered in both inputs, averaging its alternating rectangle difference

`Δ_{ij}=h_{ij}(a,b)-h_{ij}(a',b)-h_{ij}(a,b')+h_{ij}(a',b')`

over the independent pair `(a',b')` yields `h_{ij}(a,b)`. Thus a deterministic rectangle exists with `|Δ_{ij}|≥b_{ij}`. On every matched edge compare the uniform even coupling `{(a,b),(a',b')}` against the uniform odd coupling `{(a,b'),(a',b)}`, switching their order to make the difference positive. Form global experiments by independent products of these per-edge couplings and identical laws on the remaining singleton coordinates.

Every singleton term and every pair term **other than a selected matching edge** has equal expectation in both experiments: it involves at most one variable from each matching block, whose one-variable marginals are unchanged, or two distinct independent blocks, whose marginals are also unchanged. Exactly the selected terms survive, each contributing `|Δ_{ij}|/2`. Since `|f|≤B` under both experiments,

`Σ_{(i,j)∈P} b_{ij} ≤ Σ|Δ_{ij}| = 2|E_+ f-E_- f| ≤ 4B`.

This is a deterministic *all-graph* matching bound, not a separate sparse-graph hypothesis.

### 2. Greedy edge assignment: total cost ≤8B

Scan positive-weight edges in descending order of `b_{ij}`; retain an edge if it is disjoint from previously retained edges. Give each endpoint of a retained edge cost `c_i=b_{ij}` and all untouched vertices cost zero. Every edge is either retained or intersects a previously retained edge with weight at least its own; consequently it has some endpoint `i` with `c_i≥b_{ij}`. Assign each edge to one such endpoint, forming disjoint assigned-edge sets `S_i`. By the preceding matching bound, `Σ_i c_i ≤8B`.

### 3. Oscillation budget: Σ E||U_i||≤8B

For a fixed input `x`, define `osc_i(x)=sup_s f(x_{-i},s)-inf_s f(x_{-i},s)`. Choose maximizing values `y_i` for all coordinates and, independently at each coordinate, switch `x_i` to `y_i` with probability `t`. The expected output `q(t)` is a real polynomial of degree at most two because `f` has ANOVA degree ≤2; its range lies in `[-B,B]` on `[0,1]`. The endpoint Markov inequality gives `|q'(0)|≤8B`. Here `q'(0)=Σ_i (f(x_{-i},y_i)-f(x))`, a sum of nonnegative increases. Repeat with coordinatewise minimizers to obtain a combined oscillation bound `Σ_i osc_i(x)≤16B`.

Define `H_i=L²(μ_i)` and the centered section `U_i(·;X_{-i})=h_i(·)+Σ_{j≠i}h_{ij}(·,X_j)`. The standard-deviation/range inequality gives `||U_i||_{H_i}≤osc_i(X)/2`. Integrating and summing proves `Σ_i E||U_i||_{H_i}≤8B`.

### 4. Additive projection norm: Σ_i||h_i||≤7B

Write `g=m+Σ_i h_i` and for each fixed `x` set

`q_x(t)=[∏_i(E_i+t(Id-E_i))f](x)=m+tΣ_i h_i(x_i)+t²Σ_{i<j}h_{ij}(x_i,x_j)`.

Each factor `E_i+t(Id-E_i)` is a positive Markov contraction for `0≤t≤1`, so `|q_x(t)|≤B`. The **exact** interpolation identity

`g(x)=q_x(0)+q'_x(0)=-2q_x(0)+4q_x(1/2)-q_x(1)`

gives `||g||∞≤7B`. Because `g` is an additive function on the entire Cartesian product, the sum of the ranges of the separate `h_i` is at most `14B`. Popoviciu's variance bound implies `||h_i||_{H_i}≤range(h_i)/2`, hence `Σ_i||h_i||_{H_i}≤7B`. In particular the additive variance contribution is at most `7B√M`.

**Scope note:** the standalone interpolation constant 7 is sharp among arbitrary bounded degree-two polynomials on `[0,1]`; its textbook Chebyshev extremizer need not be realized by a bounded positive Markov interpolation of a nonconstant `f`. The proof requires only the upper bound.

### 5. Actual independent assigned increments, not a formal assumption

For each endpoint `i`, define in the **Hilbert space `H_i=L²(μ_i)`**

`Y_{ij}=h_{ij}(·,X_j)` for `j` whose edge has been assigned to `i`, and `Z_i=Σ_{j∈S_i}Y_{ij}`.

Distinct `Y_{ij}` are independent because they depend on distinct independent coordinates `X_j`. Their Bochner expectations are zero in `H_i` by the canonical degeneracy `E_{X_j}h_{ij}(x_i,X_j)=0`. Their pointwise Hilbert norms obey `||Y_{ij}||_{H_i}≤||h_{ij}||∞=b_{ij}≤c_i`. Thus all three requirements (independence, centering, and `c_i`-boundedness) are *proved from the product function*, with no assumption of fair signs or minimum atom mass.

Set `s_i=E||Z_i||²=Σ_{j∈S_i}E||Y_{ij}||²`. Orthogonality of the ANOVA components gives `s_i≤I_i(f)≤M` and `Σ_i s_i=Σ_{i<j}||h_{ij}||²_2` (every edge assigned once). Conditioning `U_i` on the sigma-field generated by its assigned neighbor coordinates gives `E[U_i|X_{S_i}]=h_i+Z_i` in `H_i`, so Jensen and the triangle inequality yield

`E||Z_i|| ≤ E||U_i||+||h_i||`, hence `Σ_i E||Z_i||≤8B+7B=15B`.

### 6. Exact independent-Hilbert fourth moment

For independent centered real Hilbert-valued `Y_1,...,Y_m`, put `v_j=E||Y_j||²`, `s=Σ_jv_j`. Expansion of the square of `||ΣY_j||²`, using centering and independence, gives the exact identity

`E||ΣY_j||⁴ = Σ_j E||Y_j||⁴ +2Σ_{j<k}v_jv_k +4Σ_{j<k} E⟨Y_j,Y_k⟩²`.

By Cauchy–Schwarz, `E⟨Y_j,Y_k⟩²≤v_jv_k` (independence), and if `||Y_j||≤c`, then `E||Y_j||⁴≤c²v_j`. Consequently

`E||ΣY_j||⁴ ≤ c²s +6Σ_{j<k}v_jv_k ≤ c²s+3s²`.

Specializing to the actual `Y_{ij}` gives `E||Z_i||⁴≤c_i²s_i+3s_i²`. Real interpolation between `L¹,L²,L⁴` yields

`s_i^(3/2) ≤ E||Z_i|| ·(E||Z_i||⁴)^(1/2)`, hence for `s_i>0`,

`s_i ≤ E||Z_i|| sqrt(c_i²+3s_i) ≤ (c_i+√(3M))E||Z_i||`.

For `s_i=0` the conclusion is immediate. Summing, using `E||Z_i||≤sqrt(s_i)≤sqrt M`, and the prior budgets yields

`Σ_i s_i ≤ sqrt M Σ_i c_i +√(3M)Σ_i E||Z_i|| ≤ (8+15√3) B√M`.

The additive part contributes at most `7B√M`. In the **pure quadratic** case (`h_i=0`), the same argument instead has `Σ_i E||Z_i||≤8B`, yielding the sharper subclass bound `V≤8(1+√3)B√M`. Therefore

`V=Σ_i||h_i||²+Σ_i s_i ≤15(1+√3)B√M`.

No global fourth-moment hypothesis on the full `f` is used; only the **actual independent assigned increments in `H_i`** are needed. This establishes analytically a dependency that PR #359 explicitly and correctly retains as an **unformalized premise**; it does not change the scope of the Lean declarations.

### 7. Arbitrary probability spaces and products

Bounded finite rectangular cylinder functions are `L²`-dense for arbitrary products (and completions). Choose nested finite-coordinate finite-partition sigma-fields `G_n` such that `f_n=E[f|G_n]→f` in `L²`. Here `f_n` is bounded by `B` on every positive-probability cell and can be represented on finitely many finite categorical coordinates with zero cells discarded. The product projection `E[·|G_n]` commutes with every coordinate-averaging operator `E_i` by independence; hence it preserves the annihilation identities characterizing Hoeffding degree ≤2 and satisfies `I_i(f_n)≤I_i(f)` for all `i`. Therefore `Var(f_n)→Var(f)` while `sup_iI_i(f_n)≤sup_iI_i(f)`; pass to the limit. This argument requires neither separable input sigma-fields nor a universal regular conditional probability kernel.

For a general finite-dimensional real Hilbert target `H` of dimension `r`, the argument may instead be run directly in `L²(μ_i;H)`. Every scalar direction has the same amplitude/oscillation bounds, and spherical averaging supplies `E_u√(u^T K u)≥a_r√tr K` for `K≽0` with `a_r=Γ(r/2)/(√πΓ((r+1)/2))`. The resulting rank-sensitive conclusion is `V≤15(1+√3)B√M/a_r`. Its adaptive posterior corollary needs, in addition, measurable selection and the exact `E[T_next|history]=T-I_i` identity. Those are separate, explicitly scoped steps and are not Lean-checked by this audit.

## Independent reproducibility

`check_exact_quadratic.py` builds 33 independently generated five-coordinate products with 2–3 categorical atoms per coordinate, including rare-mass cases, and exhausts their full Cartesian tables with Python `Fraction`. It verifies 546 separate matching instances, **explicit parity coupling expectation identities**, ANOVA energy/influence identities, the sharp 7B and 8B budgets, the exact Hilbert fourth-moment identity for every assigned endpoint, the variance-squared consequence and rational enclosures for square roots. The fourth-moment and matching identities are checked by independent calculations rather than by replaying the algebra above. These finite checks cannot replace the all-law proof or provide an external expert referee.

Command: `python3 research/nightfall/2026-11-quadratic-law-free-audit/check_exact_quadratic.py`. Exit code nonzero on a contradiction.

## Dated prior art — searched 11 November 2026

The relevant comparisons are:

1. **David Turturean**, *A proof of the Aaronson–Ambainis conjecture*, [arXiv:2611.09773](https://arxiv.org/abs/2611.09773), 6 November 2026: `Var^(5/2)/d^6` on the uniformly distributed Boolean cube; does not explicitly assert this arbitrary-law exponent-two degree-two theorem.
2. **Uma Girish, Kunal Mittal, Barak Nehoran and Ran Raz**, *Distributional Variants of the Aaronson–Ambainis Conjecture*, [arXiv:2609.35327](https://arxiv.org/abs/2609.35327), 28 September 2026: fixed common bias and slice equivalences, not an explicit atom-uniform, heterogeneous-alphabet degree-two constant. Its precise reductions still merit source-level examination before priority clearance.
3. **Yuval Filmus, Hamed Hatami, Nathan Keller and Noam Lifshitz**, *On the sum of the L1 influences of bounded functions*, [arXiv:1404.3396](https://arxiv.org/abs/1404.3396), revised 2015, journal 2016: bounded `L¹` influences of low-degree functions on the uniform cube. The endpoint Markov mechanism is inherited.
4. **Aaronson, Ambainis, Iraids, Kokainis and Smotrovs**, *Polynomials, Quantum Query Complexity, and Grothendieck's Inequality*, [CCC 2016](https://doi.org/10.4230/LIPIcs.CCC.2016.25); and **Briët, Escudero Gutiérrez and Gribling**, *Grothendieck inequalities characterize converses to the polynomial method*, [Quantum 8 (2024)](https://doi.org/10.22331/q-2024-11-18-1526): quadratic bounded-form theory on the uniform cube, not visibly identical to heterogeneous independent categorical inputs.
5. **O'Donnell, Saks, Schramm and Servedio**, *Every decision tree has an influential variable*, [arXiv:cs/0508071](https://arxiv.org/abs/cs/0508071), 2005: influential-variable and arbitrary-product decision-tree inequalities. Different hypothesis/output requirements.
6. **Grimmett, Janson and Norris**, *Influence in product spaces*, [arXiv:1207.1780](https://arxiv.org/abs/1207.1780), 2012 / journal 2016: general product influence/threshold results, not the specifically bounded Hoeffding-degree-two squared-variance statement.
7. **Classical** ANOVA/Hoeffding, Markov's polynomial derivative inequality, Popoviciu, Rosenthal-type moment expansions, Littlewood mixed-norm bounds and elementary greedy matching are imported ingredients, not claimed novel independently.

**Priority conclusion:** no exact statement match found in this targeted session search; **worldwide novelty remains open**. This result is an internally reconstructed analytic theorem, not a theorem with a dated independent peer-review report or end-to-end Lean kernel proof. PR #359 must not be promoted based only on its conditional declarations. The right next independent audit is a non-author mathematical referee attack on Sections 1–7 and a source-to-source check of the antecedents, particularly prior U-statistic decoupling, biased Littlewood-type inequalities and categorical junta results.

## Source integrity and revision

- Proof source: NIGHTFALL consolidated v4.0 PDF (11 November 2026), Section 5, and earlier 10 November matching source archives, authored under the NIGHTFALL research program.
- This file is a **new independent analytic audit**, not a byte-identical copy of the named but missing original `matching-core.tex` or the v4 source ZIP. Original archive hashes and source provenance should be deposited separately; never silently substitute this audit for the frozen source.
- The accompanying exact checker contains no Lean declarations. It does not alter or supersede the pinned finite all-degree Turturean transfer.