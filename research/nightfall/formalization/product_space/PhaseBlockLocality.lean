import Mathlib

/-!
NIGHTFALL raw-oracle-to-hidden-block locality bridge.

All maps and finite interaction witnesses are arbitrary: each raw observation
depends on one hidden block and a local reading index. A term supported on
k raw positions pulls back to a term supported on at most k hidden blocks.
This is deterministic finite combinatorics, not a quantum circuit theorem
or a Route 1 simulation conclusion.
-/

namespace Nightfall.PhaseBlockLocality

variable {B J S V K : Type*} [DecidableEq B]

/-- A block-local encoding of hidden symbols into raw oracle readings. -/
def encode (read : S → J → V) (x : B → S) : (B × J) → V :=
  fun p => read (x p.1) p.2

/-- A raw term depends only on a declared finite set of raw coordinates. -/
def RawSupportedOn (R : Finset (B × J))
    (f : ((B × J) → V) → ℝ) : Prop :=
  ∀ x y, (∀ p ∈ R, x p = y p) → f x = f y

/-- A hidden-block term depends only on a declared finite set of blocks. -/
def BlockSupportedOn (T : Finset B)
    (f : (B → S) → ℝ) : Prop :=
  ∀ x y, (∀ b ∈ T, x b = y b) → f x = f y

theorem local_pullback (read : S → J → V)
    (R : Finset (B × J)) (f : ((B × J) → V) → ℝ)
    (hf : RawSupportedOn R f) :
    BlockSupportedOn (R.image Prod.fst)
      (fun x => f (encode read x)) := by
  intro x y hxy
  apply hf
  intro p hp
  exact congrArg (fun z => read z p.2)
    (hxy p.1 (Finset.mem_image.mpr ⟨p, hp, rfl⟩))

theorem pullback_support_card_le (R : Finset (B × J)) :
    (R.image Prod.fst).card ≤ R.card := by
  exact Finset.card_image_le

/-- A finite family of raw terms, each supported on at most d raw entries,
has an explicit family of hidden-block supports, each of size at most d.
The terms can depend on arbitrarily many bits within one block. -/
theorem finite_pullback_supports [Fintype K]
    (read : S → J → V)
    (terms : K → ((B × J) → V) → ℝ)
    (rawSupports : K → Finset (B × J))
    (d : ℕ)
    (hraw : ∀ k, RawSupportedOn (rawSupports k) (terms k))
    (hsize : ∀ k, (rawSupports k).card ≤ d) :
    ∃ blockSupports : K → Finset B,
      (∀ k, (blockSupports k).card ≤ d) ∧
      (∀ k, BlockSupportedOn (blockSupports k)
        (fun x => terms k (encode read x))) := by
  refine ⟨fun k => (rawSupports k).image Prod.fst, ?_, ?_⟩
  · intro k
    exact (pullback_support_card_le (rawSupports k)).trans (hsize k)
  · intro k
    exact local_pullback read (rawSupports k) (terms k) (hraw k)

#print axioms Nightfall.PhaseBlockLocality.local_pullback
#print axioms Nightfall.PhaseBlockLocality.pullback_support_card_le
#print axioms Nightfall.PhaseBlockLocality.finite_pullback_supports

end Nightfall.PhaseBlockLocality
