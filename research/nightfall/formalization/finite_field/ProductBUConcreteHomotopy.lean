import Mathlib
import ProductBUAugmentedRank
import ProductBUParityReference

/-!
# The concrete equivariant parametric homotopy for maximal product-sphere BU

This is the actual finite-dimensional parameter family required before
applying the source-pinned ATLAS Euclidean parametric Sard theorem.
The previous right-inverse theorem in ProductBUAugmentedRank proved only
an ABSTRACT derivative-surjectivity scheme for arbitrary spatial D.

Here we define the true H_{A,B}(u,v,t) = (1-t)F0(u,v) + t F1(u,v)
  + t(1-t)(Au,Bv)
and prove:
 - both exact endpoints, for every parameter, not just approximately;
 - both independent antipodal characters at ALL ambient coordinates/times;
 - the sphere-equation augmentation vanishes iff u,v are actual unit;
 - all named scalar coordinates of the augmented family are C-infinity
   whenever F1's corresponding scalar coordinates are C-infinity.

The actual Fréchet derivative identity, regular slice, and global
manifold-with-boundary assembly are separate proof obligations. This file
does not claim ProductSphereZero or import it as an axiom.

Source dependencies: #1032 original finite-parameter rank-one map;
#1050 abstract all-time right inverse; #1024 reference parity map.
-/

namespace Nightfall.ProductBUConcreteHomotopy

open Nightfall.ProductSphereObstruction
open Nightfall.ProductBUParity
open Nightfall.ProductBUPerturbation
open Nightfall.ProductBUAugmentedRank
open scoped Topology ContDiff

abbrev V (k : ℕ) := Fin (k + 1) → ℝ
abbrev W (k : ℕ) := Fin k → ℝ

/-- The U-character response of the ACTUAL smooth parameter family. -/
def H_U (k : ℕ) (fU : V k → V k → W k) (A : Param k)
    (u v : V k) (t : ℝ) (i : Fin k) : ℝ :=
  (1 - t) * refU k u v i +
    t * fU u v i +
    t * (1 - t) * applyParam k A u i

/-- The V-character response of the ACTUAL smooth parameter family. -/
def H_V (k : ℕ) (fV : V k → V k → W k) (B : Param k)
    (u v : V k) (t : ℝ) (i : Fin k) : ℝ :=
  (1 - t) * refV k u v i +
    t * fV u v i +
    t * (1 - t) * applyParam k B v i

/-- End t=0 is EXACT reference, independent of the smooth target
and matrix parameters. -/
theorem H_U_zero (k : ℕ) (fU : V k → V k → W k)
    (A : Param k) (u v : V k) (i : Fin k) :
    H_U k fU A u v 0 i = refU k u v i := by
  simp [H_U]

theorem H_V_zero (k : ℕ) (fV : V k → V k → W k)
    (B : Param k) (u v : V k) (i : Fin k) :
    H_V k fV B u v 0 i = refV k u v i := by
  simp [H_V]

/-- End t=1 is EXACT the prescribed smooth equivariant response,
with the perturbation identically zero. -/
theorem H_U_one (k : ℕ) (fU : V k → V k → W k)
    (A : Param k) (u v : V k) (i : Fin k) :
    H_U k fU A u v 1 i = fU u v i := by
  simp [H_U]

theorem H_V_one (k : ℕ) (fV : V k → V k → W k)
    (B : Param k) (u v : V k) (i : Fin k) :
    H_V k fV B u v 1 i = fV u v i := by
  simp [H_V]

/-- Matrix perturbation is odd in its input vector. -/
private theorem applyParam_neg (k : ℕ) (A : Param k) (u : V k) (i : Fin k) :
    applyParam k A (-u) i = -applyParam k A u i := by
  simp [applyParam, Finset.sum_neg_distrib]

/-- U block has independent U-odd/V-even characters for all t. -/
theorem H_U_flip_left (k : ℕ)
    (fU : V k → V k → W k) (A : Param k)
    (hodd : ∀ u v (i : Fin k), fU (-u) v i = -fU u v i)
    (u v : V k) (t : ℝ) (i : Fin k) :
    H_U k fU A (-u) v t i = -H_U k fU A u v t i := by
  simp only [H_U, refU_flip_left, hodd, applyParam_neg]
  ring

theorem H_U_flip_right (k : ℕ)
    (fU : V k → V k → W k) (A : Param k)
    (heven : ∀ u v (i : Fin k), fU u (-v) i = fU u v i)
    (u v : V k) (t : ℝ) (i : Fin k) :
    H_U k fU A u (-v) t i = H_U k fU A u v t i := by
  simp [H_U, refU_flip_right, heven]

/-- V block has independent U-even/V-odd characters for all t. -/
theorem H_V_flip_left (k : ℕ)
    (fV : V k → V k → W k) (B : Param k)
    (heven : ∀ u v (i : Fin k), fV (-u) v i = fV u v i)
    (u v : V k) (t : ℝ) (i : Fin k) :
    H_V k fV B (-u) v t i = H_V k fV B u v t i := by
  simp [H_V, refV_flip_left, heven]

theorem H_V_flip_right (k : ℕ)
    (fV : V k → V k → W k) (B : Param k)
    (hodd : ∀ u v (i : Fin k), fV u (-v) i = -fV u v i)
    (u v : V k) (t : ℝ) (i : Fin k) :
    H_V k fV B u (-v) t i = -H_V k fV B u v t i := by
  simp only [H_V, refV_flip_right, hodd, applyParam_neg]
  ring

/-- Separate quadratic unit constraints, included in the ATLAS
Euclidean parametric Sard map to eliminate sphere-chart hypotheses. -/
def normDefect (k : ℕ) (u : V k) : ℝ :=
  (∑ j : Fin (k + 1), u j ^ 2) - 1

theorem normDefect_zero_iff (k : ℕ) (u : V k) :
    normDefect k u = 0 ↔ UnitVec (k + 1) u := by
  simp only [normDefect, UnitVec, sub_eq_zero]

theorem normDefect_neg (k : ℕ) (u : V k) :
    normDefect k (-u) = normDefect k u := by
  simp [normDefect]

/-- Smoothness of each scalar response under a GLOBALLY smooth input
approximation. This is the exact regularity class of the Sard family. -/
theorem H_U_contDiff (k : ℕ)
    (fU : V k → V k → W k) (A : Param k)
    (hf : ∀ i : Fin k, ContDiff ℝ (⊤ : ℕ∞)
      (fun p : V k × V k => fU p.1 p.2 i))
    (i : Fin k) :
    ContDiff ℝ (⊤ : ℕ∞)
      (fun p : (V k × V k) × ℝ =>
        H_U k fU A p.1.1 p.1.2 p.2 i) := by
  unfold H_U refU applyParam
  fun_prop

theorem H_V_contDiff (k : ℕ)
    (fV : V k → V k → W k) (B : Param k)
    (hf : ∀ i : Fin k, ContDiff ℝ (⊤ : ℕ∞)
      (fun p : V k × V k => fV p.1 p.2 i))
    (i : Fin k) :
    ContDiff ℝ (⊤ : ℕ∞)
      (fun p : (V k × V k) × ℝ =>
        H_V k fV B p.1.1 p.1.2 p.2 i) := by
  unfold H_V refV applyParam
  fun_prop

#print H_U_zero
#print axioms H_U_zero
#print H_V_zero
#print axioms H_V_zero
#print H_U_one
#print axioms H_U_one
#print H_V_one
#print axioms H_V_one
#print H_U_flip_left
#print axioms H_U_flip_left
#print H_U_flip_right
#print axioms H_U_flip_right
#print H_V_flip_left
#print axioms H_V_flip_left
#print H_V_flip_right
#print axioms H_V_flip_right
#print normDefect_zero_iff
#print axioms normDefect_zero_iff
#print normDefect_neg
#print axioms normDefect_neg
#print H_U_contDiff
#print axioms H_U_contDiff
#print H_V_contDiff
#print axioms H_V_contDiff

end Nightfall.ProductBUConcreteHomotopy
