import InfinitePiQ2InfluenceStability
import Mathlib.Probability.Independence.InfinitePi

/-!
# Actual infinite-product coordinate-versus-complement independence

An arbitrary original product measure (including noncountable sites,
heterogeneous atomless factors and zero atoms) has its entire complement
independent of each single site. This is source-specific probability
structure used to identify the one-site marginal heat-bath with the
genuine L² conditional expectation. No conditional-expectation identity
is asserted by this module.
-/

namespace Nightfall.InfinitePiQ2OriginalIndependence

open MeasureTheory ProbabilityTheory
open Nightfall.InfinitePiQ2InfluenceStability

universe u v
variable {ι : Type u} {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i))
variable [∀ i, IsProbabilityMeasure (μ i)]

/-- Independence of the full vector at all sites except i from the
singleton-index source vector, in the actual Measure.infinitePi law. -/
theorem source_singleton_other_indepFun (i : ι) :
    IndepFun
      (fun x : (j : ι) → X j => (fun j : ({i} : Set ι) => x j))
      (fun x : (j : ι) → X j =>
        (fun j : sourceOtherIndices i => x j))
      (Measure.infinitePi μ) := by
  let S : Set ι := {i}
  let T : Set ι := sourceOtherIndices i
  have hST : Disjoint S T := by
    apply Set.disjoint_left.mpr
    intro j hjS hjT
    have hji : j = i := by simpa [S] using hjS
    have hne : j ≠ i := by simpa [T, sourceOtherIndices] using hjT
    exact hne hji
  have hindep : iIndepFun
      (fun j (x : (k : ι) → X k) => x j)
      (Measure.infinitePi μ) :=
    iIndepFun_infinitePi (X := fun j (x : X j) => x)
      (by intro j; exact measurable_id)
  have h := hindep.indepFun_set S T hST (by intro j; fun_prop)
  simpa only [S, T, sourceOtherIndices] using h

/-- The actual original coordinate value and its entire other-coordinate
vector are independent. This includes uncountable index sets. -/
theorem source_coordinate_other_indepFun (i : ι) :
    IndepFun
      (fun x : (j : ι) → X j => x i)
      (fun x : (j : ι) → X j =>
        (fun j : sourceOtherIndices i => x j))
      (Measure.infinitePi μ) := by
  let S : Set ι := {i}
  let eval : ((j : S) → X j) → X i :=
    fun y => y ⟨i, by simp [S]⟩
  have heval : Measurable eval := by
    dsimp [eval]
    fun_prop
  have h := (source_singleton_other_indepFun μ i).comp heval measurable_id
  simpa only [Function.comp_def, eval, S, id_eq] using h

end Nightfall.InfinitePiQ2OriginalIndependence
