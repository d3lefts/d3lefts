import T2BornWalsh

/-! The exact physical-to-legal-transcript terminal, conditional only on the
quantitative outside-span energy estimate and acceptance range. -/
namespace Nightfall.StructuralInformation.T2BornWalsh
open Finset
open Nightfall.StructuralInformation.T2BornExpansion
open Nightfall.StructuralInformation.T2UniformParseval
open Nightfall.StructuralInformation.T2UniformEstimator
open Nightfall.StructuralInformation.T2WalshTranscript
open Nightfall.StructuralInformation.T2SecondStageLight
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]
variable {D : Type*} [Fintype D] [DecidableEq D]
variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]

theorem physical_uniform_success_of_tail (h₂ : ∀ z : G, z+z=0)
    (label : D → G) (psi : H D E) (U : H D E ≃ₗᵢ[ℂ] H D E)
    (P : H D E →L[ℂ] H D E) (Q : Finset G)
    (hf : ∀ s : AddChar G ℂ, 0 ≤ (bornAmplitude label s psi U P).re ∧
      (bornAmplitude label s psi U P).re ≤ 1)
    (eps delta : ℝ) (heps : 0 < eps)
    (htail : (∑ z ∈ outside Q, (coefficient label psi U P z)^2) ≤ eps^2*delta) :
    ∃ g : (↑Q → ℂ) → ℝ, (∀ a, 0 ≤ g a ∧ g a ≤ 1) ∧
      ((univ.filter (fun s : AddChar G ℂ =>
        eps < |(bornAmplitude label s psi U P).re - g (originalTranscript Q s)|)).card : ℝ) ≤
          (Fintype.card (AddChar G ℂ) : ℝ)*delta := by
  classical
  simp_rw [actual_born_eq_real_fourier h₂] at hf ⊢
  exact legal_query_uniform_success h₂ Q (coefficient label psi U P) hf eps delta heps htail

#print axioms physical_uniform_success_of_tail
end Nightfall.StructuralInformation.T2BornWalsh
