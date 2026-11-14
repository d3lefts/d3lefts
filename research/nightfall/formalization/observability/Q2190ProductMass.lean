import Q2190SiteRotation

/-!
# Exact finite-product expectation factorization for local and pair kernels.

This module uses literal products of arbitrary normalized site laws.
Its lemmas are valid on heterogeneous finite alphabets after replacing
the common α with dependent FinitePi, but current Lean declarations
use the repo's genuine finite common-alphabet interface.
-/

namespace Nightfall.Q2190
open Finset

variable {ι α : Type*}
  [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

noncomputable def piMass (q : ι → α → ℝ) (x : ι → α) : ℝ :=
  ∏ i : ι, q i (x i)

theorem piMass_sum_one
    (q : ι → α → ℝ)
    (hq : ∀ i, (∑ a : α, q i a) = 1) :
    (∑ x : ι → α, piMass q x) = 1 := by
  unfold piMass
  rw [(Fintype.prod_sum (fun i a => q i a)).symm]
  simp [hq]

/-- Factorization across independent product laws, without any
strict positivity assumption. -/
theorem piMass_product_factorization
    (q : ι → α → ℝ) (g : ι → α → ℝ) :
    (∑ x : ι → α, piMass q x * (∏ i : ι, g i (x i))) =
      ∏ i : ι, ∑ a : α, q i a * g i a := by
  classical
  calc
    (∑ x : ι → α, piMass q x * (∏ i : ι, g i (x i))) =
      ∑ x : ι → α, ∏ i : ι, q i (x i) * g i (x i) := by
        apply Finset.sum_congr rfl
        intro x _
        simp only [piMass, Finset.prod_mul_distrib]
    _ = _ := (Fintype.prod_sum (fun i a => q i a * g i a)).symm

/-- One actual-coordinate finite marginal. -/
theorem piMass_singleton
    (q : ι → α → ℝ)
    (hq : ∀ i, (∑ a : α, q i a) = 1)
    (i : ι) (g : α → ℝ) :
    (∑ x : ι → α, piMass q x * g (x i)) =
      ∑ a : α, q i a * g a := by
  classical
  let G : ι → α → ℝ := fun j a => if j = i then g a else 1
  have hG (x : ι → α) : (∏ j : ι, G j (x j)) = g (x i) := by
    simp [G]
  have hfactor (j : ι) :
      (∑ a : α, q j a * G j a) =
      if j = i then (∑ a : α, q j a * g a) else 1 := by
    by_cases hj : j = i
    · simp only [G, hj, ite_true]
    · simp only [G, if_neg hj, mul_one, hq j]
  calc
    (∑ x : ι → α, piMass q x * g (x i)) =
      ∑ x : ι → α, piMass q x * (∏ j : ι, G j (x j)) := by
        apply Finset.sum_congr rfl
        intro x _
        rw [hG]
    _ = ∏ j : ι, ∑ a : α, q j a * G j a :=
      piMass_product_factorization q G
    _ = ∏ j : ι, if j = i then
       (∑ a : α, q j a * g a) else 1 := by simp_rw [hfactor]
    _ = ∑ a : α, q i a * g a := by simp

/-- Two distinct actual coordinates factor under any independent source. -/
theorem piMass_two_coordinate_product
    (q : ι → α → ℝ)
    (hq : ∀ i, (∑ a : α, q i a) = 1)
    (i j : ι) (hij : i ≠ j)
    (g h : α → ℝ) :
    (∑ x : ι → α, piMass q x * (g (x i)*h (x j))) =
      (∑ a : α, q i a*g a) * (∑ b : α, q j b*h b) := by
  classical
  let G : ι → α → ℝ := fun t a =>
    if t = i then g a else if t = j then h a else 1
  have hG (x : ι → α) :
      (∏ t : ι, G t (x t)) = g (x i)*h (x j) := by
    simp [G, hij]
  have hfactor (t : ι) :
      (∑ a : α, q t a * G t a) =
       if t = i then (∑ a : α, q t a*g a)
       else if t = j then (∑ a : α, q t a*h a) else 1 := by
    by_cases hi : t = i
    · simp [G, hi]
    · by_cases hj : t = j
      · simp [G, hi, hj]
      · simp [G, hi, hj, hq t]
  calc
    (∑ x : ι → α, piMass q x * (g (x i)*h (x j))) =
      ∑ x : ι → α, piMass q x * (∏ t : ι, G t (x t)) := by
        apply Finset.sum_congr rfl
        intro x _
        rw [hG]
    _ = ∏ t : ι, ∑ a : α, q t a * G t a :=
      piMass_product_factorization q G
    _ = ∏ t : ι, if t = i then (∑ a : α, q t a*g a)
       else if t = j then (∑ a : α, q t a*h a) else 1 := by
      simp_rw [hfactor]
    _ = (∑ a : α, q i a*g a) * (∑ b : α, q j b*h b) := by
      simp [hij]

/-- Two-coordinate arbitrary kernel, using exact finite Dirac
expansion rather than any sampling or approximate independence. -/
theorem piMass_pair_kernel
    (q : ι → α → ℝ)
    (hq : ∀ i, (∑ a : α, q i a) = 1)
    (i j : ι) (hij : i ≠ j)
    (K : α → α → ℝ) :
    (∑ x : ι → α, piMass q x * K (x i) (x j)) =
      ∑ a : α, ∑ b : α, (q i a)*(q j b)*K a b := by
  classical
  let delta : α → α → ℝ := fun a x => if x=a then 1 else 0
  have hdelta (x : ι → α) :
      K (x i) (x j) =
      ∑ a : α, delta a (x i)*K a (x j) := by
    simp [delta]
  calc
    (∑ x : ι → α, piMass q x*K (x i) (x j)) =
      ∑ x : ι → α, ∑ a : α,
        piMass q x * (delta a (x i)*K a (x j)) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [← Finset.mul_sum]
          rw [← hdelta x]
    _ = ∑ a : α, ∑ x : ι → α,
        piMass q x * (delta a (x i)*K a (x j)) := by
          rw [Finset.sum_comm]
    _ = ∑ a : α,
        (∑ t : α, q i t*delta a t) *
        (∑ b : α, q j b*K a b) := by
          apply Finset.sum_congr rfl
          intro a _
          exact piMass_two_coordinate_product q hq i j hij (delta a) (K a)
    _ = _ := by
          apply Finset.sum_congr rfl
          intro a _
          simp [delta]
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro b _
          ring

end Nightfall.Q2190
