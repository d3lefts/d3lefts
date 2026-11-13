import ProductInfluence

/-!
# Actual finite-product conditional norm Jensen contraction

This is a vector-valued conditional expectation over the literal
original source product masses and the source's finite coordinate
merge operation. The norm contraction is *proved*, not given as an
operator or "oracle" premise. It accepts any real normed vector space,
including the weighted finite-dimensional Hilbert spaces used in the
quadratic fourth-moment argument.

To close source Q2, identify this projected centered-section vector
with the canonical singleton term plus the greedy-owned distinct
neighbor increments (ActualESOwnedConditional), then use the actual
product expectation/tower identity to sum its norm budget.

A pointwise Jensen contraction alone does not establish that final
source identity or the global variance-influence inequality.
-/

namespace Nightfall.Observability.ActualESConditionalJensen

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Exact finite-weight Hilbert (indeed, any normed vector)
triangle/Jensen inequality, without a nonzero atom requirement. -/
theorem weighted_vector_jensen
    {Ω H : Type*} [Fintype Ω]
    [NormedAddCommGroup H] [NormedSpace ℝ H]
    (w : Ω → ℝ) (hw : ∀ z, 0 ≤ w z)
    (v : Ω → H) :
    ‖∑ z : Ω, w z • v z‖ ≤
      ∑ z : Ω, w z * ‖v z‖ := by
  classical
  calc
    ‖∑ z : Ω, w z • v z‖ ≤
        ∑ z : Ω, ‖w z • v z‖ := norm_sum_le _ _
    _ = ∑ z : Ω, w z * ‖v z‖ := by
      apply Finset.sum_congr rfl
      intro z _
      rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hw z)]

/-- Actual vector conditional expectation, formed directly by
resampling the unobserved ORIGINAL product coordinates. -/
noncomputable def actualConditionalVector
    {H : Type*} [AddCommMonoid H] [Module ℝ H]
    (p : ι → α → ℝ) (N : Finset ι)
    (G : (ι → α) → H) (x : ι → α) : H :=
  ∑ y : ι → α, prodMass p y • G (merge N x y)

/-- Jensen for the actual conditional product operator, with no
assumed norm-contraction axiom. The right side is the genuine
conditional expectation of the original norm function. -/
theorem actual_source_conditional_norm_jensen
    {H : Type*} [NormedAddCommGroup H] [NormedSpace ℝ H]
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (N : Finset ι) (G : (ι → α) → H) (x : ι → α) :
    ‖actualConditionalVector p N G x‖ ≤
      condExp p N (fun y => ‖G y‖) x := by
  unfold actualConditionalVector condExp
  exact weighted_vector_jensen (prodMass p)
    (prodMass_nonneg' p hp)
    (fun y => G (merge N x y))

end Nightfall.Observability.ActualESConditionalJensen
