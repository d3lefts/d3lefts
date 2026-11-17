import InfinitePiQ2NativeSupportedTerminal
import InfinitePiQ2ConditionalSourceTest
import InfinitePiQ2EventualTerminal

/-!
# Original-source finite-label cell averages for infinite-product Q2

Fix finitely many ORIGINAL coordinates of the genuine product law
`Measure.infinitePi μ` and a finite measurable label on each of them.
The finite table of the bounded quadratic source `f` is its exact cell
average over the original product law. This file proves, with no
caller-supplied finite inequality:

* the table is bounded by the source bound;
* the table has native supported degree two whenever `f` has pointwise
  degree two (anchored decomposition + exact coordinate independence);
* every native table influence is at most the genuine original
  conditional-expectation influence of `f`;
* the source variance exceeds the native table variance by at most the
  L² distance from `f` to any function constant on the label cells.

Consequently the original-source finite theorem
`native_heterogeneous_q2_105416_supported_unconditional` applies to every
such table. The infinite-product terminal is composed in
`InfinitePiQ2UnconditionalTerminal`.
-/

namespace Nightfall.InfinitePiQ2CellAverage

set_option maxHeartbeats 1600000

open MeasureTheory ProbabilityTheory Finset
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2NativeHeterogeneousTerminal
open Nightfall.InfinitePiQ2NativeSupportedTerminal
open Nightfall.InfinitePiQ2ConditionalSourceTest

/-! ## Elementary set-integral algebra on a probability space -/

section Basic

variable {Ω : Type*} [MeasurableSpace Ω] (ν : Measure Ω) [IsProbabilityMeasure ν]

theorem integrable_of_abs_le {h : Ω → ℝ} (hm : Measurable h) (B : ℝ)
    (hb : ∀ x, |h x| ≤ B) : Integrable h ν :=
  Integrable.of_bound hm.aestronglyMeasurable B
    (Filter.Eventually.of_forall fun x => by
      simpa only [Real.norm_eq_abs] using hb x)

theorem setIntegral_sq_sub_const {C : Set Ω} {h : Ω → ℝ}
    (hh : Integrable h ν) (hh2 : Integrable (fun x => h x ^ 2) ν) (c : ℝ) :
    ∫ x in C, (h x - c) ^ 2 ∂ν =
      (∫ x in C, h x ^ 2 ∂ν) - 2 * c * (∫ x in C, h x ∂ν) +
        c ^ 2 * ν.real C := by
  have i1 : Integrable (fun x => h x ^ 2 - (2 * c) * h x) (ν.restrict C) :=
    hh2.integrableOn.sub (hh.integrableOn.const_mul _)
  have e : ∫ x in C, (h x - c) ^ 2 ∂ν =
      (∫ x in C, (h x ^ 2 - (2 * c) * h x) ∂ν) + ∫ x in C, c ^ 2 ∂ν := by
    rw [← integral_add i1 (integrable_const _)]
    congr 1; funext x; ring
  rw [e, integral_sub hh2.integrableOn (hh.integrableOn.const_mul _),
    integral_const_mul, setIntegral_const, smul_eq_mul]
  ring

/-- Cauchy–Schwarz on one cell: `m (I₁/m)² ≤ I₂`. -/
theorem cell_sq_avg_le {C : Set Ω} (hC : MeasurableSet C) {h : Ω → ℝ}
    (hh : Integrable h ν) (hh2 : Integrable (fun x => h x ^ 2) ν) :
    ν.real C * ((∫ x in C, h x ∂ν) / ν.real C) ^ 2 ≤
      ∫ x in C, h x ^ 2 ∂ν := by
  have hI2 : 0 ≤ ∫ x in C, h x ^ 2 ∂ν :=
    setIntegral_nonneg hC (fun x _ => sq_nonneg _)
  rcases (measureReal_nonneg : 0 ≤ ν.real C).eq_or_lt with hm | hm
  · rw [← hm]; simpa using hI2
  · set c := (∫ x in C, h x ∂ν) / ν.real C with hc
    have hexp := setIntegral_sq_sub_const (C := C) ν hh hh2 c
    have hnn : 0 ≤ ∫ x in C, (h x - c) ^ 2 ∂ν :=
      setIntegral_nonneg hC (fun x _ => sq_nonneg _)
    have hcm : c * ν.real C = ∫ x in C, h x ∂ν := by
      rw [hc]; exact div_mul_cancel₀ _ hm.ne'
    have hk : c * (∫ x in C, h x ∂ν) = c ^ 2 * ν.real C := by
      rw [← hcm]; ring
    nlinarith

/-- The cell mean minimizes the cell quadratic error. -/
theorem cell_sq_err_le {C : Set Ω} (hC : MeasurableSet C) {h : Ω → ℝ}
    (hh : Integrable h ν) (hh2 : Integrable (fun x => h x ^ 2) ν) (c : ℝ) :
    (∫ x in C, h x ^ 2 ∂ν) -
        ν.real C * ((∫ x in C, h x ∂ν) / ν.real C) ^ 2 ≤
      ∫ x in C, (h x - c) ^ 2 ∂ν := by
  rw [setIntegral_sq_sub_const ν hh hh2 c]
  rcases (measureReal_nonneg : 0 ≤ ν.real C).eq_or_lt with hm | hm
  · have hC0 : ν C = 0 := by
      rw [measureReal_def, eq_comm, ENNReal.toReal_eq_zero_iff] at hm
      rcases hm with h0 | htop
      · exact h0
      · exact absurd htop (measure_ne_top ν C)
    rw [← hm, setIntegral_measure_zero _ hC0, setIntegral_measure_zero _ hC0]
    simp
  · set g := (∫ x in C, h x ∂ν) / ν.real C with hg
    have hgm : g * ν.real C = ∫ x in C, h x ∂ν := by
      rw [hg]; exact div_mul_cancel₀ _ hm.ne'
    rw [← hgm]
    nlinarith [sq_nonneg (g - c), hm]

end Basic

/-! ## Finite measurable labels on original coordinates -/

universe v

variable {ι : Type} [DecidableEq ι] {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-- Finitely many original coordinates, each with a finite measurable label. -/
structure CellLabels (X : ι → Type v) [∀ i, MeasurableSpace (X i)] where
  F : Finset ι
  N : F → ℕ
  pos : ∀ k, 0 < N k
  φ : (k : F) → X k → Fin (N k)
  meas : ∀ (k : F) (a : Fin (N k)), MeasurableSet (φ k ⁻¹' {a})

/-! ### Exact coordinate independence on original cells -/

section Independence

/-- Other-coordinate measurability of a coordinate overwrite. -/
theorem measurable_update_other (i : ι) (t : X i) :
    Measurable[sourceOtherSigma (X := X) i]
      (fun x : (j : ι) → X j => Function.update x i t) := by
  refine @Measurable.of_eval _ _ _ (sourceOtherSigma (X := X) i) _ _ fun j => ?_
  by_cases h : j = i
  · subst h
    have e : (fun x : (l : ι) → X l => Function.update x j t j) = fun _ => t :=
      funext fun x => Function.update_self j t x
    rw [e]
    exact @measurable_const _ _ _ (sourceOtherSigma (X := X) j) _
  · have e : (fun x : (j : ι) → X j => Function.update x i t j) =
        fun x => (sourceOtherIndices i).restrict x ⟨j, h⟩ := by
      funext x
      simp [Function.update_of_ne h, Set.restrict]
    rw [e]
    exact (measurable_pi_apply _).comp (comap_measurable _)

theorem measurable_coord_other {i j : ι} (h : j ≠ i) :
    Measurable[sourceOtherSigma (X := X) i] (fun x : (l : ι) → X l => x j) := by
  have e : (fun x : (l : ι) → X l => x j) =
      fun x => (sourceOtherIndices i).restrict x ⟨j, h⟩ := rfl
  rw [e]
  exact (measurable_pi_apply _).comp (comap_measurable _)

/-- A measurable function insensitive to coordinate `i` is measurable for
the original all-other-coordinates sigma algebra. -/
theorem stronglyMeasurable_other_of_invariant (i : ι) (t0 : X i)
    {V : ((j : ι) → X j) → ℝ} (hV : Measurable V)
    (hinv : ∀ x t, V (Function.update x i t) = V x) :
    StronglyMeasurable[sourceOtherSigma (X := X) i] V := by
  have e : V = fun x => V (Function.update x i t0) := by
    funext x; exact (hinv x t0).symm
  rw [e]
  exact (hV.comp (measurable_update_other i t0)).stronglyMeasurable

variable (μ : (i : ι) → Measure (X i)) [∀ i, IsProbabilityMeasure (μ i)]

/-- Exact factorization of a site test against any other-coordinate function. -/
theorem integral_coord_mul_other (i : ι) {U : X i → ℝ} (hU : Measurable U)
    {W : ((j : ι) → X j) → ℝ}
    (hW : StronglyMeasurable[sourceOtherSigma (X := X) i] W) :
    ∫ x, U (x i) * W x ∂ Measure.infinitePi μ =
      (∫ z, U z ∂ μ i) * ∫ x, W x ∂ Measure.infinitePi μ := by
  have hind : IndepFun (fun x : (j : ι) → X j => U (x i)) W (Measure.infinitePi μ) := by
    rw [IndepFun_iff_Indep]
    refine indep_of_indep_of_le_right
      (indep_of_indep_of_le_left (source_coordinate_other_sigma_indep μ i) ?_) ?_
    · have : (fun x : (j : ι) → X j => U (x i)) = U ∘ (fun x => x i) := rfl
      rw [this, ← MeasurableSpace.comap_comp]
      exact MeasurableSpace.comap_mono hU.comap_le
    · exact hW.measurable.comap_le
  have hUm : AEStronglyMeasurable (fun x : (j : ι) → X j => U (x i))
      (Measure.infinitePi μ) :=
    (hU.comp (measurable_pi_apply i)).aestronglyMeasurable
  have hWm : AEStronglyMeasurable W (Measure.infinitePi μ) :=
    (hW.mono (sourceOtherSigma_le (X := X) i)).aestronglyMeasurable
  rw [hind.integral_fun_mul_eq_mul_integral hUm hWm,
    original_source_coordinate_integral μ i U hU]

end Independence

namespace CellLabels

variable (L : CellLabels X)

abbrev Letter (k : L.F) : Type := Fin (L.N k)

instance instNonemptyLetter (k : L.F) : Nonempty (L.Letter k) := ⟨⟨0, L.pos k⟩⟩

abbrev Word : Type := (k : L.F) → L.Letter k

def word (x : (i : ι) → X i) : L.Word := fun k => L.φ k (x k)

def cell (y : L.Word) : Set ((i : ι) → X i) := {x | L.word x = y}

theorem mem_cell {y : L.Word} {x : (i : ι) → X i} :
    x ∈ L.cell y ↔ ∀ k : L.F, L.φ k (x k) = y k := by
  simp only [cell, word, Set.mem_setOf_eq, funext_iff]

theorem mem_cell_word (x : (i : ι) → X i) : x ∈ L.cell (L.word x) := by
  simp [cell]

theorem measurableSet_cell (y : L.Word) : MeasurableSet (L.cell y) := by
  have h : L.cell y =
      ⋂ k : L.F, (fun x : (i : ι) → X i => x k) ⁻¹' (L.φ k ⁻¹' {y k}) := by
    ext x; simp [mem_cell]
  rw [h]
  exact MeasurableSet.iInter fun k => (measurable_pi_apply (k : ι)) (L.meas k (y k))

variable (μ : (i : ι) → Measure (X i)) [∀ i, IsProbabilityMeasure (μ i)]

/-- Original label probability at one coordinate. -/
noncomputable def prob (k : L.F) (a : L.Letter k) : ℝ :=
  (μ k).real (L.φ k ⁻¹' {a})

theorem prob_nonneg (k : L.F) (a : L.Letter k) : 0 ≤ L.prob μ k a :=
  measureReal_nonneg

theorem prob_sum (k : L.F) : ∑ a : L.Letter k, L.prob μ k a = 1 := by
  unfold prob
  simp only [measureReal_def]
  rw [← ENNReal.toReal_sum (fun a _ => measure_ne_top _ _),
    sum_measure_preimage_singleton _ (fun a _ => L.meas k a)]
  simp

/-- Exact original-product measure of a label cell. -/
theorem measure_cell (y : L.Word) :
    Measure.infinitePi μ (L.cell y) = ∏ k : L.F, μ k (L.φ k ⁻¹' {y k}) := by
  classical
  let t : (i : ι) → Set (X i) := fun i =>
    if h : i ∈ L.F then L.φ ⟨i, h⟩ ⁻¹' {y ⟨i, h⟩} else Set.univ
  have ht : ∀ i ∈ L.F, MeasurableSet (t i) := by
    intro i hi
    simp only [t, dif_pos hi]
    exact L.meas _ _
  have hcell : L.cell y = Set.pi (↑L.F) t := by
    ext x
    simp only [mem_cell, Set.mem_pi, Finset.mem_coe, t]
    constructor
    · intro h i hi
      rw [dif_pos hi]
      exact h ⟨i, hi⟩
    · intro h k
      have hk := h k k.2
      rw [dif_pos k.2] at hk
      exact hk
  rw [hcell, Measure.infinitePi_pi (μ := μ) ht, ← Finset.prod_coe_sort L.F]
  refine Finset.prod_congr rfl fun k _ => ?_
  simp only [t, dif_pos k.2]

/-- Native finite mass of a word is the original cell probability. -/
theorem nativeMass_eq (y : L.Word) :
    nativeMass L.Letter (L.prob μ) y = (Measure.infinitePi μ).real (L.cell y) := by
  unfold nativeMass prob
  rw [measureReal_def, measure_cell, ENNReal.toReal_prod]
  rfl

/-- Integrals split exactly over the finite family of label cells. -/
theorem sum_setIntegral_cell {h : ((i : ι) → X i) → ℝ}
    (hh : Integrable h (Measure.infinitePi μ)) :
    ∑ y : L.Word, ∫ x in L.cell y, h x ∂ Measure.infinitePi μ =
      ∫ x, h x ∂ Measure.infinitePi μ := by
  have hpt : ∀ x, ∑ y : L.Word, (L.cell y).indicator h x = h x := by
    intro x
    rw [Finset.sum_eq_single (L.word x)]
    · exact Set.indicator_of_mem (L.mem_cell_word x) h
    · intro y _ hy
      apply Set.indicator_of_notMem
      intro hx
      exact hy hx.symm
    · intro hx; exact absurd (Finset.mem_univ _) hx
  calc
    ∑ y : L.Word, ∫ x in L.cell y, h x ∂ Measure.infinitePi μ =
        ∑ y : L.Word, ∫ x, (L.cell y).indicator h x ∂ Measure.infinitePi μ := by
      refine Finset.sum_congr rfl fun y _ => ?_
      rw [integral_indicator (L.measurableSet_cell y)]
    _ = ∫ x, ∑ y : L.Word, (L.cell y).indicator h x ∂ Measure.infinitePi μ :=
      (integral_finsetSum _ fun y _ =>
        hh.indicator (L.measurableSet_cell y)).symm
    _ = ∫ x, h x ∂ Measure.infinitePi μ := by simp_rw [hpt]

theorem sum_nativeMass : ∑ y : L.Word, nativeMass L.Letter (L.prob μ) y = 1 := by
  simp_rw [L.nativeMass_eq μ]
  have h := L.sum_setIntegral_cell μ (h := fun _ => (1 : ℝ)) (integrable_const _)
  simpa [setIntegral_const] using h

/-- The original-source cell average table of a function. -/
noncomputable def avg (f : ((i : ι) → X i) → ℝ) (y : L.Word) : ℝ :=
  (∫ x in L.cell y, f x ∂ Measure.infinitePi μ) /
    (Measure.infinitePi μ).real (L.cell y)

theorem avg_mul_mass (f : ((i : ι) → X i) → ℝ) (y : L.Word) :
    L.avg μ f y * (Measure.infinitePi μ).real (L.cell y) =
      ∫ x in L.cell y, f x ∂ Measure.infinitePi μ := by
  unfold avg
  rcases (measureReal_nonneg :
      0 ≤ (Measure.infinitePi μ).real (L.cell y)).eq_or_lt with hm | hm
  · have hC0 : Measure.infinitePi μ (L.cell y) = 0 := by
      rw [measureReal_def, eq_comm, ENNReal.toReal_eq_zero_iff] at hm
      rcases hm with h0 | htop
      · exact h0
      · exact absurd htop (measure_ne_top _ _)
    rw [← hm, setIntegral_measure_zero _ hC0]; simp
  · exact div_mul_cancel₀ _ hm.ne'

theorem avg_add {f g : ((i : ι) → X i) → ℝ}
    (hf : Integrable f (Measure.infinitePi μ)) (hg : Integrable g (Measure.infinitePi μ))
    (y : L.Word) :
    L.avg μ (fun x => f x + g x) y = L.avg μ f y + L.avg μ g y := by
  unfold avg
  rw [integral_add hf.integrableOn hg.integrableOn, add_div]

/-! ### Boundedness -/

theorem abs_avg_le {f : ((i : ι) → X i) → ℝ} {B : ℝ} (hB : 0 ≤ B)
    (hb : ∀ x, |f x| ≤ B) (y : L.Word) : |L.avg μ f y| ≤ B := by
  unfold avg
  rcases (measureReal_nonneg :
      0 ≤ (Measure.infinitePi μ).real (L.cell y)).eq_or_lt with hm | hm
  · rw [← hm, div_zero, abs_zero]; exact hB
  · rw [abs_div, abs_of_pos hm, div_le_iff₀ hm]
    have h := norm_setIntegral_le_of_norm_le_const (μ := Measure.infinitePi μ)
      (s := L.cell y) (f := f) (C := B) (measure_lt_top _ _)
      (fun x _ => by simpa only [Real.norm_eq_abs] using hb x)
    simpa only [Real.norm_eq_abs] using h

/-! ### Variance comparison -/

theorem native_mean_eq {f : ((i : ι) → X i) → ℝ}
    (hf : Integrable f (Measure.infinitePi μ)) :
    nativeMean L.Letter (L.prob μ) (L.avg μ f) =
      ∫ x, f x ∂ Measure.infinitePi μ := by
  unfold nativeMean
  rw [← L.sum_setIntegral_cell μ hf]
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [L.nativeMass_eq μ, mul_comm, L.avg_mul_mass μ]

theorem native_variance_eq {f : ((i : ι) → X i) → ℝ}
    (hf : Integrable f (Measure.infinitePi μ)) :
    nativeVariance L.Letter (L.prob μ) (L.avg μ f) =
      (∑ y : L.Word, nativeMass L.Letter (L.prob μ) y * L.avg μ f y ^ 2) -
        (∫ x, f x ∂ Measure.infinitePi μ) ^ 2 := by
  unfold nativeVariance
  rw [L.native_mean_eq μ hf]
  set E := ∫ x, f x ∂ Measure.infinitePi μ
  have hmean : ∑ y : L.Word, nativeMass L.Letter (L.prob μ) y * L.avg μ f y = E := by
    have := L.native_mean_eq μ hf
    unfold nativeMean at this
    exact this
  have hmass := L.sum_nativeMass μ
  have e : ∀ y : L.Word,
      nativeMass L.Letter (L.prob μ) y * (L.avg μ f y - E) ^ 2 =
        nativeMass L.Letter (L.prob μ) y * L.avg μ f y ^ 2 -
          2 * E * (nativeMass L.Letter (L.prob μ) y * L.avg μ f y) +
            E ^ 2 * nativeMass L.Letter (L.prob μ) y := by
    intro y; ring
  simp_rw [e, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    hmean, hmass]
  ring

/-- Source variance minus native table variance is at most the L² error of
ANY function constant on every label cell. -/
theorem variance_gap_le {f u : ((i : ι) → X i) → ℝ}
    (hf : Integrable f (Measure.infinitePi μ))
    (hf2 : Integrable (fun x => f x ^ 2) (Measure.infinitePi μ))
    (hfu : Integrable (fun x => (f x - u x) ^ 2) (Measure.infinitePi μ))
    (hu : ∀ y : L.Word, ∀ x ∈ L.cell y, ∀ x' ∈ L.cell y, u x = u x') :
    ((∫ x, f x ^ 2 ∂ Measure.infinitePi μ) -
        (∫ x, f x ∂ Measure.infinitePi μ) ^ 2) -
      nativeVariance L.Letter (L.prob μ) (L.avg μ f) ≤
      ∫ x, (f x - u x) ^ 2 ∂ Measure.infinitePi μ := by
  rw [L.native_variance_eq μ hf, ← L.sum_setIntegral_cell μ hf2,
    ← L.sum_setIntegral_cell μ hfu]
  have hcell : ∀ y : L.Word,
      (∫ x in L.cell y, f x ^ 2 ∂ Measure.infinitePi μ) -
          nativeMass L.Letter (L.prob μ) y * L.avg μ f y ^ 2 ≤
        ∫ x in L.cell y, (f x - u x) ^ 2 ∂ Measure.infinitePi μ := by
    intro y
    rw [L.nativeMass_eq μ]
    by_cases hne : (L.cell y).Nonempty
    · obtain ⟨x0, hx0⟩ := hne
      have hconst : ∫ x in L.cell y, (f x - u x) ^ 2 ∂ Measure.infinitePi μ =
          ∫ x in L.cell y, (f x - u x0) ^ 2 ∂ Measure.infinitePi μ := by
        refine setIntegral_congr_fun (L.measurableSet_cell y) fun x hx => ?_
        simp only [hu y x hx x0 hx0]
      rw [hconst]
      exact cell_sq_err_le _ (L.measurableSet_cell y) hf hf2 (u x0)
    · rw [Set.not_nonempty_iff_eq_empty] at hne
      rw [hne]
      simp
  have := Finset.sum_le_sum fun y (_ : y ∈ (Finset.univ : Finset L.Word)) => hcell y
  rw [Finset.sum_sub_distrib] at this
  linarith


/-- The cell of all labels except at `k`. -/
def otherCell (k : L.F) (y : L.Word) : Set ((i : ι) → X i) :=
  {x | ∀ l : L.F, l ≠ k → L.φ l (x l) = y l}

theorem measurableSet_otherCell_other (k : L.F) (y : L.Word) :
    MeasurableSet[sourceOtherSigma (X := X) (k : ι)] (L.otherCell k y) := by
  have h : L.otherCell k y =
      ⋂ l : L.F, {x : (i : ι) → X i | l ≠ k → L.φ l (x l) = y l} := by
    ext x; simp [otherCell]
  rw [h]
  refine MeasurableSet.iInter fun l => ?_
  by_cases hl : l = k
  · have : {x : (i : ι) → X i | l ≠ k → L.φ l (x l) = y l} = Set.univ := by
      ext x; simp [hl]
    rw [this]; exact MeasurableSet.univ
  · have hne : (l : ι) ≠ (k : ι) := fun h => hl (Subtype.ext h)
    have : {x : (i : ι) → X i | l ≠ k → L.φ l (x l) = y l} =
        (fun x : (i : ι) → X i => x l) ⁻¹' (L.φ l ⁻¹' {y l}) := by
      ext x; simp [hl]
    rw [this]
    exact (measurable_coord_other hne) (L.meas l (y l))

theorem measurableSet_otherCell (k : L.F) (y : L.Word) :
    MeasurableSet (L.otherCell k y) :=
  sourceOtherSigma_le (X := X) (k : ι) _ (L.measurableSet_otherCell_other k y)

theorem cell_update_indicator (k : L.F) (y : L.Word) (a : L.Letter k)
    (W : ((i : ι) → X i) → ℝ) (x : (i : ι) → X i) :
    (L.cell (Function.update y k a)).indicator W x =
      (L.φ k ⁻¹' {a}).indicator (fun _ => (1 : ℝ)) (x k) *
        (L.otherCell k y).indicator W x := by
  have hmem : x ∈ L.cell (Function.update y k a) ↔
      L.φ k (x k) = a ∧ x ∈ L.otherCell k y := by
    rw [mem_cell]
    constructor
    · intro h
      refine ⟨by simpa using h k, fun l hl => ?_⟩
      simpa [Function.update_of_ne hl] using h l
    · rintro ⟨h1, h2⟩ l
      by_cases hl : l = k
      · subst hl; simpa using h1
      · simpa [Function.update_of_ne hl] using h2 l hl
  by_cases h1 : L.φ k (x k) = a <;> by_cases h2 : x ∈ L.otherCell k y <;>
    simp [Set.indicator, hmem, h1, h2]

/-- Exact factorization of a cell integral at coordinate `k`. -/
theorem setIntegral_cell_update (k : L.F) (y : L.Word) (a : L.Letter k)
    {W : ((i : ι) → X i) → ℝ}
    (hW : StronglyMeasurable[sourceOtherSigma (X := X) (k : ι)] W) :
    ∫ x in L.cell (Function.update y k a), W x ∂ Measure.infinitePi μ =
      L.prob μ k a * ∫ x in L.otherCell k y, W x ∂ Measure.infinitePi μ := by
  rw [← integral_indicator (L.measurableSet_cell _),
    ← integral_indicator (L.measurableSet_otherCell k y)]
  simp_rw [L.cell_update_indicator k y a W]
  have hWD : StronglyMeasurable[sourceOtherSigma (X := X) (k : ι)]
      ((L.otherCell k y).indicator W) :=
    hW.indicator (L.measurableSet_otherCell_other k y)
  rw [integral_coord_mul_other μ (k : ι)
      (measurable_const.indicator (L.meas k a)) hWD]
  congr 1
  rw [integral_indicator (L.meas k a), setIntegral_const, smul_eq_mul, mul_one]
  rfl

theorem mass_update (k : L.F) (y : L.Word) (a : L.Letter k) :
    (Measure.infinitePi μ).real (L.cell (Function.update y k a)) =
      L.prob μ k a * (Measure.infinitePi μ).real (L.otherCell k y) := by
  have h := L.setIntegral_cell_update μ k y a
    (W := fun _ => (1 : ℝ)) stronglyMeasurable_const
  simpa [setIntegral_const] using h

theorem otherCell_update (k : L.F) (y : L.Word) (a : L.Letter k) :
    L.otherCell k (Function.update y k a) = L.otherCell k y := by
  ext x
  simp only [otherCell, Set.mem_setOf_eq]
  constructor
  · intro h l hl; simpa [Function.update_of_ne hl] using h l hl
  · intro h l hl; simpa [Function.update_of_ne hl] using h l hl

/-- An other-cell splits exactly over the letter at `k`. -/
theorem setIntegral_otherCell_split (k : L.F) (y : L.Word)
    {h : ((i : ι) → X i) → ℝ} (hh : Integrable h (Measure.infinitePi μ)) :
    ∫ x in L.otherCell k y, h x ∂ Measure.infinitePi μ =
      ∑ a : L.Letter k,
        ∫ x in L.cell (Function.update y k a), h x ∂ Measure.infinitePi μ := by
  have hpt : ∀ x, (L.otherCell k y).indicator h x =
      ∑ a : L.Letter k, (L.cell (Function.update y k a)).indicator h x := by
    intro x
    simp_rw [L.cell_update_indicator k y _ h x]
    rw [Finset.sum_eq_single (L.φ k (x k))]
    · simp
    · intro b _ hb
      have : x k ∉ L.φ k ⁻¹' {b} := fun hx => hb (Set.mem_singleton_iff.mp hx).symm
      simp [Set.indicator_of_notMem this]
    · intro hx; exact absurd (Finset.mem_univ _) hx
  rw [← integral_indicator (L.measurableSet_otherCell k y)]
  simp_rw [hpt]
  rw [integral_finsetSum _ fun a _ => hh.indicator (L.measurableSet_cell _)]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [integral_indicator (L.measurableSet_cell _)]

/-! ### Influence contraction -/

/-- Exact heat-bath identity: the native one-coordinate resampling of the
cell-average table equals the cell integral of the genuine original
conditional expectation, for EVERY word (no positivity needed). -/
theorem heatBath_mass_eq (k : L.F) (y : L.Word) {f : ((i : ι) → X i) → ℝ}
    (hf : Integrable f (Measure.infinitePi μ))
    {h' : ((i : ι) → X i) → ℝ}
    (hh' : StronglyMeasurable[sourceOtherSigma (X := X) (k : ι)] h')
    (hset : ∀ s, MeasurableSet[sourceOtherSigma (X := X) (k : ι)] s →
      ∫ x in s, h' x ∂ Measure.infinitePi μ = ∫ x in s, f x ∂ Measure.infinitePi μ) :
    (∑ a : L.Letter k, L.prob μ k a * L.avg μ f (Function.update y k a)) *
        (Measure.infinitePi μ).real (L.cell y) =
      ∫ x in L.cell y, h' x ∂ Measure.infinitePi μ := by
  have hy : Function.update y k (y k) = y := Function.update_eq_self k y
  have hmy : (Measure.infinitePi μ).real (L.cell y) = L.prob μ k (y k) * (Measure.infinitePi μ).real (L.otherCell k y) := by
    conv_lhs => rw [← hy]
    exact L.mass_update μ k y (y k)
  have hcy : ∫ x in L.cell y, h' x ∂ Measure.infinitePi μ =
      L.prob μ k (y k) * ∫ x in L.otherCell k y, h' x ∂ Measure.infinitePi μ := by
    conv_lhs => rw [← hy]
    exact L.setIntegral_cell_update μ k y (y k) hh'
  have hterm : ∀ a : L.Letter k,
      L.prob μ k a * L.avg μ f (Function.update y k a) * (Measure.infinitePi μ).real (L.otherCell k y) =
        ∫ x in L.cell (Function.update y k a), f x ∂ Measure.infinitePi μ := by
    intro a
    rw [← L.avg_mul_mass μ f, L.mass_update μ k y a]
    ring
  rw [hmy, hcy, hset _ (L.measurableSet_otherCell_other k y),
    L.setIntegral_otherCell_split μ k y hf, Finset.mul_sum]
  calc
    (∑ a : L.Letter k, L.prob μ k a * L.avg μ f (Function.update y k a)) *
        (L.prob μ k (y k) * (Measure.infinitePi μ).real (L.otherCell k y)) =
        L.prob μ k (y k) *
          ∑ a : L.Letter k, L.prob μ k a * L.avg μ f (Function.update y k a) * (Measure.infinitePi μ).real (L.otherCell k y) := by
      rw [Finset.sum_mul, Finset.mul_sum]
      refine Finset.sum_congr rfl fun a _ => ?_
      ring
    _ = ∑ a : L.Letter k, L.prob μ k (y k) *
          ∫ x in L.cell (Function.update y k a), f x ∂ Measure.infinitePi μ := by
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun a _ => ?_
      rw [hterm a]

/-- Every native table influence is at most the genuine original-source
coordinate influence of the bounded measurable source function. -/
theorem native_influence_le {f : ((i : ι) → X i) → ℝ} (hfm : Measurable f)
    {B : ℝ} (hb : ∀ x, |f x| ≤ B)
    (hf2 : MemLp f 2 (Measure.infinitePi μ)) (k : L.F) :
    nativeInfluence L.Letter (L.prob μ) (L.avg μ f) k ≤
      sourceCoordinateInfluence μ (k : ι) (hf2.toLp f) := by
  have hf : Integrable f (Measure.infinitePi μ) :=
    integrable_of_abs_le (Measure.infinitePi μ) hfm B hb
  have hPm : AEStronglyMeasurable[sourceOtherSigma (X := X) (k : ι)]
      (sourceOtherProjection μ (k : ι) (hf2.toLp f) : ((i : ι) → X i) → ℝ)
      (Measure.infinitePi μ) :=
    lpMeas.aestronglyMeasurable
      (condExpL2 ℝ ℝ (sourceOtherSigma_le (X := X) (k : ι)) (hf2.toLp f))
  obtain ⟨h', hh', hPh'⟩ := hPm
  have hset : ∀ s, MeasurableSet[sourceOtherSigma (X := X) (k : ι)] s →
      ∫ x in s, h' x ∂(Measure.infinitePi μ) =
        ∫ x in s, f x ∂(Measure.infinitePi μ) := by
    intro s hs
    have hs' : MeasurableSet s := sourceOtherSigma_le (X := X) (k : ι) _ hs
    have h1 : ∫ x in s, h' x ∂(Measure.infinitePi μ) =
        ∫ x in s, (sourceOtherProjection μ (k : ι) (hf2.toLp f) :
          ((i : ι) → X i) → ℝ) x ∂(Measure.infinitePi μ) :=
      setIntegral_congr_ae hs' (hPh'.mono fun x hx _ => hx.symm)
    have h2 : ∫ x in s, (sourceOtherProjection μ (k : ι) (hf2.toLp f) :
          ((i : ι) → X i) → ℝ) x ∂(Measure.infinitePi μ) =
        ∫ x in s, (hf2.toLp f) x ∂(Measure.infinitePi μ) :=
      integral_condExpL2_eq (sourceOtherSigma_le (X := X) (k : ι)) (hf2.toLp f) hs
        (measure_ne_top _ _)
    have h3 : ∫ x in s, (hf2.toLp f) x ∂(Measure.infinitePi μ) =
        ∫ x in s, f x ∂(Measure.infinitePi μ) :=
      setIntegral_congr_ae hs' ((hf2.coeFn_toLp).mono fun x hx _ => hx)
    rw [h1, h2, h3]
  have hres : ((hf2.toLp f - sourceOtherProjection μ (k : ι) (hf2.toLp f) :
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) : ((i : ι) → X i) → ℝ)
        =ᵐ[Measure.infinitePi μ] fun x => f x - h' x := by
    filter_upwards [Lp.coeFn_sub (hf2.toLp f)
      (sourceOtherProjection μ (k : ι) (hf2.toLp f)), hf2.coeFn_toLp, hPh']
      with x h1 h2 h3
    rw [h1, Pi.sub_apply, h2, h3]
  have hR2 : Integrable (fun x => (f x - h' x) ^ 2) (Measure.infinitePi μ) := by
    have := (Lp.memLp (hf2.toLp f -
      sourceOtherProjection μ (k : ι) (hf2.toLp f))).integrable_sq
    exact this.congr (hres.mono fun x hx => by simp only [hx])
  have hP1 : Integrable h' (Measure.infinitePi μ) := by
    have : Integrable (sourceOtherProjection μ (k : ι) (hf2.toLp f) :
        ((i : ι) → X i) → ℝ) (Measure.infinitePi μ) :=
      (Lp.memLp _).integrable one_le_two
    exact this.congr hPh'
  have hR1 : Integrable (fun x => f x - h' x) (Measure.infinitePi μ) := hf.sub hP1
  have hInf : sourceCoordinateInfluence μ (k : ι) (hf2.toLp f) =
      ∫ x, (f x - h' x) ^ 2 ∂(Measure.infinitePi μ) := by
    unfold sourceCoordinateInfluence sourceCoordinateResidual
    rw [← real_inner_self_eq_norm_sq, L2.inner_def]
    refine integral_congr_ae (hres.mono fun x hx => ?_)
    dsimp only
    rw [hx]
    simp only [real_inner_self_eq_norm_sq, Real.norm_eq_abs, sq_abs]
  rw [hInf, ← L.sum_setIntegral_cell μ hR2]
  unfold nativeInfluence
  refine Finset.sum_le_sum fun y _ => ?_
  rw [L.nativeMass_eq μ]
  have hcell := cell_sq_avg_le (Measure.infinitePi μ) (L.measurableSet_cell y) hR1 hR2
  rcases (measureReal_nonneg :
      0 ≤ (Measure.infinitePi μ).real (L.cell y)).eq_or_lt with hm | hm
  · rw [← hm, zero_mul]
    exact setIntegral_nonneg (L.measurableSet_cell y) fun x _ => sq_nonneg _
  · have hHB := L.heatBath_mass_eq μ k y hf hh' hset
    have hdiff : L.avg μ f y -
        ∑ a : L.Letter k, L.prob μ k a * L.avg μ f (Function.update y k a) =
        (∫ x in L.cell y, (f x - h' x) ∂(Measure.infinitePi μ)) /
          (Measure.infinitePi μ).real (L.cell y) := by
      rw [integral_sub hf.integrableOn hP1.integrableOn, ← hHB, ← L.avg_mul_mass μ f,
        ← sub_mul, mul_div_assoc, div_self hm.ne', mul_one]
    rw [hdiff]
    exact hcell

/-! ### Degree two of the cell-average table -/

/-- If a source function ignores coordinate `k`, its table ignores every
positive letter at `k`. -/
theorem avg_update_invariant (k : L.F) (t0 : X k)
    {V : ((i : ι) → X i) → ℝ} (hV : Measurable V)
    (hinv : ∀ x t, V (Function.update x (k : ι) t) = V x)
    (y : L.Word) (a a' : L.Letter k)
    (ha : 0 < L.prob μ k a) (ha' : 0 < L.prob μ k a') :
    L.avg μ V (Function.update y k a) = L.avg μ V (Function.update y k a') := by
  have hW := stronglyMeasurable_other_of_invariant (k : ι) t0 hV hinv
  have e : ∀ b : L.Letter k, 0 < L.prob μ k b →
      L.avg μ V (Function.update y k b) =
        (∫ x in L.otherCell k y, V x ∂ Measure.infinitePi μ) /
          (Measure.infinitePi μ).real (L.otherCell k y) := by
    intro b hb
    unfold avg
    rw [L.setIntegral_cell_update μ k y b hW, L.mass_update μ k y b,
      mul_div_mul_left _ _ hb.ne']
  rw [e a ha, e a' ha']

/-- Triple differences vanish when the table ignores the outer coordinate. -/
theorem delta_three_zero_of_outer {G : L.Word → ℝ}
    (i j k : L.F) (hij : i ≠ j) (hik : i ≠ k)
    (a a' : L.Letter i) (b b' : L.Letter j) (c c' : L.Letter k)
    (hinv : ∀ z : L.Word, G (Function.update z i a) = G (Function.update z i a'))
    (y : L.Word) :
    delta i a a' (delta j b b' (delta k c c' G)) y = 0 := by
  simp only [delta]
  have e : ∀ (β : L.Letter j) (γ : L.Letter k) (α : L.Letter i),
      Function.update (Function.update (Function.update y i α) j β) k γ =
        Function.update (Function.update (Function.update y j β) k γ) i α := by
    intro β γ α
    rw [Function.update_comm hij, Function.update_comm hik]
  simp only [e, hinv]
  ring

theorem delta_comm {G : L.Word → ℝ} (i j : L.F) (hij : i ≠ j)
    (a a' : L.Letter i) (b b' : L.Letter j) :
    delta i a a' (delta j b b' G) = delta j b b' (delta i a a' G) := by
  funext y
  simp only [delta]
  rw [Function.update_comm hij a b, Function.update_comm hij a b',
    Function.update_comm hij a' b, Function.update_comm hij a' b']
  ring

/-- Anchored three-term decomposition of a pointwise degree-two source. -/
theorem anchored_decomposition {f : ((i : ι) → X i) → ℝ}
    (hdeg : PointwiseDegreeTwo f) (i1 i2 i3 : ι)
    (h12 : i1 ≠ i2) (h13 : i1 ≠ i3) (h23 : i2 ≠ i3)
    (u1 : X i1) (u2 : X i2) (u3 : X i3) (x : (i : ι) → X i) :
    f x =
      (f (Function.update x i1 u1) -
        f (Function.update (Function.update x i1 u1) i3 u3) -
        f (Function.update (Function.update x i1 u1) i2 u2) +
        f (Function.update (Function.update (Function.update x i1 u1) i2 u2) i3 u3)) +
      (f (Function.update x i2 u2) -
        f (Function.update (Function.update x i2 u2) i3 u3)) +
      f (Function.update x i3 u3) := by
  have h := hdeg i1 i2 i3 h12 h13 h23 (x i1) u1 (x i2) u2 (x i3) u3 x
  simp only [delta] at h
  have e1 : ∀ (w : (i : ι) → X i), w i2 = x i2 → w i3 = x i3 →
      Function.update (Function.update w i2 (x i2)) i3 (x i3) = w := by
    intro w hw2 hw3
    rw [← hw2, Function.update_eq_self]
    rw [← hw3, Function.update_eq_self]
  have e2 : ∀ (w : (i : ι) → X i) (v : X i2), w i3 = x i3 →
      Function.update (Function.update w i2 v) i3 (x i3) = Function.update w i2 v := by
    intro w v hw3
    apply Function.update_eq_self_iff.mpr
    rw [Function.update_of_ne h23.symm, hw3]
  have e3 : ∀ (w : (i : ι) → X i), w i2 = x i2 →
      Function.update w i2 (x i2) = w := by
    intro w hw2
    rw [← hw2, Function.update_eq_self]
  rw [Function.update_eq_self] at h
  rw [e1 x rfl rfl, e2 x u2 rfl, e3 x rfl,
    e1 (Function.update x i1 u1) (by rw [Function.update_of_ne h12.symm])
      (by rw [Function.update_of_ne h13.symm]),
    e2 (Function.update x i1 u1) u2 (by rw [Function.update_of_ne h13.symm]),
    e3 (Function.update x i1 u1) (by rw [Function.update_of_ne h12.symm])] at h
  linarith

/-- The cell-average table of a bounded measurable pointwise degree-two
source has native supported degree two. -/
theorem avg_nativeSupportedDegreeTwo {f : ((i : ι) → X i) → ℝ}
    (hfm : Measurable f) {B : ℝ} (hb : ∀ x, |f x| ≤ B)
    (hdeg : PointwiseDegreeTwo f) (x0 : (i : ι) → X i) :
    NativeSupportedDegreeTwo L.Letter (L.prob μ) (L.avg μ f) := by
  intro k1 k2 k3 h12 h13 h23 a a' b b' c c' y _ ha ha' hb1 hb1' hc hc'
  have n12 : (k1 : ι) ≠ k2 := fun h => h12 (Subtype.ext h)
  have n13 : (k1 : ι) ≠ k3 := fun h => h13 (Subtype.ext h)
  have n23 : (k2 : ι) ≠ k3 := fun h => h23 (Subtype.ext h)
  set u1 := x0 k1
  set u2 := x0 k2
  set u3 := x0 k3
  have hupd : ∀ (j : ι) (t : X j), Measurable fun x : (i : ι) → X i => Function.update x j t :=
    fun j t => (measurable_update_other j t).mono (sourceOtherSigma_le (X := X) j) le_rfl
  let A1 : ((i : ι) → X i) → ℝ := fun x =>
    f (Function.update x k1 u1) -
      f (Function.update (Function.update x k1 u1) k3 u3) -
      f (Function.update (Function.update x k1 u1) k2 u2) +
      f (Function.update (Function.update (Function.update x k1 u1) k2 u2) k3 u3)
  let A2 : ((i : ι) → X i) → ℝ := fun x =>
    f (Function.update x k2 u2) - f (Function.update (Function.update x k2 u2) k3 u3)
  let A3 : ((i : ι) → X i) → ℝ := fun x => f (Function.update x k3 u3)
  have mA1 : Measurable A1 := by
    refine (((hfm.comp (hupd _ _)).sub (hfm.comp ((hupd _ _).comp (hupd _ _)))).sub
      (hfm.comp ((hupd _ _).comp (hupd _ _)))).add
      (hfm.comp ((hupd _ _).comp ((hupd _ _).comp (hupd _ _))))
  have mA2 : Measurable A2 :=
    (hfm.comp (hupd _ _)).sub (hfm.comp ((hupd _ _).comp (hupd _ _)))
  have mA3 : Measurable A3 := hfm.comp (hupd _ _)
  have bA1 : ∀ x, |A1 x| ≤ 4 * B := by
    intro x
    have h1 := abs_le.mp (hb (Function.update x k1 u1))
    have h2 := abs_le.mp (hb (Function.update (Function.update x k1 u1) k3 u3))
    have h3 := abs_le.mp (hb (Function.update (Function.update x k1 u1) k2 u2))
    have h4 := abs_le.mp
      (hb (Function.update (Function.update (Function.update x k1 u1) k2 u2) k3 u3))
    simp only [A1]
    rw [abs_le]
    constructor <;> linarith [h1.1, h1.2, h2.1, h2.2, h3.1, h3.2, h4.1, h4.2]
  have bA2 : ∀ x, |A2 x| ≤ 2 * B := by
    intro x
    have h1 := abs_le.mp (hb (Function.update x k2 u2))
    have h2 := abs_le.mp (hb (Function.update (Function.update x k2 u2) k3 u3))
    simp only [A2]
    rw [abs_le]
    constructor <;> linarith [h1.1, h1.2, h2.1, h2.2]
  have iA1 : Integrable A1 (Measure.infinitePi μ) := integrable_of_abs_le (Measure.infinitePi μ) mA1 _ bA1
  have iA2 : Integrable A2 (Measure.infinitePi μ) := integrable_of_abs_le (Measure.infinitePi μ) mA2 _ bA2
  have iA3 : Integrable A3 (Measure.infinitePi μ) := integrable_of_abs_le (Measure.infinitePi μ) mA3 _ fun x => hb _
  have hdec : ∀ x, f x = A1 x + A2 x + A3 x := fun x =>
    anchored_decomposition hdeg k1 k2 k3 n12 n13 n23 u1 u2 u3 x
  have hsum : ∀ z : L.Word, L.avg μ f z = L.avg μ A1 z + L.avg μ A2 z + L.avg μ A3 z := by
    intro z
    have hf' : f = fun x => (A1 x + A2 x) + A3 x := funext hdec
    rw [hf', L.avg_add μ (f := fun x => A1 x + A2 x) (g := A3) (iA1.add iA2) iA3,
      L.avg_add μ iA1 iA2]
  have inv1 : ∀ x t, A1 (Function.update x (k1 : ι) t) = A1 x := by
    intro x t; simp only [A1, Function.update_idem]
  have inv2 : ∀ x t, A2 (Function.update x (k2 : ι) t) = A2 x := by
    intro x t; simp only [A2, Function.update_idem]
  have inv3 : ∀ x t, A3 (Function.update x (k3 : ι) t) = A3 x := by
    intro x t; simp only [A3, Function.update_idem]
  have z1 : delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ A1))) y = 0 :=
    L.delta_three_zero_of_outer k1 k2 k3 h12 h13 a a' b b' c c'
      (fun z => L.avg_update_invariant μ k1 u1 mA1 inv1 z a a' ha ha') y
  have z2 : delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ A2))) y = 0 := by
    rw [L.delta_comm k1 k2 h12]
    exact L.delta_three_zero_of_outer k2 k1 k3 (Ne.symm h12) h23 b b' a a' c c'
      (fun z => L.avg_update_invariant μ k2 u2 mA2 inv2 z b b' hb1 hb1') y
  have z3 : delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ A3))) y = 0 := by
    have e1 := L.delta_comm (G := L.avg μ A3) k2 k3 h23 b b' c c'
    rw [e1, L.delta_comm k1 k3 h13]
    exact L.delta_three_zero_of_outer k3 k1 k2 (Ne.symm h13) (Ne.symm h23) c c' a a' b b'
      (fun z => L.avg_update_invariant μ k3 u3 mA3 inv3 z c c' hc hc') y
  have hlin : delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ f))) y =
      delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ A1))) y +
      delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ A2))) y +
      delta k1 a a' (delta k2 b b' (delta k3 c c' (L.avg μ A3))) y := by
    simp only [delta, hsum]
    ring
  rw [hlin, z1, z2, z3]
  ring

/-! ### The finite original-source Q2 inequality for every label table -/

/-- Unconditional C105.416 inequality for the original-source cell-average
table of a bounded measurable pointwise degree-two source, with the
genuine original infinite-product influences on the right. -/
theorem cellAverage_q2 {f : ((i : ι) → X i) → ℝ} (hfm : Measurable f)
    (hdeg : PointwiseDegreeTwo f) {B : ℝ} (hB : 0 ≤ B) (hb : ∀ x, |f x| ≤ B)
    (hf2 : MemLp f 2 (Measure.infinitePi μ)) {M : ℝ} (hM : 0 ≤ M)
    (hI : ∀ i : ι, sourceCoordinateInfluence μ i (hf2.toLp f) ≤ M)
    (x0 : (i : ι) → X i) [Nonempty L.F] :
    (nativeVariance L.Letter (L.prob μ) (L.avg μ f)) ^ 2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2 * B ^ 2 * M :=
  native_heterogeneous_q2_105416_supported_unconditional L.Letter (L.prob μ)
    (L.prob_nonneg μ) (L.prob_sum μ) (L.avg μ f)
    (L.avg_nativeSupportedDegreeTwo μ hfm hb hdeg x0) B hB
    (fun y _ => L.abs_avg_le μ hB hb y) M hM
    (fun k => (L.native_influence_le μ hfm hb hf2 k).trans (hI k))

end CellLabels

end Nightfall.InfinitePiQ2CellAverage
