import Route1PolylogTools

/-!
# Route 1: the entropy potential and the M-free information charge

For unnormalized posterior weights `v`, `Ent v = ∑_θ negMulLog (v θ) − negMulLog (∑ v)` is the total
weight times the entropy of the posterior. Querying coordinate `j` lowers it by exactly
`∑_θ v_θ KL(P_θ j ‖ q_j)` (`ent_children`), where `q_j` is the posterior mixture marginal, and

    KL(p ‖ q) ≥ ∑ (√p − √q)² ≥ tvd(p, q)²                       (`kl_ge_tvd_sq`)

so the drop is at least `∑_θ v_θ tvd(P_θ j, q_j)²` (`ent_drop_ge`). At the root (`∑ w = 1`),
`Ent w ≤ log M` (`ent_le_log_card`). No Pinsker inequality is needed.
-/

namespace Nightfall.Route1Polylog

open Finset Real
open Nightfall.ProductSpace.Mixture

section KL

variable {α : Type} [Fintype α] [DecidableEq α]

/-- `∑ p (log p − log q)`; terms with `p = 0` vanish. -/
noncomputable def kl (p q : α → ℝ) : ℝ := ∑ b, p b * (Real.log (p b) - Real.log (q b))

theorem term_ge (p q : ℝ) (hp : 0 ≤ p) (hq : 0 ≤ q) (hpq : 0 < p → 0 < q) :
    2 * p - 2 * Real.sqrt (p * q) ≤ p * (Real.log p - Real.log q) := by
  rcases hp.eq_or_lt with h0 | hpos
  · subst h0; simp
  · have hqpos := hpq hpos
    set t := Real.sqrt (q / p) with ht
    have htpos : 0 < t := Real.sqrt_pos.mpr (div_pos hqpos hpos)
    have hlog : Real.log t ≤ t - 1 := Real.log_le_sub_one_of_pos htpos
    have hlt : Real.log (q / p) = 2 * Real.log t := by
      rw [ht, Real.log_sqrt (div_nonneg hq hp)]; ring
    have hsq : Real.sqrt (p * q) = p * t := by
      have hs : Real.sqrt p ^ 2 = p := Real.sq_sqrt hp
      have hne : Real.sqrt p ≠ 0 := (Real.sqrt_pos.mpr hpos).ne'
      rw [ht, Real.sqrt_mul hp, Real.sqrt_div hq, mul_div_assoc', eq_div_iff hne]
      nth_rewrite 3 [← hs]; ring
    have hdiff : Real.log p - Real.log q = - Real.log (q / p) := by
      rw [Real.log_div hqpos.ne' hpos.ne']; ring
    rw [hdiff, hlt, hsq]
    nlinarith

theorem hell_le_kl (p q : α → ℝ) (hp0 : ∀ b, 0 ≤ p b) (hq0 : ∀ b, 0 ≤ q b)
    (hp1 : ∑ b, p b = 1) (hq1 : ∑ b, q b = 1) (hpq : ∀ b, 0 < p b → 0 < q b) :
    ∑ b, (Real.sqrt (p b) - Real.sqrt (q b)) ^ 2 ≤ kl p q := by
  have hexp : ∀ b, (Real.sqrt (p b) - Real.sqrt (q b)) ^ 2 =
      p b + q b - 2 * Real.sqrt (p b * q b) := by
    intro b
    rw [sub_sq, Real.sq_sqrt (hp0 b), Real.sq_sqrt (hq0 b), Real.sqrt_mul (hp0 b)]; ring
  rw [Finset.sum_congr rfl fun b _ => hexp b]
  unfold kl
  have h2 : ∑ b, (p b + q b - 2 * Real.sqrt (p b * q b)) =
      ∑ b, (2 * p b - 2 * Real.sqrt (p b * q b)) := by
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum,
      ← Finset.mul_sum]; rw [hp1, hq1]; ring
  rw [h2]
  exact Finset.sum_le_sum fun b _ => term_ge (p b) (q b) (hp0 b) (hq0 b) (hpq b)

theorem tvd_sq_le_hell (p q : α → ℝ) (hp0 : ∀ b, 0 ≤ p b) (hq0 : ∀ b, 0 ≤ q b)
    (hp1 : ∑ b, p b = 1) (hq1 : ∑ b, q b = 1) :
    tvd p q ^ 2 ≤ ∑ b, (Real.sqrt (p b) - Real.sqrt (q b)) ^ 2 := by
  have hl1 := l1_eq_two_tvd p q hp1 hq1
  have hfac : ∀ b, |p b - q b| = |Real.sqrt (p b) - Real.sqrt (q b)| *
      (Real.sqrt (p b) + Real.sqrt (q b)) := by
    intro b
    have h1 : p b - q b = (Real.sqrt (p b) - Real.sqrt (q b)) *
        (Real.sqrt (p b) + Real.sqrt (q b)) := by
      have := Real.sq_sqrt (hp0 b); have := Real.sq_sqrt (hq0 b); nlinarith
    rw [h1, abs_mul, abs_of_nonneg (add_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))]
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq univ
    (fun b => |Real.sqrt (p b) - Real.sqrt (q b)|) (fun b => Real.sqrt (p b) + Real.sqrt (q b))
  have hsum2 : ∑ b, (Real.sqrt (p b) + Real.sqrt (q b)) ^ 2 ≤ 4 := by
    have : ∀ b, (Real.sqrt (p b) + Real.sqrt (q b)) ^ 2 ≤ 2 * (p b + q b) := by
      intro b
      have := Real.sq_sqrt (hp0 b); have := Real.sq_sqrt (hq0 b)
      nlinarith [sq_nonneg (Real.sqrt (p b) - Real.sqrt (q b))]
    calc ∑ b, (Real.sqrt (p b) + Real.sqrt (q b)) ^ 2 ≤ ∑ b, 2 * (p b + q b) :=
          Finset.sum_le_sum fun b _ => this b
      _ = 4 := by rw [← Finset.mul_sum, Finset.sum_add_distrib, hp1, hq1]; norm_num
  have hL : ∑ b, |p b - q b| = ∑ b, |Real.sqrt (p b) - Real.sqrt (q b)| *
      (Real.sqrt (p b) + Real.sqrt (q b)) := Finset.sum_congr rfl fun b _ => hfac b
  simp only [sq_abs] at hcs
  have hH0 : 0 ≤ ∑ b, (Real.sqrt (p b) - Real.sqrt (q b)) ^ 2 :=
    Finset.sum_nonneg fun b _ => sq_nonneg _
  have : (2 * tvd p q) ^ 2 ≤ (∑ b, (Real.sqrt (p b) - Real.sqrt (q b)) ^ 2) * 4 := by
    rw [← hl1, hL]
    exact hcs.trans (mul_le_mul_of_nonneg_left hsum2 hH0)
  nlinarith

theorem kl_ge_tvd_sq (p q : α → ℝ) (hp0 : ∀ b, 0 ≤ p b) (hq0 : ∀ b, 0 ≤ q b)
    (hp1 : ∑ b, p b = 1) (hq1 : ∑ b, q b = 1) (hpq : ∀ b, 0 < p b → 0 < q b) :
    tvd p q ^ 2 ≤ kl p q :=
  (tvd_sq_le_hell p q hp0 hq0 hp1 hq1).trans (hell_le_kl p q hp0 hq0 hp1 hq1 hpq)

end KL

section Ent

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]
variable {Θ : Type} [Fintype Θ]
variable (P : Θ → ι → α → ℝ)

/-- Total weight times the posterior entropy. -/
noncomputable def Ent (v : Θ → ℝ) : ℝ := ∑ θ, negMulLog (v θ) - negMulLog (Vs v)

/-- Posterior mixture marginal of coordinate `j`. -/
noncomputable def qmix (v : Θ → ℝ) (j : ι) (b : α) : ℝ := (∑ θ, v θ * P θ j b) / Vs v

theorem ent_nonneg (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) : 0 ≤ Ent v := by
  unfold Ent Vs
  have hV : 0 ≤ ∑ θ, v θ := Finset.sum_nonneg fun θ _ => hv θ
  have h : negMulLog (∑ θ, v θ) = ∑ θ, - v θ * Real.log (∑ θ', v θ') := by
    unfold negMulLog; rw [← Finset.sum_mul, Finset.sum_neg_distrib]
  rw [h, ← Finset.sum_sub_distrib]
  refine Finset.sum_nonneg fun θ _ => ?_
  unfold negMulLog
  rcases (hv θ).eq_or_lt with h0 | hpos
  · rw [← h0]; simp
  · have hle : v θ ≤ ∑ θ', v θ' := Finset.single_le_sum (fun θ' _ => hv θ') (mem_univ θ)
    have := Real.log_le_log hpos hle
    nlinarith

theorem ent_le_log_card [Nonempty Θ] (w : Θ → ℝ) (hw : ∀ θ, 0 ≤ w θ) (hw1 : ∑ θ, w θ = 1) :
    Ent w ≤ Real.log (Fintype.card Θ) := by
  unfold Ent Vs
  rw [hw1, negMulLog_one, sub_zero]
  have hM : (0 : ℝ) < Fintype.card Θ := Nat.cast_pos.mpr Fintype.card_pos
  have hcon := Real.concaveOn_negMulLog.le_map_sum (t := univ)
    (w := fun _ => 1 / (Fintype.card Θ : ℝ)) (p := w) (fun _ _ => by positivity)
    (by rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; field_simp) (fun θ _ => hw θ)
  simp only [smul_eq_mul] at hcon
  rw [← Finset.mul_sum, ← Finset.mul_sum, hw1, mul_one] at hcon
  have hval : negMulLog (1 / (Fintype.card Θ : ℝ)) =
      Real.log (Fintype.card Θ) / Fintype.card Θ := by
    unfold negMulLog; rw [one_div, Real.log_inv]; field_simp
  rw [hval, one_div_mul_eq_div] at hcon
  exact (div_le_div_iff_of_pos_right hM).mp hcon

variable (hP0 : ∀ θ i a, 0 ≤ P θ i a) (hP1 : ∀ θ i, ∑ a, P θ i a = 1)

include hP1 in
theorem qmix_sum (v : Θ → ℝ) (hV : 0 < Vs v) (j : ι) : ∑ b, qmix P v j b = 1 := by
  unfold qmix
  rw [← Finset.sum_div, Finset.sum_comm]
  simp only [← Finset.mul_sum, hP1, mul_one]
  exact div_self hV.ne'

include hP0 in
theorem qmix_nonneg (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (j : ι) (b : α) : 0 ≤ qmix P v j b := by
  unfold qmix
  exact div_nonneg (Finset.sum_nonneg fun θ _ => mul_nonneg (hv θ) (hP0 θ j b))
    (Finset.sum_nonneg fun θ _ => hv θ)

include hP0 hP1 in
/-- **Entropy drop identity.** -/
theorem ent_children (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v) (j : ι) :
    ∑ b, Ent (upd P v j b) = Ent v - ∑ θ, v θ * kl (P θ j) (qmix P v j) := by
  have hVb : ∀ b, Vs (upd P v j b) = Vs v * qmix P v j b := by
    intro b; unfold Vs upd qmix; field_simp; rfl
  unfold Ent
  simp only [hVb, Real.negMulLog_mul]
  rw [Finset.sum_sub_distrib]
  have h1 : ∑ b, ∑ θ, negMulLog (upd P v j b θ) =
      ∑ θ, negMulLog (v θ) + ∑ θ, v θ * ∑ b, negMulLog (P θ j b) := by
    unfold upd
    rw [Finset.sum_comm]
    simp only [Real.negMulLog_mul]
    rw [← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun θ _ => ?_
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, hP1 θ j, one_mul, Finset.mul_sum]
  have h2 : ∑ b, (qmix P v j b * negMulLog (Vs v) + Vs v * negMulLog (qmix P v j b)) =
      negMulLog (Vs v) + Vs v * ∑ b, negMulLog (qmix P v j b) := by
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, qmix_sum P hP1 v hV j, one_mul, Finset.mul_sum]
  rw [h1, h2]
  -- `Vs · H(q) = ∑_θ v_θ ∑_b P (−log q)`
  have h3 : Vs v * ∑ b, negMulLog (qmix P v j b) =
      ∑ θ, v θ * ∑ b, P θ j b * (- Real.log (qmix P v j b)) := by
    unfold negMulLog
    rw [Finset.mul_sum]
    have : ∀ b, Vs v * (-qmix P v j b * Real.log (qmix P v j b)) =
        ∑ θ, v θ * (P θ j b * (- Real.log (qmix P v j b))) := by
      intro b
      generalize Real.log (qmix P v j b) = L
      unfold qmix
      have hne : Vs v ≠ 0 := hV.ne'
      have e1 : Vs v * (-((∑ θ, v θ * P θ j b) / Vs v) * L) = -(∑ θ, v θ * P θ j b) * L := by
        field_simp
      rw [e1, neg_mul, Finset.sum_mul, ← Finset.sum_neg_distrib]
      exact Finset.sum_congr rfl fun θ _ => by ring
    rw [Finset.sum_congr rfl fun b _ => this b, Finset.sum_comm]
    exact Finset.sum_congr rfl fun θ _ => by rw [Finset.mul_sum]
  rw [h3]
  have h4 : ∑ θ, v θ * kl (P θ j) (qmix P v j) = ∑ θ, v θ * ∑ b, P θ j b * (- Real.log (qmix P v j b))
      - ∑ θ, v θ * ∑ b, negMulLog (P θ j b) := by
    rw [← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun θ _ => ?_
    unfold kl negMulLog
    rw [← mul_sub, ← Finset.sum_sub_distrib]
    congr 1
    exact Finset.sum_congr rfl fun b _ => by ring
  rw [h4]
  ring

include hP0 hP1 in
/-- **Information charge.** Querying `j` lowers `Ent` by at least `∑_θ v_θ tvd(P_θ j, q_j)²`. -/
theorem ent_drop_ge (v : Θ → ℝ) (hv : ∀ θ, 0 ≤ v θ) (hV : 0 < Vs v) (j : ι) :
    ∑ θ, v θ * tvd (P θ j) (qmix P v j) ^ 2 ≤ Ent v - ∑ b, Ent (upd P v j b) := by
  rw [ent_children P hP0 hP1 v hv hV j, sub_sub_cancel]
  refine Finset.sum_le_sum fun θ _ => ?_
  rcases (hv θ).eq_or_lt with h0 | hpos
  · rw [← h0]; simp
  · refine mul_le_mul_of_nonneg_left ?_ (hv θ)
    refine kl_ge_tvd_sq _ _ (hP0 θ j) (qmix_nonneg P hP0 v hv j) (hP1 θ j)
      (qmix_sum P hP1 v hV j) fun b hb => ?_
    unfold qmix
    refine div_pos ?_ hV
    exact lt_of_lt_of_le (mul_pos hpos hb)
      (Finset.single_le_sum (fun θ' _ => mul_nonneg (hv θ') (hP0 θ' j b)) (mem_univ θ))

end Ent

end Nightfall.Route1Polylog

#print axioms Nightfall.Route1Polylog.kl_ge_tvd_sq
#print axioms Nightfall.Route1Polylog.ent_children
#print axioms Nightfall.Route1Polylog.ent_drop_ge
#print axioms Nightfall.Route1Polylog.ent_le_log_card
