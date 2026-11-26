import ProductSphereCausalComposition

/-!
# Exact quantitative separation for genuine causal phase-retrieval collisions

The established original-source causal composition (ProductSphereCausalComposition)
constructs indistinguishable real signals x=u+v and y=u-v from a
ProductSphereZero topology HYPOTHESIS and reachability-continuous row policies.

This module upgrades the collision conclusion:
  sqNorm (x-y)=4 and sqNorm (x+y)=4.
Thus the two sign classes are separated by Euclidean distance exactly 2.

No new ProductSphereZero proof is introduced, and no detector lower bound
is asserted without the topological premise. A minimax reconstruction
bound follows analytically by the triangle inequality in sign-quotient
Euclidean distance (not formalized in this file).

The purpose of this upgrade is to preserve an exact quantitative
operational consequence while the separate ATLAS geometric realization
and topology certificates are completed.

Source and attribution: original NIGHTFALL reachable-prefix collision
from ProductSphereCausalComposition; ordinary Euclidean algebra below.
-/

open scoped BigOperators
namespace Nightfall.ProductBUQuantitativeCollision

open Nightfall.ProductSphereObstruction
open Nightfall.ProductSphereCausal

/-- The square of the Euclidean length of twice a unit vector is exactly 4.
This uses the original coordinate-squared norm, not the function-space
supremum norm. -/
theorem sqNorm_add_self_of_unit
    (n : ℕ) (u : Signal n) (hu : UnitVec n u) :
    sqNorm n (u + u) = 4 := by
  change (∑ i : Fin n, (u i + u i) ^ 2) = 4
  calc
    (∑ i : Fin n, (u i + u i) ^ 2) =
        4 * (∑ i : Fin n, (u i) ^ 2) := by
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro i hi
          ring
    _ = 4 := by
      change (∑ i : Fin n, u i ^ 2) = 1 at hu
      rw [hu]
      ring

/-- Exact, dimension-free antipodal-quotient separation of the
candidate phase-retrieval pair, independent of the topology theorem. -/
theorem exact_plus_minus_separation
    (n : ℕ) (u v : Signal n)
    (hu : UnitVec n u) (hv : UnitVec n v) :
    sqNorm n ((u + v) - (u - v)) = 4 ∧
    sqNorm n ((u + v) + (u - v)) = 4 := by
  constructor
  · have h : (u + v) - (u - v) = v + v := by abel
    rw [h]
    exact sqNorm_add_self_of_unit n v hv
  · have h : (u + v) + (u - v) = u + u := by abel
    rw [h]
    exact sqNorm_add_self_of_unit n u hu

/-- A quantitative upgrade of the exact genuine-prefix collision theorem.
The two signals share ALL actual causal readings in this protocol but
are exactly distance 2 apart even after optimizing over a global sign.

HARD GATE: ProductSphereZero remains a PROPOSITION passed as hBU,
not a theorem proved in this module. This is a conditional implication,
not an unconditional n-dimensional topology or phase-retrieval theorem. -/
theorem quantitative_collision_of_product_sphere_zero
    (n r s : ℕ)
    (hBU : ProductSphereZero n r s)
    (a : CausalRows n)
    (ha : ReachableContinuous a) :
    ∃ x y : Signal n,
      GenuinePrefixPhase.transcript (amp a) (r + s) x =
        GenuinePrefixPhase.transcript (amp a) (r + s) y ∧
      sqNorm n (x - y) = 4 ∧
      sqNorm n (x + y) = 4 ∧
      x ≠ y ∧ x ≠ -y := by
  obtain ⟨u, v, hu, hv, heq, hneq, hnotneg⟩ :=
    collision_of_product_sphere_zero_reachable n r s hBU a ha
  obtain ⟨hsep, hsepneg⟩ :=
    exact_plus_minus_separation n u v hu hv
  exact ⟨u + v, u - v, heq, hsep, hsepneg, hneq, hnotneg⟩

#check sqNorm_add_self_of_unit
#print axioms sqNorm_add_self_of_unit
#check exact_plus_minus_separation
#print axioms exact_plus_minus_separation
#check quantitative_collision_of_product_sphere_zero
#print axioms quantitative_collision_of_product_sphere_zero

end Nightfall.ProductBUQuantitativeCollision
