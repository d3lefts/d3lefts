import InfinitePiQ2DegreeRetraction
import Mathlib

/-!
# Degree-two is preserved by source-measure integration

This lemma justifies the algebraic part of the finite-table construction:
averaging an integrable family of pointwise quadratic observables over any
fixed auxiliary probability/finite measure preserves vanishing of every
mixed third difference. No atom, index-cardinality or common-alphabet
assumptions. The construction of the finite table and its source influence
comparison remain separate, unproved Lean obligations.
-/

namespace Nightfall.InfinitePiQ2DegreeAverage

open MeasureTheory
open Nightfall.InfinitePiQ2DegreeRetraction

universe u v w
variable {ι : Type u} [DecidableEq ι]
variable {A : ι → Type v}
variable {Ω : Type w} [MeasurableSpace Ω]

/-- Integrating a family of coordinate differences equals taking the
coordinate difference of its integrals. -/
theorem delta_integral
    (μ : Measure Ω) (f : Ω → ((i : ι) → A i) → ℝ)
    (hInt : ∀ x, Integrable (fun ω => f ω x) μ)
    (i : ι) (a b : A i) (x : (j : ι) → A j) :
    delta i a b (fun z => ∫ ω, f ω z ∂μ) x =
      ∫ ω, delta i a b (f ω) x ∂μ := by
  simp only [delta]
  rw [integral_sub (hInt _) (hInt _)]

/-- Integrable source sections have integrable coordinate differences. -/
theorem integrable_delta
    (μ : Measure Ω) (f : Ω → ((i : ι) → A i) → ℝ)
    (hInt : ∀ x, Integrable (fun ω => f ω x) μ)
    (i : ι) (a b : A i) (x : (j : ι) → A j) :
    Integrable (fun ω => delta i a b (f ω) x) μ := by
  change Integrable (fun ω => f ω (Function.update x i a) -
    f ω (Function.update x i b)) μ
  exact (hInt _).sub (hInt _)

/-- The third mixed difference commutes exactly with the original
integration operator; this is valid for all coordinate types and indices. -/
theorem delta_three_integral
    (μ : Measure Ω) (f : Ω → ((i : ι) → A i) → ℝ)
    (hInt : ∀ x, Integrable (fun ω => f ω x) μ)
    (i j k : ι)
    (a a' : A i) (b b' : A j) (c c' : A k)
    (x : (m : ι) → A m) :
    delta i a a' (delta j b b' (delta k c c'
      (fun z => ∫ ω, f ω z ∂μ))) x =
      ∫ ω, delta i a a' (delta j b b' (delta k c c' (f ω))) x ∂μ := by
  let fk : Ω → ((i : ι) → A i) → ℝ :=
    fun ω z => delta k c c' (f ω) z
  have hk : delta k c c' (fun z => ∫ ω, f ω z ∂μ) =
      (fun z => ∫ ω, fk ω z ∂μ) := by
    funext z
    exact delta_integral μ f hInt k c c' z
  have hfk : ∀ z, Integrable (fun ω => fk ω z) μ := by
    intro z
    exact integrable_delta μ f hInt k c c' z
  let fjk : Ω → ((i : ι) → A i) → ℝ :=
    fun ω z => delta j b b' (fk ω) z
  have hj : delta j b b' (fun z => ∫ ω, fk ω z ∂μ) =
      (fun z => ∫ ω, fjk ω z ∂μ) := by
    funext z
    exact delta_integral μ fk hfk j b b' z
  have hfjk : ∀ z, Integrable (fun ω => fjk ω z) μ := by
    intro z
    exact integrable_delta μ fk hfk j b b' z
  calc
    delta i a a' (delta j b b' (delta k c c'
        (fun z => ∫ ω, f ω z ∂μ))) x =
        delta i a a' (delta j b b'
          (fun z => ∫ ω, fk ω z ∂μ)) x := by rw [hk]
    _ = delta i a a' (fun z => ∫ ω, fjk ω z ∂μ) x := by rw [hj]
    _ = ∫ ω, delta i a a' (fjk ω) x ∂μ :=
      delta_integral μ fjk hfjk i a a' x
    _ = ∫ ω, delta i a a' (delta j b b' (delta k c c' (f ω))) x ∂μ := rfl

/-- Pointwise Efron-Stein degree at most two is stable under integration
of any family of integrable degree-two real observables. -/
theorem degree_two_under_integral
    (μ : Measure Ω) (f : Ω → ((i : ι) → A i) → ℝ)
    (hInt : ∀ x, Integrable (fun ω => f ω x) μ)
    (hdegree : ∀ ω, PointwiseDegreeTwo (f ω)) :
    PointwiseDegreeTwo (fun x => ∫ ω, f ω x ∂μ) := by
  intro i j k hij hik hjk a a' b b' c c' x
  rw [delta_three_integral μ f hInt i j k a a' b b' c c' x]
  have hzero : (fun ω =>
      delta i a a' (delta j b b' (delta k c c' (f ω))) x) =
      (fun _ : Ω => (0 : ℝ)) := by
    funext ω
    exact hdegree ω i j k hij hik hjk a a' b b' c c' x
  rw [hzero]
  simp

end Nightfall.InfinitePiQ2DegreeAverage
