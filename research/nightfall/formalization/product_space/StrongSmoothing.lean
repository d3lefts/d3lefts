import Mathlib

/-!
# The binomial-tail event smoother: exact interval bounds

For k,r : ℕ, the function `tail k r z` is the finite sum

  Σ_(j=r+1)^k choose(k,j) (z²)^j (1-z²)^(k-j).

This file proves *unconditionally* that the function takes values in
[0,1] on [-1,1]. It uses the binomial theorem, not an estimate of the
tails. The ε/η Hoeffding bounds and the coordinate-degree bound are
separate obligations for the strong simulation proof.
-/

namespace Nightfall.StrongSimulation.Smoothing

/-- A finite binomial tail, which is a polynomial expression in z. -/
def tail (k r : ℕ) (z : ℝ) : ℝ :=
  ∑ j ∈ Finset.Ico (r + 1) (k + 1),
    (z ^ 2) ^ j * (1 - z ^ 2) ^ (k - j) * (k.choose j : ℝ)

/-- Every summand is nonnegative when |z|≤1. -/
private theorem term_nonneg (k j : ℕ) (z : ℝ) (hz : |z| ≤ 1) :
    0 ≤ (z ^ 2) ^ j * (1 - z ^ 2) ^ (k - j) * (k.choose j : ℝ) := by
  have hz' : -1 ≤ z ∧ z ≤ 1 := abs_le.mp hz
  have hl : 0 ≤ 1 - z := by linarith [hz'.2]
  have hr : 0 ≤ 1 + z := by linarith [hz'.1]
  have hq : 0 ≤ 1 - z ^ 2 := by
    nlinarith [mul_nonneg hl hr]
  positivity

theorem tail_nonneg (k r : ℕ) (z : ℝ) (hz : |z| ≤ 1) :
    0 ≤ tail k r z := by
  unfold tail
  exact Finset.sum_nonneg (fun j hj => term_nonneg k j z hz)

/-- The full binomial mass is exactly one: (z²+(1-z²))^k=1. -/
theorem total_mass_eq_one (k : ℕ) (z : ℝ) :
    (∑ j ∈ Finset.range (k + 1),
      (z ^ 2) ^ j * (1 - z ^ 2) ^ (k - j) * (k.choose j : ℝ)) = 1 := by
  have h := add_pow (z ^ 2) (1 - z ^ 2) k
  have hsum : z ^ 2 + (1 - z ^ 2) = (1 : ℝ) := by ring
  rw [hsum, one_pow] at h
  exact h.symm

/-- A binomial tail is bounded by the full nonnegative binomial sum. -/
theorem tail_le_one (k r : ℕ) (z : ℝ) (hz : |z| ≤ 1) :
    tail k r z ≤ 1 := by
  unfold tail
  calc
    (∑ j ∈ Finset.Ico (r + 1) (k + 1),
      (z ^ 2) ^ j * (1 - z ^ 2) ^ (k - j) * (k.choose j : ℝ))
      ≤ (∑ j ∈ Finset.range (k + 1),
        (z ^ 2) ^ j * (1 - z ^ 2) ^ (k - j) * (k.choose j : ℝ)) := by
          apply Finset.sum_le_sum_of_subset_of_nonneg
          · intro j hj
            exact Finset.mem_range.mpr (Finset.mem_Ico.mp hj).2
          · intro j hj hnot
            exact term_nonneg k j z hz
    _ = 1 := total_mass_eq_one k z

theorem tail_mem_unit_interval (k r : ℕ) (z : ℝ) (hz : |z| ≤ 1) :
    0 ≤ tail k r z ∧ tail k r z ≤ 1 :=
  ⟨tail_nonneg k r z hz, tail_le_one k r z hz⟩

end Nightfall.StrongSimulation.Smoothing
