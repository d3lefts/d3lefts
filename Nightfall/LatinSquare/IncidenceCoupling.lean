import Mathlib

/-!
# Finite total-variation deletion and survival budget

Independent finite algebra for the "killing a marked incidence" mechanism
in Mira Cult, "Exact uniform generation of labeled Latin squares",
source commit 30ddaaad27b48df2002225c3e3f40cffd02c5253,
paper/incidence-v2.tex.

This CERTIFIES only one-step total-variation accounting and a finite
survival-budget telescope. It does not prove the regular-board laws
obey the paper's summable total-variation estimates, nor establish
any Latin-square enumeration asymptotic.
-/

namespace Nightfall.LatinSquare

/-- A scalar overlap identity over the rationals. -/
theorem min_as_half_sum_sub_abs (a b : ℚ) :
    min a b = (a + b - |a - b|) / 2 := by
  rcases le_total a b with hab | hba
  · rw [min_eq_left hab, abs_of_nonpos (sub_nonpos.mpr hab)]
    ring
  · rw [min_eq_right hba, abs_of_nonneg (sub_nonneg.mpr hba)]
    ring

/-- Sum of the pointwise common mass, with no positivity implied. -/
def overlapMass (α : Type*) [Fintype α]
    (p q : α → ℚ) : ℚ :=
  ∑ x, min (p x) (q x)

/-- One half the finite L1 distance. -/
def totalVariationMass (α : Type*) [Fintype α]
    (p q : α → ℚ) : ℚ :=
  (∑ x, |p x - q x|) / 2

/-- The common part of two normalized finite laws has mass 1 - TV.
This is the exact algebra behind the incidence-killing loss. -/
theorem overlapMass_eq_one_sub_tv
    (α : Type*) [Fintype α] (p q : α → ℚ)
    (hp : (∑ x, p x) = 1) (hq : (∑ x, q x) = 1) :
    overlapMass α p q = 1 - totalVariationMass α p q := by
  unfold overlapMass totalVariationMass
  calc
    (∑ x, min (p x) (q x)) =
        ∑ x, (p x + q x - |p x - q x|) / 2 := by
          apply Finset.sum_congr rfl
          intro x hx
          exact min_as_half_sum_sub_abs (p x) (q x)
    _ = ((∑ x, p x) + (∑ x, q x) -
        (∑ x, |p x - q x|)) / 2 := by
          simp only [div_eq_mul_inv, ← Finset.sum_mul,
            Finset.sum_sub_distrib, Finset.sum_add_distrib]
    _ = 1 - (∑ x, |p x - q x|) / 2 := by
          rw [hp, hq]
          ring

/-- The exact amount discarded by capping normalized p at q is TV. -/
theorem killedMass_eq_totalVariation
    (α : Type*) [Fintype α] (p q : α → ℚ)
    (hp : (∑ x, p x) = 1) (hq : (∑ x, q x) = 1) :
    (∑ x, p x - min (p x) (q x)) =
      totalVariationMass α p q := by
  rw [Finset.sum_sub_distrib, hp,
      overlapMass_eq_one_sub_tv α p q hp hq]
  ring

/-- The retained mass is pointwise bounded by both input laws. -/
theorem overlap_dominated (a b : ℚ) :
    min a b ≤ a ∧ min a b ≤ b :=
  ⟨min_le_left _ _, min_le_right _ _⟩

/-- The real algorithmic cap p * min(1,q/p) is exactly min(p,q)
when the denominator law has a positive atom. -/
theorem capped_density_eq_overlap (p q : ℚ) (hp : 0 < p) :
    p * min 1 (q / p) = min p q := by
  by_cases h : p ≤ q
  · have hdiv : 1 ≤ q / p := (le_div_iff₀ hp).2 (by simpa using h)
    rw [min_eq_left hdiv, min_eq_left h]
    ring
  · have hqp : q ≤ p := le_of_lt (lt_of_not_ge h)
    have hdiv : q / p ≤ 1 := (div_le_iff₀ hp).2 (by simpa using hqp)
    rw [min_eq_right hdiv, min_eq_right hqp]
    field_simp [ne_of_gt hp]

/-- Every transition can lose a bounded amount of mass. Add the
errors instead of assuming independent survival events. -/
theorem sequential_survival_budget
    (mass err : ℕ → ℚ) (k : ℕ)
    (hstep : ∀ i < k, mass i ≤ mass (i + 1) + err i) :
    mass 0 ≤ mass k + ∑ i ∈ Finset.range k, err i := by
  induction k with
  | zero =>
      simpa
  | succ k ih =>
      have hprev : ∀ i < k, mass i ≤ mass (i + 1) + err i := by
        intro i hi
        exact hstep i (Nat.lt_trans hi (Nat.lt_succ_self k))
      have hlast := hstep k (Nat.lt_succ_self k)
      have hfirst := ih hprev
      rw [Finset.sum_range_succ]
      linarith

/-- Positive retained mass if total deleted mass stays below 1/4.
This is the generic survival step of the incidence proof. -/
theorem retained_mass_three_quarters
    (mass err : ℕ → ℚ) (k : ℕ)
    (hinitial : mass 0 = 1)
    (hstep : ∀ i < k, mass i ≤ mass (i + 1) + err i)
    (hbudget : (∑ i ∈ Finset.range k, err i) ≤ 1 / 4) :
    (3 : ℚ) / 4 ≤ mass k := by
  have h := sequential_survival_budget mass err k hstep
  rw [hinitial] at h
  linarith

#print axioms Nightfall.LatinSquare.min_as_half_sum_sub_abs
#print axioms Nightfall.LatinSquare.overlapMass_eq_one_sub_tv
#print axioms Nightfall.LatinSquare.killedMass_eq_totalVariation
#print axioms Nightfall.LatinSquare.overlap_dominated
#print axioms Nightfall.LatinSquare.capped_density_eq_overlap
#print axioms Nightfall.LatinSquare.sequential_survival_budget
#print axioms Nightfall.LatinSquare.retained_mass_three_quarters

end Nightfall.LatinSquare
