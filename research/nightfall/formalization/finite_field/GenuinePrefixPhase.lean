import Mathlib

/-!
# Genuine-prefix phase retrieval: causal algebra

This module checks the causal part of PR #997. It does not formalize
the product-sphere or Stiefel zero theorem. A common zero is an explicit
premise, and no global extension of a selector is used by the proof.
A reverse chronological prefix is equivalent to the chronological
one up to a fixed coordinate permutation.
-/

namespace Nightfall.GenuinePrefixPhase

variable {V : Type*} [AddCommGroup V]

/-- A deterministic amplitude oracle. Its first argument is the reverse prefix. -/
abbrev Oracle (V : Type*) := List ℝ → V → ℝ

def transcript (a : Oracle V) : ℕ → V → List ℝ
  | 0, _ => []
  | j + 1, x =>
    let h := transcript a j x
    (a h x)^2 :: h

def comparison (a : Oracle V) (j : ℕ) (u v w : V) : ℝ :=
  a (transcript a j (u + v)) w + a (transcript a j (u - v)) w

theorem transcript_neg (a : Oracle V)
    (hneg : ∀ h x, a h (-x) = -a h x) (x : V) (m : ℕ) :
    transcript a m (-x) = transcript a m x := by
  induction m with
  | zero => rfl
  | succ j ih =>
    simp only [transcript, ih, hneg, neg_sq]

theorem comparison_flip_right (a : Oracle V) (j : ℕ) (u v w : V) :
    comparison a j u (-v) w = comparison a j u v w := by
  unfold comparison
  rw [← sub_eq_add_neg u v, sub_neg_eq_add]
  exact add_comm _ _

theorem comparison_flip_left (a : Oracle V)
    (hneg : ∀ h x, a h (-x) = -a h x) (j : ℕ) (u v w : V) :
    comparison a j (-u) v w = comparison a j u v w := by
  have h1 : -u + v = -(u - v) := by abel
  have h2 : -u - v = -(u + v) := by abel
  unfold comparison
  rw [h1, h2, transcript_neg a hneg, transcript_neg a hneg]
  exact add_comm _ _

/-- At a joint zero, genuine histories coincide at every causal step. -/
theorem causal_collision_of_genuine_prefix_zeros (a : Oracle V)
    (hadd : ∀ h x y, a h (x + y) = a h x + a h y)
    (hsub : ∀ h x y, a h (x - y) = a h x - a h y)
    (u v : V) (m : ℕ)
    (hz : ∀ j < m, comparison a j u v u = 0 ∨ comparison a j u v v = 0) :
    transcript a m (u + v) = transcript a m (u - v) := by
  induction m with
  | zero => rfl
  | succ j ih =>
    have hp := ih (fun i hi => hz i (by omega))
    have hcz := hz j (by omega)
    simp only [comparison, hp] at hcz
    let p := transcript a j (u - v)
    have hs : a p u = 0 ∨ a p v = 0 := by
      rcases hcz with h | h
      · left
        change a p u + a p u = 0 at h
        linarith
      · right
        change a p v + a p v = 0 at h
        linarith
    have hr : (a p (u + v))^2 = (a p (u - v))^2 := by
      rw [hadd, hsub]
      rcases hs with h | h
      · rw [h]
        ring
      · rw [h]
        ring
    simp only [transcript, hp]
    exact congrArg (fun z : ℝ => z :: p) hr

/-- Equal retained readings and equal totals determine the omitted reading. -/
theorem omitted_intensity_eq (a b tailA tailB : ℝ)
    (htail : tailA = tailB) (htotal : a + tailA = b + tailB) :
    a = b := by linarith

#print axioms transcript_neg
#print axioms comparison_flip_right
#print axioms comparison_flip_left
#print axioms causal_collision_of_genuine_prefix_zeros
#print axioms omitted_intensity_eq

end Nightfall.GenuinePrefixPhase
