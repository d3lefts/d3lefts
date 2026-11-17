import InfinitePiQ2Density
import Mathlib

/-!
# General original-product Q2 limit for dense finite-label approximations

The existing source_q2_quadratic_limit uses the directed NET of all
finite-COORDINATE conditional projections. The actual finite-alphabet
C105.416 application instead yields bounds for genuine finite-label
conditional averages, which need not equal any entire-coordinate
projection when source coordinate spaces are infinite/nonatomic.

This lemma closes the correct final analytical interface: for a
fixed original L² observable f, it is sufficient to approximate f
arbitrarily well by ANY source-law observables g of exactly the same
original mean and uniformly bounded original variance squared.

Continuity is proved as a closed sublevel set of a continuous norm
functional. No source substitution, countability, atom floor, uniform
rate, finite coordinate set, or new Q2 constant is required.

This theorem does NOT construct the bounded degree-two finite-label
tables or prove their original-law influence contraction.
-/

namespace Nightfall.InfinitePiQ2DenseLabelLimit

open MeasureTheory
open Nightfall.InfinitePiQ2Density

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- A common Q2 quadratic bound passes to any original-source L²
observable in the closure of a set of approximants having the SAME
original-source mean and uniform original-source variance bound.
The approximating set need not be a subspace or a sequence. -/
theorem source_q2_bound_of_mean_preserving_closure
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (S : Set (Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)))
    (hf : f ∈ closure S)
    (R : ℝ)
    (hmean : ∀ g ∈ S,
      (∫ x, g x ∂ Measure.infinitePi μ) =
        ∫ x, f x ∂ Measure.infinitePi μ)
    (hbound : ∀ g ∈ S, (sourceL2Variance μ g)^2 ≤ R) :
    (sourceL2Variance μ f)^2 ≤ R := by
  let c : ℝ := (∫ x, f x ∂ Measure.infinitePi μ)^2
  let Q : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) → ℝ :=
    fun g => (‖g‖^2 - c)^2
  have hQ : Continuous Q := by
    dsimp [Q]
    fun_prop
  have hclosed : IsClosed {g | Q g ≤ R} :=
    isClosed_le hQ continuous_const
  have hsub : S ⊆ {g | Q g ≤ R} := by
    intro g hg
    have hb := hbound g hg
    change (‖g‖^2 -
      (∫ x, g x ∂ Measure.infinitePi μ)^2)^2 ≤ R at hb
    rw [hmean g hg] at hb
    exact hb
  have hclosure : closure S ⊆ {g | Q g ≤ R} :=
    closure_minimal hsub hclosed
  have hresult := hclosure hf
  change Q f ≤ R at hresult
  simpa only [Q, c, sourceL2Variance] using hresult

/-- Epsilon form of the actual original-product finite-LABEL limit.
For every ε, a genuine label projection with:
- distance to f strictly less than ε in source L²,
- the same original source mean, and
- the common C105.416 variance bound
suffices for the full infinite-product bound.

Unlike the finite-coordinate-only limit, this is the exact endpoint
usable by arbitrary finite-label σ-algebra conditional projections. -/
theorem source_q2_bound_of_approximate_finite_labels
    (f : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (R : ℝ)
    (happrox : ∀ ε : ℝ, 0 < ε →
      ∃ g : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ),
        ‖f - g‖ < ε ∧
        (∫ x, g x ∂ Measure.infinitePi μ) =
          (∫ x, f x ∂ Measure.infinitePi μ) ∧
        (sourceL2Variance μ g)^2 ≤ R) :
    (sourceL2Variance μ f)^2 ≤ R := by
  let S : Set (Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :=
    {g | (∫ x, g x ∂ Measure.infinitePi μ) =
            (∫ x, f x ∂ Measure.infinitePi μ) ∧
          (sourceL2Variance μ g)^2 ≤ R}
  have hmem : f ∈ closure S := by
    rw [Metric.mem_closure_iff]
    intro ε hε
    obtain ⟨g, hdist, hmean, hvar⟩ := happrox ε hε
    refine ⟨g, ⟨hmean, hvar⟩, ?_⟩
    simpa only [dist_eq_norm] using hdist
  exact source_q2_bound_of_mean_preserving_closure μ f S hmem R
    (fun g hg => hg.1) (fun g hg => hg.2)

#print axioms Nightfall.InfinitePiQ2DenseLabelLimit.source_q2_bound_of_mean_preserving_closure
#print axioms Nightfall.InfinitePiQ2DenseLabelLimit.source_q2_bound_of_approximate_finite_labels

end Nightfall.InfinitePiQ2DenseLabelLimit
