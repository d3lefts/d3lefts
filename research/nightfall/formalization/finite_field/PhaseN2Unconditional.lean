import Mathlib
import CausalPhaseConditional

/-!
Unconditional planar two-reading obstruction, using a polynomial path and IVT.
No topology axiom or ProductSphereZero premise is used.
-/
namespace Nightfall.PhaseN2Unconditional

open Nightfall.CausalPhaseConditional
open Nightfall.GenuinePrefixPhase
open Nightfall.ProductSphereObstruction

abbrev V2 := Vec 2

def arc (t : ℝ) : V2 := fun i => if i = 0 then t else 1 - t ^ 2

theorem arc_endpoint : arc (-1) = -arc 1 := by
  funext i
  fin_cases i <;> norm_num [arc]

theorem arc_ne_zero (t : ℝ) : arc t ≠ 0 := by
  intro h
  have h0 : t = 0 := by
    have e := congrFun h (0 : Fin 2)
    simpa [arc] using e
  have h1 : 1 - t ^ 2 = 0 := by
    have e := congrFun h (1 : Fin 2)
    simpa [arc] using e
  nlinarith

theorem continuous_arc : Continuous arc := by
  apply continuous_pi
  intro i
  fin_cases i <;> simp [arc] <;> fun_prop

def perpendicular (a : V2) : V2 :=
  fun i => if i = 0 then -(a 1) else a 0

theorem dot_perpendicular (a : V2) : mixedDot 2 a (perpendicular a) = 0 := by
  simp [mixedDot, perpendicular, Fin.sum_univ_succ]
  ring

theorem perpendicular_ne_zero (a : V2) (ha : a ≠ 0) :
    perpendicular a ≠ 0 := by
  intro hp
  have h0 : a 0 = 0 := by
    have e := congrFun hp (1 : Fin 2)
    simpa [perpendicular] using e
  have h1 : a 1 = 0 := by
    have e := congrFun hp (0 : Fin 2)
    have he : -(a 1) = 0 := by simpa [perpendicular] using e
    linarith
  apply ha
  funext i
  fin_cases i <;> simp [h0, h1]

def kernelVector (a : V2) : V2 :=
  if a = 0 then arc 0 else perpendicular a

theorem kernelVector_ne_zero (a : V2) : kernelVector a ≠ 0 := by
  by_cases ha : a = 0
  · simpa [kernelVector, ha] using arc_ne_zero (0 : ℝ)
  · simpa [kernelVector, ha] using perpendicular_ne_zero a ha

theorem kernelVector_dot (a : V2) : mixedDot 2 a (kernelVector a) = 0 := by
  by_cases ha : a = 0
  · simp [kernelVector, ha, mixedDot]
  · simpa [kernelVector, ha] using dot_perpendicular a

theorem continuous_antipodal_root (g : ℝ → ℝ) (hg : Continuous g)
    (he : g (-1) = -g 1) : ∃ t : ℝ, g t = 0 := by
  by_cases hpos : 0 ≤ g 1
  · have hm : (0 : ℝ) ∈ Set.Icc (g (-1)) (g 1) := by
      constructor <;> linarith [he]
    obtain ⟨t, _, ht⟩ :=
      (intermediate_value_Icc (show (-1 : ℝ) ≤ 1 by norm_num)
        hg.continuousOn) hm
    exact ⟨t, ht⟩
  · have hm : (0 : ℝ) ∈ Set.Icc (-g (-1)) (-g 1) := by
      constructor <;> linarith [he]
    obtain ⟨t, _, ht⟩ :=
      (intermediate_value_Icc (show (-1 : ℝ) ≤ 1 by norm_num)
        hg.neg.continuousOn) hm
    refine ⟨t, ?_⟩
    change -(g t) = 0 at ht
    linarith

theorem plus_minus_distinct (u v : V2) (hu : u ≠ 0) (hv : v ≠ 0) :
    u + v ≠ u - v ∧ u + v ≠ -(u - v) := by
  constructor
  · intro he
    have hz : v = 0 := by
      funext i
      have hi := congrFun he i
      change u i + v i = u i - v i at hi
      change v i = 0
      linarith
    exact hv hz
  · intro he
    have hz : u = 0 := by
      funext i
      have hi := congrFun he i
      change u i + v i = -(u i - v i) at hi
      change u i = 0
      linarith
    exact hu hz

/-- Genuine-prefix continuity is sufficient for an unconditional
two-reading planar phase-retrieval collision. -/
theorem two_readings_not_injective (rows : Rows 2)
    (hrows : ReachableContinuous rows) :
    ∃ x y : V2,
      transcript (oracle rows) 2 x = transcript (oracle rows) 2 y ∧
      x ≠ y ∧ x ≠ -y := by
  let a0 : V2 := rows 0 (fun _ => 0)
  let u : V2 := kernelVector a0
  let g : ℝ → ℝ := fun t =>
    comparison (oracle rows) 1 u (arc t) (arc t)
  have hu : u ≠ 0 := kernelVector_ne_zero a0
  have hg : Continuous g := by
    have hcmp := continuous_test rows hrows 1 Prod.snd continuous_snd
    have hp : Continuous (fun t : ℝ => (u, arc t)) :=
      continuous_const.prodMk continuous_arc
    exact hcmp.comp hp
  have he : g (-1) = -g 1 := by
    dsimp [g]
    rw [arc_endpoint, comparison_flip_right, test_neg_arg]
  obtain ⟨t, ht⟩ := continuous_antipodal_root g hg he
  have hfirst : (oracle rows) [] u = 0 := by
    change mixedDot 2 (rows 0 (encode [])) u = 0
    simpa [u, a0, encode] using kernelVector_dot a0
  have hstage0 : comparison (oracle rows) 0 u (arc t) u = 0 := by
    change (oracle rows) [] u + (oracle rows) [] u = 0
    rw [hfirst]
    ring
  have hstage1 : comparison (oracle rows) 1 u (arc t) (arc t) = 0 := ht
  have hcollision :
      transcript (oracle rows) 2 (u + arc t) =
      transcript (oracle rows) 2 (u - arc t) := by
    apply causal_collision_of_genuine_prefix_zeros
      (oracle rows) (oracle_add rows) (oracle_sub rows) u (arc t) 2
    intro j hj
    have hjcases : j = 0 ∨ j = 1 := by omega
    rcases hjcases with rfl | rfl
    · exact Or.inl hstage0
    · exact Or.inr hstage1
  exact ⟨u + arc t, u - arc t, hcollision,
    (plus_minus_distinct u (arc t) hu (arc_ne_zero t)).1,
    (plus_minus_distinct u (arc t) hu (arc_ne_zero t)).2⟩

#check Nightfall.PhaseN2Unconditional.two_readings_not_injective
#print axioms Nightfall.PhaseN2Unconditional.two_readings_not_injective

end Nightfall.PhaseN2Unconditional
