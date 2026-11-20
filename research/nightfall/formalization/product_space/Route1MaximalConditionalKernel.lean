import Route1FiniteJointMass

/-!
# Finite maximal conditional kernel (including zero reference atoms)

This discharges the normalized-kernel and pushforward premises
of the existing Route1StarCoupling module without any new axioms.
-/

namespace Nightfall.Route1FiniteMaxCoupling

open Finset
variable {A : Type} [Fintype A] [DecidableEq A]

noncomputable def maximalKernel (p q : A → ℝ) (a b : A) : ℝ :=
  if p a = 0 then q b else pairMass p q a b / p a

theorem maximalKernel_nonneg (p q : A → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ a, 0 ≤ q a) (a b : A) :
    0 ≤ maximalKernel p q a b := by
  classical
  by_cases ha : p a = 0
  · simpa [maximalKernel, ha] using hq b
  · have hJ := pairMass_nonneg p q hp hq a b
    simpa [maximalKernel, ha] using
      div_nonneg hJ (hp a)

theorem maximalKernel_row (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) (hq : (∑ b, q b) = 1) (a : A) :
    (∑ b, maximalKernel p q a b) = 1 := by
  classical
  by_cases ha : p a = 0
  · simp [maximalKernel, ha, hq]
  · simp only [maximalKernel, if_neg ha]
    calc
      (∑ b : A, pairMass p q a b / p a) =
          (∑ b : A, pairMass p q a b) / p a := by
            rw [Finset.sum_div]
      _ = p a / p a := by
            rw [pairMass_left p q hp hq a]
      _ = 1 := div_self ha

theorem pairMass_zero_of_ref_zero (p q : A → ℝ)
    (hnonnegP : ∀ a, 0 ≤ p a) (hnonnegQ : ∀ a, 0 ≤ q a)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1)
    (a b : A) (ha : p a = 0) :
    pairMass p q a b = 0 := by
  have hzero : (∑ z : A, pairMass p q a z) = 0 := by
    rw [pairMass_left p q hp hq a, ha]
  have hbound : pairMass p q a b ≤ (∑ z : A, pairMass p q a z) :=
    Finset.single_le_sum
      (fun z _ => pairMass_nonneg p q hnonnegP hnonnegQ a z)
      (Finset.mem_univ b)
  rw [hzero] at hbound
  exact le_antisymm hbound (pairMass_nonneg p q hnonnegP hnonnegQ a b)

theorem maximalKernel_weighted_pair (p q : A → ℝ)
    (hnonnegP : ∀ a, 0 ≤ p a) (hnonnegQ : ∀ a, 0 ≤ q a)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1)
    (a b : A) :
    p a * maximalKernel p q a b = pairMass p q a b := by
  classical
  by_cases ha : p a = 0
  · rw [ha, zero_mul]
    exact (pairMass_zero_of_ref_zero p q hnonnegP hnonnegQ hp hq a b ha).symm
  · simp only [maximalKernel, if_neg ha]
    field_simp [ha]

theorem maximalKernel_push (p q : A → ℝ)
    (hnonnegP : ∀ a, 0 ≤ p a) (hnonnegQ : ∀ a, 0 ≤ q a)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1)
    (b : A) :
    (∑ a, p a * maximalKernel p q a b) = q b := by
  calc
    (∑ a, p a * maximalKernel p q a b) =
        ∑ a, pairMass p q a b := by
          apply Finset.sum_congr rfl
          intro a _
          exact maximalKernel_weighted_pair p q hnonnegP hnonnegQ hp hq a b
    _ = q b := pairMass_right p q hp hq b

theorem pairMass_mismatch (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1) :
    (∑ a : A, ∑ b : A,
      if a = b then 0 else pairMass p q a b) =
        mismatchMass p q := by
  classical
  have hrow (a : A) :
      (∑ b : A, if a = b then 0 else pairMass p q a b) =
        p a - overlap p q a := by
    let off : A → ℝ := fun z => if a = z then 0 else pairMass p q a z
    let diag : A → ℝ := fun z => if a = z then pairMass p q a z else 0
    have hsplit (z : A) :
        off z + diag z = pairMass p q a z := by
      dsimp [off, diag]
      by_cases hz : a = z <;> simp [hz]
    have hsum :
        (∑ z : A, off z) + (∑ z : A, diag z) =
          ∑ z : A, pairMass p q a z := by
      rw [← Finset.sum_add_distrib]
      apply Finset.sum_congr rfl
      intro z _
      exact hsplit z
    have hdiag : (∑ z : A, diag z) = pairMass p q a a := by
      simp [diag]
    have hh := pairMass_left p q hp hq a
    have hd := pairMass_diag_normalized p q hp hq a
    rw [hdiag, hh, hd] at hsum
    change (∑ z : A, off z) = p a - overlap p q a
    linarith
  calc
    (∑ a : A, ∑ b : A,
        if a = b then 0 else pairMass p q a b) =
        ∑ a : A, (p a - overlap p q a) := by
          apply Finset.sum_congr rfl
          intro a _
          exact hrow a
    _ = mismatchMass p q := by rfl

theorem finite_maximal_kernel_exists (p q : A → ℝ)
    (hnonnegP : ∀ a, 0 ≤ p a) (hnonnegQ : ∀ a, 0 ≤ q a)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1) :
    ∃ K : A → A → ℝ,
      (∀ a b, 0 ≤ K a b) ∧
      (∀ a, (∑ b, K a b) = 1) ∧
      (∀ b, (∑ a, p a * K a b) = q b) ∧
      ((∑ a : A, ∑ b : A, if a = b then 0 else p a * K a b) =
        mismatchMass p q) := by
  refine ⟨maximalKernel p q, ?_, ?_, ?_, ?_⟩
  · exact maximalKernel_nonneg p q hnonnegP hnonnegQ
  · exact maximalKernel_row p q hp hq
  · exact maximalKernel_push p q hnonnegP hnonnegQ hp hq
  · calc
      (∑ a : A, ∑ b : A,
        if a = b then 0 else p a * maximalKernel p q a b) =
        (∑ a : A, ∑ b : A,
          if a = b then 0 else pairMass p q a b) := by
            apply Finset.sum_congr rfl
            intro a _
            apply Finset.sum_congr rfl
            intro b _
            by_cases hab : a = b <;>
              simp [hab, maximalKernel_weighted_pair p q hnonnegP hnonnegQ hp hq a b]
      _ = mismatchMass p q := pairMass_mismatch p q hp hq

end Nightfall.Route1FiniteMaxCoupling

#print axioms Nightfall.Route1FiniteMaxCoupling.maximalKernel_row
#print axioms Nightfall.Route1FiniteMaxCoupling.maximalKernel_push
#print axioms Nightfall.Route1FiniteMaxCoupling.pairMass_mismatch
#print axioms Nightfall.Route1FiniteMaxCoupling.finite_maximal_kernel_exists
