import Mathlib

/-!
# Multiscale projection transfer
Credit: Cinna Davis, solved-conjectures, agnostic VC proof, d72a880f.
The two quadratic-form estimates hold for a monotone family of orthogonal
projections, with independently sampled nonuniform query subsets. The
sampling and variance are defined recursively, not passed as premises.
No commutativity, coordinate independence, or uniform atom bound is used.
-/

open Finset
open scoped InnerProductSpace
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
      rw [Nat.add_mul, one_mul]
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
    exact add_le_add (div_le_div_of_nonneg_left (sq_nonneg _) ha (hr i)) le_rfl
  calc
    kl p r ≤ ∑ i, ((p i-r i)^2/a + (p i-r i)) := Finset.sum_le_sum (fun i _ => ht i)
    _ = _ := by rw [Finset.sum_add_distrib, ← Finset.sum_div,
      Finset.sum_sub_distrib, hp1, hr1, sub_self, add_zero]

end Information

section FiniteSource

variable {Ω L α : Type*} [Fintype Ω] [Fintype L]

/-- Actual coordinate agreement, not a postulated projection family. -/
def agrees (f : Ω → ι → α) (U : Finset ι) (x y : Ω) : Prop :=
  ∀ i ∈ U, f x i = f y i

/-- Weighted L² realization on the finite positive-mass support.
An input table v is represented by sqrt(ν x) * v(x,l).
Zero-mass input atoms may be removed before this construction. -/
noncomputable def embed (ν : Ω → ℝ) (p : Ω → L → ℝ) :
    EuclideanSpace ℝ (Ω × L) :=
  WithLp.toLp 2 (fun z : Ω × L => Real.sqrt (ν z.1) * p z.1 z.2)

noncomputable def querySpace (f : Ω → ι → α) (ν : Ω → ℝ) (U : Finset ι) :
    Submodule ℝ (EuclideanSpace ℝ (Ω × L)) where
  carrier := {v | ∀ x y l, agrees f U x y →
    Real.sqrt (ν y) * v (x,l) = Real.sqrt (ν x) * v (y,l)}
  zero_mem' := by
    intro x y l h
    simp
  add_mem' := by
    intro v w hv hw x y l h
    change Real.sqrt (ν y) * (v+w) (x,l) =
      Real.sqrt (ν x) * (v+w) (y,l)
    simp only [PiLp.add_apply, mul_add]
    rw [hv x y l h, hw x y l h]
  smul_mem' := by
    intro c v hv x y l h
    change Real.sqrt (ν y) * (c • v) (x,l) =
      Real.sqrt (ν x) * (c • v) (y,l)
    simp only [PiLp.smul_apply, smul_eq_mul]
    calc
      _ = c * (Real.sqrt (ν y) * v (x,l)) := by ring
      _ = c * (Real.sqrt (ν x) * v (y,l)) := by rw [hv x y l h]
      _ = _ := by ring

theorem querySpace_mono (f : Ω → ι → α) (ν : Ω → ℝ) :
    Monotone (querySpace (L := L) f ν) := by
  intro U V hUV v hv x y l hxy
  exact hv x y l (fun i hi => hxy i (hUV hi))

/-- Conditional predictive table defined by the genuine orthogonal projection. -/
noncomputable def predictive (f : Ω → ι → α) (ν : Ω → ℝ)
    (p : Ω → L → ℝ) (U : Finset ι) (x : Ω) (l : L) : ℝ :=
  ((querySpace (L := L) f ν U).starProjection (embed ν p)) (x,l) /
    Real.sqrt (ν x)

theorem predictive_mul_sqrt (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (p : Ω → L → ℝ) (U : Finset ι) (x : Ω) (l : L) :
    Real.sqrt (ν x) * predictive f ν p U x l =
      ((querySpace (L := L) f ν U).starProjection (embed ν p)) (x,l) := by
  unfold predictive
  field_simp [ne_of_gt (Real.sqrt_pos.2 (hν x))]

theorem predictive_agrees (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (p : Ω → L → ℝ) (U : Finset ι)
    (x y : Ω) (l : L) (hxy : agrees f U x y) :
    predictive f ν p U x l = predictive f ν p U y l := by
  have hv := (querySpace (L := L) f ν U).starProjection_apply_mem (embed ν p)
  have he := hv x y l hxy
  unfold predictive
  apply (div_eq_div_iff (ne_of_gt (Real.sqrt_pos.2 (hν x)))
    (ne_of_gt (Real.sqrt_pos.2 (hν y)))).2
  simpa only [mul_comm] using he

noncomputable def cellMass (f : Ω → ι → α) (ν : Ω → ℝ)
    (U : Finset ι) (x : Ω) : ℝ := by
  classical
  exact ∑ t, if agrees f U t x then ν t else 0

noncomputable def cellNumerator (f : Ω → ι → α) (ν : Ω → ℝ)
    (p : Ω → L → ℝ) (U : Finset ι) (x : Ω) (l : L) : ℝ := by
  classical
  exact ∑ t, if agrees f U t x then ν t * p t l else 0

theorem cellMass_pos (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (U : Finset ι) (x : Ω) :
    0 < cellMass f ν U x := by
  classical
  have hx : agrees f U x x := fun _ _ => rfl
  have hn : ∀ t ∈ (Finset.univ : Finset Ω),
      0 ≤ (if agrees f U t x then ν t else 0) := by
    intro t _
    split
    · exact (hν t).le
    · exact le_rfl
  have hle : (if agrees f U x x then ν x else 0) ≤
      ∑ t, if agrees f U t x then ν t else 0 :=
    Finset.single_le_sum hn (Finset.mem_univ x)
  simp only [if_pos hx] at hle
  exact (hν x).trans_le hle

noncomputable def cellTest (f : Ω → ι → α) (ν : Ω → ℝ)
    (U : Finset ι) (x : Ω) (l : L) : EuclideanSpace ℝ (Ω × L) := by
  classical
  exact WithLp.toLp 2 (fun z : Ω × L =>
    if agrees f U z.1 x ∧ z.2 = l then Real.sqrt (ν z.1) else 0)

theorem cellTest_mem (f : Ω → ι → α) (ν : Ω → ℝ)
    (U : Finset ι) (x : Ω) (l : L) :
    cellTest f ν U x l ∈ querySpace (L := L) f ν U := by
  classical
  intro t s b hts
  have h : agrees f U t x ↔ agrees f U s x := by
    constructor
    · intro ht i hi
      exact (hts i hi).symm.trans (ht i hi)
    · intro hs i hi
      exact (hts i hi).trans (hs i hi)
  change Real.sqrt (ν s) * cellTest f ν U x l (t,b) =
    Real.sqrt (ν t) * cellTest f ν U x l (s,b)
  simp only [cellTest, PiLp.toLp_apply, h]
  split <;> ring

/-- No assumed Bayes/orthogonal-projection identification: derive the actual
finite cell mean from a coordinate-cell indicator and orthogonality. -/
theorem predictive_eq_cell_average (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (p : Ω → L → ℝ) (U : Finset ι) (x : Ω) (l : L) :
    predictive f ν p U x l = cellNumerator f ν p U x l / cellMass f ν U x := by
  classical
  let v := (querySpace (L := L) f ν U).starProjection (embed ν p)
  have horth := (querySpace (L := L) f ν U).starProjection_inner_eq_zero
    (embed ν p) (cellTest f ν U x l) (cellTest_mem f ν U x l)
  change ⟪embed ν p - v, cellTest f ν U x l⟫_ℝ = 0 at horth
  rw [PiLp.inner_apply, Fintype.sum_prod_type] at horth
  simp only [Real.inner_apply] at horth
  have ht (t : Ω) :
      (∑ b : L, (embed ν p - v) (t,b) * cellTest f ν U x l (t,b)) =
        if agrees f U t x then ν t * (p t l - predictive f ν p U x l) else 0 := by
    by_cases htx : agrees f U t x
    · rw [if_pos htx, Finset.sum_eq_single l]
      · have hm : Real.sqrt (ν t) * predictive f ν p U t l = v (t,l) :=
          predictive_mul_sqrt f ν hν p U t l
        simp only [PiLp.sub_apply, embed, cellTest, PiLp.toLp_apply, htx, true_and, if_pos rfl, if_true]
        rw [← hm, predictive_agrees f ν hν p U t x l htx]
        calc
          _ = (Real.sqrt (ν t))^2 * (p t l - predictive f ν p U x l) := by ring
          _ = _ := by rw [Real.sq_sqrt (hν t).le]
      · intro b _ hb
        simp [cellTest, hb]
      · simp
    · rw [if_neg htx]
      apply Finset.sum_eq_zero
      intro b _
      simp [cellTest, htx]
  rw [Finset.sum_congr rfl (fun t _ => ht t)] at horth
  have hsplit : (∑ t, if agrees f U t x then ν t * (p t l - predictive f ν p U x l) else 0) =
      cellNumerator f ν p U x l - cellMass f ν U x * predictive f ν p U x l := by
    unfold cellNumerator cellMass
    rw [Finset.sum_mul, ← Finset.sum_sub_distrib]
    apply Finset.sum_congr rfl
    intro t _
    by_cases htx : agrees f U t x <;> simp [htx] <;> ring
  rw [hsplit] at horth
  apply (eq_div_iff (ne_of_gt (cellMass_pos f ν hν U x))).2
  linarith

theorem predictive_sum_one (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (p : Ω → L → ℝ) (hp1 : ∀ x, ∑ l, p x l = 1)
    (U : Finset ι) (x : Ω) :
    ∑ l, predictive f ν p U x l = 1 := by
  classical
  simp_rw [predictive_eq_cell_average f ν hν p U x]
  rw [← Finset.sum_div]
  have hsum : (∑ l, cellNumerator f ν p U x l) = cellMass f ν U x := by
    unfold cellNumerator cellMass
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro t _
    by_cases htx : agrees f U t x
    · simp [htx, ← Finset.mul_sum, hp1 t]
    · simp [htx]
  rw [hsum]
  exact div_self (ne_of_gt (cellMass_pos f ν hν U x))

theorem source_projection_risk_eq (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (p : Ω → L → ℝ) (U : Finset ι) :
    ‖embed ν p - (querySpace (L := L) f ν U).starProjection (embed ν p)‖ ^ 2 =
      ∑ x, ν x * ∑ l, (p x l - predictive f ν p U x l)^2 := by
  rw [EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
  apply Finset.sum_congr rfl
  intro x _
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro l _
  rw [PiLp.sub_apply]
  change (Real.sqrt (ν x) * p x l - ((querySpace (L := L) f ν U).starProjection (embed ν p)) (x,l)) ^ 2 = _
  rw [← predictive_mul_sqrt f ν hν p U x l]
  calc
    _ = (Real.sqrt (ν x))^2 * (p x l - predictive f ν p U x l)^2 := by ring
    _ = _ := by rw [Real.sq_sqrt (hν x).le]

/-- Exact residual conditional information, in nats, for the joint table
Pr(X=x,Theta=l)=ν x * p x l, after observing coordinates U. -/
noncomputable def residualInfo (f : Ω → ι → α) (ν : Ω → ℝ)
    (p : Ω → L → ℝ) (U : Finset ι) : ℝ :=
  ∑ x, ν x * kl (p x) (predictive f ν p U x)

theorem source_kl_floor (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (p : Ω → L → ℝ)
    (hp : ∀ x l, 0 ≤ p x l) (hp1 : ∀ x, ∑ l, p x l = 1)
    (a : ℝ) (ha : 0 < a) (U : Finset ι)
    (hfloor : ∀ x l, a ≤ predictive f ν p U x l) :
    residualInfo f ν p U ≤
      (1/a) * ‖embed ν p - (querySpace (L := L) f ν U).starProjection (embed ν p)‖ ^ 2 := by
  rw [source_projection_risk_eq f ν hν p U, Finset.mul_sum]
  unfold residualInfo
  apply Finset.sum_le_sum
  intro x _
  have h := kl_predictive_floor (p x) (predictive f ν p U x) a ha
    (hp x) (hfloor x) (hp1 x) (predictive_sum_one f ν hν p hp1 U x)
  calc
    _ ≤ ν x * ((∑ l, (p x l - predictive f ν p U x l)^2) / a) :=
      mul_le_mul_of_nonneg_left h (hν x).le
    _ = _ := by ring

/-- Expected cost on the actual union of independent queries. -/
noncomputable def costRisk (w : J → ℝ) (q : J → Finset ι)
    (g : Finset ι → ℝ) : ℕ → Finset ι → ℝ
  | 0, U => g U
  | n+1, U => ∑ j, w j * costRisk w q g n (U ∪ q j)

theorem costRisk_le_scaled_union (S : Finset ι → Submodule ℝ H)
    (w : J → ℝ) (hw : ∀ j, 0 ≤ w j) (q : J → Finset ι)
    (g : Finset ι → ℝ) (x : H) (c : ℝ) (n : ℕ) (U : Finset ι)
    (hbound : ∀ js : List J, js.length = n →
      g (js.foldl (fun V j => V ∪ q j) U) ≤
        c * ‖x - (S (js.foldl (fun V j => V ∪ q j) U)).starProjection x‖ ^ 2) :
    costRisk w q g n U ≤ c * unionRisk S w q n U x := by
  induction n generalizing U with
  | zero => simpa [costRisk, unionRisk] using hbound [] rfl
  | succ n ih =>
      simp only [costRisk, unionRisk, Finset.mul_sum]
      apply Finset.sum_le_sum
      intro j _
      have hb : ∀ js : List J, js.length = n →
          g (js.foldl (fun V j => V ∪ q j) (U ∪ q j)) ≤
            c * ‖x - (S (js.foldl (fun V j => V ∪ q j) (U ∪ q j))).starProjection x‖ ^ 2 := by
        intro js hjs
        exact hbound (j :: js) (by simp [hjs])
      calc
        _ ≤ w j * (c * unionRisk S w q n (U ∪ q j) x) :=
          mul_le_mul_of_nonneg_left (ih (U ∪ q j) hb) (hw j)
        _ = _ := by ring

/-- Full finite latent information transfer for actual coordinate reads.
The predictive floor is required only on reachable final unions. -/
theorem finite_latent_transfer (f : Ω → ι → α) (ν : Ω → ℝ)
    (hν : ∀ x, 0 < ν x) (_hν1 : ∑ x, ν x = 1)
    (p : Ω → L → ℝ) (hp : ∀ x l, 0 ≤ p x l) (hp1 : ∀ x, ∑ l, p x l = 1)
    (w : J → ℝ) (hw : ∀ j, 0 ≤ w j) (hw1 : ∑ j, w j = 1)
    (q : J → Finset ι) (k : ℕ) (hk : 0 < k) (a : ℝ) (ha : 0 < a)
    (hfloor : ∀ js : List J, js.length = k → ∀ x l,
      a ≤ predictive f ν p (js.foldl (fun V j => V ∪ q j) ∅) x l) :
    costRisk w q (residualInfo f ν p) k ∅ ≤
      (1/a) * (‖embed ν p - avgProjection (querySpace (L := L) f ν) w q (embed ν p)‖ ^ 2 +
        (⟪embed ν p, avgProjection (querySpace (L := L) f ν) w q (embed ν p)⟫_ℝ -
          ‖avgProjection (querySpace (L := L) f ν) w q (embed ν p)‖ ^ 2) / (k : ℝ)) := by
  have h := costRisk_le_scaled_union (querySpace (L := L) f ν) w hw q
    (residualInfo f ν p) (embed ν p) (1/a) k ∅
    (fun js hjs => source_kl_floor f ν hν p hp hp1 a ha
      (js.foldl (fun V j => V ∪ q j) ∅) (hfloor js hjs))
  exact h.trans (mul_le_mul_of_nonneg_left
    (residual_variance (querySpace (L := L) f ν) (querySpace_mono f ν)
      w hw hw1 q (embed ν p) k hk) (by positivity))

end FiniteSource

end Nightfall.MultiscaleProjection

#print axioms Nightfall.MultiscaleProjection.sumRisk_exact
#print axioms Nightfall.MultiscaleProjection.overlap_variance
#print axioms Nightfall.MultiscaleProjection.residual_variance
#print axioms Nightfall.MultiscaleProjection.union_card_budget
#print axioms Nightfall.MultiscaleProjection.kl_predictive_floor

#print axioms Nightfall.MultiscaleProjection.predictive_eq_cell_average
#print axioms Nightfall.MultiscaleProjection.finite_latent_transfer
