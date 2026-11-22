import Mathlib

/-! Unconditional planar 2-reading intensity collision via an IVT polynomial arc.
No ProductSphereZero, topology oracle, or custom axiom. This scalar row model
uses global continuity of the second-row selector; reachable-only continuity
will require a separate exact-model bridge. -/

namespace Nightfall.PlanarTwoRowsDirect
noncomputable section

abbrev V2 := ℝ × ℝ
def dot (a x : V2) : ℝ := a.1 * x.1 + a.2 * x.2
def intensity (a x : V2) : ℝ := (dot a x) ^ 2
def protocol (a : V2) (b : ℝ → V2) (x : V2) : ℝ × ℝ :=
  (intensity a x, intensity (b (intensity a x)) x)
def arc (t : ℝ) : V2 := (t, 1 - t ^ 2)

theorem arc_endpoint : arc (-1) = -arc 1 := by
  apply Prod.ext <;> norm_num [arc]

theorem arc_ne_zero (t : ℝ) : arc t ≠ 0 := by
  intro h
  have h0 : t = 0 := by
    have e := congrArg Prod.fst h
    simpa [arc] using e
  have h1 : 1 - t ^ 2 = 0 := by
    have e := congrArg Prod.snd h
    simpa [arc] using e
  nlinarith

theorem arc_continuous : Continuous arc := by
  exact continuous_id.prodMk (continuous_const.sub (continuous_id.pow 2))

def perp (a : V2) : V2 := (-a.2, a.1)
theorem dot_perp (a : V2) : dot a (perp a) = 0 := by
  dsimp [dot, perp]
  ring
theorem perp_nonzero (a : V2) (ha : a ≠ 0) : perp a ≠ 0 := by
  intro hp
  have h0 : a.1 = 0 := by
    have e := congrArg Prod.snd hp
    simpa [perp] using e
  have h1 : a.2 = 0 := by
    have e := congrArg Prod.fst hp
    have he : -(a.2) = 0 := by simpa [perp] using e
    linarith
  exact ha (Prod.ext h0 h1)

def kernel (a : V2) : V2 := if a = 0 then (1, 0) else perp a
theorem kernel_nonzero (a : V2) : kernel a ≠ 0 := by
  by_cases ha : a = 0
  · simp [kernel, ha]
  · simpa [kernel, ha] using perp_nonzero a ha
theorem dot_kernel (a : V2) : dot a (kernel a) = 0 := by
  by_cases ha : a = 0
  · simp [kernel, ha, dot]
  · simpa [kernel, ha] using dot_perp a

theorem dot_add (a u v : V2) : dot a (u + v) = dot a u + dot a v := by
  dsimp [dot]
  ring
theorem dot_sub (a u v : V2) : dot a (u - v) = dot a u - dot a v := by
  dsimp [dot]
  ring
theorem dot_neg (a v : V2) : dot a (-v) = -(dot a v) := by
  dsimp [dot]
  ring
theorem intensity_neg (a v : V2) : intensity a (-v) = intensity a v := by
  simp [intensity, dot_neg]

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
  · intro h
    have hv0 : v = 0 := by
      apply Prod.ext
      · have e := congrArg Prod.fst h
        change u.1 + v.1 = u.1 - v.1 at e
        change v.1 = (0 : ℝ)
        linarith
      · have e := congrArg Prod.snd h
        change u.2 + v.2 = u.2 - v.2 at e
        change v.2 = (0 : ℝ)
        linarith
    exact hv hv0
  · intro h
    have hu0 : u = 0 := by
      apply Prod.ext
      · have e := congrArg Prod.fst h
        change u.1 + v.1 = -(u.1 - v.1) at e
        change u.1 = (0 : ℝ)
        linarith
      · have e := congrArg Prod.snd h
        change u.2 + v.2 = -(u.2 - v.2) at e
        change u.2 = (0 : ℝ)
        linarith
    exact hu hu0

/-- Unconditional two-reading impossibility for a globally continuous
history-selected planar squared-linear intensity row. -/
theorem two_readings_not_injective (a : V2) (b : ℝ → V2)
    (hb : Continuous b) :
    ∃ x y : V2, protocol a b x = protocol a b y ∧
      x ≠ y ∧ x ≠ -y := by
  let u : V2 := kernel a
  let g : ℝ → ℝ := fun t => dot (b (intensity a (arc t))) (arc t)
  have harg : Continuous (fun t : ℝ => intensity a (arc t)) := by
    dsimp [intensity, dot, arc]
    fun_prop
  have hbcomp : Continuous (fun t : ℝ => b (intensity a (arc t))) :=
    hb.comp harg
  have hg : Continuous g := by
    exact ((continuous_fst.comp hbcomp).mul
      (continuous_fst.comp arc_continuous)).add
      ((continuous_snd.comp hbcomp).mul
      (continuous_snd.comp arc_continuous))
  have he : g (-1) = -g 1 := by
    change dot (b (intensity a (arc (-1)))) (arc (-1)) =
      -dot (b (intensity a (arc 1))) (arc 1)
    rw [arc_endpoint, intensity_neg, dot_neg]
  obtain ⟨t, hroot⟩ := continuous_antipodal_root g hg he
  let v := arc t
  have hu : u ≠ 0 := kernel_nonzero a
  have hv : v ≠ 0 := arc_ne_zero t
  have hkernel : dot a u = 0 := dot_kernel a
  have hreadplus : intensity a (u + v) = intensity a v := by
    simp [intensity, dot_add, hkernel]
  have hreadminus : intensity a (u - v) = intensity a v := by
    simp [intensity, dot_sub, hkernel]
  have hroot' : dot (b (intensity a v)) v = 0 := hroot
  have hsecond : intensity (b (intensity a v)) (u + v) =
      intensity (b (intensity a v)) (u - v) := by
    change (dot (b (intensity a v)) (u + v)) ^ 2 =
      (dot (b (intensity a v)) (u - v)) ^ 2
    rw [dot_add, dot_sub, hroot']
    ring
  refine ⟨u + v, u - v, ?_,
    (plus_minus_distinct u v hu hv).1,
    (plus_minus_distinct u v hu hv).2⟩
  simp [protocol, hreadplus, hreadminus, hsecond]

#check two_readings_not_injective
#print axioms two_readings_not_injective

end
end Nightfall.PlanarTwoRowsDirect
