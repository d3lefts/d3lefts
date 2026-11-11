import Mathlib

/-!
# Parity coupling: cancellation across distinct matching blocks

Each matching block has an independent selector bit. Passing from even to
odd coupling flips the selector for the right endpoint but not the left.
For any pair term using endpoints from distinct blocks, the two full-product
expectations agree by a measure-preserving selector flip.

This is an actual full-selector-product identity for arbitrary block counts,
not the complete theorem that matched terms are the only survivors.
-/ 

namespace Nightfall.Observability.ParityBlocks

open Finset
variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def flip (j : ι) (σ : ι → Bool) : ι → Bool :=
  fun i => if i = j then !(σ i) else σ i

theorem flip_self (j : ι) (σ : ι → Bool) : flip j σ j = !(σ j) := by
  simp [flip]

theorem flip_other {i j : ι} (hij : i ≠ j) (σ : ι → Bool) :
    flip j σ i = σ i := by
  simp [flip, hij]

theorem flip_flip (j : ι) (σ : ι → Bool) : flip j (flip j σ) = σ := by
  funext i
  by_cases h : i = j
  · subst i
    simp [flip]
  · simp [flip, h]

/-- Full independent-selector expectation is invariant under a block flip. -/
theorem sum_flip (j : ι) (G : (ι → Bool) → ℝ) :
    (∑ σ : ι → Bool, G (flip j σ)) = ∑ σ : ι → Bool, G σ := by
  classical
  apply Finset.sum_bij (fun σ _ => flip j σ)
  · intro σ _
    exact Finset.mem_univ _
  · intro σ _ τ _ h
    have hf := congrArg (flip j) h
    simpa [flip_flip] using hf
  · intro τ _
    exact ⟨flip j τ, Finset.mem_univ _, flip_flip j τ⟩
  · intro σ _
    rfl

/-- Cross-block cancellation for an arbitrary kernel with one endpoint
in block i and the other in distinct block j; no alphabet or atom premise. -/
theorem cross_block_left_right
    {A B : Type*} (left : ι → Bool → A) (right : ι → Bool → B)
    (F : A → B → ℝ) (i j : ι) (hij : i ≠ j) :
    (∑ σ : ι → Bool, F (left i (σ i)) (right j (σ j))) =
      ∑ σ : ι → Bool, F (left i (σ i)) (right j (!(σ j))) := by
  let G : (ι → Bool) → ℝ :=
    fun σ => F (left i (σ i)) (right j (!(σ j)))
  have h := sum_flip j G
  have heq : ∀ σ : ι → Bool,
      G (flip j σ) = F (left i (σ i)) (right j (σ j)) := by
    intro σ
    simp [G, flip_other hij, flip_self]
  calc
    (∑ σ : ι → Bool, F (left i (σ i)) (right j (σ j))) =
        ∑ σ : ι → Bool, G (flip j σ) := by
          apply Finset.sum_congr rfl
          intro σ _
          exact (heq σ).symm
    _ = ∑ σ : ι → Bool, G σ := h
    _ = ∑ σ : ι → Bool,
          F (left i (σ i)) (right j (!(σ j))) := rfl

/-- The right coordinate has equal one-variable marginal under both parities. -/
theorem right_marginal
    {B : Type*} (right : ι → Bool → B) (G : B → ℝ) (j : ι) :
    (∑ σ : ι → Bool, G (right j (σ j))) =
      ∑ σ : ι → Bool, G (right j (!(σ j))) := by
  let H : (ι → Bool) → ℝ := fun σ => G (right j (!(σ j)))
  have h := sum_flip j H
  calc
    (∑ σ : ι → Bool, G (right j (σ j))) =
        ∑ σ : ι → Bool, H (flip j σ) := by
          apply Finset.sum_congr rfl
          intro σ _
          simp [H, flip_self]
    _ = ∑ σ : ι → Bool, H σ := h
    _ = _ := rfl

end Nightfall.Observability.ParityBlocks
