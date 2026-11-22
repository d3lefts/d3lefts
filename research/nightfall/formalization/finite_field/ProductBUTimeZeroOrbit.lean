import ProductBUFiberFreeAction
import ProductBUOrbitCertificate

/-!
# Actual time-zero boundary fiber: exactly one four-element sign orbit

The compiled reference-zero classifier from PR #1034 is lifted to the
ACTUAL zeroFiber subtype (rather than a synthetic boundary set).
If the augmented homotopy agrees at time zero with the source reference
map, every time-zero zero is in the orbit of any chosen time-zero zero.

No 1D manifold or ProductSphereZero hypothesis occurs in this module.
The hF0 property is an explicit equation that the final concrete
augmented family must discharge, not a topological axiom.
-/

namespace Nightfall.ProductBUTimeZeroOrbit

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUParity
open Nightfall.ProductBUOrbit
open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction

/-- Any two actual zero-fiber points on the time-zero face differ by
independent sign changes, when the initial response has exactly the
reference map's zero equations. -/
theorem time_zero_real_fiber_one_orbit
    (k m : ℕ)
    (F : SpaceTime (k + 1) → Values m)
    (hF0 : ∀ u v, UnitVec (k + 1) u → UnitVec (k + 1) v →
      F ((u,v), 0) = 0 →
      (∀ i : Fin k, refU k u v i = 0) ∧
      (∀ i : Fin k, refV k u v i = 0))
    (hFU : ∀ x, F x = 0 → F (flipU x) = 0)
    (hFV : ∀ x, F x = 0 → F (flipV x) = 0)
    (hFUV : ∀ x, F x = 0 → F (flipUV x) = 0)
    (p z : Z (k + 1) m F)
    (hp0 : p.1.2 = 0) (hz0 : z.1.2 = 0) :
    z = p ∨ z = eU (k + 1) m F hFU p ∨
      z = eV (k + 1) m F hFV p ∨
      z = eUV (k + 1) m F hFUV p := by
  have hp := zeroFiber_mem (k + 1) m F p.2
  have hz := zeroFiber_mem (k + 1) m F z.2
  have hpF : F (p.1.1, (0 : ℝ)) = 0 := by
    simpa only [hp0] using hp.2.2
  have hzF : F (z.1.1, (0 : ℝ)) = 0 := by
    simpa only [hz0] using hz.2.2
  obtain ⟨hpU, hpV⟩ := hF0 p.1.1.1 p.1.1.2 hp.1.1 hp.1.2 hpF
  obtain ⟨hzU, hzV⟩ := hF0 z.1.1.1 z.1.1.2 hz.1.1 hz.1.2 hzF
  obtain ⟨hU | hU, hV | hV⟩ :=
    reference_zeros_one_orbit k
      p.1.1.1 p.1.1.2 z.1.1.1 z.1.1.2
      hp.1.1 hp.1.2 hz.1.1 hz.1.2
      hpU hpV hzU hzV
  · left
    apply Subtype.ext
    exact Prod.ext (Prod.ext hU hV) (hz0.trans hp0.symm)
  · right; right; left
    apply Subtype.ext
    change z.1 = flipV p.1
    exact Prod.ext (Prod.ext hU hV) (hz0.trans hp0.symm)
  · right; left
    apply Subtype.ext
    change z.1 = flipU p.1
    exact Prod.ext (Prod.ext hU hV) (hz0.trans hp0.symm)
  · right; right; right
    apply Subtype.ext
    change z.1 = flipUV p.1
    exact Prod.ext (Prod.ext hU hV) (hz0.trans hp0.symm)

#check time_zero_real_fiber_one_orbit
#print axioms time_zero_real_fiber_one_orbit

end Nightfall.ProductBUTimeZeroOrbit
