import Mathlib

/-!
# Exact centered-pair -> four-point rectangular-difference bridge

For two arbitrary finite coordinate alphabets and arbitrary normalized
weights (zero-mass atoms permitted), if a pair kernel is centered in
each input, then each value equals the average of its four-corner
mixed differences.  This bridges true Hoeffding components to the
weighted matching parity construction; it does not assume a fair law.

No matching estimate, influence bound, or full quadratic theorem is
asserted by this file.  The underlying identity is elementary.
-/

namespace Nightfall.Observability.CenteredRectangle
open Finset

variable {α β : Type*} [Fintype α] [Fintype β]

def delta (h : α → β → ℝ) (a s : α) (b t : β) : ℝ :=
  h a b - h s b - h a t + h s t

/-- Pairwise canonical degeneracy directly implies the exact
weighted rectangular-difference identity, without a minimum atom
condition or a uniform reference measure. -/
theorem centered_pair_rectangle_average
    (p : α → ℝ) (q : β → ℝ)
    (hp : (∑ s : α, p s) = 1)
    (hq : (∑ t : β, q t) = 1)
    (h : α → β → ℝ)
    (hleft : ∀ t : β, (∑ s : α, p s * h s t) = 0)
    (hright : ∀ s : α, (∑ t : β, q t * h s t) = 0)
    (a : α) (b : β) :
    (∑ s : α, ∑ t : β, p s * q t * delta h a s b t) = h a b := by
  classical
  have hin (s : α) :
      (∑ t : β, q t * delta h a s b t) = h a b - h s b := by
    calc
      (∑ t : β, q t * delta h a s b t)
          = ∑ t : β, (q t * (h a b - h s b) -
            q t * h a t + q t * h s t) := by
              apply Finset.sum_congr rfl
              intro t _
              dsimp [delta]
              ring
      _ = (∑ t : β, q t) * (h a b - h s b) -
          (∑ t : β, q t * h a t) +
          (∑ t : β, q t * h s t) := by
            rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_mul]
      _ = h a b - h s b := by rw [hq, hright a, hright s]; ring
  calc
    (∑ s : α, ∑ t : β, p s * q t * delta h a s b t)
        = ∑ s : α, p s * (h a b - h s b) := by
            apply Finset.sum_congr rfl
            intro s _
            rw [← Finset.mul_sum]
            congr 1
            exact hin s
    _ = ∑ s : α, (p s * h a b - p s * h s b) := by
          apply Finset.sum_congr rfl
          intro s _
          ring
    _ = (∑ s : α, p s) * h a b -
          (∑ s : α, p s * h s b) := by
            rw [Finset.sum_sub_distrib, Finset.sum_mul]
    _ = h a b := by rw [hp, hleft b]; ring

end Nightfall.Observability.CenteredRectangle
