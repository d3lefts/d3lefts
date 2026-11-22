import Mathlib
import ProductBUSphereSmoothApprox

/-!
# Simultaneous smooth approximation of both pure-character blocks

This composes the source-pinned scalar sphere-relative theorems of #1046
into a single finite block certificate. It preserves:
* the original continuity-only-on-SpherePair hypotheses;
* both independent antipodal sign characters;
* global ambient C-infinity regularity of every coordinate;
* strict, arbitrarily small uniform coordinate error on SpherePair.

This finite-choice construction does NOT assert an equivariant zero,
nonvanishing of the approximants, parametric transversality,
or any topological ProductSphereZero theorem.

Source provenance: ProductBUCharacterAverage (#1032), SmoothCharacterApprox
(#1037), ProductBUSphereExtension (#1041), SphereSmoothApprox (#1046).
-/

namespace Nightfall.ProductBUVectorSmooth

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUSphereSmooth

abbrev V (n : ℕ) := Fin n → ℝ
abbrev PureBlock (n k : ℕ) := V n → V n → Fin k → ℝ

/-- Coordinatewise finite-choice construction of smooth U and V blocks,
with the exact separate sign characters everywhere in Euclidean space.
The original map is only continuous/equivariant on the product spheres. -/
theorem exists_smooth_pure_blocks_approx
    (n k : ℕ)
    (fU fV : PureBlock n k)
    (hcU : ∀ i : Fin k, ContinuousOn
      (fun p : V n × V n => fU p.1 p.2 i) (SpherePair n))
    (hcV : ∀ i : Fin k, ContinuousOn
      (fun p : V n × V n => fV p.1 p.2 i) (SpherePair n))
    (hUleft : ∀ u v (i : Fin k), UnitVec n u → UnitVec n v →
      fU (-u) v i = -fU u v i)
    (hUright : ∀ u v (i : Fin k), UnitVec n u → UnitVec n v →
      fU u (-v) i = fU u v i)
    (hVleft : ∀ u v (i : Fin k), UnitVec n u → UnitVec n v →
      fV (-u) v i = fV u v i)
    (hVright : ∀ u v (i : Fin k), UnitVec n u → UnitVec n v →
      fV u (-v) i = -fV u v i)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ gU gV : PureBlock n k,
      (∀ i : Fin k, ContDiff ℝ (↑(⊤ : ℕ∞))
        (fun p : V n × V n => gU p.1 p.2 i)) ∧
      (∀ i : Fin k, ContDiff ℝ (↑(⊤ : ℕ∞))
        (fun p : V n × V n => gV p.1 p.2 i)) ∧
      (∀ u v (i : Fin k), UnitVec n u → UnitVec n v →
        |gU u v i - fU u v i| < ε) ∧
      (∀ u v (i : Fin k), UnitVec n u → UnitVec n v →
        |gV u v i - fV u v i| < ε) ∧
      (∀ u v (i : Fin k), gU (-u) v i = -gU u v i) ∧
      (∀ u v (i : Fin k), gU u (-v) i = gU u v i) ∧
      (∀ u v (i : Fin k), gV (-u) v i = gV u v i) ∧
      (∀ u v (i : Fin k), gV u (-v) i = -gV u v i) := by
  classical
  have hchoicesU : ∀ i : Fin k,
      ∃ g : V n → V n → ℝ,
        ContDiff ℝ (↑(⊤ : ℕ∞))
          (fun p : V n × V n => g p.1 p.2) ∧
        (∀ u v, UnitVec n u → UnitVec n v →
          |g u v - fU u v i| < ε) ∧
        (∀ u v, g (-u) v = -g u v) ∧
        (∀ u v, g u (-v) = g u v) := by
    intro i
    exact exists_smooth_sphere_charU_approx n (fun u v => fU u v i)
      (hcU i)
      (fun u v hu hv => hUleft u v i hu hv)
      (fun u v hu hv => hUright u v i hu hv) ε hε
  have hchoicesV : ∀ i : Fin k,
      ∃ g : V n → V n → ℝ,
        ContDiff ℝ (↑(⊤ : ℕ∞))
          (fun p : V n × V n => g p.1 p.2) ∧
        (∀ u v, UnitVec n u → UnitVec n v →
          |g u v - fV u v i| < ε) ∧
        (∀ u v, g (-u) v = g u v) ∧
        (∀ u v, g u (-v) = -g u v) := by
    intro i
    exact exists_smooth_sphere_charV_approx n (fun u v => fV u v i)
      (hcV i)
      (fun u v hu hv => hVleft u v i hu hv)
      (fun u v hu hv => hVright u v i hu hv) ε hε
  choose U hU_smooth hU_gap hU_flipL hU_flipR using hchoicesU
  choose Vmap hV_smooth hV_gap hV_flipL hV_flipR using hchoicesV
  refine ⟨(fun u v i => U i u v), (fun u v i => Vmap i u v),
    ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro i
    exact hU_smooth i
  · intro i
    exact hV_smooth i
  · intro u v i hu hv
    exact hU_gap i u v hu hv
  · intro u v i hu hv
    exact hV_gap i u v hu hv
  · intro u v i
    exact hU_flipL i u v
  · intro u v i
    exact hU_flipR i u v
  · intro u v i
    exact hV_flipL i u v
  · intro u v i
    exact hV_flipR i u v

#print exists_smooth_pure_blocks_approx
#print axioms exists_smooth_pure_blocks_approx

end Nightfall.ProductBUVectorSmooth
