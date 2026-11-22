import Mathlib

/-!
# NIGHTFALL PR #1000: causal collision induction, without topology smuggling

This proves only the stagewise *algebraic* implication used in #995/#1000.
The existence of a product-sphere equivariant zero is NOT assumed as a global
axiom and is NOT proved here. Instead an explicit finite-stage annihilator
condition is a hypothesis, exactly as needed for a later honest topological
composition.

The stage policy is otherwise unrestricted; input dependence is genuinely
linear and history dependence arbitrary. Prefixes are reverse chronological.
-/

namespace Nightfall.CausalNoiseless

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- A sequence of rows selected from the actually observed history. -/
abbrev Rows (E : Type*) [NormedAddCommGroup E] [NormedSpace ℝ E] :=
  ℕ → List ℝ → E →L[ℝ] ℝ

/-- Actual noiseless intensity history. -/
def actual (rows : Rows E) (x : E) : ℕ → List ℝ
  | 0 => []
  | k + 1 =>
      let h := actual rows x k
      (((rows k h) x) ^ 2) :: h

/-- An independent virtual history determined from the candidate pair and
a coloring of each stage. U stages use v, V stages use u. -/
def virtual (rows : Rows E) (u v : E) (color : ℕ → Bool) : ℕ → List ℝ
  | 0 => []
  | k + 1 =>
      let h := virtual rows u v color k
      (if color k then (((rows k h) v) ^ 2) else (((rows k h) u) ^ 2)) :: h

/-- The explicit, stage-local annihilator condition. A later product-sphere
zero theorem has to produce these constraints; this module does not. -/
def stageZero (rows : Rows E) (u v : E) (color : ℕ → Bool) (k : ℕ) : Prop :=
  if color k then (rows k (virtual rows u v color k)) u = 0
  else (rows k (virtual rows u v color k)) v = 0

/-- Genuine-prefix causal induction: virtual histories coincide with the
two actual histories as soon as the stated annihilator equations hold. -/
theorem actual_pair_eq_virtual (rows : Rows E) (u v : E) (color : ℕ → Bool) :
    ∀ m, (∀ k, k < m → stageZero rows u v color k) →
      actual rows (u + v) m = virtual rows u v color m ∧
      actual rows (u - v) m = virtual rows u v color m := by
  intro m
  induction m with
  | zero =>
      intro _
      exact ⟨rfl, rfl⟩
  | succ k ih =>
      intro hs
      have hprev : ∀ j, j < k → stageZero rows u v color j := by
        intro j hj
        exact hs j (Nat.lt_trans hj (Nat.lt_succ_self k))
      obtain ⟨hp, hm⟩ := ih hprev
      have hk : stageZero rows u v color k := hs k (Nat.lt_succ_self k)
      by_cases hc : color k
      · have hz : (rows k (virtual rows u v color k)) u = 0 := by
          simpa [stageZero, hc] using hk
        constructor
        · simp [actual, virtual, hp, hc, map_add, hz]
        · simp [actual, virtual, hm, hc, map_sub, hz]
      · have hz : (rows k (virtual rows u v color k)) v = 0 := by
          simpa [stageZero, hc] using hk
        constructor
        · simp [actual, virtual, hp, hc, map_add, hz]
        · simp [actual, virtual, hm, hc, map_sub, hz]

/-- The exact conclusion in the original physical model (no virtual
history in the statement): two actual causal intensity transcripts agree.
This is CONDITIONAL on the displayed, explicit annihilator system. -/
theorem actual_collision_of_stage_zeros
    (rows : Rows E) (u v : E) (color : ℕ → Bool) (m : ℕ)
    (hz : ∀ k, k < m → stageZero rows u v color k) :
    actual rows (u + v) m = actual rows (u - v) m := by
  obtain ⟨hp, hm⟩ := actual_pair_eq_virtual rows u v color m hz
  exact hp.trans hm.symm

#print actual_pair_eq_virtual
#print axioms actual_pair_eq_virtual
#print actual_collision_of_stage_zeros
#print axioms actual_collision_of_stage_zeros

end Nightfall.CausalNoiseless
