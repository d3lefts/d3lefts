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

/-- Two independent original-source draws in EVERY coordinate retain
their exact product law after simultaneous coordinatewise labeling.
This is the paired-input representation needed for finite heat-bath
influence transport. No resampling/canonical-residual equality is
asserted by this statement. -/
theorem sourcePairedLabelLaw_exact
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i)) :
    (Measure.infinitePi (fun i => (μ i).prod (μ i))).map
        (fun z i => Prod.map (φ i) (φ i) (z i)) =
      Measure.infinitePi
        (fun i => ((μ i).map (φ i)).prod ((μ i).map (φ i))) := by
  have hpair (i : ι) : Measurable (Prod.map (φ i) (φ i)) := by
    fun_prop
  calc
    (Measure.infinitePi (fun i => (μ i).prod (μ i))).map
        (fun z i => Prod.map (φ i) (φ i) (z i)) =
      Measure.infinitePi
        (fun i => ((μ i).prod (μ i)).map (Prod.map (φ i) (φ i))) := by
          exact Measure.infinitePi_map_pi
            (fun i => (μ i).prod (μ i)) hpair
    _ = Measure.infinitePi
        (fun i => ((μ i).map (φ i)).prod ((μ i).map (φ i))) := by
      congr 1
      funext i
      exact (Measure.map_prod_map (μ i) (μ i) (hφ i) (hφ i)).symm

/-- Every integrable observable of the finite source labels has exactly
the same expectation under the original infinite product as under the
true finite label law. For a nonintegrable observable both sides obey
Mathlib's same integral convention. -/
theorem sourceFiniteLabelIntegral_exact
    (F : Finset ι)
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : ((j : F) → Y j) → ℝ)
    (hg : Measurable g) :
    (∫ x, g (F.restrict (sourceLabelMap φ x))
      ∂ Measure.infinitePi μ) =
      ∫ y, g y ∂ Measure.pi (fun j : F => (μ j).map (φ j)) := by
  let label : ((i : ι) → X i) → ((j : F) → Y j) :=
    fun x => F.restrict (sourceLabelMap φ x)
  have hmp := sourceFiniteLabelMap_measurePreserving μ F φ hφ
  have hmeas : Measurable label := hmp.measurable
  have hstrong :
      AEStronglyMeasurable g ((Measure.infinitePi μ).map label) := by
    rw [show ((Measure.infinitePi μ).map label) =
      Measure.pi (fun j : F => (μ j).map (φ j)) from
        sourceFiniteLabelLaw_exact μ F φ hφ]
    exact hg.aestronglyMeasurable
  calc
    (∫ x, g (F.restrict (sourceLabelMap φ x))
      ∂ Measure.infinitePi μ) =
      ∫ y, g y ∂ ((Measure.infinitePi μ).map label) := by
        exact (integral_map hmeas.aemeasurable hstrong).symm
    _ = ∫ y, g y ∂ Measure.pi
        (fun j : F => (μ j).map (φ j)) := by
      rw [sourceFiniteLabelLaw_exact μ F φ hφ]

/-- An arbitrary measurable function of *two independent coordinate
draws* has exactly its original-source expectation after replacing each
pair by the corresponding labeled pair. This is the measure transport
for the paired heat-bath energy representation, not a claim about
identification with the condExpL2 residual. -/
theorem sourcePairedIntegral_exact
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : ((i : ι) → Y i × Y i) → ℝ)
    (hg : Measurable g) :
    (∫ z, g (fun i => Prod.map (φ i) (φ i) (z i))
      ∂ Measure.infinitePi (fun i => (μ i).prod (μ i))) =
      ∫ y, g y
        ∂ Measure.infinitePi
          (fun i => ((μ i).map (φ i)).prod ((μ i).map (φ i))) := by
  let label : ((i : ι) → X i × X i) → ((i : ι) → Y i × Y i) :=
    fun z i => Prod.map (φ i) (φ i) (z i)
  have hmeas : Measurable label := by
    change Measurable
      (fun (z : (i : ι) → X i × X i) i =>
        Prod.map (φ i) (φ i) (z i))
    fun_prop
  have hstrong : AEStronglyMeasurable g
      ((Measure.infinitePi (fun i => (μ i).prod (μ i))).map label) := by
    rw [show
      ((Measure.infinitePi (fun i => (μ i).prod (μ i))).map label) =
      Measure.infinitePi
        (fun i => ((μ i).map (φ i)).prod ((μ i).map (φ i)))
      from sourcePairedLabelLaw_exact μ φ hφ]
    exact hg.aestronglyMeasurable
  calc
    (∫ z, g (fun i => Prod.map (φ i) (φ i) (z i))
      ∂ Measure.infinitePi (fun i => (μ i).prod (μ i))) =
      ∫ y, g y
        ∂ ((Measure.infinitePi (fun i => (μ i).prod (μ i))).map label) := by
          exact (integral_map hmeas.aemeasurable hstrong).symm
    _ = ∫ y, g y
        ∂ Measure.infinitePi
          (fun i => ((μ i).map (φ i)).prod ((μ i).map (φ i))) := by
      rw [sourcePairedLabelLaw_exact μ φ hφ]

/-- The first draw from the original per-coordinate independent pair law. -/
def sourcePairFirst
    (z : (i : ι) → X i × X i) : (i : ι) → X i :=
  fun i => (z i).1

/-- Independently refreshing exactly coordinate i of the first draw. -/
def sourcePairRefresh [DecidableEq ι] (i : ι)
    (z : (j : ι) → X j × X j) : (j : ι) → X j :=
  Function.update (sourcePairFirst z) i (z i).2

/-- The source-resampling energy integrated under actual independent
per-coordinate pairs. This is an explicit observable, not an axiom
identifying it with the condExpL2 source residual. -/
noncomputable def sourcePairedRefreshEnergy [DecidableEq ι] (i : ι)
    (f : ((j : ι) → X j) → ℝ) : ℝ :=
  ∫ z, (f (sourcePairFirst z) - f (sourcePairRefresh i z)) ^ 2 / 2
    ∂ Measure.infinitePi (fun j => (μ j).prod (μ j))

theorem sourcePairFirst_measurable :
    Measurable (sourcePairFirst (X := X)) := by
  change Measurable (fun (z : (i : ι) → X i × X i) i => (z i).1)
  fun_prop

theorem sourcePairRefresh_measurable [DecidableEq ι] (i : ι) :
    Measurable (sourcePairRefresh (X := X) i) := by
  change Measurable
    (fun (z : (j : ι) → X j × X j) =>
      Function.update (sourcePairFirst z) i (z i).2)
  have hf : Measurable (fun (z : (j : ι) → X j × X j) =>
      sourcePairFirst z) := sourcePairFirst_measurable
  have hg : Measurable (fun (z : (j : ι) → X j × X j) =>
      (z i).2) := by fun_prop
  exact measurable_update'.comp (hf.prodMk hg)

/-- Per-coordinate independent refreshing commutes *pointwise* with
arbitrary source cell labels. The same paired source is used on both
sides. This lemma has no measure assumptions. -/
theorem sourcePairRefresh_label_commute
    [DecidableEq ι] (i : ι)
    (φ : ∀ j, X j → Y j)
    (z : (j : ι) → X j × X j) :
    sourceLabelMap φ (sourcePairRefresh i z) =
      sourcePairRefresh i
        (fun j => Prod.map (φ j) (φ j) (z j)) := by
  funext j
  by_cases hij : j = i
  · subst j
    simp [sourceLabelMap, sourcePairRefresh, sourcePairFirst]
  · simp [sourceLabelMap, sourcePairRefresh, sourcePairFirst,
      Function.update_of_ne hij]

/-- Exact original-law resampling energy of a finite-label observable
equals its genuine label-product-law resampling energy. No replacement
source distribution and no L2 projection hypothesis. -/
theorem sourcePairedRefreshEnergy_label_exact
    [DecidableEq ι]
    (φ : ∀ i, X i → Y i)
    (hφ : ∀ i, Measurable (φ i))
    (g : ((i : ι) → Y i) → ℝ) (hg : Measurable g)
    (i : ι) :
    sourcePairedRefreshEnergy μ i (fun x => g (sourceLabelMap φ x)) =
      sourcePairedRefreshEnergy
        (fun j => (μ j).map (φ j)) i g := by
  let G : ((j : ι) → Y j × Y j) → ℝ :=
    fun y => (g (sourcePairFirst y) - g (sourcePairRefresh i y)) ^ 2 / 2
  have hG : Measurable G := by
    dsimp [G]
    have hfirst : Measurable (sourcePairFirst (X := Y)) :=
      sourcePairFirst_measurable
    have hsecond : Measurable (sourcePairRefresh (X := Y) i) :=
      sourcePairRefresh_measurable i
    fun_prop
  have hfirst (z : (j : ι) → X j × X j) :
      sourceLabelMap φ (sourcePairFirst z) =
        sourcePairFirst (fun j => Prod.map (φ j) (φ j) (z j)) := by
    rfl
  have hsecond (z : (j : ι) → X j × X j) :
      sourceLabelMap φ (sourcePairRefresh i z) =
        sourcePairRefresh i (fun j => Prod.map (φ j) (φ j) (z j)) :=
    sourcePairRefresh_label_commute i φ z
  have hint (z : (j : ι) → X j × X j) :
      (g (sourceLabelMap φ (sourcePairFirst z)) -
          g (sourceLabelMap φ (sourcePairRefresh i z))) ^ 2 / 2 =
      G (fun j => Prod.map (φ j) (φ j) (z j)) := by
    rw [hfirst z, hsecond z]
  calc
    sourcePairedRefreshEnergy μ i (fun x => g (sourceLabelMap φ x)) =
        ∫ z, G (fun j => Prod.map (φ j) (φ j) (z j))
          ∂ Measure.infinitePi (fun j => (μ j).prod (μ j)) := by
      unfold sourcePairedRefreshEnergy
      apply integral_congr_ae
      exact Filter.Eventually.of_forall hint
    _ = ∫ y, G y
          ∂ Measure.infinitePi
            (fun j => ((μ j).map (φ j)).prod ((μ j).map (φ j))) :=
      sourcePairedIntegral_exact μ φ hφ G hG
    _ = sourcePairedRefreshEnergy
        (fun j => (μ j).map (φ j)) i g := by
      rfl

end Nightfall.InfinitePiQ2OriginalLabelTransport
