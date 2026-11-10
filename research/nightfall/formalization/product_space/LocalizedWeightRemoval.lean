import Mathlib

/-!
# Localized weight removal (Certificate Engine v2, Lemma 4.1) — complete form

NIGHTFALL product-space programme. This file formalizes, for arbitrary finite
index types and *nonnegative* (possibly zero) coefficients:

1. `reg_weight_mul_le`, `div_reg_weight_le`: the ε-regularized weight bounds.
2. `le_of_forall_reg`: the ε → 0 limit, by an explicit ε–δ argument.
3. `localized_weight_optimization`: if `V² ≤ (∑ wᵢAᵢ)(∑ βᵢ/wᵢ)` for every positive `w`,
   then `V ≤ ∑ √βᵢ √Aᵢ`. This removes the strict-positivity hypotheses of
   `localized_weight_optimization_positive` (PR #289).
4. `cs_reciprocal`, `cs_reciprocal2`: Cauchy–Schwarz with reciprocal weights.
5. `localized_weight_removal`: the full lemma. If for every positive `w` the pair sums
   `s_xy(w) = ∑_{j ∈ J x y} wⱼ λₓⱼ γᵧⱼ` are positive and `∑ₓ ∑ᵧ s_xy(w)⁻¹ ≤ ∑ⱼ cⱼ / wⱼ`, then
   `(∑ₓ ‖λₓ‖⁻¹)(∑ᵧ ‖γᵧ‖⁻¹) ≤ ∑ⱼ √cⱼ · √(Xⱼ Yⱼ)`.
6. `weight_removal_max`: Turturean's form (Lemma 5.3 of arXiv:2611.09773), recovered:
   `(∑ₓ ‖λₓ‖⁻¹)(∑ᵧ ‖γᵧ‖⁻¹) ≤ M` whenever every `cⱼ ≤ M`.

The probabilistic input (the all-pairs inequality on product spaces, Theorem 1.2) is
NOT formalized here. Combined with it, item 5 is the localized two-sided inequality.
No `sorry`, no custom axioms.
-/

namespace Nightfall.ProductSpace

open Finset

/-! ## 1. Regularized weights -/

lemma reg_weight_pos {b a ε : ℝ} (hε : 0 < ε) :
    0 < (Real.sqrt b + ε) / (Real.sqrt a + ε) :=
  div_pos (add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε)
    (add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε)

lemma reg_weight_mul_le {b a ε : ℝ} (ha : 0 ≤ a) (hε : 0 < ε) :
    (Real.sqrt b + ε) / (Real.sqrt a + ε) * a ≤ (Real.sqrt b + ε) * Real.sqrt a := by
  have hA : 0 < Real.sqrt a + ε := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε
  have hB : 0 ≤ Real.sqrt b + ε := add_nonneg (Real.sqrt_nonneg _) hε.le
  have hsa : 0 ≤ Real.sqrt a := Real.sqrt_nonneg _
  have hs : Real.sqrt a * Real.sqrt a = a := Real.mul_self_sqrt ha
  rw [div_mul_eq_mul_div, div_le_iff₀ hA]
  calc (Real.sqrt b + ε) * a
      = (Real.sqrt b + ε) * Real.sqrt a * Real.sqrt a := by rw [mul_assoc, hs]
    _ ≤ (Real.sqrt b + ε) * Real.sqrt a * (Real.sqrt a + ε) :=
        mul_le_mul_of_nonneg_left (by linarith) (mul_nonneg hB hsa)

lemma div_reg_weight_le {b a ε : ℝ} (hb : 0 ≤ b) (hε : 0 < ε) :
    b / ((Real.sqrt b + ε) / (Real.sqrt a + ε)) ≤ Real.sqrt b * (Real.sqrt a + ε) := by
  have hA : 0 < Real.sqrt a + ε := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε
  have hB : 0 < Real.sqrt b + ε := add_pos_of_nonneg_of_pos (Real.sqrt_nonneg _) hε
  have hsb : 0 ≤ Real.sqrt b := Real.sqrt_nonneg _
  have hs : Real.sqrt b * Real.sqrt b = b := Real.mul_self_sqrt hb
  rw [div_div_eq_mul_div, div_le_iff₀ hB]
  calc b * (Real.sqrt a + ε)
      = Real.sqrt b * Real.sqrt b * (Real.sqrt a + ε) := by rw [hs]
    _ = Real.sqrt b * (Real.sqrt a + ε) * Real.sqrt b := by ring
    _ ≤ Real.sqrt b * (Real.sqrt a + ε) * (Real.sqrt b + ε) :=
        mul_le_mul_of_nonneg_left (by linarith) (mul_nonneg hsb hA.le)

/-! ## 2. The limit ε → 0 -/

lemma le_of_forall_reg (V S a b : ℝ) (hS : 0 ≤ S) (ha : 0 ≤ a) (hb : 0 ≤ b)
    (key : ∀ ε : ℝ, 0 < ε → V ^ 2 ≤ (S + ε * a) * (S + ε * b)) : V ≤ S := by
  by_contra hlt
  push_neg at hlt
  have hVS : 0 < V + S := by linarith
  have hgap : 0 < V ^ 2 - S ^ 2 := by nlinarith [mul_pos (sub_pos.2 hlt) hVS]
  have hC : 0 ≤ a * S + b * S + a * b := by
    have h1 := mul_nonneg ha hS
    have h2 := mul_nonneg hb hS
    have h3 := mul_nonneg ha hb
    linarith
  have hpos : 0 < 2 * (a * S + b * S + a * b + 1) := by linarith
  obtain ⟨ε, hεdef⟩ : ∃ ε, ε = min 1 ((V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1))) :=
    ⟨_, rfl⟩
  have hε : 0 < ε := by rw [hεdef]; exact lt_min one_pos (div_pos hgap hpos)
  have hε1 : ε ≤ 1 := by rw [hεdef]; exact min_le_left _ _
  have hε2 : ε ≤ (V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1)) := by
    rw [hεdef]; exact min_le_right _ _
  have hk := key ε hε
  have hsq : ε ^ 2 * (a * b) ≤ ε * (a * b) := by
    refine mul_le_mul_of_nonneg_right ?_ (mul_nonneg ha hb)
    nlinarith [mul_nonneg hε.le (sub_nonneg.2 hε1)]
  have hexp : (S + ε * a) * (S + ε * b) = S ^ 2 + ε * (a * S + b * S) + ε ^ 2 * (a * b) := by
    ring
  have h3 : ε * (a * S + b * S + a * b) ≤
      (V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1)) * (a * S + b * S + a * b) :=
    mul_le_mul_of_nonneg_right hε2 hC
  have h4 : (V ^ 2 - S ^ 2) / (2 * (a * S + b * S + a * b + 1)) * (a * S + b * S + a * b) ≤
      (V ^ 2 - S ^ 2) / 2 := by
    rw [div_mul_eq_mul_div, div_le_iff₀ hpos]
    nlinarith [hgap.le]
  have h5 : ε * (a * S + b * S + a * b) = ε * (a * S + b * S) + ε * (a * b) := by ring
  linarith

/-! ## 3. Weight optimization with zero coefficients allowed -/

/-- Localized weight optimization: nonnegative coefficients, finite support, no positivity
assumption on `β` or `A`. -/
theorem localized_weight_optimization {ι : Type*} (s : Finset ι)
    (β A : ι → ℝ) (V : ℝ)
    (hβ : ∀ i ∈ s, 0 ≤ β i) (hA : ∀ i ∈ s, 0 ≤ A i)
    (hweighted : ∀ w : ι → ℝ, (∀ i ∈ s, 0 < w i) →
      V ^ 2 ≤ (∑ i ∈ s, w i * A i) * (∑ i ∈ s, β i / w i)) :
    V ≤ ∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i) := by
  have hS : 0 ≤ ∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i) :=
    sum_nonneg fun i _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have ha : 0 ≤ ∑ i ∈ s, Real.sqrt (A i) := sum_nonneg fun i _ => Real.sqrt_nonneg _
  have hb : 0 ≤ ∑ i ∈ s, Real.sqrt (β i) := sum_nonneg fun i _ => Real.sqrt_nonneg _
  refine le_of_forall_reg V (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i))
    (∑ i ∈ s, Real.sqrt (A i)) (∑ i ∈ s, Real.sqrt (β i)) hS ha hb ?_
  intro ε hε
  have hW := hweighted (fun i => (Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε))
    (fun i _ => reg_weight_pos hε)
  beta_reduce at hW
  have h1 : (∑ i ∈ s, (Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε) * A i) ≤
      (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (A i) := by
    calc (∑ i ∈ s, (Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε) * A i)
        ≤ ∑ i ∈ s, (Real.sqrt (β i) + ε) * Real.sqrt (A i) :=
          sum_le_sum fun i hi => reg_weight_mul_le (hA i hi) hε
      _ = (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (A i) := by
          rw [mul_sum, ← sum_add_distrib]
          exact sum_congr rfl fun i _ => by ring
  have h2 : (∑ i ∈ s, β i / ((Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε))) ≤
      (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (β i) := by
    calc (∑ i ∈ s, β i / ((Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε)))
        ≤ ∑ i ∈ s, Real.sqrt (β i) * (Real.sqrt (A i) + ε) :=
          sum_le_sum fun i hi => div_reg_weight_le (hβ i hi) hε
      _ = (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (β i) := by
          rw [mul_sum, ← sum_add_distrib]
          exact sum_congr rfl fun i _ => by ring
  have hpos2 : 0 ≤ ∑ i ∈ s, β i / ((Real.sqrt (β i) + ε) / (Real.sqrt (A i) + ε)) :=
    sum_nonneg fun i hi => div_nonneg (hβ i hi) (reg_weight_pos hε).le
  have hR : 0 ≤ (∑ i ∈ s, Real.sqrt (β i) * Real.sqrt (A i)) + ε * ∑ i ∈ s, Real.sqrt (A i) :=
    add_nonneg hS (mul_nonneg hε.le ha)
  exact le_trans hW (mul_le_mul h1 h2 hpos2 hR)

/-! ## 4. Cauchy–Schwarz with reciprocal weights -/

lemma cs_reciprocal {κ : Type*} [Fintype κ] (a s : κ → ℝ) (hs : ∀ k, 0 < s k) :
    (∑ k, a k) ^ 2 ≤ (∑ k, a k ^ 2 * s k) * (∑ k, (s k)⁻¹) := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun k => a k * Real.sqrt (s k)) (fun k => (Real.sqrt (s k))⁻¹)
  have e1 : ∀ k, a k * Real.sqrt (s k) * (Real.sqrt (s k))⁻¹ = a k := fun k =>
    mul_inv_cancel_right₀ (Real.sqrt_pos.2 (hs k)).ne' (a k)
  have e2 : ∀ k, (a k * Real.sqrt (s k)) ^ 2 = a k ^ 2 * s k := fun k => by
    rw [mul_pow, Real.sq_sqrt (hs k).le]
  have e3 : ∀ k, ((Real.sqrt (s k))⁻¹) ^ 2 = (s k)⁻¹ := fun k => by
    rw [inv_pow, Real.sq_sqrt (hs k).le]
  simp only [e1, e2, e3] at h
  exact h

lemma cs_reciprocal2 {α γ : Type*} [Fintype α] [Fintype γ] (a s : α → γ → ℝ)
    (hs : ∀ x y, 0 < s x y) :
    (∑ x, ∑ y, a x y) ^ 2 ≤
      (∑ x, ∑ y, a x y ^ 2 * s x y) * (∑ x, ∑ y, (s x y)⁻¹) := by
  have h := cs_reciprocal (fun p : α × γ => a p.1 p.2) (fun p => s p.1 p.2)
    (fun p => hs p.1 p.2)
  simp only [Fintype.sum_prod_type] at h
  exact h

/-! ## 5. Localized weight removal -/

/-- Inverse ℓ¹ cost of a row. -/
noncomputable def invCost {n : ℕ} (r : Fin n → ℝ) : ℝ := (∑ j, r j)⁻¹

/-- Coordinate load `Xⱼ = ∑ₓ ‖λₓ‖⁻² λₓⱼ`. -/
noncomputable def load {α : Type*} [Fintype α] {n : ℕ} (lam : α → Fin n → ℝ) (j : Fin n) : ℝ :=
  ∑ x, invCost (lam x) ^ 2 * lam x j

lemma load_nonneg {α : Type*} [Fintype α] {n : ℕ} (lam : α → Fin n → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (j : Fin n) : 0 ≤ load lam j :=
  sum_nonneg fun x _ => mul_nonneg (sq_nonneg _) (hlam x j)

/-- Localized weight removal (Certificate Engine v2, Lemma 4.1). -/
theorem localized_weight_removal {α γ : Type*} [Fintype α] [Fintype γ] {n : ℕ}
    (lam : α → Fin n → ℝ) (gam : γ → Fin n → ℝ) (J : α → γ → Finset (Fin n))
    (c : Fin n → ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (hgam : ∀ y j, 0 ≤ gam y j) (hc : ∀ j, 0 ≤ c j)
    (hpos : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * lam x j * gam y j)
    (hrecip : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      ∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ ≤ ∑ j, c j / w j) :
    (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) ≤
      ∑ j, Real.sqrt (c j) * Real.sqrt (load lam j * load gam j) := by
  refine localized_weight_optimization Finset.univ c (fun j => load lam j * load gam j)
    ((∑ x, invCost (lam x)) * (∑ y, invCost (gam y)))
    (fun j _ => hc j)
    (fun j _ => mul_nonneg (load_nonneg lam hlam j) (load_nonneg gam hgam j)) ?_
  intro w hw'
  have hw : ∀ j, 0 < w j := fun j => hw' j (Finset.mem_univ j)
  -- Cauchy–Schwarz over pairs
  have cs := cs_reciprocal2 (fun x y => invCost (lam x) * invCost (gam y))
    (fun x y => ∑ j ∈ J x y, w j * lam x j * gam y j) (fun x y => hpos w hw x y)
  beta_reduce at cs
  have hV : (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) =
      ∑ x, ∑ y, invCost (lam x) * invCost (gam y) := by
    rw [Finset.sum_mul_sum]
  -- enlarge J x y to all coordinates
  have hterm : ∀ x y, 0 ≤ ∑ j, w j * lam x j * gam y j := fun x y =>
    sum_nonneg fun j _ => mul_nonneg (mul_nonneg (hw j).le (hlam x j)) (hgam y j)
  have h1 : (∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
        ∑ j ∈ J x y, w j * lam x j * gam y j) ≤
      ∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
        ∑ j, w j * lam x j * gam y j := by
    refine sum_le_sum fun x _ => sum_le_sum fun y _ => ?_
    refine mul_le_mul_of_nonneg_left ?_ (sq_nonneg _)
    exact sum_le_sum_of_subset_of_nonneg (subset_univ _)
      (fun j _ _ => mul_nonneg (mul_nonneg (hw j).le (hlam x j)) (hgam y j))
  -- rearrange into coordinate loads
  have expand : (∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
        ∑ j, w j * lam x j * gam y j) =
      ∑ j, w j * (load lam j * load gam j) := by
    symm
    calc ∑ j, w j * (load lam j * load gam j)
        = ∑ j, ∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            (w j * lam x j * gam y j) := by
          refine sum_congr rfl fun j _ => ?_
          unfold load
          rw [Finset.sum_mul_sum, Finset.mul_sum]
          refine sum_congr rfl fun x _ => ?_
          rw [Finset.mul_sum]
          refine sum_congr rfl fun y _ => ?_
          ring
      _ = ∑ x, ∑ j, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            (w j * lam x j * gam y j) := Finset.sum_comm
      _ = ∑ x, ∑ y, ∑ j, (invCost (lam x) * invCost (gam y)) ^ 2 *
            (w j * lam x j * gam y j) := by
          refine sum_congr rfl fun x _ => ?_
          exact Finset.sum_comm
      _ = ∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            ∑ j, w j * lam x j * gam y j := by
          refine sum_congr rfl fun x _ => sum_congr rfl fun y _ => ?_
          rw [Finset.mul_sum]
  have hrec_nonneg : 0 ≤ ∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ :=
    sum_nonneg fun x _ => sum_nonneg fun y _ => (inv_pos.2 (hpos w hw x y)).le
  have hload_nonneg : 0 ≤ ∑ j, w j * (load lam j * load gam j) :=
    sum_nonneg fun j _ =>
      mul_nonneg (hw j).le (mul_nonneg (load_nonneg lam hlam j) (load_nonneg gam hgam j))
  calc ((∑ x, invCost (lam x)) * (∑ y, invCost (gam y))) ^ 2
      = (∑ x, ∑ y, invCost (lam x) * invCost (gam y)) ^ 2 := by rw [hV]
    _ ≤ (∑ x, ∑ y, (invCost (lam x) * invCost (gam y)) ^ 2 *
            ∑ j ∈ J x y, w j * lam x j * gam y j) *
          (∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹) := cs
    _ ≤ (∑ j, w j * (load lam j * load gam j)) * (∑ j, c j / w j) :=
        mul_le_mul (h1.trans expand.le) (hrecip w hw) hrec_nonneg hload_nonneg

/-! ## 6. Turturean's form (unlocalized) as a corollary -/

lemma sum_load_eq {α : Type*} [Fintype α] {n : ℕ} (lam : α → Fin n → ℝ)
    (hnl : ∀ x, 0 < ∑ j, lam x j) :
    ∑ j, load lam j = ∑ x, invCost (lam x) := by
  unfold load
  rw [Finset.sum_comm]
  refine sum_congr rfl fun x _ => ?_
  rw [← Finset.mul_sum]
  unfold invCost
  have h : (∑ j, lam x j) ≠ 0 := (hnl x).ne'
  rw [sq, mul_assoc, inv_mul_cancel₀ h, mul_one]

/-- Recovering the unlocalized weight-removal bound from the localized one. -/
theorem weight_removal_max {α γ : Type*} [Fintype α] [Fintype γ] {n : ℕ}
    (lam : α → Fin n → ℝ) (gam : γ → Fin n → ℝ) (J : α → γ → Finset (Fin n))
    (c : Fin n → ℝ) (M : ℝ)
    (hlam : ∀ x j, 0 ≤ lam x j) (hgam : ∀ y j, 0 ≤ gam y j) (hc : ∀ j, 0 ≤ c j)
    (hM : ∀ j, c j ≤ M) (hM0 : 0 ≤ M)
    (hnl : ∀ x, 0 < ∑ j, lam x j) (hng : ∀ y, 0 < ∑ j, gam y j)
    (hpos : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * lam x j * gam y j)
    (hrecip : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      ∑ x, ∑ y, (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ ≤ ∑ j, c j / w j) :
    (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) ≤ M := by
  have hloc := localized_weight_removal lam gam J c hlam hgam hc hpos hrecip
  have hXn := load_nonneg lam hlam
  have hYn := load_nonneg gam hgam
  have hVA : 0 ≤ ∑ x, invCost (lam x) :=
    sum_nonneg fun x _ => inv_nonneg.2 (hnl x).le
  have hVB : 0 ≤ ∑ y, invCost (gam y) :=
    sum_nonneg fun y _ => inv_nonneg.2 (hng y).le
  set V := (∑ x, invCost (lam x)) * (∑ y, invCost (gam y)) with hVdef
  have hV : 0 ≤ V := mul_nonneg hVA hVB
  set T := ∑ j, Real.sqrt (load lam j) * Real.sqrt (load gam j) with hTdef
  have hT : 0 ≤ T := sum_nonneg fun j _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  -- V ≤ √M · T
  have hle : V ≤ Real.sqrt M * T := by
    refine le_trans hloc ?_
    rw [hTdef, Finset.mul_sum]
    refine sum_le_sum fun j _ => ?_
    have hcM : Real.sqrt (c j) ≤ Real.sqrt M := Real.sqrt_le_sqrt (hM j)
    have hXY : 0 ≤ Real.sqrt (load lam j) * Real.sqrt (load gam j) :=
      mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
    rw [Real.sqrt_mul (hXn j)]
    exact mul_le_mul_of_nonneg_right hcM hXY
  -- T² ≤ V by Cauchy–Schwarz over coordinates
  have hT2 : T ^ 2 ≤ V := by
    have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
      (fun j => Real.sqrt (load lam j)) (fun j => Real.sqrt (load gam j))
    have eX : ∀ j, Real.sqrt (load lam j) ^ 2 = load lam j := fun j => Real.sq_sqrt (hXn j)
    have eY : ∀ j, Real.sqrt (load gam j) ^ 2 = load gam j := fun j => Real.sq_sqrt (hYn j)
    simp only [eX, eY] at h
    rw [sum_load_eq lam hnl, sum_load_eq gam hng] at h
    exact h
  -- conclude
  have hVV : V * V ≤ M * V := by
    have h1 : V * V ≤ (Real.sqrt M * T) * (Real.sqrt M * T) := mul_self_le_mul_self hV hle
    have h2 : (Real.sqrt M * T) * (Real.sqrt M * T) = M * T ^ 2 := by
      have := Real.mul_self_sqrt hM0
      calc (Real.sqrt M * T) * (Real.sqrt M * T)
          = (Real.sqrt M * Real.sqrt M) * T ^ 2 := by ring
        _ = M * T ^ 2 := by rw [this]
    have h3 : M * T ^ 2 ≤ M * V := mul_le_mul_of_nonneg_left hT2 hM0
    linarith
  rcases eq_or_lt_of_le hV with h0 | hpos'
  · rw [← h0]; exact hM0
  · exact le_of_mul_le_mul_right hVV hpos'

end Nightfall.ProductSpace