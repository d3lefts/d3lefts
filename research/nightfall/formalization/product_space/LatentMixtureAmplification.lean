import Mathlib

/-!
# Finite latent-mixture AA witness amplification

This is a modular algebraic composition theorem. It makes explicit every
premise: mixture weights, componentwise AA witnesses, genuine correlated-law
influence domination, and variance retention. It is NOT itself a proof that
the input source satisfies those premises. The fibre-dominance condition
is established separately in LatentMixtureVariance.lean.
-/

namespace Nightfall.LatentMixture

open Finset

variable {Θ ι : Type*} [Fintype Θ] [DecidableEq Θ] [Fintype ι] [DecidableEq ι]

/-- Finite Jensen for the power 5/2, the exact exponent in Turturean's bound. -/
theorem weighted_jensen_five_halves
    (w Vθ : Θ → ℝ)
    (hw : ∀ θ, 0 ≤ w θ) (hsum : (∑ θ, w θ) = 1)
    (hVθ : ∀ θ, 0 ≤ Vθ θ) :
    (∑ θ, w θ * Vθ θ) ^ (5 / 2 : ℝ) ≤
      (∑ θ, w θ * (Vθ θ ^ (5 / 2 : ℝ))) := by
  have hc : ConvexOn ℝ (Set.Ici (0 : ℝ))
      (fun x : ℝ => x ^ (5 / 2 : ℝ)) := convexOn_rpow (by norm_num)
  have h := hc.map_sum_le (t := Finset.univ) (w := w) (p := Vθ)
      (by intro θ hθ; exact hw θ)
      (by simpa using hsum)
      (by intro θ hθ; exact hVθ θ)
  simpa only [smul_eq_mul] using h

/-- Dimension-free influence under a bounded number of product-law
latent components, with explicit variance retention and true-influence
comparison. The factor card Θ is the number of latent components. -/
theorem latent_witness_amplification
    (w Vθ : Θ → ℝ) (Iθ : Θ → ι → ℝ) (Ijoint : ι → ℝ)
    (V κ a M : ℝ)
    (hκ : 0 ≤ κ) (hV : 0 ≤ V) (ha : 0 ≤ a)
    (hw : ∀ θ, 0 ≤ w θ) (hsum : (∑ θ, w θ) = 1)
    (hVθ : ∀ θ, 0 ≤ Vθ θ)
    (hIθ : ∀ θ i, 0 ≤ Iθ θ i)
    (hwithin : κ * V ≤ ∑ θ, w θ * Vθ θ)
    (hwitness : ∀ θ, ∃ i, a * Vθ θ ^ (5 / 2 : ℝ) ≤ Iθ θ i)
    (hmixture : ∀ i, (∑ θ, w θ * Iθ θ i) ≤ Ijoint i)
    (hmax : ∀ i, Ijoint i ≤ M) :
    a * (κ * V) ^ (5 / 2 : ℝ) ≤ (Fintype.card Θ : ℝ) * M := by
  have hJensen := weighted_jensen_five_halves w Vθ hw hsum hVθ
  have hpower : (κ * V) ^ (5 / 2 : ℝ) ≤
      (∑ θ, w θ * Vθ θ) ^ (5 / 2 : ℝ) :=
    Real.rpow_le_rpow (mul_nonneg hκ hV) hwithin (by norm_num)
  have hterms : (∑ θ, w θ * (a * Vθ θ ^ (5 / 2 : ℝ))) ≤
      (Fintype.card Θ : ℝ) * M := by
    have h := Finset.sum_le_sum (s := Finset.univ)
      (fun θ hθ => by
        obtain ⟨i, hi⟩ := hwitness θ
        have hsingle : w θ * Iθ θ i ≤ (∑ φ, w φ * Iθ φ i) :=
          Finset.single_le_sum
            (fun φ hφ => mul_nonneg (hw φ) (hIθ φ i))
            (Finset.mem_univ θ)
        calc
          w θ * (a * Vθ θ ^ (5 / 2 : ℝ)) ≤ w θ * Iθ θ i :=
            mul_le_mul_of_nonneg_left hi (hw θ)
          _ ≤ (∑ φ, w φ * Iθ φ i) := hsingle
          _ ≤ Ijoint i := hmixture i
          _ ≤ M := hmax i)
    simpa only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using h
  calc
    a * (κ * V) ^ (5 / 2 : ℝ)
       ≤ a * ((∑ θ, w θ * Vθ θ) ^ (5 / 2 : ℝ)) :=
           mul_le_mul_of_nonneg_left hpower ha
    _ ≤ a * (∑ θ, w θ * (Vθ θ ^ (5 / 2 : ℝ))) :=
        mul_le_mul_of_nonneg_left hJensen ha
    _ = ∑ θ, w θ * (a * Vθ θ ^ (5 / 2 : ℝ)) := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro θ hθ
        ring
    _ ≤ (Fintype.card Θ : ℝ) * M := hterms

end Nightfall.LatentMixture
