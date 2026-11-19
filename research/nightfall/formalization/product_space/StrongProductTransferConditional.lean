import Mathlib

/-!
# Strong product transfer: finite source-mass and deterministic-tape gates

These are actual finite-probability reductions, NOT a formalization of BDST,
coherent block-oracle compilation, or the quantum hybrid bound. They are the
last elementary probability gates in the Theorem P construction. All upstream
premises appear explicitly in the terminal theorem.
-/

namespace Nightfall.StrongProductTransferConditional

open Finset

/-- A strict additive-error failure indicator. -/
noncomputable def bad (ε a b : ℝ) : ℝ :=
  if ε < |a - b| then 1 else 0

/-- If a two-stage approximation fails, at least one half-error fails. -/
theorem bad_triangle (ε a b c : ℝ) :
    bad ε a c ≤ bad (ε / 2) a b + bad (ε / 2) b c := by
  have htri : |a - c| ≤ |a - b| + |b - c| := by
    calc
      |a - c| = |(a - b) + (b - c)| := by congr 1 <;> ring
      _ ≤ |a - b| + |b - c| := abs_add_le _ _
  by_cases h : ε < |a - c|
  · by_cases h1 : ε / 2 < |a - b|
    · by_cases h2 : ε / 2 < |b - c| <;> simp [bad, h, h1, h2]
    · have h2 : ε / 2 < |b - c| := by
        have hn : |a - b| ≤ ε / 2 := le_of_not_gt h1
        linarith
      simp [bad, h, h1, h2]
  · by_cases h1 : ε / 2 < |a - b| <;>
      by_cases h2 : ε / 2 < |b - c| <;> simp [bad, h, h1, h2]

variable {X U : Type*} [Fintype X] [Fintype U]

/-- An *actual* uniform seed marginal converts the source/seed joint
probability of the Boolean simulator's failure to its uniform-cube mass. -/
theorem uniform_seed_bad_mass
    (p : X → ℝ) (K : X → U → ℝ)
    (hU : ∀ u : U, (∑ x : X, p x * K x u) =
      1 / (Fintype.card U : ℝ))
    (g : U → X) (f : X → ℝ) (B : U → ℝ) (ε : ℝ) :
    (∑ x : X, ∑ u : U,
      p x * K x u * bad ε (f (g u)) (B u)) =
    ∑ u : U, (1 / (Fintype.card U : ℝ)) *
      bad ε (f (g u)) (B u) := by
  classical
  calc
    (∑ x : X, ∑ u : U,
        p x * K x u * bad ε (f (g u)) (B u)) =
      ∑ u : U, ∑ x : X,
        p x * K x u * bad ε (f (g u)) (B u) := Finset.sum_comm
    _ = ∑ u : U, (∑ x : X, p x * K x u) *
        bad ε (f (g u)) (B u) := by
        apply Finset.sum_congr rfl
        intro u _
        rw [Finset.sum_mul]
    _ = _ := by
      apply Finset.sum_congr rfl
      intro u _
      rw [hU u]

/-- The precise original-source two-error composition gate: given an exact
joint Markov kernel with **uniform seed marginal**, the source-to-pullback
hybrid estimate and BDST's uniform-Boolean failure estimate imply the
original-source bound. Neither estimate is assumed as an unconditional
proposition: both remain explicit inputs to this theorem. -/
theorem source_joint_failure_le
    (p : X → ℝ) (K : X → U → ℝ)
    (hp : ∀ x, 0 ≤ p x) (hK : ∀ x u, 0 ≤ K x u)
    (hU : ∀ u : U, (∑ x : X, p x * K x u) =
      1 / (Fintype.card U : ℝ))
    (g : U → X) (f : X → ℝ) (B : U → ℝ)
    (ε δ : ℝ)
    (hhybrid : (∑ x : X, ∑ u : U, p x * K x u *
       bad (ε / 2) (f x) (f (g u))) ≤ δ / 2)
    (hBDST : (∑ u : U, (1 / (Fintype.card U : ℝ)) *
       bad (ε / 2) (f (g u)) (B u)) ≤ δ / 2) :
    (∑ x : X, ∑ u : U, p x * K x u *
       bad ε (f x) (B u)) ≤ δ := by
  classical
  have hpoint (x : X) (u : U) :
      p x * K x u * bad ε (f x) (B u) ≤
      p x * K x u * bad (ε / 2) (f x) (f (g u)) +
      p x * K x u * bad (ε / 2) (f (g u)) (B u) := by
    have h := mul_le_mul_of_nonneg_left
      (bad_triangle ε (f x) (f (g u)) (B u))
      (mul_nonneg (hp x) (hK x u))
    simpa only [mul_add] using h
  have hsum :
      (∑ x : X, ∑ u : U, p x * K x u * bad ε (f x) (B u)) ≤
      (∑ x : X, ∑ u : U, p x * K x u *
          bad (ε / 2) (f x) (f (g u))) +
      (∑ x : X, ∑ u : U, p x * K x u *
          bad (ε / 2) (f (g u)) (B u)) := by
    calc
      _ ≤ ∑ x : X, ∑ u : U,
          (p x * K x u * bad (ε / 2) (f x) (f (g u)) +
           p x * K x u * bad (ε / 2) (f (g u)) (B u)) := by
             apply Finset.sum_le_sum
             intro x _
             apply Finset.sum_le_sum
             intro u _
             exact hpoint x u
      _ = _ := by simp only [Finset.sum_add_distrib]
  have hu : (∑ x : X, ∑ u : U, p x * K x u *
        bad (ε / 2) (f (g u)) (B u)) ≤ δ / 2 := by
    rw [uniform_seed_bad_mass p K hU g f B (ε / 2)]
    exact hBDST
  linarith

/-- The deterministic-tape selection gate: a finite randomized family of
whole-symbol trees with weighted average source error ≤δ contains one
fixed deterministic tree whose source error is ≤δ. The family and each
worst-case depth bound must be supplied by the external tree interpreter. -/
theorem fix_random_tape {R : Type*} [Fintype R]
    (w : R → ℝ) (hw0 : ∀ r, 0 ≤ w r)
    (hwsum : (∑ r : R, w r) = 1)
    (cost : R → ℝ) (δ : ℝ)
    (hav : (∑ r : R, w r * cost r) ≤ δ) :
    ∃ r : R, cost r ≤ δ := by
  classical
  by_contra hn
  have hlarge : ∀ r : R, δ < cost r := by
    intro r
    by_contra h
    exact hn ⟨r, le_of_not_gt h⟩
  have hex : ∃ r : R, 0 < w r := by
    by_contra hh
    push_neg at hh
    have hs : (∑ r : R, w r) ≤ 0 :=
      Finset.sum_nonpos (fun r _ => hh r)
    linarith
  obtain ⟨r0, hr0⟩ := hex
  have hpos : (0 : ℝ) < ∑ r : R, w r * (cost r - δ) := by
    apply Finset.sum_pos
    · intro r _
      exact mul_nonneg (hw0 r) (le_of_lt (sub_pos.mpr (hlarge r)))
    · exact ⟨r0, Finset.mem_univ _,
        mul_pos hr0 (sub_pos.mpr (hlarge r0))⟩
  have heq : (∑ r : R, w r * (cost r - δ)) =
      (∑ r : R, w r * cost r) - δ := by
    calc
      _ = (∑ r : R, w r * cost r) - (∑ r : R, w r * δ) := by
        simp_rw [mul_sub]
        rw [Finset.sum_sub_distrib]
      _ = (∑ r : R, w r * cost r) - δ := by
        rw [← Finset.sum_mul, hwsum, one_mul]
  rw [heq] at hpos
  linarith

end Nightfall.StrongProductTransferConditional

#print axioms Nightfall.StrongProductTransferConditional.bad_triangle
#print axioms Nightfall.StrongProductTransferConditional.uniform_seed_bad_mass
#print axioms Nightfall.StrongProductTransferConditional.source_joint_failure_le
#print axioms Nightfall.StrongProductTransferConditional.fix_random_tape

