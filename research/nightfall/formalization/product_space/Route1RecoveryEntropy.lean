import Mathlib
import Route1StaticObstruction

/-! Source-level proof candidates for the missing binary recovery range and
support entropy bridges. The actual tree query count is used, not a
caller-supplied cardinality bound. -/
open Finset Real
namespace Nightfall.Route1RecoveryEntropy

inductive BinaryRecovery (I A : Type*) where
  | leaf (a : A)
  | node (i : I) (next : Bool → BinaryRecovery I A)

namespace BinaryRecovery
variable {I A : Type*}

def eval : BinaryRecovery I A → (I → Bool) → A
  | .leaf a, _ => a
  | .node i next, x => eval (next (x i)) x

def queries : BinaryRecovery I A → (I → Bool) → ℕ
  | .leaf _, _ => 0
  | .node i next, x => queries (next (x i)) x + 1

/-- Only reachable inputs are charged. Arbitrarily deep unreachable branches
are permitted. Every depth-r binary decoder has at most 2^r distinct outputs. -/
theorem image_card_le [DecidableEq A] (t : BinaryRecovery I A)
    (S : Finset (I → Bool)) (r : ℕ)
    (h : ∀ x ∈ S, t.queries x ≤ r) :
    (S.image t.eval).card ≤ 2 ^ r := by
  classical
  induction t generalizing S r with
  | leaf a =>
      have hs : S.image (BinaryRecovery.leaf a).eval ⊆ {a} := by
        intro y hy
        obtain ⟨x, _, rfl⟩ := Finset.mem_image.mp hy
        simp [eval]
      exact (Finset.card_le_card hs).trans (by
        simp only [Finset.card_singleton]
        have hp : 0 < (2 : ℕ) ^ r := by positivity
        omega)
  | node i next ih =>
      cases r with
      | zero =>
          have he : S = ∅ := by
            apply Finset.eq_empty_iff_forall_notMem.mpr
            intro x hx
            have hh := h x hx
            simp [queries] at hh
          simp [he]
      | succ r =>
          let S0 := S.filter (fun x => x i = false)
          let S1 := S.filter (fun x => x i = true)
          have h0 : ∀ x ∈ S0, (next false).queries x ≤ r := by
            intro x hx
            have hh := h x (Finset.mem_filter.mp hx).1
            have he := (Finset.mem_filter.mp hx).2
            simp [queries, he] at hh
            exact hh
          have h1 : ∀ x ∈ S1, (next true).queries x ≤ r := by
            intro x hx
            have hh := h x (Finset.mem_filter.mp hx).1
            have he := (Finset.mem_filter.mp hx).2
            simp [queries, he] at hh
            exact hh
          have hs : S.image (BinaryRecovery.node i next).eval ⊆
              (S0.image (next false).eval) ∪ (S1.image (next true).eval) := by
            intro y hy
            obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hy
            cases he : x i with
            | false =>
                apply Finset.mem_union.mpr
                left
                exact Finset.mem_image.mpr ⟨x, Finset.mem_filter.mpr ⟨hx, he⟩, by simp [eval, he]⟩
            | true =>
                apply Finset.mem_union.mpr
                right
                exact Finset.mem_image.mpr ⟨x, Finset.mem_filter.mpr ⟨hx, he⟩, by simp [eval, he]⟩
          calc
            _ ≤ ((S0.image (next false).eval) ∪ (S1.image (next true).eval)).card :=
              Finset.card_le_card hs
            _ ≤ (S0.image (next false).eval).card + (S1.image (next true).eval).card :=
              Finset.card_union_le _ _
            _ ≤ 2 ^ r + 2 ^ r := Nat.add_le_add (ih false S0 r h0) (ih true S1 r h1)
            _ = 2 ^ (r + 1) := by rw [pow_succ]; omega

end BinaryRecovery

/-- Entropy of a normalized law on an actual finite nonempty support. -/
theorem support_entropy_le {X : Type*} [DecidableEq X] (S : Finset X)
    (hS : S.Nonempty) (p : X → ℝ) (hp0 : ∀ x ∈ S, 0 ≤ p x)
    (hp1 : ∑ x ∈ S, p x = 1) :
    ∑ x ∈ S, negMulLog (p x) ≤ Real.log (S.card : ℝ) := by
  have hM : (0 : ℝ) < S.card := Nat.cast_pos.mpr (Finset.card_pos.mpr hS)
  have hcon := Real.concaveOn_negMulLog.le_map_sum (t := S)
    (w := fun _ => 1 / (S.card : ℝ)) (p := p)
    (fun _ _ => by positivity)
    (by rw [Finset.sum_const, nsmul_eq_mul]; field_simp)
    hp0
  simp only [smul_eq_mul] at hcon
  rw [← Finset.mul_sum, ← Finset.mul_sum, hp1, mul_one] at hcon
  have hval : negMulLog (1 / (S.card : ℝ)) =
      Real.log (S.card : ℝ) / S.card := by
    unfold negMulLog
    rw [one_div, Real.log_inv]
    field_simp
  rw [hval, one_div_mul_eq_div] at hcon
  exact (div_le_div_iff_of_pos_right hM).mp hcon

/-- Entropy range bridge for any binary recovery tree, using the actual
reachable range and the entropy bound on that range. -/
theorem recovery_entropy_le {I A : Type*} [DecidableEq A]
    (t : BinaryRecovery I A) (S : Finset (I → Bool)) (hS : S.Nonempty)
    (r : ℕ) (h : ∀ x ∈ S, t.queries x ≤ r)
    (p : A → ℝ) (hp0 : ∀ a ∈ S.image t.eval, 0 ≤ p a)
    (hp1 : ∑ a ∈ S.image t.eval, p a = 1) :
    ∑ a ∈ S.image t.eval, negMulLog (p a) ≤ (r : ℝ) * Real.log 2 := by
  classical
  have hT : (S.image t.eval).Nonempty := hS.image _
  have hcard := BinaryRecovery.image_card_le t S r h
  have hpos : (0 : ℝ) < (S.image t.eval).card :=
    Nat.cast_pos.mpr (Finset.card_pos.mpr hT)
  have hcast : ((S.image t.eval).card : ℝ) ≤ (2 : ℝ) ^ r := by exact_mod_cast hcard
  calc
    _ ≤ Real.log ((S.image t.eval).card : ℝ) := support_entropy_le _ hT p hp0 hp1
    _ ≤ Real.log ((2 : ℝ) ^ r) := Real.log_le_log hpos hcast
    _ = _ := by rw [Real.log_pow]

end Nightfall.Route1RecoveryEntropy

#print axioms Nightfall.Route1RecoveryEntropy.BinaryRecovery.image_card_le
#print axioms Nightfall.Route1RecoveryEntropy.support_entropy_le
#print axioms Nightfall.Route1RecoveryEntropy.recovery_entropy_le
