import Mathlib

/-!
NIGHTFALL low-interaction switching operator.
This checks the exact quadratic endpoint Bernstein--Markov input used
in the all-alphabet degree-two oscillation budget and in the
activation/matching proofs. This is a classical ingredient, not an
original result and not the full product-space switching theorem.
-/

namespace Nightfall.Observability.Switching

/-- Three exactly sampled values bound the initial derivative
of a quadratic: b=-3q(0)+4q(1/2)-q(1).
The statement is uniform over all real coefficients. -/
theorem quadratic_three_point_endpoint
    (a b c B : ℝ)
    (h0 : |c| ≤ B)
    (hh : |a / 4 + b / 2 + c| ≤ B)
    (h1 : |a + b + c| ≤ B) :
    |b| ≤ 8 * B := by
  obtain ⟨hcL, hcU⟩ := abs_le.mp h0
  obtain ⟨hhL, hhU⟩ := abs_le.mp hh
  obtain ⟨h1L, h1U⟩ := abs_le.mp h1
  have hb : b = -3 * c + 4 * (a / 4 + b / 2 + c) -
      (a + b + c) := by ring
  rw [hb]
  apply abs_le.mpr
  constructor <;> linarith

/-- For a real polynomial q(t)=a t²+b t+c bounded by B on [0,1],
the endpoint derivative q'(0)=b has absolute value ≤8B.
This validates the 8B switching derivative budget for d=2. -/
theorem quadratic_endpoint_markov
    (a b c B : ℝ)
    (hB : ∀ t : ℝ, 0 ≤ t → t ≤ 1 →
      |a * t^2 + b*t + c| ≤ B) :
    |b| ≤ 8 * B := by
  have h0 : |c| ≤ B := by
    simpa using (hB 0 (by norm_num) (by norm_num))
  have hh : |a / 4 + b / 2 + c| ≤ B := by
    have h := hB (1/2 : ℝ) (by norm_num) (by norm_num)
    convert h using 1 <;> ring
  have h1 : |a + b + c| ≤ B := by
    have h := hB 1 (by norm_num) (by norm_num)
    convert h using 1 <;> ring
  exact quadratic_three_point_endpoint a b c B h0 hh h1

end Nightfall.Observability.Switching
