import Mathlib

/-!
# Continuous sign-fiber obstruction

An exact source-independent intermediate-value lemma for the
coordinate-first squared-linear phase retrieval architecture.

The only topological dependency is Mathlib's intermediate value theorem.
No projective-space embedding assumption or externally declared axiom.
-/

namespace Nightfall.ContinuousPhaseObstruction

/-- If two continuous signed measurement contributions vanish at opposite
ends of a support-changing path and are nonzero at the other endpoints,
there is an interior collision up to sign. -/
theorem signed_contributions_cross
    (u v : ℝ → ℝ) (hu : Continuous u) (hv : Continuous v)
    (hu0 : u 0 = 0) (hv1 : v 1 = 0)
    (hv0 : v 0 ≠ 0) (hu1 : u 1 ≠ 0) :
    ∃ t : ℝ, 0 < t ∧ t < 1 ∧ (u t = v t ∨ u t = -v t) := by
  let g : ℝ → ℝ := fun t => (u t)^2 - (v t)^2
  have hg : Continuous g := (hu.pow 2).sub (hv.pow 2)
  have hg0 : g 0 < 0 := by
    dsimp [g]
    rw [hu0]
    nlinarith [sq_pos_of_ne_zero hv0]
  have hg1 : 0 < g 1 := by
    dsimp [g]
    rw [hv1]
    nlinarith [sq_pos_of_ne_zero hu1]
  have hm : (0 : ℝ) ∈ Set.Icc (g 0) (g 1) :=
    ⟨le_of_lt hg0, le_of_lt hg1⟩
  obtain ⟨t, ht, he⟩ :=
    (intermediate_value_Icc (show (0 : ℝ) ≤ 1 by norm_num)
      hg.continuousOn) hm
  have ht_ne_zero : t ≠ 0 := by
    intro hz
    subst t
    exact (ne_of_lt hg0) he
  have ht_ne_one : t ≠ 1 := by
    intro hz
    subst t
    exact (ne_of_gt hg1) he
  have ht0 : 0 < t := by
    rcases eq_or_lt_of_le ht.1 with hz | hp
    · exact False.elim (ht_ne_zero hz.symm)
    · exact hp
  have ht1 : t < 1 := by
    rcases lt_or_eq_of_le ht.2 with hp | hz
    · exact hp
    · exact False.elim (ht_ne_one hz)
  have hsquares : (u t)^2 = (v t)^2 := by
    dsimp [g] at he
    linarith
  have hmuls : u t * u t = v t * v t := by
    simpa only [pow_two] using hsquares
  exact ⟨t, ht0, ht1, (mul_self_eq_mul_self_iff).mp hmuls⟩

#print axioms Nightfall.ContinuousPhaseObstruction.signed_contributions_cross

end Nightfall.ContinuousPhaseObstruction
