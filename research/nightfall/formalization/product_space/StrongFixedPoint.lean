import Mathlib

/-!
# Explicit dyadic fixed-point arithmetic

This file proves the *elementary growth* needed to remove a circular
choice of dyadic block length. It does not import, assume as an axiom,
or claim to prove BDST, Bernstein, Markov, binomial concentration, or
the coherent-oracle pullback.

The remaining quantitative adapter must supply:
* `h ≤ H * m^N` from a concrete uniform-cube simulator depth bound;
* `H ≤ c * η * 2^A` from its constants;
* `A ≤ 2*N^2`.

Choosing `m=4*N^2` then provably ensures `2^{-m} ≤ c*η/h`.
The quadratic choice is deliberately conservative and avoids real
logarithms in the kernel theorem.
-/

namespace Nightfall.StrongSimulation.FixedPoint

/-- A simple exact growth bound, valid for every positive natural n. -/
theorem two_mul_le_two_pow (n : ℕ) (hn : 1 ≤ n) :
    2 * n ≤ 2 ^ n := by
  induction n, hn using Nat.le_induction with
  | base => norm_num
  | succ n hn ih =>
    calc
      2 * (n + 1) ≤ 2 * (2 * n) := by omega
      _ ≤ 2 * (2 ^ n) := Nat.mul_le_mul_left 2 ih
      _ = 2 ^ (n + 1) := by rw [pow_succ]; omega

/-- The dyadic exponential dominates the power at the *explicit*
quadratic block size, without analytic estimates or asymptotics. -/
theorem quadratic_nat_growth (N : ℕ) (hN : 1 ≤ N) :
    (4 * N ^ 2) ^ N ≤ 2 ^ (2 * N ^ 2) := by
  have hb : 2 * N ≤ 2 ^ N := two_mul_le_two_pow N hN
  calc
    (4 * N ^ 2) ^ N = ((2 * N) ^ 2) ^ N := by congr 1; ring
    _ = (2 * N) ^ (2 * N) := by rw [← pow_mul]
    _ ≤ (2 ^ N) ^ (2 * N) := by gcongr
    _ = 2 ^ (2 * N ^ 2) := by
      rw [← pow_mul]
      congr 1
      ring

theorem quadratic_real_growth (N : ℕ) (hN : 1 ≤ N) :
    (((4 * N ^ 2 : ℕ) : ℝ) ^ N) ≤
      (2 : ℝ) ^ (2 * N ^ 2) := by
  exact_mod_cast quadratic_nat_growth N hN

/-- Noncircular fixed-point arithmetic: m=4N² and k=2N². -/
theorem explicit_dyadic_fixed_point
    (N : ℕ) (H h c η : ℝ)
    (hN : 1 ≤ N) (hH : 0 ≤ H)
    (hpoly : h ≤ H * (((4 * N ^ 2 : ℕ) : ℝ) ^ N))
    (hbudget : H ≤ c * η * (2 : ℝ) ^ (2 * N ^ 2)) :
    h ≤ c * η * (2 : ℝ) ^ (4 * N ^ 2) := by
  have hgrowth := quadratic_real_growth N hN
  have h1 : H * (((4 * N ^ 2 : ℕ) : ℝ) ^ N) ≤
      H * (2 : ℝ) ^ (2 * N ^ 2) :=
    mul_le_mul_of_nonneg_left hgrowth hH
  have h2 : H * (2 : ℝ) ^ (2 * N ^ 2) ≤
      (c * η * (2 : ℝ) ^ (2 * N ^ 2)) *
        (2 : ℝ) ^ (2 * N ^ 2) :=
    mul_le_mul_of_nonneg_right hbudget (by positivity)
  calc
    h ≤ H * (((4 * N ^ 2 : ℕ) : ℝ) ^ N) := hpoly
    _ ≤ H * (2 : ℝ) ^ (2 * N ^ 2) := h1
    _ ≤ (c * η * (2 : ℝ) ^ (2 * N ^ 2)) *
          (2 : ℝ) ^ (2 * N ^ 2) := h2
    _ = c * η * (2 : ℝ) ^ (4 * N ^ 2) := by
      calc
        (c * η * (2 : ℝ) ^ (2 * N ^ 2)) *
              (2 : ℝ) ^ (2 * N ^ 2) =
            c * η * ((2 : ℝ) ^ (2 * N ^ 2) *
              (2 : ℝ) ^ (2 * N ^ 2)) := by ring
        _ = c * η * (2 : ℝ) ^ (4 * N ^ 2) := by
          rw [← pow_add]
          congr 1
          ring

/-- The same statement in the useful rounding-error form. -/
theorem explicit_rounding_condition
    (N : ℕ) (H h c η : ℝ)
    (hN : 1 ≤ N) (hH : 0 ≤ H) (hh : 0 < h)
    (hpoly : h ≤ H * (((4 * N ^ 2 : ℕ) : ℝ) ^ N))
    (hbudget : H ≤ c * η * (2 : ℝ) ^ (2 * N ^ 2)) :
    (1 : ℝ) / (2 : ℝ) ^ (4 * N ^ 2) ≤ c * η / h := by
  have hbound :=
    explicit_dyadic_fixed_point N H h c η hN hH hpoly hbudget
  have hp : (0 : ℝ) < (2 : ℝ) ^ (4 * N ^ 2) := by positivity
  apply (div_le_div_iff₀ hp hh).2
  simpa only [one_mul] using hbound

end Nightfall.StrongSimulation.FixedPoint
