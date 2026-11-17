import InfinitePiQ2FrozenLabelMeasurable
import InfinitePiQ2FiniteRankConditional

/-!
# Finite-label source conditional expectation with no surrogate law

On the *actual* original arbitrary product, condition on all coordinates
except i. A bounded measurable finite-label observable can be decomposed
as a sum of original-coordinate label indicators times complement-measurable
frozen table sections. The exact conditional mean follows from certified
original-source finite-rank tensors. Integrability is derived from boundedness,
not imposed as an additional theorem premise.

This is the active-coordinate source operator identification necessary for
the L² finite-cell Q2 transfer. It is not the complete infinite-Q2 theorem.
-/

namespace Nightfall.InfinitePiQ2ActiveFiniteLabelCondExp

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2OriginalLabelTransport
open Nightfall.InfinitePiQ2FrozenLabelMeasurable
open Nightfall.InfinitePiQ2FiniteRankConditional
open Nightfall.InfinitePiQ2ConditionalSourceTest

universe u v w
variable {ι : Type u} {X : ι → Type v} {Y : ι → Type w}
variable [∀ i, MeasurableSpace (X i)] [∀ i, MeasurableSpace (Y i)]
variable [∀ i, MeasurableSingletonClass (Y i)]
variable [DecidableEq ι]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Exact original-site finite-label decomposition, even for a table on
an arbitrary product of label types. Only the selected site's labels
need be finite. This is pointwise and needs no probability assumption. -/
theorem label_site_decomposition
    (φ : ∀ i, X i → Y i)
    (g : ((i : ι) → Y i) → ℝ)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)]
    (x : (i : ι) → X i) :
    g (sourceLabelMap φ x) =
      ∑ a : Y i,
        (if φ i (x i) = a then (1 : ℝ) else 0) *
          g (Function.update (sourceLabelMap φ x) i a) := by
  classical
  have hself : Function.update (sourceLabelMap φ x) i (φ i (x i)) =
      sourceLabelMap φ x := by
    funext j
    by_cases hj : j = i
    · subst j
      simp [sourceLabelMap]
    · simp [Function.update_of_ne hj]
  simp [ite_mul, Finset.sum_ite_eq', hself]

/-- Source-original conditional expectation of a globally B-bounded
finite-coordinate label function, with all other coordinates retained.
The integrability hypotheses of the finite-rank theorem are discharged
from finite mass, measurability and the global table bound. No source-
to-finite model equality is supplied as an axiom. -/
theorem source_condExp_lifted_finite_label
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B)
    (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)] :
    (Measure.infinitePi μ)[
      (fun x => g (sourceLabelMap φ x)) |
      sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
      (fun x => ∑ a : Y i,
        (∫ b : X i, (if φ i b = a then (1 : ℝ) else 0) ∂ μ i) *
           g (Function.update (sourceLabelMap φ x) i a)) := by
  classical
  let ν : Measure ((j : ι) → X j) := Measure.infinitePi μ
  let h : Y i → X i → ℝ := fun a b =>
    if φ i b = a then 1 else 0
  let v : Y i → ((j : ι) → X j) → ℝ := fun a x =>
    g (Function.update (sourceLabelMap φ x) i a)
  have hmeas (a : Y i) : Measurable (h a) := by
    have hset : MeasurableSet {b : X i | φ i b = a} :=
      (hφ i) (measurableSet_singleton a)
    have hm : Measurable (fun b : X i =>
        if φ i b = a then (1 : ℝ) else 0) :=
      Measurable.ite hset measurable_const measurable_const
    exact hm
  have hother (a : Y i) :
      StronglyMeasurable[sourceOtherSigma (X := X) i] (v a) := by
    exact source_frozen_label_factor_stronglyMeasurable φ hφ i a g hg
  have hsite (a : Y i) :
      StronglyMeasurable (sourceOneCoordTest i (h a)) := by
    exact ((hmeas a).comp (by fun_prop)).stronglyMeasurable
  have hfull (a : Y i) : StronglyMeasurable (v a) :=
    (hother a).mono (sourceOtherSigma_le (X := X) i)
  have hint (a : Y i) :
      Integrable (sourceOneCoordTest i (h a)) ν := by
    refine Integrable.of_bound (hsite a).aestronglyMeasurable 1
      (Filter.Eventually.of_forall ?_)
    intro x
    by_cases ha : φ i (x i) = a
    · simp [sourceOneCoordTest, h, ha]
    · simp [sourceOneCoordTest, h, ha]
  have hprod (a : Y i) :
      Integrable (sourceOneCoordTest i (h a) * v a) ν := by
    refine Integrable.of_bound ((hsite a).mul (hfull a)).aestronglyMeasurable
      B (Filter.Eventually.of_forall ?_)
    intro x
    by_cases ha : φ i (x i) = a
    · simpa [h, v, sourceOneCoordTest, ha, Real.norm_eq_abs] using
        (hbound (Function.update (sourceLabelMap φ x) i a))
    · simpa [h, v, sourceOneCoordTest, ha] using hB
  have hlinear :=
    source_condExp_finset_tensors μ (Finset.univ : Finset (Y i))
      i h v
      (by intro a _; exact hmeas a)
      (by intro a _; exact hother a)
      (by intro a _; exact hint a)
      (by intro a _; exact hprod a)
  have hsum : (∑ a ∈ (Finset.univ : Finset (Y i)),
       sourceOneCoordTest i (h a) * v a) =
       (fun x => g (sourceLabelMap φ x)) := by
    funext x
    have hd := label_site_decomposition (X := X) φ g i x
    simpa only [Finset.sum_apply, Pi.mul_apply,
      sourceOneCoordTest, h, v] using hd.symm
  rw [hsum] at hlinear
  have htarget :
      (∑ a : Y i, fun x : ((j : ι) → X j) =>
        (∫ b : X i, h a b ∂ μ i) * v a x) =
      (fun x : ((j : ι) → X j) =>
        ∑ a : Y i, (∫ b : X i, h a b ∂ μ i) * v a x) := by
    funext x
    simp only [Finset.sum_apply]
  rw [htarget] at hlinear
  simpa only [h, v] using hlinear

/-- The preceding original-product conditional identity is the actual
L² orthogonal heat-bath projection, with no conditional-projection
identity or L² membership supplied by the caller. The latter follows
from the finite-label bound, and the former from Mathlib's condExpL2
representation theorem under the unchanged source law. -/
theorem sourceOtherProjection_lifted_finite_label_ae
    (φ : ∀ i, X i → Y i) (hφ : ∀ i, Measurable (φ i))
    (g : ((j : ι) → Y j) → ℝ) (hg : Measurable g)
    (B : ℝ) (hB : 0 ≤ B)
    (hbound : ∀ y, |g y| ≤ B)
    (i : ι) [Fintype (Y i)] [DecidableEq (Y i)] :
    let f : ((j : ι) → X j) → ℝ :=
      fun x => g (sourceLabelMap φ x)
    let hmem : MemLp f (2 : ENNReal) (Measure.infinitePi μ) :=
      MemLp.of_bound
        ((hg.comp (sourceLabelMap_measurable φ hφ)).aestronglyMeasurable)
        B (Filter.Eventually.of_forall (fun x => by
          simpa only [Real.norm_eq_abs, Function.comp_apply] using
            hbound (sourceLabelMap φ x)))
    (↑↑↑(sourceOtherProjection μ i hmem.toLp)) =ᵐ[Measure.infinitePi μ]
      (fun x => ∑ a : Y i,
        (∫ b : X i, (if φ i b = a then (1 : ℝ) else 0) ∂ μ i) *
          g (Function.update (sourceLabelMap φ x) i a)) := by
  dsimp only
  have hf : MemLp (fun x => g (sourceLabelMap φ x))
      (2 : ENNReal) (Measure.infinitePi μ) := by
    apply MemLp.of_bound
      ((hg.comp (sourceLabelMap_measurable φ hφ)).aestronglyMeasurable) B
    exact Filter.Eventually.of_forall (fun x => by
      simpa only [Real.norm_eq_abs, Function.comp_apply] using
        hbound (sourceLabelMap φ x))
  have hL2 :=
    MemLp.condExpL2_ae_eq_condExp (E := ℝ) (𝕜 := ℝ)
      (sourceOtherSigma_le (X := X) i) hf
  exact hL2.trans
    (source_condExp_lifted_finite_label μ φ hφ g hg B hB hbound i)

#print axioms Nightfall.InfinitePiQ2ActiveFiniteLabelCondExp.label_site_decomposition
#print axioms Nightfall.InfinitePiQ2ActiveFiniteLabelCondExp.sourceOtherProjection_lifted_finite_label_ae
#print axioms Nightfall.InfinitePiQ2ActiveFiniteLabelCondExp.source_condExp_lifted_finite_label

end Nightfall.InfinitePiQ2ActiveFiniteLabelCondExp
