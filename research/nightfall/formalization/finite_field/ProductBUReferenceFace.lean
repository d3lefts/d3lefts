import Mathlib
import ProductBUOrbitCertificate
import ProductBUCompactFiber

/-!
# Exact reference face of the genuine product-sphere time-slab zero fiber

The zero locus at t=0 of a homotopy which equals the reference tail
map is EXACTLY the four independently signed axis pairs. This
formalizes an endpoint-set identity, not merely an orbit count.

No manifold-with-boundary, regularity, transversality, or
ProductSphereZero theorem is assumed or proved. The only hypothesis
in the general time-face transfer is that the actual t=0 zeros
coincide with those of the explicit reference map.

Dependencies:
  #1024  reference pure-character tail map
  #1034  entire reference-zero classification
  #1080  actual compact zero-fiber model and membership
-/

namespace Nightfall.ProductBUReferenceFace

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUParity
open Nightfall.ProductBUOrbit
open Nightfall.ProductBUCompactFiber

/-- The actual reference zero set on both unit spheres. -/
def referenceZero (k : ℕ) : Set (PairSpace (k + 1)) :=
  {p | p ∈ SpherePair (k + 1) ∧
    (∀ i : Fin k, refU k p.1 p.2 i = 0) ∧
    (∀ i : Fin k, refV k p.1 p.2 i = 0)}

/-- Four independently signed axis pairs, without a quotient. -/
def signedAxes (k : ℕ) : Set (PairSpace (k + 1)) :=
  {p | (p.1 = axis k ∨ p.1 = -axis k) ∧
    (p.2 = axis k ∨ p.2 = -axis k)}

private theorem unit_neg (n : ℕ) (u : Fin n → ℝ)
    (h : UnitVec n u) : UnitVec n (-u) := by
  simpa only [UnitVec, Pi.neg_apply, neg_sq] using h

private theorem signed_axis_unit (k : ℕ) (u : Fin (k + 1) → ℝ)
    (h : u = axis k ∨ u = -axis k) : UnitVec (k + 1) u := by
  rcases h with h | h
  · rw [h]
    exact axis_unit k
  · rw [h]
    exact unit_neg (k + 1) (axis k) (axis_unit k)

private theorem signed_axis_tailU (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (h : u = axis k ∨ u = -axis k) :
    ∀ i : Fin k, refU k u v i = 0 := by
  rcases h with h | h
  · rw [h]
    intro i
    exact axis_tail k i
  · rw [h]
    intro i
    rw [refU_flip_left]
    simp [refU, axis_tail]

private theorem signed_axis_tailV (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (h : v = axis k ∨ v = -axis k) :
    ∀ i : Fin k, refV k u v i = 0 := by
  rcases h with h | h
  · rw [h]
    intro i
    exact axis_tail k i
  · rw [h]
    intro i
    rw [refV_flip_right]
    simp [refV, axis_tail]

/-- The reference zero set is *equal*, as a set, to the four signed
axis pairs. This retains the original (u,v) coordinates and works
also at k=0, where the codomain has no tail coordinates. -/
theorem referenceZero_eq_signedAxes (k : ℕ) :
    referenceZero k = signedAxes k := by
  ext p
  constructor
  · rintro ⟨⟨hu, hv⟩, hU, hV⟩
    exact reference_zero_axis_classification k p.1 p.2 hu hv hU hV
  · intro hp
    obtain ⟨hu, hv⟩ : (p.1 = axis k ∨ p.1 = -axis k) ∧
        (p.2 = axis k ∨ p.2 = -axis k) := hp
    exact ⟨⟨signed_axis_unit k p.1 hu,
      signed_axis_unit k p.2 hv⟩,
      signed_axis_tailU k p.1 p.2 hu,
      signed_axis_tailV k p.1 p.2 hv⟩

/-- The t=0 face of the *actual* zero-fiber is precisely the signed
reference axes, provided the source response at t=0 has exactly the
same zeros as the reference tail map. The precondition will be
discharged by unfolding the concrete augmented homotopy; it is not a
topological zero-existence assumption. -/
theorem zeroFiber_time_zero_iff (k m : ℕ)
    (F : SpaceTime (k + 1) → Values m)
    (hF0 : ∀ z ∈ SpherePair (k + 1),
      (F (z, 0) = 0 ↔
        (∀ i : Fin k, refU k z.1 z.2 i = 0) ∧
        (∀ i : Fin k, refV k z.1 z.2 i = 0)))
    (z : PairSpace (k + 1)) :
    (z, (0 : ℝ)) ∈ zeroFiber (k + 1) m F ↔ z ∈ signedAxes k := by
  constructor
  · intro hz
    have hs := zeroFiber_mem (k + 1) m F hz
    have hr : z ∈ referenceZero k :=
      ⟨hs.1, (hF0 z hs.1).mp hs.2.2⟩
    simpa only [referenceZero_eq_signedAxes k] using hr
  · intro hz
    have hr : z ∈ referenceZero k := by
      rw [referenceZero_eq_signedAxes]
      exact hz
    refine ⟨⟨hr.1, ?_⟩, ?_⟩
    · norm_num
    · exact (hF0 z hr.1).mpr ⟨hr.2.1, hr.2.2⟩

#print referenceZero_eq_signedAxes
#print axioms referenceZero_eq_signedAxes
#print zeroFiber_time_zero_iff
#print axioms zeroFiber_time_zero_iff

end Nightfall.ProductBUReferenceFace
