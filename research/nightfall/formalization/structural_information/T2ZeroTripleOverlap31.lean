import Mathlib

/-!
# Two-query zero-triple survivor identities: scoped certification

The paper-level T2 operator estimate reduces to a four-position overlap
identity. This module certifies its algebraic survivor equations in any
commutative additive group, the exponent-two three-survivor obstruction,
and the exact coefficient-31 arithmetic. It does **not** establish the
Hilbert-space frame inequalities or the full quantum simulator.
-/

namespace Nightfall.StructuralInformation.T2ZeroTripleOverlap

/-- When the other three slots sum to zero, the survivor is the total
four-slot frequency. No exponent-two hypothesis is required. -/
theorem survivor_is_total {G : Type*} [AddCommGroup G]
    (a b c d : G) (hz : b + c + d = 0) :
    a + b + c + d = a := by
  calc
    a + b + c + d = a + (b + c + d) := by abel
    _ = a := by rw [hz, add_zero]

/-- Two different zero-triple choices must have equal survivors. -/
theorem two_zero_triple_survivors_equal
    {G : Type*} [AddCommGroup G]
    (a b c d : G)
    (ha : b + c + d = 0)
    (hb : a + c + d = 0) : a = b := by
  have hA : a + b + c + d = a :=
    survivor_is_total a b c d ha
  have hB : a + b + c + d = b := by
    calc
      a + b + c + d = b + (a + c + d) := by abel
      _ = b := by rw [hb, add_zero]
  exact hA.symm.trans hB

/-- Three extended zero triples force the fourth label to be zero in
characteristic two, so on an all-nonzero label family there can be
at most two extended survivor positions. -/
theorem three_survivors_force_fourth_zero
    {G : Type*} [AddCommGroup G]
    (h₂ : ∀ x : G, x + x = 0)
    (a b c d : G)
    (ha : b + c + d = 0)
    (hb : a + c + d = 0)
    (hc : a + b + d = 0) : d = 0 := by
  have hab : a = b :=
    two_zero_triple_survivors_equal a b c d ha hb
  have hA : a + b + c + d = a :=
    survivor_is_total a b c d ha
  have hC : a + b + c + d = c := by
    calc
      a + b + c + d = c + (a + b + d) := by abel
      _ = c := by rw [hc, add_zero]
  have hac : a = c := hA.symm.trans hC
  rw [← hab, ← hac] at ha
  simpa [h₂ a] using ha

/-- A source-exact rational certificate: √2≤3/2, √6≤5/2,
hence 12+6√2+4√6≤31. The separate Hilbert bounds are NOT
assumed or established here. -/
theorem pair_energy_coefficient_le_31 :
    12 + 6 * Real.sqrt 2 + 4 * Real.sqrt 6 ≤ (31 : ℝ) := by
  have hs₂ : Real.sqrt (2 : ℝ) ≤ (3 / 2 : ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2),
      Real.sqrt_nonneg (2 : ℝ)]
  have hs₆ : Real.sqrt (6 : ℝ) ≤ (5 / 2 : ℝ) := by
    nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 6),
      Real.sqrt_nonneg (6 : ℝ)]
  nlinarith

#print axioms Nightfall.StructuralInformation.T2ZeroTripleOverlap.survivor_is_total
#print axioms Nightfall.StructuralInformation.T2ZeroTripleOverlap.two_zero_triple_survivors_equal
#print axioms Nightfall.StructuralInformation.T2ZeroTripleOverlap.three_survivors_force_fourth_zero
#print axioms Nightfall.StructuralInformation.T2ZeroTripleOverlap.pair_energy_coefficient_le_31

end Nightfall.StructuralInformation.T2ZeroTripleOverlap
