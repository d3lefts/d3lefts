import ActualESPairMatchingBridge

/-!
# Actual Efron–Stein pair sections: distinct-neighbor conditional projection

The owned source coordinates form a Finset disjoint from the section
coordinate i. No repeated-coordinate synthetic independent draws are used.
This module proves a componentwise conditional-expectation identity.
L2 energy and Hilbert Jensen are *not* certified by this file.
-/

namespace Nightfall.Observability.ActualESDistinctNeighborSections

open Finset Nightfall.ProductSpace Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Transfer
open Nightfall.Observability.ActualESPairMatching

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

theorem product_expect_single
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (j : ι) (g : α → ℝ) :
    (∑ x : ι → α, prodMass p x * g (x j)) =
      ∑ b : α, p j b * g b := by
  classical
  have hsplit (x : ι → α) :
      prodMass p x * g (x j) =
        ∑ b : α, if x j = b then prodMass p x * g b else 0 := by
    simp
  calc
    (∑ x : ι → α, prodMass p x * g (x j)) =
        ∑ x : ι → α, ∑ b : α,
          if x j = b then prodMass p x * g b else 0 := by
            apply Finset.sum_congr rfl
            intro x _
            exact hsplit x
    _ = ∑ b : α, ∑ x : ι → α,
          if x j = b then prodMass p x * g b else 0 := Finset.sum_comm
    _ = ∑ b : α, (∑ x : ι → α,
          if x j = b then prodMass p x else 0) * g b := by
            apply Finset.sum_congr rfl
            intro b _
            rw [Finset.sum_mul]
            apply Finset.sum_congr rfl
            intro x _
            split_ifs <;> ring
    _ = ∑ b : α, p j b * g b := by
            apply Finset.sum_congr rfl
            intro b _
            rw [Nightfall.ProductSpace.Posterior.single_product_marginal p hp1 j b]

theorem condExp_single_inside
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (J : Finset ι) (j : ι) (hj : j ∈ J)
    (g : α → ℝ) (x : ι → α) :
    condExp p J (fun y => g (y j)) x = g (x j) := by
  unfold condExp
  have hmerge (y : ι → α) : merge J x y j = x j := by
    simp [merge, hj]
  simp only [hmerge]
  rw [← Finset.sum_mul, sum_prodMass' p hp1, one_mul]

theorem condExp_single_outside
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (J : Finset ι) (j : ι) (hj : j ∉ J)
    (g : α → ℝ) (x : ι → α) :
    condExp p J (fun y => g (y j)) x =
      ∑ b : α, p j b * g b := by
  unfold condExp
  have hmerge (y : ι → α) : merge J x y j = y j := by
    simp [merge, hj]
  simp only [hmerge]
  exact product_expect_single p hp1 j g

noncomputable def fullPairSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α) (i : ι) (a : α)
    (x : ι → α) : ℝ :=
  ∑ j ∈ (Finset.univ.erase i),
    actualPairKernel p f base i j a (x j)

noncomputable def ownedPairSection
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (base : ι → α) (i : ι) (a : α)
    (J : Finset ι) (x : ι → α) : ℝ :=
  ∑ j ∈ J, actualPairKernel p f base i j a (x j)

/-- E[P_i(a;X_{-i}) | X_J] = Y_i(a;X_J), for genuine source
pair components. The finite J contains distinct original coordinates. -/
theorem actual_owned_section_is_conditional_projection
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (base : ι → α) (i : ι)
    (J : Finset ι) (hi : i ∉ J)
    (a : α) (x : ι → α) :
    condExp p J (fullPairSection p f base i a) x =
      ownedPairSection p f base i a J x := by
  classical
  let s : Finset ι := Finset.univ.erase i
  let g : ι → (ι → α) → ℝ := fun j y =>
    actualPairKernel p f base i j a (y j)
  have hcommute :
      condExp p J (fullPairSection p f base i a) x =
        ∑ j ∈ s, condExp p J (g j) x := by
    unfold condExp fullPairSection
    simp only [Finset.mul_sum]
    rw [Finset.sum_comm]
  have hterm (j : ι) (hj : j ∈ s) :
      condExp p J (g j) x =
        if j ∈ J then g j x else 0 := by
    by_cases hJ : j ∈ J
    · rw [if_pos hJ]
      exact condExp_single_inside p hp1 J j hJ
        (fun b => actualPairKernel p f base i j a b) x
    · rw [if_neg hJ]
      have hneq : i ≠ j := by
        have hj' : j ≠ i := by simpa [s] using hj
        exact Ne.symm hj'
      have hc := actual_pair_kernel_right_centered
        p hp1 f base i j hneq a
      exact (condExp_single_outside p hp1 J j hJ
        (fun b => actualPairKernel p f base i j a b) x).trans hc
  have hJsub : J ⊆ s := by
    intro j hj
    have hne : j ≠ i := by
      intro hji
      exact hi (hji ▸ hj)
    simp [s, hne]
  have hfilter : s.filter (fun j => j ∈ J) = J := by
    ext j
    simp only [Finset.mem_filter]
    constructor
    · exact fun h => h.2
    · exact fun h => ⟨hJsub h, h⟩
  calc
    condExp p J (fullPairSection p f base i a) x =
        ∑ j ∈ s, condExp p J (g j) x := hcommute
    _ = ∑ j ∈ s, if j ∈ J then g j x else 0 := by
          apply Finset.sum_congr rfl
          intro j hj
          exact hterm j hj
    _ = ∑ j ∈ J, g j x := by
          rw [← Finset.sum_filter, hfilter]
    _ = ownedPairSection p f base i a J x := rfl


/-- Finite conditional Jensen for any real normed vector space. This
operator is used on the actual finite weighted L2 section fibers, not
on independent copies of repeated source coordinates. -/
theorem finite_weighted_vector_jensen
    {Ω V : Type*} [Fintype Ω]
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    (μ : Ω → ℝ) (hμ : ∀ w, 0 ≤ μ w) (g : Ω → V) :
    ‖∑ w : Ω, μ w • g w‖ ≤
      ∑ w : Ω, μ w * ‖g w‖ := by
  classical
  calc
    ‖∑ w : Ω, μ w • g w‖ ≤
        ∑ w : Ω, ‖μ w • g w‖ := norm_sum_le _ _
    _ = ∑ w : Ω, μ w * ‖g w‖ := by
          apply Finset.sum_congr rfl
          intro w _
          rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hμ w)]

end Nightfall.Observability.ActualESDistinctNeighborSections
