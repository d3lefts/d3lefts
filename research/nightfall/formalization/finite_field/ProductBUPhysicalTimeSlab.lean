import ProductBUTimeHalfspaceChart
import ProductBUCompactFiber

/-!
# Actual physical product-sphere fiber to time-first slab chart coordinates

The physical zero fiber Z n m F is the genuine subtype of
((u,v),t) : PairSpace n × Real. The time-graph chart source uses
(t,(u,v)) in (Set.Icc 0 1) × PairSpace n. This module constructs
a real Homeomorph between the two ACTUAL subtype spaces and
transports the genuine half-space chart back to the physical fiber.

No smoothness, Sard regularity, analytic implicit-function
assumptions, or universal ProductSphereZero are inferred from this
topological reordering. It removes a genuine source-space equality
gap in the intended full atlas assembly.
-/

open scoped Topology Manifold ContDiff
open Manifold

namespace Nightfall.ProductBUPhysicalTimeSlab

open Nightfall.ProductBUCompactFiber
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUTimeHalfspaceChart

/-- Actual zero equations on the time-FIRST closed slab.
This set is definitionally the physical zero-fiber in rearranged
coordinates, including both sphere constraints, rather than
a newly assumed manifold or a virtual homotopy fiber. -/
def timeFirstZeroFiber (n m : ℕ) (F : SpaceTime n → Values m) :
    Set (TimeSlab × PairSpace n) :=
  { p | p.2 ∈ SpherePair n ∧ F (p.2, p.1.val) = 0 }

/-- Source-exact homeomorphism between the original physical
product-sphere zero fiber with time LAST, and the exact SAME
zeros in the canonical time-slab-first coordinates. -/
def physicalTimeSlabHomeomorph (n m : ℕ)
    (F : SpaceTime n → Values m) :
    zeroFiber n m F ≃ₜ timeFirstZeroFiber n m F where
  toFun := fun p =>
    ⟨(⟨p.val.2, (zeroFiber_mem n m F p.property).2.1⟩, p.val.1),
      ⟨(zeroFiber_mem n m F p.property).1,
        (zeroFiber_mem n m F p.property).2.2⟩⟩
  invFun := fun q =>
    ⟨(q.val.2, q.val.1.val),
      ⟨⟨q.property.1, q.val.1.property⟩, q.property.2⟩⟩
  left_inv := by
    intro p
    apply Subtype.ext
    rfl
  right_inv := by
    intro q
    apply Subtype.ext
    rfl
  continuous_toFun := by
    apply Continuous.subtype_mk
    apply Continuous.prodMk
    · apply Continuous.subtype_mk
      exact continuous_snd.comp continuous_subtype_val
    · exact continuous_fst.comp continuous_subtype_val
  continuous_invFun := by
    apply Continuous.subtype_mk
    apply Continuous.prodMk
    · exact continuous_snd.comp continuous_subtype_val
    · exact continuous_subtype_val.comp
        (continuous_fst.comp continuous_subtype_val)

/-- This is a genuine `OpenPartialHomeomorph` on the *physical* zero fiber,
not merely the time-first surrogate. Its local graph assumptions are
about the explicitly defined time-first image set, so all conditions
can be checked against the actual augmented homotopy equations.

It does NOT assert that those local graph assumptions hold at every
fiber point or produce the final global C-infinity atlas. -/
noncomputable def physical_time_zero_halfspace_chart
    (n m : ℕ) (F : SpaceTime n → Values m)
    (U : Set TimeSlab)
    (V : Set (TimeSlab × PairSpace n))
    (g : TimeSlab → PairSpace n)
    (hU : IsOpen U) (hV : IsOpen V)
    (hg : ContinuousOn g U)
    (hshape : ∀ z ∈ V,
      (z ∈ timeFirstZeroFiber n m F ↔
        z.1 ∈ U ∧ z.2 = g z.1))
    (x₀ : timeFirstZeroFiber n m F) :
    OpenPartialHomeomorph (zeroFiber n m F) (EuclideanHalfSpace 1) :=
  (physicalTimeSlabHomeomorph n m F).toOpenPartialHomeomorph.trans
    (actual_time_graph_halfspace_chart
      (timeFirstZeroFiber n m F) U V g hU hV hg hshape x₀)

#check timeFirstZeroFiber
#check physicalTimeSlabHomeomorph
#print axioms physicalTimeSlabHomeomorph
#check physical_time_zero_halfspace_chart
#print axioms physical_time_zero_halfspace_chart

end Nightfall.ProductBUPhysicalTimeSlab
