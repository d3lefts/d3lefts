import MathlibExt.Geometry.Manifold.LocalParametrization

/-!
# Exact ATLAS local regular-fiber bridge for one-dimensional level sets

At NIGHTFALL's frozen Mathlib pin, the external ATLAS regularLevelSet_localParametrization
already constructs a local immersed chart for any regular level set with dimension gap 1.
This module instantiates that source at k=1, retaining its actual neighborhood-equality
certificate rather than asserting an unsupported global manifold structure.

The source is *not* the complete ProductSphereZero theorem. Additional proofs must assemble
the local charts, respect the time boundary, and apply the already checked 1D classification.
-/

open scoped Topology Manifold ContDiff
open Manifold

namespace Nightfall.ProductBURegularFiberLocal

/-- A C¹ Euclidean map with surjective derivative at a zero has a local
smooth one-dimensional immersed parametrization; its image equals the
actual local zero fiber, not merely an approximate tangent model. -/
theorem regular_fiber_has_local_one_dimensional_chart
    {m : ℕ}
    (f : EuclideanSpace ℝ (Fin (1 + m)) →
      EuclideanSpace ℝ (Fin m))
    (hf : ContDiff ℝ 1 f)
    (x₀ : EuclideanSpace ℝ (Fin (1 + m)))
    (hreg : Function.Surjective (fderiv ℝ f x₀)) :
    ∃ (U : Set (EuclideanSpace ℝ (Fin 1))) (_ : IsOpen U)
      (u₀ : EuclideanSpace ℝ (Fin 1)) (_ : u₀ ∈ U)
      (φ : EuclideanSpace ℝ (Fin 1) →
        EuclideanSpace ℝ (Fin (1 + m))),
      ContMDiff 𝓘(ℝ, EuclideanSpace ℝ (Fin 1))
          𝓘(ℝ, EuclideanSpace ℝ (Fin (1 + m))) 1 φ ∧
      IsImmersion 𝓘(ℝ, EuclideanSpace ℝ (Fin 1))
          𝓘(ℝ, EuclideanSpace ℝ (Fin (1 + m))) 1 φ ∧
      ∃ V ∈ 𝓝 x₀,
        φ '' (U ∩ φ ⁻¹' V) = V ∩ f ⁻¹' {f x₀} ∧
        φ u₀ = x₀ := by
  exact MathlibExt.Geometry.Manifold.LocalParametrizationWanted.regularLevelSet_localParametrization
    f hf x₀ hreg

#check regular_fiber_has_local_one_dimensional_chart
#print axioms regular_fiber_has_local_one_dimensional_chart

end Nightfall.ProductBURegularFiberLocal
