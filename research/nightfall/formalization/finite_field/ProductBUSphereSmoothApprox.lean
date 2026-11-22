import Mathlib
import ProductBUSphereExtension
import ProductBUSmoothCharacterApprox

/-!
# Sphere-relative smooth equivariant approximation (two independent signs)

This formally composes three separately sourced, pinned Lean mechanisms:
* closed-product-sphere exact Tietze extension (#1041, merged),
* four-term G=(Z/2)^2 character projection (parallel #1032),
* ambient C-infinity character-preserving approximation (#1037).

Every continuous-on-sphere pure-character scalar map has arbitrarily close
C-infinity *ambient* pure-character approximants. The original sign character
is only assumed on the sphere. No extra regularity at unreachable inputs
or topological zero theorem is assumed.

IMPORTANT: This closes the scalar analytic smoothing stage only. It does NOT
prove that an equivariant zero exists; the relative parametric transversality
and mod-two boundary-orbit parity remain separate mathematical obligations.
-/

namespace Nightfall.ProductBUSphereSmooth
open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSphereExtension
open Nightfall.ProductBUCharacterAverage
open Nightfall.ProductBUSmooth

abbrev V (n : ℕ) := Fin n → ℝ

theorem unitVec_neg (n : ℕ) (u : V n)
    (hu : UnitVec n u) : UnitVec n (-u) := by
  unfold UnitVec at hu ⊢
  simpa only [Pi.neg_apply, neg_sq] using hu

/-- The U projection of an ambient extension agrees exactly with the
original U-character function on both unit spheres. -/
theorem charU_extension_agrees (n : ℕ)
    (f g : V n → V n → ℝ)
    (heq : ∀ u v, UnitVec n u → UnitVec n v → g u v = f u v)
    (hleft : ∀ u v, UnitVec n u → UnitVec n v →
      f (-u) v = -f u v)
    (hright : ∀ u v, UnitVec n u → UnitVec n v →
      f u (-v) = f u v)
    (u v : V n) (hu : UnitVec n u) (hv : UnitVec n v) :
    charU g u v = f u v := by
  have h0 := heq u v hu hv
  have h1 := heq (-u) v (unitVec_neg n u hu) hv
  have h2 := heq u (-v) hu (unitVec_neg n v hv)
  have h3 := heq (-u) (-v) (unitVec_neg n u hu) (unitVec_neg n v hv)
  have hboth : f (-u) (-v) = -f u v := by
    rw [hright (-u) v (unitVec_neg n u hu) hv, hleft u v hu hv]
  unfold charU
  rw [h0, h1, h2, h3, hleft u v hu hv, hright u v hu hv, hboth]
  ring

theorem charV_extension_agrees (n : ℕ)
    (f g : V n → V n → ℝ)
    (heq : ∀ u v, UnitVec n u → UnitVec n v → g u v = f u v)
    (hleft : ∀ u v, UnitVec n u → UnitVec n v →
      f (-u) v = f u v)
    (hright : ∀ u v, UnitVec n u → UnitVec n v →
      f u (-v) = -f u v)
    (u v : V n) (hu : UnitVec n u) (hv : UnitVec n v) :
    charV g u v = f u v := by
  have h0 := heq u v hu hv
  have h1 := heq (-u) v (unitVec_neg n u hu) hv
  have h2 := heq u (-v) hu (unitVec_neg n v hv)
  have h3 := heq (-u) (-v) (unitVec_neg n u hu) (unitVec_neg n v hv)
  have hboth : f (-u) (-v) = -f u v := by
    rw [hright (-u) v (unitVec_neg n u hu) hv, hleft u v hu hv]
  unfold charV
  rw [h0, h1, h2, h3, hleft u v hu hv, hright u v hu hv, hboth]
  ring

/-- No global continuity assumption: the original response may be
continuous ONLY on the sphere product. Even then, it admits a smooth
global U-character approximant with a strict prescribed error there. -/
theorem exists_smooth_sphere_charU_approx (n : ℕ)
    (f : V n → V n → ℝ)
    (hf : ContinuousOn (fun z : V n × V n => f z.1 z.2)
      (SpherePair n))
    (hleft : ∀ u v, UnitVec n u → UnitVec n v →
      f (-u) v = -f u v)
    (hright : ∀ u v, UnitVec n u → UnitVec n v →
      f u (-v) = f u v)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ g : V n → V n → ℝ,
      ContDiff ℝ (↑(⊤ : ℕ∞))
        (fun z : V n × V n => g z.1 z.2) ∧
      (∀ u v, UnitVec n u → UnitVec n v →
        |g u v - f u v| < ε) ∧
      (∀ u v, g (-u) v = -g u v) ∧
      (∀ u v, g u (-v) = g u v) := by
  obtain ⟨G, hG, hEq⟩ :=
    exists_continuous_extension n (fun z : V n × V n => f z.1 z.2) hf
  let F : V n → V n → ℝ := fun u v => G (u,v)
  have hF : Continuous (fun z : V n × V n => F z.1 z.2) := by
    simpa only [F, Prod.mk.eta] using hG
  have hproj : ∀ u v, UnitVec n u → UnitVec n v →
      charU F u v = f u v := by
    intro u v hu hv
    exact charU_extension_agrees n f F
      (fun a b ha hb => hEq (show (a,b) ∈ SpherePair n from ⟨ha,hb⟩))
      hleft hright u v hu hv
  obtain ⟨g, hgsm, hgap, hgl, hgr⟩ :=
    exists_smooth_charU_approx n (charU F)
      (continuous_charU F hF)
      (charU_flip_left F) (charU_flip_right F) ε hε
  refine ⟨g, hgsm, ?_, hgl, hgr⟩
  intro u v hu hv
  simpa only [hproj u v hu hv] using hgap u v

theorem exists_smooth_sphere_charV_approx (n : ℕ)
    (f : V n → V n → ℝ)
    (hf : ContinuousOn (fun z : V n × V n => f z.1 z.2)
      (SpherePair n))
    (hleft : ∀ u v, UnitVec n u → UnitVec n v →
      f (-u) v = f u v)
    (hright : ∀ u v, UnitVec n u → UnitVec n v →
      f u (-v) = -f u v)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ g : V n → V n → ℝ,
      ContDiff ℝ (↑(⊤ : ℕ∞))
        (fun z : V n × V n => g z.1 z.2) ∧
      (∀ u v, UnitVec n u → UnitVec n v →
        |g u v - f u v| < ε) ∧
      (∀ u v, g (-u) v = g u v) ∧
      (∀ u v, g u (-v) = -g u v) := by
  obtain ⟨G, hG, hEq⟩ :=
    exists_continuous_extension n (fun z : V n × V n => f z.1 z.2) hf
  let F : V n → V n → ℝ := fun u v => G (u,v)
  have hF : Continuous (fun z : V n × V n => F z.1 z.2) := by
    simpa only [F, Prod.mk.eta] using hG
  have hproj : ∀ u v, UnitVec n u → UnitVec n v →
      charV F u v = f u v := by
    intro u v hu hv
    exact charV_extension_agrees n f F
      (fun a b ha hb => hEq (show (a,b) ∈ SpherePair n from ⟨ha,hb⟩))
      hleft hright u v hu hv
  obtain ⟨g, hgsm, hgap, hgl, hgr⟩ :=
    exists_smooth_charV_approx n (charV F)
      (continuous_charV F hF)
      (charV_flip_left F) (charV_flip_right F) ε hε
  refine ⟨g, hgsm, ?_, hgl, hgr⟩
  intro u v hu hv
  simpa only [hproj u v hu hv] using hgap u v

#print axioms unitVec_neg
#print axioms charU_extension_agrees
#print axioms charV_extension_agrees
#print exists_smooth_sphere_charU_approx
#print axioms exists_smooth_sphere_charU_approx
#print exists_smooth_sphere_charV_approx
#print axioms exists_smooth_sphere_charV_approx

end Nightfall.ProductBUSphereSmooth
