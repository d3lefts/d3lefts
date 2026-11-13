import ActualESQuadraticRectangles
import QuadraticHybridTelescoping

/-!
# Actual degree-two Efron–Stein sources: parity on packed matching blocks

The full finite source is indexed by β × Bool. Every β-block is a disjoint
pair; there are no unpaired coordinates in this module. The only mathematical
premises for the parity theorem are normalized product marginals and
ESDegreeLE p f 2. In particular no block polynomial, parity identity,
rectangle-invariance, or matching mass is assumed.

This is a *packed-matching* source theorem. Reindexing an arbitrary matching
inside a larger coordinate set, identifying supported amplitude witnesses,
and the greedy source-energy interface are separate obligations.
-/

namespace Nightfall.Observability.ActualESPackedParity

open Finset Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.ActualESQuadraticRectangles
open Nightfall.Observability.QuadraticHybridTelescoping

variable {β α : Type} [Fintype β] [DecidableEq β]
  [Fintype α] [DecidableEq α]

/-- A paired-block replacement is literally two consecutive updates of
the original source function, not a synthetic block polynomial. -/
theorem blockReplace_eq_source_updates
    (x : β × Bool → α) (e : β) (a b : α) :
    blockReplace x e a b =
      Function.update (Function.update x (e, false) a) (e, true) b := by
  funext k
  rcases k with ⟨k, s⟩
  by_cases hk : k = e
  · subst k
    cases s <;> simp [blockReplace, Function.update]
  · cases s <;> simp [blockReplace, Function.update, hk]

/-- The concrete hybrid four-corner expression equals the canonical
source-function rectangle on the two real coordinates. -/
theorem blockRectangle_eq_sourceRectangle
    (f : (β × Bool → α) → ℝ)
    (x : β × Bool → α) (e : β)
    (a0 a1 b0 b1 : α) :
    blockRectangle f x e a0 a1 b0 b1 =
      sourceRectangle f x (e, false) (e, true)
        a0 a1 b0 b1 := by
  unfold blockRectangle sourceRectangle
  simp only [blockReplace_eq_source_updates]

/-- The full selector-product parity identity for a *genuine* degree-two
source. The background-invariance premise of the hybrid telescope is
discharged using the actual Efron–Stein decomposition. -/
theorem actual_source_global_packed_parity
    (p : β × Bool → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (β × Bool → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : β × Bool → α)
    (left right : β → Bool → α) :
    2 * (hybridTotal f left right ∅ -
      hybridTotal f left right univ) =
    (Fintype.card (β → Bool) : ℝ) *
      (∑ e : β, sourceRectangle f base
        (e, false) (e, true)
        (left e false) (left e true)
        (right e false) (right e true)) := by
  let d : β → ℝ := fun e =>
    sourceRectangle f base (e, false) (e, true)
      (left e false) (left e true)
      (right e false) (right e true)
  have hrect : ∀ e x,
      blockRectangle f x e
        (left e false) (left e true)
        (right e false) (right e true) = d e := by
    intro e x
    rw [blockRectangle_eq_sourceRectangle]
    exact actual_quadratic_rectangle_base_independent
      p hp1 f hdegree
      (e, false) (e, true) (by simp)
      x base
      (left e false) (left e true)
      (right e false) (right e true)
  simpa only [d] using
    (hybrid_global_parity_telescope f left right d hrect)

/-- Actual-source global 4B rectangle budget for a fully packed
matching. Neither the parity identity nor the 4B budget is a premise.
The bound is pointwise on the finite supported alphabet being modelled.
-/
theorem actual_source_packed_rectangles_le_four
    (p : β × Bool → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (β × Bool → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : β × Bool → α)
    (left right : β → Bool → α)
    (B : ℝ)
    (hf : ∀ x, |f x| ≤ B) :
    (∑ e : β, sourceRectangle f base (e, false) (e, true)
      (left e false) (left e true)
      (right e false) (right e true)) ≤ 4 * B := by
  classical
  let N : ℝ := Fintype.card (β → Bool)
  have hN : 0 < N := by
    dsimp [N]
    exact_mod_cast
      (Fintype.card_pos_iff.mpr
        ⟨fun (_ : β) => false⟩ : 0 < Fintype.card (β → Bool))
  have he : hybridTotal f left right ∅ ≤ N * B := by
    calc
      hybridTotal f left right ∅ =
          ∑ σ : β → Bool, f (hybridState left right ∅ σ) := rfl
      _ ≤ ∑ _σ : β → Bool, B := by
        apply Finset.sum_le_sum
        intro σ _
        exact (abs_le.mp (hf _)).2
      _ = N * B := by simp [N]
  have ho : -(N * B) ≤ hybridTotal f left right univ := by
    calc
      -(N * B) = ∑ _σ : β → Bool, -B := by simp [N, mul_neg]
      _ ≤ ∑ σ : β → Bool, f (hybridState left right univ σ) := by
        apply Finset.sum_le_sum
        intro σ _
        exact (abs_le.mp (hf _)).1
      _ = hybridTotal f left right univ := rfl
  have hpar := actual_source_global_packed_parity
    p hp1 f hdegree base left right
  have hmul :
      N * (∑ e : β, sourceRectangle f base (e, false) (e, true)
        (left e false) (left e true)
        (right e false) (right e true)) ≤ N * (4 * B) := by
    dsimp [N] at *
    nlinarith [hpar, he, ho]
  by_contra hn
  have hs : 4 * B <
      ∑ e : β, sourceRectangle f base (e, false) (e, true)
        (left e false) (left e true)
        (right e false) (right e true) := lt_of_not_ge hn
  have hp : 0 < N *
      ((∑ e : β, sourceRectangle f base (e, false) (e, true)
        (left e false) (left e true)
        (right e false) (right e true)) - 4 * B) :=
    mul_pos hN (sub_pos.mpr hs)
  nlinarith [hmul, hp]

end Nightfall.Observability.ActualESPackedParity
