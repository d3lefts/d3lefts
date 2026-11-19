# Claims and contributions — Aaronson–Ambainis on product spaces (2026-11-18)

Headline: a distribution-uniform Aaronson–Ambainis theorem. The quantitative influence inequality
extends from Boolean cubes to arbitrary independent product probability spaces, with constants
uniform across product probability measures: they depend on neither the alphabet size nor the
smallest symbol probability. (The law still defines the variance and the influences; only the
constants are independent of it.) The inequality contains the printed conjecture as the case of fair
bits.

## Claims

Certification baselines are **per declaration**, never retroactively per branch:
the AA product/terminal theorem passed at `d596301` ([run 44393215489](https://github.com/d3lefts/d3lefts/actions/runs/44393215489));
the printed-cube specialization passed at `d8e2016` ([run 44406881226](https://github.com/d3lefts/d3lefts/actions/runs/44406881226)),
177 modules, with `propext`, `Classical.choice`, `Quot.sound` only.
Row 6 compares constants. Row 7 is a **newer theorem** in `ProductSimulation.lean`;
its exact-head [run 44433153026](https://github.com/d3lefts/d3lefts/actions/runs/44433153026)
on `771d11af21896aa83f481b332d21d7d706b56927` has **passed**: the 178-module closure and strict named simulation audits succeeded, with only the three standard Lean logical axioms.
Do not equate the earlier 177-module certificate with certification of the newer 178th module.

| # | Claim | Form | Lean declaration |
| --- | --- | --- | --- |
| 1 | Finite product spaces: any finite alphabet, any product law, masses may be 0 or arbitrarily small | `3 Var⁵ ≤ 12500 (π² d²)⁶ Inf_j²`; no alphabet size, no minimum mass | `Influence.product_influence` |
| 2 | Different alphabet per coordinate; the bound by 1 is needed only on positive-mass words | same bound | `Heterogeneous.heterogeneous_influence` |
| 3 | Infinite products: index type in any universe, measurable coordinate spaces, a.e. bound `B`, Efron–Stein degree `≤ d` | `3 Var⁵ ≤ 12500 (π² d²)⁶ B⁶ M²` when every influence is `≤ M` | `InfinitePiAAProductTerminal.infinitePi_aa_product` |
| 4 | Product-space row bound, via the competing-symbol selector | a fractional-certificate row of cost `≤ π² d²` at every point, the same cost as Turturean's cube Theorem 6.8 | `RowBound.product_row_bound` |
| 5 | Recovers the printed conjecture as the fair-bit case, with Turturean's constant | `PrintedConjecture`, `ExplicitBound`, `MainTheorem` (`50000 π⁸ d¹²`); the statements are Turturean's Mathlib-only `Conjecture.lean`, byte-identical | `CubeAA.printedConjecture`, `CubeAA.explicitBound`, `CubeAA.mainTheorem_of_productSpace` |
| 6 | Constant on the cube | the headline form (row 1) is about 5× weaker in `Inf` than Turturean; the sharper `12500 K⁴ L² Inf²` form with `L ≤ 2d²` gives his constant exactly | via `Influence.influence_bound` and `CubeAA.sum_pincr_unif_le` |
| 7 | **Classical simulation over arbitrary finite product laws** (same finite alphabet, heterogeneous marginals, including zero masses) | Deterministic full-symbol decision tree with at most `n` queries and error probability `≤ δ` when `n ε³ δ² √δ ≥ 6√2 π⁶ d⁶` for `[0,1]`-valued coordinate-degree-`d` functions (`d ≥ 1`); equivalently `O(d⁶ ε⁻³ δ⁻⁵ᐟ²)` queries | `Simulation.simulation_rows`, `Simulation.simulation_degree`, `Simulation.build` (`ProductSimulation.lean`); **exact-head CI success**, run 44433153026 |

Row 5 uses none of Turturean's cube proof (`Chain`, `Main`, `MainTheorem` are not in the compiled
closure; CI checks this). It reuses his vendored Chebyshev/Markov block lemmas and his transport
lemmas, so it is a containment check, not an independent proof of the conjecture.

On zero masses: deleting zero-mass symbols changes nothing measure-theoretically. The content of
rows 1–3 is that no lower bound on the masses enters, so the bound is uniform as probabilities go
to 0.

## Algorithmic consequence and its exact scope

The new simulator uses **total mean absolute increment** as its potential, not the older
Efron–Stein total influence. A fractional-certificate row of cost `K` survives coordinate
restriction without a separate degree-preservation lemma; `L(g) ≤ K` and
`E[L(g|X_j)] = L(g) − pincr_j(g)`. The named decision-tree `build` has at most `n`
queries and the probability bound in row 7. The `simulation_degree` source requires
a common finite alphabet, arbitrary original-law marginals and a bounded
indicator-monomial degree-`d` function; it does **not** formally quantify over
quantum circuits.

**Quantum interpretation (paper-level bridge):** the acceptance probability of a
`T`-query finite-alphabet whole-symbol quantum oracle algorithm is a bounded real
indicator polynomial of coordinate degree `≤2T`. Substitution yields
`n ε³ δ² √δ ≥ 384√2 π⁶ T⁶`, or `O(T⁶ ε⁻³ δ⁻⁵ᐟ²)` classical queries.
Padding different finite coordinate alphabets with zero-mass symbols gives
the heterogeneous-alphabet statement, but the exact padding bridge and quantum
amplitude-to-polynomial argument are **not yet formalized in Lean**.

This is a distributional, computationally unrestricted approximation to a quantum
algorithm's **acceptance probability** on all but a specified fraction of inputs,
not a general assertion that a classical machine can solve every quantum promise
problem. For total bounded-error decision problems sampled from a product source,
it rules out superpolynomial quantum-versus-classical **distributional query**
advantages in this approximation sense; promise-conditioned distributions may
be correlated even when a reference input distribution is uniform.
Literature priority and independent expert review remain open.

**Decision/search boundary.** This is a statement about *decision* acceptance
probabilities and distributional query complexity, not general quantum search or
relation problems. Exponential quantum-vs-classical search separations are known
relative to a uniformly random oracle (Yamakawa–Zhandry, as cited in
Blanc–Docter–Strassle–Tan, arXiv:2611.11626v1, §1.2). It would be false to
claim that all exponential quantum query speedups require correlated inputs.

**Dense-promise deduction (paper-level; not a separate Lean declaration).**
Let `S` be any domain with original product probability `μ(S) ≥ θ > 0`.
Suppose a `T`-query quantum algorithm decides a Boolean function `F:S→{0,1}`
with acceptance probability `Q`, satisfying `Q(x) ≥ 2/3` for `F(x)=1`
and `Q(x) ≤ 1/3` for `F(x)=0`. Apply `simulation_degree` with
`d=2T`, `ε=1/12` and `δ=θη`. On inputs where `|Q(x)-A(x)|≤1/12`,
thresholding `A(x)` at `1/2` recovers `F(x)`, since
`1/3+1/12 < 1/2 < 2/3-1/12`. The bad set has product mass at most
`θη`; conditioning on `S` makes its relative error at most `η`.
The query count is therefore `O(T^6 θ^{-5/2} η^{-5/2})`,
independent of alphabet and symbol masses. This **does not assert** that
`μ(·|S)` is product; the `θ^{-5/2}` loss comes from conditioning a
product-source approximation on the promise domain.

**Random-oracle limitation.** The finite-query theorem alone does *not*
prove a new complexity-class inclusion for independently biased random
oracles. Theorem 11 of Blanc–Docter–Strassle–Tan (arXiv:2608.19158)
concerns a uniformly random infinite oracle and uses an additional
nonuniform-to-effective simulation/diagonalization argument under an
unrelativized class-equality premise. Replacing that oracle law by arbitrary
heterogeneous biases—including sequences approaching deterministic
values—requires rechecking the effective simulation, conditioning, and
almost-sure measure steps; it is not an automatic corollary of a finite-product
query bound. No such extension is claimed in this packet.

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
bias-free bounds are not covered by the specific sources checked. Priority of both the
influence extension and the **distribution-uniform simulator** remains unresolved.

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

- An end-to-end Lean theorem quantifying over quantum oracle circuits. The
  finite-product low-degree **decision-tree simulator is kernel-checked** in
  run 44433153026, but the quantum amplitude degree bound and dependent-alphabet
  padding bridge remain paper-level.
- A new almost-sure `PromiseBQP^A ⊆ PromiseHeurBPP^A` statement for arbitrarily biased
  random oracles; the source proof has additional computational and probabilistic
  steps, not yet checked under changing oracle laws.
- A bias-free simulation for algorithms from the hybrid argument.
- Any comparison with the Agarwal–Ben-David row constant `π² d² / 2` on product spaces.
- Any exponent improvement (degree-3 exponent 2 and Q3 remain open).
- Independence from Turturean: rows 1–5 reuse his vendored lemmas.

GMNR citations verified against the 23-page PDF by external review (2026-11-18): Lemma 2.2,
Remarks 3.4, 3.5, 4.4, Proposition 3.10, Theorem 4.3, Corollary 4.8. Turturean's fixed-bias remark
is on printed page 9 of arXiv:2611.09773.

The exact-head simulator kernel audit passed in
[run 44433153026](https://github.com/d3lefts/d3lefts/actions/runs/44433153026).
All three unaltered, hash-verified original CI named-audit JSONs are committed
with a [per-file SHA-256 and source/run register](../../../docs/nightfall-aa-receipts-20261118/register.json)
under `docs/nightfall-aa-receipts-20261118/` by successful [archive workflow
44436629265](https://github.com/d3lefts/d3lefts/actions/runs/44436629265)
on stacked Lake PR #859. This is source custody, not the 204-module Lake proof replay.
Next steps: independent review of the selector, proof-semantic simulator audit, and claim-specific
priority checks for both the product-space inequality and the quantum simulation consequence.

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
- G. Blanc, J. Docter, C. Strassle, L.-Y. Tan, *Quantum Speedups Require
  Structure or Depth*, https://arxiv.org/abs/2608.19158 (Theorem 11;
  random-oracle implications).
- G. Blanc, J. Docter, C. Strassle, L.-Y. Tan, *Proof of the
  Aaronson–Ambainis Conjecture: An Exposition*, https://arxiv.org/html/2611.11626v1
  (§1.2; quantum search boundary).
- Lean sources: `product_space/ProductRowBound.lean`, `ProductInfluence.lean`,
  `HeterogeneousAlphabets.lean`, `CubePrintedAA.lean`, and
  `universal/InfinitePiAAProductTerminal.lean`.
