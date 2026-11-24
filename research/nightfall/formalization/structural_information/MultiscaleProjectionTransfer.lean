import Mathlib

/-!
# Multiscale projection transfer
Credit: Cinna Davis, solved-conjectures, agnostic VC proof, d72a880f.
The two quadratic-form estimates hold for a monotone family of orthogonal
projections, with independently sampled nonuniform query subsets. The
sampling and variance are defined recursively, not passed as premises.
No commutativity, coordinate independence, or uniform atom bound is used.
-/

open Finset RealInnerProductSpace
namespace Nightfall.MultiscaleProjection

variable {J H : Type*} [Fintype J] [NormedAddCommGroup H] [InnerProductSpace ℝ H]

noncomputable def mean (w : J → ℝ) (u : J → H) : H :=
  ∑ j, w j • u j

noncomputable def variance (w : J → ℝ) (u : J → H) : ℝ :=
  (∑ j, w j * ‖u j‖ ^ 2) - ‖mean w u‖ ^ 2

/-- One actual independent draw at each step. -/
noncomputable def sumRisk (w : J → ℝ) (u : J → H) : ℕ → H → ℝ
  | 0, z => ‖z‖ ^ 2
  | n+1, z => ∑ j, w j * sumRisk w u n (z - u j)

theorem weighted_shift (w : J → ℝ) (u : J → H)
    (hw : ∑ j, w j = 1) (z : H) :
    (∑ j, w j * ‖z - u j‖ ^ 2) =
      ‖z - mean w u‖ ^ 2 + variance w u := by
  have hc : (∑ j, w j * ⟪z, u j⟫_ℝ) = ⟪z, mean w u⟫_ℝ := by
    simp [mean, inner_sum, real_inner_smul_right]
  calc
    _ = ∑ j, (w j * ‖z‖ ^ 2 - 2 * (w j * ⟪z, u j⟫_ℝ) +
          w j * ‖u j‖ ^ 2) := by
      apply Finset.sum_congr rfl
      intro j _
      rw [norm_sub_sq_real]
      ring
    _ = ‖z‖ ^ 2 - 2 * ⟪z, mean w u⟫_ℝ + ∑ j, w j * ‖u j‖ ^ 2 := by
      rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul,
        hw, one_mul, ← Finset.mul_sum, hc]
    _ = _ := by rw [norm_sub_sq_real, variance]; ring

theorem sumRisk_exact (w : J → ℝ) (u : J → H)
    (hw : ∑ j, w j = 1) (n : ℕ) (z : H) :
    sumRisk w u n z =
      ‖z - (n : ℝ) • mean w u‖ ^ 2 + (n : ℝ) * variance w u := by
  induction n generalizing z with
  | zero => simp [sumRisk]
  | succ n ih =>
      simp only [sumRisk, ih]
      have hs (j : J) :
          z - u j - (n : ℝ) • mean w u =
            (z - (n : ℝ) • mean w u) - u j := by abel
      simp_rw [hs, mul_add, Finset.sum_add_distrib]
      rw [← Finset.sum_mul, hw, one_mul, weighted_shift w u hw]
      have hz : z - (n : ℝ) • mean w u - mean w u =
          z - ((n+1 : ℕ) : ℝ) • mean w u := by
        rw [Nat.cast_succ, add_smul, one_smul, sub_sub]
      rw [hz, Nat.cast_succ]
      ring

variable {ι : Type*} [DecidableEq ι] [FiniteDimensional ℝ H]

noncomputable def unionRisk (S : Finset ι → Submodule ℝ H)
    (w : J → ℝ) (q : J → Finset ι) : ℕ → Finset ι → H → ℝ
  | 0, U, x => ‖x - (S U).starProjection x‖ ^ 2
  | n+1, U, x => ∑ j, w j * unionRisk S w q n (U ∪ q j) x

theorem projection_best_sq (V : Submodule ℝ H) (x z : H) (hz : z ∈ V) :
    ‖x - V.starProjection x‖ ^ 2 ≤ ‖x - z‖ ^ 2 := by
  have hm : V.starProjection x - z ∈ V :=
    V.sub_mem (V.starProjection_apply_mem x) hz
  have horth := V.starProjection_inner_eq_zero x (V.starProjection x - z) hm
  have heq : x - z = (x - V.starProjection x) + (V.starProjection x - z) := by abel
  rw [heq, norm_add_sq_real, horth]
  nlinarith [sq_nonneg ‖V.starProjection x - z‖]

theorem unionRisk_le_sumRisk (S : Finset ι → Submodule ℝ H)
    (hS : Monotone S) (w : J → ℝ) (hw : ∀ j, 0 ≤ w j)
    (q : J → Finset ι) (y x : H) (n : ℕ) (U : Finset ι)
    (z : H) (hz : z ∈ S U) :
    unionRisk S w q n U x ≤
      sumRisk w (fun j => (S (q j)).starProjection y) n (x - z) := by
  induction n generalizing U z with
  | zero =>
      simpa only [unionRisk, sumRisk] using projection_best_sq (S U) x z hz
  | succ n ih =>
      simp only [unionRisk, sumRisk]
      apply Finset.sum_le_sum
      intro j _
      apply mul_le_mul_of_nonneg_left _ (hw j)
      have hm : z + (S (q j)).starProjection y ∈ S (U ∪ q j) :=
        (S (U ∪ q j)).add_mem
          (hS Finset.subset_union_left hz)
          (hS Finset.subset_union_right ((S (q j)).starProjection_apply_mem y))
      simpa only [sub_add_eq_sub_sub] using
        ih (U ∪ q j) (z + (S (q j)).starProjection y) hm

theorem unionRisk_smul (S : Finset ι → Submodule ℝ H)
    (w : J → ℝ) (q : J → Finset ι) (n : ℕ) (U : Finset ι)
    (c : ℝ) (x : H) :
    unionRisk S w q n U (c • x) = c ^ 2 * unionRisk S w q n U x := by
  induction n generalizing U with
  | zero =>
      simp only [unionRisk, map_smul, ← smul_sub, norm_smul, Real.norm_eq_abs,
        mul_pow, sq_abs]
  | succ n ih =>
      simp only [unionRisk, ih, Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro j _
      ring

noncomputable def avgProjection (S : Finset ι → Submodule ℝ H)
    (w : J → ℝ) (q : J → Finset ι) (y : H) : H :=
  mean w (fun j => (S (q j)).starProjection y)

theorem projection_variance (S : Finset ι → Submodule ℝ H)
    (w : J → ℝ) (q : J → Finset ι) (y : H) :
    variance w (fun j => (S (q j)).starProjection y) =
      ⟪y, avgProjection S w q y⟫_ℝ - ‖avgProjection S w q y‖ ^ 2 := by
  have hp (j : J) :
      ⟪y, (S (q j)).starProjection y⟫_ℝ = ‖(S (q j)).starProjection y‖ ^ 2 := by
    have h := (S (q j)).starProjection_inner_eq_zero y
      ((S (q j)).starProjection y) ((S (q j)).starProjection_apply_mem y)
    rw [inner_sub_left, real_inner_self_eq_norm_sq] at h
    linarith
  simp [variance, avgProjection, mean, inner_sum, real_inner_smul_right, hp]

/-- Full independent-union quadratic-form estimate. No sampling identity
or projection inequality is supplied by the caller. -/
theorem independent_union_risk (S : Finset ι → Submodule ℝ H)
    (hS : Monotone S) (w : J → ℝ) (hw : ∀ j, 0 ≤ w j)
    (hw1 : ∑ j, w j = 1) (q : J → Finset ι) (y x : H)
    (k : ℕ) (hk : 0 < k) :
    unionRisk S w q k ∅ x ≤
      ‖x - avgProjection S w q y‖ ^ 2 +
        (⟪y, avgProjection S w q y⟫_ℝ - ‖avgProjection S w q y‖ ^ 2) / (k : ℝ) := by
  have h := unionRisk_le_sumRisk S hS w hw q y ((k : ℝ) • x) k ∅ 0
    ((S ∅).zero_mem)
  rw [sub_zero, sumRisk_exact w _ hw1, unionRisk_smul,
    projection_variance S w q y] at h
  change (k : ℝ)^2 * unionRisk S w q k ∅ x ≤
    ‖(k : ℝ) • x - (k : ℝ) • avgProjection S w q y‖ ^ 2 +
      (k : ℝ) * (⟪y, avgProjection S w q y⟫_ℝ - ‖avgProjection S w q y‖ ^ 2) at h
  rw [← smul_sub, norm_smul, Real.norm_eq_abs, mul_pow, sq_abs] at h
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  apply le_of_mul_le_mul_left _ (show (0 : ℝ) < (k : ℝ)^2 by positivity)
  calc
    _ ≤ _ := h
    _ = _ := by field_simp [ne_of_gt hkR] <;> ring

/-- First inequality of #1186 in quadratic form, A(I-C)A. -/
theorem overlap_variance (S : Finset ι → Submodule ℝ H)
    (hS : Monotone S) (w : J → ℝ) (hw : ∀ j, 0 ≤ w j)
    (hw1 : ∑ j, w j = 1) (q : J → Finset ι) (y : H)
    (k : ℕ) (hk : 0 < k) :
    unionRisk S w q k ∅ (avgProjection S w q y) ≤
      (⟪y, avgProjection S w q y⟫_ℝ - ‖avgProjection S w q y‖ ^ 2) / (k : ℝ) := by
  simpa using independent_union_risk S hS w hw hw1 q y
    (avgProjection S w q y) k hk

/-- Second inequality of #1186 in quadratic form, I-C. -/
theorem residual_variance (S : Finset ι → Submodule ℝ H)
    (hS : Monotone S) (w : J → ℝ) (hw : ∀ j, 0 ≤ w j)
    (hw1 : ∑ j, w j = 1) (q : J → Finset ι) (y : H)
    (k : ℕ) (hk : 0 < k) :
    unionRisk S w q k ∅ y ≤ ‖y - avgProjection S w q y‖ ^ 2 +
      (⟪y, avgProjection S w q y⟫_ℝ - ‖avgProjection S w q y‖ ^ 2) / (k : ℝ) :=
  independent_union_risk S hS w hw hw1 q y y k hk

/-- Actual union cardinality: each step charges at most m coordinates. -/
theorem union_card_budget (q : J → Finset ι) (m : ℕ)
    (hq : ∀ j, (q j).card ≤ m) (js : List J) (U : Finset ι) :
    (js.foldl (fun V j => V ∪ q j) U).card ≤ U.card + js.length * m := by
  induction js generalizing U with
  | nil => simp
  | cons j js ih =>
      simp only [List.foldl_cons, List.length_cons]
      have h := ih (U ∪ q j)
      have hc := Finset.card_union_le U (q j)
      have hj := hq j
      omega

section Information
variable {L : Type*} [Fintype L]

noncomputable def kl (p r : L → ℝ) : ℝ :=
  ∑ i, p i * Real.log (p i / r i)

theorem kl_term (p r : ℝ) (hp : 0 ≤ p) (hr : 0 < r) :
    p * Real.log (p/r) ≤ (p-r)^2/r + (p-r) := by
  rcases hp.eq_or_lt with h | h
  · subst p
    simp [div_eq_mul_inv]
    field_simp [ne_of_gt hr] <;> ring_nf <;> linarith
  · have ht := mul_le_mul_of_nonneg_left
        (Real.log_le_sub_one_of_pos (div_pos h hr)) h.le
    calc
      _ ≤ p * (p/r - 1) := ht
      _ = _ := by field_simp [ne_of_gt hr] <;> ring

theorem kl_predictive_floor (p r : L → ℝ) (a : ℝ) (ha : 0 < a)
    (hp : ∀ i, 0 ≤ p i) (hr : ∀ i, a ≤ r i)
    (hp1 : ∑ i, p i = 1) (hr1 : ∑ i, r i = 1) :
    kl p r ≤ (∑ i, (p i-r i)^2) / a := by
  have ht (i : L) : p i * Real.log (p i/r i) ≤
      (p i-r i)^2/a + (p i-r i) := by
    apply (kl_term (p i) (r i) (hp i) (ha.trans_le (hr i))).trans
    apply add_le_add_right
    exact div_le_div_of_nonneg_left (sq_nonneg _) ha (hr i)
  calc
    kl p r ≤ ∑ i, ((p i-r i)^2/a + (p i-r i)) := Finset.sum_le_sum (fun i _ => ht i)
    _ = _ := by rw [Finset.sum_add_distrib, ← Finset.sum_div,
      Finset.sum_sub_distrib, hp1, hr1, sub_self, add_zero]

end Information
end Nightfall.MultiscaleProjection

#print axioms Nightfall.MultiscaleProjection.sumRisk_exact
#print axioms Nightfall.MultiscaleProjection.overlap_variance
#print axioms Nightfall.MultiscaleProjection.residual_variance
#print axioms Nightfall.MultiscaleProjection.union_card_budget
#print axioms Nightfall.MultiscaleProjection.kl_predictive_floor
