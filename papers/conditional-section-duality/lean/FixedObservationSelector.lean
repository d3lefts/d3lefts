import Mathlib

/-!
# NIGHTFALL finite selector for conditional-section duality
Author-side scoped certificate, not the full fixed-coordinate observability
theorem. The L1 section budget, source ANOVA reconstruction, and sorted top-q
existence are NOT proved here. Priority and external review remain open.
-/
namespace Nightfall.ConditionalSection

open Finset

private theorem square_le_square_of_nonneg {x y : ℝ}
    (hx : 0 ≤ x) (hxy : x ≤ y) : x ^ 2 ≤ y ^ 2 := by
  have hy : 0 ≤ y := le_trans hx hxy
  have hprod : 0 ≤ (y - x) * (y + x) :=
    mul_nonneg (sub_nonneg.mpr hxy) (add_nonneg hy hx)
  nlinarith

/-- A head budget >=q*t, omitted nonnegative tail and omitted squared
energy <=t*tail give the exact 1/(4q) scaling. -/
theorem scalar_fixed_observation_selector
    (q t head tail total risk : ℝ)
    (hq : 0 < q) (ht : 0 ≤ t) (htail : 0 ≤ tail)
    (hhead : q * t ≤ head) (htotal : head + tail ≤ total)
    (hrisk : risk ≤ t * tail) :
    4 * q * risk ≤ total ^ 2 := by
  have hqt : 0 ≤ q * t := mul_nonneg (le_of_lt hq) ht
  have hlow : 0 ≤ q * t + tail := add_nonneg hqt htail
  have hcap : q * t + tail ≤ total := by linarith
  have hsq : (q * t + tail) ^ 2 ≤ total ^ 2 :=
    square_le_square_of_nonneg hlow hcap
  have hfour : 4 * (q * t) * tail ≤ (q * t + tail) ^ 2 := by
    nlinarith [sq_nonneg (q * t - tail)]
  have hrem : q * risk ≤ q * (t * tail) :=
    mul_le_mul_of_nonneg_left hrisk (le_of_lt hq)
  nlinarith

/-- The supplied section L1 budget beta*L<=2*d²*B forces the exact
beta-conditioned d⁴/q risk bound, conditional on the selector premises. -/
theorem beta_conditioned_fixed_observation
    (d B beta q t head tail total risk : ℝ)
    (hd : 0 ≤ d) (hB : 0 ≤ B) (hbeta : 0 < beta)
    (hq : 0 < q) (ht : 0 ≤ t) (htail : 0 ≤ tail)
    (hhead : q * t ≤ head) (htotal : head + tail ≤ total)
    (hrisk : risk ≤ t * tail) (hbudget : beta * total ≤ 2 * d ^ 2 * B) :
    beta ^ 2 * q * risk ≤ d ^ 4 * B ^ 2 := by
  have hnon : 0 ≤ total := by
    have hqt : 0 ≤ q * t := mul_nonneg (le_of_lt hq) ht
    linarith
  have hsel : 4 * q * risk ≤ total ^ 2 :=
    scalar_fixed_observation_selector q t head tail total risk hq ht htail hhead htotal hrisk
  have hleft : 4 * (beta ^ 2 * q * risk) ≤ beta ^ 2 * total ^ 2 := by
    calc
      4 * (beta ^ 2 * q * risk) = beta ^ 2 * (4 * q * risk) := by ring
      _ ≤ beta ^ 2 * total ^ 2 :=
        mul_le_mul_of_nonneg_left hsel (sq_nonneg beta)
  have hright : beta ^ 2 * total ^ 2 ≤ 4 * d ^ 4 * B ^ 2 := by
    calc
      beta ^ 2 * total ^ 2 = (beta * total) ^ 2 := by ring
      _ ≤ (2 * d ^ 2 * B) ^ 2 :=
        square_le_square_of_nonneg (mul_nonneg (le_of_lt hbeta) hnon) hbudget
      _ = 4 * d ^ 4 * B ^ 2 := by ring
  nlinarith

/-- Given a selected finite block S (values >=threshold) and an omitted
block T (values in [0,threshold]), derive the exact omitted squared-energy
budget from actual sums, rather than assuming the tail bound as a premise. -/
theorem finite_selector_tail_energy
    {ι : Type*} [DecidableEq ι] (S T : Finset ι) (a : ι → ℝ) (t : ℝ)
    (hdisj : Disjoint S T) (hS : S.Nonempty) (ht : 0 ≤ t)
    (hsel : ∀ i ∈ S, t ≤ a i)
    (hremnon : ∀ i ∈ T, 0 ≤ a i)
    (hrem : ∀ i ∈ T, a i ≤ t) :
    4 * (S.card : ℝ) * (T.sum fun i => (a i) ^ 2) ≤
      ((S ∪ T).sum a) ^ 2 := by
  have hq : 0 < (S.card : ℝ) := by
    exact_mod_cast (Finset.card_pos.mpr hS)
  have hhead : (S.card : ℝ) * t ≤ S.sum a := by
    have h : S.sum (fun _ => t) ≤ S.sum a := by
      apply Finset.sum_le_sum
      intro i hi
      exact hsel i hi
    simpa [nsmul_eq_mul] using h
  have htail : 0 ≤ T.sum a := by
    apply Finset.sum_nonneg
    intro i hi
    exact hremnon i hi
  have hrisk : T.sum (fun i => (a i) ^ 2) ≤ t * (T.sum a) := by
    calc
      T.sum (fun i => (a i) ^ 2) ≤ T.sum (fun i => t * a i) := by
        apply Finset.sum_le_sum
        intro i hi
        have ha : 0 ≤ a i := hremnon i hi
        have hbound : 0 ≤ t - a i := sub_nonneg.mpr (hrem i hi)
        nlinarith [mul_nonneg ha hbound]
      _ = t * (T.sum a) := by rw [Finset.mul_sum]
  have htotal : S.sum a + T.sum a ≤ (S ∪ T).sum a := by
    rw [Finset.sum_union hdisj]
  exact scalar_fixed_observation_selector
    (S.card : ℝ) t (S.sum a) (T.sum a) ((S ∪ T).sum a)
    (T.sum fun i => (a i) ^ 2) hq ht htail hhead htotal hrisk

/-- Finite beta-conditioned selection bound for the actual disjoint blocks.
No assumption on the omitted squared energy is needed. -/
theorem finite_beta_fixed_observation
    {ι : Type*} [DecidableEq ι] (S T : Finset ι) (a : ι → ℝ)
    (d B beta t : ℝ)
    (hdisj : Disjoint S T) (hS : S.Nonempty)
    (hd : 0 ≤ d) (hB : 0 ≤ B) (hbeta : 0 < beta)
    (ht : 0 ≤ t) (hsel : ∀ i ∈ S, t ≤ a i)
    (hremnon : ∀ i ∈ T, 0 ≤ a i)
    (hrem : ∀ i ∈ T, a i ≤ t)
    (hbudget : beta * ((S ∪ T).sum a) ≤ 2 * d ^ 2 * B) :
    beta ^ 2 * (S.card : ℝ) * (T.sum fun i => (a i) ^ 2) ≤
       d ^ 4 * B ^ 2 := by
  have hq : 0 < (S.card : ℝ) := by
    exact_mod_cast (Finset.card_pos.mpr hS)
  have hs : 4 * (S.card : ℝ) * (T.sum fun i => (a i) ^ 2) ≤
      ((S ∪ T).sum a) ^ 2 :=
    finite_selector_tail_energy S T a t hdisj hS ht hsel hremnon hrem
  have htnon : 0 ≤ (S ∪ T).sum a := by
    apply Finset.sum_nonneg
    intro i hi
    rcases Finset.mem_union.mp hi with hsi | hti
    · exact le_trans ht (hsel i hsi)
    · exact hremnon i hti
  have hsq : (beta * ((S ∪ T).sum a)) ^ 2 ≤ (2 * d ^ 2 * B) ^ 2 :=
    square_le_square_of_nonneg (mul_nonneg (le_of_lt hbeta) htnon) hbudget
  have ha : 4 * (beta ^ 2 * (S.card : ℝ) * (T.sum fun i => (a i) ^ 2)) ≤
      beta ^ 2 * ((S ∪ T).sum a) ^ 2 := by
    calc
      4 * (beta ^ 2 * (S.card : ℝ) * (T.sum fun i => (a i) ^ 2)) =
          beta ^ 2 * (4 * (S.card : ℝ) * (T.sum fun i => (a i) ^ 2)) := by ring
      _ ≤ beta ^ 2 * ((S ∪ T).sum a) ^ 2 :=
        mul_le_mul_of_nonneg_left hs (sq_nonneg beta)
  have hb : beta ^ 2 * ((S ∪ T).sum a) ^ 2 ≤ 4 * d ^ 4 * B ^ 2 := by
    calc
      beta ^ 2 * ((S ∪ T).sum a) ^ 2 =
          (beta * ((S ∪ T).sum a)) ^ 2 := by ring
      _ ≤ (2 * d ^ 2 * B) ^ 2 := hsq
      _ = 4 * d ^ 4 * B ^ 2 := by ring
  nlinarith

/-- Algebraic sharpness: the head and omitted mass can both equal q*t. -/
theorem selector_factor_four_sharp (q t : ℝ) :
    4 * q * (q * t ^ 2) = (q * t + q * t) ^ 2 := by
  ring

end Nightfall.ConditionalSection
