import LocalizedWeightRemoval

/-!
Mass absorption for the conditional localized weight-removal theorem.
For strictly positive sample weights p and q, replacing rows
  lambda(x,j) by lambda(x,j)/p(x)
turns inverse row costs into p(x) times the original inverse cost, and
reciprocal pair costs into p(x)q(y) times the original reciprocal pair cost.

This is algebraically independent of the probabilistic antipodal transfer.
It does not prove the latter's reciprocal premise. Zero-mass points
are handled by restricting the finite index sets to their supports.
-/

namespace Nightfall.ProductSpace

open Finset

lemma invCost_scaled {n : ℕ} (r : Fin n → ℝ) {m : ℝ} (hm : 0 < m) :
    invCost (fun j => r j / m) = m * invCost r := by
  unfold invCost
  change (∑ j, r j / m)⁻¹ = m * (∑ j, r j)⁻¹
  rw [← Finset.sum_div, inv_div, div_eq_mul_inv]

lemma scaled_pair_sum {α γ : Type*} [Fintype α] [Fintype γ]
    {n : ℕ} (lam : α → Fin n → ℝ) (gam : γ → Fin n → ℝ)
    (J : α → γ → Finset (Fin n)) (w : Fin n → ℝ)
    (p : α → ℝ) (q : γ → ℝ)
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y) (x : α) (y : γ) :
    (∑ j ∈ J x y, w j * (lam x j / p x) * (gam y j / q y)) =
      (∑ j ∈ J x y, w j * lam x j * gam y j) / (p x * q y) := by
  rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro j _
  field_simp [(hp x).ne', (hq y).ne']

lemma scaled_pair_inv {α γ : Type*} [Fintype α] [Fintype γ]
    {n : ℕ} (lam : α → Fin n → ℝ) (gam : γ → Fin n → ℝ)
    (J : α → γ → Finset (Fin n)) (w : Fin n → ℝ)
    (p : α → ℝ) (q : γ → ℝ)
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y) (x : α) (y : γ) :
    (∑ j ∈ J x y, w j * (lam x j / p x) * (gam y j / q y))⁻¹ =
      p x * q y * (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹ := by
  rw [scaled_pair_sum lam gam J w p q hp hq x y, inv_div, div_eq_mul_inv]

lemma load_scaled {α : Type*} [Fintype α] {n : ℕ}
    (lam : α → Fin n → ℝ) (p : α → ℝ) (hp : ∀ x, 0 < p x)
    (j : Fin n) :
    load (fun x i => lam x i / p x) j =
      ∑ x, p x * invCost (lam x) ^ 2 * lam x j := by
  unfold load
  apply Finset.sum_congr rfl
  intro x _
  rw [invCost_scaled (lam x) (hp x)]
  have hx : p x ≠ 0 := (hp x).ne'
  field_simp [hx]

/-- The already-certified unweighted localized weight-removal lemma
extends exactly to finite strictly-positive masses by row scaling.
The only reciprocal premise is a mass-weighted one, not a new axiom. -/
theorem localized_weight_removal_mass
    {α γ : Type*} [Fintype α] [Fintype γ] {n : ℕ}
    (lam : α → Fin n → ℝ) (gam : γ → Fin n → ℝ)
    (J : α → γ → Finset (Fin n))
    (p : α → ℝ) (q : γ → ℝ)
    (c : Fin n → ℝ)
    (hp : ∀ x, 0 < p x) (hq : ∀ y, 0 < q y)
    (hlam : ∀ x j, 0 ≤ lam x j)
    (hgam : ∀ y j, 0 ≤ gam y j)
    (hc : ∀ j, 0 ≤ c j)
    (hpos : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * lam x j * gam y j)
    (hrecip : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      (∑ x, ∑ y, p x * q y *
        (∑ j ∈ J x y, w j * lam x j * gam y j)⁻¹) ≤
        ∑ j, c j / w j) :
    (∑ x, p x * invCost (lam x)) *
      (∑ y, q y * invCost (gam y)) ≤
      ∑ j, Real.sqrt (c j) *
        Real.sqrt ((∑ x, p x * invCost (lam x) ^ 2 * lam x j) *
                   (∑ y, q y * invCost (gam y) ^ 2 * gam y j)) := by
  let ls : α → Fin n → ℝ := fun x j => lam x j / p x
  let gs : γ → Fin n → ℝ := fun y j => gam y j / q y
  have hls : ∀ x j, 0 ≤ ls x j :=
    fun x j => div_nonneg (hlam x j) (hp x).le
  have hgs : ∀ y j, 0 ≤ gs y j :=
    fun y j => div_nonneg (hgam y j) (hq y).le
  have hpos' : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      ∀ x y, 0 < ∑ j ∈ J x y, w j * ls x j * gs y j := by
    intro w hw x y
    change 0 < ∑ j ∈ J x y, w j * (lam x j / p x) * (gam y j / q y)
    rw [scaled_pair_sum lam gam J w p q hp hq x y]
    exact div_pos (hpos w hw x y) (mul_pos (hp x) (hq y))
  have hrecip' : ∀ w : Fin n → ℝ, (∀ j, 0 < w j) →
      (∑ x, ∑ y, (∑ j ∈ J x y, w j * ls x j * gs y j)⁻¹) ≤
      ∑ j, c j / w j := by
    intro w hw
    have h := hrecip w hw
    convert h using 1
    apply Finset.sum_congr rfl
    intro x _
    apply Finset.sum_congr rfl
    intro y _
    exact scaled_pair_inv lam gam J w p q hp hq x y
  have hcore := localized_weight_removal ls gs J c hls hgs hc hpos' hrecip'
  calc
    (∑ x, p x * invCost (lam x)) * (∑ y, q y * invCost (gam y)) =
        (∑ x, invCost (ls x)) * (∑ y, invCost (gs y)) := by
          congr 1
          · apply Finset.sum_congr rfl
            intro x _
            exact (invCost_scaled (lam x) (hp x)).symm
          · apply Finset.sum_congr rfl
            intro y _
            exact (invCost_scaled (gam y) (hq y)).symm
    _ ≤ ∑ j, Real.sqrt (c j) * Real.sqrt (load ls j * load gs j) := hcore
    _ = ∑ j, Real.sqrt (c j) *
        Real.sqrt ((∑ x, p x * invCost (lam x) ^ 2 * lam x j) *
                   (∑ y, q y * invCost (gam y) ^ 2 * gam y j)) := by
        apply Finset.sum_congr rfl
        intro j _
        rw [load_scaled lam p hp j, load_scaled gam q hq j]

end Nightfall.ProductSpace
