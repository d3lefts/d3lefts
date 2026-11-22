import Mathlib

/-!
# A free action cannot preserve an interval component

The product-sphere cobordism proof needs an endpoint orbit contradiction.
It is enough to show an *individual nonidentity group element* cannot
preserve an interval component of a free G action: its induced continuous
self-map of [0,1] must have a fixed point.

This is stronger structurally than doing a global mod-eight count over
finitely many components. If the time-zero boundary is one G-orbit of
four points, the OTHER endpoint of the interval containing any fixed
reference endpoint is another element of that same orbit. The
corresponding group element must stabilize the interval component and
then have a fixed point — contradiction.

The theorem below is purely topological. It proves no existence of
the regular zero-fiber 1-manifold or its interval component. It uses
only the standard real intermediate value theorem and the closed-set
continuous-extension theorem to provide a *noncircular* fixed point
witness on an arbitrary continuously self-mapped interval subtype.
-/

namespace Nightfall.ProductBUInterval

def I01 := Set.Icc (0 : ℝ) 1

/-- Every continuous endomap of the closed interval, represented as
a subtype, has an actual fixed point. The proof extends the scalar
response from the closed interval to R via the standard Tietze theorem,
then applies the real intermediate value fixed-point result. -/
theorem interval_endomap_has_fixed_point (f : I01 → I01)
    (hf : Continuous f) : ∃ t : I01, f t = t := by
  let g : C(I01, ℝ) :=
    ⟨fun t => (f t).1, continuous_subtype_val.comp hf⟩
  obtain ⟨G, hG⟩ := ContinuousMap.exists_restrict_eq
    (isClosed_Icc : IsClosed (Set.Icc (0 : ℝ) 1)) g
  have h0 : (0 : ℝ) ≤ G 0 := by
    have h := congrArg
      (fun H : C(I01, ℝ) => H ⟨0, by simp [I01]⟩) hG
    have hval : (G 0 : ℝ) = (f ⟨0, by simp [I01]⟩).1 := by
      change G 0 = (f ⟨0, by simp [I01]⟩).1 at h
      exact h
    rw [hval]
    exact (f ⟨0, by simp [I01]⟩).2.1
  have h1 : (G 1 : ℝ) ≤ 1 := by
    have h := congrArg
      (fun H : C(I01, ℝ) => H ⟨1, by simp [I01]⟩) hG
    have hval : (G 1 : ℝ) = (f ⟨1, by simp [I01]⟩).1 := by
      change G 1 = (f ⟨1, by simp [I01]⟩).1 at h
      exact h
    rw [hval]
    exact (f ⟨1, by simp [I01]⟩).2.2
  obtain ⟨t, ht, hfixed⟩ :=
    exists_mem_Icc_isFixedPt
      (a := (0 : ℝ)) (b := (1 : ℝ))
      G.continuous.continuousOn (by norm_num) h0 h1
  refine ⟨⟨t, ht⟩, ?_⟩
  apply Subtype.ext
  have h := congrArg
    (fun H : C(I01, ℝ) => H ⟨t, ht⟩) hG
  change G t = (f ⟨t, ht⟩).1 at h
  exact h.symm.trans hfixed

/-- A continuously embedded closed interval is impossible as a
forward-invariant subset for a continuous fixed-point-free self-map.

This is the exact algebraic endpoint stabilizer contradiction used
when a nonidentity group element preserves a component of the
regular 1-dimensional zero fiber. No group cardinality or finite
component enumeration is needed. -/
theorem no_fixedpoint_free_invariant_interval
    {X : Type*} [TopologicalSpace X]
    (C : Set X) (hI : C ≃ₜ I01)
    (g : X → X) (hg : Continuous g)
    (hC : Set.MapsTo g C C)
    (hfree : ∀ x ∈ C, g x ≠ x) : False := by
  let gC : C → C := fun x => ⟨g x.1, hC x.2⟩
  have hgC : Continuous gC := by
    apply Continuous.subtype_mk
    exact hg.comp continuous_subtype_val
  let f : I01 → I01 := fun t => hI (gC (hI.symm t))
  have hf : Continuous f :=
    hI.continuous.comp (hgC.comp hI.symm.continuous)
  obtain ⟨t, ht⟩ := interval_endomap_has_fixed_point f hf
  have htC : gC (hI.symm t) = hI.symm t := by
    apply hI.injective
    simpa [f] using ht
  have hgpoint : g (hI.symm t).1 = (hI.symm t).1 :=
    congrArg Subtype.val htC
  exact hfree (hI.symm t).1 (hI.symm t).2 hgpoint

#print interval_endomap_has_fixed_point
#print axioms interval_endomap_has_fixed_point
#print no_fixedpoint_free_invariant_interval
#print axioms no_fixedpoint_free_invariant_interval

end Nightfall.ProductBUInterval
