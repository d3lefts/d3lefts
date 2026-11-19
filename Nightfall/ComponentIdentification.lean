import Mathlib

/-!
# Component identification: finite real-arithmetic reductions

Draft Lean source for the finite Step 3/Step 4 testing reduction and the
pointwise Hellinger comparison in Step 5.

**Not yet kernel-checked.** This source is intentionally not imported into
`Nightfall.lean`. The analytic Bernstein interpolation inequality and the
product Bhattacharyya tensorization bound remain separate named obligations.
No `sorry` or new axioms are introduced here.

Source: research/nightfall/strong_simulation_progress/
  COMPONENT_IDENTIFICATION_20261119.md
Audit: research/nightfall/strong_simulation_progress/
  INDEPENDENT_AUDIT_20261119.md
-/

namespace Nightfall.ComponentIdentification

/-- Step 3: two bounded conditional mean deviations and a small-gap shift
bound force separation to be paid by conditional failure masses.
The underlying expectations -> deviation estimates are obligations of the
probabilistic interface. -/
theorem separation_paid_by_failures
    (u v mp mq ε failureP failureQ : ℝ)
    (hp : |u - mp| ≤ ε + failureP)
    (hq : |mq - v| ≤ ε + failureQ)
    (hshift : |mp - mq| ≤ ε) :
    |u - v| ≤ 3 * ε + failureP + failureQ := by
  have htriangle : |u - v| ≤ |u - mp| + |mp - mq| + |mq - v| := by
    calc
      |u - v| = |(u - mp) + ((mp - mq) + (mq - v))| := by
        congr 1
        ring
      _ ≤ |u - mp| + |(mp - mq) + (mq - v)| := abs_add_le _ _
      _ ≤ |u - mp| + (|mp - mq| + |mq - v|) :=
        add_le_add_left (abs_add_le _ _) _
      _ = |u - mp| + |mp - mq| + |mq - v| := by ring
  linarith

/-- Step 4: the weighted overlap is controlled by the two weighted failure
masses. This theorem makes no probability-normalization assumptions and is
valid for any finite index type. -/
theorem weighted_overlap
    {Ω : Type*} [Fintype Ω]
    (p q failureP failureQ : Ω → ℝ) (Δ : ℝ)
    (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 ≤ q x)
    (hfP : ∀ x, 0 ≤ failureP x) (hfQ : ∀ x, 0 ≤ failureQ x)
    (hpoint : ∀ x, Δ ≤ failureP x + failureQ x) :
    Δ * (∑ x : Ω, min (p x) (q x)) ≤
      (∑ x : Ω, p x * failureP x) +
      (∑ x : Ω, q x * failureQ x) := by
  have hterm : ∀ x : Ω,
      min (p x) (q x) * Δ ≤
        p x * failureP x + q x * failureQ x := by
    intro x
    calc
      min (p x) (q x) * Δ
          ≤ min (p x) (q x) * (failureP x + failureQ x) :=
              mul_le_mul_of_nonneg_left (hpoint x) (le_min (hp x) (hq x))
      _ = min (p x) (q x) * failureP x +
            min (p x) (q x) * failureQ x := by ring
      _ ≤ p x * failureP x + q x * failureQ x := by
        apply add_le_add
        · exact mul_le_mul_of_nonneg_right (min_le_left _ _) (hfP x)
        · exact mul_le_mul_of_nonneg_right (min_le_right _ _) (hfQ x)
  calc
    Δ * (∑ x : Ω, min (p x) (q x))
        = (∑ x : Ω, min (p x) (q x)) * Δ := mul_comm _ _
    _ = ∑ x : Ω, min (p x) (q x) * Δ := by rw [Finset.sum_mul]
    _ ≤ ∑ x : Ω, (p x * failureP x + q x * failureQ x) :=
      Finset.sum_le_sum (fun x _ => hterm x)
    _ = (∑ x : Ω, p x * failureP x) +
          (∑ x : Ω, q x * failureQ x) := by rw [Finset.sum_add_distrib]

/-- The Step 4 numerical error bound. -/
theorem overlap_le_failure_budget
    (overlap Δ δP δQ : ℝ)
    (hΔ : 0 < Δ)
    (hbudget : Δ * overlap ≤ δP + δQ) :
    overlap ≤ (δP + δQ) / Δ := by
  apply (le_div_iff₀ hΔ).2
  nlinarith

/-- Step 5 (pointwise): elementary comparison of overlap to
Bhattacharyya affinity, without any distribution assumptions beyond
nonnegativity. -/
theorem min_le_sqrt_product (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    min a b ≤ Real.sqrt (a * b) := by
  have hm : 0 ≤ a * b := mul_nonneg ha hb
  have hs : 0 ≤ Real.sqrt (a * b) := Real.sqrt_nonneg _
  have hsq : (Real.sqrt (a * b)) ^ 2 = a * b := Real.sq_sqrt hm
  rcases le_total a b with hab | hba
  · rw [min_eq_left hab]
    have hh : 0 ≤ a * (b - a) := mul_nonneg ha (sub_nonneg.mpr hab)
    nlinarith
  · rw [min_eq_right hba]
    have hh : 0 ≤ b * (a - b) := mul_nonneg hb (sub_nonneg.mpr hba)
    nlinarith

/-- Step 5: finite overlap is bounded by finite Bhattacharyya affinity.
Product factorization and exponential decay are the remaining separate
Bernstein/Hellinger interface obligations. -/
theorem overlap_le_affinity
    {Ω : Type*} [Fintype Ω]
    (p q : Ω → ℝ)
    (hp : ∀ x, 0 ≤ p x) (hq : ∀ x, 0 ≤ q x) :
    (∑ x : Ω, min (p x) (q x)) ≤
      ∑ x : Ω, Real.sqrt (p x * q x) := by
  apply Finset.sum_le_sum
  intro x _
  exact min_le_sqrt_product (p x) (q x) (hp x) (hq x)

end Nightfall.ComponentIdentification
