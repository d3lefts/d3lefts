import PaperVIGeneralLatentTerminal

/-! Paper VI Corollary 7.4. Actual original-coordinate tree obtained
from the certified staged general and quadratic source terminals on a
dominating reference distribution, with actual squared loss under ν. -/
namespace Nightfall.PaperVI
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerQuadraticProgress
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]

theorem dominated_mse (ν ρ : (ι → α) → ℝ) (M : ℝ)
    (hdom : ∀ x, ν x ≤ M*ρ x)
    (f g : (ι → α) → ℝ) :
    (∑ x, ν x*(f x-g x)^2) ≤ M*(∑ x, ρ x*(f x-g x)^2) := by
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro x _
  have h := mul_le_mul_of_nonneg_right (hdom x) (sq_nonneg (f x-g x))
  simpa only [mul_assoc] using h

theorem reference_general_mse
    (ν ρ : (ι → α) → ℝ) (hρ0 : ∀ x, 0 ≤ ρ x) (hρ1 : ∑ x, ρ x = 1)
    (M : ℝ) (hM : 1 ≤ M) (hdom : ∀ x, ν x ≤ M*ρ x)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (τ : ℝ) (hτ : 0 < τ) (n : ℕ) (hn : 0 < n)
    (hbudget : meanWeight d ((τ/M)/2)*rowK d +
      infoWeight d ((τ/M)/2)*(wynerGen ρ+(τ/M)*Real.sqrt (τ/M))
        ≤ (n : ℝ)*((τ/M)/2)) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ τ := by
  have hM0 : 0 < M := by linarith
  obtain ⟨t,ht,herr⟩ := paper_vi_general_mse_wyner ρ hρ0 hρ1 f hf d hd hdeg
    (τ/M) (div_pos hτ hM0) n hn hbudget
  refine ⟨t,ht,?_⟩
  calc
    _ ≤ M*(∑ x, ρ x*(f x-t.eval x)^2) := dominated_mse ν ρ M hdom f t.eval
    _ ≤ M*(τ/M) := mul_le_mul_of_nonneg_left herr hM0.le
    _ = τ := by field_simp

theorem reference_quadratic_mse
    (ν ρ : (ι → α) → ℝ) (hρ0 : ∀ x, 0 ≤ ρ x) (hρ1 : ∑ x, ρ x = 1)
    (M : ℝ) (hM : 1 ≤ M) (hdom : ∀ x, ν x ≤ M*ρ x)
    (f : (ι → α) → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdeg : HasProdDegreeLE f 2)
    (τ : ℝ) (hτ : 0 < τ) (hτmax : τ/M < 1/4) :
    ∃ t : DTree ι α,
      (∀ x, (t.queries x : ℝ) ≤
        (2048*quadraticC+2)/(2*(τ/M)) +
        ((2^40 : ℝ)*rowK 2*(wynerGen ρ+(τ/M)^2))/(8*(τ/M)^3)) ∧
      ∑ x, ν x*(f x-t.eval x)^2 ≤ τ := by
  have hM0 : 0 < M := by linarith
  obtain ⟨t,ht,herr⟩ := paper_vi_quadratic_mse_wyner ρ hρ0 hρ1 f hf hdeg
    (τ/M) (div_pos hτ hM0) hτmax
  refine ⟨t,ht,?_⟩
  calc
    _ ≤ M*(∑ x, ρ x*(f x-t.eval x)^2) := dominated_mse ν ρ M hdom f t.eval
    _ ≤ M*(τ/M) := mul_le_mul_of_nonneg_left herr hM0.le
    _ = τ := by field_simp

#print axioms dominated_mse
#print axioms reference_general_mse
#print axioms reference_quadratic_mse
end Nightfall.PaperVI
