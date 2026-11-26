import Mathlib
import T2DoubleLightCharge

/-! Paper V v2.1 equations (4) and (5): actual finite frequency
grouping, without an abstract orthogonality assumption. Applies to the
real parts of the physical four-slot coefficients. The six repeated
and four survivor operator estimates still require source composition. -/
namespace Nightfall.PaperVGroupedEnergy
open Finset
variable {T G : Type*} [DecidableEq T] [DecidableEq G]

theorem single_light_energy (S A B C D : Finset T) (w : T → ℝ) (eta : ℝ)
    (hw : ∀ t, 0 ≤ w t)
    (ha : ∑ t ∈ A, w t ≤ eta) (hb : ∑ t ∈ B, w t ≤ eta)
    (hc : ∑ t ∈ C, w t ≤ eta) (hd : ∑ t ∈ D, w t ≤ eta)
    (hcover : ∀ t ∈ S, t ∈ A ∨ t ∈ B ∨ t ∈ C ∨ t ∈ D) :
    ∑ t ∈ S, w t ≤ 4*eta := by
  classical
  have hcharge : ∀ X : Finset T,
      (∑ t ∈ S, (if t ∈ X then w t else 0)) ≤ ∑ t ∈ X, w t := by
    intro X
    rw [← Finset.sum_filter]
    exact Finset.sum_le_sum_of_subset_of_nonneg (fun t ht => (Finset.mem_filter.mp ht).2)
      (fun t _ _ => hw t)
  have h : (∑ t ∈ S, w t) ≤
      ∑ t ∈ S, ((if t ∈ A then w t else 0) + (if t ∈ B then w t else 0) +
        (if t ∈ C then w t else 0) + (if t ∈ D then w t else 0)) := by
    apply Finset.sum_le_sum
    intro t ht
    rcases hcover t ht with hA | hB | hC | hD
    · simp only [hA, if_true]
      split <;> split <;> split <;> linarith [hw t]
    · simp only [hB, if_true]
      split <;> split <;> split <;> linarith [hw t]
    · simp only [hC, if_true]
      split <;> split <;> split <;> linarith [hw t]
    · simp only [hD, if_true]
      split <;> split <;> split <;> linarith [hw t]
  simp only [Finset.sum_add_distrib] at h
  linarith [hcharge A, hcharge B, hcharge C, hcharge D]

/-- Equation (5) in squared form, before taking the square root.
The fiber sum is computed from the tuple-to-frequency map itself. -/
theorem grouped_sq_bound (S : Finset T) (Z : Finset G) (freq : T → G)
    (c : T → ℝ) (B : ℝ) (hB : 0 ≤ B)
    (hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t = z)).card : ℝ) ≤ B) :
    (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t = z), c t)^2)
      ≤ B * ∑ t ∈ S, (c t)^2 := by
  classical
  calc
    _ ≤ ∑ z ∈ Z, B * ∑ t ∈ S.filter (fun t => freq t = z), (c t)^2 := by
      apply Finset.sum_le_sum
      intro z hz
      let F := S.filter (fun t => freq t = z)
      have hc : (∑ t ∈ F, c t)^2 ≤ (F.card : ℝ) * ∑ t ∈ F, (c t)^2 := by
        simpa using Finset.sum_mul_sq_le_sq_mul_sq F (fun _ : T => (1 : ℝ)) c
      exact hc.trans (mul_le_mul_of_nonneg_right (hcard z hz)
        (Finset.sum_nonneg fun t _ => sq_nonneg (c t)))
    _ = B * ∑ t ∈ S.filter (fun t => freq t ∈ Z), (c t)^2 := by
      rw [← Finset.mul_sum, Finset.sum_fiberwise_eq_sum_filter S Z freq]
    _ ≤ B * ∑ t ∈ S, (c t)^2 := by
      apply mul_le_mul_of_nonneg_left _ hB
      exact Finset.sum_le_sum_of_subset_of_nonneg
        (Finset.filter_subset _ _) (fun t _ _ => sq_nonneg (c t))

theorem primitive_grouped_energy (S A B C D : Finset T) (Z : Finset G)
    (freq : T → G) (c : T → ℝ) (K eta : ℝ) (hK : 0 ≤ K)
    (ha : ∑ t ∈ A, (c t)^2 ≤ eta) (hb : ∑ t ∈ B, (c t)^2 ≤ eta)
    (hc : ∑ t ∈ C, (c t)^2 ≤ eta) (hd : ∑ t ∈ D, (c t)^2 ≤ eta)
    (hcover : ∀ t ∈ S, t ∈ A ∨ t ∈ B ∨ t ∈ C ∨ t ∈ D)
    (hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t = z)).card : ℝ) ≤ K) :
    (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t = z), c t)^2)
      ≤ 4*K*eta := by
  have h := single_light_energy S A B C D (fun t => (c t)^2) eta
    (fun t => sq_nonneg _) ha hb hc hd hcover
  calc
    _ ≤ K * ∑ t ∈ S, (c t)^2 := grouped_sq_bound S Z freq c K hK hcard
    _ ≤ K * (4*eta) := mul_le_mul_of_nonneg_left h hK
    _ = 4*K*eta := by ring

theorem correction_grouped_energy (S A B C D : Finset T) (Z : Finset G)
    (freq : T → G) (c : T → ℝ) (M eta : ℝ) (hM : 0 ≤ M)
    (ha : ∑ t ∈ A, (c t)^2 ≤ eta) (hb : ∑ t ∈ B, (c t)^2 ≤ eta)
    (hc : ∑ t ∈ C, (c t)^2 ≤ eta) (hd : ∑ t ∈ D, (c t)^2 ≤ eta)
    (hdouble : ∀ t ∈ S, 2 ≤ (if t ∈ A then (1 : ℝ) else 0) +
      (if t ∈ B then 1 else 0) + (if t ∈ C then 1 else 0) + (if t ∈ D then 1 else 0))
    (hcard : ∀ z ∈ Z, ((S.filter (fun t => freq t = z)).card : ℝ) ≤ 6*M) :
    (∑ z ∈ Z, (∑ t ∈ S.filter (fun t => freq t = z), c t)^2)
      ≤ 12*M*eta := by
  have h := Nightfall.StructuralInformation.T2DoubleLightCharge.double_light_energy
    S A B C D (fun t => (c t)^2) eta (fun t => sq_nonneg _) ha hb hc hd hdouble
  calc
    _ ≤ (6*M) * ∑ t ∈ S, (c t)^2 :=
      grouped_sq_bound S Z freq c (6*M) (by positivity) hcard
    _ ≤ (6*M) * (2*eta) := mul_le_mul_of_nonneg_left h (by positivity)
    _ = 12*M*eta := by ring

#print axioms single_light_energy
#print axioms grouped_sq_bound
#print axioms primitive_grouped_energy
#print axioms correction_grouped_energy
end Nightfall.PaperVGroupedEnergy
