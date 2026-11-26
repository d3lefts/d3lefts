import PaperVPhysicalEnergy

/-! Paper V: compose actual complex physical path coefficients with the double-slot charge, rather than assume the four light-energy bounds. The correction-set membership and fiber bound are explicit premises; full Theorem 4.1 is not yet claimed. -/
namespace Nightfall.PaperVPhysicalEnergy
open Finset
open Nightfall.StructuralInformation.T2SecondStageLight
open Nightfall.StructuralInformation.T2ActualSource
open Nightfall.StructuralInformation.T2BornExpansion
open Nightfall.PaperVGroupedEnergy
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
theorem physical_double_light_grouped
    {G : Type*} [DecidableEq G] (freq : T D → G)
    (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E) (P : H D E →L[ℂ] H D E)
    (hpsi : ‖psi‖^2 ≤ 1) (hP0 : 0 ≤ P) (hP1 : P ≤ 1)
    (L : Finset D) (eta : ℝ) (heta : 0 ≤ eta)
    (hp : ∀ a ∈ L, ‖psi a‖^2 ≤ eta)
    (hq : ∀ b ∈ L, (∑ a : D, ‖sourcePath psi U b a‖^2) ≤ eta)
    (S : Finset (T D)) (Z : Finset G) (M : ℝ) (hM : 0 ≤ M)
    (hcover : ∀ t ∈ S, 2 ≤ (if t.1.1 ∈ L then (1 : ℝ) else 0) +
      (if t.1.2 ∈ L then 1 else 0) + (if t.2.1 ∈ L then 1 else 0) +
      (if t.2.2 ∈ L then 1 else 0))
    (hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t=z)).card : ℝ) ≤ 6*M) :
    (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t=z), c psi U P t)^2) ≤ 12*M*eta := by
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
  have hcov : ∀ t ∈ S, 2 ≤ (if t ∈ A then (1 : ℝ) else 0) +
      (if t ∈ B then 1 else 0) + (if t ∈ C then 1 else 0) + (if t ∈ F then 1 else 0) := by
    intro t ht
    simpa [A,B,C,F] using hcover t ht
  exact correction_grouped_energy S A B C F Z freq (c psi U P) M eta hM ha hb hc hf hcov hcard


#print axioms physical_double_light_grouped
end Nightfall.PaperVPhysicalEnergy
