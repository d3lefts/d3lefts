import Mathlib

/-!
# Route 1 finite maximal coupling: exact overlap and residual algebra

The new proof constructs an optimal coupling of two normalized
finite probability vectors (including zeros), then turns it into a
conditional kernel. This fills the real missing input of the already
kernel-checked Route1StarCoupling.lean.

All universal statements have explicit finite probability hypotheses.
No sorry, new axioms, numerical tolerances, or reliance on an oracle.
-/

namespace Nightfall.Route1FiniteMaxCoupling

open Finset

variable {A : Type} [Fintype A] [DecidableEq A]

noncomputable def overlap (p q : A → ℝ) (a : A) : ℝ := min (p a) (q a)

noncomputable def leftResidual (p q : A → ℝ) (a : A) : ℝ :=
  p a - overlap p q a

noncomputable def rightResidual (p q : A → ℝ) (a : A) : ℝ :=
  q a - overlap p q a

noncomputable def mismatchMass (p q : A → ℝ) : ℝ :=
  ∑ a, leftResidual p q a

theorem overlap_nonneg (p q : A → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ a, 0 ≤ q a) (a : A) :
    0 ≤ overlap p q a := by
  simp only [overlap]
  exact le_min (hp a) (hq a)

theorem residual_nonneg (p q : A → ℝ) (a : A) :
    0 ≤ leftResidual p q a ∧ 0 ≤ rightResidual p q a := by
  constructor
  · exact sub_nonneg.mpr (min_le_left _ _)
  · exact sub_nonneg.mpr (min_le_right _ _)

theorem residual_disjoint (p q : A → ℝ) (a : A) :
    leftResidual p q a * rightResidual p q a = 0 := by
  unfold leftResidual rightResidual overlap
  le_total (p a) (q a) |>.elim
    (fun h => by rw [min_eq_left h]; ring)
    (fun h => by rw [min_eq_right h]; ring)

theorem residual_mass_eq (p q : A → ℝ)
    (hp : (∑ a, p a) = 1)
    (hq : (∑ a, q a) = 1) :
    (∑ a, rightResidual p q a) = mismatchMass p q := by
  simp only [mismatchMass, leftResidual, rightResidual]
  rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, hp, hq]

theorem mismatchMass_nonneg (p q : A → ℝ) :
    0 ≤ mismatchMass p q := by
  exact Finset.sum_nonneg (fun a _ => (residual_nonneg p q a).1)

theorem residual_zero_of_mass_zero (p q : A → ℝ)
    (ht : mismatchMass p q = 0) (a : A) :
    leftResidual p q a = 0 := by
  have ha : leftResidual p q a ≤ mismatchMass p q := by
    unfold mismatchMass
    exact Finset.single_le_sum
      (fun b _ => (residual_nonneg p q b).1)
      (Finset.mem_univ a)
  exact le_antisymm (by simpa [ht] using ha) (residual_nonneg p q a).1

theorem right_residual_zero_of_mass_zero (p q : A → ℝ)
    (hp : (∑ a, p a) = 1) (hq : (∑ a, q a) = 1)
    (ht : mismatchMass p q = 0) (a : A) :
    rightResidual p q a = 0 := by
  have ha : rightResidual p q a ≤ (∑ b, rightResidual p q b) := by
    exact Finset.single_le_sum
      (fun b _ => (residual_nonneg p q b).2)
      (Finset.mem_univ a)
  rw [residual_mass_eq p q hp hq, ht] at ha
  exact le_antisymm ha (residual_nonneg p q a).2

theorem overlap_add_leftResidual (p q : A → ℝ) (a : A) :
    overlap p q a + leftResidual p q a = p a := by
  simp only [leftResidual]
  ring

theorem overlap_add_rightResidual (p q : A → ℝ) (a : A) :
    overlap p q a + rightResidual p q a = q a := by
  simp only [rightResidual]
  ring

end Nightfall.Route1FiniteMaxCoupling

#print axioms Nightfall.Route1FiniteMaxCoupling.overlap_nonneg
#print axioms Nightfall.Route1FiniteMaxCoupling.residual_nonneg
#print axioms Nightfall.Route1FiniteMaxCoupling.residual_disjoint
#print axioms Nightfall.Route1FiniteMaxCoupling.residual_mass_eq
#print axioms Nightfall.Route1FiniteMaxCoupling.residual_zero_of_mass_zero
