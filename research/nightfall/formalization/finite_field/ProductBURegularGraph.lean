import MathlibExt.Geometry.Manifold.LocalGraph

/-!
# Genuine local graph coordinates for a one-dimensional regular fiber

Extracts explicit coordinate recovery and injectivity from the frozen ATLAS
regular-level-set local graph theorem. This is the *embedding* bridge: the
published external theorem gave a smooth graph and exact local level-set
equality; this module additionally isolates a coordinate-inverse equation
and uniqueness of its graph parametrization.

This is not a claim that the full fiber has already been given a global
ChartedSpace or a manifold-with-boundary instance. That remains a separate
source-exact integration obligation for ProductSphereZero.
-/

namespace Nightfall.ProductBURegularGraph

open scoped Topology
noncomputable section

/-- Extract a genuine one-dimensional graph coordinate from the regular
level-set theorem, not only an immersed local parametrization. -/
theorem regular_fiber_has_local_injective_graph
    {m : ℕ}
    (f : EuclideanSpace ℝ (Fin (1 + m)) → EuclideanSpace ℝ (Fin m))
    (hf : ContDiff ℝ 1 f)
    (x₀ : EuclideanSpace ℝ (Fin (1 + m)))
    (hreg : Function.Surjective (fderiv ℝ f x₀)) :
    ∃ (e : EuclideanSpace ℝ (Fin (1 + m)) ≃L[ℝ]
          (EuclideanSpace ℝ (Fin 1) × EuclideanSpace ℝ (Fin m)))
      (U : Set (EuclideanSpace ℝ (Fin 1)))
      (_ : U ∈ 𝓝 (e x₀).1)
      (g : EuclideanSpace ℝ (Fin 1) → EuclideanSpace ℝ (Fin m)),
      ContDiffOn ℝ 1 g U ∧
      ∃ V ∈ 𝓝 x₀,
        (∀ z ∈ V,
          f z = f x₀ ↔ (e z).1 ∈ U ∧ (e z).2 = g (e z).1) ∧
        Function.Injective (fun a : EuclideanSpace ℝ (Fin 1) =>
          e.symm (a, g a)) := by
  obtain ⟨e, U, hU, g, hg, V, hV, hgraph⟩ :=
    MathlibExt.Geometry.Manifold.LocalGraphWanted.regularLevelSet_localGraph
      f hf x₀ hreg
  refine ⟨e, U, hU, g, hg, V, hV, ?_, ?_⟩
  · intro z hz
    have h := congrArg (fun s : Set (EuclideanSpace ℝ (Fin (1 + m))) =>
      z ∈ s) hgraph
    simpa [hz] using h
  · intro a b h
    have h' := congrArg e h
    have hp := congrArg Prod.fst h'
    simpa using hp

#check regular_fiber_has_local_injective_graph
#print axioms regular_fiber_has_local_injective_graph

end Nightfall.ProductBURegularGraph
