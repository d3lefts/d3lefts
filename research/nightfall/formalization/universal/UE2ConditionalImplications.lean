import Mathlib

/-!
# NIGHTFALL UE2: conditional scalar implications only

No conjecture is asserted as an axiom and no infinite-cylinder transfer is
claimed by this file. This isolates scalar consequences of an explicit bound.
-/

namespace Nightfall.UE2ConditionalImplications

/-- Scalar UE2 instance, with chosen degree exponent k.
The product-space theorem remains an open conjecture. -/
def UE2 (k : ℕ) (C V B M : ℝ) (d : ℕ) : Prop :=
  V ^ 2 ≤ C * (d : ℝ) ^ k * B ^ 2 * M

/-- Degree exponent two implies six with the same C, conditionally. -/
theorem degree_two_implies_degree_six
    (C V B M : ℝ) (d : ℕ)
    (hC : 0 ≤ C) (hM : 0 ≤ M) (hd : 1 ≤ d)
    (h : UE2 2 C V B M d) : UE2 6 C V B M d := by
  unfold UE2 at h ⊢
  have hdR : (1 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
  have hd2 : (1 : ℝ) ≤ (d : ℝ) ^ 2 := by
    have hh : 0 ≤ ((d : ℝ) - 1) * ((d : ℝ) + 1) :=
      mul_nonneg (sub_nonneg.mpr hdR) (by linarith)
    nlinarith
  have hd4 : (1 : ℝ) ≤ (d : ℝ) ^ 4 := by
    have hh : 0 ≤ ((d : ℝ) ^ 2 - 1) * ((d : ℝ) ^ 2 + 1) :=
      mul_nonneg (sub_nonneg.mpr hd2) (by nlinarith [sq_nonneg (d : ℝ)])
    nlinarith
  have hpow : (d : ℝ) ^ 2 ≤ (d : ℝ) ^ 6 := by
    calc
      (d : ℝ) ^ 2 = (d : ℝ) ^ 2 * 1 := by ring
      _ ≤ (d : ℝ) ^ 2 * (d : ℝ) ^ 4 :=
        mul_le_mul_of_nonneg_left hd4 (sq_nonneg _)
      _ = (d : ℝ) ^ 6 := by ring
  have hmult : 0 ≤ C * B ^ 2 * M :=
    mul_nonneg (mul_nonneg hC (sq_nonneg B)) hM
  calc
    V ^ 2 ≤ C * (d : ℝ) ^ 2 * B ^ 2 * M := h
    _ = (C * B ^ 2 * M) * (d : ℝ) ^ 2 := by ring
    _ ≤ (C * B ^ 2 * M) * (d : ℝ) ^ 6 :=
      mul_le_mul_of_nonneg_left hpow hmult
    _ = C * (d : ℝ) ^ 6 * B ^ 2 * M := by ring

/-- Conditional implication into AA flip normalization.
For uniform [0,1]-valued functions their centered radius is at most 1/2. -/
theorem implies_aa_flip_normalization
    (C V B M : ℝ) (d : ℕ)
    (hC : 0 ≤ C) (hM : 0 ≤ M)
    (hB0 : 0 ≤ B) (hB : B ≤ (1 / 2 : ℝ))
    (h : UE2 6 C V B M d) :
    16 * V ^ 2 ≤ C * (d : ℝ) ^ 6 * (4 * M) := by
  unfold UE2 at h
  have hBs : B ^ 2 ≤ (1 / 2 : ℝ) ^ 2 := by
    have hh : 0 ≤ ((1 / 2 : ℝ) - B) * ((1 / 2 : ℝ) + B) :=
      mul_nonneg (sub_nonneg.mpr hB) (by linarith)
    nlinarith
  have hpow : 0 ≤ (d : ℝ) ^ 6 :=
    pow_nonneg (by exact_mod_cast (Nat.zero_le d)) _
  have hfactor : 0 ≤ C * (d : ℝ) ^ 6 * M :=
    mul_nonneg (mul_nonneg hC hpow) hM
  have hbound : V ^ 2 ≤ C * (d : ℝ) ^ 6 * (1 / 2 : ℝ) ^ 2 * M := by
    calc
      V ^ 2 ≤ C * (d : ℝ) ^ 6 * B ^ 2 * M := h
      _ = (C * (d : ℝ) ^ 6 * M) * B ^ 2 := by ring
      _ ≤ (C * (d : ℝ) ^ 6 * M) * (1 / 2 : ℝ) ^ 2 :=
        mul_le_mul_of_nonneg_left hBs hfactor
      _ = C * (d : ℝ) ^ 6 * (1 / 2 : ℝ) ^ 2 * M := by ring
  nlinarith [hbound]

/-- A coefficient-qualified consequence of a variance-squared UE2 bound.
The five-halves variance term is V^2 * sqrt V, with 0 <= V <= 1. -/
theorem dominates_five_halves_when_coefficient_allows
    (C t V M : ℝ) (d : ℕ)
    (hC : 0 ≤ C) (ht : 0 ≤ t) (hCt : C * t ≤ 1)
    (hV0 : 0 ≤ V) (hV1 : V ≤ 1) (hM : 0 ≤ M)
    (h : UE2 6 C V 1 M d) :
    t * V ^ 2 * Real.sqrt V ≤ (d : ℝ) ^ 6 * M := by
  unfold UE2 at h
  have hsqrt0 : 0 ≤ Real.sqrt V := Real.sqrt_nonneg V
  have hsqrt2 : (Real.sqrt V) ^ 2 = V := Real.sq_sqrt hV0
  have hsqrt1 : Real.sqrt V ≤ 1 := by nlinarith
  have hp : 0 ≤ (d : ℝ) ^ 6 :=
    pow_nonneg (by exact_mod_cast (Nat.zero_le d)) _
  have hnonneg : 0 ≤ (d : ℝ) ^ 6 * M := mul_nonneg hp hM
  have hbound : V ^ 2 ≤ C * ((d : ℝ) ^ 6 * M) := by
    nlinarith [h]
  have hmid : t * V ^ 2 ≤ (d : ℝ) ^ 6 * M := by
    calc
      t * V ^ 2 ≤ t * (C * ((d : ℝ) ^ 6 * M)) :=
        mul_le_mul_of_nonneg_left hbound ht
      _ = (C * t) * ((d : ℝ) ^ 6 * M) := by ring
      _ ≤ 1 * ((d : ℝ) ^ 6 * M) :=
        mul_le_mul_of_nonneg_right hCt hnonneg
      _ = (d : ℝ) ^ 6 * M := by ring
  calc
    t * V ^ 2 * Real.sqrt V ≤ t * V ^ 2 * 1 :=
      mul_le_mul_of_nonneg_left hsqrt1
        (mul_nonneg ht (sq_nonneg V))
    _ = t * V ^ 2 := by ring
    _ ≤ (d : ℝ) ^ 6 * M := hmid

#print axioms Nightfall.UE2ConditionalImplications.degree_two_implies_degree_six
#print axioms Nightfall.UE2ConditionalImplications.implies_aa_flip_normalization
#print axioms Nightfall.UE2ConditionalImplications.dominates_five_halves_when_coefficient_allows
end Nightfall.UE2ConditionalImplications
