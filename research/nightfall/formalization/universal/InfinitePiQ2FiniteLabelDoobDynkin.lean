import Mathlib

/-!
# Actual-original-law L² label projections factor through their labels

The missing bridge between a general original-product Hilbert conditional
expectation and a native finite table is a Doob-Dynkin factorization.
Mathlib supplies a strictly measurable representative of an a.e.
strongly measurable function, and its existing Doob-Dynkin theorem
factors that representative through the exact observation map.

No source-law replacement, singleton atom bound, countability, or
numerical finite-Q2 inequality is imposed here. The result is stronger
than the finite-label case and reusable for any measurable label space.
-/

namespace Nightfall.InfinitePiQ2FiniteLabelDoobDynkin

open MeasureTheory

universe u v
variable {Ω : Type u} [MeasurableSpace Ω]
variable {A : Type v} [MeasurableSpace A]

/-- Every original-source a.e. strongly measurable observation for
the actual pullback sigma algebra of L has a real-valued label-table
representative, equal almost everywhere under the SAME original μ.
This works for arbitrary label space A; finiteness is not required. -/
theorem source_ae_comap_factors_as_label_table
    (μ : Measure Ω) (L : Ω → A) (g : Ω → ℝ)
    (hsm : AEStronglyMeasurable[
      MeasurableSpace.comap L (inferInstance : MeasurableSpace A)] g μ) :
    ∃ table : A → ℝ,
      g =ᵐ[μ] (fun x => table (L x)) := by
  classical
  obtain ⟨table, _, hfactor⟩ :=
    StronglyMeasurable.exists_eq_measurable_comp
      (f := L) (g := hsm.mk g) hsm.stronglyMeasurable_mk
  refine ⟨table, ?_⟩
  filter_upwards [hsm.ae_eq_mk] with x hx
  calc
    g x = hsm.mk g x := hx
    _ = table (L x) := congrFun hfactor x

/-- Every real L² conditional projection onto the actual observation
sigma algebra of L is a.e. a pullback of one deterministic table.
The projection is genuine Mathlib condExpL2 under the original μ,
and no surrogate table model is passed as a hypothesis. -/
theorem original_condExpL2_is_label_table_ae
    (μ : Measure Ω) (L : Ω → A)
    (hm : MeasurableSpace.comap L
      (inferInstance : MeasurableSpace A) ≤
      (inferInstance : MeasurableSpace Ω))
    (f : Lp ℝ (2 : ENNReal) μ) :
    ∃ table : A → ℝ,
      (condExpL2 ℝ ℝ
        (μ := μ)
        (m := MeasurableSpace.comap L
          (inferInstance : MeasurableSpace A)) hm f :
          Ω → ℝ) =ᵐ[μ]
      (fun x => table (L x)) := by
  exact source_ae_comap_factors_as_label_table μ L _
    (aestronglyMeasurable_condExpL2 hm f)

#print axioms Nightfall.InfinitePiQ2FiniteLabelDoobDynkin.source_ae_comap_factors_as_label_table
#print axioms Nightfall.InfinitePiQ2FiniteLabelDoobDynkin.original_condExpL2_is_label_table_ae

end Nightfall.InfinitePiQ2FiniteLabelDoobDynkin
