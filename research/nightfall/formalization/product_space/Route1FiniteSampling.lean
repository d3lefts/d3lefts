import Mathlib.Probability.Moments.SubGaussian
import Mathlib.Tactic

/-! Finite-test empirical-law sparsification, supporting #1182.
Independent sample draws and each score's mean bound are explicit.
No assumption of a simultaneous good sample or concentration bound.
The Yao minimax, counting of trees, and entropy/support bridge are separate. -/
namespace Nightfall.Route1Sampling
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal NNReal

theorem finite_test_sample
    {Ω X J : Type*} [MeasurableSpace Ω] [MeasurableSpace X] [Fintype J]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (L : ℕ) (hL : 0 < L)
    (draw : Fin L → Ω → X) (hdraw : ∀ i, Measurable (draw i))
    (hind : iIndepFun draw μ)
    (score : J → X → ℝ) (hscore : ∀ j, Measurable (score j))
    (hb : ∀ j x, score j x ∈ Set.Icc (0 : ℝ) 1)
    (hm : ∀ j i, (∫ ω, score j (draw i ω) ∂μ) ≤ (2 : ℝ)/3)
    (hbudget : (∑' _j : J, ENNReal.ofReal (Real.exp (-(L : ℝ)/288))) < 1) :
    ∃ ω, ∀ j, (∑ i : Fin L, score j (draw i ω)) ≤ (L : ℝ) * (17/24 : ℝ) := by
  classical
  let C (j : J) (i : Fin L) (ω : Ω) : ℝ :=
    score j (draw i ω) - ∫ v, score j (draw i v) ∂μ
  let E (j : J) : Set Ω :=
    {ω | (L : ℝ)/24 ≤ ∑ i : Fin L, C j i ω}
  have hp : ∀ j, μ (E j) ≤ ENNReal.ofReal (Real.exp (-(L : ℝ)/288)) := by
    intro j
    have hi : iIndepFun (C j) μ := by
      exact hind.comp (fun i x => score j x - ∫ v, score j (draw i v) ∂μ)
        (fun i => (hscore j).sub measurable_const)
    have hg : ∀ i : Fin L, HasSubgaussianMGF (C j i) (1/4 : ℝ≥0) μ := by
      intro i
      have h := hasSubgaussianMGF_of_mem_Icc
        ((hscore j).comp (hdraw i)).aemeasurable
        (Filter.Eventually.of_forall (fun ω => hb j (draw i ω)))
      norm_num [C] at h ⊢
      exact h
    have ht := HasSubgaussianMGF.measure_sum_ge_le_of_iIndepFun
      (s := Finset.univ) (c := fun _ : Fin L => (1/4 : ℝ≥0))
      hi (fun i _ => hg i) (ε := (L : ℝ)/24) (by positivity)
    have hLp : (0 : ℝ) < L := by exact_mod_cast hL
    have heq : -((L : ℝ)/24)^2 / (2 * (L * (1/4 : ℝ))) = -(L : ℝ)/288 := by
      field_simp
      <;> ring
    have ht' : (μ (E j)).toReal ≤ Real.exp (-(L : ℝ)/288) := by
      simpa [E, Measure.real, heq] using ht
    calc
      μ (E j) = ENNReal.ofReal ((μ (E j)).toReal) :=
        (ENNReal.ofReal_toReal (measure_ne_top μ _)).symm
      _ ≤ ENNReal.ofReal (Real.exp (-(L : ℝ)/288)) := ENNReal.ofReal_le_ofReal ht'
  have hUnion : μ (⋃ j, E j) < 1 := by
    calc
      μ (⋃ j, E j) ≤ ∑' j, μ (E j) := measure_iUnion_le E
      _ ≤ ∑' _j : J, ENNReal.ofReal (Real.exp (-(L : ℝ)/288)) :=
        ENNReal.tsum_le_tsum hp
      _ < 1 := hbudget
  have hex : ∃ ω, ω ∉ ⋃ j, E j := by
    by_contra! hn
    have hu : (⋃ j, E j) = Set.univ := Set.eq_univ_of_forall hn
    rw [hu, measure_univ] at hUnion
    exact (lt_irrefl 1) hUnion
  obtain ⟨ω, hω⟩ := hex
  refine ⟨ω, ?_⟩
  intro j
  have hnot : ω ∉ E j := fun hj => hω (Set.mem_iUnion.mpr ⟨j, hj⟩)
  have hc : (∑ i : Fin L, C j i ω) < (L : ℝ)/24 := lt_of_not_ge hnot
  have hmean : (∑ i : Fin L, ∫ v, score j (draw i v) ∂μ) ≤ (L : ℝ)*(2/3 : ℝ) := by
    calc
      _ ≤ ∑ _i : Fin L, (2/3 : ℝ) := Finset.sum_le_sum (fun i _ => hm j i)
      _ = _ := by simp [nsmul_eq_mul]
  simp only [C, Finset.sum_sub_distrib] at hc
  linarith

end Nightfall.Route1Sampling
#print axioms Nightfall.Route1Sampling.finite_test_sample
