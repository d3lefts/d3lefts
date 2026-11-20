# Representation transfer, and why information alone cannot be necessary (2026-11-19)

Status: paper proofs, not reviewed, no Lean. Section 1 depends on the structural simulation theorem
(Route 1 status). Section 3 depends only on the certified product-space simulation and standard facts.

## 1. Representation transfer theorem

**Definition ((c, c′)-local representation).** A distribution `ν` on `Ω = ∏ Σ_i` has a
`(c, c′)`-local representation by `ν′` on `Ω′ = ∏ Σ′_j` if there are

* a map `Γ : Ω′ → Ω` with `X = Γ(X′)` in law for `X′ ∼ ν′`, each `Γ_i` depending on at most `c`
  coordinates of `x′` (quantum direction), and
* a factorised conditional law: given `X = x`, the coordinates `X′_j` are independent, and the law of
  `X′_j` depends on at most `c′` coordinates of `x` (classical direction).

**Theorem 1.** If `ν` has a `(c, c′)`-local representation by `ν′`, every `T`-query, `r`-round quantum
algorithm on `ν` has an `(ε, δ)`-simulation of depth `c′ · D′`, where `D′` is the `(ε, δ)`-simulation
depth on `ν′` for `2cT`-query, `2r`-round algorithms. With the structural simulation theorem,

    depth ≤ c′ · poly(cT, 1/ε, 1/δ) · (1 + S(ν′)).

*Proof.* (i) Compile: each query to `x_i` becomes "query the `≤ c` coordinates of `x′` that `Γ_i`
reads, compute `Γ_i` into an ancilla, apply the original oracle action, uncompute". This is exact, so
`Q′(x′) = Q(Γ(x′))`, with `≤ 2cT` queries in `≤ 2r` rounds. (ii) Take a deterministic tree `τ′` for
`Q′` on `ν′`. (iii) On input `x`, run `τ′`; when it asks `x′_j` for the first time, query the `≤ c′`
coordinates of `x` its conditional law depends on and sample `x′_j`; reuse it afterwards. Because the
`X′_j` are conditionally independent given `X`, sampling them one at a time in any adaptive order
produces exactly `X′ ∼ ν′(· | X = x)`, so `(x, x′)` has the joint law of `(Γ(X′), X′)`. Hence
`Pr_ν[|τ − Q| > ε] = Pr_{ν′}[|τ′ − Q′| > ε] ≤ δ`. (iv) Fix the sampling randomness by averaging. ∎

The identity representation (`c = c′ = 1`) recovers the structural simulation theorem. The `c′`
cost blocks the trivial representation that packs `x` into one giant symbol (`c = 1`, `c′ = n`).

**Representation cost.** `Λ_T(ν) = min over local representations of c′ · poly(cT) · (1 + S(ν′))`,
which upper-bounds simulation cost. The correct object is the trade-off curve over `(c, c′, S)`, not
one number, as the examples show.

## 2. Examples

| Input | Identity: `S` | Better representation | `(c, c′, S′)` | True classical cost |
| --- | --- | --- | --- | --- |
| `m` fair bits, each duplicated `k` times | `m` | merge copies into one symbol | `(1, 1, 0)` | `poly(T)`, no `m` |
| any local code of a product (each symbol a function of `≤ c` source symbols, decodable from `≤ c′`) | up to `H(X)` | the source | `(c, c′, 0)` | `c′ · poly(cT)` |
| Route 2 dyadic encoding of `k`-ary product laws | — | uniform bit blocks | `(m, 1, 0)` | used there |
| Bernstein–Vazirani, `x_y = s·y` | `≤ m` | `x′ = s` | `(m, 1, 0)` | `Θ(m)` at `T = 1` |

Duplication and local codes beat Wyner by an unbounded factor (`m` or `H(X)` against `0`). In
Bernstein–Vazirani the cost moves from information (`S = m`) to locality (`c = m`); both ends of the
curve cost about `m`, matching the true `Ω(m)`. So information and locality trade off, and a single
minimised `S` cannot match lower bounds.

## 3. Random functions: information-heavy, computationally useless

**Lemma 2 (Wyner ≥ dual total correlation).** `S(ν) ≥ H(X) − ∑_i H(X_i | X_{−i})`.
*Proof.* If the `X_i` are independent given `W`, then
`I(W; X) = H(X) − ∑_i H(X_i | W)` and `H(X_i | W) = H(X_i | W, X_{−i}) ≤ H(X_i | X_{−i})`. ∎

**The distributions.** Fix `H : [N] × {0,1}^m → {0,1}`. Let `D_H` be the law of
`X = (s, H(1, s), …, H(N, s))` with `s` uniform; `n = m + N` bits. The functions are part of the
problem and known to the algorithms, which may be tailored to `H`.

**Theorem 3.** Take `N = m` and `H` uniformly random. With probability `1 − o(1)` over `H`:

1. `S(D_H) ≥ m − o(1)` (and `≤ m`).
2. For every `T ≤ c₀ m / log m`, every `T`-query quantum algorithm on `D_H`, including algorithms
   chosen after `H`, has an `(ε, δ)`-simulation of depth `poly(T, 1/ε, 1/δ)` for all constant
   `ε, δ` with `δ² 2^m ≥ (2m)^{3T}`. The depth does not depend on `m`.

*Proof of 1.* `H(X) = m`. Given `X_{−i}`, a coordinate `y_j = H(j, s)` is determined by `s`, and
`s_i` is determined unless the two completions of `s_{−i}` have the same `y`-vector, which has
probability `2^{-m}`. So `∑_i H(X_i | X_{−i}) = o(1)` in expectation over `H`, and Lemma 2 applies.

*Proof of 2.* Let `U` be uniform on `{0,1}^n`, a product law. The averaging identity is
`E_H D_H = U`, and more strongly, for fixed `H` the points `(s, H(·, s))` for different `s` have
independent `y`-parts when `H` is random.

Fix a bounded function `g` of degree `≤ 2T` on `n` bits. The certified product-space simulation gives
a tree `τ_g` of depth `poly(T, 1/ε, 1/δ)`, built from `g` and `U` only, with
`Pr_U[|τ_g − g| > ε] ≤ δ`. Under `D_H` the bad event `B_g(s) = 1[|τ_g − g|(s, H(·, s)) > ε]` is a
function of `s` and the `s`-th column of `H`. The columns are independent, so the `2^m` indicators
are independent with average mean `Pr_U[B_g] ≤ δ`. Hoeffding gives
`Pr_H[Pr_{D_H}(B_g) > 2δ] ≤ exp(−2δ² 2^m)`.

A union bound over an `ε`-net (in sup norm) of bounded degree-`≤ 2T` functions on `n` bits finishes
it. Round the at most `n^{2T}` Fourier coefficients, each in `[−1, 1]`, to a grid of width
`ε n^{-2T}`; the net has `exp(O(n^{2T} · T log(n/ε)))` elements. This is `≪ exp(2δ² 2^m)` under the
stated condition (with `n = 2m`, it holds for `T ≤ c₀ m / log m` and constant `ε, δ`). Every
acceptance probability `Q` (even one depending on `H`) is within `ε` of a net element `g`, and
`τ_g` then simulates `Q` within `2ε` except with `D_H`-probability `2δ`. ∎

**Consequences.**

* **No information-only measure is necessary.** `D_H` has maximal Wyner common information and
  maximal dual total correlation (`≈ m`, as large as `H(X)` allows), yet no quantum algorithm with
  `T ≪ m / log m` queries has any advantage. So "large structural information can always be
  exploited" is false for `S`, for dual total correlation, and for any measure bounded below by
  them.
* **The representation cost likely fails too.** Each coordinate `H(j, s)` is a random function of
  all of `s`, so no representation with `c, c′ ≪ m` and small `S′` is apparent. We conjecture
  `Λ_T(D_H) ≳ m^{Ω(1)}`. If so, oracle-relative information is also not necessary: the easiness of
  `D_H` comes from averaging (`E_H D_H = U` with independent columns), which no exact
  representation of a single `D_H` sees.
* **What the right notion must see.** The proof suggests a computational relaxation. Call `ν`
  *`T`-pseudo-structured with parameter `σ`* if `ν` is a typical member of an ensemble `{D_H}`
  whose mean has `Λ_T ≤ σ` and whose bad events concentrate (independence across a large index
  set). Then simulation cost is at most that of the mean. Random functions have `σ = 0`. Whether a
  matching lower bound holds for such a notion is the open landmark question. It also has to avoid
  circularity: the notion must be defined without reference to simulation cost.

## 4. Status of the programme

* **Sufficiency side:** structural simulation (Wyner), representation transfer (Theorem 1), and the
  averaging argument of Theorem 3 combine into an upper bound by the cheapest of: an exact local
  representation with small common information, or a concentrated ensemble whose mean has one.
* **Necessity side:** settled negatively for information-only measures (Theorem 3). Necessity, if
  true at all, needs a computational notion of structure. Next tests: whether
  Bernstein–Vazirani-like and Forrelation distributions are pseudo-structured with small `σ` (they
  must not be), and a lower bound in the spirit of random-oracle indistinguishability for the
  conjecture `Λ_T(D_H) ≳ m^{Ω(1)}`.
