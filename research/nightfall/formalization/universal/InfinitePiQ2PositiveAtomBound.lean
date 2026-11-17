import Mathlib
import InfinitePiQ2OriginalLabelTransport

/-!
# Positive-atom extraction from an original-source essential bound

The finite-label adjoint produces an a.e. table, while the certified
finite supported Q2 terminal expects pointwise bounds *only on positive
source atoms*. This module supplies that missing transfer without any
lower bound on nonzero masses and without modifying zero-mass words.

No finite-alphabet, countability, or source-replacement hypothesis.
-/

namespace Nightfall.InfinitePiQ2PositiveAtomBound

open MeasureTheory

universe u v w

/-- A non-null atom cannot belong to the exceptional set of an
almost-everywhere predicate. No measurability of the predicate is needed. -/
theorem ae_property_at_nonnull_atom
    {α : Type u} [MeasurableSpace α]
    (μ : Measure α) (P : α → Prop) (a : α)
    (hP : ∀ᵐ x ∂μ, P x) (ha : μ {a} ≠ 0) :
    P a := by
  by_contra hn
  have hnot : ∀ᵐ x ∂μ, x ∉ ({a} : Set α) := by
    filter_upwards [hP] with x hx
    intro hmem
    have hxa : x = a := Set.mem_singleton_iff.mp hmem
    subst x
    exact hn hx
  have hzero : μ {a} = 0 :=
    measure_eq_zero_iff_ae_notMem.mpr hnot
  exact ha hzero

/-- An essential magnitude bound is pointwise at every atom that
has strictly positive probability, with NO atom-probability floor. -/
theorem abs_bound_at_positive_atom
    {α : Type u} [MeasurableSpace α]
    (μ : Measure α) (g : α → ℝ) (B : ℝ) (a : α)
    (hB : ∀ᵐ x ∂μ, |g x| ≤ B)
    (ha : 0 < μ {a}) :
    |g a| ≤ B :=
  ae_property_at_nonnull_atom μ (fun x => |g x| ≤ B) a hB (ne_of_gt ha)

/-- The exact induced original-product label law has the same bound on
each of its positive-mass words. This is the law required by the native
finite C105.416 theorem, not a surrogate distribution. -/
theorem original_label_positive_atom_bound
    {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
    [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
    (μ : (i : ι) → Measure (X i))
    [∀ i, IsProbabilityMeasure (μ i)]
    (φ : ∀ i, X i → Y i)
    (g : ((i : ι) → Y i) → ℝ) (B : ℝ)
    (y : (i : ι) → Y i)
    (hB : ∀ᵐ z ∂(Measure.infinitePi (fun i => (μ i).map (φ i))),
      |g z| ≤ B)
    (hy : 0 < (Measure.infinitePi (fun i => (μ i).map (φ i))) {y}) :
    |g y| ≤ B :=
  abs_bound_at_positive_atom
    (Measure.infinitePi (fun i => (μ i).map (φ i))) g B y hB hy

#print axioms Nightfall.InfinitePiQ2PositiveAtomBound.ae_property_at_nonnull_atom
#print axioms Nightfall.InfinitePiQ2PositiveAtomBound.abs_bound_at_positive_atom
#print axioms Nightfall.InfinitePiQ2PositiveAtomBound.original_label_positive_atom_bound

end Nightfall.InfinitePiQ2PositiveAtomBound
