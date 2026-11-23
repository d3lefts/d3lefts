import AffineWynerFiberCount

/-!
# NIGHTFALL — exact affine-fiber finite entropy upper bound

Reuse the exact Jensen/concavity proof shape from the existing source-verified
Route1Entropy.ent_le_log_card, with no extra import chain.
The fiber of an affine code at a fixed nonfree projection is a Cartesian
cube of free coordinates, independently proved in AffineWynerFiberCount.

This is a support-size entropy statement, NOT the full Wyner mutual
information infimum. The general C_W identity still needs the finite
mixture lower bound, attaining quotient projection, and rank arithmetic.

Exact source status: pending pinned Lean/leanchecker replay.
-/

namespace Nightfall.AffineWyner

open Finset

variable {X : Type*} [Fintype X] [DecidableEq X] [Nonempty X]

/-- Entropy of any finite probability mass is bounded by log(cardinality).
This is a direct source-exact specialization of Route1's verified theorem. -/
theorem entropy_le_log_card (p : X → ℝ)
    (hp0 : ∀ x, 0 ≤ p x) (hp1 : ∑ x, p x = 1) :
    (∑ x, negMulLog (p x)) ≤ Real.log (Fintype.card X) := by
  have hM : (0 : ℝ) < Fintype.card X := Nat.cast_pos.mpr Fintype.card_pos
  have hcon := Real.concaveOn_negMulLog.le_map_sum (t := univ)
    (w := fun _ => 1 / (Fintype.card X : ℝ)) (p := p)
    (fun _ _ => by positivity)
    (by rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp)
    (fun x _ => hp0 x)
  simp only [smul_eq_mul] at hcon
  rw [← Finset.mul_sum, ← Finset.mul_sum, hp1, mul_one] at hcon
  have hval : negMulLog (1 / (Fintype.card X : ℝ)) =
      Real.log (Fintype.card X) / Fintype.card X := by
    unfold negMulLog
    rw [one_div, Real.log_inv]
    field_simp
  rw [hval, one_div_mul_eq_div] at hcon
  exact (div_le_div_iff_of_pos_right hM).mp hcon

/-- A conditional law supported on an affine free-coordinate fiber has
entropy at most r*log q, expressed first exactly as log(q^r). -/
theorem affine_free_fiber_entropy_bound
    {ι 𝔽 : Type*} [Fintype ι] [DecidableEq ι]
    [Field 𝔽] [Fintype 𝔽] [DecidableEq 𝔽]
    (L : Submodule 𝔽 (ι → 𝔽)) (a x : ι → 𝔽)
    (hx : InAffineCode L a x)
    (p : FixedProjectionFiber L a x → ℝ)
    (hp0 : ∀ z, 0 ≤ p z) (hp1 : ∑ z, p z = 1) :
    (∑ z, negMulLog (p z)) ≤
      Real.log ((Fintype.card 𝔽) ^ Fintype.card (FreeAxis L)) := by
  classical
  letI : Nonempty (FixedProjectionFiber L a x) :=
    ⟨⟨x, hx, by intro i _; rfl⟩⟩
  have h := entropy_le_log_card p hp0 hp1
  rw [fixedProjectionFiber_card L a x hx] at h
  exact h

end Nightfall.AffineWyner

#print axioms Nightfall.AffineWyner.entropy_le_log_card
#print axioms Nightfall.AffineWyner.affine_free_fiber_entropy_bound
