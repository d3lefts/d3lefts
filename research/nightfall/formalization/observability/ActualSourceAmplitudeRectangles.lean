import ActualSourcePairAmplitudes
import ActualSourceQuadraticRectangles
import ActualSourceCanonicalIdentification
import CenteredRectangles

/-!
# Source-identical pair amplitude to actual mixed-rectangle witness

No supplied matching/corner/amplitude assumptions. The original
finite product function has Hoeffding degree <=2. Canonical Efron–Stein
pair kernels are the original-source double-centered tables, and every
attained maximal absolute pair amplitude admits an oriented positive
rectangle of the bounded original function.
Ported from legacy #424/#430 source-certified kernels to Lean 4.36.
-/

namespace Nightfall.Observability.ActualSourceAmplitudeRectangles

open Finset
open Nightfall.Observability.ActualSourceANOVA
open Nightfall.Observability.ActualSourceQuadraticRectangles
open Nightfall.Observability.ActualSourceCanonicalIdentification
open Nightfall.Observability.ActualProductSourcePairCentering
open Nightfall.Observability.ActualSourcePairAmplitudes
open Nightfall.Observability.CenteredRectangles

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

/-- The actual mixed rectangle of degree-2 f is exactly the four-corner
rectangle of its canonical pair table, for all original inputs, with
no hidden choice of background configuration. -/
theorem original_source_rectangle_eq_pair_table
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (i j : ι) (hij : i ≠ j)
    (a0 a1 b0 b1 : α) :
    sourceRectangle f base i j a0 a1 b0 b1 =
      sourceDoubleCenteredPair p f i j a0 b0 -
      sourceDoubleCenteredPair p f i j a0 b1 -
      sourceDoubleCenteredPair p f i j a1 b0 +
      sourceDoubleCenteredPair p f i j a1 b1 := by
  rw [actual_quadratic_rectangle_eq_es_pair
    p hp1 f hdegree i j hij base a0 a1 b0 b1]
  unfold sourceRectangle
  simp only [actual_source_esComp_pair_eq_derived p hp1 f i j hij]
  simp [Function.update, hij]

/-- The actual source-derived finite maximum is bounded by an oriented
four-corner rectangle of the original bounded f, without providing an
amplitude witness. -/
theorem original_source_pair_amplitude_oriented_rectangle
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ)
    (hdegree : ESDegreeLE p f 2)
    (base : ι → α)
    (i j : ι) (hij : i ≠ j) :
    ∃ a0 a1 b0 b1 : α,
      pairAmplitudeWeight p f i j ≤
        sourceRectangle f base i j a0 a1 b0 b1 := by
  let a := pairAmplitudeMax p f i j
  obtain ⟨a0,a1,b0,b1,h⟩ :=
    exists_oriented_rectangle_dominating_abs
      (p i) (p j) (hp i) (hp j) (hp1 i) (hp1 j)
      (sourceDoubleCenteredPair p f i j)
      (actual_source_derived_pair_second_centered p hp1 f i j)
      (actual_source_derived_pair_first_centered p hp1 f i j)
      a.1 a.2
  refine ⟨a0,a1,b0,b1, ?_⟩
  rw [original_source_rectangle_eq_pair_table
    p hp1 f hdegree base i j hij a0 a1 b0 b1]
  exact h

end Nightfall.Observability.ActualSourceAmplitudeRectangles
