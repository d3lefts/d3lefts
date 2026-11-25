import AllOrderFourier
import AllOrderTensorLocalization
import Mathlib.Data.Fintype.Option

namespace Nightfall.AllOrder
open Finset
open Nightfall.StructuralInformation.T2UniformParseval
variable {I A : Type*} [Fintype I] [DecidableEq I] [Fintype A] [DecidableEq A]

/-- A bound on the exact coefficient-array multilinear form on independent real unit cubes. -/
def CubeBound (c : (I → A) → ℝ) (K : ℝ) : Prop :=
  ∀ u : I → A → ℝ, (∀ i a, |u i a| ≤ 1) → |cubeForm c u| ≤ K

/-- Operator norm of a coefficient mask on the multilinear cube. -/
def MaskCost (H : (I → A) → ℝ) (C : ℝ) : Prop :=
  0 ≤ C ∧ ∀ (c : (I → A) → ℝ) (K : ℝ), 0 ≤ K → CubeBound c K → CubeBound (fun a => c a * H a) (C*K)

theorem mask_cost_one : MaskCost (fun _ : I → A => 1) 1 := by
  refine ⟨by norm_num,?_⟩
  intro c K hK hc u hu
  simpa using hc u hu

theorem cubeForm_add (c d : (I → A) → ℝ) (u : I → A → ℝ) :
    cubeForm (fun a => c a + d a) u = cubeForm c u + cubeForm d u := by
  simp [cubeForm,add_mul,Finset.sum_add_distrib]

theorem cubeForm_sub (c d : (I → A) → ℝ) (u : I → A → ℝ) :
    cubeForm (fun a => c a - d a) u = cubeForm c u - cubeForm d u := by
  simp [cubeForm,sub_mul,Finset.sum_sub_distrib]

theorem mask_cost_add (H G : (I → A) → ℝ) (C D : ℝ) (hH : MaskCost H C) (hG : MaskCost G D) :
    MaskCost (fun a => H a + G a) (C+D) := by
  refine ⟨add_nonneg hH.1 hG.1,?_⟩
  intro c K hK hc u hu
  have h : (fun a => c a*(H a+G a)) = fun a => c a*H a+c a*G a := by funext a; ring
  rw [h,cubeForm_add,add_mul]
  exact (abs_add_le _ _).trans (add_le_add (hH.2 c K hK hc u hu) (hG.2 c K hK hc u hu))

theorem mask_cost_complement (H : (I → A) → ℝ) (C : ℝ) (hH : MaskCost H C) :
    MaskCost (fun a => 1-H a) (1+C) := by
  refine ⟨by linarith [hH.1],?_⟩
  intro c K hK hc u hu
  have h : (fun a => c a*(1-H a)) = fun a => c a-c a*H a := by funext a; ring
  rw [h,cubeForm_sub,add_mul,one_mul]
  exact (abs_sub _ _).trans (add_le_add (hc u hu) (hH.2 c K hK hc u hu))

theorem mask_cost_mul (H G : (I → A) → ℝ) (C D : ℝ) (hH : MaskCost H C) (hG : MaskCost G D) :
    MaskCost (fun a => H a * G a) (C*D) := by
  refine ⟨mul_nonneg hH.1 hG.1,?_⟩
  intro c K hK hc u hu
  have h := hG.2 (fun a => c a*H a) (C*K) (mul_nonneg hH.1 hK) (hH.2 c K hK hc) u hu
  have he : (fun a => c a * H a * G a) = fun a => c a * (H a * G a) := by
    funext a; ring
  rw [he] at h
  have he' : D*(C*K) = C*D*K := by ring
  rwa [he'] at h

theorem mask_cost_mono (H : (I → A) → ℝ) (C D : ℝ) (hH : MaskCost H C) (hCD : C ≤ D) : MaskCost H D := by
  refine ⟨hH.1.trans hCD,?_⟩
  intro c K hK hc u hu
  exact (hH.2 c K hK hc u hu).trans (mul_le_mul_of_nonneg_right hCD hK)

theorem mask_cost_zero : MaskCost (fun _ : I → A => 0) 0 := by
  refine ⟨le_rfl,?_⟩
  intro c K hK hc u hu
  simp [cubeForm]

theorem mask_cost_sum {W : Type*} (S : Finset W) (H : W → (I → A) → ℝ) (C : W → ℝ)
    (hH : ∀ w ∈ S, MaskCost (H w) (C w)) :
    MaskCost (fun a => ∑ w ∈ S, H w a) (∑ w ∈ S, C w) := by
  classical
  induction S using Finset.induction_on with
  | empty => simpa using (mask_cost_zero (I := I) (A := A))
  | @insert w S hw ih =>
    simp only [Finset.sum_insert hw]
    exact mask_cost_add _ _ _ _ (hH w (Finset.mem_insert_self _ _)) (ih (fun k hk => hH k (Finset.mem_insert_of_mem hk)))

theorem mask_cost_prod {W : Type*} (S : Finset W) (H : W → (I → A) → ℝ) (C : W → ℝ)
    (hH : ∀ w ∈ S, MaskCost (H w) (C w)) :
    MaskCost (fun a => ∏ w ∈ S, H w a) (∏ w ∈ S, C w) := by
  classical
  induction S using Finset.induction_on with
  | empty => simpa using (mask_cost_one (I := I) (A := A))
  | @insert w S hw ih =>
    simp only [Finset.prod_insert hw]
    exact mask_cost_mul _ _ _ _ (hH w (Finset.mem_insert_self _ _)) (ih (fun k hk => hH k (Finset.mem_insert_of_mem hk)))

/-- Any finite signed separable representation gives an actual mask operator norm. -/
theorem mask_cost_rep {W : Type*} [Fintype W] (w : W → ℝ) (m : W → I → A → ℝ)
    (hm : ∀ t i a, |m t i a| ≤ 1) : MaskCost (maskRep w m) (∑ t, |w t|) := by
  refine ⟨Finset.sum_nonneg (fun _ _ => abs_nonneg _),?_⟩
  intro c K hK hc u hu
  exact cube_mask_bound c u w m K hK hc hu hm

section Character
variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

theorem abs_sign (h₂ : ∀ z : G, z+z=0) (s : AddChar G ℂ) (z : G) : |sign s z| = 1 := by
  rcases char_sign h₂ s z with h|h <;> simp [sign,h]

/-- Exact zero-sum subset mask with operator cost one. -/
theorem zero_subset_mask_cost (label : A → G) (h₂ : ∀ z : G, z+z=0) (S : Finset I) :
    MaskCost (fun a => if (∑ i ∈ S, label (a i)) = 0 then 1 else 0) 1 := by
  classical
  let w : AddChar G ℂ → ℝ := fun _ => (Fintype.card G : ℝ)⁻¹
  let m : AddChar G ℂ → I → A → ℝ := fun t i a => if i ∈ S then sign t (label a) else 1
  have hm : ∀ t i a, |m t i a| ≤ 1 := by
    intro t i a
    by_cases h : i ∈ S <;> simp [m,h,abs_sign h₂]
  have hrep : maskRep w m = (fun a => if (∑ i ∈ S, label (a i)) = 0 then 1 else 0) := by
    funext a
    unfold maskRep w m
    simp_rw [← Finset.prod_filter]
    simp only [Finset.filter_mem_eq_inter, Finset.univ_inter]
    rw [← Finset.mul_sum, zero_mask_average h₂]
    have hn : (Fintype.card G : ℝ) ≠ 0 := by positivity
    split <;> simp [hn]
  have hcost : ∑ t, |w t| = 1 := by
    have hn : (Fintype.card G : ℝ) ≠ 0 := by positivity
    simp [w, AddChar.card_eq, abs_of_nonneg (inv_nonneg.mpr (by positivity : (0:ℝ) ≤ Fintype.card G)), hn, nsmul_eq_mul]
  rw [← hrep, ← hcost]
  exact mask_cost_rep w m hm
end Character

#print axioms mask_cost_prod
#print axioms mask_cost_rep
#print axioms zero_subset_mask_cost
end Nightfall.AllOrder
