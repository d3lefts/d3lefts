import InfinitePiQ2UnconditionalTerminal
import MixedDifferenceDegree

/-!
# Aaronson–Ambainis influence bound on arbitrary product probability spaces

For an index type `ι` in ANY universe, arbitrary measurable coordinate spaces `X i` and
arbitrary probability laws `μ i`, let `ν = Measure.infinitePi μ` and let `G ∈ L²(ν)` satisfy

* `|G| ≤ B` ν-almost everywhere;
* **L² Efron–Stein degree ≤ d** (`ESDegreeLE μ d G`): for every list of `d + 1` distinct
  coordinates, the iterated genuine original residuals annihilate `G`;
* every genuine original influence `‖G − E[G | X_{≠ i}]‖²₂ ≤ M`.

Then (`infinitePi_aa_product`)

  `3 · Var(G)⁵ ≤ 12500 · (π² d²)⁶ · B⁶ · M²`,

i.e. `sup_i Inf_i(G) ≥ √(3/12500) · Var(G)^{5/2} / (π⁶ d⁶ B³)`: Turturean's exponents
`(5/2, 6)` with no dependence on alphabets, laws, atom masses, or the number of coordinates.

Proof: exact original-source cell tables over finitely many coordinate tests
(`InfinitePiQ2CellAverage`), finite-test L² approximation (`InfinitePiQ2UnconditionalTerminal`),
the table degree bound from the L² hypothesis via iterated residual peeling and anchored
Möbius expansion (`MixedDifferenceDegree`), and the kernel-checked finite heterogeneous
theorem `Heterogeneous.heterogeneous_influence` (a port of Turturean's Lean proof to finite
product spaces with zero-mass atoms).
-/

set_option maxHeartbeats 1600000

open MeasureTheory ProbabilityTheory Finset
open Nightfall.InfinitePiQ2InfluenceStability
open Nightfall.InfinitePiQ2Density
open Nightfall.InfinitePiQ2NativeHeterogeneousTerminal
open Nightfall.InfinitePiQ2EventualTerminal
open Nightfall.InfinitePiQ2CellAverage
open Nightfall.InfinitePiQ2UnconditionalTerminal
open Nightfall.ProductSpace.Heterogeneous
open Nightfall.ProductSpace.MixedDifference

universe u v

variable {ι : Type u} [DecidableEq ι] {X : ι → Type v}
variable [∀ i, MeasurableSpace (X i)]
variable (μ : (i : ι) → Measure (X i)) [∀ i, IsProbabilityMeasure (μ i)]

namespace Nightfall.InfinitePiAAProductTerminal

/-- Iterated genuine original-source residuals along a list of coordinates. -/
noncomputable def iterResidual :
    List ι → Lp ℝ (2 : ENNReal) (Measure.infinitePi μ) →
      Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)
  | [], G => G
  | i :: l, G => sourceCoordinateResidual μ i (iterResidual l G)

/-- **L² Efron–Stein degree at most `d`**: iterated residuals along any `d + 1` distinct
coordinates annihilate `G`. A statement about the `L²` class only. -/
def ESDegreeLE (d : ℕ) (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) : Prop :=
  ∀ l : List ι, l.Nodup → l.length = d + 1 → iterResidual μ l G = 0

end Nightfall.InfinitePiAAProductTerminal

namespace Nightfall.InfinitePiQ2CellAverage.CellLabels

open Nightfall.InfinitePiAAProductTerminal

variable {μ}
variable (L : CellLabels X)

/-- One genuine residual can be peeled at any positive step of a distinct-coordinate
mixed difference of a cell table. -/
theorem peel (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (l : List (Step L.Letter)) (hnd : (l.map Sigma.fst).Nodup)
    (s : Step L.Letter) (hs : s ∈ l)
    (hpos : 0 < L.prob μ s.1 s.2.1) (hpos' : 0 < L.prob μ s.1 s.2.2) (y : L.Word) :
    mdelta l (L.avg μ (⇑G)) y =
      mdelta l (L.avg μ (⇑(sourceCoordinateResidual μ (L.e s.1) G))) y := by
  have hsplit : L.avg μ (⇑G) = fun z =>
      L.avg μ (⇑(sourceOtherProjection μ (L.e s.1) G)) z +
        L.avg μ (⇑(sourceCoordinateResidual μ (L.e s.1) G)) z := by
    funext z
    rw [← L.avg_Lp_add μ]
    congr 2
    unfold sourceCoordinateResidual
    abel
  rw [hsplit, mdelta_add,
    mdelta_eq_zero_of_mem l hnd s hs _
      (fun z => L.avg_projection_invariant μ s.1 G z s.2.1 s.2.2 hpos hpos') y,
    zero_add]

theorem peel_list (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ))
    (l : List (Step L.Letter)) (hnd : (l.map Sigma.fst).Nodup)
    (hpos : ∀ s ∈ l, 0 < L.prob μ s.1 s.2.1 ∧ 0 < L.prob μ s.1 s.2.2)
    (t : List (Step L.Letter)) (ht : ∀ s ∈ t, s ∈ l) (y : L.Word) :
    mdelta l (L.avg μ (⇑G)) y =
      mdelta l (L.avg μ (⇑(iterResidual μ (t.map fun s => L.e s.1) G))) y := by
  induction t with
  | nil => rfl
  | cons s t ih =>
    rw [ih (fun r hr => ht r (List.mem_cons_of_mem _ hr))]
    have hsl := ht s List.mem_cons_self
    rw [peel L _ l hnd s hsl (hpos s hsl).1 (hpos s hsl).2 y]
    rfl

/-- Mixed differences of the cell table along `d + 1` distinct coordinates with positive
letters vanish when `G` has L² Efron–Stein degree at most `d`. -/
theorem mdelta_table_zero (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) (d : ℕ)
    (hG : ESDegreeLE μ d G)
    (l : List (Step L.Letter)) (hnd : (l.map Sigma.fst).Nodup) (hlen : l.length = d + 1)
    (hpos : ∀ s ∈ l, 0 < L.prob μ s.1 s.2.1 ∧ 0 < L.prob μ s.1 s.2.2) (y : L.Word) :
    mdelta l (L.avg μ (⇑G)) y = 0 := by
  rw [peel_list L G l hnd hpos l (fun s hs => hs) y]
  have hz : iterResidual μ (l.map fun s => L.e s.1) G = 0 := by
    refine hG _ ?_ (by simpa using hlen)
    have : (l.map fun s => L.e s.1) = (l.map Sigma.fst).map L.e := by
      simp [List.map_map, Function.comp_def]
    rw [this]
    exact hnd.map L.inj
  have h0 : L.avg μ (⇑(iterResidual μ (l.map fun s => L.e s.1) G)) = fun _ => 0 := by
    funext z
    rw [hz]
    exact L.avg_Lp_zero μ z
  rw [h0, mdelta_zero]

/-- A positive-mass letter at every coordinate. -/
theorem exists_pos_letter (k : Fin L.n) : ∃ a : L.Letter k, 0 < L.prob μ k a := by
  have h : ∑ _a : L.Letter k, (0 : ℝ) < ∑ a : L.Letter k, L.prob μ k a := by
    rw [L.prob_sum μ k]; simp
  obtain ⟨a, -, ha⟩ := Finset.exists_lt_of_sum_lt h
  exact ⟨a, ha⟩

/-- Retraction of zero-mass letters onto a fixed positive letter. -/
noncomputable def retract (k : Fin L.n) (a : L.Letter k) : L.Letter k :=
  if 0 < L.prob μ k a then a else Classical.choose (L.exists_pos_letter (μ := μ) k)

theorem retract_pos (k : Fin L.n) (a : L.Letter k) : 0 < L.prob μ k (L.retract (μ := μ) k a) := by
  unfold retract
  split_ifs with h
  · exact h
  · exact Classical.choose_spec (L.exists_pos_letter (μ := μ) k)

theorem retract_of_pos (k : Fin L.n) (a : L.Letter k) (h : 0 < L.prob μ k a) :
    L.retract (μ := μ) k a = a := by
  unfold retract; rw [if_pos h]

/-- The retracted table: equal to the cell table on every positive-mass word. -/
noncomputable def rtable (f : ((i : ι) → X i) → ℝ) (y : L.Word) : ℝ :=
  L.avg μ f (fun k => L.retract (μ := μ) k (y k))

theorem rtable_of_pos (f : ((i : ι) → X i) → ℝ) (y : L.Word)
    (hy : ∀ k, 0 < L.prob μ k (y k)) : L.rtable (μ := μ) f y = L.avg μ f y := by
  unfold rtable
  congr 1
  funext k
  exact L.retract_of_pos k (y k) (hy k)

theorem mass_mul_rtable (f : ((i : ι) → X i) → ℝ) (φ : ℝ → ℝ) (y : L.Word) :
    dMass (L.prob μ) y * φ (L.rtable (μ := μ) f y) = dMass (L.prob μ) y * φ (L.avg μ f y) := by
  by_cases hy : ∀ k, 0 < L.prob μ k (y k)
  · rw [L.rtable_of_pos f y hy]
  · push_neg at hy
    obtain ⟨k, hk⟩ := hy
    have hk0 : L.prob μ k (y k) = 0 := le_antisymm hk (L.prob_nonneg μ k (y k))
    have : dMass (L.prob μ) y = 0 := by
      unfold dMass
      exact Finset.prod_eq_zero (Finset.mem_univ k) hk0
    rw [this, zero_mul, zero_mul]

theorem dexp_rtable (f : ((i : ι) → X i) → ℝ) :
    dexp (L.prob μ) (L.rtable (μ := μ) f) = nativeMean L.Letter (L.prob μ) (L.avg μ f) := by
  unfold dexp nativeMean
  refine Finset.sum_congr rfl fun y _ => ?_
  exact L.mass_mul_rtable f id y

theorem dvar_rtable (f : ((i : ι) → X i) → ℝ) :
    dvar (L.prob μ) (L.rtable (μ := μ) f) =
      nativeVariance L.Letter (L.prob μ) (L.avg μ f) := by
  unfold dvar nativeVariance
  rw [dexp_rtable]
  refine Finset.sum_congr rfl fun y _ => ?_
  exact L.mass_mul_rtable f (fun t => (t - nativeMean L.Letter (L.prob μ) (L.avg μ f)) ^ 2) y

theorem dinfl_rtable (f : ((i : ι) → X i) → ℝ) (j : Fin L.n) :
    dinfl (L.prob μ) (L.rtable (μ := μ) f) j =
      nativeInfluence L.Letter (L.prob μ) (L.avg μ f) j := by
  rw [dinfl_eq_heatBath (L.prob μ) (L.prob_sum μ)]
  unfold nativeInfluence
  refine Finset.sum_congr rfl fun y _ => ?_
  by_cases hy : ∀ k, 0 < L.prob μ k (y k)
  · have hin : ∑ b : L.Letter j, L.prob μ j b * L.rtable (μ := μ) f (Function.update y j b) =
        ∑ b : L.Letter j, L.prob μ j b * L.avg μ f (Function.update y j b) := by
      refine Finset.sum_congr rfl fun b _ => ?_
      rcases (L.prob_nonneg μ j b).eq_or_lt with hb | hb
      · rw [← hb, zero_mul, zero_mul]
      · rw [L.rtable_of_pos f _ (fun k => by
          by_cases hk : k = j
          · subst hk; simpa using hb
          · simpa [Function.update_of_ne hk] using hy k)]
    rw [hin, L.rtable_of_pos f y hy]
    rfl
  · push_neg at hy
    obtain ⟨k, hk⟩ := hy
    have hk0 : L.prob μ k (y k) = 0 := le_antisymm hk (L.prob_nonneg μ k (y k))
    have h1 : dMass (L.prob μ) y = 0 := by
      unfold dMass
      exact Finset.prod_eq_zero (Finset.mem_univ k) hk0
    have h2 : nativeMass L.Letter (L.prob μ) y = 0 := h1
    rw [h1, h2, zero_mul, zero_mul]

theorem rtable_degree (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) (d : ℕ)
    (hG : ESDegreeLE μ d G) : DepDegreeLE (L.rtable (μ := μ) (⇑G)) d := by
  obtain ⟨s0, -⟩ : ∃ s0 : L.Word, True := ⟨fun k => ⟨0, L.pos k⟩, trivial⟩
  refine depDegree_of_mdelta _ d s0 fun l hnd hlen y => ?_
  unfold rtable
  rw [mdelta_comp (fun k a => L.retract (μ := μ) k a) l (L.avg μ (⇑G)) y]
  refine L.mdelta_table_zero G d hG _ ?_ ?_ ?_ _
  · simpa [List.map_map, Function.comp_def] using hnd
  · simpa using hlen
  · intro s hs
    obtain ⟨t, -, rfl⟩ := List.mem_map.mp hs
    exact ⟨L.retract_pos t.1 t.2.1, L.retract_pos t.1 t.2.2⟩

theorem dvar_smul (c : ℝ) (F : L.Word → ℝ) :
    dvar (L.prob μ) (fun y => c * F y) = c ^ 2 * dvar (L.prob μ) F := by
  have hE : ∑ x, dMass (L.prob μ) x * (c * F x) = c * ∑ x, dMass (L.prob μ) x * F x := by
    rw [Finset.mul_sum]; exact Finset.sum_congr rfl fun x _ => by ring
  simp only [dvar, dexp]
  rw [hE]
  conv_rhs => rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun y _ => by ring

theorem dinfl_smul (c : ℝ) (F : L.Word → ℝ) (j : Fin L.n) :
    dinfl (L.prob μ) (fun y => c * F y) j = c ^ 2 * dinfl (L.prob μ) F j := by
  simp only [dinfl]
  conv_rhs => rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun y _ => ?_
  conv_rhs => rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun b _ => by ring

theorem depDegree_smul (c : ℝ) {F : L.Word → ℝ} {d : ℕ} (h : DepDegreeLE F d) :
    DepDegreeLE (fun y => c * F y) d := by
  obtain ⟨a, ha0, hrep⟩ := h
  refine ⟨fun T τ => c * a T τ, fun T hT τ => by
    show c * a T τ = 0
    rw [ha0 T hT τ, mul_zero], fun y => ?_⟩
  show c * F y = ∑ T, ∑ τ, c * a T τ * dIndMono T τ y
  rw [hrep y, Finset.mul_sum]
  refine Finset.sum_congr rfl fun T _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun τ _ => ?_
  ring

/-- **Finite-table Aaronson–Ambainis bound** with the genuine original influences. -/
theorem table_aa {f : ((i : ι) → X i) → ℝ} (hfm : Measurable f) {B : ℝ} (hB : 0 ≤ B)
    (hb : ∀ x, |f x| ≤ B) (hf2 : MemLp f 2 (Measure.infinitePi μ))
    (d : ℕ) (hdeg : DepDegreeLE (L.rtable (μ := μ) f) d)
    {M : ℝ} (hM : 0 ≤ M) (hI : ∀ i : ι, sourceCoordinateInfluence μ i (hf2.toLp f) ≤ M) :
    3 * (nativeVariance L.Letter (L.prob μ) (L.avg μ f)) ^ 5 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * M ^ 2 := by
  set V := nativeVariance L.Letter (L.prob μ) (L.avg μ f)
  have hV0 : 0 ≤ V := nativeVariance_nonneg L.Letter (L.prob μ) (L.prob_nonneg μ) _
  have hK : 0 ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * M ^ 2 := by positivity
  rcases hV0.eq_or_lt with hVz | hVp
  · rw [← hVz]; simpa using hK
  have hBp : 0 < B := by
    rcases hB.eq_or_lt with hB0 | hB0
    · exfalso
      have hz : ∀ y, L.avg μ f y = 0 := fun y => by
        have := L.abs_avg_le μ hB hb y
        rw [← hB0] at this
        exact abs_nonpos_iff.mp this
      have : V = 0 := by
        simp only [V, nativeVariance, nativeMean, hz, mul_zero, Finset.sum_const_zero,
          sub_zero, ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow]
      linarith
    · exact hB0
  set F : L.Word → ℝ := fun y => B⁻¹ * L.rtable (μ := μ) f y
  have hF1 : ∀ y : L.Word, (∀ k, 0 < L.prob μ k (y k)) → |F y| ≤ 1 := by
    intro y _
    simp only [F, abs_mul, abs_inv, abs_of_pos hBp]
    rw [inv_mul_le_iff₀ hBp, mul_one]
    exact L.abs_avg_le μ hB hb _
  have hFvar : dvar (L.prob μ) F = (B⁻¹) ^ 2 * V := by
    rw [L.dvar_smul, L.dvar_rtable]
  have hFinf : ∀ j, dinfl (L.prob μ) F j =
      (B⁻¹) ^ 2 * nativeInfluence L.Letter (L.prob μ) (L.avg μ f) j := by
    intro j; rw [L.dinfl_smul, L.dinfl_rtable]
  have hFpos : 0 < dvar (L.prob μ) F := by
    rw [hFvar]; positivity
  obtain ⟨j, hj⟩ := heterogeneous_influence (L.prob μ) (L.prob_nonneg μ) (L.prob_sum μ) d F
    hF1 (L.depDegree_smul B⁻¹ hdeg) hFpos
  rw [hFvar, hFinf j] at hj
  set I := nativeInfluence L.Letter (L.prob μ) (L.avg μ f) j
  have hI0 : 0 ≤ I := by
    have := nativeVariance_nonneg L.Letter (L.prob μ) (L.prob_nonneg μ) (L.avg μ f)
    unfold I nativeInfluence
    refine Finset.sum_nonneg fun y _ => mul_nonneg ?_ (sq_nonneg _)
    exact Finset.prod_nonneg fun k _ => L.prob_nonneg μ k (y k)
  have hIM : I ≤ M := (L.native_influence_le μ hfm hb hf2 j).trans (hI (L.e j))
  have hI2 : I ^ 2 ≤ M ^ 2 := pow_le_pow_left₀ hI0 hIM 2
  -- clear the scaling: multiply by B^10
  have hB10 : 0 < B ^ 10 := by positivity
  have key : 3 * V ^ 5 ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * I ^ 2 := by
    have e1 : 3 * ((B⁻¹) ^ 2 * V) ^ 5 = (3 * V ^ 5) / B ^ 10 := by
      field_simp
    have e2 : 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * ((B⁻¹) ^ 2 * I) ^ 2 =
        (12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * I ^ 2) / B ^ 10 := by
      field_simp
    rw [e1, e2] at hj
    exact (div_le_div_iff_of_pos_right hB10).mp hj
  calc 3 * V ^ 5 ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * I ^ 2 := key
    _ ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * M ^ 2 := by
      have : 0 ≤ 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 := by positivity
      exact mul_le_mul_of_nonneg_left hI2 this

end Nightfall.InfinitePiQ2CellAverage.CellLabels

namespace Nightfall.InfinitePiAAProductTerminal

/-- **Aaronson–Ambainis on arbitrary product probability spaces (a.e. L² form).** -/
theorem infinitePi_aa_product
    (G : Lp ℝ (2 : ENNReal) (Measure.infinitePi μ)) (d : ℕ)
    (B : ℝ) (hB : 0 ≤ B) (hb : ∀ᵐ x ∂ Measure.infinitePi μ, |G x| ≤ B)
    (hdeg : ESDegreeLE μ d G)
    (M : ℝ) (hM : 0 ≤ M)
    (hI : ∀ i : ι, sourceCoordinateInfluence μ i G ≤ M) :
    3 * (sourceL2Variance μ G) ^ 5 ≤
      12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * M ^ 2 := by
  -- clamp a measurable representative into [-B, B]
  obtain ⟨g, hgs, hGg⟩ := Lp.aestronglyMeasurable G
  have hgm : Measurable g := hgs.measurable
  let f : ((i : ι) → X i) → ℝ := fun x => max (-B) (min B (g x))
  have hfm : Measurable f := measurable_const.max (measurable_const.min hgm)
  have hfb : ∀ x, |f x| ≤ B := by
    intro x
    rw [abs_le]
    exact ⟨le_max_left _ _, max_le (by linarith) (min_le_left _ _)⟩
  have hfG : f =ᵐ[Measure.infinitePi μ] (G : ((i : ι) → X i) → ℝ) := by
    filter_upwards [hGg, hb] with x hx hxb
    have h2 := abs_le.mp hxb
    simp only [f]
    rw [← hx, min_eq_right h2.2, max_eq_right h2.1]
  have hf2 : MemLp f 2 (Measure.infinitePi μ) := memLp_two_of_bounded μ hfm hfb
  have hGf : hf2.toLp f = G := Lp.ext (hf2.coeFn_toLp.trans hfG)
  have hI' : ∀ i : ι, sourceCoordinateInfluence μ i (hf2.toLp f) ≤ M := by
    rw [hGf]; exact hI
  set K := 12500 * (Real.pi ^ 2 * (d : ℝ) ^ 2) ^ 6 * B ^ 6 * M ^ 2
  have hK : 0 ≤ K := by positivity
  set R := (K / 3) ^ ((5 : ℕ)⁻¹ : ℝ) with hRdef
  have hR0 : 0 ≤ R := Real.rpow_nonneg (by positivity) _
  have hR5 : R ^ 5 = K / 3 := Real.rpow_inv_natCast_pow (by positivity) (by norm_num)
  set V := sourceL2Variance μ (hf2.toLp f)
  have hV0 : 0 ≤ V := source_variance_nonneg μ (hf2.toLp f)
  have hVR : V ≤ R := by
    refine le_of_forall_pos_le_add fun ε hε => ?_
    obtain ⟨L, hL⟩ := exists_labels_variance_gap μ hfm hfb hf2 ε hε
    have havg : L.avg μ f = L.avg μ (⇑G) := funext fun y => L.avg_congr_ae μ hfG y
    have hdegT : DepDegreeLE (L.rtable (μ := μ) f) d := by
      have : L.rtable (μ := μ) f = L.rtable (μ := μ) (⇑G) := by
        funext y; unfold CellLabels.rtable; rw [havg]
      rw [this]
      exact L.rtable_degree G d hdeg
    have hq := L.table_aa hfm hB hfb hf2 d hdegT hM hI'
    set Vt := nativeVariance L.Letter (L.prob μ) (L.avg μ f)
    have hVt0 : 0 ≤ Vt := nativeVariance_nonneg L.Letter (L.prob μ) (L.prob_nonneg μ) _
    have hVt : Vt ≤ R := by
      have h5 : Vt ^ 5 ≤ R ^ 5 := by rw [hR5]; linarith
      exact (pow_le_pow_iff_left₀ hVt0 hR0 (by norm_num)).mp h5
    linarith
  have h5 : V ^ 5 ≤ R ^ 5 := pow_le_pow_left₀ hV0 hVR 5
  rw [hR5] at h5
  rw [← hGf]
  linarith

end Nightfall.InfinitePiAAProductTerminal
