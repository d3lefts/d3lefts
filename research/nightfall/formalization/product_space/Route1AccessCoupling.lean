import Route1WynerGeneral

/-! A clean-input coupling transfers original-coordinate trees to corrupted sources.
The terminal uses the original Route 1 simulator and its certified degree row bound. -/

namespace Nightfall.Route1AccessCoupling

open Finset
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Influence
open Nightfall.ProductSpace.Simulation
open Nightfall.Route1Polylog

variable {ι α : Type} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α] [Nonempty α]

abbrev Input (ι α : Type) := ι → α

def touched : DTree ι α → Input ι α → Finset ι
  | .leaf _ _, _ => ∅
  | .node j ts, x => insert j (touched (ts (x j)) x)

theorem touched_card_le (t : DTree ι α) (y : Input ι α) :
    (touched t y).card ≤ t.queries y := by
  induction t with
  | leaf => simp [touched, DTree.queries]
  | node j ts ih =>
    simp only [touched, DTree.queries]
    exact (Finset.card_insert_le _ _).trans (Nat.add_le_add_right (ih (y j)) 1)

theorem eval_eq_of_touched (t : DTree ι α) (x y : Input ι α)
    (h : ∀ i ∈ touched t y, x i = y i) : t.eval x = t.eval y := by
  induction t with
  | leaf => rfl
  | node j ts ih =>
    have hj : x j = y j := h j (by simp [touched])
    simp only [DTree.eval, hj]
    apply ih (y j)
    intro i hi
    exact h i (by simp [touched, hi])

def miss (y x : Input ι α) (i : ι) : ℝ := if x i ≠ y i then 1 else 0

noncomputable def fail (f : Input ι α → ℝ) (t : DTree ι α)
    (e : ℝ) (x : Input ι α) : ℝ :=
  if e < |f x - t.eval x| then 1 else 0

theorem miss_nonneg (y x : Input ι α) (i : ι) : 0 ≤ miss y x i := by
  unfold miss
  split_ifs <;> norm_num

theorem fail_nonneg (f : Input ι α → ℝ) (t : DTree ι α) (e : ℝ)
    (x : Input ι α) : 0 ≤ fail f t e x := by
  unfold fail
  split_ifs <;> norm_num

/-- Access-path union bound plus a pointwise comparison of target values. -/
theorem failure_at_pair (f : Input ι α → ℝ) (t : DTree ι α)
    (e u : ℝ) (hu : 0 < u) (x y : Input ι α) :
    fail f t (e + u) x ≤
      fail f t e y + (∑ i ∈ touched t y, miss y x i) + |f x - f y| / u := by
  have hm : 0 ≤ ∑ i ∈ touched t y, miss y x i :=
    Finset.sum_nonneg fun i _ => miss_nonneg y x i
  have hv : 0 ≤ |f x - f y| / u := div_nonneg (abs_nonneg _) hu.le
  by_cases hb : e + u < |f x - t.eval x|
  · rw [fail, if_pos hb]
    by_cases hc : e < |f y - t.eval y|
    · rw [fail, if_pos hc]
      linarith
    · rw [fail, if_neg hc]
      by_cases ha : ∀ i ∈ touched t y, x i = y i
      · have he := eval_eq_of_touched t x y ha
        have hh : |f x - t.eval x| ≤ |f x - f y| + |f y - t.eval y| := by
          rw [he, show f x - t.eval y = (f x - f y) + (f y - t.eval y) by ring]
          exact abs_add_le _ _
        have hp : u ≤ |f x - f y| := by linarith [le_of_not_gt hc]
        have hd : 1 ≤ |f x - f y| / u := (le_div_iff₀ hu).2 (by simpa using hp)
        linarith
      · push Not at ha
        obtain ⟨i, hi, hxy⟩ := ha
        have hsum := Finset.single_le_sum
          (f := fun j => miss y x j) (fun j _ => miss_nonneg y x j) hi
        have hi1 : miss y x i = 1 := by simp [miss, hxy]
        rw [hi1] at hsum
        linarith
  · rw [fail, if_neg hb]
    linarith [fail_nonneg f t e y]

theorem sum_miss_le (C : Input ι α → ℝ) (y : Input ι α)
    (η : ι → ℝ) (hη : ∀ i, (∑ x, C x * miss y x i) ≤ η i)
    (I : Finset ι) (a : ι → ℝ) (ha : ∀ i, 0 ≤ a i) :
    (∑ x, C x * ∑ i ∈ I, a i * miss y x i) ≤ ∑ i ∈ I, a i * η i := by
  calc
    (∑ x, C x * ∑ i ∈ I, a i * miss y x i) =
        ∑ i ∈ I, a i * (∑ x, C x * miss y x i) := by
      simp only [Finset.mul_sum]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro i _
      apply Finset.sum_congr rfl
      intro x _
      ring
    _ ≤ ∑ i ∈ I, a i * η i :=
      Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left (hη i) (ha i)

theorem target_miss_bound (f : Input ι α → ℝ) (a : Input ι α → ι → ℝ)
    (ha : RealRow f a) (y x : Input ι α) :
    |f x - f y| ≤ ∑ i, a y i * miss y x i := by
  rw [abs_sub_comm]
  have h := ha.2 y x
  unfold Nightfall.ProductSpace.Transfer.disagree at h
  rw [Finset.sum_filter] at h
  refine h.trans_eq ?_
  apply Finset.sum_congr rfl
  intro i _
  by_cases hxy : x i = y i
  · simp [miss, hxy, hxy.symm]
  · have hyx : y i ≠ x i := Ne.symm hxy
    simp [miss, hxy, hyx]

/-- Per-anchor, path-weighted transfer. The entire reference-to-actual
coupling may be correlated. Only conditional marginal mismatch is bounded. -/
theorem anchor_failure_le (f : Input ι α → ℝ) (t : DTree ι α)
    (a : Input ι α → ι → ℝ) (ha : RealRow f a)
    (C : Input ι α → ℝ) (hc : ∀ x, 0 ≤ C x) (hc1 : ∑ x, C x = 1)
    (y : Input ι α) (η : ι → ℝ)
    (hη : ∀ i, (∑ x, C x * miss y x i) ≤ η i)
    (e u : ℝ) (hu : 0 < u) :
    (∑ x, C x * fail f t (e + u) x) ≤
      fail f t e y + (∑ i ∈ touched t y, η i) + (∑ i, a y i * η i) / u := by
  have hp := sum_miss_le C y η hη (touched t y) (fun _ => 1) (fun _ => zero_le_one)
  simp only [one_mul] at hp
  have hv := sum_miss_le C y η hη Finset.univ (a y) (ha.1 y)
  calc
    (∑ x, C x * fail f t (e + u) x) ≤ ∑ x, C x *
        (fail f t e y + (∑ i ∈ touched t y, miss y x i) +
          (∑ i, a y i * miss y x i) / u) := by
      apply Finset.sum_le_sum
      intro x _
      apply mul_le_mul_of_nonneg_left _ (hc x)
      exact (failure_at_pair f t e u hu x y).trans
        (add_le_add_right (div_le_div_of_nonneg_right (target_miss_bound f a ha y x) hu.le) _)
    _ = fail f t e y + (∑ x, C x * ∑ i ∈ touched t y, miss y x i) +
          (∑ x, C x * ∑ i, a y i * miss y x i) / u := by
      simp only [mul_add, Finset.sum_add_distrib, ← mul_div_assoc]
      rw [← Finset.sum_mul, hc1, one_mul, ← Finset.sum_div]
    _ ≤ _ := add_le_add (add_le_add_right hp _) (div_le_div_of_nonneg_right hv hu.le)

theorem transfer_access_risk (Q ν : Input ι α → ℝ)
    (hQ : ∀ y, 0 ≤ Q y)
    (C : Input ι α → Input ι α → ℝ) (hc : ∀ y x, 0 ≤ C y x)
    (hc1 : ∀ y, ∑ x, C y x = 1) (hmarg : ∀ x, ν x = ∑ y, Q y * C y x)
    (f : Input ι α → ℝ) (t : DTree ι α)
    (a : Input ι α → ι → ℝ) (ha : RealRow f a) (η : Input ι α → ι → ℝ)
    (hη : ∀ y i, (∑ x, C y x * miss y x i) ≤ η y i)
    (e u : ℝ) (hu : 0 < u) :
    (∑ x, ν x * fail f t (e + u) x) ≤
      ∑ y, Q y * (fail f t e y + (∑ i ∈ touched t y, η y i) +
        (∑ i, a y i * η y i) / u) := by
  calc
    (∑ x, ν x * fail f t (e + u) x) =
        ∑ y, Q y * ∑ x, C y x * fail f t (e + u) x := by
      simp only [hmarg, Finset.sum_mul, Finset.mul_sum]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro y _
      apply Finset.sum_congr rfl
      intro x _
      ring
    _ ≤ _ := Finset.sum_le_sum fun y _ => mul_le_mul_of_nonneg_left
      (anchor_failure_le f t a ha (C y) (hc y) (hc1 y) y (η y) (hη y) e u hu) (hQ y)

noncomputable def budgetK (d : ℕ) : ℝ := Real.pi ^ 2 * (d : ℝ) ^ 2 / 2

noncomputable def nominal (d : ℕ) (τ e s : ℝ) (n : ℕ) : ℝ :=
  (budgetK d / (2 * gam d τ) + s / (etaC d τ ^ 2 * w0C (budgetK d) d τ)) / n + τ / e ^ 2

/-- Route 1 under access-local mismatch: same charged original queries,
no independent-coordinate or global-TV constraint on the corruption. -/
theorem route1_wyner_access_coupled (Q ν : Input ι α → ℝ)
    (hQ : ∀ y, 0 ≤ Q y) (hQ1 : ∑ y, Q y = 1)
    (C : Input ι α → Input ι α → ℝ) (hc : ∀ y x, 0 ≤ C y x)
    (hc1 : ∀ y, ∑ x, C y x = 1) (hmarg : ∀ x, ν x = ∑ y, Q y * C y x)
    (η : ℝ) (hη0 : 0 ≤ η) (hη : ∀ y i, (∑ x, C y x * miss y x i) ≤ η)
    (f : Input ι α → ℝ) (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (d : ℕ) (hd : 1 ≤ d) (hdeg : HasProdDegreeLE f d)
    (τ e u s : ℝ) (hτ : 0 < τ) (hτ1 : τ ≤ 1) (he : 0 < e) (hu : 0 < u)
    (hs : wynerGen Q < s) (n : ℕ) (hn : 0 < n) :
    ∃ t : DTree ι α, (∀ x, t.queries x ≤ n) ∧
      (∑ x, ν x * fail f t (e + u) x) ≤ nominal d τ e s n + n * η + budgetK d * η / u := by
  obtain ⟨a, ha, hsum⟩ := hasRows_of_degree f d hf hdeg
  obtain ⟨t, ht, hclean⟩ := route1_wyner_general Q hQ hQ1 f hf d hd hdeg τ hτ hτ1 e he n hn s hs
  have hclean' : (∑ x, Q x * fail f t e x) ≤ nominal d τ e s n := by
    simpa [fail, nominal, budgetK] using hclean
  refine ⟨t, ht, (transfer_access_risk Q ν hQ C hc hc1 hmarg f t a ha (fun _ _ => η) hη e u hu).trans ?_⟩
  have hnode (y : Input ι α) :
      (∑ i ∈ touched t y, η) ≤ (n : ℝ) * η := by
    rw [Finset.sum_const, nsmul_eq_mul]
    have hcard : ((touched t y).card : ℝ) ≤ (n : ℝ) := by
      exact_mod_cast (touched_card_le t y).trans (ht y)
    exact mul_le_mul_of_nonneg_right hcard hη0
  have hrow (y : Input ι α) : (∑ i, a y i * η) / u ≤ budgetK d * η / u := by
    rw [← Finset.sum_mul]
    exact div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right (hsum y) hη0) hu.le
  calc
    (∑ y, Q y * (fail f t e y + (∑ i ∈ touched t y, η) + (∑ i, a y i * η) / u)) ≤
        ∑ y, Q y * (fail f t e y + (n : ℝ) * η + budgetK d * η / u) := by
      apply Finset.sum_le_sum
      intro y _
      exact mul_le_mul_of_nonneg_left (add_le_add (add_le_add_right (hnode y) _) (hrow y)) (hQ y)
    _ = (∑ y, Q y * fail f t e y) + n * η + budgetK d * η / u := by
      simp only [mul_add, Finset.sum_add_distrib]
      rw [← Finset.sum_mul, ← Finset.sum_mul, hQ1, one_mul, one_mul]
    _ ≤ _ := by linarith

#print axioms eval_eq_of_touched
#print axioms transfer_access_risk
#print axioms route1_wyner_access_coupled

end Nightfall.Route1AccessCoupling
