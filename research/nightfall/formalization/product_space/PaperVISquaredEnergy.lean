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

/-- Degree-weighted ANOVA identity gives the initial/staged energy cap. -/
theorem Itot_le_degree_var
    (p : ι → α → ℝ) (hp0 : ∀ i a, 0 ≤ p i a) (hp1 : ∀ i, ∑ a, p i a = 1)
    (g : (ι → α) → ℝ) (d : ℕ) (hd : HasProdDegreeLE g d) :
    Itot p g ≤ (d : ℝ) * pvar p g := by
  classical
  have hdegree : ESDegreeLE p g d :=
    Nightfall.ProductSpace.EfronStein.esDegree_of_prodDegree p g d hd
  let E : Finset ι → ℝ := fun S => ∑ x : ι → α, originalMass p x * (esComp p S g x)^2
  have hE0 : ∀ S, 0 ≤ E S := by
    intro S
    exact Finset.sum_nonneg fun x _ => mul_nonneg
      (show 0 ≤ originalMass p x from prodMass_nonneg' p hp0 x) (sq_nonneg _)
  have hEz : ∀ S : Finset ι, d < S.card → E S = 0 := by
    intro S hs
    dsimp [E]
    simp [hdegree S hs]
  have hi : ∀ i, pinfl p g i = ∑ S : Finset ι, if i ∈ S then E S else 0 := by
    intro i
    rw [route1_influence_eq_q2_source p hp1 g i]
    exact original_source_influence_eq_interaction_energy p hp1 g i
  have hv : pvar p g = ∑ S : Finset ι, if S = ∅ then 0 else E S := by
    rw [route1_variance_eq_q2_source p g]
    exact actual_source_variance_es_energy p hp1 g
  have hcount (S : Finset ι) :
      (∑ i : ι, if i ∈ S then E S else 0) = (S.card : ℝ) * E S := by
    classical
    rw [← Finset.sum_filter]
    have he : (univ : Finset ι).filter (fun i => i ∈ S) = S := by ext i; simp
    rw [he]
    simp [nsmul_eq_mul]
  unfold Itot
  simp_rw [hi]
  rw [Finset.sum_comm]
  simp_rw [hcount]
  rw [hv, Finset.mul_sum]
  refine Finset.sum_le_sum fun S _ => ?_
  by_cases hS : S = ∅
  · subst S
    simp
  · rw [if_neg hS]
    by_cases hcard : S.card ≤ d
    · exact mul_le_mul_of_nonneg_right (by exact_mod_cast hcard) (hE0 S)
    · rw [hEz S (lt_of_not_ge hcard)]
      simp

theorem Phi2_le_degree_mvar
    (P : Θ → ι → α → ℝ) (hP0 : ∀ θ i a, 0 ≤ P θ i a)
    (hP1 : ∀ θ i, ∑ a, P θ i a = 1) (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ)
    (g : (ι → α) → ℝ) (d : ℕ) (hd : HasProdDegreeLE g d) :
    Phi2 P v g ≤ (d : ℝ) * mvar P v g := by
  have hsum : (∑ θ, v θ * Itot (P θ) g) ≤
      ∑ θ, v θ * ((d : ℝ) * pvar (P θ) g) :=
    Finset.sum_le_sum fun θ _ => mul_le_mul_of_nonneg_left
      (Itot_le_degree_var (P θ) (hP0 θ) (hP1 θ) g d hd) (hv θ)
  have he : (∑ θ, v θ * ((d : ℝ) * pvar (P θ) g)) =
      (d : ℝ) * ∑ θ, v θ * pvar (P θ) g := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun θ _ => by ring
  have hvle : (∑ θ, v θ * pvar (P θ) g) ≤ mvar P v g := by
    rw [mvar_decomp P hP1 v g]
    exact le_add_of_nonneg_right (Finset.sum_nonneg fun θ _ =>
      mul_nonneg (hv θ) (sq_nonneg _))
  rw [he] at hsum
  exact hsum.trans (mul_le_mul_of_nonneg_left hvle (Nat.cast_nonneg d))

#print axioms Nightfall.PaperVI.Itot_le_degree_var
#print axioms Nightfall.PaperVI.Phi2_le_degree_mvar

#print axioms Nightfall.PaperVI.sum_mul_pinfl_sect
#print axioms Nightfall.PaperVI.Phi2_sum
#print axioms Nightfall.PaperVI.Phi2_nonneg
end Nightfall.PaperVI
