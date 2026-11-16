import Mathlib
import PhysicalBornTerminal

/-!
NIGHTFALL: a *source-derived* scalar normalization for the exact physical
ternary p=3/4, q=1/4 ensemble. No estimated coefficient and no imported
"optimal gain" hypothesis: the target theorem uses ActualBornTerminal's
named, kernel-checked full-dimensional POVM equality and original A/B.

The normalization factor 3^d is the number of equiprobable ternary
source strings. This is a separate Lean gate from the unnormalized theorem.
-/

namespace Nightfall.Quantum.PhysicalGainNormalized
open scoped BigOperators ComplexOrder Matrix
open Nightfall.Quantum.ActualBornTerminal
open Nightfall.Quantum.OperatorReduction
noncomputable section

theorem source_weight_all_zero (d : ℕ) :
    SourceBorn.sourceWeight d (z d) = ((9 / 4 : ℝ) ^ d) := by
  simp [SourceBorn.sourceWeight, SourceBorn.localWeight, z,
    Finset.prod_const, Finset.card_fin, div_pow]

theorem source_weight_all_one (d : ℕ) :
    SourceBorn.sourceWeight d (o d) = ((3 / 4 : ℝ) ^ d) := by
  simp [SourceBorn.sourceWeight, SourceBorn.localWeight, o,
    Finset.prod_const, Finset.card_fin, div_pow]

theorem physical_source_corner_real (d : ℕ) (hd : 0 < d) :
    (unnormalizedA d (z d) (o d)).re =
      (((3 * Real.sqrt 3 / 4 : ℝ) ^ d) / 2) := by
  have hsource := OperatorReduction.actual_A_ghz_corner_value d hd
  change unnormalizedA d (z d) (o d) =
    (((3:ℂ) * ((Real.sqrt (3:ℝ) : ℂ)/4)) ^ d) / 2 at hsource
  let v : ℝ := 3 * Real.sqrt (3:ℝ) / 4
  have hv : (3:ℂ) * ((Real.sqrt (3:ℝ) : ℂ)/4) = (v : ℂ) := by
    dsimp [v]
    push_cast
    ring
  rw [hv] at hsource
  rw [hsource]
  change (((v : ℂ) ^ d / 2)).re = v ^ d / 2
  have hc : ((v : ℂ) ^ d / 2) = ((v ^ d / 2 : ℝ) : ℂ) := by
    calc
      ((v : ℂ) ^ d / 2) = ((v ^ d : ℝ) : ℂ) / 2 := by
        rw [Complex.ofReal_pow]
      _ = ((v ^ d / 2 : ℝ) : ℂ) := by push_cast; ring
  rw [hc]
  exact Complex.ofReal_re _

theorem exact_gain_ratio_scalar (d : ℕ) :
    (4 * (((3 * Real.sqrt 3 / 4 : ℝ) ^ d / 2) ^ 2) /
        ((9 / 4 : ℝ) ^ d + (3 / 4 : ℝ) ^ d)) / (3 : ℝ) ^ d =
      (3 / 16 : ℝ) ^ d / ((3 / 4 : ℝ) ^ d + (1 / 4 : ℝ) ^ d) := by
  have hr : (Real.sqrt (3:ℝ)) ^ 2 = 3 :=
    Real.sq_sqrt (by norm_num)
  have hsquare : ((3 * Real.sqrt 3 / 4 : ℝ) ^ 2) = (27 / 16 : ℝ) := by
    rw [div_pow, mul_pow, hr]
    norm_num
  have hnum :
      4 * (((3 * Real.sqrt 3 / 4 : ℝ) ^ d / 2) ^ 2) =
        (3 : ℝ) ^ d * (3 : ℝ) ^ d * (3 / 16 : ℝ) ^ d := by
    calc
      4 * (((3 * Real.sqrt 3 / 4 : ℝ) ^ d / 2) ^ 2) =
          ((3 * Real.sqrt 3 / 4 : ℝ) ^ d) ^ 2 := by ring
      _ = (((3 * Real.sqrt 3 / 4 : ℝ) ^ 2) ^ d) := by
          rw [← pow_mul, ← pow_mul, Nat.mul_comm d 2]
      _ = (27 / 16 : ℝ) ^ d := by rw [hsquare]
      _ = ((3 : ℝ) * 3 * (3 / 16)) ^ d := by norm_num
      _ = (3 : ℝ) ^ d * (3 : ℝ) ^ d * (3 / 16 : ℝ) ^ d := by
          rw [mul_pow, mul_pow]
  have hden :
      (9 / 4 : ℝ) ^ d + (3 / 4 : ℝ) ^ d =
        (3 : ℝ) ^ d * ((3 / 4 : ℝ) ^ d + (1 / 4 : ℝ) ^ d) := by
    have h1 : (9 / 4 : ℝ) = 3 * (3 / 4) := by norm_num
    have h2 : (3 / 4 : ℝ) = 3 * (1 / 4) := by norm_num
    rw [h1, h2, mul_pow, mul_pow]
    ring
  have hp : (3 : ℝ) ^ d ≠ 0 := pow_ne_zero _ (by norm_num)
  have hb : (3 / 4 : ℝ) ^ d + (1 / 4 : ℝ) ^ d ≠ 0 :=
    (add_pos (pow_pos (by norm_num) _) (pow_pos (by norm_num) _)).ne'
  rw [hnum, hden]
  field_simp [hp, hb] <;> ring

theorem actual_physical_optimal_gain_normalized
    (d : ℕ) (hd : 0 < d) :
    (∑ out : Fin 3,
      (bornNum d (fullGHZ d out)) ^ 2 /
        bornDen d (fullGHZ d out)) / (3 : ℝ) ^ d =
      (3 / 16 : ℝ) ^ d /
        ((3 / 4 : ℝ) ^ d + (1 / 4 : ℝ) ^ d) := by
  rw [ActualBornTerminal.full_GHZ_attains_actual_physical_bound d hd]
  rw [physical_source_corner_real d hd,
    source_weight_all_zero d, source_weight_all_one d]
  exact exact_gain_ratio_scalar d

#print axioms Nightfall.Quantum.PhysicalGainNormalized.source_weight_all_zero
#print axioms Nightfall.Quantum.PhysicalGainNormalized.source_weight_all_one
#print axioms Nightfall.Quantum.PhysicalGainNormalized.physical_source_corner_real
#print axioms Nightfall.Quantum.PhysicalGainNormalized.exact_gain_ratio_scalar
#print axioms Nightfall.Quantum.PhysicalGainNormalized.actual_physical_optimal_gain_normalized

end
end Nightfall.Quantum.PhysicalGainNormalized
