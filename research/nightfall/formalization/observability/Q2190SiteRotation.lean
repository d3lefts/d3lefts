import Q2190FourPoint

/-!
# Q2 spherical tangent at an arbitrary finite source law

All weights are the *actual* finite-source weights. There is no
strict-positive-atom assumption. If a singleton norm vanishes, its
rotation is exactly constant, rather than a non-normalized cos² mass.

This file proves local normalized rotations and tangent covariance.
A separate product-level degree-two cancellation theorem must still
identify four rotated expectations with the sum of singleton norms.
-/

namespace Nightfall.Q2190
open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

noncomputable def siteEnergy (p h : α → ℝ) : ℝ :=
  ∑ x : α, p x * (h x)^2

noncomputable def siteNorm (p h : α → ℝ) : ℝ :=
  Real.sqrt (siteEnergy p h)

noncomputable def tangent (p h : α → ℝ) (x : α) : ℝ :=
  if siteNorm p h = 0 then 0 else Real.sqrt (p x) * h x / siteNorm p h

noncomputable def signedTangent (p h : α → ℝ) (x : α) : ℝ :=
  if siteNorm p h = 0 then 0 else p x * h x / siteNorm p h

theorem siteEnergy_nonneg (p h : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) : 0 ≤ siteEnergy p h := by
  unfold siteEnergy
  exact Finset.sum_nonneg (fun x _ => mul_nonneg (hp x) (sq_nonneg _))

theorem siteNorm_nonneg (p h : α → ℝ) : 0 ≤ siteNorm p h :=
  Real.sqrt_nonneg _

theorem siteNorm_sq (p h : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) :
    (siteNorm p h)^2 = siteEnergy p h :=
  Real.sq_sqrt (siteEnergy_nonneg p h hp)

theorem sitePsi_unit (p : α → ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (hp1 : (∑ x : α, p x) = 1) :
    (∑ x : α, (Real.sqrt (p x))^2) = 1 := by
  calc
    (∑ x : α, (Real.sqrt (p x))^2) =
       ∑ x : α, p x := by
         apply Finset.sum_congr rfl
         intro x _
         exact Real.sq_sqrt (hp x)
    _ = 1 := hp1

/-- Normalized Fisher/spherical tangent on each positive-norm site. -/
theorem tangent_unit_when_nonzero
    (p h : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (ha : siteNorm p h ≠ 0) :
    (∑ x : α, (tangent p h x)^2) = 1 := by
  have hnorm : (siteNorm p h)^2 = siteEnergy p h :=
    siteNorm_sq p h hp
  have hnonzero : (siteNorm p h)^2 ≠ 0 := pow_ne_zero _ ha
  calc
    (∑ x : α, (tangent p h x)^2) =
      ∑ x : α, (p x * (h x)^2) / (siteNorm p h)^2 := by
        apply Finset.sum_congr rfl
        intro x _
        simp only [tangent, if_neg ha, div_pow, mul_pow]
        rw [Real.sq_sqrt (hp x)]
    _ = (siteEnergy p h) / (siteNorm p h)^2 := by
      unfold siteEnergy
      rw [Finset.sum_div]
    _ = 1 := by rw [← hnorm]; exact div_self hnonzero

theorem tangent_orthogonal
    (p h : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (hcenter : (∑ x : α, p x*h x) = 0) :
    (∑ x : α, Real.sqrt (p x)*tangent p h x) = 0 := by
  by_cases ha : siteNorm p h = 0
  · simp [tangent, ha]
  · calc
      (∑ x : α, Real.sqrt (p x)*tangent p h x) =
        ∑ x : α, (p x*h x) / siteNorm p h := by
          apply Finset.sum_congr rfl
          intro x _
          simp only [tangent, if_neg ha]
          calc
            Real.sqrt (p x) *
                (Real.sqrt (p x) * h x / siteNorm p h) =
              ((Real.sqrt (p x))^2) * h x / siteNorm p h := by ring
            _ = p x * h x / siteNorm p h := by rw [Real.sq_sqrt (hp x)]
      _ = (∑ x : α, p x*h x) / siteNorm p h := by
        rw [Finset.sum_div]
      _ = 0 := by rw [hcenter]; simp

theorem signedTangent_centered
    (p h : α → ℝ)
    (hcenter : (∑ x : α, p x*h x) = 0) :
    (∑ x : α, signedTangent p h x) = 0 := by
  by_cases ha : siteNorm p h = 0
  · simp [signedTangent, ha]
  · simp_rw [signedTangent, if_neg ha]
    rw [← Finset.sum_div, hcenter]
    simp

/-- The signed tangent is exactly dual to its genuine L² norm. -/
theorem signedTangent_pairs_to_norm
    (p h : α → ℝ)
    (hp : ∀ x, 0 ≤ p x) :
    (∑ x : α, signedTangent p h x * h x) = siteNorm p h := by
  by_cases ha : siteNorm p h = 0
  · simp [signedTangent, ha]
  · have hnorm : (siteNorm p h)^2 = siteEnergy p h :=
      siteNorm_sq p h hp
    calc
      (∑ x : α, signedTangent p h x * h x) =
        ∑ x : α, (p x*(h x)^2) / siteNorm p h := by
          apply Finset.sum_congr rfl
          intro x _
          simp only [signedTangent, if_neg ha]
          ring
      _ = siteEnergy p h / siteNorm p h := by
        unfold siteEnergy
        rw [Finset.sum_div]
      _ = siteNorm p h := by
        rw [← hnorm]
        field_simp

/-- Legitimate normalized rotating probability law.
For vanishing L², leave the original marginal untouched. -/
noncomputable def siteRotation
    (p h : α → ℝ) (u v sign : ℝ) (x : α) : ℝ :=
  if siteNorm p h = 0 then p x else
    (u * Real.sqrt (p x) + sign*v*tangent p h x)^2

theorem siteRotation_nonneg
    (p h : α → ℝ) (u v sign : ℝ)
    (hp : ∀ x, 0 ≤ p x) :
    ∀ x, 0 ≤ siteRotation p h u v sign x := by
  intro x
  unfold siteRotation
  split_ifs with hz
  · exact hp x
  · exact sq_nonneg _

theorem siteRotation_normalized
    (p h : α → ℝ) (u v sign : ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (hp1 : (∑ x : α, p x) = 1)
    (hcenter : (∑ x : α, p x*h x) = 0)
    (huv : u^2 + v^2 = 1)
    (hsign : sign^2 = 1) :
    (∑ x : α, siteRotation p h u v sign x) = 1 := by
  by_cases ha : siteNorm p h = 0
  · simpa [siteRotation, ha] using hp1
  · simp only [siteRotation, if_neg ha]
    exact rotated_mass_normalized
      (fun x => Real.sqrt (p x)) (tangent p h) u v sign
      (sitePsi_unit p hp hp1)
      (tangent_unit_when_nonzero p h hp ha)
      (tangent_orthogonal p h hp hcenter) huv hsign

/-- The site rotation's antisymmetric part has literal tangent density.
This identity is valid even when a_i=0. -/
theorem siteRotation_plus_sub_minus
    (p h : α → ℝ) (u v : ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (x : α) :
    siteRotation p h u v 1 x - siteRotation p h u v (-1) x =
      (4*u*v)*signedTangent p h x := by
  by_cases ha : siteNorm p h = 0
  · simp [siteRotation, signedTangent, ha]
  · simp only [siteRotation, signedTangent, if_neg ha]
    have hh : Real.sqrt (p x)*tangent p h x =
        p x*h x/siteNorm p h := by
      simp only [tangent, if_neg ha]
      calc
        Real.sqrt (p x) *
            (Real.sqrt (p x)*h x/siteNorm p h) =
          ((Real.sqrt (p x))^2)*h x/siteNorm p h := by ring
        _ = p x*h x/siteNorm p h := by
          rw [Real.sq_sqrt (hp x)]
    calc
      (u*Real.sqrt (p x)+1*v*tangent p h x)^2 -
          (u*Real.sqrt (p x)+(-1)*v*tangent p h x)^2 =
        4*u*v*(Real.sqrt (p x)*tangent p h x) := by ring
      _ = 4*u*v*(p x*h x/siteNorm p h) := by rw [hh]

end Nightfall.Q2190
