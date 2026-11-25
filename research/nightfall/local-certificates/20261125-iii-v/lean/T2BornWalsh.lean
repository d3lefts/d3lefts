import T2BornExpansion
import T2UniformEstimator

/-! Exact physical Born expansion in the real uniform-dual Fourier model.
This is the source connection for the analytic coefficient estimates. -/
namespace Nightfall.StructuralInformation.T2BornWalsh
open Finset
open Nightfall.StructuralInformation.T2BornExpansion
open Nightfall.StructuralInformation.T2UniformParseval
open Nightfall.StructuralInformation.T2UniformEstimator
open Nightfall.StructuralInformation.T2SecondStageLight
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

/-- The exact real grouped coefficient, indexed by actual sector paths. -/
noncomputable def coefficient (label : D → G)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) (z : G) : ℝ :=
  ∑ ba : D × D, ∑ cd : D × D,
    if pathFrequency label ba + pathFrequency label cd = z then
      (originalFourCoefficient psi U P ba cd).re else 0

theorem char_real_product (h₂ : ∀ z : G, z+z=0)
    (s : AddChar G ℂ) (x y : G) (c : ℂ) :
    (((starRingEnd ℂ) (s x) * s y) * c).re = c.re * sign s (x+y) := by
  rw [← sign_mul h₂]
  unfold sign
  rcases char_sign h₂ s x with hx|hx <;>
    rcases char_sign h₂ s y with hy|hy <;>
    rw [hx,hy] <;> simp

theorem actual_born_eq_real_fourier (h₂ : ∀ z : G, z+z=0)
    (label : D → G) (s : AddChar G ℂ)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) :
    (bornAmplitude label s psi U P).re =
      polynomial univ (coefficient label psi U P) s := by
  classical
  rw [bornAmplitude_eq_complex_four_slot_sum]
  simp_rw [Complex.re_sum, char_real_product h₂]
  unfold polynomial coefficient
  simp_rw [Finset.sum_mul]
  symm
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro ba _
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro cd _
  rw [Finset.sum_eq_single (pathFrequency label ba + pathFrequency label cd)]
  · simp
  · intro z _ hz
    simp [Ne.symm hz]
  · simp

#print axioms actual_born_eq_real_fourier
end Nightfall.StructuralInformation.T2BornWalsh
