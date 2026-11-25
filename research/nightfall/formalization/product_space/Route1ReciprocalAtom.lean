import Mathlib

/-! The reciprocal interpolation atom, independently of Route 1's analytic hypotheses. -/

namespace Nightfall.Route1ReciprocalAtom

open Polynomial

noncomputable section

def reciprocalAtom (l j : ℕ) : Polynomial ℝ :=
  X ^ (j - l) * ∏ i ∈ Finset.range l, (1 - C (i : ℝ) * X)

theorem reciprocalAtom_eval_inv (l j : ℕ) (hlj : l ≤ j)
    (r : ℝ) (hr : r ≠ 0) :
    (reciprocalAtom l j).eval r⁻¹ = (∏ i ∈ Finset.range l, (r - (i : ℝ))) / r ^ j := by
  simp only [reciprocalAtom, Polynomial.eval_mul, Polynomial.eval_pow,
    Polynomial.eval_X, Polynomial.eval_prod, Polynomial.eval_sub,
    Polynomial.eval_one, Polynomial.eval_C]
  have hfactor (i : ℕ) : (1 : ℝ) - (i : ℝ) * r⁻¹ = (r - (i : ℝ)) * r⁻¹ := by
    field_simp [hr]
    <;> ring
  simp_rw [hfactor]
  rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_range]
  simp only [div_eq_mul_inv, ← inv_pow]
  let P : ℝ := ∏ i ∈ Finset.range l, (r - (i : ℝ))
  change r⁻¹ ^ (j-l) * (P * r⁻¹ ^ l) = P * r⁻¹ ^ j
  calc
    r⁻¹ ^ (j-l) * (P * r⁻¹ ^ l) = P * (r⁻¹ ^ (j-l) * r⁻¹ ^ l) := by ring
    _ = P * r⁻¹ ^ j := by rw [← pow_add, Nat.sub_add_cancel hlj]

theorem reciprocalAtom_eval_zero (l j : ℕ) (hlj : l ≤ j) :
    (reciprocalAtom l j).eval 0 = if j = l then 1 else 0 := by
  by_cases h : j = l
  · subst j
    simp [reciprocalAtom, Polynomial.eval_prod]
  · have hjl : j - l ≠ 0 := by omega
    simp [reciprocalAtom, Polynomial.eval_prod, h, hjl]

private theorem factor_natDegree_le (i : ℕ) :
    (1 - C (i : ℝ) * X : Polynomial ℝ).natDegree ≤ 1 := by
  refine (Polynomial.natDegree_sub_le _ _).trans (max_le ?_ ?_)
  · simp
  · simpa only [Polynomial.natDegree_X] using
      (Polynomial.natDegree_C_mul_le (i : ℝ) (X : Polynomial ℝ))

private theorem prod_succ_natDegree_le (k : ℕ) :
    (∏ i ∈ Finset.range (k + 1), (1 - C (i : ℝ) * X : Polynomial ℝ)).natDegree ≤ k := by
  induction k with
  | zero => simp [Finset.prod_range_succ]
  | succ k ih =>
    rw [Finset.prod_range_succ]
    exact Polynomial.natDegree_mul_le.trans (Nat.add_le_add ih (factor_natDegree_le (k+1)))

theorem reciprocalAtom_natDegree_le (l j : ℕ) (hl : 0 < l) (hlj : l ≤ j) :
    (reciprocalAtom l j).natDegree ≤ j - 1 := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt hl)
  have hX : (X ^ (j - (k + 1)) : Polynomial ℝ).natDegree ≤ j - (k + 1) := by
    simpa using (Polynomial.natDegree_pow_le (p := (X : Polynomial ℝ)) (n := j - (k + 1)))
  unfold reciprocalAtom
  refine Polynomial.natDegree_mul_le.trans ((Nat.add_le_add hX (prod_succ_natDegree_le k)).trans ?_)
  omega

#print axioms reciprocalAtom_eval_inv
#print axioms reciprocalAtom_eval_zero
#print axioms reciprocalAtom_natDegree_le

end

end Nightfall.Route1ReciprocalAtom
