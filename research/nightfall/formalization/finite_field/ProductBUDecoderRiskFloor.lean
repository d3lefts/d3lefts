import ProductBUQuantitativeCollision

/-!
# Exact decoder-independent risk floor from a sign-invariant causal collision

An underlying ProductSphereZero proposition supplies two signals with
identical genuine causal transcripts and Euclidean sign-class separation 2.
The finite real algebra below upgrades the certificate to an exact
two-point minimax squared-error obstruction, for EVERY decoder estimate.

This is a conditional implication: the topology zero remains an explicit
HYPOTHESIS, not a theorem proved in this file. The conclusion is for
the natural unit-pair collision; scale-free R-ball extension is in the
companion paper note and has NOT been Lean-formalized.

No other norm is silently substituted for the coordinate squared norm.
-/

open scoped BigOperators

namespace Nightfall.ProductBUDecoderRiskFloor

open Nightfall.ProductSphereObstruction
open Nightfall.ProductSphereCausal
open Nightfall.ProductBUQuantitativeCollision

/-- Squared distance to the sign orbit {x,-x}. -/
def signOrbitSqError (n : ℕ) (z x : Signal n) : ℝ :=
  min (sqNorm n (z - x)) (sqNorm n (z + x))

/-- Nonnegativity of the actual Euclidean coordinate-squared norm. -/
theorem sqNorm_nonneg (n : ℕ) (z : Signal n) :
    0 ≤ sqNorm n z := by
  unfold sqNorm
  exact Finset.sum_nonneg (fun i hi => sq_nonneg _)

/-- A fully quantitative two-point inequality obtained by summing
the exact scalar identity
(2z-a-b)^2 = 2(z-a)^2+2(z-b)^2-(a-b)^2. -/
theorem sqNorm_two_point_floor (n : ℕ)
    (z a b : Signal n) :
    sqNorm n (a - b) ≤
      2 * (sqNorm n (z - a) + sqNorm n (z - b)) := by
  change (∑ i : Fin n, (a i - b i)^2) ≤
    2 * ((∑ i : Fin n, (z i - a i)^2) +
          (∑ i : Fin n, (z i - b i)^2))
  have hp (i : Fin n) :
      (a i - b i)^2 ≤
      2 * ((z i - a i)^2 + (z i - b i)^2) := by
    nlinarith [sq_nonneg (2 * z i - a i - b i)]
  calc
    (∑ i : Fin n, (a i - b i)^2) ≤
        ∑ i : Fin n,
          2 * ((z i - a i)^2 + (z i - b i)^2) :=
      Finset.sum_le_sum (fun i hi => hp i)
    _ = 2 * (∑ i : Fin n,
          ((z i - a i)^2 + (z i - b i)^2)) := by
      rw [Finset.mul_sum]
    _ = 2 * ((∑ i : Fin n, (z i - a i)^2) +
          (∑ i : Fin n, (z i - b i)^2)) := by
      rw [Finset.sum_add_distrib]

/-- Exact sign invariance of a squared Euclidean coordinate norm. -/
theorem sqNorm_neg (n : ℕ) (z : Signal n) :
    sqNorm n (-z) = sqNorm n z := by
  simp [sqNorm]

/-- If both possible sign distances of x and y are exactly 2,
then at least one sign-class squared error is >= 1 for any estimate.
The sum of squared errors is >=2, the stronger pointwise statement. -/
theorem sign_orbit_pair_risk_floor
    (n : ℕ) (x y z : Signal n)
    (hminus : sqNorm n (x - y) = 4)
    (hplus : sqNorm n (x + y) = 4) :
    2 ≤ signOrbitSqError n z x + signOrbitSqError n z y := by
  have h1 : 2 ≤ sqNorm n (z - x) + sqNorm n (z - y) := by
    have h := sqNorm_two_point_floor n z x y
    rw [hminus] at h
    linarith
  have h2 : 2 ≤ sqNorm n (z - x) + sqNorm n (z + y) := by
    have h := sqNorm_two_point_floor n z x (-y)
    have hxy : x - (-y) = x + y := by abel
    have hzy : z - (-y) = z + y := by abel
    rw [hxy, hzy, hplus] at h
    linarith
  have h3 : 2 ≤ sqNorm n (z + x) + sqNorm n (z - y) := by
    have h := sqNorm_two_point_floor n z (-x) y
    have hxy : (-x) - y = -(x + y) := by abel
    have hzx : z - (-x) = z + x := by abel
    rw [hxy, sqNorm_neg, hplus, hzx] at h
    linarith
  have h4 : 2 ≤ sqNorm n (z + x) + sqNorm n (z + y) := by
    have h := sqNorm_two_point_floor n z (-x) (-y)
    have hxy : (-x) - (-y) = -(x - y) := by abel
    have hzx : z - (-x) = z + x := by abel
    have hzy : z - (-y) = z + y := by abel
    rw [hxy, sqNorm_neg, hminus, hzx, hzy] at h
    linarith
  dsimp [signOrbitSqError]
  simp only [min_def]
  split_ifs <;> linarith

/-- Every decoder estimate must pay squared sign-orbit error at least 1
on at least one of the exact indistinguishable signals. -/
theorem sign_orbit_pair_worst_risk_floor
    (n : ℕ) (x y z : Signal n)
    (hminus : sqNorm n (x - y) = 4)
    (hplus : sqNorm n (x + y) = 4) :
    1 ≤ max (signOrbitSqError n z x) (signOrbitSqError n z y) := by
  have h := sign_orbit_pair_risk_floor n x y z hminus hplus
  rcases le_total (signOrbitSqError n z x) (signOrbitSqError n z y) with hle | hle
  · rw [max_eq_right hle]
    linarith
  · rw [max_eq_left hle]
    linarith

/-- Exact conditional causal minimax lower bound at the unit-pair scale.
There is one pair of equal transcripts that forces >= 1 squared phase
error for every candidate output of any decoder. No decoder assumptions. -/
theorem causal_decoder_risk_floor_of_product_sphere_zero
    (n r s : ℕ) (hBU : ProductSphereZero n r s)
    (a : CausalRows n) (ha : ReachableContinuous a) :
    ∃ x y : Signal n,
      GenuinePrefixPhase.transcript (amp a) (r + s) x =
        GenuinePrefixPhase.transcript (amp a) (r + s) y ∧
      ∀ z : Signal n,
        1 ≤ max (signOrbitSqError n z x) (signOrbitSqError n z y) := by
  obtain ⟨x, y, htrans, hminus, hplus, _, _⟩ :=
    quantitative_collision_of_product_sphere_zero n r s hBU a ha
  exact ⟨x, y, htrans, fun z =>
    sign_orbit_pair_worst_risk_floor n x y z hminus hplus⟩

#check sqNorm_two_point_floor
#print axioms sqNorm_two_point_floor
#check sign_orbit_pair_risk_floor
#print axioms sign_orbit_pair_risk_floor
#check sign_orbit_pair_worst_risk_floor
#print axioms sign_orbit_pair_worst_risk_floor
#check causal_decoder_risk_floor_of_product_sphere_zero
#print axioms causal_decoder_risk_floor_of_product_sphere_zero

end Nightfall.ProductBUDecoderRiskFloor
