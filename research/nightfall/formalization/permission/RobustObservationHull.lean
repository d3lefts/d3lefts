import Mathlib

/-!
# Exact rational convex-hull supporting certificates for robust observation

For a finite source law q, a fixed target-law p and original-source
conditional response table d(a,z), the useful pre-observation gain is

    gain(q) = Σ_z p(z) (Σ_a q(a) d(a,z))².

A source-derived support vector h with squared norm λ and
  Σ_z p(z) h(z) d(a,z) >= λ for EVERY source atom a
certifies gain(q) >= λ for EVERY q in the simplex.  A matching
convex combination q* with h=Σ_a q*(a)d(a,z) certifies exact optimality.

This is elementary convex projection / Gram duality, not a new
mathematical optimization primitive.  It does not formalize a JSON
parser, source authenticity, zero-error mission admission, or real
effect-time enforcement.
-/

namespace Nightfall.RobustObservationHull

open Finset

private theorem weighted_square_identity
    {m : ℕ} (p g h : Fin m → ℚ) :
    (∑ z : Fin m, p z * (g z) ^ 2) =
      (∑ z : Fin m, p z * (g z - h z) ^ 2) +
      2 * (∑ z : Fin m, p z * h z * g z) -
      (∑ z : Fin m, p z * (h z) ^ 2) := by
  calc
    (∑ z : Fin m, p z * (g z) ^ 2) =
        ∑ z : Fin m, (p z * (g z - h z) ^ 2 +
          2 * (p z * h z * g z) -
          p z * (h z) ^ 2) := by
      apply Finset.sum_congr rfl
      intro z _
      ring
    _ = (∑ z : Fin m, p z * (g z - h z) ^ 2) +
        2 * (∑ z : Fin m, p z * h z * g z) -
        (∑ z : Fin m, p z * (h z) ^ 2) := by
      rw [Finset.sum_sub_distrib, Finset.sum_add_distrib,
        ← Finset.mul_sum]

/-- A checkable exact rational dual lower bound for the distance from
the origin to the convex hull of a finite family of response vectors.
There is no assumed optimizer, Gram-matrix oracle or numerical tolerance. -/
theorem rational_hull_supporting_certificate
    {m n : ℕ}
    (p : Fin m → ℚ) (d : Fin n → Fin m → ℚ)
    (h : Fin m → ℚ) (λ : ℚ)
    (hp : ∀ z, 0 ≤ p z)
    (hnorm : (∑ z : Fin m, p z * (h z) ^ 2) = λ)
    (hsupport : ∀ a, λ ≤ ∑ z : Fin m, p z * h z * d a z) :
    ∀ (q : Fin n → ℚ),
      (∀ a, 0 ≤ q a) →
      (∑ a : Fin n, q a) = 1 →
      λ ≤ ∑ z : Fin m, p z * (∑ a : Fin n, q a * d a z) ^ 2
      := by
  intro q hq hqsum
  let g : Fin m → ℚ := fun z => ∑ a : Fin n, q a * d a z
  have hcross : λ ≤ ∑ z : Fin m, p z * h z * g z := by
    calc
      λ = (∑ a : Fin n, q a) * λ := by rw [hqsum]; ring
      _ = ∑ a : Fin n, q a * λ := by rw [Finset.sum_mul]
      _ ≤ ∑ a : Fin n, q a *
            (∑ z : Fin m, p z * h z * d a z) := by
          apply Finset.sum_le_sum
          intro a _
          exact mul_le_mul_of_nonneg_left (hsupport a) (hq a)
      _ = ∑ z : Fin m, p z * h z * g z := by
          calc
            (∑ a : Fin n, q a *
                (∑ z : Fin m, p z * h z * d a z)) =
                ∑ a : Fin n, ∑ z : Fin m,
                  q a * (p z * h z * d a z) := by
              apply Finset.sum_congr rfl
              intro a _
              rw [Finset.mul_sum]
            _ = ∑ z : Fin m, ∑ a : Fin n,
                  q a * (p z * h z * d a z) := by
              rw [Finset.sum_comm]
            _ = ∑ z : Fin m, p z * h z * g z := by
              apply Finset.sum_congr rfl
              intro z _
              dsimp [g]
              rw [Finset.mul_sum]
              apply Finset.sum_congr rfl
              intro a _
              ring
  have hsq : 0 ≤ ∑ z : Fin m, p z * (g z - h z) ^ 2 := by
    apply Finset.sum_nonneg
    intro z _
    exact mul_nonneg (hp z) (sq_nonneg _)
  have hid := weighted_square_identity p g h
  have heq : (∑ z : Fin m, p z * (g z) ^ 2) =
      (∑ z : Fin m, p z * (g z - h z) ^ 2) +
      2 * (∑ z : Fin m, p z * h z * g z) - λ := by
    rw [hid, hnorm]
  change λ ≤ ∑ z : Fin m, p z * (g z) ^ 2
  rw [heq]
  linarith

/-- Matching source-law witness and support hyperplane together certify the
exact minimum, not merely a lower bound. -/
theorem rational_hull_matching_optimal
    {m n : ℕ}
    (p : Fin m → ℚ) (d : Fin n → Fin m → ℚ)
    (h : Fin m → ℚ) (λ : ℚ)
    (hp : ∀ z, 0 ≤ p z)
    (hnorm : (∑ z : Fin m, p z * (h z) ^ 2) = λ)
    (hsupport : ∀ a, λ ≤ ∑ z : Fin m, p z * h z * d a z)
    (qstar : Fin n → ℚ)
    (hqlaw : (∀ a, 0 ≤ qstar a) ∧ (∑ a : Fin n, qstar a) = 1)
    (hresponse : ∀ z, h z = ∑ a : Fin n, qstar a * d a z) :
    (∀ (q : Fin n → ℚ), (∀ a, 0 ≤ q a) →
        (∑ a : Fin n, q a) = 1 →
        λ ≤ ∑ z : Fin m, p z * (∑ a : Fin n, q a * d a z) ^ 2) ∧
      (∑ z : Fin m, p z *
        (∑ a : Fin n, qstar a * d a z) ^ 2) = λ := by
  constructor
  · intro q hq hqsum
    exact rational_hull_supporting_certificate p d h λ hp hnorm
      hsupport q hq hqsum
  · simpa only [← hresponse] using hnorm

end Nightfall.RobustObservationHull
