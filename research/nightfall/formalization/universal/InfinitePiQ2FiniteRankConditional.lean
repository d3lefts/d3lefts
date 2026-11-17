import InfinitePiQ2ConditionalSourceTest
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# True-source conditional expectation of finite-rank coordinate tensors

Composes the source-specific one-site times complement factor theorem
(from PR #710) with Mathlib's finite-sum conditional-expectation linearity.
Finite sums of coordinate-simple tensors are the algebraic building
blocks for arbitrary finite-coordinate and finite-cell table lifts.

No source distribution replacement, pointwise-heatbath=Hilbert premise,
bounded table representation or final unconditional Q2 inequality is
assumed or asserted here.
-/

namespace Nightfall.InfinitePiQ2FiniteRankConditional

open MeasureTheory
open Nightfall.InfinitePiQ2ConditionalSourceTest
open Nightfall.InfinitePiQ2InfluenceStability

universe u v w
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Conditional expectation onto every source coordinate except i
of an arbitrary finite sum of one-coordinate tests times complement-
measurable factors. All integrals are under the ORIGINAL source law.
This is an exact source-specific finite-rank operator identity. -/
theorem source_condExp_finset_tensors
    {κ : Type w} (S : Finset κ) (i : ι)
    (h : κ → X i → ℝ)
    (v : κ → ((j : ι) → X j) → ℝ)
    (hh : ∀ k ∈ S, Measurable (h k))
    (hv : ∀ k ∈ S,
      StronglyMeasurable[sourceOtherSigma (X := X) i] (v k))
    (hint : ∀ k ∈ S,
      Integrable (sourceOneCoordTest i (h k)) (Measure.infinitePi μ))
    (hprod : ∀ k ∈ S,
      Integrable (sourceOneCoordTest i (h k) * v k)
        (Measure.infinitePi μ)) :
    (Measure.infinitePi μ)[
        ∑ k ∈ S, sourceOneCoordTest i (h k) * v k |
        sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
      (∑ k ∈ S,
        fun x => (∫ a : X i, h k a ∂ μ i) * v k x) := by
  classical
  let ν : Measure ((j : ι) → X j) := Measure.infinitePi μ
  let m := sourceOtherSigma (X := X) i
  let t : κ → ((j : ι) → X j) → ℝ :=
    fun k => sourceOneCoordTest i (h k) * v k
  let q : κ → ((j : ι) → X j) → ℝ :=
    fun k x => (∫ a : X i, h k a ∂ μ i) * v k x
  have hlinear :
      ν[∑ k ∈ S, t k | m] =ᵐ[ν]
        ∑ k ∈ S, ν[t k | m] := by
    exact condExp_finsetSum (fun k hk => hprod k hk) m
  have heach (k : κ) (hk : k ∈ S) :
      ν[t k | m] =ᵐ[ν] q k := by
    change
      (Measure.infinitePi μ)[sourceOneCoordTest i (h k) * v k |
          sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
        (fun x => (∫ a : X i, h k a ∂ μ i) * v k x)
    exact source_condExp_coordinate_mul_other μ i (h k) (hh k hk)
      (v k) (hv k hk) (hint k hk) (hprod k hk)
  have hsum :
      ∀ T : Finset κ, T ⊆ S →
        (∑ k ∈ T, ν[t k | m]) =ᵐ[ν]
          (∑ k ∈ T, q k) := by
    intro T
    induction T using Finset.induction_on with
    | empty =>
        intro _
        simp
    | @insert k T hk ih =>
        intro hTS
        have hks : k ∈ S := hTS (Finset.mem_insert_self k T)
        have hrest : T ⊆ S := by
          intro j hj
          exact hTS (Finset.mem_insert_of_mem hj)
        simpa only [Finset.sum_insert hk] using
          (heach k hks).add (ih hrest)
  exact hlinear.trans (hsum S (Finset.Subset.refl S))

#print axioms Nightfall.InfinitePiQ2FiniteRankConditional.source_condExp_finset_tensors

end Nightfall.InfinitePiQ2FiniteRankConditional
