import Mathlib
import ProductSphereObstruction

/-!
# Constructive surjectivity of product-sphere equivariant perturbation directions

For any pair of unit vectors u,v and time 0<t<1, the finite family
  (A,B) ↦ t(1-t) (Au, Bv)
surjects onto both pure-character target blocks. An explicit rank-one
right inverse is given, with *no* topological theorem assumed.

This is the algebraic parameter-direction hypothesis of the parametric
transversality argument sketched in #1024. It does NOT prove Sard's theorem,
generic transversality, manifold structure of the zero set, orbit parity,
or the existence assertion ProductSphereZero.
-/

namespace Nightfall.ProductBUPerturbation

open Nightfall.ProductSphereObstruction

abbrev Param (k : ℕ) := Fin k → Fin (k + 1) → ℝ

/-- Action of a rectangular real matrix on a vector. -/
def applyParam (k : ℕ) (A : Param k) (u : Fin (k + 1) → ℝ) :
    Fin k → ℝ :=
  fun i => ∑ j, A i j * u j

/-- Rank-one right-inverse parameter built from a unit vector. -/
def rankOne (k : ℕ) (u : Fin (k + 1) → ℝ) (y : Fin k → ℝ) :
    Param k :=
  fun i j => y i * u j

/-- At a unit vector, the rank-one parameter realizes any target. -/
theorem applyParam_rankOne_unit (k : ℕ) (u : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (y : Fin k → ℝ) :
    applyParam k (rankOne k u y) u = y := by
  funext i
  have hnorm : (∑ j : Fin (k + 1), (u j) ^ 2) = 1 := hu
  dsimp [applyParam, rankOne]
  calc
    (∑ j : Fin (k + 1), (y i * u j) * u j) =
        ∑ j : Fin (k + 1), y i * (u j) ^ 2 := by
          apply Finset.sum_congr rfl
          intro j hj
          ring
    _ = y i * (∑ j : Fin (k + 1), (u j) ^ 2) := by
          rw [Finset.mul_sum]
    _ = y i := by rw [hnorm]; ring

/-- Every non-endpoint time gives a full rank parameter derivative
in each pure-character block; proof constructs an explicit right inverse. -/
theorem weighted_perturbation_surjective (k : ℕ)
    (u : Fin (k + 1) → ℝ) (hu : UnitVec (k + 1) u)
    (t : ℝ) (ht : 0 < t) (ht1 : t < 1)
    (y : Fin k → ℝ) :
    ∃ A : Param k,
      ∀ i : Fin k, t * (1 - t) * applyParam k A u i = y i := by
  have hc : t * (1 - t) ≠ 0 :=
    ne_of_gt (mul_pos ht (sub_pos.mpr ht1))
  refine ⟨rankOne k u (fun i => y i / (t * (1 - t))), ?_⟩
  intro i
  rw [congrFun (applyParam_rankOne_unit k u hu
    (fun i => y i / (t * (1 - t)))) i]
  field_simp

/-- Simultaneous parameter-direction surjectivity for the whole product,
not merely for one sphere or one coordinate block. -/
theorem product_weighted_perturbation_surjective (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (t : ℝ) (ht : 0 < t) (ht1 : t < 1)
    (yU yV : Fin k → ℝ) :
    ∃ A B : Param k,
      (∀ i : Fin k, t * (1 - t) * applyParam k A u i = yU i) ∧
      (∀ i : Fin k, t * (1 - t) * applyParam k B v i = yV i) := by
  obtain ⟨A,hA⟩ := weighted_perturbation_surjective k u hu t ht ht1 yU
  obtain ⟨B,hB⟩ := weighted_perturbation_surjective k v hv t ht ht1 yV
  exact ⟨A,B,hA,hB⟩

#print axioms applyParam_rankOne_unit
#print axioms weighted_perturbation_surjective
#print axioms product_weighted_perturbation_surjective

end Nightfall.ProductBUPerturbation
