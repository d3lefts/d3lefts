import InfinitePiQ2Density
import Mathlib.Probability.ProductMeasure

/-!
# Exact original-product pushforward under finite coordinate cell labels

The finite-table model used by the Q2 lift must have the pushforward
of the ORIGINAL product law, not a freely postulated table law.
The key fact is true for arbitrary index sets, dependent source and
target alphabets, arbitrary non-atomic sources, and cells of zero mass.

This module proves the exact full labeled product law and its
finite-coordinate marginal. It does not identify heat-bath residuals,
construct a degree-two table, or claim the infinite Q2 terminal.
-/

namespace Nightfall.InfinitePiQ2OriginalLabelTransport

open MeasureTheory

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Coordinatewise cell labels evaluated on the original product word. -/
def sourceLabelMap (φ : ∀ i, X i → Y i)
    (x : (i : ι) → X i) : (i : ι) → Y i :=
  fun i => φ i (x i)

theorem sourceLabelMap_measurable
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    Measurable (sourceLabelMap φ) := by
  change Measurable (fun (x : (j : ι) → X j) (i : ι) => φ i (x i))
  fun_prop

/-- Pushing the genuine infinite product through all coordinate
cell labels gives exactly the infinite product of their pushforwards.
No independence assumption is recreated: it is the original law. -/
theorem sourceLabelLaw_exact
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    (Measure.infinitePi μ).map (sourceLabelMap φ) =
      Measure.infinitePi (fun i => (μ i).map (φ i)) := by
  change (Measure.infinitePi μ).map (fun x i => φ i (x i)) =
    Measure.infinitePi (fun i => (μ i).map (φ i))
  exact Measure.infinitePi_map_pi μ hφ

/-- The actual finite-coordinate cell word has precisely the
heterogeneous finite product of the original source cell measures.
This is the law required by the source-only C105.416 finite theorem. -/
theorem sourceFiniteLabelLaw_exact
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    (Measure.infinitePi μ).map
        (fun x => F.restrict (sourceLabelMap φ x)) =
      Measure.pi (fun j : F => (μ j).map (φ j)) := by
  have hmap : Measurable (sourceLabelMap φ) :=
    sourceLabelMap_measurable φ hφ
  have hrestr : Measurable
      (F.restrict : ((i : ι) → Y i) → ((j : F) → Y j)) :=
    Finset.measurable_restrict F
  calc
    (Measure.infinitePi μ).map
        (fun x => F.restrict (sourceLabelMap φ x)) =
      ((Measure.infinitePi μ).map (sourceLabelMap φ)).map F.restrict := by
        rw [Measure.map_map hrestr hmap]
        rfl
    _ = (Measure.infinitePi (fun i => (μ i).map (φ i))).map F.restrict := by
      rw [sourceLabelLaw_exact μ φ hφ]
    _ = Measure.pi (fun j : F => (μ j).map (φ j)) := by
      exact Measure.infinitePi_map_restrict (fun i => (μ i).map (φ i))

/-- The finite label vector is measure preserving from the unchanged
source infinite product into the true finite source table law. -/
theorem sourceFiniteLabelMap_measurePreserving
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    MeasurePreserving
      (fun x : (i : ι) → X i => F.restrict (sourceLabelMap φ x))
      (Measure.infinitePi μ)
      (Measure.pi (fun j : F => (μ j).map (φ j))) := by
  refine ⟨?_, sourceFiniteLabelLaw_exact μ F φ hφ⟩
  exact (Finset.measurable_restrict F).comp
    (sourceLabelMap_measurable φ hφ)

/-- The finite-cell source variance is exactly the original infinite-product
variance of its lifted cylinder, with no coefficient or atom loss.
This holds for any measurable table, not merely degree-two tables. -/
theorem sourceFiniteLabelVariance_exact
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : ((j : F) → Y j) → ℝ)
    (hg : Measurable g) :
    ProbabilityTheory.variance
        (fun x : (i : ι) → X i =>
          g (F.restrict (sourceLabelMap φ x)))
        (Measure.infinitePi μ) =
      ProbabilityTheory.variance g
        (Measure.pi (fun j : F => (μ j).map (φ j))) := by
  exact (sourceFiniteLabelMap_measurePreserving μ F φ hφ).variance_fun_comp
    hg.aemeasurable

/-- Actual infinite-product pullback of any finite-table L² observable
is an isometry, so second moments and L² convergence are not measured
under a substituted law. -/
theorem sourceFiniteLabelL2_norm_exact
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : Lp ℝ (2 : ENNReal)
      (Measure.pi (fun j : F => (μ j).map (φ j)))) :
    ‖Lp.compMeasurePreserving
      (fun x : (i : ι) → X i =>
        F.restrict (sourceLabelMap φ x))
      (sourceFiniteLabelMap_measurePreserving μ F φ hφ) g‖ = ‖g‖ := by
  exact Lp.norm_compMeasurePreserving g
    (sourceFiniteLabelMap_measurePreserving μ F φ hφ)

end Nightfall.InfinitePiQ2OriginalLabelTransport
