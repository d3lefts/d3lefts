# Linear distributions: the necessity half reduced to an additive-combinatorics dichotomy (2026-11-19)

Status: Theorem C and Corollary D proved on paper; the dichotomy is a conjecture. Not reviewed.
Notation as in `LINEAR_DISTRIBUTIONS_20261119.md`. For `r ≥ 1` let `r·R` be the set of sums of at
most `r` rows.

## Theorem C (subspaces in short sumsets give advantage)

If a subspace `V ⊆ F_2^m` of dimension `k` satisfies `V ⊆ r·R`, there is an `r`-query quantum
algorithm on `ν_G` whose acceptance probability is a `{0,1}`-valued function `F(s)`, while every
classical algorithm that queries parities of `s` (rows of `R` or any others) and outputs within
`ε < 1/2` of `F` except with probability `δ < 1/2` needs at least `k/2 − log₂(1/(1 − 2δ))` queries.

*Proof.* Fix for each `v ∈ V` a decomposition `v = g_{i_1(v)} + ⋯ + g_{i_r(v)}` (pad with a fixed row
used twice if needed, which contributes a trivial phase). Prepare `|V|^{-1/2} ∑_{v∈V} |v⟩`; make `r`
phase queries at indices `i_1(v), …, i_r(v)` in superposition. The state becomes
`|V|^{-1/2} ∑_v (−1)^{⟨v, s⟩} |v⟩`; Fourier transform over `V` returns `u = π_V(s)`, the coordinates of
`s` in a dual basis of `V`, exactly (Bernstein–Vazirani on `V`). Let `F(s) = IP(u_{1..k/2}, u_{k/2+1..k})`.

Classical side: `(−1)^{F}` is bent on `u`, so as a function of `s` its Fourier coefficients have
magnitude `2^{-k/2}` on a set of `2^k` characters and vanish elsewhere. A parity decision tree of depth
`q` has leaves that are affine subspaces of codimension `≤ q`; on such a leaf the bias of `(−1)^F`
is a sum of at most `2^q` coefficients, so at most `2^{q − k/2}`. Since `F ∈ {0, 1}` and `ε < 1/2`,
each leaf errs with probability at least `(1 − 2^{q−k/2})/2`, so `δ ≥ (1 − 2^{q−k/2})/2`. ∎

## Corollary D (the frame measure detects every such subspace)

By Theorem B, simulation cost is at most `p(T, Λ_T, 1/ε, 1/δ)`. Applying it at `T = r` to the
algorithm of Theorem C:

    V ⊆ r·R, dim V = k   ⇒   p(r, Λ_r(G), O(1), O(1)) ≥ k/2 − O(1),

so `Λ_r(G) ≥ k^{Ω(1)} / poly(r)`. Large subspaces inside short sumsets force large frame cost.

## The remaining direction: a structure-versus-randomness dichotomy

Define the **subspace number** `N_r(R) = max { dim V : V subspace, V ⊆ r·R }`. Spans of `r` rows
always give `N_r ≥ min(r, rank)`, which is useless (classical can query those rows); advantage needs
`N_r ≫ poly(r)`.

**Conjecture E (dichotomy).** There are polynomials `a, b` such that for every row set `R` and `T`:
if `N_{a(T)}(R) ≤ k` then `R` has a `(c, c′, h(2cT))`-frame with `c · c′ ≤ b(k, T)`.

Theorem B, Theorem C and Corollary D, together with Conjecture E, give the two-sided
characterization: on linear distributions, quantum query advantage with `poly(T)` queries is
polynomially equivalent to `N_{poly(T)}(R)` (equivalently `Λ_T`). Either short sums of rows contain a
large subspace, and Bernstein–Vazirani on it gives an advantage, or the rows have a local frame with
high independence, and classical simulation is cheap.

**Why additive combinatorics.** Conjecture E is a statement about sumset structure in `F_2^m`:

* No short dependencies (`B = R`, `Λ = 1`) means sums of `≤ h/2` rows are all distinct, i.e. maximal
  sumset growth.
* A large subspace inside `r·R` is the conclusion of Bogolyubov-type lemmas. For dense row sets,
  `|R| ≥ 2^m / K`, Sanders' quasi-polynomial Bogolyubov–Ruzsa lemma puts a subspace of codimension
  `O(log⁴ K)` inside `4·R`, so dense rows always give advantage `≈ m` at `T = 4`.
* The intermediate regime (many collisions, no large subspace) is where the polynomial
  Freiman–Ruzsa theorem (Gowers–Green–Manners–Tao) is the natural tool: small doubling forces `R` to be
  covered by few cosets of a subspace, which should be either Fourier-sampled (subspace found) or used
  as the frame.

## Worked example: unstructured rows can give advantage

Let `R` be `n = 2^{m/10}` uniformly random rows. Sums of `≤ 20` rows number about `2^{2m}/20!`; every
`v ∈ F_2^m` has about `2^m/20!` representations, and a second-moment bound with a union bound over
`2^m` vectors gives `20·R = F_2^m` with high probability. By Theorem C, a 20-query quantum algorithm
computes a function needing `m/2 − O(1)` classical queries. With `n = Cm` random rows instead, the dual
distance is `Θ(n)`, `Λ = 1`, and there is no advantage (Theorem A). So within random linear inputs the
transition from no advantage to advantage `≈ m` happens as the number of rows grows from linear to
exponential in `m`, and `N_r` tracks it.

## Next steps

1. Prove Conjecture E for row sets with small doubling (`|2·R| ≤ K|R|`) via PFR.
2. Locate the threshold for random rows exactly: for `n = m^α`, compute `N_r` and `Λ_T`.
3. Check whether `N_r` is known under another name (sumset/Fourier-sampling literature).
