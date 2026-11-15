import Mathlib

/-!
# A sharp one-increment independent-Hilbert L₁/L₂ bound

The result applies to *every* real normed space, not only a Hilbert space.
For a finite normalized nonnegative source p, a centered increment Y with
norm ≤ c, and arbitrary deterministic h, put F = ‖h + Y‖. Then

  E F² - (E F)² ≤ c E F.

No lower bound on atom probabilities, symmetric-law assumption, fourth-moment
premise, or positivity condition on h. The proof is geometric: triangle
inequality bounds F by ‖h‖ + c, and Jensen bounds ‖h‖ by E F.
The all-length independent-increment inequality needed for C96.57352
is NOT derived by this lemma.
-/

namespace Nightfall.Q2FirstChaos

open Finset

variable {α H : Type*} [Fintype α]
  [NormedAddCommGroup H] [NormedSpace ℝ H]

/-- Original-law one-increment fluctuation bound, including zero atoms.
The input increment is centered and pointwise norm-bounded. -/
theorem centered_one_increment_norm_variance
    (p : α → ℝ) (Y : α → H) (h : H) (c : ℝ)
    (hp : ∀ a, 0 ≤ p a)
    (hp1 : (∑ a : α, p a) = 1)
    (hY : (∑ a : α, p a • Y a) = 0)
    (hc : ∀ a, ‖Y a‖ ≤ c) :
    (∑ a : α, p a * ‖h + Y a‖ ^ 2) -
      (∑ a : α, p a * ‖h + Y a‖) ^ 2 ≤
        c * (∑ a : α, p a * ‖h + Y a‖) := by
  classical
  let u : ℝ := ∑ a : α, p a * ‖h + Y a‖
  let e : ℝ := ∑ a : α, p a * ‖h + Y a‖ ^ 2
  have hsum_h : (∑ a : α, p a • h) = h := by
    rw [← Finset.sum_smul, hp1]
    simp
  have hweighted_center : (∑ a : α, p a • (h + Y a)) = h := by
    calc
      (∑ a : α, p a • (h + Y a)) =
          (∑ a : α, p a • h) + (∑ a : α, p a • Y a) := by
            simp only [smul_add, Finset.sum_add_distrib]
      _ = h := by rw [hsum_h, hY]; simp
  have hweighted_norm :
      (∑ a : α, ‖p a • (h + Y a)‖) = u := by
    dsimp [u]
    apply Finset.sum_congr rfl
    intro a _
    rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hp a)]
  have hcenter : ‖h‖ ≤ u := by
    calc
      ‖h‖ = ‖∑ a : α, p a • (h + Y a)‖ := by rw [hweighted_center]
      _ ≤ ∑ a : α, ‖p a • (h + Y a)‖ := norm_sum_le _ _
      _ = u := hweighted_norm
  have hpoint_bound (a : α) : ‖h + Y a‖ ≤ u + c := by
    calc
      ‖h + Y a‖ ≤ ‖h‖ + ‖Y a‖ := norm_add_le _ _
      _ ≤ ‖h‖ + c := add_le_add_left (hc a) _
      _ ≤ u + c := add_le_add_right hcenter _
  have hpoint (a : α) :
      p a * ‖h + Y a‖ ^ 2 ≤ p a * ((u + c) * ‖h + Y a‖) := by
    have hz : 0 ≤ ‖h + Y a‖ := norm_nonneg _
    have hsq : ‖h + Y a‖ ^ 2 ≤ (u + c) * ‖h + Y a‖ := by
      nlinarith [mul_nonneg hz (sub_nonneg.mpr (hpoint_bound a))]
    exact mul_le_mul_of_nonneg_left hsq (hp a)
  have he : e ≤ (u + c) * u := by
    dsimp [e]
    calc
      (∑ a : α, p a * ‖h + Y a‖ ^ 2) ≤
          ∑ a : α, p a * ((u + c) * ‖h + Y a‖) :=
            Finset.sum_le_sum (fun a _ => hpoint a)
      _ = (u + c) * (∑ a : α, p a * ‖h + Y a‖) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro a _
            ring
      _ = (u + c) * u := rfl
  change e - u ^ 2 ≤ c * u
  nlinarith [he]

end Nightfall.Q2FirstChaos
