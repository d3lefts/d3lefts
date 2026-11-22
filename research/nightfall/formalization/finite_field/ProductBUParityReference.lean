import Mathlib
import ProductSphereObstruction

/-!
# One-orbit reference map for the mod-two parity proof

A purely algebraic prerequisite for the equivariant cobordism proof of
ProductSphereZero. This module does NOT prove transversality, the compact
1-manifold boundary parity lemma, or ProductSphereZero itself.
-/

namespace Nightfall.ProductBUParity

open Nightfall.ProductSphereObstruction

def refU (k : ℕ) (u v : Fin (k + 1) → ℝ) (i : Fin k) : ℝ :=
  u i.succ

def refV (k : ℕ) (u v : Fin (k + 1) → ℝ) (i : Fin k) : ℝ :=
  v i.succ

theorem refU_flip_left (k : ℕ) (u v : Fin (k + 1) → ℝ) (i : Fin k) :
    refU k (-u) v i = -refU k u v i := by
  simp [refU]

theorem refU_flip_right (k : ℕ) (u v : Fin (k + 1) → ℝ) (i : Fin k) :
    refU k u (-v) i = refU k u v i := by
  rfl

theorem refV_flip_left (k : ℕ) (u v : Fin (k + 1) → ℝ) (i : Fin k) :
    refV k (-u) v i = refV k u v i := by
  rfl

theorem refV_flip_right (k : ℕ) (u v : Fin (k + 1) → ℝ) (i : Fin k) :
    refV k u (-v) i = -refV k u v i := by
  simp [refV]

/-- If all transverse coordinates vanish on the unit sphere, the
first coordinate is necessarily a sign. -/
theorem unit_tail_zero_first_sign (k : ℕ) (u : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (htail : ∀ i : Fin k, u i.succ = 0) :
    u 0 = 1 ∨ u 0 = -1 := by
  have htail_sum : (∑ i : Fin k, (u i.succ) ^ 2) = 0 := by
    simp [htail]
  have hs : (u 0) ^ 2 = 1 := by
    have h := hu
    unfold UnitVec at h
    rw [Fin.sum_univ_succ, htail_sum] at h
    linarith
  have hf : (u 0 - 1) * (u 0 + 1) = 0 := by nlinarith
  rcases mul_eq_zero.mp hf with h | h
  · left
    linarith
  · right
    linarith

/-- The two-factor reference zero has exactly two possible signs
for each first coordinate. Equivariance identifies all four choices
into one free G-orbit (the orbit statement is not formalized here). -/
theorem reference_zero_signs (k : ℕ) (u v : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (hU : ∀ i : Fin k, refU k u v i = 0)
    (hV : ∀ i : Fin k, refV k u v i = 0) :
    (u 0 = 1 ∨ u 0 = -1) ∧ (v 0 = 1 ∨ v 0 = -1) := by
  constructor
  · exact unit_tail_zero_first_sign k u hu (fun i => hU i)
  · exact unit_tail_zero_first_sign k v hv (fun i => hV i)

#print axioms refU_flip_left
#print axioms refU_flip_right
#print axioms refV_flip_left
#print axioms refV_flip_right
#print axioms unit_tail_zero_first_sign
#print axioms reference_zero_signs

end Nightfall.ProductBUParity
