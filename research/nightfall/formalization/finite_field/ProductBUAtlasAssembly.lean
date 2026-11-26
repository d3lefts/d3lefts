import ProductBUPhysicalAtlas
import ProductBUAxisBoundaryTerminal
import ProductBUConcreteHomotopy

/-! The actual augmented zero set has the old zero-fiber subtype topology.
The new atlas is constructed, rather than required as a premise.
Analytic regularity hypotheses are explicit; this is not yet ProductSphereZero. -/

open scoped Manifold Topology ContDiff
open Manifold
namespace Nightfall.ProductBUAtlasAssembly
noncomputable section
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUCompactFiber
open Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductBUParity
open Nightfall.ProductBUPhysicalAtlas
open Nightfall.ProductBUConcreteHomotopy

def time (k : ℕ) : SpaceTime (k+1) →L[ℝ] ℝ :=
  ContinuousLinearMap.snd ℝ (PairSpace (k+1)) ℝ

def augmented (k : ℕ) (F : SpaceTime (k+1) → Values (2*k))
    (p : SpaceTime (k+1)) : Values (2*k) × (ℝ × ℝ) :=
  (F p, (normDefect k p.1.1, normDefect k p.1.2))

theorem physical_eq_zeroFiber (k : ℕ) (F : SpaceTime (k+1) → Values (2*k)) :
    physical (augmented k F) (time k) = zeroFiber (k+1) (2*k) F := by
  ext p
  change (augmented k F p = 0 ∧ 0 ≤ p.2 ∧ p.2 ≤ 1) ↔
    ((UnitVec (k+1) p.1.1 ∧ UnitVec (k+1) p.1.2) ∧
      (0 ≤ p.2 ∧ p.2 ≤ 1)) ∧ F p = 0
  constructor
  · rintro ⟨hz, ht⟩
    have hf : F p = 0 := congrArg Prod.fst hz
    have hu : normDefect k p.1.1 = 0 :=
      congrArg (fun x : Values (2*k) × (ℝ × ℝ) => x.2.1) hz
    have hv : normDefect k p.1.2 = 0 :=
      congrArg (fun x : Values (2*k) × (ℝ × ℝ) => x.2.2) hz
    exact ⟨⟨⟨(normDefect_zero_iff k _).mp hu,
      (normDefect_zero_iff k _).mp hv⟩, ht⟩, hf⟩
  · rintro ⟨⟨⟨hu,hv⟩,ht⟩,hf⟩
    exact ⟨Prod.ext hf (Prod.ext ((normDefect_zero_iff k _).mpr hu)
      ((normDefect_zero_iff k _).mpr hv)), ht⟩

theorem augmented_finrank (k : ℕ) :
    Module.finrank ℝ (SpaceTime (k+1)) =
      Module.finrank ℝ (Values (2*k) × (ℝ × ℝ)) + 1 := by
  simp [SpaceTime, PairSpace, Values, Module.finrank_prod, Module.finrank_pi]
  omega

theorem augmented_smooth (k : ℕ) (F : SpaceTime (k+1) → Values (2*k))
    (hF : ContDiff ℝ (∞ : ℕ∞ω) F) :
    ContDiff ℝ (∞ : ℕ∞ω) (augmented k F) := by
  unfold augmented normDefect
  fun_prop

/-- Geometric composition on the actual augmented fiber. There is no
charted-space, manifold, boundary, or interval-component premise. -/
theorem regular_augmented_reference_fiber_impossible
    (k : ℕ) (F : SpaceTime (k+1) → Values (2*k))
    (hF : ContDiff ℝ (∞ : ℕ∞ω) F)
    (hreg : ∀ p ∈ physical (augmented k F) (time k),
      Function.Surjective (fderiv ℝ (augmented k F) p))
    (hentry : ∀ p ∈ physical (augmented k F) (time k), time k p = 0 →
      ((time k).prod (fderiv ℝ (augmented k F) p)).IsInvertible)
    (hnoexit : ∀ p ∈ physical (augmented k F) (time k), time k p ≠ 1)
    (hF0 : ∀ z ∈ SpherePair (k+1),
      (F (z,0) = 0 ↔
        (∀ i : Fin k, refU k z.1 z.2 i = 0) ∧
        (∀ i : Fin k, refV k z.1 z.2 i = 0)))
    (hFU : ∀ p, F p = 0 → F (flipU p) = 0)
    (hFV : ∀ p, F p = 0 → F (flipV p) = 0)
    (hFUV : ∀ p, F p = 0 → F (flipUV p) = 0) : False := by
  have hg := physical_regular_manifold (augmented k F) (time k)
    (augmented_smooth k F hF) (augmented_finrank k) hreg hentry hnoexit
  rw [physical_eq_zeroFiber k F] at hg
  obtain ⟨cs, hm, hb⟩ := hg
  letI : ChartedSpace (EuclideanHalfSpace 1) (Z (k+1) (2*k) F) := cs
  letI : IsManifold (𝓡∂ 1) (∞ : ℕ∞ω) (Z (k+1) (2*k) F) := hm
  apply Nightfall.ProductBUAxisBoundaryTerminal.actual_smooth_reference_boundary_impossible
    k (2*k) F hF.continuous hF0 hFU hFV hFUV
  intro z
  change z ∈ (𝓡∂ 1).boundary (Z (k+1) (2*k) F) ↔ z.1.2 = 0
  rw [hb]
  rfl

#print axioms physical_eq_zeroFiber
#print axioms augmented_finrank
#print axioms augmented_smooth
#print axioms regular_augmented_reference_fiber_impossible
end
end Nightfall.ProductBUAtlasAssembly
