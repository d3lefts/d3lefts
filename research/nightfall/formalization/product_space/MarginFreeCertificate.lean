import Mathlib
import ComponentIdentification

/-!
# Margin-free component identification: certified finite algebra

This file strengthens the finite portion of PR #893 for use with a margin-free
angular or common-part expectation-stability theorem.

No analytic inequality is asserted or hidden as an axiom:
`hsmall` is an EXPLICIT hypothesis of weighted_overlap.
The quantum simulation and high-dimensional angular inequality are NOT
certified by this file.

All declarations below must be kernel-checked with printed axiom dependencies.
-/

namespace Nightfall.MarginFreeCertificate

open Finset BigOperators

/-- Unequal component priors and unequal total failure budgets are permitted.
    The individual `hsmall` mean shift is an explicitly assumed *analytic*
    input, not a theorem about polynomial degree. -/
theorem weighted_overlap {ι : Type*} (s : Finset ι)
    (P Q dP dQ EP EQ : ι → ℝ) (u v ε ρP ρQ : ℝ)
    (hP0 : ∀ i ∈ s, 0 ≤ P i) (hQ0 : ∀ i ∈ s, 0 ≤ Q i)
    (hdP : ∀ i ∈ s, 0 ≤ dP i) (hdQ : ∀ i ∈ s, 0 ≤ dQ i)
    (hsmall : ∀ i ∈ s, |EP i - EQ i| ≤ ε)
    (hmeanP : ∀ i ∈ s, |EP i - u| ≤ ε + dP i)
    (hmeanQ : ∀ i ∈ s, |EQ i - v| ≤ ε + dQ i)
    (hsep : 3 * ε < |u - v|)
    (hfailP : ∑ i ∈ s, P i * dP i ≤ ρP)
    (hfailQ : ∑ i ∈ s, Q i * dQ i ≤ ρQ) :
    ∑ i ∈ s, min (P i) (Q i) ≤
      (ρP + ρQ) / (|u - v| - 3 * ε) := by
  have hΔ : 0 < |u - v| - 3 * ε := by linarith
  rw [le_div_iff₀ hΔ]
  calc
    (∑ i ∈ s, min (P i) (Q i)) * (|u - v| - 3 * ε)
        = ∑ i ∈ s, min (P i) (Q i) * (|u - v| - 3 * ε) :=
            Finset.sum_mul _ _ _
    _ ≤ ∑ i ∈ s, (P i * dP i + Q i * dQ i) := by
      apply Finset.sum_le_sum
      intro i hi
      have hcost := Nightfall.ComponentIdentification.cell_cost
        (EP i) (EQ i) u v ε (dP i) (dQ i)
        (hsmall i hi) (hmeanP i hi) (hmeanQ i hi)
      have hm0 : 0 ≤ min (P i) (Q i) :=
        le_min (hP0 i hi) (hQ0 i hi)
      calc
        min (P i) (Q i) * (|u - v| - 3 * ε)
            ≤ min (P i) (Q i) * (dP i + dQ i) :=
              mul_le_mul_of_nonneg_left hcost hm0
        _ = min (P i) (Q i) * dP i + min (P i) (Q i) * dQ i := by ring
        _ ≤ P i * dP i + Q i * dQ i := by
          gcongr
          · exact hdP i hi
          · exact min_le_left _ _
          · exact hdQ i hi
          · exact min_le_right _ _
    _ = (∑ i ∈ s, P i * dP i) + (∑ i ∈ s, Q i * dQ i) :=
          Finset.sum_add_distrib
    _ ≤ ρP + ρQ := add_le_add hfailP hfailQ

/-- Normalizing two distributions and rounding non-anchor atoms upward
    moves exactly the sum of their increases from the anchor. -/
theorem rounding_mass_balance {α : Type*} [DecidableEq α]
    (s : Finset α) (anchor : α) (p q : α → ℝ)
    (ha : anchor ∈ s)
    (hp : ∑ i ∈ s, p i = 1)
    (hq : ∑ i ∈ s, q i = 1) :
    p anchor - q anchor =
      ∑ i ∈ s.erase anchor, (q i - p i) := by
  have htotal : (∑ i ∈ s, (q i - p i)) = 0 := by
    rw [Finset.sum_sub_distrib, hq, hp]
    ring
  have hsplit : (∑ i ∈ s.erase anchor, (q i - p i)) +
      (q anchor - p anchor) = ∑ i ∈ s, (q i - p i) := by
    exact Finset.sum_erase_add ha
  linarith

/-- Exact finite-dimensional rounding displacement, with no positivity floor
    imposed on the NON-anchor source atoms. -/
theorem rounding_mass_bound {α : Type*} [DecidableEq α]
    (s : Finset α) (anchor : α) (p q : α → ℝ) (ρ : ℝ)
    (ha : anchor ∈ s) (hρ : 0 ≤ ρ)
    (hp : ∑ i ∈ s, p i = 1)
    (hq : ∑ i ∈ s, q i = 1)
    (hround : ∀ i ∈ s.erase anchor, 0 ≤ q i - p i ∧ q i - p i ≤ ρ) :
    0 ≤ p anchor - q anchor ∧
      p anchor - q anchor ≤ (s.card : ℝ) * ρ := by
  have hbal := rounding_mass_balance s anchor p q ha hp hq
  constructor
  · rw [hbal]
    exact Finset.sum_nonneg (fun i hi => (hround i hi).1)
  · rw [hbal]
    calc
      (∑ i ∈ s.erase anchor, (q i - p i))
          ≤ ∑ _i ∈ s.erase anchor, ρ :=
            Finset.sum_le_sum (fun i hi => (hround i hi).2)
      _ = ((s.erase anchor).card : ℝ) * ρ := by simp
      _ ≤ (s.card : ℝ) * ρ := by
        gcongr
        exact Finset.card_le_card (Finset.erase_subset anchor s)

/-- If the reserved anchor has probability at least 1/|Σ|, its conditional
    mismatch probability is bounded by |Σ|² ρ. No lower bound is assumed
    for any other atom, including atoms whose original probability is zero. -/
theorem rounding_conditional_mismatch {α : Type*} [DecidableEq α]
    (s : Finset α) (anchor : α) (p q : α → ℝ) (ρ : ℝ)
    (ha : anchor ∈ s) (hρ : 0 ≤ ρ)
    (hp : ∑ i ∈ s, p i = 1)
    (hq : ∑ i ∈ s, q i = 1)
    (hround : ∀ i ∈ s.erase anchor, 0 ≤ q i - p i ∧ q i - p i ≤ ρ)
    (hanchor : 1 / (s.card : ℝ) ≤ p anchor) :
    (p anchor - q anchor) / p anchor ≤ (s.card : ℝ) ^ 2 * ρ := by
  have hcard_nat : 0 < s.card := Finset.card_pos.mpr ⟨anchor, ha⟩
  have hcard : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast hcard_nat
  have hp_pos : 0 < p anchor := by
    have : 0 < 1 / (s.card : ℝ) := by positivity
    linarith
  have hlow : 1 ≤ (s.card : ℝ) * p anchor :=
    (div_le_iff₀ hcard).mp hanchor
  have hmass := (rounding_mass_bound s anchor p q ρ ha hρ hp hq hround).2
  have hnonneg : 0 ≤ (s.card : ℝ) * ρ :=
    mul_nonneg (le_of_lt hcard) hρ
  have hscaled := mul_le_mul_of_nonneg_left hlow hnonneg
  apply (div_le_iff₀ hp_pos).2
  nlinarith [hscaled]

/-- Final union-bound arithmetic for M-mixture frozen duels, using the
    paper's explicit ρ = εδ/(8M) and ζ = δ/(4M) budgets. -/
theorem tournament_budget (M ε δ : ℝ)
    (hM : 1 ≤ M) (hε : 0 < ε) (hε1 : ε ≤ 1) (hδ : 0 ≤ δ) :
    ε * δ / (8 * M) +
      (M - 1) * (δ / (4 * M) + 2 * (ε * δ / (8 * M)) / ε)
      ≤ δ := by
  have hMpos : 0 < M := by linarith
  have hεne : ε ≠ 0 := ne_of_gt hε
  have hMne : M ≠ 0 := ne_of_gt hMpos
  have heq :
      ε * δ / (8 * M) +
        (M - 1) * (δ / (4 * M) + 2 * (ε * δ / (8 * M)) / ε) =
      δ * (ε + 4 * (M - 1)) / (8 * M) := by
    field_simp [hMne, hεne]
    ring
  rw [heq]
  apply (div_le_iff₀ (by positivity : 0 < 8 * M)).2
  have hgap : 0 ≤ 8 * M - (ε + 4 * (M - 1)) := by linarith
  have hnonneg := mul_nonneg hδ hgap
  nlinarith

end Nightfall.MarginFreeCertificate
