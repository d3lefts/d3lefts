import Mathlib
import Nightfall.ProductSphereObstruction
import GenuinePrefixPhase

/-!
# PR #1000: composition of the pure product-sphere zero and genuine-prefix algebra

This module adds a source-exact conditional physical collision theorem connecting
the two already distinct research lanes: the existing finite topology *contract*
(ProductSphereZero) and the causal actual-prefix theorem in PR #1008.

IMPORTANT PROOF SCOPE:
* ProductSphereZero is a named HYPOTHESIS, not a proved theorem.
* The two continuity-on-sphere hypotheses are explicit. A separate source
  bridge must derive them from a row selector continuous on reachable
  histories; this file does not claim that bridge.
* The proof checks both independent antipodal sign characters, exact stage
  indexing, actual physical transcript equality, and non-sign-equivalence.
* No theorem-shaped axiom, sorry, or assumed collision is introduced.

The stronger end-to-end terminal is open until the continuity bridge, topology
theorem and full current-pin formal integration are separately discharged.
-/

namespace Nightfall.ProductSphereCausal

open Nightfall.ProductSphereObstruction
open Nightfall.GenuinePrefixPhase

abbrev Signal (n : ℕ) := Fin n → ℝ
abbrev CausalRows (n : ℕ) := List ℝ → Signal n →L[ℝ] ℝ

def amp {n : ℕ} (a : CausalRows n) :
    GenuinePrefixPhase.Oracle (Signal n) := fun h x => (a h) x

theorem amp_neg {n : ℕ} (a : CausalRows n) :
    ∀ h x, amp a h (-x) = -amp a h x := by
  intro h x
  simp [amp]

theorem amp_add {n : ℕ} (a : CausalRows n) :
    ∀ h x y, amp a h (x + y) = amp a h x + amp a h y := by
  intro h x y
  simp [amp]

theorem amp_sub {n : ℕ} (a : CausalRows n) :
    ∀ h x y, amp a h (x - y) = amp a h x - amp a h y := by
  intro h x y
  simp [amp]

def testU {n : ℕ} (a : CausalRows n) (r : ℕ)
    (u v : Signal n) (i : Fin r) : ℝ :=
  comparison (amp a) i.val u v u

def testV {n : ℕ} (a : CausalRows n) (r s : ℕ)
    (u v : Signal n) (i : Fin s) : ℝ :=
  comparison (amp a) (r + i.val) u v v

theorem comparison_neg_last {n : ℕ} (a : CausalRows n)
    (j : ℕ) (u v w : Signal n) :
    comparison (amp a) j u v (-w) =
      -comparison (amp a) j u v w := by
  simp [comparison, amp, map_neg, neg_add_rev, add_comm]

theorem testU_flip_left {n r : ℕ} (a : CausalRows n)
    (u v : Signal n) (i : Fin r) :
    testU a r (-u) v i = -testU a r u v i := by
  calc
    testU a r (-u) v i =
        comparison (amp a) i.val u v (-u) :=
      comparison_flip_left (amp a) (amp_neg a) i.val u v (-u)
    _ = -comparison (amp a) i.val u v u :=
      comparison_neg_last a i.val u v u
    _ = -testU a r u v i := rfl

theorem testU_flip_right {n r : ℕ} (a : CausalRows n)
    (u v : Signal n) (i : Fin r) :
    testU a r u (-v) i = testU a r u v i := by
  exact comparison_flip_right (amp a) i.val u v u

theorem testV_flip_left {n r s : ℕ} (a : CausalRows n)
    (u v : Signal n) (i : Fin s) :
    testV a r s (-u) v i = testV a r s u v i := by
  exact comparison_flip_left (amp a) (amp_neg a) (r + i.val) u v v

theorem testV_flip_right {n r s : ℕ} (a : CausalRows n)
    (u v : Signal n) (i : Fin s) :
    testV a r s u (-v) i = -testV a r s u v i := by
  calc
    testV a r s u (-v) i =
        comparison (amp a) (r + i.val) u v (-v) :=
      comparison_flip_right (amp a) (r + i.val) u v (-v)
    _ = -comparison (amp a) (r + i.val) u v v :=
      comparison_neg_last a (r + i.val) u v v
    _ = -testV a r s u v i := rfl

/-- Fully quantified conditional lower bound, without a preassumed
collision. The only existence input is the exact pure-character topology
contract; continuity of the specific genuine-prefix test maps is explicit.
The rows act on actual histories, and all vector operations are the
original real squared-linear sensing model. -/
theorem collision_of_product_sphere_zero
    (n r s : ℕ)
    (hBU : ProductSphereZero n r s)
    (a : CausalRows n)
    (hcontU : ∀ i : Fin r, ContinuousOn
        (fun p : (Signal n) × (Signal n) => testU a r p.1 p.2 i)
        (SpherePair n))
    (hcontV : ∀ i : Fin s, ContinuousOn
        (fun p : (Signal n) × (Signal n) => testV a r s p.1 p.2 i)
        (SpherePair n)) :
    ∃ u v : Signal n, UnitVec n u ∧ UnitVec n v ∧
      GenuinePrefixPhase.transcript (amp a) (r + s) (u + v) =
      GenuinePrefixPhase.transcript (amp a) (r + s) (u - v) ∧
      u + v ≠ u - v ∧
      u + v ≠ -(u - v) := by
  obtain ⟨u, v, hu, hv, hU, hV⟩ :=
    hBU (testU a r) (testV a r s)
      hcontU hcontV
      (fun u v i _ _ => testU_flip_left a u v i)
      (fun u v i _ _ => testU_flip_right a u v i)
      (fun u v i _ _ => testV_flip_left a u v i)
      (fun u v i _ _ => testV_flip_right a u v i)
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
  have hu0 : u ≠ 0 := by
    intro hz
    simp [UnitVec, hz] at hu
  have hv0 : v ≠ 0 := by
    intro hz
    simp [UnitVec, hz] at hv
  have hne : u + v ≠ u - v := by
    intro hz
    have htwo : (2 : ℝ) • v = 0 := by
      calc
        (2 : ℝ) • v = v + v := by simp [two_smul]
        _ = (u + v) - (u - v) := by abel
        _ = 0 := by rw [hz]; simp
    exact hv0 ((smul_eq_zero.mp htwo).resolve_left (by norm_num))
  have hne' : u + v ≠ -(u - v) := by
    intro hz
    have htwo : (2 : ℝ) • u = 0 := by
      calc
        (2 : ℝ) • u = u + u := by simp [two_smul]
        _ = (u + v) + (u - v) := by abel
        _ = 0 := by rw [hz]; simp
    exact hu0 ((smul_eq_zero.mp htwo).resolve_left (by norm_num))
  exact ⟨u, v, hu, hv, heq, hne, hne'⟩

#print collision_of_product_sphere_zero
#print axioms collision_of_product_sphere_zero
#print axioms testU_flip_left
#print axioms testV_flip_right

end Nightfall.ProductSphereCausal
