import Mathlib
import ProductSphereObstruction
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


/-!
## Stronger reachable-prefix continuity bridge

The row function is only required to be continuous *on the set of prefixes
actually produced by the original intensity protocol*, for each history
length. We do not extend it continuously to virtual / unreachable histories.

The list topology is the Mathlib fixed-length component topology
(Mathlib.Topology.List). The comparison maps use only genuine prefixes.
This closes the previous additional continuity premises in the conditional
theorem, without Tietze and without any new topological axiom.
-/

/-- Original deterministic causal model: the continuous-linear reading
selector is continuous only when restricted to the attainable histories. -/
def ReachableContinuous {n : ℕ} (a : CausalRows n) : Prop :=
  ∀ k, ContinuousOn a
    (Set.range (GenuinePrefixPhase.transcript (amp a) k))

/-- The actual transcript map is continuous, by induction through the
attainable-prefix image. No off-image continuity is required. -/
theorem continuous_actual_transcript {n : ℕ} (a : CausalRows n)
    (ha : ReachableContinuous a) :
    ∀ k, Continuous
      (GenuinePrefixPhase.transcript (amp a) k) := by
  intro k
  induction k with
  | zero =>
      simpa [GenuinePrefixPhase.transcript] using
        (continuous_const : Continuous (fun _ : Signal n => ([] : List ℝ)))
  | succ j ih =>
      have hrow : Continuous
          (fun x : Signal n =>
            a (GenuinePrefixPhase.transcript (amp a) j x)) := by
        exact (ha j).comp_continuous ih
          (fun x => ⟨x, rfl⟩)
      have hread : Continuous
          (fun x : Signal n =>
            (a (GenuinePrefixPhase.transcript (amp a) j x)) x) :=
        Continuous.clm_apply hrow continuous_id
      have hfull : Continuous
          (fun x : Signal n =>
            ((a (GenuinePrefixPhase.transcript (amp a) j x)) x) ^ 2 ::
              GenuinePrefixPhase.transcript (amp a) j x) :=
        List.continuous_cons.comp ((hread.pow 2).prodMk ih)
      simpa [GenuinePrefixPhase.transcript, amp] using hfull

/-- The U-colour test is automatically globally continuous as a function
of its genuine pair (u,v). It uses no fictitious virtual histories. -/
theorem continuous_testU {n r : ℕ} (a : CausalRows n)
    (ha : ReachableContinuous a) (i : Fin r) :
    Continuous (fun p : (Signal n) × (Signal n) =>
      testU a r p.1 p.2 i) := by
  let T := GenuinePrefixPhase.transcript (amp a) i.val
  have hT : Continuous T := continuous_actual_transcript a ha i.val
  have hplus : Continuous (fun p : (Signal n) × (Signal n) => p.1 + p.2) :=
    continuous_fst.add continuous_snd
  have hminus : Continuous (fun p : (Signal n) × (Signal n) => p.1 - p.2) :=
    continuous_fst.sub continuous_snd
  have hrp : Continuous (fun p : (Signal n) × (Signal n) =>
      a (T (p.1 + p.2))) := by
    exact (ha i.val).comp_continuous (hT.comp hplus)
      (fun p => ⟨p.1 + p.2, rfl⟩)
  have hrm : Continuous (fun p : (Signal n) × (Signal n) =>
      a (T (p.1 - p.2))) := by
    exact (ha i.val).comp_continuous (hT.comp hminus)
      (fun p => ⟨p.1 - p.2, rfl⟩)
  have hp : Continuous (fun p : (Signal n) × (Signal n) =>
      (a (T (p.1 + p.2))) p.1) :=
    Continuous.clm_apply hrp continuous_fst
  have hm : Continuous (fun p : (Signal n) × (Signal n) =>
      (a (T (p.1 - p.2))) p.1) :=
    Continuous.clm_apply hrm continuous_fst
  simpa only [testU, GenuinePrefixPhase.comparison, amp, T, Pi.add_apply] using hp.add hm

/-- The V-colour test likewise has continuity derived from the actual
reachable-prefix selectors, not postulated. -/
theorem continuous_testV {n r s : ℕ} (a : CausalRows n)
    (ha : ReachableContinuous a) (i : Fin s) :
    Continuous (fun p : (Signal n) × (Signal n) =>
      testV a r s p.1 p.2 i) := by
  let j : ℕ := r + i.val
  let T := GenuinePrefixPhase.transcript (amp a) j
  have hT : Continuous T := continuous_actual_transcript a ha j
  have hplus : Continuous (fun p : (Signal n) × (Signal n) => p.1 + p.2) :=
    continuous_fst.add continuous_snd
  have hminus : Continuous (fun p : (Signal n) × (Signal n) => p.1 - p.2) :=
    continuous_fst.sub continuous_snd
  have hrp : Continuous (fun p : (Signal n) × (Signal n) =>
      a (T (p.1 + p.2))) := by
    exact (ha j).comp_continuous (hT.comp hplus)
      (fun p => ⟨p.1 + p.2, rfl⟩)
  have hrm : Continuous (fun p : (Signal n) × (Signal n) =>
      a (T (p.1 - p.2))) := by
    exact (ha j).comp_continuous (hT.comp hminus)
      (fun p => ⟨p.1 - p.2, rfl⟩)
  have hp : Continuous (fun p : (Signal n) × (Signal n) =>
      (a (T (p.1 + p.2))) p.2) :=
    Continuous.clm_apply hrp continuous_snd
  have hm : Continuous (fun p : (Signal n) × (Signal n) =>
      (a (T (p.1 - p.2))) p.2) :=
    Continuous.clm_apply hrm continuous_snd
  simpa only [testV, GenuinePrefixPhase.comparison, amp, T, j, Pi.add_apply] using hp.add hm

/-- FINAL REACHABLE-PREFIX COMPOSITION, conditional only on the precisely
typed ProductSphereZero topology theorem. The previously explicit
test-map continuity assumptions are *derived*, not assumed.

This statement is independent of a Tietze extension or of any row
regularity at unreachable, virtual histories.
-/
theorem collision_of_product_sphere_zero_reachable
    (n r s : ℕ)
    (hBU : ProductSphereZero n r s)
    (a : CausalRows n)
    (ha : ReachableContinuous a) :
    ∃ u v : Signal n, UnitVec n u ∧ UnitVec n v ∧
      GenuinePrefixPhase.transcript (amp a) (r + s) (u + v) =
      GenuinePrefixPhase.transcript (amp a) (r + s) (u - v) ∧
      u + v ≠ u - v ∧
      u + v ≠ -(u - v) := by
  exact collision_of_product_sphere_zero n r s hBU a
    (fun i => (continuous_testU a ha i).continuousOn)
    (fun i => (continuous_testV a ha i).continuousOn)

#print continuous_actual_transcript
#print axioms continuous_actual_transcript
#print continuous_testU
#print axioms continuous_testU
#print continuous_testV
#print axioms continuous_testV
#print collision_of_product_sphere_zero_reachable
#print axioms collision_of_product_sphere_zero_reachable

#print collision_of_product_sphere_zero
#print axioms collision_of_product_sphere_zero
#print axioms testU_flip_left
#print axioms testV_flip_right

end Nightfall.ProductSphereCausal
