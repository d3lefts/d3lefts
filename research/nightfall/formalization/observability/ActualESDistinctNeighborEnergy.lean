import ActualESDistinctNeighborSections

/-!
# Exact source-law orthogonality of distinct centered neighbor increments

The expectation is over one actual coordinate-product draw, not over a
list of independently sampled synthetic copies of possibly repeated sites.
The cross term is zero for any two distinct coordinates, for any
nonnegative normalized coordinate laws (including zero masses).
-/

namespace Nightfall.Observability.ActualESDistinctNeighborEnergy

open Finset Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Centering on one source coordinate annihilates every product cross
term with a function of a different actual coordinate. -/
theorem centered_distinct_coordinate_cross_zero
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j k : ι) (hjk : j ≠ k)
    (g h : α → ℝ)
    (hg : (∑ b : α, p j b * g b) = 0) :
    (∑ x : ι → α,
      prodMass p x * (g (x j) * h (x k))) = 0 := by
  classical
  let F : (ι → α) → ℝ := fun x => g (x j) * h (x k)
  have hres := resample_sum p hp1 j F
  have hreplace (x : ι → α) (b : α) :
      F (Function.update x j b) = g b * h (x k) := by
    simp [F, Function.update_of_ne hjk.symm]
  have hx (x : ι → α) :
      (∑ b : α, prodMass p x * p j b *
        (g b * h (x k))) = 0 := by
    calc
      (∑ b : α, prodMass p x * p j b *
        (g b * h (x k))) =
        prodMass p x * (∑ b : α, p j b *
          (g b * h (x k))) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro b _
            ring
      _ = prodMass p x * ((∑ b : α, p j b * g b) *
          h (x k)) := by
            rw [Finset.sum_mul]
            congr 1
            apply Finset.sum_congr rfl
            intro b _
            ring
      _ = 0 := by rw [hg]; ring
  calc
    (∑ x : ι → α,
      prodMass p x * (g (x j) * h (x k))) =
      ∑ x : ι → α, ∑ b : α, prodMass p x * p j b *
        F (Function.update x j b) := hres.symm
    _ = ∑ x : ι → α, ∑ b : α, prodMass p x * p j b *
        (g b * h (x k)) := by
          apply Finset.sum_congr rfl
          intro x _
          apply Finset.sum_congr rfl
          intro b _
          rw [hreplace]
    _ = 0 := by simp [hx]


/-- The exact second-moment isometry for a finite set of DISTINCT centered
source coordinate functions. This is the source-law energy interface:
no synthetic copies, no rank, dimension, or minimum-atom restriction. -/
theorem centered_source_owned_second_moment
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (J : Finset ι) (g : ι → α → ℝ)
    (hcenter : ∀ j ∈ J, (∑ b : α, p j b * g j b) = 0) :
    (∑ x : ι → α,
      prodMass p x * (∑ j ∈ J, g j (x j)) ^ 2) =
      ∑ j ∈ J, ∑ b : α, p j b * (g j b) ^ 2 := by
  classical
  have hexpand (x : ι → α) :
      (∑ j ∈ J, g j (x j)) ^ 2 =
        ∑ j ∈ J, ∑ k ∈ J, g j (x j) * g k (x k) := by
    calc
      (∑ j ∈ J, g j (x j)) ^ 2 =
          (∑ j ∈ J, g j (x j)) *
            (∑ k ∈ J, g k (x k)) := by ring
      _ = ∑ j ∈ J, ∑ k ∈ J, g j (x j) * g k (x k) := by
            rw [Finset.sum_mul]
            apply Finset.sum_congr rfl
            intro j _
            rw [Finset.mul_sum]
  have hswap :
      (∑ x : ι → α, prodMass p x *
        (∑ j ∈ J, ∑ k ∈ J, g j (x j) * g k (x k))) =
      ∑ j ∈ J, ∑ k ∈ J, ∑ x : ι → α,
        prodMass p x * (g j (x j) * g k (x k)) := by
    calc
      (∑ x : ι → α, prodMass p x *
        (∑ j ∈ J, ∑ k ∈ J, g j (x j) * g k (x k))) =
        ∑ x : ι → α, ∑ j ∈ J, ∑ k ∈ J,
          prodMass p x * (g j (x j) * g k (x k)) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro j _
            rw [Finset.mul_sum]
      _ = ∑ j ∈ J, ∑ x : ι → α, ∑ k ∈ J,
          prodMass p x * (g j (x j) * g k (x k)) := Finset.sum_comm
      _ = ∑ j ∈ J, ∑ k ∈ J, ∑ x : ι → α,
          prodMass p x * (g j (x j) * g k (x k)) := by
            apply Finset.sum_congr rfl
            intro j _
            exact Finset.sum_comm
  have hdiag (j : ι) (hj : j ∈ J) :
      (∑ k ∈ J, ∑ x : ι → α,
        prodMass p x * (g j (x j) * g k (x k))) =
      ∑ x : ι → α, prodMass p x * (g j (x j)) ^ 2 := by
    rw [Finset.sum_eq_single j]
    · apply Finset.sum_congr rfl
      intro x _
      ring
    · intro k hk hne
      exact centered_distinct_coordinate_cross_zero
        p hp1 j k hne.symm (g j) (g k) (hcenter j hj)
    · intro hnot
      exact (hnot hj).elim
  calc
    (∑ x : ι → α,
      prodMass p x * (∑ j ∈ J, g j (x j)) ^ 2) =
      ∑ x : ι → α, prodMass p x *
        (∑ j ∈ J, ∑ k ∈ J, g j (x j) * g k (x k)) := by
          apply Finset.sum_congr rfl
          intro x _
          rw [hexpand]
    _ = ∑ j ∈ J, ∑ k ∈ J, ∑ x : ι → α,
        prodMass p x * (g j (x j) * g k (x k)) := hswap
    _ = ∑ j ∈ J, ∑ x : ι → α,
        prodMass p x * (g j (x j)) ^ 2 := by
          apply Finset.sum_congr rfl
          intro j hj
          exact hdiag j hj
    _ = ∑ j ∈ J, ∑ b : α, p j b * (g j b) ^ 2 := by
          apply Finset.sum_congr rfl
          intro j _
          exact sum_prodMass_coord p hp1 j
            (fun b => (g j b) ^ 2)


/-- Exact weighted Hilbert-section second moment in the original source
law. The output coordinate a is weighted by the genuine marginal p i,
and every owned neighbor j is a distinct actual input coordinate.
No artificial repeated samples and no supplied energy bound. -/
theorem centered_source_owned_hilbert_second_moment
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (i : ι) (J : Finset ι) (h : ι → α → α → ℝ)
    (hcenter : ∀ j ∈ J, ∀ a : α,
      (∑ b : α, p j b * h j a b) = 0) :
    (∑ x : ι → α, prodMass p x *
      (∑ a : α, p i a *
        (∑ j ∈ J, h j a (x j)) ^ 2)) =
      ∑ j ∈ J, ∑ a : α, p i a *
        (∑ b : α, p j b * (h j a b) ^ 2) := by
  classical
  have hswitch :
      (∑ x : ι → α, prodMass p x *
        (∑ a : α, p i a *
          (∑ j ∈ J, h j a (x j)) ^ 2)) =
      ∑ a : α, p i a *
        (∑ x : ι → α, prodMass p x *
          (∑ j ∈ J, h j a (x j)) ^ 2) := by
    calc
      _ = ∑ x : ι → α, ∑ a : α,
        prodMass p x * (p i a *
          (∑ j ∈ J, h j a (x j)) ^ 2) := by
            apply Finset.sum_congr rfl
            intro x _
            rw [Finset.mul_sum]
      _ = ∑ a : α, ∑ x : ι → α,
        prodMass p x * (p i a *
          (∑ j ∈ J, h j a (x j)) ^ 2) := Finset.sum_comm
      _ = ∑ a : α, p i a *
        (∑ x : ι → α, prodMass p x *
          (∑ j ∈ J, h j a (x j)) ^ 2) := by
            apply Finset.sum_congr rfl
            intro a _
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro x _
            ring
  calc
    (∑ x : ι → α, prodMass p x *
      (∑ a : α, p i a *
        (∑ j ∈ J, h j a (x j)) ^ 2)) =
      ∑ a : α, p i a *
        (∑ x : ι → α, prodMass p x *
          (∑ j ∈ J, h j a (x j)) ^ 2) := hswitch
    _ = ∑ a : α, p i a *
        (∑ j ∈ J, ∑ b : α, p j b * (h j a b) ^ 2) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [centered_source_owned_second_moment p hp1 J
            (fun j b => h j a b) (fun j hj => hcenter j hj a)]
    _ = ∑ a : α, ∑ j ∈ J,
          p i a * (∑ b : α, p j b * (h j a b) ^ 2) := by
          apply Finset.sum_congr rfl
          intro a _
          rw [Finset.mul_sum]
    _ = ∑ j ∈ J, ∑ a : α, p i a *
          (∑ b : α, p j b * (h j a b) ^ 2) := Finset.sum_comm

end Nightfall.Observability.ActualESDistinctNeighborEnergy
