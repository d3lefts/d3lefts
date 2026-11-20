import Route1FiniteMaxCoupling

/-!
# Fully finite maximal pair mass, derived from overlap/residual algebra.
This is the next Route 1 kernel obligation after star-kernel normalization:
simultaneously usable pair couplings to the shared reference law.
-/
namespace Nightfall.Route1FiniteMaxCoupling

open Finset
variable {A : Type} [Fintype A] [DecidableEq A]

/-- Exact maximal coupling. The t=0 branch is diagonal, and the t>0
    branch uses disjoint residual supports. -/
noncomputable def pairMass (p q : A → ℝ) (a b : A) : ℝ :=
  if mismatchMass p q = 0 then
    if a = b then p a else 0
  else
    (if a = b then overlap p q a else 0) +
      leftResidual p q a * rightResidual p q b / mismatchMass p q

theorem pairMass_nonneg (p q : A → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ a, 0 ≤ q a) (a b : A) :
    0 ≤ pairMass p q a b := by
  classical
  by_cases ht : mismatchMass p q = 0
  · simp only [pairMass, ht, ↓reduceIte]
    split_ifs with h
    · exact hp a
    · exact le_refl _
  · have htpos : 0 < mismatchMass p q := by
      have hn := mismatchMass_nonneg p q
      rcases lt_or_eq_of_le hn with h | h
      · exact h
      · exact False.elim (ht h.symm)
    simp only [pairMass, ht, ↓reduceIte]
    apply add_nonneg
    · split_ifs
      · exact overlap_nonneg p q hp hq a
      · exact le_refl _
    · exact div_nonneg (mul_nonneg (residual_nonneg p q a).1
        (residual_nonneg p q b).2) htpos.le

theorem pairMass_left (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1) (a : A) :
    (∑ b, pairMass p q a b) = p a := by
  classical
  by_cases ht : mismatchMass p q = 0
  · simp [pairMass, ht]
  · have hs (b : A) :
        pairMass p q a b =
          (if a = b then overlap p q a else 0) +
            leftResidual p q a * rightResidual p q b / mismatchMass p q := by
      simp [pairMass, ht]
    simp_rw [hs]
    rw [Finset.sum_add_distrib]
    have hd :
        (∑ b : A, if a = b then overlap p q a else 0) =
          overlap p q a := by simp
    rw [hd]
    have hr :
        (∑ b : A, leftResidual p q a * rightResidual p q b /
          mismatchMass p q) =
        leftResidual p q a * (∑ b : A, rightResidual p q b) /
          mismatchMass p q := by
      calc
        _ = ∑ b : A,
            (leftResidual p q a / mismatchMass p q) *
              rightResidual p q b := by
              apply Finset.sum_congr rfl
              intro b _
              ring
        _ = leftResidual p q a / mismatchMass p q *
              (∑ b : A, rightResidual p q b) := by
                rw [Finset.mul_sum]
        _ = _ := by ring
    rw [hr, residual_mass_eq p q hp hq]
    have ht' :
        leftResidual p q a * mismatchMass p q / mismatchMass p q =
          leftResidual p q a := by field_simp [ht]
    rw [ht']
    exact overlap_add_leftResidual p q a

theorem pairMass_right (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1) (b : A) :
    (∑ a, pairMass p q a b) = q b := by
  classical
  by_cases ht : mismatchMass p q = 0
  · have hpq : p b = q b := by
      have hl := residual_zero_of_mass_zero p q ht b
      have hr := right_residual_zero_of_mass_zero p q hp hq ht b
      have hleft : p b = overlap p q b := by
        have h := overlap_add_leftResidual p q b
        rw [hl, add_zero] at h
        exact h.symm
      have hright : q b = overlap p q b := by
        have h := overlap_add_rightResidual p q b
        rw [hr, add_zero] at h
        exact h.symm
      exact hleft.trans hright.symm
    simpa [pairMass, ht] using hpq
  · have hs (a : A) :
        pairMass p q a b =
          (if a = b then overlap p q a else 0) +
            leftResidual p q a * rightResidual p q b / mismatchMass p q := by
      simp [pairMass, ht]
    simp_rw [hs]
    rw [Finset.sum_add_distrib]
    have hd :
        (∑ a : A, if a = b then overlap p q a else 0) =
          overlap p q b := by simp
    rw [hd]
    have hr :
        (∑ a : A, leftResidual p q a * rightResidual p q b /
          mismatchMass p q) =
        (∑ a : A, leftResidual p q a) * rightResidual p q b /
          mismatchMass p q := by
      calc
        _ = ∑ a : A,
            leftResidual p q a *
              (rightResidual p q b / mismatchMass p q) := by
              apply Finset.sum_congr rfl
              intro a _
              ring
        _ = (∑ a : A, leftResidual p q a) *
              (rightResidual p q b / mismatchMass p q) := by
                rw [Finset.sum_mul]
        _ = _ := by ring
    rw [hr]
    change overlap p q b + mismatchMass p q *
      rightResidual p q b / mismatchMass p q = q b
    have ht' : mismatchMass p q *
      rightResidual p q b / mismatchMass p q = rightResidual p q b := by
        field_simp [ht]
    rw [ht']
    exact overlap_add_rightResidual p q b

theorem pairMass_diag (p q : A → ℝ) (a : A)
    (ht : mismatchMass p q = 0 → p a = overlap p q a) :
    pairMass p q a a = overlap p q a := by
  classical
  by_cases hz : mismatchMass p q = 0
  · simp [pairMass, hz, ht hz]
  · simp [pairMass, hz, residual_disjoint p q a]

theorem pairMass_diag_normalized (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1) (a : A) :
    pairMass p q a a = overlap p q a := by
  apply pairMass_diag p q a ?_
  intro ht
  have h := residual_zero_of_mass_zero p q ht a
  unfold leftResidual at h
  linarith

theorem mismatchMass_eq_one_sub_overlap (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) :
    mismatchMass p q = 1 - ∑ a, overlap p q a := by
  unfold mismatchMass leftResidual
  rw [Finset.sum_sub_distrib, hp]

end Nightfall.Route1FiniteMaxCoupling

#print axioms Nightfall.Route1FiniteMaxCoupling.pairMass_left
#print axioms Nightfall.Route1FiniteMaxCoupling.pairMass_right
#print axioms Nightfall.Route1FiniteMaxCoupling.pairMass_diag_normalized
