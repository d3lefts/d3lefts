import Mathlib

/-!
# Anchored multipartite analytic dependency: finite original-law range budget

This file addresses the *range/Popoviciu* half of #804 with genuine finite
original-law weights (including zero-weight atoms). A supplied value bound
is used ONLY at positive-mass endpoint configurations. The Hilbert-valued
sharp Khintchine--Kahane estimate, the chaos coefficient identities, and the
unrestricted #807 theorem are NOT proved here.

No custom axioms, \`sorry\`, or source-substitution.
-/

namespace Nightfall.CubicQ3.AnchoredRange

open Finset

/-- Popoviciu's estimate for a *centered* finitely supported source, stated
directly in original weights. Zero-weight atoms may lie outside the specified
endpoint interval, since the interval only covers positive-probability atoms.

It gives \`4 E[X²] ≤ (hi-lo)²\` under \`E[X]=0\`. -/
theorem weighted_popoviciu_centered
    {β : Type*} [Fintype β] (p h : β → ℝ) (lo hi : ℝ)
    (hp : ∀ b, 0 ≤ p b)
    (hnorm : (∑ b, p b) = 1)
    (hmean : (∑ b, p b * h b) = 0)
    (hsupport : ∀ b, 0 < p b → lo ≤ h b ∧ h b ≤ hi) :
    4 * (∑ b, p b * (h b) ^ 2) ≤ (hi - lo) ^ 2 := by
  have hpoint :
      ∀ b, p b * (h b) ^ 2 ≤
        p b * ((lo + hi) * h b - lo * hi) := by
    intro b
    by_cases hpos : 0 < p b
    · obtain ⟨hlo, hhi⟩ := hsupport b hpos
      have ha : 0 ≤ h b - lo := sub_nonneg.mpr hlo
      have hb : 0 ≤ hi - h b := sub_nonneg.mpr hhi
      have hprod : 0 ≤ p b * ((h b - lo) * (hi - h b)) :=
        mul_nonneg (le_of_lt hpos) (mul_nonneg ha hb)
      nlinarith
    · have hz : p b = 0 := le_antisymm (le_of_not_gt hpos) (hp b)
      simp [hz]
  have hsum :
      (∑ b, p b * (h b) ^ 2) ≤
        (∑ b, p b * ((lo + hi) * h b - lo * hi)) := by
    apply Finset.sum_le_sum
    intro b _
    exact hpoint b
  have hlinear :
      (∑ b, p b * ((lo + hi) * h b - lo * hi)) = -lo * hi := by
    calc
      (∑ b, p b * ((lo + hi) * h b - lo * hi)) =
          (∑ b, (lo + hi) * (p b * h b)) -
          (∑ b, (lo * hi) * p b) := by
            rw [← Finset.sum_sub_distrib]
            apply Finset.sum_congr rfl
            intro b _
            ring
      _ = (lo + hi) * (∑ b, p b * h b) -
          (lo * hi) * (∑ b, p b) := by
            rw [Finset.mul_sum, Finset.mul_sum]
      _ = -lo * hi := by
            rw [hmean, hnorm]
            ring
  rw [hlinear] at hsum
  nlinarith [sq_nonneg (lo + hi)]

/-- Exact original-law pointwise range budget for finitely many independent
anchor rows. Endpoint configurations must have positive product mass.
The proof does not assume each anchor row is scalar rank one. -/
theorem anchored_endpoint_range_budget
    {ι : Type*} [Fintype ι] {α : ι → Type*}
    [∀ i, Fintype (α i)]
    (p h : ∀ i, α i → ℝ)
    (xlo xhi : ∀ i, α i) (B : ℝ)
    (hendpoints : ∀ i, 0 < p i (xlo i) ∧ 0 < p i (xhi i))
    (hbound : ∀ x : ∀ i, α i,
      (∀ i, 0 < p i (x i)) → |∑ i, h i (x i)| ≤ B) :
    (∑ i, (h i (xhi i) - h i (xlo i))) ≤ 2 * B := by
  have hhigh : (∑ i, h i (xhi i)) ≤ B :=
    (abs_le.mp (hbound xhi (fun i => (hendpoints i).2))).2
  have hlow : -B ≤ (∑ i, h i (xlo i)) :=
    (abs_le.mp (hbound xlo (fun i => (hendpoints i).1))).1
  rw [Finset.sum_sub_distrib]
  linarith

/-- The exact original-source anchor budget of #804:
 \`Σ_i sqrt(E[h_i²]) ≤ B\`, pointwise in the external fair signs.

The source law is heterogeneous, may include zero-mass atoms, and need not
be uniform. All proof obligations are explicit and proved below except for
the premise that the sum is bounded by B on the positive-mass product support.
In #804, applying this result to each fair-sign configuration still requires
the separate sharp Hilbert Khintchine step. -/
theorem anchored_original_law_l2_budget
    {ι : Type*} [Fintype ι] {α : ι → Type*}
    [∀ i, Fintype (α i)]
    (p h : ∀ i, α i → ℝ)
    (xlo xhi : ∀ i, α i) (B : ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hnorm : ∀ i, (∑ a, p i a) = 1)
    (hcenter : ∀ i, (∑ a, p i a * h i a) = 0)
    (hendpoints : ∀ i, 0 < p i (xlo i) ∧ 0 < p i (xhi i))
    (hranges : ∀ i a, 0 < p i a →
      h i (xlo i) ≤ h i a ∧ h i a ≤ h i (xhi i))
    (hbound : ∀ x : ∀ i, α i,
      (∀ i, 0 < p i (x i)) → |∑ i, h i (x i)| ≤ B) :
    (∑ i, Real.sqrt (∑ a, p i a * (h i a) ^ 2)) ≤ B := by
  have hmom_nonneg (i : ι) :
      0 ≤ (∑ a, p i a * (h i a) ^ 2) := by
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hp i a) (sq_nonneg _)
  have hlocal (i : ι) :
      2 * Real.sqrt (∑ a, p i a * (h i a) ^ 2) ≤
        h i (xhi i) - h i (xlo i) := by
    have hpop := weighted_popoviciu_centered
      (p i) (h i) (h i (xlo i)) (h i (xhi i))
      (hp i) (hnorm i) (hcenter i) (hranges i)
    have hdelta : 0 ≤ h i (xhi i) - h i (xlo i) := by
      have hx := (hranges i (xhi i) (hendpoints i).2).1
      linarith
    have hsquare :
        (Real.sqrt (∑ a, p i a * (h i a) ^ 2)) ^ 2 =
          (∑ a, p i a * (h i a) ^ 2) :=
      Real.sq_sqrt (hmom_nonneg i)
    have hroot : 0 ≤ Real.sqrt (∑ a, p i a * (h i a) ^ 2) :=
      Real.sqrt_nonneg _
    nlinarith
  have hsum :
      (∑ i, 2 * Real.sqrt (∑ a, p i a * (h i a) ^ 2)) ≤
        (∑ i, (h i (xhi i) - h i (xlo i))) := by
    apply Finset.sum_le_sum
    intro i _
    exact hlocal i
  have hrange := anchored_endpoint_range_budget
    p h xlo xhi B hendpoints hbound
  have htwice :
      2 * (∑ i, Real.sqrt (∑ a, p i a * (h i a) ^ 2)) ≤ 2 * B := by
    calc
      _ = (∑ i, 2 * Real.sqrt (∑ a, p i a * (h i a) ^ 2)) := by
        rw [Finset.mul_sum]
      _ ≤ (∑ i, (h i (xhi i) - h i (xlo i))) := hsum
      _ ≤ 2 * B := hrange
  linarith

end Nightfall.CubicQ3.AnchoredRange
