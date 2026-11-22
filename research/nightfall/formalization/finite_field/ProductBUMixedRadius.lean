import ProductBUDecoderRiskFloor

/-!
# Known-radius phase-retrieval collision from mixed-character product BU

The mixed-character `ProductSphereMixedZero` premise is a separately stated
topological proposition in the original ProductSphereObstruction source,
not a Lean-certified universal zero theorem.

We construct the true causal collision from the *mixed* witness, including
the extra dot-product coordinate. That coordinate forces u ⟂ v,
hence both indistinguishable signals u+v, u-v lie on the same Euclidean
sphere of squared radius 2. Their sign-quotient separation squared is 4.

This is an exact, conditional implication in all dimensions. It neither
assumes continuity away from genuinely reachable histories nor upgrades
the external product-of-spheres Borsuk–Ulam theorem to a kernel theorem.
-/

open scoped BigOperators

namespace Nightfall.ProductBUMixedRadius

open Nightfall.ProductSphereObstruction
open Nightfall.ProductSphereCausal
open Nightfall.ProductBUQuantitativeCollision
open Nightfall.ProductBUDecoderRiskFloor
open Nightfall.GenuinePrefixPhase

/-- Orthogonality and two unit norms imply that the plus signal has
Euclidean squared norm exactly 2. -/
theorem sqNorm_plus_eq_two_of_orthogonal_unit
    (n : ℕ) (u v : Signal n)
    (hu : UnitVec n u) (hv : UnitVec n v)
    (horth : mixedDot n u v = 0) :
    sqNorm n (u + v) = 2 := by
  change (∑ i : Fin n, (u i + v i)^2) = 2
  change (∑ i : Fin n, u i ^ 2) = 1 at hu
  change (∑ i : Fin n, v i ^ 2) = 1 at hv
  change (∑ i : Fin n, u i * v i) = 0 at horth
  calc
    (∑ i : Fin n, (u i + v i)^2) =
        ∑ i : Fin n, (u i ^ 2 + v i ^ 2 + 2 * (u i * v i)) := by
          apply Finset.sum_congr rfl
          intro i hi
          ring
    _ = (∑ i : Fin n, u i ^ 2) +
        (∑ i : Fin n, v i ^ 2) +
        2 * (∑ i : Fin n, u i * v i) := by
          simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
    _ = 2 := by rw [hu, hv, horth]; ring

/-- Both phase candidates lie on one *known-radius* sphere. -/
theorem exact_known_radius_pair
    (n : ℕ) (u v : Signal n)
    (hu : UnitVec n u) (hv : UnitVec n v)
    (horth : mixedDot n u v = 0) :
    sqNorm n (u + v) = 2 ∧
    sqNorm n (u - v) = 2 ∧
    sqNorm n ((u + v) - (u - v)) = 4 ∧
    sqNorm n ((u + v) + (u - v)) = 4 := by
  have hp := sqNorm_plus_eq_two_of_orthogonal_unit n u v hu hv horth
  have heq := sqNorm_eq_of_mixedDot_zero n u v horth
  obtain ⟨hdiff, hsum⟩ := exact_plus_minus_separation n u v hu hv
  exact ⟨hp, heq.symm.trans hp, hdiff, hsum⟩

/-- Mixed-character topology, when supplied, yields a physical
causal *same-radius* collision and the squared decoder-error floor.
This named statement does not derive `ProductSphereMixedZero`. -/
theorem known_radius_risk_of_mixed_product_sphere_zero
    (n r s : ℕ)
    (hMixed : ProductSphereMixedZero n r s)
    (a : CausalRows n)
    (ha : ReachableContinuous a) :
    ∃ x y : Signal n,
      GenuinePrefixPhase.transcript (amp a) (r + s) x =
        GenuinePrefixPhase.transcript (amp a) (r + s) y ∧
      sqNorm n x = 2 ∧
      sqNorm n y = 2 ∧
      sqNorm n (x - y) = 4 ∧
      sqNorm n (x + y) = 4 ∧
      ∀ z : Signal n,
        1 ≤ max (signOrbitSqError n z x) (signOrbitSqError n z y) := by
  obtain ⟨u, v, hu, hv, hU, hV, horth⟩ :=
    hMixed (testU a r) (testV a r s) (mixedDot n)
      (fun i => (continuous_testU a ha i).continuousOn)
      (fun i => (continuous_testV a ha i).continuousOn)
      (continuous_mixedDot n).continuousOn
      (fun u v i _ _ => testU_flip_left a u v i)
      (fun u v i _ _ => testU_flip_right a u v i)
      (fun u v i _ _ => testV_flip_left a u v i)
      (fun u v i _ _ => testV_flip_right a u v i)
      (fun u v _ _ => mixedDot_flip_left n u v)
      (fun u v _ _ => mixedDot_flip_right n u v)
  have hstage : ∀ j < r + s,
      comparison (amp a) j u v u = 0 ∨
      comparison (amp a) j u v v = 0 := by
    intro j hj
    by_cases h : j < r
    · left
      simpa [testU] using hU ⟨j, h⟩
    · right
      have hs : j - r < s := by omega
      have hr : r + (j - r) = j := by omega
      simpa [testV, hr] using hV ⟨j - r, hs⟩
  have heq :=
    GenuinePrefixPhase.causal_collision_of_genuine_prefix_zeros
      (amp a) (amp_add a) (amp_sub a) u v (r+s) hstage
  obtain ⟨hx, hy, hdiff, hsum⟩ :=
    exact_known_radius_pair n u v hu hv horth
  exact ⟨u + v, u - v, heq, hx, hy, hdiff, hsum,
    fun z => sign_orbit_pair_worst_risk_floor n (u + v) (u - v) z hdiff hsum⟩

#check sqNorm_plus_eq_two_of_orthogonal_unit
#print axioms sqNorm_plus_eq_two_of_orthogonal_unit
#check exact_known_radius_pair
#print axioms exact_known_radius_pair
#check known_radius_risk_of_mixed_product_sphere_zero
#print axioms known_radius_risk_of_mixed_product_sphere_zero

end Nightfall.ProductBUMixedRadius
