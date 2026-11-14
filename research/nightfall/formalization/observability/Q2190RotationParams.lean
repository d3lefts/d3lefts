import Q2190SiteRotation

/-!
# The four exact normalized spherical source laws, in affine coordinates

A=(1+1/sqrt(2))/2, D=(1-1/sqrt(2))/2.
The root parameter pair (sqrt A,sqrt D) has 2ab=1/sqrt(2);
the swapped pair has the same cross coefficient.
This establishes literal source weights p+theta*delta±r*eta,
including the a_i=0 branch and old zero-probability symbols.
-/

namespace Nightfall.Q2190
open Finset

noncomputable def rootA : ℝ := Real.sqrt A
noncomputable def rootD : ℝ := Real.sqrt D

theorem rootA_nonneg : 0 ≤ rootA := Real.sqrt_nonneg _
theorem rootD_nonneg : 0 ≤ rootD := Real.sqrt_nonneg _
theorem rootA_sq : rootA^2 = A := Real.sq_sqrt A_nonneg
theorem rootD_sq : rootD^2 = D := Real.sq_sqrt D_nonneg

theorem root_unit : rootA^2+rootD^2=1 := by
  rw [rootA_sq, rootD_sq, A_add_D]

theorem root_cross : 2*rootA*rootD = r := by
  have hsq : (2*rootA*rootD)^2 = r^2 := by
    calc
      (2*rootA*rootD)^2 = 4*(rootA^2)*(rootD^2) := by ring
      _ = 4*A*D := by rw [rootA_sq, rootD_sq]
      _ = r^2 := by
        unfold A D
        nlinarith [r_sq]
  have hnonneg : 0 ≤ 2*rootA*rootD := by
    positivity
  nlinarith [hsq, r_nonneg]

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The even perturbation of the source law; zero if singleton norm
vanishes, which makes the zero branch exactly source-stationary. -/
noncomputable def siteDelta (p h : α → ℝ) (x : α) : ℝ :=
  if siteNorm p h = 0 then 0 else (tangent p h x)^2-p x

theorem siteRotation_affine
    (p h : α → ℝ) (u v sign : ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (hunit : u^2+v^2=1)
    (hcross : 2*u*v=r)
    (hsign : sign^2=1) (x : α) :
    siteRotation p h u v sign x =
      p x + v^2*siteDelta p h x +
        sign*r*signedTangent p h x := by
  by_cases ha : siteNorm p h = 0
  · simp [siteRotation, siteDelta, signedTangent, ha]
  · have hroot : (Real.sqrt (p x))^2=p x :=
      Real.sq_sqrt (hp x)
    have heta : Real.sqrt (p x)*tangent p h x =
        signedTangent p h x := by
      simp only [tangent, signedTangent, if_neg ha]
      calc
        Real.sqrt (p x)*
            (Real.sqrt (p x)*h x/siteNorm p h) =
          (Real.sqrt (p x))^2*h x/siteNorm p h := by ring
        _ = p x*h x/siteNorm p h := by rw [hroot]
    simp only [siteRotation, siteDelta, signedTangent, if_neg ha]
    have hsq :
        (u*Real.sqrt (p x)+sign*v*tangent p h x)^2 =
        (u^2)*(Real.sqrt (p x))^2+
          (sign^2)*(v^2)*(tangent p h x)^2+
          sign*(2*u*v)*(Real.sqrt (p x)*tangent p h x) := by ring
    rw [hsq, hsign, hroot, hcross]
    have hunit' : u^2=1-v^2 := by linarith
    rw [hunit']
    rw [heta]
    ring

theorem rotatedA_affine
    (p h : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (sign : ℝ) (hsign : sign^2=1) (x : α) :
    siteRotation p h rootA rootD sign x =
      p x + D*siteDelta p h x + sign*r*signedTangent p h x := by
  simpa only [rootD_sq] using
    siteRotation_affine p h rootA rootD sign hp root_unit root_cross hsign x

theorem rotatedB_affine
    (p h : α → ℝ) (hp : ∀ x, 0 ≤ p x)
    (sign : ℝ) (hsign : sign^2=1) (x : α) :
    siteRotation p h rootD rootA sign x =
      p x + A*siteDelta p h x + sign*r*signedTangent p h x := by
  have hunit : rootD^2+rootA^2=1 := by nlinarith [root_unit]
  have hcross : 2*rootD*rootA = r := by nlinarith [root_cross]
  simpa only [rootA_sq] using
    siteRotation_affine p h rootD rootA sign hp hunit hcross hsign x

theorem siteDelta_centered
    (p h : α → ℝ)
    (hp : ∀ x, 0 ≤ p x)
    (hp1 : (∑ x : α, p x)=1) :
    (∑ x : α, siteDelta p h x)=0 := by
  by_cases ha : siteNorm p h=0
  · simp [siteDelta,ha]
  · simp_rw [siteDelta, if_neg ha, Finset.sum_sub_distrib]
    rw [tangent_unit_when_nonzero p h hp ha, hp1]
    ring

end Nightfall.Q2190
