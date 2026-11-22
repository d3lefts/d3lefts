import WrightV8MixedFunctional

/-!
# Finite-product mixed median weight removal, with the actual law and rows.

Proves the cross-median (3/2,3/2) moment estimate by combining the
real integrated-all-pairs inequality, mixed cubic AM--GM, and
Turturean's Cauchy--Schwarz weight-removal lemma. No FHKL theorem is
assumed. The final one-sided/mixed median Hölder synthesis remains
a separate proof obligation, and no full v8 constant is claimed.
-/

namespace Nightfall.Wright.MixedWeightRemoval

open Finset
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Transfer
open Nightfall.Wright.MixedFunctional

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

noncomputable def upperMoment (f : (ι → α) → ℝ) (r : ℝ) (x : ι → α) : ℝ :=
  max (f x - r) 0 * Real.sqrt (max (f x - r) 0)

noncomputable def lowerMoment (f : (ι → α) → ℝ) (r : ℝ) (y : ι → α) : ℝ :=
  max (r - f y) 0 * Real.sqrt (max (r - f y) 0)

theorem upperMoment_nonneg (f : (ι → α) → ℝ) (r : ℝ) (x : ι → α) :
    0 ≤ upperMoment f r x :=
  mul_nonneg (le_max_right _ _) (Real.sqrt_nonneg _)

theorem lowerMoment_nonneg (f : (ι → α) → ℝ) (r : ℝ) (y : ι → α) :
    0 ≤ lowerMoment f r y :=
  mul_nonneg (le_max_right _ _) (Real.sqrt_nonneg _)

theorem upperMoment_pos (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (r : ℝ) (x : ι → α) (hx : x ∈ upSet p f r) :
    0 < upperMoment f r x := by
  have h : r < f x := (Finset.mem_filter.mp hx).2.1
  unfold upperMoment
  rw [max_eq_left (show 0 ≤ f x - r by linarith)]
  exact mul_pos (by linarith) (Real.sqrt_pos.mpr (by linarith))

theorem lowerMoment_pos (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (r : ℝ) (y : ι → α) (hy : y ∈ downSet p f r) :
    0 < lowerMoment f r y := by
  have h : f y < r := (Finset.mem_filter.mp hy).2.1
  unfold lowerMoment
  rw [max_eq_left (show 0 ≤ r - f y by linarith)]
  exact mul_pos (by linarith) (Real.sqrt_pos.mpr (by linarith))

theorem crossingProduct_eq_moments (p : ι → α → ℝ)
    (f : (ι → α) → ℝ) (r : ℝ) (x y : ι → α)
    (hx : x ∈ upSet p f r) (hy : y ∈ downSet p f r) :
    crossingProduct f r x y = upperMoment f r x * lowerMoment f r y := by
  have h1 : 0 ≤ f x - r := by
    have h := (Finset.mem_filter.mp hx).2.1
    linarith
  have h2 : 0 ≤ r - f y := by
    have h := (Finset.mem_filter.mp hy).2.1
    linarith
  simp only [crossingProduct, upperMoment, lowerMoment,
    max_eq_left h1, max_eq_left h2]

/-- Exact joint-row denominator scaling, with no measure dependence. -/
theorem scaled_pair_cost
    (a : (ι → α) → ι → ℝ) (w : ι → ℝ)
    (f : (ι → α) → ℝ) (r : ℝ) (x y : ι → α) :
    (∑ j ∈ disagree x y,
      w j * (a x j / upperMoment f r x) *
        (a y j / lowerMoment f r y)) =
      pairCost w a x y / (upperMoment f r x * lowerMoment f r y) := by
  unfold pairCost
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- The genuine mixed-crossing estimate that v8 needs for the stronger
two-sided median. M bounds actual coordinate-resampling increments. -/
theorem mixed_third_moment_product
    (p : ι → α → ℝ) (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, ∑ b, p i b = 1)
    (f : (ι → α) → ℝ)
    (a : (ι → α) → ι → ℝ) (hr : RealRow f a)
    (K : ℝ) (hK : ∀ x, ∑ j, a x j ≤ K)
    (M : ℝ) (hM0 : 0 ≤ M) (hM : ∀ j, pincr p f j ≤ M) (r : ℝ) :
    8 * (∑ x ∈ upSet p f r, prodMass p x * upperMoment f r x) *
      (∑ y ∈ downSet p f r, prodMass p y * lowerMoment f r y) ≤
        3 * K ^ 2 * M := by
  let A := upSet p f r
  let B := downSet p f r
  have hR : 0 ≤ 3 * K ^ 2 * M :=
    mul_nonneg (mul_nonneg (by norm_num) (sq_nonneg K)) hM0
  by_cases hAe : A.Nonempty
  swap
  · have hAe' : A = ∅ := Finset.not_nonempty_iff_eq_empty.mp hAe
    simpa [hAe'] using hR
  by_cases hBe : B.Nonempty
  swap
  · have hBe' : B = ∅ := Finset.not_nonempty_iff_eq_empty.mp hBe
    simpa [hBe'] using hR
  obtain ⟨x0, hx0⟩ := hAe
  obtain ⟨y0, hy0⟩ := hBe
  have hAx : ∀ x ∈ A, r < f x :=
    fun x hx => (Finset.mem_filter.mp hx).2.1
  have hBy : ∀ y ∈ B, f y < r :=
    fun y hy => (Finset.mem_filter.mp hy).2.1
  have hAm : ∀ x ∈ A, 0 < prodMass p x :=
    fun x hx => (Finset.mem_filter.mp hx).2.2
  have hBm : ∀ y ∈ B, 0 < prodMass p y :=
    fun y hy => (Finset.mem_filter.mp hy).2.2
  have hU : ∀ x ∈ A, 0 < upperMoment f r x :=
    fun x hx => upperMoment_pos p f r x hx
  have hV : ∀ y ∈ B, 0 < lowerMoment f r y :=
    fun y hy => lowerMoment_pos p f r y hy
  have rowpos : ∀ x y : ι → α, f x ≠ f y → 0 < ∑ j, a x j := by
    intro x y hxy
    have h1 := hr.2 x y
    have h2 : ∑ j ∈ disagree x y, a x j ≤ ∑ j, a x j :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun j _ _ => hr.1 x j)
    have h3 : 0 < |f x - f y| := abs_pos.mpr (sub_ne_zero.mpr hxy)
    linarith
  have hKpos : 0 < K :=
    lt_of_lt_of_le (rowpos x0 y0
      (ne_of_gt (show f y0 < f x0 by linarith [hAx x0 hx0, hBy y0 hy0])))
      (hK x0)
  have hCS :
    (∑ x ∈ A, prodMass p x * (∑ j, a x j / upperMoment f r x)⁻¹) *
    (∑ y ∈ B, prodMass p y * (∑ j, a y j / lowerMoment f r y)⁻¹)
       ≤ 3 * M / 8 := by
    have hC : 0 ≤ 3 * M / 8 := by positivity
    exact weighted_cs A B (prodMass p) (prodMass p)
      (prodMass_nonneg' p hp) (prodMass_nonneg' p hp)
      hAm hBm
      (fun x j => a x j / upperMoment f r x)
      (fun y j => a y j / lowerMoment f r y)
      (fun x j => div_nonneg (hr.1 x j) (upperMoment_nonneg f r x))
      (fun y j => div_nonneg (hr.1 y j) (lowerMoment_nonneg f r y))
      disagree (3 * M / 8) hC
      (by
        intro x hx y hy w hw
        rw [scaled_pair_cost]
        exact div_pos
          (pairCost_pos f a hr w hw x y (by linarith [hAx x hx, hBy y hy]))
          (mul_pos (hU x hx) (hV y hy)))
      (by
        intro w hw
        have hbudget := weighted_mixed_crossing_budget p hp hp1 f a hr w hw M hM r
        have heq :
            (∑ x ∈ A, ∑ y ∈ B,
               prodMass p x * prodMass p y *
                (∑ j ∈ disagree x y,
                  w j * (a x j / upperMoment f r x) *
                    (a y j / lowerMoment f r y))⁻¹) =
            (∑ x ∈ A, ∑ y ∈ B,
               (prodMass p x * prodMass p y / pairCost w a x y) *
                 crossingProduct f r x y) := by
          apply Finset.sum_congr rfl
          intro x hx
          apply Finset.sum_congr rfl
          intro y hy
          rw [scaled_pair_cost, inv_div, crossingProduct_eq_moments p f r x y hx hy]
          ring
        rw [heq]
        change 8 * (∑ x ∈ A, ∑ y ∈ B,
          (prodMass p x * prodMass p y / pairCost w a x y) *
            crossingProduct f r x y) ≤ 3 * M * ∑ j, (w j)⁻¹ at hbudget
        have hfactor : 3 * M * ∑ j, (w j)⁻¹ =
            8 * ((3 * M / 8) * ∑ j, (w j)⁻¹) := by ring
        rw [hfactor] at hbudget
        linarith)
  have hP0 : 0 ≤ ∑ x ∈ A, prodMass p x * upperMoment f r x :=
    Finset.sum_nonneg (fun x hx =>
      mul_nonneg (prodMass_nonneg' p hp x) (upperMoment_nonneg f r x))
  have hQ0 : 0 ≤ ∑ y ∈ B, prodMass p y * lowerMoment f r y :=
    Finset.sum_nonneg (fun y hy =>
      mul_nonneg (prodMass_nonneg' p hp y) (lowerMoment_nonneg f r y))
  have hP :
      (∑ x ∈ A, prodMass p x * upperMoment f r x) / K ≤
      ∑ x ∈ A, prodMass p x * (∑ j, a x j / upperMoment f r x)⁻¹ := by
    rw [Finset.sum_div]
    apply Finset.sum_le_sum
    intro x hx
    have hnormpos : 0 < ∑ j, a x j :=
      rowpos x y0 (ne_of_gt (by linarith [hAx x hx, hBy y0 hy0]))
    have hinv : 1 / K ≤ 1 / ∑ j, a x j :=
      one_div_le_one_div_of_le hnormpos (hK x)
    have hq : (∑ j, a x j / upperMoment f r x)⁻¹ =
        upperMoment f r x / (∑ j, a x j) := by
      rw [Finset.sum_div, inv_div]
    rw [hq]
    calc
      prodMass p x * upperMoment f r x / K =
          (prodMass p x * upperMoment f r x) * (1 / K) := by ring
      _ ≤ (prodMass p x * upperMoment f r x) * (1 / ∑ j, a x j) :=
        mul_le_mul_of_nonneg_left hinv
          (mul_nonneg (prodMass_nonneg' p hp x) (upperMoment_nonneg f r x))
      _ = prodMass p x * (upperMoment f r x / ∑ j, a x j) := by ring
  have hQ :
      (∑ y ∈ B, prodMass p y * lowerMoment f r y) / K ≤
      ∑ y ∈ B, prodMass p y * (∑ j, a y j / lowerMoment f r y)⁻¹ := by
    rw [Finset.sum_div]
    apply Finset.sum_le_sum
    intro y hy
    have hnormpos : 0 < ∑ j, a y j :=
      rowpos y x0 (ne_of_lt (by linarith [hAx x0 hx0, hBy y hy]))
    have hinv : 1 / K ≤ 1 / ∑ j, a y j :=
      one_div_le_one_div_of_le hnormpos (hK y)
    have hq : (∑ j, a y j / lowerMoment f r y)⁻¹ =
        lowerMoment f r y / (∑ j, a y j) := by
      rw [Finset.sum_div, inv_div]
    rw [hq]
    calc
      prodMass p y * lowerMoment f r y / K =
          (prodMass p y * lowerMoment f r y) * (1 / K) := by ring
      _ ≤ (prodMass p y * lowerMoment f r y) * (1 / ∑ j, a y j) :=
        mul_le_mul_of_nonneg_left hinv
          (mul_nonneg (prodMass_nonneg' p hp y) (lowerMoment_nonneg f r y))
      _ = prodMass p y * (lowerMoment f r y / ∑ j, a y j) := by ring
  have hCS' :
      (∑ x ∈ A, prodMass p x * (∑ j, a x j / upperMoment f r x)⁻¹) *
      (∑ y ∈ B, prodMass p y * (∑ j, a y j / lowerMoment f r y)⁻¹)
        ≤ 3 * (M / 8) := by convert hCS using 1 <;> ring
  have hfinal := final_alg hKpos hP0 hQ0 hP hQ hCS'
  calc
    8 * (∑ x ∈ A, prodMass p x * upperMoment f r x) *
      (∑ y ∈ B, prodMass p y * lowerMoment f r y) =
      8 * ((∑ x ∈ A, prodMass p x * upperMoment f r x) *
        (∑ y ∈ B, prodMass p y * lowerMoment f r y)) := by ring
    _ ≤ 8 * (3 * K ^ 2 * (M / 8)) :=
      mul_le_mul_of_nonneg_left hfinal (by norm_num)
    _ = 3 * K ^ 2 * M := by ring

end Nightfall.Wright.MixedWeightRemoval
