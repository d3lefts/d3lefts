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


/-- All lower-rank pure-character product-sphere zero statements follow
from the single top-square case, by zero-padding the output blocks.
This is a *conditional reduction*, not a proof of the top-square case. -/
theorem square_implies_productSphereZero (n r s : ℕ)
    (hr : r ≤ n - 1) (hs : s ≤ n - 1)
    (hTop : ProductSphereZero n (n - 1) (n - 1)) :
    ProductSphereZero n r s := by
  intro fU fV hcU hcV hUneg hUeven hVeven hVneg
  let embU (u v : Fin n → ℝ) (i : Fin (n - 1)) : ℝ :=
    if hi : i.val < r then fU u v ⟨i.val, hi⟩ else 0
  let embV (u v : Fin n → ℝ) (i : Fin (n - 1)) : ℝ :=
    if hi : i.val < s then fV u v ⟨i.val, hi⟩ else 0
  have hcU' : ∀ i : Fin (n - 1), ContinuousOn
      (fun p : (Fin n → ℝ) × (Fin n → ℝ) => embU p.1 p.2 i)
      (SpherePair n) := by
    intro i
    by_cases hi : i.val < r
    · simpa only [embU, dif_pos hi] using hcU ⟨i.val, hi⟩
    · simpa [embU, hi] using
        (continuousOn_const : ContinuousOn
          (fun _ : (Fin n → ℝ) × (Fin n → ℝ) => (0 : ℝ)) (SpherePair n))
  have hcV' : ∀ i : Fin (n - 1), ContinuousOn
      (fun p : (Fin n → ℝ) × (Fin n → ℝ) => embV p.1 p.2 i)
      (SpherePair n) := by
    intro i
    by_cases hi : i.val < s
    · simpa only [embV, dif_pos hi] using hcV ⟨i.val, hi⟩
    · simpa [embV, hi] using
        (continuousOn_const : ContinuousOn
          (fun _ : (Fin n → ℝ) × (Fin n → ℝ) => (0 : ℝ)) (SpherePair n))
  have hUneg' : ∀ u v (i : Fin (n - 1)), UnitVec n u → UnitVec n v →
      embU (-u) v i = -embU u v i := by
    intro u v i hu hv
    by_cases hi : i.val < r
    · simpa only [embU, dif_pos hi] using hUneg u v ⟨i.val,hi⟩ hu hv
    · simp [embU, hi]
  have hUeven' : ∀ u v (i : Fin (n - 1)), UnitVec n u → UnitVec n v →
      embU u (-v) i = embU u v i := by
    intro u v i hu hv
    by_cases hi : i.val < r
    · simpa only [embU, dif_pos hi] using hUeven u v ⟨i.val,hi⟩ hu hv
    · simp [embU, hi]
  have hVeven' : ∀ u v (i : Fin (n - 1)), UnitVec n u → UnitVec n v →
      embV (-u) v i = embV u v i := by
    intro u v i hu hv
    by_cases hi : i.val < s
    · simpa only [embV, dif_pos hi] using hVeven u v ⟨i.val,hi⟩ hu hv
    · simp [embV, hi]
  have hVneg' : ∀ u v (i : Fin (n - 1)), UnitVec n u → UnitVec n v →
      embV u (-v) i = -embV u v i := by
    intro u v i hu hv
    by_cases hi : i.val < s
    · simpa only [embV, dif_pos hi] using hVneg u v ⟨i.val,hi⟩ hu hv
    · simp [embV, hi]
  obtain ⟨u,v,hu,hv,hzU,hzV⟩ :=
    hTop embU embV hcU' hcV' hUneg' hUeven' hVeven' hVneg'
  refine ⟨u,v,hu,hv,?_,?_⟩
  · intro i
    let j : Fin (n - 1) := ⟨i.val, by omega⟩
    have hj := hzU j
    have hij : j.val < r := i.isLt
    simpa [embU, hij, j] using hj
  · intro i
    let j : Fin (n - 1) := ⟨i.val, by omega⟩
    have hj := hzV j
    have hij : j.val < s := i.isLt
    simpa [embV, hij, j] using hj

#print axioms square_implies_productSphereZero

#print axioms refU_flip_left
#print axioms refU_flip_right
#print axioms refV_flip_left
#print axioms refV_flip_right
#print axioms unit_tail_zero_first_sign
#print axioms reference_zero_signs

end Nightfall.ProductBUParity
