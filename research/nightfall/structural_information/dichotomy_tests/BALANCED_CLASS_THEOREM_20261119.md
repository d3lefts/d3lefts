# Conjecture E for balanced row sets, and the exact obstruction in general (2026-11-19)

Status: Theorem F proved on paper (a short consequence of Theorems A and C). Section 2 identifies
precisely what a general proof must overcome. Not reviewed.

Notation: rows `R` spanning `F_2^m` (otherwise pass to the span). The **dependency code** is
`C_R = {a ∈ F_2^n : ∑_i a_i g_i = 0}`. Let `d(R)` be its minimum distance (the input `x = Gs` is
`(d−1)`-wise independent) and `ρ(R)` the least `r` with `r·R = F_2^m` (the covering radius of `C_R`).
`h(T) = h(T, ε, δ)` is the independence scale of Theorem A.

## 1. Theorem F (balanced row sets)

Suppose `ρ(R) ≤ p(d(R))` for a polynomial `p`. Then for every `T`:

* if `h(T) < d(R)`: every `T`-query algorithm has a simulation of depth `poly(T, 1/ε, 1/δ)`,
  independent of `m` (Theorem A with frame `B = R`, `Λ_T = 1`);
* if `h(T) ≥ d(R)`: `p(h(T))·R ⊇ ρ(R)·R = F_2^m`, so `N_{p(h(T))}(R) = m`, and by Theorem C a
  `p(h(T))`-query algorithm has classical cost `≥ m/2 − O(1)`, while every `T`-query algorithm is
  simulable with `m` queries (a basis of rows is a frame with `c ≤ m`, `c′ = 1`).

So in the balanced class the advantage is all-or-nothing, switching on at `T ≈ h^{-1}(d(R))`, and
Conjecture E holds with `a(T) = p(h(T))`. ∎

**Covered:** dual BCH (`d = 2t+1`, `ρ = 2t−1`), Gold/APN graphs (`t = 2`), random rows at every
density (`d` and `ρ` both `≈ m / log(n/m)` up to constants, w.h.p.), random linear codes, product
inputs (`C_R = 0`, `d = ∞`).

**Not covered:** row sets with short dependencies but large covering radius. Repeated rows
(`d = 2`, `ρ = m`), local codes, rank-one matrices (`d = 3`, `ρ = a = √m`), direct sums of balanced
blocks. In every such example we checked, a frame or Flanders-type subspace argument still confirms
Conjecture E, but not through Theorem F.

## 2. The exact obstruction

**Greedy frames exist at the wrong scale.** Let `B ⊆ R` be a maximal subset with no dependency of
weight `≤ h₀`. For any row `g ∉ B`, `B ∪ {g}` has such a dependency, and it must contain `g`, so `g`
is a sum of `≤ h₀ − 1` elements of `B`. Thus **every** row set has a frame with sparsity
`c = h₀ − 1`, `c′ = 1` and independence `h₀`, for every `h₀`.

A frame is useful only if its independence exceeds `h(2cT) ≥ 4k_φ c T`, a polynomially larger scale
than its sparsity `c`. The greedy frame has independence equal to its sparsity, so it never
qualifies. This is exactly why Bernstein–Vazirani has `Λ_T = m`.

**Multi-scale reformulation (Conjecture E′).** Fix scales `h₀ < h₁ < ⋯` with
`h_{j+1} = h(2 h_j T)`. Conjecture E is equivalent, up to polynomial losses, to: unless
`r·R` contains a subspace of dimension `≥ k` for some `r ≤ poly(T)`, there is a set `B` (of rows or
short sums of rows) and a scale `j` such that every row is a sum of `≤ h_j` elements of `B` and `B`
has no dependency of weight `≤ h_{j+1}`.

Plan of attack: run the greedy construction at every scale. If at scale `j` the greedy set has a
dependency of weight in `(h_j, h_{j+1}]`, use these dependencies either to merge (as with repeated
and local rows) or to grow a subspace inside a short sumset (as with BCH and rank-one). The number of
scales is `O(log m / log T)`, so a per-scale loss polynomial in `T` is affordable only if it does not
compound; controlling that compounding is the core technical problem, and the polynomial
Freiman–Ruzsa theorem is the tool for the small-doubling steps.
