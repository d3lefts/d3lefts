import Mathlib
import ProductBUComponentOrbit

/-!
# Compact 1D zero-fiber boundary-pairing closure

The previous interval-orbit contradiction required explicitly providing
the second boundary point q in the same connected component. Here q
is constructed from the opposite endpoint of an interval homeomorphism.

This is the reusable final component-level assembly for the four-point
reference orbit, using connected components rather than mod-8 arithmetic.
The global smooth manifold-with-boundary instance on the physical zero
fiber remains a separate explicit dependency; no ProductSphereZero is
declared by this file.
-/

namespace Nightfall.ProductBUBoundaryAssembly

open Nightfall.ProductBUInterval
open Nightfall.ProductBUComponentOrbit

def zeroEnd : I01 := ⟨0, by norm_num⟩
def oneEnd : I01 := ⟨1, by norm_num⟩

theorem zeroEnd_ne_oneEnd : zeroEnd ≠ oneEnd := by
  intro h
  have hh := congrArg Subtype.val h
  norm_num [zeroEnd, oneEnd] at hh

/-- The endpoints of a connected interval component are distinct
ambient points. -/
theorem interval_opposite_endpoints_distinct
    {X : Type*} [TopologicalSpace X] (p : X)
    (hI : connectedComponent p ≃ₜ I01) :
    (hI.symm zeroEnd).1 ≠ (hI.symm oneEnd).1 := by
  intro heq
  have hsub : hI.symm zeroEnd = hI.symm oneEnd :=
    Subtype.ext heq
  have hends : zeroEnd = oneEnd := hI.symm.injective hsub
  exact zeroEnd_ne_oneEnd hends

/-- If the reference zero p is an endpoint of its interval component,
the opposite endpoint is a DIFFERENT boundary point, and is therefore
a nonidentity antipode of p by the single-orbit reference certificate.
That antipode stabilizes the component and fixes a point, contradiction.

The hypotheses explicitly retain the actual interval component and its
geometric boundary identification. These are the remaining obligations
of the global regular zero-fiber construction.
-/
theorem no_free_four_orbit_when_component_endpoints_are_boundary
    {X : Type*} [TopologicalSpace X]
    (eU eV eUV : X ≃ₜ X)
    (boundary : Set X) (p : X)
    (hI : connectedComponent p ≃ₜ I01)
    (hboundary : ∀ z ∈ boundary,
      z = p ∨ z = eU p ∨ z = eV p ∨ z = eUV p)
    (hpEnd : hI ⟨p, mem_connectedComponent⟩ = zeroEnd ∨
      hI ⟨p, mem_connectedComponent⟩ = oneEnd)
    (hend0 : (hI.symm zeroEnd).1 ∈ boundary)
    (hend1 : (hI.symm oneEnd).1 ∈ boundary)
    (hfreeU : ∀ x ∈ connectedComponent p, eU x ≠ x)
    (hfreeV : ∀ x ∈ connectedComponent p, eV x ≠ x)
    (hfreeUV : ∀ x ∈ connectedComponent p, eUV x ≠ x) : False := by
  have hneq := interval_opposite_endpoints_distinct p hI
  rcases hpEnd with hp0 | hp1
  · have hpval : (hI.symm zeroEnd).1 = p := by
      have h : hI.symm zeroEnd =
          (⟨p, mem_connectedComponent⟩ : connectedComponent p) := by
        rw [← hp0]
        simp
      exact congrArg Subtype.val h
    have hqne : (hI.symm oneEnd).1 ≠ p := by
      intro h
      exact hneq (hpval.trans h)
    exact no_free_single_four_orbit_boundary_component
      eU eV eUV boundary p ((hI.symm oneEnd).1)
      hboundary hend1 hqne (hI.symm oneEnd).2 hI
      hfreeU hfreeV hfreeUV
  · have hpval : (hI.symm oneEnd).1 = p := by
      have h : hI.symm oneEnd =
          (⟨p, mem_connectedComponent⟩ : connectedComponent p) := by
        rw [← hp1]
        simp
      exact congrArg Subtype.val h
    have hqne : (hI.symm zeroEnd).1 ≠ p := by
      intro h
      exact hneq (h.trans hpval.symm)
    exact no_free_single_four_orbit_boundary_component
      eU eV eUV boundary p ((hI.symm zeroEnd).1)
      hboundary hend0 hqne (hI.symm zeroEnd).2 hI
      hfreeU hfreeV hfreeUV

#check interval_opposite_endpoints_distinct
#print axioms interval_opposite_endpoints_distinct
#check no_free_four_orbit_when_component_endpoints_are_boundary
#print axioms no_free_four_orbit_when_component_endpoints_are_boundary

end Nightfall.ProductBUBoundaryAssembly
