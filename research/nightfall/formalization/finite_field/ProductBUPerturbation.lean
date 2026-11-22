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


/-- An explicit radial direction solves an arbitrary tangent equation
for the unit-sphere norm constraint; this is the second part of the
augmented Euclidean parametric-Sard surjectivity check. -/
noncomputable def radialDirection (k : ℕ) (u : Fin (k + 1) → ℝ) (r : ℝ) :
    Fin (k + 1) → ℝ := fun j => (r / 2) * u j

theorem radial_direction_right_inverse (k : ℕ)
    (u : Fin (k + 1) → ℝ) (hu : UnitVec (k + 1) u) (r : ℝ) :
    2 * mixedDot (k + 1) u (radialDirection k u r) = r := by
  have hnorm : (∑ j : Fin (k + 1), (u j) ^ 2) = 1 := hu
  unfold mixedDot radialDirection
  calc
    2 * (∑ j : Fin (k + 1), u j * (r / 2 * u j)) =
        2 * ((r / 2) * (∑ j : Fin (k + 1), u j ^ 2)) := by
          congr 1
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro j hj
          ring
    _ = r := by rw [hnorm]; ring

/-- Full algebraic right inverse of the combined norm constraints and
pure-character perturbation blocks. Any *already existing* derivative
contributions in the target can be cancelled by the independent A/B
parameter directions. This is a finite-dimensional algebra theorem
only, not a Lean proof of the differential or parametric Sard step. -/
theorem augmented_constraint_parameter_surjective (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (t : ℝ) (ht : 0 < t) (ht1 : t < 1)
    (rU rV : ℝ)
    (baseU baseV targetU targetV : Fin k → ℝ) :
    ∃ du dv : Fin (k + 1) → ℝ, ∃ A B : Param k,
      2 * mixedDot (k + 1) u du = rU ∧
      2 * mixedDot (k + 1) v dv = rV ∧
      (∀ i : Fin k, baseU i + t * (1 - t) * applyParam k A u i = targetU i) ∧
      (∀ i : Fin k, baseV i + t * (1 - t) * applyParam k B v i = targetV i) := by
  obtain ⟨A,hA⟩ := weighted_perturbation_surjective k u hu t ht ht1
    (fun i => targetU i - baseU i)
  obtain ⟨B,hB⟩ := weighted_perturbation_surjective k v hv t ht ht1
    (fun i => targetV i - baseV i)
  refine ⟨radialDirection k u rU, radialDirection k v rV,
    A, B, radial_direction_right_inverse k u hu rU,
    radial_direction_right_inverse k v hv rV, ?_, ?_⟩
  · intro i
    have hi := hA i
    linarith
  · intro i
    have hi := hB i
    linarith


/-- The exact parameter right inverse works for *every real time* except
t = 0,1; positivity of t is mathematically unnecessary. This is
needed because Euclidean parametric Sard checks all t ∈ ℝ. -/
theorem weighted_perturbation_surjective_nonzero (k : ℕ)
    (u : Fin (k + 1) → ℝ) (hu : UnitVec (k + 1) u)
    (t : ℝ) (ht : t * (1 - t) ≠ 0)
    (y : Fin k → ℝ) :
    ∃ A : Param k,
      ∀ i : Fin k, t * (1 - t) * applyParam k A u i = y i := by
  refine ⟨rankOne k u (fun i => y i / (t * (1 - t))), ?_⟩
  intro i
  rw [congrFun (applyParam_rankOne_unit k u hu
    (fun i => y i / (t * (1 - t)))) i]
  exact mul_div_cancel_left₀ (y i) ht

/-- The nonzero-weight augmented linear parameter/norm-gradient right
inverse, valid for every real t with t ≠ 0 and t ≠ 1. -/
theorem augmented_constraint_parameter_surjective_nonzero (k : ℕ)
    (u v : Fin (k + 1) → ℝ)
    (hu : UnitVec (k + 1) u) (hv : UnitVec (k + 1) v)
    (t : ℝ) (ht : t * (1 - t) ≠ 0)
    (rU rV : ℝ)
    (baseU baseV targetU targetV : Fin k → ℝ) :
    ∃ du dv : Fin (k + 1) → ℝ, ∃ A B : Param k,
      2 * mixedDot (k + 1) u du = rU ∧
      2 * mixedDot (k + 1) v dv = rV ∧
      (∀ i : Fin k, baseU i + t * (1 - t) * applyParam k A u i = targetU i) ∧
      (∀ i : Fin k, baseV i + t * (1 - t) * applyParam k B v i = targetV i) := by
  obtain ⟨A,hA⟩ := weighted_perturbation_surjective_nonzero k u hu t ht
    (fun i => targetU i - baseU i)
  obtain ⟨B,hB⟩ := weighted_perturbation_surjective_nonzero k v hv t ht
    (fun i => targetV i - baseV i)
  refine ⟨radialDirection k u rU, radialDirection k v rV,
    A, B, radial_direction_right_inverse k u hu rU,
    radial_direction_right_inverse k v hv rV, ?_, ?_⟩
  · intro i
    have hi := hA i
    linarith
  · intro i
    have hi := hB i
    linarith

#print axioms weighted_perturbation_surjective_nonzero
#print axioms augmented_constraint_parameter_surjective_nonzero
#print axioms radial_direction_right_inverse
#print axioms augmented_constraint_parameter_surjective
#print axioms applyParam_rankOne_unit
#print axioms weighted_perturbation_surjective
#print axioms product_weighted_perturbation_surjective

end Nightfall.ProductBUPerturbation
