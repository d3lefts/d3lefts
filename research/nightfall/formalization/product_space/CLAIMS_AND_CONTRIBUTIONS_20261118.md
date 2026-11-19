# Claims and contributions — Aaronson–Ambainis on product spaces (2026-11-18)

Headline: a distribution-uniform Aaronson–Ambainis theorem. The quantitative influence inequality
extends from Boolean cubes to arbitrary independent product probability spaces, with constants
uniform across product probability measures: they depend on neither the alphabet size nor the
smallest symbol probability. (The law still defines the variance and the influences; only the
constants are independent of it.) The inequality contains the printed conjecture as the case of fair
bits.

## Claims

Certification baseline: every claim below is certified in Lean at commit `d8e2016` (CI run
44406881226, 177 modules, axioms `propext`, `Classical.choice`, `Quot.sound` only), except row 6,
which is a statement about constants. Later commits on PR #858 (`9a5188c`, a Lake-generator fix;
`18c62ab` and after, this note) change no Lean source; their AA workflow and integrated-Lake runs
must finish green before the PR is merged, and the review baseline is the last fully green commit
with its receipts.

| # | Claim | Form | Lean declaration |
| --- | --- | --- | --- |
| 1 | Finite product spaces: any finite alphabet, any product law, masses may be 0 or arbitrarily small | `3 Var⁵ ≤ 12500 (π² d²)⁶ Inf_j²`; no alphabet size, no minimum mass | `Influence.product_influence` |
| 2 | Different alphabet per coordinate; the bound by 1 is needed only on positive-mass words | same bound | `Heterogeneous.heterogeneous_influence` |
| 3 | Infinite products: index type in any universe, measurable coordinate spaces, a.e. bound `B`, Efron–Stein degree `≤ d` | `3 Var⁵ ≤ 12500 (π² d²)⁶ B⁶ M²` when every influence is `≤ M` | `InfinitePiAAProductTerminal.infinitePi_aa_product` |
| 4 | Product-space row bound, via the competing-symbol selector | a fractional-certificate row of cost `≤ π² d²` at every point, the same cost as Turturean's cube Theorem 6.8 | `RowBound.product_row_bound` |
| 5 | Recovers the printed conjecture as the fair-bit case, with Turturean's constant | `PrintedConjecture`, `ExplicitBound`, `MainTheorem` (`50000 π⁸ d¹²`); the statements are Turturean's Mathlib-only `Conjecture.lean`, byte-identical | `CubeAA.printedConjecture`, `CubeAA.explicitBound`, `CubeAA.mainTheorem_of_productSpace` |
| 6 | Constant on the cube | the headline form (row 1) is about 5× weaker in `Inf` than Turturean; the sharper `12500 K⁴ L² Inf²` form with `L ≤ 2d²` gives his constant exactly | via `Influence.influence_bound` and `CubeAA.sum_pincr_unif_le` |

Row 5 uses none of Turturean's cube proof (`Chain`, `Main`, `MainTheorem` are not in the compiled
closure; CI checks this). It reuses his vendored Chebyshev/Markov block lemmas and his transport
lemmas, so it is a containment check, not an independent proof of the conjecture.

On zero masses: deleting zero-mass symbols changes nothing measure-theoretically. The content of
rows 1–3 is that no lower bound on the masses enters, so the bound is uniform as probabilities go
to 0.

## Is it routine?

Two contributions are not routine; the rest is a port.

1. **Finite alphabets: the competing-symbol selector** inside the row bound, described below. This
   is the identifiable new proof mechanism.
2. **Infinite products: the original-source finite-cell approximation and the arbitrary-index
   lift** (`universal/InfinitePiQ2CellAverage.lean`, `product_space/MixedDifferenceDegree.lean`,
   `universal/InfinitePiAAProductTerminal.lean`). Cell averages over finitely many source
   coordinates are finite heterogeneous products; mixed differences carry the Efron–Stein degree
   bound to them, and the bound passes to the limit for an index type in any universe. This is a
   separate extension, not bookkeeping.

The influence argument after the row bound (Turturean's Theorem 8.3) ports to product laws with
only bookkeeping changes.

**What breaks.** On the cube, a set `S` of coordinates determines one alternative point, `x` with
`S` flipped. Turturean's block inequality builds a polynomial in block indicators `w` whose value at
the `b`-th unit vector is `f` at the `b`-th block's flip; overlapping blocks just flip the same bit.
On a product space each `S` has many alternatives `y` with `disagree x y = S`. The row bound must
cover the worst one, so each block `b` carries its own replacement `y_b` (chosen by `ysel`). When
several active blocks contain coordinate `i`, they can propose different symbols at `i`, and
"flip `i`" no longer names a point.

**What we do.** At coordinate `i` the selector uses a probability vector on the alphabet,
`P_i(w)(s) = [s = x_i](1 − H(cnt_i)) + cnt_{i,s} · q(cnt_i)`, where `cnt_{i,s}` counts the active
blocks proposing `s` at `i` and `H(t) = t q(t)` is the Chebyshev gate. It shares the gate mass
among the proposals in proportion to their counts. The selector
`G(w) = ∑_σ f(σ) ∏_i P_i(w)(σ_i)` is an average of `f`, so it stays bounded by 1; it has degree at
most `d m` in `w`, equals `f(x)` at the origin and `f(y_b)` at the `b`-th unit vector. From there
Turturean's endpoint bound, packing and LP duality apply unchanged (`Pv`, `Gsel`,
`product_block_inequality` in `ProductRowBound.lean`).

**What it costs.** Nothing against Turturean's proved row bound: our cost `π² d²` equals his
Theorem 6.8 (row bound for `f : Q_n → [-1, 1]`). It is a factor 2 above the stronger Boolean bound
`π² d² / 2` of Agarwal and Ben-David (arXiv:2410.19062, Theorems 3.3 and 1.7), which Turturean
recalls in Remark 6.9 and does not formalize unconditionally (upstream `FbsDegreeBound` is a
hypothesis). Whether the Agarwal–Ben-David constant extends to product spaces is open; it is not a
priority before external review.

**Imported unchanged** (vendored, Apache-2.0, credited in `vendor/aaronson_ambainis/`):
covering-LP duality `coverDuality`, the packing and limit steps in `Pack`, the degree calculus in
`Row/Degree.lean`, and the endpoint sensitivity bound `Row.sum_abs_sub_unit_le` with constant `4D²`.

## Prior work and how we differ

The binary biased case is already known with a bias-dependent loss; general alphabets and
bias-free bounds are not covered by anything we found.

| Work | Setting | Dependence on bias or alphabet |
| --- | --- | --- |
| Girish, Mittal, Nehoran, Raz, arXiv:2609.35327 | p-biased bits and slices; Remark 3.5: per-coordinate biases in `[a, 1 − a]` | Binary only. Simulation overheads polynomial in `1/a`, `a = min(p, 1 − p)` (Remark 3.4); biased-to-slice overhead has a factor `a⁻¹` (Prop. 3.10); transferred influence bounds polynomial in `a` (Thm 4.3, Remark 4.4, Cor. 4.8) |
| Turturean, arXiv:2611.09773 | uniform cube; his paper notes `AA(μ_p)` for every fixed `p` by combining his theorem with GMNR Thm 4.3 | inherits GMNR's dependence on `p`; no general alphabets |
| Huffstutler, Miloschewsky, Podder, arXiv:2611.12795 | uniform cube | uniform measure only |
| This work | any finite product law, any alphabets, infinite products | none: no alphabet size and no minimum mass in the bound |

**Sparsity, as a remark.** For bits with `p = 1/n`, GMNR's loss is polynomial in `1/a`, so
polynomial in `n`. Our inequality has no such loss. The bias-free statement concerns bounded
polynomials. GMNR's hybrid argument (Lemma 2.2) is about algorithms: for a coupling with
per-coordinate disagreement at most `γ`, a `T`-query quantum algorithm changes its acceptance
probability by at most `4T√γ` on average. It transfers simulations between nearby distributions; it
does not give an influence inequality for polynomials. The remark should cite Lemma 2.2 and
Remark 3.4 by number.

**The bit encoding of k-ary laws.** A k-ary product law is an exact product of bits under the
sequential encoding: `k − 1` independent bits, bit `s` equal to 1 with probability
`P(x = s | x ≥ s)`, and `x` decoded as the first `s` whose bit is 1. General alphabets therefore do
reduce to bits, at a price:

- The indicator `1[x = s]` becomes `b_s ∏_{t<s} (1 − b_t)`, so degree `d` becomes at most
  `d(k − 1)`. In the squared inequality `3 Var⁵ ≤ C d¹² Inf²` this costs a factor `(k − 1)¹²`; in
  the influence lower bound `Inf ≥ c Var^{5/2} / d⁶` it costs `(k − 1)⁶`.
- The conditional bit probabilities can be small even when no symbol is rare, so any
  bias-dependent reduction pays again.

These are costs of this sequential reduction, not lower bounds for every binary encoding. Our bound
pays neither. That sentence, not "no encoding exists", is the claim.

## Not claimed

These stay out of the paper until written and proved.

- A classical simulation of quantum query algorithms on k-ary or sparse product inputs. The
  inequality is the ingredient; the query-algorithm corollary is not written.
- A bias-free simulation for algorithms from the hybrid argument.
- Any comparison with the Agarwal–Ben-David row constant `π² d² / 2` on product spaces.
- Any exponent improvement (degree-3 exponent 2 and Q3 remain open).
- Independence from Turturean: rows 1–5 reuse his vendored lemmas.

GMNR citations verified against the 23-page PDF by external review (2026-11-18): Lemma 2.2,
Remarks 3.4, 3.5, 4.4, Proposition 3.10, Theorem 4.3, Corollary 4.8. Turturean's fixed-bias remark
is on printed page 9 of arXiv:2611.09773.

Next steps: external review of the selector and a priority check for the full quantitative
theorem.

## Sources

- U. Girish, K. Mittal, B. Nehoran, R. Raz, *Distributional Variants of the Aaronson–Ambainis
  Conjecture*, https://arxiv.org/abs/2609.35327
- D. Turturean, https://arxiv.org/abs/2611.09773; the remark on `AA(μ_p)` is in the applications
  section of `paper/aaronson_ambainis_paper.tex` at upstream commit `2a6ceae`
  (`physical-superintelligence/aaronson-ambainis`).
- T. Huffstutler, D. Miloschewsky, S. Podder, *A short proof of the Aaronson–Ambainis Conjecture
  via the completion framework*, https://arxiv.org/abs/2611.12795
- A. Agarwal, S. Ben-David, *Oracle separations for the quantum-classical polynomial hierarchy*,
  https://arxiv.org/abs/2410.19062 (Theorems 1.7 and 3.3); recalled in Turturean's Remark 6.9.
- Lean sources: `product_space/ProductRowBound.lean`, `ProductInfluence.lean`,
  `HeterogeneousAlphabets.lean`, `CubePrintedAA.lean`, and
  `universal/InfinitePiAAProductTerminal.lean`.
