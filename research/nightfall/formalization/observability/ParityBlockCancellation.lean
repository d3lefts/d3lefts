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


/-- Reverse endpoint orientation: the right coordinate of one block and
left coordinate of another retain their joint law under parity switch. -/
theorem cross_block_right_left
    {A B : Type*} (right : ι → Bool → A) (left : ι → Bool → B)
    (F : A → B → ℝ) (i j : ι) (hij : i ≠ j) :
    (∑ σ : ι → Bool, F (right i (σ i)) (left j (σ j))) =
      ∑ σ : ι → Bool, F (right i (!(σ i))) (left j (σ j)) := by
  simpa only using
    (cross_block_left_right left right (fun b a => F a b) j i hij.symm)

/-- Both endpoints right-handed: independently flip selectors in the two
distinct matching blocks, preserving all cross-block pair expectations. -/
theorem cross_block_right_right
    {A B : Type*} (rightA : ι → Bool → A) (rightB : ι → Bool → B)
    (F : A → B → ℝ) (i j : ι) (hij : i ≠ j) :
    (∑ σ : ι → Bool, F (rightA i (σ i)) (rightB j (σ j))) =
      ∑ σ : ι → Bool, F (rightA i (!(σ i))) (rightB j (!(σ j))) := by
  let G : (ι → Bool) → ℝ :=
    fun σ => F (rightA i (!(σ i))) (rightB j (σ j))
  have hg := sum_flip i G
  have hi : (∑ σ : ι → Bool, F (rightA i (σ i)) (rightB j (σ j))) =
      ∑ σ : ι → Bool, G σ := by
    calc
      (∑ σ : ι → Bool, F (rightA i (σ i)) (rightB j (σ j))) =
          ∑ σ : ι → Bool, G (flip i σ) := by
            apply Finset.sum_congr rfl
            intro σ _
            simp [G, flip_self, flip_other hij.symm]
      _ = ∑ σ : ι → Bool, G σ := hg
  have hj := cross_block_left_right
    (fun k b => rightA k (!b)) rightB F i j hij
  calc
    (∑ σ : ι → Bool, F (rightA i (σ i)) (rightB j (σ j))) =
       ∑ σ : ι → Bool, G σ := hi
    _ = ∑ σ : ι → Bool, F (rightA i (!(σ i))) (rightB j (!(σ j))) := hj

/-- All four endpoint-side combinations between distinct blocks have
identical even/odd selector expectations. -/
theorem cross_block_all_sides
    {A B : Type*}
    (leftA rightA : ι → Bool → A)
    (leftB rightB : ι → Bool → B)
    (F : A → B → ℝ) (i j : ι) (hij : i ≠ j)
    (si sj : Bool) :
    (∑ σ : ι → Bool,
        F (if si then rightA i (σ i) else leftA i (σ i))
          (if sj then rightB j (σ j) else leftB j (σ j))) =
      (∑ σ : ι → Bool,
        F (if si then rightA i (!(σ i)) else leftA i (σ i))
          (if sj then rightB j (!(σ j)) else leftB j (σ j))) := by
  cases si <;> cases sj
  · rfl
  · simpa using
      (cross_block_left_right leftA rightB F i j hij)
  · simpa using
      (cross_block_right_left rightA leftB F i j hij)
  · simpa using
      (cross_block_right_right rightA rightB F i j hij)

end Nightfall.Observability.ParityBlocks
