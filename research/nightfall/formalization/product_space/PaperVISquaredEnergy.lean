import PaperVIProjectedCrux

/-!
Paper VI: exact squared-influence potential, conditional mixture drift,
and finite-degree cap, on the existing Route1 source semantics.
-/
namespace Nightfall.PaperVI
open Finset
open Nightfall.Route1Polylog
open Nightfall.QuadraticWynerQ2SourceBridge
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Simulation
open Nightfall.ProductSpace.Mixture
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceVarianceEnergy
open Nightfall.Observability.ActualSourceInfluenceEnergy

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α] [Nonempty α]
variable {Θ : Type} [Fintype Θ] [DecidableEq Θ] [Nonempty Θ]

theorem sum_mul_pinfl_sect (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (j k : ι) (hkj : k ≠ j) :
    ∑ c, p j c * pinfl p (sect g j c) k = pinfl p g k := by
  let F : (ι → α) → ℝ := fun y => ∑ b, p k b * ((g y - g (Function.update y k b))^2/2)
  have hs : ∀ c, pinfl p (sect g j c) k = ∑ x, prodMass p x * F (Function.update x j c) := by
    intro c
    unfold pinfl
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [F, sect, Finset.mul_sum]
    refine Finset.sum_congr rfl fun b _ => ?_
    rw [Function.update_comm hkj]
    ring
  have hg : pinfl p g k = ∑ x, prodMass p x * F x := by
    unfold pinfl
    refine Finset.sum_congr rfl fun x _ => ?_
    simp only [F, Finset.mul_sum]
    exact Finset.sum_congr rfl fun b _ => by ring
  simp only [hs, hg]
  rw [← resample_sum p hp1 j F, Finset.sum_comm]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun x _ => by ring

noncomputable def Itot (p : ι → α → ℝ) (g : (ι → α) → ℝ) : ℝ := ∑ j, pinfl p g j

theorem sum_mul_Itot_sect (p : ι → α → ℝ) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (j : ι) :
    ∑ c, p j c * Itot p (sect g j c) = Itot p g - pinfl p g j := by
  unfold Itot
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]
  rw [← Finset.add_sum_erase _ _ (mem_univ j), ← Finset.add_sum_erase _ _ (mem_univ j)]
  have h0 : ∑ c, p j c * pinfl p (sect g j c) j = 0 :=
    Finset.sum_eq_zero fun c _ => by rw [pinfl_inv p _ j (inv_sect_self g j c), mul_zero]
  rw [h0, zero_add]
  have h : ∑ k ∈ univ.erase j, ∑ c, p j c * pinfl p (sect g j c) k =
      ∑ k ∈ univ.erase j, pinfl p g k :=
    Finset.sum_congr rfl fun k hk => sum_mul_pinfl_sect p hp1 g j k (Finset.ne_of_mem_erase hk)
  rw [h]
  ring

noncomputable def Phi2 (P : Θ → ι → α → ℝ) (v : Θ → ℝ) (g : (ι → α) → ℝ) : ℝ :=
  ∑ θ, v θ * Itot (P θ) g

theorem Phi2_nonneg (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (g : (ι → α) → ℝ) :
    0 ≤ Phi2 P v g := by
  unfold Phi2 Itot
  exact Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ)
    (Finset.sum_nonneg fun j _ => pinfl_nonneg (P θ) (hP0 θ) g j)

theorem Phi2_sum (P : Θ → ι → α → ℝ) (hP1 : ∀ θ i, ∑ b : α, P θ i b = 1)
    (v : Θ → ℝ) (g : (ι → α) → ℝ) (j : ι) :
    ∑ b, Phi2 P (upd P v j b) (sect g j b) =
      Phi2 P v g - ∑ θ, v θ * pinfl (P θ) g j := by
  unfold Phi2 upd
  rw [Finset.sum_comm, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun θ _ => ?_
  calc
    ∑ b, v θ * P θ j b * Itot (P θ) (sect g j b) =
      v θ * ∑ b, P θ j b * Itot (P θ) (sect g j b) := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun b _ => by ring
    _ = v θ * Itot (P θ) g - v θ * pinfl (P θ) g j := by
        rw [sum_mul_Itot_sect (P θ) (hP1 θ) g j]
        ring

#print axioms Nightfall.PaperVI.sum_mul_pinfl_sect
#print axioms Nightfall.PaperVI.Phi2_sum
#print axioms Nightfall.PaperVI.Phi2_nonneg
end Nightfall.PaperVI
