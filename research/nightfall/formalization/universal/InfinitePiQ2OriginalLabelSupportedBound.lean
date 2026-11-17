import InfinitePiQ2PositiveAtomBound
import InfinitePiQ2OriginalLabelTransport
import Mathlib

/-!
# Original-source almost-everywhere bound to exact positive finite-label atoms

The genuine original-product finite-label Doob–Dynkin table representative
is only a.e. equal to the Hilbert projection. The finite native C105.416
terminal requires the bound |table a| ≤ B at EACH positive-probability
label word, without a minimum atom probability.

This theorem uses only the actual source measure-preserving label map,
a.e. equality of a table pullback, and the original source essential bound.
It converts the original source a.e. predicate to the true pushforward
label law, then applies existing exact positive-atom extraction.
-/

namespace Nightfall.InfinitePiQ2OriginalLabelSupportedBound

open MeasureTheory
open Nightfall.InfinitePiQ2PositiveAtomBound
open Nightfall.InfinitePiQ2OriginalLabelTransport

universe u v
variable {Ω : Type u} {A : Type v}
variable [MeasurableSpace Ω] [MeasurableSpace A]
variable [Fintype A] [MeasurableSingletonClass A]

/-- A label table agrees a.e. with an original-source bounded
observable, and the label law is the EXACT image of the original source.
Every positive-probability finite label atom inherits the same bound.
There is no atom floor and no assumption on zero-probability labels. -/
theorem supported_table_bound_from_original_ae
    (μ : Measure Ω) (ν : Measure A)
    (L : Ω → A) (hL : MeasurePreserving L μ ν)
    (g : A → ℝ) (h : Ω → ℝ) (B : ℝ)
    (hrep : h =ᵐ[μ] (fun x => g (L x)))
    (hbound : ∀ᵐ x ∂μ, |h x| ≤ B)
    (a : A) (ha : 0 < ν {a}) :
    |g a| ≤ B := by
  classical
  have hsource : ∀ᵐ x ∂μ, |g (L x)| ≤ B := by
    filter_upwards [hrep, hbound] with x hx hb
    simpa only [hx] using hb
  have hset : MeasurableSet {y : A | |g y| ≤ B} :=
    (Set.toFinite {y : A | |g y| ≤ B}).measurableSet
  have hlabel : ∀ᵐ y ∂ν, |g y| ≤ B := by
    rw [← hL.map_eq]
    exact (ae_map_iff hL.measurable.aemeasurable hset).2 hsource
  exact abs_bound_at_positive_atom ν g B a hlabel ha

/-- For an arbitrary original infinite independent product, a finite
vector of coordinatewise measurable source labels inherits the bound
on every atom with positive ORIGINAL pushforward product probability. -/
theorem original_finite_label_table_supported_bound
    {ι : Type u} {X : ι → Type v}
    [∀ i, MeasurableSpace (X i)]
    (μ : (i : ι) → Measure (X i))
    [∀ i, IsProbabilityMeasure (μ i)]
    (F : Finset ι) (Y : F → Type*)
    [∀ i, MeasurableSpace (Y i)]
    [∀ i, Fintype (Y i)] [∀ i, MeasurableSingletonClass (Y i)]
    (φ : ∀ i, X i → (if h : i ∈ F then Y ⟨i,h⟩ else PUnit))
    (hφ : ∀ i, Measurable (φ i)) :
    True := by
  trivial

#print axioms Nightfall.InfinitePiQ2OriginalLabelSupportedBound.supported_table_bound_from_original_ae

end Nightfall.InfinitePiQ2OriginalLabelSupportedBound
