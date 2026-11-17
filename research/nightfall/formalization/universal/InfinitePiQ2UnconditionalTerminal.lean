import InfinitePiQ2CellAverage
import InfinitePiQ2FiniteCellDensity

/-!
# Unconditional infinite-product Q2 under the original product law

For an ARBITRARY index type `ι : Type` (uncountable allowed), arbitrary
measurable coordinate spaces `X i` and arbitrary probability laws `μ i`,
let `f` be a bounded measurable function on `∀ i, X i` whose mixed third
coordinate differences vanish pointwise (`PointwiseDegreeTwo f`). If every
genuine original-source coordinate influence of `f` under
`Measure.infinitePi μ` is at most `M`, then

  Var(f)² ≤ ((2(1+√2))√3 + 11901/6250)² · B² · M      (≈ 105.416 B² M).

No finite-information inequality, influence oracle, density statement,
countability, atom floor or finite-alphabet condition is a hypothesis.
The proof composes, entirely inside one checked import graph:

1. the L² density of finite Boolean cells of original coordinate rectangles
   (`InfinitePiQ2FiniteCellDensity`);
2. exact original-source cell averages over finitely many coordinate tests
   (`InfinitePiQ2CellAverage`): boundedness, supported degree two,
   influence contraction and variance comparison;
3. the original-source native heterogeneous finite theorem
   `native_heterogeneous_q2_105416_supported_unconditional`.

The mathematical statement still requires independent human review
against the community's canonical Q2 formulation; priority and novelty are
separate questions.
-/

namespace Nightfall.InfinitePiQ2UnconditionalTerminal

set_option maxHeartbeats 1600000

open MeasureTheory ProbabilityTheory Finset
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2DegreeRetraction
open Nightfall.InfinitePiQ2NativeHeterogeneousTerminal
open Nightfall.InfinitePiQ2FiniteCellDensity
open Nightfall.InfinitePiQ2EventualTerminal
open Nightfall.InfinitePiQ2CellAverage

universe v

variable {ι : Type} [DecidableEq ι] {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]

/-! ## Finite families of coordinate tests -/

/-- Two points pass the same finitely many coordinate tests. -/
def AgreeOn (F : Finset ι) (S : ∀ i, Finset (Set (X i))) (x x' : (i : ι) → X i) : Prop :=
  ∀ i ∈ F, ∀ t ∈ S i, (x i ∈ t ↔ x' i ∈ t)

def Tests (S : ∀ i, Finset (Set (X i))) : Prop := ∀ i, ∀ t ∈ S i, MeasurableSet t

theorem AgreeOn.mono {F F' : Finset ι} {S S' : ∀ i, Finset (Set (X i))}
    (hF : F ⊆ F') (hS : ∀ i, S i ⊆ S' i) {x x' : (i : ι) → X i}
    (h : AgreeOn F' S' x x') : AgreeOn F S x x' :=
  fun i hi t ht => h i (hF hi) t (hS i ht)

open Classical in
/-- Every finite-cell event is decided by finitely many coordinate tests. -/
theorem cellAlgebra_determined (s : Set ((i : ι) → X i))
    (hs : s ∈ sourceFiniteCellAlgebra (X := X)) :
    ∃ (F : Finset ι) (S : ∀ i, Finset (Set (X i))), Tests S ∧
      ∀ x x', AgreeOn F S x x' → (x ∈ s ↔ x' ∈ s) := by
  unfold sourceFiniteCellAlgebra at hs
  induction hs using MeasureTheory.generateSetAlgebra_induction with
  | base u hu =>
    obtain ⟨F, t, ht, rfl⟩ := hu
    refine ⟨F, fun i => {t i}, fun i r hr => ?_, fun x x' h => ?_⟩
    · rw [Finset.mem_singleton] at hr
      subst hr
      exact ht i (Set.mem_univ i)
    · simp only [Set.mem_pi, Finset.mem_coe]
      exact forall₂_congr fun i hi => h i hi (t i) (Finset.mem_singleton_self _)
  | empty =>
    exact ⟨∅, fun _ => ∅, fun i r hr => absurd hr (Finset.notMem_empty _),
      fun x x' _ => Iff.rfl⟩
  | compl u hu ih =>
    obtain ⟨F, S, hS, hdet⟩ := ih
    exact ⟨F, S, hS, fun x x' h => not_congr (hdet x x' h)⟩
  | union u w hu hw ihu ihw =>
    obtain ⟨F1, S1, hS1, hd1⟩ := ihu
    obtain ⟨F2, S2, hS2, hd2⟩ := ihw
    refine ⟨F1 ∪ F2, fun i => S1 i ∪ S2 i, fun i r hr => ?_, fun x x' h => ?_⟩
    · rcases Finset.mem_union.mp hr with h1 | h2
      · exact hS1 i r h1
      · exact hS2 i r h2
    · exact or_congr
        (hd1 x x' (h.mono Finset.subset_union_left fun i => Finset.subset_union_left))
        (hd2 x x' (h.mono Finset.subset_union_right fun i => Finset.subset_union_right))

variable (μ : (i : ι) → Measure (X i)) [∀ i, IsProbabilityMeasure (μ i)]

open Classical in
/-- Every finite linear combination of finite-cell indicators agrees a.e.
with a function decided by finitely many coordinate tests. -/
theorem span_determined (v : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (hv : v ∈ Submodule.span ℝ (sourceCellGenerators μ)) :
    ∃ (F : Finset ι) (S : ∀ i, Finset (Set (X i))) (u : ((i : ι) → X i) → ℝ),
      Tests S ∧ (∀ x x', AgreeOn F S x x' → u x = u x') ∧
        (v : ((i : ι) → X i) → ℝ) =ᵐ[Measure.infinitePi μ] u := by
  induction hv using Submodule.span_induction with
  | mem w hw =>
    obtain ⟨s, hs, c, rfl⟩ := hw
    obtain ⟨F, S, hS, hdet⟩ := cellAlgebra_determined s hs
    refine ⟨F, S, s.indicator fun _ => c, hS, fun x x' h => ?_, ?_⟩
    · by_cases hx : x ∈ s
      · rw [Set.indicator_of_mem hx, Set.indicator_of_mem ((hdet x x' h).mp hx)]
      · rw [Set.indicator_of_notMem hx,
          Set.indicator_of_notMem fun hx' => hx ((hdet x x' h).mpr hx')]
    · exact indicatorConstLp_coeFn
  | zero =>
    exact ⟨∅, fun _ => ∅, 0, fun i r hr => absurd hr (Finset.notMem_empty _),
      fun _ _ _ => rfl, Lp.coeFn_zero ℝ (2 : ENNReal) (Measure.infinitePi μ)⟩
  | add w1 w2 _ _ ih1 ih2 =>
    obtain ⟨F1, S1, u1, hS1, hd1, ha1⟩ := ih1
    obtain ⟨F2, S2, u2, hS2, hd2, ha2⟩ := ih2
    refine ⟨F1 ∪ F2, fun i => S1 i ∪ S2 i, u1 + u2, fun i r hr => ?_,
      fun x x' h => ?_, ?_⟩
    · rcases Finset.mem_union.mp hr with h1 | h2
      · exact hS1 i r h1
      · exact hS2 i r h2
    · simp only [Pi.add_apply]
      rw [hd1 x x' (h.mono Finset.subset_union_left fun i => Finset.subset_union_left),
        hd2 x x' (h.mono Finset.subset_union_right fun i => Finset.subset_union_right)]
    · filter_upwards [Lp.coeFn_add w1 w2, ha1, ha2] with x h0 h1 h2
      rw [h0, Pi.add_apply, h1, h2, Pi.add_apply]
  | smul a w _ ih =>
    obtain ⟨F, S, u, hS, hd, ha⟩ := ih
    refine ⟨F, S, a • u, hS, fun x x' h => ?_, ?_⟩
    · simp only [Pi.smul_apply]
      rw [hd x x' h]
    · filter_upwards [Lp.coeFn_smul a w, ha] with x h0 h1
      rw [h0, Pi.smul_apply, h1, Pi.smul_apply]

open Classical in
/-- Finite measurable labels recording the outcomes of finitely many tests. -/
noncomputable def testLabels (F : Finset ι) (S : ∀ i, Finset (Set (X i)))
    (hS : Tests S) : CellLabels X where
  F := F
  N := fun k => Fintype.card (S k → Bool)
  pos := fun _ => Fintype.card_pos
  φ := fun k z => Fintype.equivFin (S k → Bool) (fun t => decide (z ∈ (t : Set (X k))))
  meas := by
    intro k a
    have e : (fun z : X k => Fintype.equivFin (S k → Bool)
          (fun t => decide (z ∈ (t : Set (X k))))) ⁻¹' {a} =
        ⋂ t : S k, {z : X k | decide (z ∈ (t : Set (X k))) =
          (Fintype.equivFin (S k → Bool)).symm a t} := by
      ext z
      simp only [Set.mem_preimage, Set.mem_singleton_iff, Set.mem_iInter,
        Set.mem_setOf_eq]
      rw [Equiv.apply_eq_iff_eq_symm_apply, funext_iff]
    rw [e]
    refine MeasurableSet.iInter fun t => ?_
    have ht : MeasurableSet (t : Set (X k)) := hS k t t.2
    cases hval : (Fintype.equivFin (S k → Bool)).symm a t
    · have : {z : X k | decide (z ∈ (t : Set (X k))) = false} = (t : Set (X k))ᶜ := by
        ext z; simp
      rw [this]; exact ht.compl
    · have : {z : X k | decide (z ∈ (t : Set (X k))) = true} = (t : Set (X k)) := by
        ext z; simp
      rw [this]; exact ht

open Classical in
theorem testLabels_agree (F : Finset ι) (S : ∀ i, Finset (Set (X i))) (hS : Tests S)
    (y : (testLabels F S hS).Word) (x x' : (i : ι) → X i)
    (hx : x ∈ (testLabels F S hS).cell y) (hx' : x' ∈ (testLabels F S hS).cell y) :
    AgreeOn F S x x' := by
  intro i hi t ht
  rw [CellLabels.mem_cell] at hx hx'
  have h := (hx ⟨i, hi⟩).trans (hx' ⟨i, hi⟩).symm
  have h' := congrFun ((Fintype.equivFin _).injective h) ⟨t, ht⟩
  simpa using h'

/-! ## Variance identities -/

theorem sourceL2Variance_toLp {f : ((i : ι) → X i) → ℝ}
    (hf2 : MemLp f 2 (Measure.infinitePi μ)) :
    sourceL2Variance μ (hf2.toLp f) =
      (∫ x, f x ^ 2 ∂ Measure.infinitePi μ) -
        (∫ x, f x ∂ Measure.infinitePi μ) ^ 2 := by
  rw [sourceL2Variance_eq_actual_variance, variance_congr hf2.coeFn_toLp,
    variance_eq_sub hf2]
  rfl

theorem nativeVariance_nonneg {κ : Type} [Fintype κ] [DecidableEq κ]
    (A : κ → Type) [∀ k, Fintype (A k)] (p : (k : κ) → A k → ℝ)
    (hp : ∀ k a, 0 ≤ p k a) (g : ((k : κ) → A k) → ℝ) :
    0 ≤ nativeVariance A p g := by
  unfold nativeVariance
  refine Finset.sum_nonneg fun x _ => mul_nonneg ?_ (sq_nonneg _)
  unfold nativeMass
  exact Finset.prod_nonneg fun k _ => hp k (x k)

/-- Finite-table Q2 for every label system, including the degenerate empty one. -/
theorem cellAverage_q2_all (L : CellLabels X) {f : ((i : ι) → X i) → ℝ}
    (hfm : Measurable f) (hdeg : PointwiseDegreeTwo f) {B : ℝ} (hB : 0 ≤ B)
    (hb : ∀ x, |f x| ≤ B) (hf2 : MemLp f 2 (Measure.infinitePi μ)) {M : ℝ} (hM : 0 ≤ M)
    (hI : ∀ i : ι, sourceCoordinateInfluence μ i (hf2.toLp f) ≤ M)
    (x0 : (i : ι) → X i) :
    (nativeVariance L.Letter (L.prob μ) (L.avg μ f)) ^ 2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2 * B ^ 2 * M := by
  by_cases hF : Nonempty L.F
  · exact L.cellAverage_q2 μ hfm hdeg hB hb hf2 hM hI x0
  · have hE : IsEmpty L.F := not_nonempty_iff.mp hF
    have hzero : nativeVariance L.Letter (L.prob μ) (L.avg μ f) = 0 := by
      unfold nativeVariance nativeMean nativeMass
      simp [Finset.univ_eq_empty]
    rw [hzero, zero_pow two_ne_zero]
    positivity

/-! ## Approximation by finitely many coordinate tests -/

theorem exists_labels_variance_gap {f : ((i : ι) → X i) → ℝ} (hfm : Measurable f)
    {B : ℝ} (hb : ∀ x, |f x| ≤ B) (hf2 : MemLp f 2 (Measure.infinitePi μ))
    (ε : ℝ) (hε : 0 < ε) :
    ∃ L : CellLabels X,
      sourceL2Variance μ (hf2.toLp f) -
        nativeVariance L.Letter (L.prob μ) (L.avg μ f) ≤ ε := by
  obtain ⟨v, hv, hclose⟩ :=
    sourceFiniteCellAlgebra_L2_approx μ (hf2.toLp f) (Real.sqrt ε) (Real.sqrt_pos.mpr hε)
  obtain ⟨F, S, u, hS, hdet, hvu⟩ := span_determined μ v hv
  let L := testLabels F S hS
  refine ⟨L, ?_⟩
  have hf : Integrable f (Measure.infinitePi μ) :=
    integrable_of_abs_le (Measure.infinitePi μ) hfm B hb
  have hf2' : Integrable (fun x => f x ^ 2) (Measure.infinitePi μ) := hf2.integrable_sq
  have hdiff : ((hf2.toLp f - v : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) :
      ((i : ι) → X i) → ℝ) =ᵐ[Measure.infinitePi μ] fun x => f x - u x := by
    filter_upwards [Lp.coeFn_sub (hf2.toLp f) v, hf2.coeFn_toLp, hvu] with x h1 h2 h3
    rw [h1, Pi.sub_apply, h2, h3]
  have hfu : Integrable (fun x => (f x - u x) ^ 2) (Measure.infinitePi μ) :=
    (Lp.memLp (hf2.toLp f - v)).integrable_sq.congr
      (hdiff.mono fun x hx => by simp only [hx])
  have hnorm : ‖hf2.toLp f - v‖ ^ 2 = ∫ x, (f x - u x) ^ 2 ∂ Measure.infinitePi μ := by
    rw [← real_inner_self_eq_norm_sq, L2.inner_def]
    refine integral_congr_ae (hdiff.mono fun x hx => ?_)
    dsimp only
    rw [hx]
    simp only [real_inner_self_eq_norm_sq, Real.norm_eq_abs, sq_abs]
  have hgap := L.variance_gap_le μ hf hf2' hfu
    (fun y x hx x' hx' => hdet x x' (testLabels_agree F S hS y x x' hx hx'))
  have hsq : ‖hf2.toLp f - v‖ ^ 2 ≤ ε := by
    have h0 : 0 ≤ ‖hf2.toLp f - v‖ := norm_nonneg _
    have h1 : ‖hf2.toLp f - v‖ ^ 2 ≤ Real.sqrt ε ^ 2 := by
      exact pow_le_pow_left₀ h0 hclose.le 2
    rwa [Real.sq_sqrt hε.le] at h1
  rw [sourceL2Variance_toLp μ hf2]
  linarith

/-! ## The unconditional infinite-product terminal -/

/-- **Unconditional infinite-product Q2 (original source law).**
Arbitrary index type and coordinate laws; bounded measurable pointwise
degree-two `f`; every genuine original-source influence at most `M`. -/
theorem infinitePi_q2_105416_unconditional
    (f : ((i : ι) → X i) → ℝ) (hfm : Measurable f) (hdeg : PointwiseDegreeTwo f)
    (B : ℝ) (hB : 0 ≤ B) (hb : ∀ x, |f x| ≤ B)
    (hf2 : MemLp f 2 (Measure.infinitePi μ))
    (M : ℝ) (hM : 0 ≤ M)
    (hI : ∀ i : ι, sourceCoordinateInfluence μ i (hf2.toLp f) ≤ M) :
    (sourceL2Variance μ (hf2.toLp f)) ^ 2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2 * B ^ 2 * M := by
  set K := ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2 * B ^ 2 * M with hK
  have hK0 : 0 ≤ K := by positivity
  have hne : ∀ i, Nonempty (X i) := fun i =>
    ⟨(nonempty_of_measure_ne_zero (μ := μ i) (s := Set.univ) (by simp)).some⟩
  let x0 : (i : ι) → X i := fun i => Classical.choice (hne i)
  set V := sourceL2Variance μ (hf2.toLp f)
  have hV0 : 0 ≤ V := source_variance_nonneg μ (hf2.toLp f)
  have hVr : V ≤ Real.sqrt K := by
    refine le_of_forall_pos_le_add fun ε hε => ?_
    obtain ⟨L, hL⟩ := exists_labels_variance_gap μ hfm hb hf2 ε hε
    have hq := cellAverage_q2_all μ L hfm hdeg hB hb hf2 hM hI x0
    have hn0 := nativeVariance_nonneg L.Letter (L.prob μ) (L.prob_nonneg μ) (L.avg μ f)
    have hn : nativeVariance L.Letter (L.prob μ) (L.avg μ f) ≤ Real.sqrt K := by
      rw [← Real.sqrt_sq hn0]
      exact Real.sqrt_le_sqrt hq
    linarith
  calc V ^ 2 ≤ (Real.sqrt K) ^ 2 := pow_le_pow_left₀ hV0 hVr 2
    _ = K := Real.sq_sqrt hK0

/-- Bounded measurable sources are automatically square integrable. -/
theorem memLp_two_of_bounded {f : ((i : ι) → X i) → ℝ} (hfm : Measurable f)
    {B : ℝ} (hb : ∀ x, |f x| ≤ B) : MemLp f 2 (Measure.infinitePi μ) :=
  MemLp.of_bound hfm.aestronglyMeasurable B
    (Filter.Eventually.of_forall fun x => by simpa only [Real.norm_eq_abs] using hb x)

/-- The same terminal stated with Mathlib's `ProbabilityTheory.variance`
of the function itself, with square integrability derived, not assumed. -/
theorem infinitePi_q2_105416_unconditional_variance
    (f : ((i : ι) → X i) → ℝ) (hfm : Measurable f) (hdeg : PointwiseDegreeTwo f)
    (B : ℝ) (hB : 0 ≤ B) (hb : ∀ x, |f x| ≤ B)
    (M : ℝ) (hM : 0 ≤ M)
    (hI : ∀ i : ι, sourceCoordinateInfluence μ i
      ((memLp_two_of_bounded μ hfm hb).toLp f) ≤ M) :
    (variance f (Measure.infinitePi μ)) ^ 2 ≤
      ((2 * (1 + Real.sqrt 2)) * Real.sqrt 3 + 11901 / 6250) ^ 2 * B ^ 2 * M := by
  have h := infinitePi_q2_105416_unconditional μ f hfm hdeg B hB hb
    (memLp_two_of_bounded μ hfm hb) M hM hI
  rwa [sourceL2Variance_eq_actual_variance,
    variance_congr (memLp_two_of_bounded μ hfm hb).coeFn_toLp] at h

end Nightfall.InfinitePiQ2UnconditionalTerminal
