import AaronsonAmbainis.Row.Main
import AaronsonAmbainis.Pack.Main
import AaronsonAmbainis.Dual.Main

/-!
# NIGHTFALL — the row bound on finite product spaces (Lemma B)

For a function `f : (ι → α) → [-1,1]` of interaction degree at most `d` on a finite product with a
common finite alphabet `α` (no measure enters), every point has a fractional-certificate row of cost
at most `π² d²`:
`|f x - f y| ≤ ∑_{i : x i ≠ y i} a i` for all `y`, with `a ≥ 0`, `∑ a ≤ π² d²`.

Imported unchanged from Turturean's pinned development (`physical-superintelligence/aaronson-ambainis`
at `2a6ceae`, arXiv:2611.09773, §6): covering-LP duality `coverDuality`, the replication and limit
steps `Pack.card_blocks_le`, `Pack.sum_blocks`, `Pack.gate_pos`, `Pack.gate_cos`, `Pack.gate_sq`,
`Pack.le_of_scaled`, the degree calculus of `Row/Degree.lean`, and the endpoint sensitivity bound
`Row.sum_abs_sub_unit_le` with `Row.markovEndpoint` (constant `4 D²`).

New here: the competing-symbol selector. At coordinate `i` the active copies may propose different
replacement symbols; the probability vector
`P_i(s) = [s = x_i](1 - H(cnt_i)) + cnt_{i,s} · q(cnt_i)`, with `H(t) = (1 - T_m(1 - c t))/2 = t q(t)`,
shares the Chebyshev mass `H(cnt_i)` among the proposals. The selector polynomial
`G(w) = ∑_σ f(σ) ∏_i P_i(w)(σ_i)` is bounded by one, has degree at most `d m`, equals `f x` at the
origin and `f (y b)` at the `b`-th unit vector.

Interaction degree is expressed through indicator monomials (`HasProdDegreeLE`), which on finite
products is equivalent to vanishing Efron–Stein components above order `d`.
-/

namespace Nightfall.ProductSpace.RowBound

open Finset Polynomial
open AaronsonAmbainis AaronsonAmbainis.Row

/-! ## Chebyshev selector polynomials -/

/-- `H_m(t) = (1 - T_m(1 - c t)) / 2`. -/
noncomputable def Hp (m : ℕ) (c : ℝ) : ℝ[X] :=
  C (1 / 2 : ℝ) * (1 - (Chebyshev.T ℝ (m : ℤ)).comp (1 - C c * X))

/-- `q_m(t) = H_m(t) / t`, a polynomial because `H_m(0) = 0`. -/
noncomputable def qp (m : ℕ) (c : ℝ) : ℝ[X] := (Hp m c).divX

lemma Hp_eval (m : ℕ) (c t : ℝ) :
    (Hp m c).eval t = (1 - (Chebyshev.T ℝ (m : ℤ)).eval (1 - c * t)) / 2 := by
  simp only [Hp, eval_mul, eval_C, eval_sub, eval_one, eval_comp, eval_X]
  ring

lemma Hp_eval_zero (m : ℕ) (c : ℝ) : (Hp m c).eval 0 = 0 := by
  rw [Hp_eval, mul_zero, sub_zero, Chebyshev.T_eval_one, sub_self, zero_div]

lemma Hp_eq_mul (m : ℕ) (c t : ℝ) : (Hp m c).eval t = t * (qp m c).eval t := by
  have h := Polynomial.divX_mul_X_add (Hp m c)
  have h0 : (Hp m c).coeff 0 = 0 := by
    rw [Polynomial.coeff_zero_eq_eval_zero, Hp_eval_zero]
  rw [h0, C_0, add_zero] at h
  calc (Hp m c).eval t = ((Hp m c).divX * X).eval t := by rw [h]
    _ = t * (qp m c).eval t := by rw [eval_mul, eval_X, mul_comm]; rfl

lemma Hp_bounds (m : ℕ) (c t : ℝ) (h1 : 0 ≤ c * t) (h2 : c * t ≤ 2) :
    0 ≤ (Hp m c).eval t ∧ (Hp m c).eval t ≤ 1 := by
  rw [Hp_eval]
  have hT : |(Chebyshev.T ℝ (m : ℤ)).eval (1 - c * t)| ≤ 1 :=
    Chebyshev.abs_eval_T_real_le_one _ (abs_le.mpr ⟨by linarith, by linarith⟩)
  obtain ⟨hl, hu⟩ := abs_le.mp hT
  constructor <;> linarith

lemma Hp_eval_one (m : ℕ) (hm : 0 < m) :
    (Hp m (1 - Real.cos (Real.pi / (m : ℝ)))).eval 1 = 1 := by
  rw [Hp_eval]
  have hm' : (m : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hm.ne'
  have harg : ((m : ℤ) : ℝ) * (Real.pi / (m : ℝ)) = Real.pi := by
    push_cast
    field_simp
  rw [mul_one, sub_sub_cancel, Chebyshev.T_real_cos, harg, Real.cos_pi]
  norm_num

lemma qp_eval_one (m : ℕ) (hm : 0 < m) :
    (qp m (1 - Real.cos (Real.pi / (m : ℝ)))).eval 1 = 1 := by
  have h := Hp_eq_mul m (1 - Real.cos (Real.pi / (m : ℝ))) 1
  rw [Hp_eval_one m hm, one_mul] at h
  exact h.symm

lemma natDegree_Hp_le (m : ℕ) (c : ℝ) : (Hp m c).natDegree ≤ m := by
  have hL : (1 - C c * X : ℝ[X]).natDegree ≤ 1 :=
    (natDegree_sub_le _ _).trans (max_le (by simp) ((natDegree_C_mul_le c X).trans natDegree_X_le))
  have hT : (Chebyshev.T ℝ (m : ℤ)).natDegree = m := by
    rw [Chebyshev.natDegree_T]
    simp
  unfold Hp
  refine (natDegree_C_mul_le _ _).trans ?_
  refine (natDegree_sub_le _ _).trans (max_le (by simp) ?_)
  refine natDegree_comp_le.trans ?_
  rw [hT]
  calc m * (1 - C c * X : ℝ[X]).natDegree ≤ m * 1 := Nat.mul_le_mul_left m hL
    _ = m := mul_one m

lemma natDegree_qp_le (m : ℕ) (c : ℝ) : (qp m c).natDegree ≤ m - 1 := by
  unfold qp
  rw [Polynomial.natDegree_divX_eq_natDegree_tsub_one]
  exact Nat.sub_le_sub_right (natDegree_Hp_le m c) 1

/-! ## Products of coordinate laws -/

section ProdSum

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

lemma sum_prod_eq_prod_sum (F : ι → α → ℝ) :
    (∑ σ : ι → α, ∏ i, F i (σ i)) = ∏ i, ∑ s, F i s := by
  rw [Finset.prod_univ_sum, Fintype.piFinset_univ]

/-- Indicator monomial `∏_{i ∈ T} [x_i = τ_i]`. -/
noncomputable def indMono (T : Finset ι) (τ : ι → α) (x : ι → α) : ℝ :=
  ∏ i ∈ T, if x i = τ i then (1 : ℝ) else 0

/-- Interaction degree at most `d`, through indicator monomials of order at most `d`. -/
def HasProdDegreeLE (f : (ι → α) → ℝ) (d : ℕ) : Prop :=
  ∃ a : Finset ι → (ι → α) → ℝ, (∀ T, d < T.card → ∀ τ, a T τ = 0) ∧
    ∀ x, f x = ∑ T, ∑ τ, a T τ * indMono T τ x

/-- Coordinates on which two configurations differ. -/
def disagree (x y : ι → α) : Finset ι := univ.filter (fun i => x i ≠ y i)

lemma mem_disagree (x y : ι → α) (i : ι) : i ∈ disagree x y ↔ x i ≠ y i := by
  simp [disagree]

lemma sum_indMono_mul_prod (P : ι → α → ℝ) (hP : ∀ i, ∑ s, P i s = 1)
    (T : Finset ι) (τ : ι → α) :
    (∑ σ : ι → α, indMono T τ σ * ∏ i, P i (σ i)) = ∏ i ∈ T, P i (τ i) := by
  have hrow : ∀ σ : ι → α, indMono T τ σ * ∏ i, P i (σ i) =
      ∏ i, (if i ∈ T then (if σ i = τ i then (1 : ℝ) else 0) else 1) * P i (σ i) := by
    intro σ
    unfold indMono
    rw [Finset.prod_mul_distrib, Finset.prod_ite_mem, Finset.univ_inter]
  calc (∑ σ : ι → α, indMono T τ σ * ∏ i, P i (σ i))
      = ∑ σ : ι → α, ∏ i,
          (if i ∈ T then (if σ i = τ i then (1 : ℝ) else 0) else 1) * P i (σ i) :=
        Finset.sum_congr rfl fun σ _ => hrow σ
    _ = ∏ i, ∑ s, (if i ∈ T then (if s = τ i then (1 : ℝ) else 0) else 1) * P i s :=
        sum_prod_eq_prod_sum
          (fun i s => (if i ∈ T then (if s = τ i then (1 : ℝ) else 0) else 1) * P i s)
    _ = ∏ i, (if i ∈ T then P i (τ i) else 1) := by
        refine Finset.prod_congr rfl fun i _ => ?_
        by_cases hi : i ∈ T
        · simp [hi]
        · simp [hi, hP i]
    _ = ∏ i ∈ T, P i (τ i) := by
        rw [Finset.prod_ite_mem, Finset.univ_inter]

lemma sum_prod_eq_one (P : ι → α → ℝ) (hP : ∀ i, ∑ s, P i s = 1) :
    (∑ σ : ι → α, ∏ i, P i (σ i)) = 1 := by
  rw [sum_prod_eq_prod_sum, Finset.prod_congr rfl (fun i _ => hP i), Finset.prod_const_one]

lemma sum_mul_prod_delta (f : (ι → α) → ℝ) (P : ι → α → ℝ) (z : ι → α)
    (h : ∀ i s, P i s = if s = z i then 1 else 0) :
    (∑ σ : ι → α, f σ * ∏ i, P i (σ i)) = f z := by
  rw [Finset.sum_eq_single z]
  · have : ∏ i, P i (z i) = 1 := Finset.prod_eq_one fun i _ => by rw [h]; simp
    rw [this, mul_one]
  · intro σ _ hσ
    obtain ⟨i, hi⟩ : ∃ i, σ i ≠ z i := by
      by_contra hc
      push_neg at hc
      exact hσ (funext hc)
    rw [Finset.prod_eq_zero (Finset.mem_univ i) (by rw [h]; simp [hi]), mul_zero]
  · intro hz
    exact absurd (Finset.mem_univ z) hz

end ProdSum

/-! ## The competing-symbol selector -/

section Selector

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
variable {β : Type} [Fintype β] [DecidableEq β]

/-- Number of active copies containing `i` that propose symbol `s` at `i`. -/
noncomputable def cntSym (S : β → Finset ι) (y : β → ι → α) (s : α) (i : ι) (w : Cube β) : ℝ :=
  ∑ b ∈ univ.filter (fun b : β => i ∈ S b),
    (if y b i = s then (if w b then (1 : ℝ) else 0) else 0)

lemma cntSym_nonneg (S : β → Finset ι) (y : β → ι → α) (s : α) (i : ι) (w : Cube β) :
    0 ≤ cntSym S y s i w :=
  Finset.sum_nonneg fun b _ => by split_ifs <;> norm_num

lemma sum_cntSym (S : β → Finset ι) (y : β → ι → α) (i : ι) (w : Cube β) :
    ∑ s, cntSym S y s i w = cnt S i w := by
  unfold cntSym cnt
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun b _ => ?_
  simp only [Finset.sum_ite_eq, Finset.mem_univ, if_true]

lemma cntSym_le_cnt (S : β → Finset ι) (y : β → ι → α) (s : α) (i : ι) (w : Cube β) :
    cntSym S y s i w ≤ cnt S i w := by
  rw [← sum_cntSym S y i w]
  exact Finset.single_le_sum (fun s' _ => cntSym_nonneg S y s' i w) (Finset.mem_univ s)

lemma cntSym_zero (S : β → Finset ι) (y : β → ι → α) (s : α) (i : ι) :
    cntSym S y s i (Row.zero β) = 0 := by
  simp [cntSym, Row.zero]

lemma cntSym_unit (S : β → Finset ι) (y : β → ι → α) (s : α) (i : ι) (b0 : β) :
    cntSym S y s i (Row.unit b0) = if i ∈ S b0 ∧ y b0 i = s then 1 else 0 := by
  unfold cntSym
  by_cases hb : i ∈ S b0
  · rw [Finset.sum_eq_single_of_mem b0 (by simp [hb])
      (fun b _ hne => by simp [Row.unit, hne])]
    simp [Row.unit, hb]
  · rw [Finset.sum_eq_zero]
    · simp [hb]
    · intro b hbmem
      have hne : b ≠ b0 := by
        rintro rfl
        simp [hb] at hbmem
      simp [Row.unit, hne]

lemma hasDegreeLE_cntSym (S : β → Finset ι) (y : β → ι → α) (s : α) (i : ι) :
    HasDegreeLE (cntSym S y s i) 1 :=
  hasDegreeLE_congr
    (hasDegreeLE_sum (univ.filter (fun b : β => i ∈ S b))
      (fun b w => if y b i = s then (if w b then (1 : ℝ) else 0) else 0)
      (fun b _ => by
        by_cases h : y b i = s
        · exact hasDegreeLE_congr (hasDegreeLE_indicator b) (fun w => by simp [h])
        · exact hasDegreeLE_congr (hasDegreeLE_zero 1) (fun w => by simp [h])))
    (fun _ => rfl)

/-- The coordinate law `P_i(w)` on the alphabet. -/
noncomputable def Pv (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (m : ℕ) (c : ℝ)
    (i : ι) (w : Cube β) (s : α) : ℝ :=
  (if s = x i then 1 - (Hp m c).eval (cnt S i w) else 0)
    + cntSym S y s i w * (qp m c).eval (cnt S i w)

lemma Pv_sum (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (m : ℕ) (c : ℝ)
    (i : ι) (w : Cube β) : ∑ s, Pv x S y m c i w s = 1 := by
  have h1 : ∑ s, (if s = x i then 1 - (Hp m c).eval (cnt S i w) else 0)
      = 1 - (Hp m c).eval (cnt S i w) := by simp
  have h2 : ∑ s, cntSym S y s i w * (qp m c).eval (cnt S i w)
      = cnt S i w * (qp m c).eval (cnt S i w) := by
    rw [← Finset.sum_mul, sum_cntSym]
  unfold Pv
  rw [Finset.sum_add_distrib, h1, h2, Hp_eq_mul]
  ring

lemma Pv_nonneg (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (N m : ℕ) (c : ℝ)
    (hc : 0 ≤ c) (hN : ∀ i, (univ.filter fun b : β => i ∈ S b).card ≤ N)
    (hNc : (N : ℝ) * c ≤ 2) (i : ι) (w : Cube β) (s : α) : 0 ≤ Pv x S y m c i w s := by
  have h0 := cnt_nonneg S i w
  have hNle := cnt_le S N hN i w
  have hcN : c * cnt S i w ≤ 2 := by nlinarith [mul_le_mul_of_nonneg_left hNle hc]
  obtain ⟨hH0, hH1⟩ := Hp_bounds m c (cnt S i w) (mul_nonneg hc h0) hcN
  have t1 : 0 ≤ (if s = x i then 1 - (Hp m c).eval (cnt S i w) else 0) := by
    split_ifs <;> linarith
  have t2 : 0 ≤ cntSym S y s i w * (qp m c).eval (cnt S i w) := by
    rcases eq_or_lt_of_le h0 with hz | hpos
    · have hs0 : cntSym S y s i w = 0 :=
        le_antisymm ((cntSym_le_cnt S y s i w).trans hz.symm.le) (cntSym_nonneg S y s i w)
      rw [hs0, zero_mul]
    · have hq : 0 ≤ (qp m c).eval (cnt S i w) := by
        by_contra hneg
        push_neg at hneg
        have := mul_neg_of_pos_of_neg hpos hneg
        rw [← Hp_eq_mul] at this
        linarith
      exact mul_nonneg (cntSym_nonneg S y s i w) hq
  unfold Pv
  linarith

lemma hasDegreeLE_Pv (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (m : ℕ) (hm : 0 < m)
    (c : ℝ) (i : ι) (s : α) : HasDegreeLE (fun w => Pv x S y m c i w s) m := by
  have hH : HasDegreeLE (fun w => (Hp m c).eval (cnt S i w)) m :=
    hasDegreeLE_mono (natDegree_Hp_le m c) (hasDegreeLE_polyEval _ (hasDegreeLE_cnt S i))
  have hq : HasDegreeLE (fun w => (qp m c).eval (cnt S i w)) (m - 1) :=
    hasDegreeLE_mono (natDegree_qp_le m c) (hasDegreeLE_polyEval _ (hasDegreeLE_cnt S i))
  have h2 : HasDegreeLE (fun w => cntSym S y s i w * (qp m c).eval (cnt S i w)) m :=
    hasDegreeLE_mono (by omega) (hasDegreeLE_mul (hasDegreeLE_cntSym S y s i) hq)
  have h1 : HasDegreeLE
      (fun w => if s = x i then 1 - (Hp m c).eval (cnt S i w) else (0 : ℝ)) m := by
    by_cases hs : s = x i
    · exact hasDegreeLE_congr
        (hasDegreeLE_add (hasDegreeLE_const 1 m) (hasDegreeLE_const_mul (-1) hH))
        (fun w => by simp only [hs, if_true]; ring)
    · exact hasDegreeLE_congr (hasDegreeLE_zero m) (fun w => by simp only [hs, if_false])
  exact hasDegreeLE_congr (hasDegreeLE_add h1 h2) (fun _ => rfl)

lemma Pv_zero (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (m : ℕ) (c : ℝ)
    (i : ι) (s : α) : Pv x S y m c i (Row.zero β) s = if s = x i then 1 else 0 := by
  unfold Pv
  rw [cnt_zero, cntSym_zero, Hp_eval_zero]
  simp

lemma Pv_unit (x : ι → α) (y : β → ι → α) (m : ℕ) (hm : 0 < m) (b0 : β) (i : ι) (s : α) :
    Pv x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ))) i (Row.unit b0) s
      = if s = y b0 i then 1 else 0 := by
  unfold Pv
  rw [cnt_unit, cntSym_unit]
  by_cases hi : i ∈ disagree x (y b0)
  · have hne : x i ≠ y b0 i := (mem_disagree x (y b0) i).mp hi
    simp only [hi, if_true, true_and]
    rw [Hp_eval_one m hm, qp_eval_one m hm]
    by_cases hs : s = y b0 i
    · subst hs
      simp [Ne.symm hne]
    · have hs' : y b0 i ≠ s := fun h => hs h.symm
      simp [hs, hs']
  · have heq : x i = y b0 i := by
      by_contra hne
      exact hi ((mem_disagree x (y b0) i).mpr hne)
    simp [hi, Hp_eval_zero, heq]

/-- The selector polynomial. -/
noncomputable def Gsel (f : (ι → α) → ℝ) (x : ι → α) (S : β → Finset ι) (y : β → ι → α)
    (m : ℕ) (c : ℝ) (w : Cube β) : ℝ :=
  ∑ σ : ι → α, f σ * ∏ i, Pv x S y m c i w (σ i)

lemma Gsel_expand (f : (ι → α) → ℝ) (a : Finset ι → (ι → α) → ℝ)
    (ha : ∀ x, f x = ∑ T, ∑ τ, a T τ * indMono T τ x)
    (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (m : ℕ) (c : ℝ) (w : Cube β) :
    Gsel f x S y m c w = ∑ T, ∑ τ, a T τ * ∏ i ∈ T, Pv x S y m c i w (τ i) := by
  have hP : ∀ i, ∑ s, Pv x S y m c i w s = 1 := fun i => Pv_sum x S y m c i w
  unfold Gsel
  calc (∑ σ : ι → α, f σ * ∏ i, Pv x S y m c i w (σ i))
      = ∑ σ : ι → α, ∑ T, ∑ τ, a T τ * (indMono T τ σ * ∏ i, Pv x S y m c i w (σ i)) := by
        refine Finset.sum_congr rfl fun σ _ => ?_
        rw [ha σ, Finset.sum_mul]
        refine Finset.sum_congr rfl fun T _ => ?_
        rw [Finset.sum_mul]
        refine Finset.sum_congr rfl fun τ _ => ?_
        ring
    _ = ∑ T, ∑ σ : ι → α, ∑ τ, a T τ * (indMono T τ σ * ∏ i, Pv x S y m c i w (σ i)) :=
        Finset.sum_comm
    _ = ∑ T, ∑ τ, ∑ σ : ι → α, a T τ * (indMono T τ σ * ∏ i, Pv x S y m c i w (σ i)) :=
        Finset.sum_congr rfl fun T _ => Finset.sum_comm
    _ = ∑ T, ∑ τ, a T τ * ∏ i ∈ T, Pv x S y m c i w (τ i) := by
        refine Finset.sum_congr rfl fun T _ => Finset.sum_congr rfl fun τ _ => ?_
        rw [← Finset.mul_sum]
        exact congrArg (fun z => a T τ * z)
          (sum_indMono_mul_prod (fun i s => Pv x S y m c i w s) hP T τ)

lemma hasDegreeLE_Gsel (d : ℕ) (f : (ι → α) → ℝ) (hd : HasProdDegreeLE f d)
    (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (m : ℕ) (hm : 0 < m) (c : ℝ) :
    HasDegreeLE (Gsel f x S y m c) (d * m) := by
  obtain ⟨a, ha0, ha⟩ := hd
  have key : HasDegreeLE (fun w => ∑ T ∈ (univ : Finset (Finset ι)),
      ∑ τ ∈ (univ : Finset (ι → α)), a T τ * ∏ i ∈ T, Pv x S y m c i w (τ i)) (d * m) := by
    apply hasDegreeLE_sum
    intro T _
    apply hasDegreeLE_sum
    intro τ _
    by_cases hT : T.card ≤ d
    · refine hasDegreeLE_const_mul _ (hasDegreeLE_mono (Nat.mul_le_mul_right m hT) ?_)
      exact hasDegreeLE_prod T (fun i w => Pv x S y m c i w (τ i))
        (fun i _ => hasDegreeLE_Pv x S y m hm c i (τ i))
    · exact hasDegreeLE_congr (hasDegreeLE_zero _)
        (fun w => by simp [ha0 T (not_le.mp hT) τ])
  exact hasDegreeLE_congr key (fun w => Gsel_expand f a ha x S y m c w)

lemma abs_Gsel_le_one (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (x : ι → α) (S : β → Finset ι) (y : β → ι → α) (N m : ℕ) (c : ℝ) (hc : 0 ≤ c)
    (hN : ∀ i, (univ.filter fun b : β => i ∈ S b).card ≤ N) (hNc : (N : ℝ) * c ≤ 2)
    (w : Cube β) : |Gsel f x S y m c w| ≤ 1 := by
  have hW : ∀ σ : ι → α, 0 ≤ ∏ i, Pv x S y m c i w (σ i) := fun σ =>
    Finset.prod_nonneg fun i _ => Pv_nonneg x S y N m c hc hN hNc i w (σ i)
  have hsum : (∑ σ : ι → α, ∏ i, Pv x S y m c i w (σ i)) = 1 :=
    sum_prod_eq_one (fun i s => Pv x S y m c i w s) (fun i => Pv_sum x S y m c i w)
  unfold Gsel
  calc |∑ σ : ι → α, f σ * ∏ i, Pv x S y m c i w (σ i)|
      ≤ ∑ σ : ι → α, |f σ * ∏ i, Pv x S y m c i w (σ i)| := Finset.abs_sum_le_sum_abs _ _
    _ = ∑ σ : ι → α, |f σ| * ∏ i, Pv x S y m c i w (σ i) := by
        refine Finset.sum_congr rfl fun σ _ => ?_
        rw [abs_mul, abs_of_nonneg (hW σ)]
    _ ≤ ∑ σ : ι → α, 1 * ∏ i, Pv x S y m c i w (σ i) :=
        Finset.sum_le_sum fun σ _ => mul_le_mul_of_nonneg_right (hf σ) (hW σ)
    _ = 1 := by simp only [one_mul]; exact hsum

/-- **Product block inequality** with competing replacement symbols. -/
theorem product_block_inequality (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α) (y : β → ι → α) (N m : ℕ) (hm : 0 < m)
    (hN : ∀ i, (univ.filter fun b : β => i ∈ disagree x (y b)).card ≤ N)
    (hNc : (N : ℝ) * (1 - Real.cos (Real.pi / (m : ℝ))) ≤ 2) :
    ∑ b, |f x - f (y b)| ≤ 4 * (d : ℝ) ^ 2 * (m : ℝ) ^ 2 := by
  have hc : 0 ≤ 1 - Real.cos (Real.pi / (m : ℝ)) := sub_nonneg.mpr (Real.cos_le_one _)
  have hG := abs_Gsel_le_one f hf x (fun b => disagree x (y b)) y N m _ hc hN hNc
  have hdeg := hasDegreeLE_Gsel d f hd x (fun b => disagree x (y b)) y m hm
    (1 - Real.cos (Real.pi / (m : ℝ)))
  have key := sum_abs_sub_unit_le markovEndpoint _ (d * m) hG hdeg
  have hz : Gsel f x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ)))
      (Row.zero β) = f x :=
    sum_mul_prod_delta f
      (fun i s => Pv x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ))) i
        (Row.zero β) s) x
      (fun i s => Pv_zero x _ y m _ i s)
  have hu : ∀ b0, Gsel f x (fun b => disagree x (y b)) y m
      (1 - Real.cos (Real.pi / (m : ℝ))) (Row.unit b0) = f (y b0) := fun b0 =>
    sum_mul_prod_delta f
      (fun i s => Pv x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ))) i
        (Row.unit b0) s) (y b0)
      (fun i s => Pv_unit x y m hm b0 i s)
  calc ∑ b, |f x - f (y b)|
      = ∑ b, |Gsel f x (fun b => disagree x (y b)) y m (1 - Real.cos (Real.pi / (m : ℝ)))
            (Row.zero β) - Gsel f x (fun b => disagree x (y b)) y m
            (1 - Real.cos (Real.pi / (m : ℝ))) (Row.unit b)| := by
        refine Finset.sum_congr rfl fun b _ => ?_
        rw [hz, hu b]
    _ ≤ 4 * ((d * m : ℕ) : ℝ) ^ 2 := key
    _ = 4 * (d : ℝ) ^ 2 * (m : ℝ) ^ 2 := by push_cast; ring

end Selector

/-! ## Packing bound, duality and the row bound -/

section RowBound

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

lemma exists_sel (f : (ι → α) → ℝ) (x : ι → α) (S : Finset ι) :
    ∃ z : ι → α, disagree x z ⊆ S ∧
      ∀ y, disagree x y = S → |f x - f y| ≤ |f x - f z| := by
  by_cases h : (univ.filter fun y : ι → α => disagree x y = S).Nonempty
  · obtain ⟨z, hz, hmax⟩ := Finset.exists_max_image _ (fun y => |f x - f y|) h
    exact ⟨z, le_of_eq (Finset.mem_filter.mp hz).2, fun y hy => hmax y (by simp [hy])⟩
  · refine ⟨x, ?_, fun y hy => absurd ⟨y, by simp [hy]⟩ h⟩
    intro i hi
    exact absurd rfl ((mem_disagree x x i).mp hi)

/-- A maximizing replacement for each disagreement set. -/
noncomputable def ysel (f : (ι → α) → ℝ) (x : ι → α) (S : Finset ι) : ι → α :=
  (exists_sel f x S).choose

lemma ysel_sub (f : (ι → α) → ℝ) (x : ι → α) (S : Finset ι) :
    disagree x (ysel f x S) ⊆ S := (exists_sel f x S).choose_spec.1

lemma ysel_max (f : (ι → α) → ℝ) (x : ι → α) (y : ι → α) :
    |f x - f y| ≤ |f x - f (ysel f x (disagree x y))| :=
  (exists_sel f x (disagree x y)).choose_spec.2 y rfl

lemma ysel_empty (f : (ι → α) → ℝ) (x : ι → α) : ysel f x ∅ = x := by
  funext i
  have h := ysel_sub f x ∅
  by_contra hne
  have hi : i ∈ disagree x (ysel f x ∅) := (mem_disagree _ _ i).mpr (fun h' => hne h'.symm)
  exact absurd (h hi) (Finset.notMem_empty i)

/-- The packing bound before the limit (product version of `Pack.scaled_bound`). -/
theorem product_scaled_bound (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α)
    (κ : Finset ι → ℝ) (hκ : ∀ S, 0 ≤ κ S)
    (hpack : ∀ i, ∑ S ∈ univ.filter (fun S : Finset ι => i ∈ S), κ S ≤ 1)
    (M : ℕ) (hM : 0 < M) :
    (M : ℝ) ^ 2 * ∑ S, κ S * |f x - f (ysel f x S)|
      ≤ (d : ℝ) ^ 2 * (Real.pi * (M : ℝ) + 2) ^ 2 + ∑ S, |f x - f (ysel f x S)| := by
  let k : Finset ι → ℕ := fun S => ⌊((M ^ 2 : ℕ) : ℝ) * κ S⌋₊
  have hN : ∀ i, (univ.filter fun b : (Σ S : Finset ι, Fin (k S)) =>
      i ∈ disagree x (ysel f x b.1)).card ≤ M ^ 2 := by
    intro i
    refine le_trans (Finset.card_le_card ?_) (Pack.card_blocks_le κ hκ hpack (M ^ 2) i)
    intro b hb
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hb ⊢
    exact ysel_sub f x b.1 hb
  have hblock : ∑ b : (Σ S : Finset ι, Fin (k S)), |f x - f (ysel f x b.1)|
      ≤ 4 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2 :=
    product_block_inequality d f hf hd x
    (fun b : (Σ S : Finset ι, Fin (k S)) => ysel f x b.1) (M ^ 2)
    ⌈Real.pi * (M : ℝ) / 2⌉₊ (Pack.gate_pos M hM) hN (Pack.gate_cos M hM)
  have hsum : (∑ b : (Σ S : Finset ι, Fin (k S)), |f x - f (ysel f x b.1)|)
      = ∑ S, (k S : ℝ) * |f x - f (ysel f x S)| :=
    Pack.sum_blocks k (fun S => |f x - f (ysel f x S)|)
  rw [hsum] at hblock
  have hcast : ((M ^ 2 : ℕ) : ℝ) = (M : ℝ) ^ 2 := by push_cast; ring
  have hd2 : (0 : ℝ) ≤ (d : ℝ) ^ 2 := sq_nonneg _
  have hright : 4 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2
      ≤ (d : ℝ) ^ 2 * (Real.pi * (M : ℝ) + 2) ^ 2 := by
    calc 4 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2
        = (d : ℝ) ^ 2 * (4 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2) := by ring
      _ ≤ (d : ℝ) ^ 2 * (Real.pi * (M : ℝ) + 2) ^ 2 :=
          mul_le_mul_of_nonneg_left (Pack.gate_sq M) hd2
  have hterm : ∀ S : Finset ι, (M : ℝ) ^ 2 * (κ S * |f x - f (ysel f x S)|)
      ≤ (k S : ℝ) * |f x - f (ysel f x S)| + |f x - f (ysel f x S)| := by
    intro S
    have hlt : ((M ^ 2 : ℕ) : ℝ) * κ S < (k S : ℝ) + 1 := Nat.lt_floor_add_one _
    have habs : (0 : ℝ) ≤ |f x - f (ysel f x S)| := abs_nonneg _
    calc (M : ℝ) ^ 2 * (κ S * |f x - f (ysel f x S)|)
        = (((M ^ 2 : ℕ) : ℝ) * κ S) * |f x - f (ysel f x S)| := by rw [hcast]; ring
      _ ≤ ((k S : ℝ) + 1) * |f x - f (ysel f x S)| :=
          mul_le_mul_of_nonneg_right hlt.le habs
      _ = (k S : ℝ) * |f x - f (ysel f x S)| + |f x - f (ysel f x S)| := by ring
  calc (M : ℝ) ^ 2 * ∑ S, κ S * |f x - f (ysel f x S)|
      = ∑ S, (M : ℝ) ^ 2 * (κ S * |f x - f (ysel f x S)|) := by rw [Finset.mul_sum]
    _ ≤ ∑ S, ((k S : ℝ) * |f x - f (ysel f x S)| + |f x - f (ysel f x S)|) :=
        Finset.sum_le_sum fun S _ => hterm S
    _ = ∑ S, (k S : ℝ) * |f x - f (ysel f x S)| + ∑ S, |f x - f (ysel f x S)| :=
        Finset.sum_add_distrib
    _ ≤ (d : ℝ) ^ 2 * (Real.pi * (M : ℝ) + 2) ^ 2 + ∑ S, |f x - f (ysel f x S)| := by
        have h4 : ∑ S, (k S : ℝ) * |f x - f (ysel f x S)|
            ≤ 4 * (d : ℝ) ^ 2 * (((⌈Real.pi * (M : ℝ) / 2⌉₊ : ℕ) : ℝ)) ^ 2 := hblock
        linarith

/-- **Packing bound on finite product spaces.** -/
theorem product_packing_bound (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α)
    (κ : Finset ι → ℝ) (hκ : ∀ S, 0 ≤ κ S)
    (hpack : ∀ i, ∑ S ∈ univ.filter (fun S : Finset ι => i ∈ S), κ S ≤ 1) :
    ∑ S, κ S * |f x - f (ysel f x S)| ≤ Real.pi ^ 2 * (d : ℝ) ^ 2 :=
  Pack.le_of_scaled _ (∑ S, |f x - f (ysel f x S)|) d
    (fun M hM => product_scaled_bound d f hf hd x κ hκ hpack M hM)

/-- **Lemma B on finite product spaces**: a bounded function of interaction degree at most `d`
has, at every point, a fractional-certificate row of cost at most `π² d²`. -/
theorem product_row_bound (d : ℕ) (f : (ι → α) → ℝ) (hf : ∀ x, |f x| ≤ 1)
    (hd : HasProdDegreeLE f d) (x : ι → α) :
    ∃ a : ι → ℝ, (∀ i, 0 ≤ a i) ∧ ∑ i, a i ≤ Real.pi ^ 2 * (d : ℝ) ^ 2 ∧
      ∀ y, |f x - f y| ≤ ∑ i ∈ disagree x y, a i := by
  have hK : 0 ≤ Real.pi ^ 2 * (d : ℝ) ^ 2 := by positivity
  have ht0 : |f x - f (ysel f x ∅)| ≤ 0 := by rw [ysel_empty, sub_self, abs_zero]
  obtain ⟨a, ha0, hasum, hcov⟩ := coverDuality ι (fun S => |f x - f (ysel f x S)|)
    (Real.pi ^ 2 * (d : ℝ) ^ 2) hK ht0
    (fun κ hκ hpack => product_packing_bound d f hf hd x κ hκ hpack)
  exact ⟨a, ha0, hasum, fun y => (ysel_max f x y).trans (hcov (disagree x y))⟩

end RowBound

end Nightfall.ProductSpace.RowBound
