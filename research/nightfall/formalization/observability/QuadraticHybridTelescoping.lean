import ParityBlockCancellation

/-!
# Global hybrid-coupling telescope

Finite matching blocks are indexed by β, with two disjoint coordinates
(β × Bool) per block. For a full source f on the product of these
coordinates, switching each independently sampled block from even
to odd creates an exact sum of four-point rectangles whenever its
within-block rectangle is independent of all background coordinates.

The latter is an *explicit* hypothesis in this standalone finite
algebra module; the actual Efron-Stein degree-two source theorem
proves that invariance separately in ActualESQuadraticRectangles.lean.
The reindexing of a matching in arbitrary ι with unmatched sites
is a further representation obligation. No Q2 claim is made.
-/

namespace Nightfall.Observability.QuadraticHybridTelescoping

open Finset
open Nightfall.Observability.ParityBlocks

variable {β α : Type*} [Fintype β] [DecidableEq β]

/-- One point in the two-coordinate alphabet for every matching block. -/
def hybridState
    (left right : β → Bool → α) (T : Finset β)
    (σ : β → Bool) : β × Bool → α :=
  fun k => if k.2 then
    right k.1 (if k.1 ∈ T then !(σ k.1) else σ k.1)
    else left k.1 (σ k.1)

/-- Replace the two coordinates of just one matching block. -/
def blockReplace (x : β × Bool → α) (e : β) (a b : α) :
    β × Bool → α :=
  fun k => if k.1 = e then (if k.2 then b else a) else x k

/-- Four-point mixed rectangle at one matching block. -/
noncomputable def blockRectangle (f : (β × Bool → α) → ℝ)
    (x : β × Bool → α) (e : β)
    (a0 a1 b0 b1 : α) : ℝ :=
  f (blockReplace x e a0 b0) -
  f (blockReplace x e a0 b1) -
  f (blockReplace x e a1 b0) +
  f (blockReplace x e a1 b1)

/-- Selector sum for one independently sampled hybrid coupling. -/
noncomputable def hybridTotal
    (f : (β × Bool → α) → ℝ)
    (left right : β → Bool → α) (T : Finset β) : ℝ :=
  ∑ σ : β → Bool, f (hybridState left right T σ)

private theorem hybrid_even_as_block
    (left right : β → Bool → α) (T : Finset β)
    (e : β) (he : e ∉ T) (σ : β → Bool) :
    hybridState left right T σ =
      blockReplace (hybridState left right T σ) e
        (left e (σ e)) (right e (σ e)) := by
  funext ⟨k,s⟩
  by_cases hk : k = e
  · subst k
    cases s <;> simp [hybridState, blockReplace, he]
  · cases s <;> simp [hybridState, blockReplace, hk]

private theorem hybrid_odd_as_block
    (left right : β → Bool → α) (T : Finset β)
    (e : β) (he : e ∉ T) (σ : β → Bool) :
    hybridState left right (insert e T) σ =
      blockReplace (hybridState left right T σ) e
        (left e (σ e)) (right e (!(σ e))) := by
  funext ⟨k,s⟩
  by_cases hk : k = e
  · subst k
    cases s <;> simp [hybridState, blockReplace, he]
  · cases s <;> simp [hybridState, blockReplace, hk]

private theorem hybrid_even_flip_as_block
    (left right : β → Bool → α) (T : Finset β)
    (e : β) (he : e ∉ T) (σ : β → Bool) :
    hybridState left right T (flip e σ) =
      blockReplace (hybridState left right T σ) e
        (left e (!(σ e))) (right e (!(σ e))) := by
  funext ⟨k,s⟩
  by_cases hk : k = e
  · subst k
    cases s <;> simp [hybridState, blockReplace, flip, he]
  · cases s <;> simp [hybridState, blockReplace, flip, hk]

private theorem hybrid_odd_flip_as_block
    (left right : β → Bool → α) (T : Finset β)
    (e : β) (he : e ∉ T) (σ : β → Bool) :
    hybridState left right (insert e T) (flip e σ) =
      blockReplace (hybridState left right T σ) e
        (left e (!(σ e))) (right e (σ e)) := by
  funext ⟨k,s⟩
  by_cases hk : k = e
  · subst k
    cases s <;> simp [hybridState, blockReplace, flip, he]
  · cases s <;> simp [hybridState, blockReplace, flip, hk]

/-- Exactly one matching-block parity switch has half the oriented
four-corner rectangle as its expectation change, provided the
rectangle's value is independent of background coordinates.
No quadratic representation is assumed here. -/
theorem hybrid_single_block_difference
    (f : (β × Bool → α) → ℝ)
    (left right : β → Bool → α)
    (d : β → ℝ)
    (hrect : ∀ e x,
      blockRectangle f x e
        (left e false) (left e true)
        (right e false) (right e true) = d e)
    (T : Finset β) (e : β) (he : e ∉ T) :
    2 * (hybridTotal f left right T -
          hybridTotal f left right (insert e T)) =
      (Fintype.card (β → Bool) : ℝ) * d e := by
  let D : (β → Bool) → ℝ := fun σ =>
    f (hybridState left right T σ) -
    f (hybridState left right (insert e T) σ)
  have hpoint (σ : β → Bool) :
      D σ + D (flip e σ) = d e := by
    let x := hybridState left right T σ
    have h1 := hybrid_even_as_block left right T e he σ
    have h2 := hybrid_odd_as_block left right T e he σ
    have h3 := hybrid_even_flip_as_block left right T e he σ
    have h4 := hybrid_odd_flip_as_block left right T e he σ
    have hraw :
        D σ + D (flip e σ) =
        blockRectangle f x e
          (left e false) (left e true)
          (right e false) (right e true) := by
      dsimp [D]
      rw [h1, h2, h3, h4]
      cases hbit : σ e <;>
        simp [blockRectangle, x, hbit] <;> ring
    exact hraw.trans (hrect e x)
  have hflip :
      (∑ σ : β → Bool, D (flip e σ)) =
      (∑ σ : β → Bool, D σ) :=
    sum_flip e D
  have hsum :
      2 * (∑ σ : β → Bool, D σ) =
        (Fintype.card (β → Bool) : ℝ) * d e := by
    calc
      2 * (∑ σ : β → Bool, D σ) =
          (∑ σ : β → Bool, D σ) +
            (∑ σ : β → Bool, D (flip e σ)) := by rw [hflip]; ring
      _ = ∑ σ : β → Bool, (D σ + D (flip e σ)) := by
            rw [Finset.sum_add_distrib]
      _ = ∑ _σ : β → Bool, d e := by
            apply Finset.sum_congr rfl
            intro σ _
            exact hpoint σ
      _ = (Fintype.card (β → Bool) : ℝ) * d e := by simp
  have hmeans :
      hybridTotal f left right T -
          hybridTotal f left right (insert e T) =
      ∑ σ : β → Bool, D σ := by
    simp only [hybridTotal, D, Finset.sum_sub_distrib]
  rw [hmeans]
  exact hsum

/-- Exact GLOBAL parity telescope for every finite number of disjoint
blocks; no matching-mass estimate or parity equation is a premise.
The only given analytic input is background-invariance of each source
four-point rectangle. -/
theorem hybrid_global_parity_telescope
    (f : (β × Bool → α) → ℝ)
    (left right : β → Bool → α)
    (d : β → ℝ)
    (hrect : ∀ e x,
      blockRectangle f x e
        (left e false) (left e true)
        (right e false) (right e true) = d e) :
    2 * (hybridTotal f left right ∅ -
         hybridTotal f left right univ) =
      (Fintype.card (β → Bool) : ℝ) * ∑ e : β, d e := by
  have hgeneral : ∀ T : Finset β,
      2 * (hybridTotal f left right ∅ - hybridTotal f left right T) =
        (Fintype.card (β → Bool) : ℝ) * (∑ e ∈ T, d e) := by
    intro T
    induction T using Finset.induction_on with
    | empty => simp
    | @insert e T he ih =>
      have step := hybrid_single_block_difference f left right d hrect T e he
      simp only [Finset.sum_insert he]
      nlinarith [ih, step]
  simpa only [Finset.sum_univ] using hgeneral univ

end Nightfall.Observability.QuadraticHybridTelescoping
