import Mathlib

/-!
# SCIF rectangle rigidity: uniqueness of a doubly-centered two-site component

For arbitrary finite alphabets and normalized real weights (zero weights
and even signed weights allowed), a two-site table which is centered
in both margins is uniquely determined by its four-corner differences.

This is the missing algebraic uniqueness mechanism for identifying
recentered canonical pair kernels. It does NOT yet identify the new
full-product esComp itself.
-/

namespace Nightfall.SCIF.RectUnique

open Finset
variable {A B : Type*} [Fintype A] [Fintype B]

/-- Every bi-centered two-site table with vanishing mixed rectangles is zero. -/
theorem zero_of_centered_and_zero_rectangles
    (q : A → ℝ) (r : B → ℝ)
    (hq : (∑ a : A, q a) = 1)
    (hr : (∑ b : B, r b) = 1)
    (g : A → B → ℝ)
    (hrow : ∀ b, (∑ a : A, q a * g a b) = 0)
    (hcol : ∀ a, (∑ b : B, r b * g a b) = 0)
    (hrect : ∀ a c b d,
      g a b - g c b - g a d + g c d = 0)
    (a : A) (b : B) : g a b = 0 := by
  have hlin (c : A) (d : B) :
      g a b = g c b + g a d - g c d := by
    have h := hrect a c b d
    linarith
  calc
    g a b = ∑ c : A, q c * (∑ d : B, r d * g a b) := by
      rw [← Finset.sum_mul, hr, one_mul, ← Finset.sum_mul, hq, one_mul]
    _ = ∑ c : A, q c * (∑ d : B, r d *
            (g c b + g a d - g c d)) := by
      apply Finset.sum_congr rfl
      intro c _
      congr 1
      apply Finset.sum_congr rfl
      intro d _
      rw [hlin c d]
    _ = ∑ c : A, q c * g c b := by
      apply Finset.sum_congr rfl
      intro c _
      congr 1
      calc
        ∑ d : B, r d * (g c b + g a d - g c d) =
            (∑ d : B, r d * g c b) +
            (∑ d : B, r d * g a d) -
            (∑ d : B, r d * g c d) := by
          simp_rw [mul_add, mul_sub]
          rw [Finset.sum_sub_distrib, Finset.sum_add_distrib]
        _ = g c b := by
          rw [← Finset.sum_mul, hr, one_mul, hcol a, hcol c]
          ring
    _ = 0 := hrow b

/-- Doubly-centered kernels with the same source rectangles coincide
pointwise, even when q/r have zero-mass atoms. -/
theorem same_rectangles_imply_equal
    (q : A → ℝ) (r : B → ℝ)
    (hq : (∑ a : A, q a) = 1)
    (hr : (∑ b : B, r b) = 1)
    (u v : A → B → ℝ)
    (hurow : ∀ b, (∑ a : A, q a * u a b) = 0)
    (hvrow : ∀ b, (∑ a : A, q a * v a b) = 0)
    (hucol : ∀ a, (∑ b : B, r b * u a b) = 0)
    (hvcol : ∀ a, (∑ b : B, r b * v a b) = 0)
    (hrect : ∀ a c b d,
      u a b-u c b-u a d+u c d =
      v a b-v c b-v a d+v c d)
    (a : A) (b : B) : u a b = v a b := by
  have hz := zero_of_centered_and_zero_rectangles q r hq hr
    (fun a b => u a b - v a b)
    (by
      intro b
      simp_rw [mul_sub, Finset.sum_sub_distrib, hurow b, hvrow b, sub_self])
    (by
      intro a
      simp_rw [mul_sub, Finset.sum_sub_distrib, hucol a, hvcol a, sub_self])
    (by
      intro a c b d
      have h := hrect a c b d
      dsimp
      linarith) a b
  linarith

end Nightfall.SCIF.RectUnique
