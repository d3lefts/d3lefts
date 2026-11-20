# Structural information as the resource for quantum query advantage (2026-11-19)

Status: theory draft. The main theorem is a short corollary of the Route 1 proof
(`mixture_aa/CLOSURE_OF_THE_JTHETA_TARGET_20261119.md`, `ROUTE1_PROOF_20261119.md`). All of it
inherits that proof's status (paper, unreviewed; Lean in progress). Priority: one search found no
link between Wyner common information and quantum query simulation; a specialist check is needed.

## 1. The resource

For a distribution `ν` of `X = (X_1, …, X_n)` on a finite product, define its **structural
information**

    S(ν) = inf { I(W; X) : X_1, …, X_n mutually independent given W },

the infimum over all latent variables `W` (any alphabet; a finite one suffices by Carathéodory).
This is Wyner's common information of `X_1, …, X_n`: the fewest bits of shared randomness from
which non-communicating parties can generate the coordinates. It measures the knowledge about a
hidden cause that makes the input a product, not how many causes there are.

Basic facts:

* `S(ν) = 0` iff `ν` is a product law.
* `S(ν) ≤ min ln M` over representations `ν = ∑_{θ ≤ M} π_θ μ_θ` with product components
  (take `W = θ`, `I ≤ H(π) ≤ ln M`). It can be far smaller: a mixture of `M` nearly identical
  products has `S ≈ 0`.
* `S(ν) ≤ H(X)` (take `W = X`).
* Subadditive under mixing: `S(λν_1 + (1−λ)ν_2) ≤ h(λ) + λS(ν_1) + (1−λ)S(ν_2)`.

## 2. Main theorem (proof complete modulo Route 1)

**Theorem (structural simulation).** Every `T`-query quantum algorithm, run on `X ∼ ν` over any
finite alphabets with any probabilities, has a deterministic classical decision tree with

    depth ≤ poly(T, 1/ε, 1/δ) · (1 + S(ν))

whose output is within `ε` of the acceptance probability except with `ν`-probability `δ`.

*Proof.* Fix `W` with `I(W; X) ≤ S(ν) + 1` and run the Route 1 simulator with `θ := W`. That proof
uses `ln M` in exactly one place: as the initial value of the entropy potential `H(π)`, which drops
in expectation by `I(θ; x_j | ρ)` per query. Replace it with
`Ψ_ρ = I(θ; X_{unqueried} | ρ)`. By the chain rule,
`I(θ; X_U | ρ) = I(θ; x_j | ρ) + E_{x_j} I(θ; X_{U∖j} | ρ, x_j)`, so `Ψ` also drops in expectation by
exactly `I(θ; x_j | ρ)` per query, is nonnegative, and starts at `I(θ; X) ≤ S(ν) + 1`. The Key Lemma,
the increment potential `Φ ≤ 2d²` and the stopping rule are unchanged (they use only conditional
independence given `θ`). The depth bound of Route 1 therefore holds with `ln M` replaced by
`S(ν) + 1`. ∎

So the cost of classical simulation is **polynomial per bit of structural information**: the
simulator never needs more knowledge about the hidden cause than `S(ν)`, and acquires it at a rate
of at least `poly(ε, δ, 1/T)` bits per query whenever it is not making progress otherwise.

## 3. Tightness and consequences

**Tight in the worst case (Bernstein–Vazirani).** `X` = the truth table of `y ↦ s·y`, `s` uniform
in `{0,1}^m`. Given `s` the coordinates are constant, so `S ≤ m`; one quantum query computes
`Maj(s)`, which needs `Ω(m)` classical queries. So the linear dependence on `S` cannot be improved
in general.

**Corollary (advantage certifies structure).** Contrapositively, any distribution on which some
`T`-query quantum algorithm beats every `q`-query classical simulation has
`S(ν) ≥ q / poly(T, 1/ε, 1/δ) − 1`. A superpolynomial average-case quantum query advantage requires
superpolynomial structural information.

**Corollary (Forrelation).** Let `F` be the Forrelation distribution on `2N` bits and
`ν = ½F + ½U`. One quantum query separates `F` from `U` with constant bias, and every classical
distinguisher needs `Ω̃(√N)` queries (Aaronson–Ambainis 2015). A simulator for `ν` with small
constant `ε, δ` yields such a distinguisher, so `S(ν) = Ω̃(√N)`; by subadditivity (`S(U) = 0`),
`S(F) ≥ 2(S(ν) − ln 2) = Ω̃(√N)`.

**Correction (2026-11-20): this corollary is weak, and a direct proof gives more.** Wyner common
information is at least the mutual information across any split of the coordinates: if `W` makes
`X_A ⊥ X_B`, then `I(X_A; X_B) ≤ I(X_A; W) ≤ I(W; X)`. For Forrelation, split into `x = sign(g)` and
`y = sign(Hg)`. `y` is uniform, so `I(x; y) ≥ ∑_j I(y_j; x)`, and given `x`, `(Hg)_j` is
approximately Gaussian with mean `√(2/π)(Hx)_j` and variance `1 − 2/π` (CLT over the half-normal
magnitudes). Each `y_j` therefore carries `≈ 0.38` bits about `x`, so `S(F) ≥ I(x; y) ≈ 0.38 N`, and
`S(F) = Θ(N)`. The quantum route gives only `Ω̃(√N)`. Keep this as a consistency check of the main
theorem, not as a result.

**Special cases recovered.** `S = 0`: the bias-free product-space AA simulation (certified).
`S ≤ ln M`: the polylog-`M` mixture simulation (Route 1).

## 4. What `S` does not capture (honest limits)

* **Not necessary.** `X` = `k` copies of each bit of a uniform `s ∈ {0,1}^m` has `S ≈ m`, yet `X` is
  a relabelling of a uniform string and admits poly(`T`) simulation with no dependence on `m`. So `S`
  bounds the cost from above; it does not characterize it.
* **Not function-relative.** `S` charges for all structure, including structure no low-degree
  function can see.
* **Polynomial in `1/δ`.** Route 2 gives `polylog(1/δ)` only for products (`S = 0`) and bounded
  rounds.

## 5. Open problems that would complete the theory

1. **Relevant structural information.** Find `S_T(ν) ≤ S(ν)`, depending on `ν` and `T` only, that
   is both sufficient (`poly(T,1/ε,1/δ)(1 + S_T)` simulation) and necessary (some `T`-query
   algorithm needs `S_T^{Ω(1)}` classical queries). Matching only degree-`≤ 2T` moments is not
   enough: in the repetition example copies of one bit have correlation 1, which no product matches.
   A candidate must at least be invariant under merging coordinates that are deterministic functions
   of each other (block structure), e.g. `S` minimised over all coarsenings of the coordinates into
   blocks queried as single symbols, at a query cost polynomial in the block size.
2. **Strong version.** `polylog(1/δ)` simulation for bounded rounds with cost `poly · (1 + S)`.
3. ~~Direct proof of the Forrelation bound~~ — done directly: `S(F) = Θ(N)` (see the correction above).
4. **Converse family.** For every `s`, a distribution with `S = s` and a `poly(log s)`-query
   quantum algorithm needing `s^{Ω(1)}` classical queries, beyond Bernstein–Vazirani.

Of these, (1) is the step from a sufficient resource to a characterization. If it holds, the theory
would say: quantum query advantage on average is exactly the cost of relevant structural knowledge.
