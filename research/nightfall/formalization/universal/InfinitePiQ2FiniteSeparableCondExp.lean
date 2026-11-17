import InfinitePiQ2ConditionalSourceTest
import Mathlib.MeasureTheory.Function.ConditionalExpectation.Basic

/-!
# Original-product conditional expectation of finite separable sums

The certified one-coordinate independent-factor conditional expectation
extends to every finite real linear combination of such factors. All factors
and integrability hypotheses are explicit. No finite label source law is
substituted for Measure.infinitePi μ. This is a genuine intermediate gate,
not the unconditional infinite-product Q2 theorem.
-/

namespace Nightfall.InfinitePiQ2FiniteSeparableCondExp

open MeasureTheory
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2ConditionalSourceTest

universe u v w
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Genuine original-product conditional expectation distributes over any
finite combination of coordinate-test × complement-observable factors. -/
theorem source_condExp_finite_separable_sum
    {α : Type w} (s : Finset α) (i : ι)
    (h : α → X i → ℝ)
    (v : α → ((j : ι) → X j) → ℝ) :
    (∀ a ∈ s, Measurable (h a)) →
    (∀ a ∈ s, StronglyMeasurable[sourceOtherSigma (X := X) i] (v a)) →
    (∀ a ∈ s, Integrable (sourceOneCoordTest i (h a))
      (Measure.infinitePi μ)) →
    (∀ a ∈ s, Integrable (sourceOneCoordTest i (h a) * v a)
      (Measure.infinitePi μ)) →
    (Measure.infinitePi μ)[
      (fun x => ∑ a ∈ s, sourceOneCoordTest i (h a) x * v a x) |
      sourceOtherSigma (X := X) i] =ᵐ[Measure.infinitePi μ]
      (fun x => ∑ a ∈ s, (∫ b, h a b ∂ μ i) * v a x) := by
  classical
  induction s using Finset.induction with
  | empty =>
      intro _ _ _ _
      simp
  | @insert a s ha ih =>
      intro hmeas hother hintegrable hproduct
      let ν := Measure.infinitePi μ
      let m := sourceOtherSigma (X := X) i
      let f : α → ((j : ι) → X j) → ℝ :=
        fun b => sourceOneCoordTest i (h b) * v b
      let g : α → ((j : ι) → X j) → ℝ :=
        fun b x => (∫ z, h b z ∂ μ i) * v b x
      have hmeas_a : Measurable (h a) := hmeas a (Finset.mem_insert_self a s)
      have hother_a : StronglyMeasurable[m] (v a) :=
        hother a (Finset.mem_insert_self a s)
      have hint_a : Integrable (sourceOneCoordTest i (h a)) ν :=
        hintegrable a (Finset.mem_insert_self a s)
      have hprod_a : Integrable (f a) ν :=
        hproduct a (Finset.mem_insert_self a s)
      have hrest : ν[(fun x => ∑ b ∈ s, f b x) | m]
          =ᵐ[ν] (fun x => ∑ b ∈ s, g b x) := by
        exact ih
          (fun b hb => hmeas b (Finset.mem_insert_of_mem hb))
          (fun b hb => hother b (Finset.mem_insert_of_mem hb))
          (fun b hb => hintegrable b (Finset.mem_insert_of_mem hb))
          (fun b hb => hproduct b (Finset.mem_insert_of_mem hb))
      have hpart : ν[f a | m] =ᵐ[ν] g a := by
        exact source_condExp_coordinate_factor μ i (h a) hmeas_a
          (v a) hother_a hint_a hprod_a
      have hsum_integrable :
          Integrable (fun x => ∑ b ∈ s, f b x) ν := by
        exact integrable_finsetSum s
          (fun b hb => hproduct b (Finset.mem_insert_of_mem hb))
      have hcombined :
          ν[f a + (fun x => ∑ b ∈ s, f b x) | m] =ᵐ[ν]
            (fun x => g a x + ∑ b ∈ s, g b x) := by
        exact (condExp_add hprod_a hsum_integrable m).trans (hpart.add hrest)
      have hsource : (fun x : (j : ι) → X j =>
          ∑ b ∈ insert a s, sourceOneCoordTest i (h b) x * v b x) =
          (f a + fun x => ∑ b ∈ s, f b x) := by
        funext x
        simp [Finset.sum_insert ha, f]
      have htarget : (fun x : (j : ι) → X j =>
          ∑ b ∈ insert a s, (∫ z, h b z ∂ μ i) * v b x) =
          (fun x => g a x + ∑ b ∈ s, g b x) := by
        funext x
        simp [Finset.sum_insert ha, g]
      rw [hsource, htarget]
      exact hcombined

#print axioms Nightfall.InfinitePiQ2FiniteSeparableCondExp.source_condExp_finite_separable_sum
end Nightfall.InfinitePiQ2FiniteSeparableCondExp
