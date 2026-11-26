import T2BornWalsh
import T2CertifiedTailBridge
import PaperVGroupedEnergy

/-! Source-exact physical light energy composition, Paper V §4.1.
The sector space and original oracle are inherited, not replaced.
The primitive component is quantified over actual path tuples.
Repeated-slot and survivor contractions remain separate. -/
namespace Nightfall.PaperVPhysicalEnergy
open Finset
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2ActualSource
open Nightfall.StructuralInformation.T2BornExpansion
open Nightfall.PaperVGroupedEnergy
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

abbrev T (D : Type*) := (D × D) × (D × D)
noncomputable def c (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) (t : T D) : ℝ :=
  (originalFourCoefficient psi U P t.1 t.2).re

theorem real_sq_le_norm_sq (z : ℂ) : z.re^2 ≤ ‖z‖^2 := by
  have h := Complex.abs_re_le_norm z
  have h' := (sq_le_sq₀ (abs_nonneg z.re) (norm_nonneg z)).mpr h
  simpa only [sq_abs] using h'

theorem physical_left_input_light
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) (P : H D E →L[ℂ] H D E)
    (hpsi : ‖psi‖^2 ≤ 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hL : ∀ a ∈ L, ‖psi a‖^2 ≤ eta) :
    ∑ t ∈ ((univ : Finset D).product L).product
      (univ : Finset (D × D)), (c psi U P t)^2 ≤ eta := by
  calc
    _ = ∑ ba ∈ (univ : Finset D).product L, ∑ cd : D × D,
        (c psi U P (ba,cd))^2 :=
      Finset.sum_product ((univ : Finset D).product L) (univ : Finset (D × D))
        (fun t => (c psi U P t)^2)
    _ ≤ eta := by
      refine le_trans ?_ (actual_first_light_four_slot_energy psi U hpsi L eta heta hL P hP0 hP1)
      apply Finset.sum_le_sum
      intro ba _
      apply Finset.sum_le_sum
      intro cd _
      exact real_sq_le_norm_sq (originalFourCoefficient psi U P ba cd)

theorem physical_left_output_light
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) (P : H D E →L[ℂ] H D E)
    (hpsi : ‖psi‖^2 ≤ 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hL : ∀ b ∈ L, (∑ a : D, ‖sourcePath psi U b a‖^2) ≤ eta) :
    ∑ t ∈ (L.product (univ : Finset D)).product
      (univ : Finset (D × D)), (c psi U P t)^2 ≤ eta := by
  calc
    _ = ∑ ba ∈ L.product (univ : Finset D), ∑ cd : D × D,
        (c psi U P (ba,cd))^2 :=
      Finset.sum_product (L.product (univ : Finset D)) (univ : Finset (D × D))
        (fun t => (c psi U P t)^2)
    _ ≤ eta := by
      refine le_trans ?_ (actual_second_light_four_slot_energy psi U hpsi L eta heta hL P hP0 hP1)
      apply Finset.sum_le_sum
      intro ba _
      apply Finset.sum_le_sum
      intro cd _
      exact real_sq_le_norm_sq (originalFourCoefficient psi U P ba cd)

theorem coeff_swap (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) (hP0 : 0 ≤ P) (ba cd : D × D) :
    c psi U P (ba,cd) = c psi U P (cd,ba) := by
  have h := (ContinuousLinearMap.nonneg_iff_isPositive.mp hP0).isSymmetric
  unfold c originalFourCoefficient
  have he := h (actualPath psi U ba) (actualPath psi U cd)
  change inner ℂ (P (actualPath psi U ba)) (actualPath psi U cd) =
    inner ℂ (actualPath psi U ba) (P (actualPath psi U cd)) at he
  rw [← he, ← inner_conj_symm]
  rfl

theorem swap_energy (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) (hP0 : 0 ≤ P) (A B : Finset (D × D)) :
    (∑ t ∈ A.product B, (c psi U P t)^2) =
      ∑ t ∈ B.product A, (c psi U P t)^2 := by
  calc
    _ = ∑ ba ∈ A, ∑ cd ∈ B, (c psi U P (ba,cd))^2 :=
      Finset.sum_product A B (fun t => (c psi U P t)^2)
    _ = ∑ cd ∈ B, ∑ ba ∈ A, (c psi U P (ba,cd))^2 := Finset.sum_comm
    _ = ∑ cd ∈ B, ∑ ba ∈ A, (c psi U P (cd,ba))^2 := by
      apply Finset.sum_congr rfl
      intro cd _
      apply Finset.sum_congr rfl
      intro ba _
      rw [coeff_swap psi U P hP0 ba cd]
    _ = _ := (Finset.sum_product B A (fun t => (c psi U P t)^2)).symm

/-- For actual physical coefficients, any one-light subfamily with
bounded frequency fibers has the Paper V primitive 4*K*eta energy.
Both light slot energies on the conjugate path are derived, not assumed. -/
theorem physical_primitive_grouped
    {G : Type*} [DecidableEq G] (freq : T D → G)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) (P : H D E →L[ℂ] H D E)
    (hpsi : ‖psi‖^2 ≤ 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hp : ∀ a ∈ L, ‖psi a‖^2 ≤ eta)
    (hq : ∀ b ∈ L, (∑ a : D, ‖sourcePath psi U b a‖^2) ≤ eta)
    (S : Finset (T D)) (Z : Finset G) (K : ℝ) (hK : 0 ≤ K)
    (hcover : ∀ t ∈ S, t.1.1 ∈ L ∨ t.1.2 ∈ L ∨ t.2.1 ∈ L ∨ t.2.2 ∈ L)
    (hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t=z)).card : ℝ) ≤ K) :
    (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t=z), c psi U P t)^2) ≤ 4*K*eta := by
  classical
  let A := (L.product (univ : Finset D)).product (univ : Finset (D × D))
  let B := ((univ : Finset D).product L).product (univ : Finset (D × D))
  let C := (univ : Finset (D × D)).product (L.product (univ : Finset D))
  let F := (univ : Finset (D × D)).product ((univ : Finset D).product L)
  have ha : ∑ t ∈ A, (c psi U P t)^2 ≤ eta :=
    physical_left_output_light psi U P hpsi hP0 hP1 L eta heta hq
  have hb : ∑ t ∈ B, (c psi U P t)^2 ≤ eta :=
    physical_left_input_light psi U P hpsi hP0 hP1 L eta heta hp
  have hc : ∑ t ∈ C, (c psi U P t)^2 ≤ eta := by
    rw [show C = (univ : Finset (D × D)).product (L.product univ) from rfl,
      swap_energy psi U P hP0]
    exact ha
  have hf : ∑ t ∈ F, (c psi U P t)^2 ≤ eta := by
    rw [show F = (univ : Finset (D × D)).product (univ.product L) from rfl,
      swap_energy psi U P hP0]
    exact hb
  have hcov : ∀ t ∈ S, t ∈ A ∨ t ∈ B ∨ t ∈ C ∨ t ∈ F := by
    intro t ht
    simpa [A,B,C,F] using hcover t ht
  exact primitive_grouped_energy S A B C F Z freq (c psi U P) K eta hK ha hb hc hf hcov hcard

#print axioms physical_left_input_light
#print axioms physical_left_output_light
#print axioms coeff_swap
#print axioms swap_energy
#print axioms physical_primitive_grouped
end Nightfall.PaperVPhysicalEnergy
