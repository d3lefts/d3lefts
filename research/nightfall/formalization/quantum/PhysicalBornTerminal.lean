import Mathlib
import PhysicalOutcomeNumerator
import AmbientGHZMeasurement
import PhysicalSourceBornTrace

/-!
NIGHTFALL: operational bridge from the ACTUAL source-defined physical operator
to the full-register three-outcome GHZ measurement.

The numerator is Tr(A E) with A averaged from actual ternary product states;
the denominator is Tr(B E) with B averaged from the same states. Both are
unnormalized by the global 3^d input count. No caller-supplied GHZ support
or posterior/coherence identity is allowed.

This module makes no novelty claim and does not by itself discharge the
normalized (pq)^d/(p^d+q^d) coefficient calculation.
-/

namespace Nightfall.Quantum.ActualBornTerminal

open scoped BigOperators ComplexOrder Matrix
open Matrix
open Nightfall.Quantum.OperatorReduction
noncomputable section

abbrev Register (d : ℕ) := Fin d → Fin 2
def z (d : ℕ) : Register d := fun _ => 0
def o (d : ℕ) : Register d := fun _ => 1

def fullGHZ (d : ℕ) (out : Fin 3) : Matrix (Register d) (Register d) ℂ :=
  AmbientGHZ.ghzAmbient (z d) (o d) out

theorem fullGHZ_positive (d : ℕ) (out : Fin 3) :
    (fullGHZ d out).PosSemidef := by
  exact AmbientGHZ.ghzAmbient_positive (z d) (o d) out

theorem fullGHZ_complete (d : ℕ) (hd : 0 < d) :
    (∑ out : Fin 3, fullGHZ d out) = 1 := by
  exact AmbientGHZ.ghzAmbient_complete (z d) (o d)
    (PhysicalNumerator.two_GHZ_rays_distinct d hd)

def bornNum (d : ℕ) (E : Matrix (Register d) (Register d) ℂ) : ℝ :=
  (Matrix.trace (unnormalizedA d * E)).re

def bornDen (d : ℕ) (E : Matrix (Register d) (Register d) ℂ) : ℝ :=
  (Matrix.trace (unnormalizedB d * E)).re

theorem bornNum_coherence (d : ℕ) (hd : 0 < d)
    (E : Matrix (Register d) (Register d) ℂ) (hE : E.PosSemidef) :
    bornNum d E =
      2 * (unnormalizedA d (z d) (o d)).re *
        (E (z d) (o d)).re := by
  exact PhysicalNumerator.actual_physical_A_real_trace_coherence d hd E hE

theorem bornDen_actual_weight (d : ℕ)
    (E : Matrix (Register d) (Register d) ℂ) :
    bornDen d E = SourceBorn.sourceBornWeight d E := by
  exact (SourceBornTrace.actual_source_born_is_real_trace d E).symm

theorem all_physical_povms_bounded
    (d : ℕ) (hd : 0 < d)
    {Out : Type*} [Fintype Out]
    (E : Out → Matrix (Register d) (Register d) ℂ)
    (hpositive : ∀ out, (E out).PosSemidef)
    (hcomplete : (∑ out, E out) = 1) :
    (∑ out, (bornNum d (E out)) ^ 2 / bornDen d (E out)) ≤
      4 * ((unnormalizedA d (z d) (o d)).re) ^ 2 /
        (SourceBorn.sourceWeight d (z d) +
          SourceBorn.sourceWeight d (o d)) := by
  simp_rw [bornNum_coherence d hd (E := _)]
  exact SourceBornTrace.physical_povm_upper_with_actual_source_trace
    d hd E hpositive hcomplete
    ((unnormalizedA d (z d) (o d)).re)

private theorem source_weight_pair_sum
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (a b : ι) (hab : a ≠ b) (w : ι → ℝ) :
    (∑ i : ι,
      w i * (if i = a then (1/2 : ℝ) else if i = b then 1/2 else 0)) =
      (w a + w b) / 2 := by
  classical
  simp [Finset.sum_ite, hab, add_div]

theorem plus_diag (d : ℕ) (hd : 0 < d) (i : Register d) :
    (fullGHZ d 0 i i).re =
      if i = z d then (1 / 2 : ℝ)
      else if i = o d then 1 / 2 else 0 := by
  classical
  have hab := PhysicalNumerator.two_GHZ_rays_distinct d hd
  by_cases ha : i = z d
  · simp [ha, fullGHZ, AmbientGHZ.ghzAmbient,
      AmbientGHZ.plusEffect, AmbientGHZ.plusVector,
      Matrix.vecMulVec, Matrix.smul_apply]
  · by_cases hb : i = o d
    · simp [ha, hb, fullGHZ, AmbientGHZ.ghzAmbient,
        AmbientGHZ.plusEffect, AmbientGHZ.plusVector,
        Matrix.vecMulVec, Matrix.smul_apply]
    · simp [ha, hb, fullGHZ, AmbientGHZ.ghzAmbient,
        AmbientGHZ.plusEffect, AmbientGHZ.plusVector,
        Matrix.vecMulVec, Matrix.smul_apply]

theorem minus_diag (d : ℕ) (hd : 0 < d) (i : Register d) :
    (fullGHZ d 1 i i).re =
      if i = z d then (1 / 2 : ℝ)
      else if i = o d then 1 / 2 else 0 := by
  classical
  have hab := PhysicalNumerator.two_GHZ_rays_distinct d hd
  by_cases ha : i = z d
  · simp [ha, fullGHZ, AmbientGHZ.ghzAmbient,
      AmbientGHZ.minusEffect, AmbientGHZ.minusVector,
      Matrix.vecMulVec, Matrix.smul_apply]
  · by_cases hb : i = o d
    · simp [ha, hb, fullGHZ, AmbientGHZ.ghzAmbient,
        AmbientGHZ.minusEffect, AmbientGHZ.minusVector,
        Matrix.vecMulVec, Matrix.smul_apply]
    · simp [ha, hb, fullGHZ, AmbientGHZ.ghzAmbient,
        AmbientGHZ.minusEffect, AmbientGHZ.minusVector,
        Matrix.vecMulVec, Matrix.smul_apply]

theorem plus_actual_source_born (d : ℕ) (hd : 0 < d) :
    bornDen d (fullGHZ d 0) =
      (SourceBorn.sourceWeight d (z d) + SourceBorn.sourceWeight d (o d)) / 2 := by
  rw [bornDen_actual_weight]
  unfold SourceBorn.sourceBornWeight
  simp_rw [plus_diag d hd]
  exact source_weight_pair_sum (z d) (o d)
    (PhysicalNumerator.two_GHZ_rays_distinct d hd) (SourceBorn.sourceWeight d)

theorem minus_actual_source_born (d : ℕ) (hd : 0 < d) :
    bornDen d (fullGHZ d 1) =
      (SourceBorn.sourceWeight d (z d) + SourceBorn.sourceWeight d (o d)) / 2 := by
  rw [bornDen_actual_weight]
  unfold SourceBorn.sourceBornWeight
  simp_rw [minus_diag d hd]
  exact source_weight_pair_sum (z d) (o d)
    (PhysicalNumerator.two_GHZ_rays_distinct d hd) (SourceBorn.sourceWeight d)

theorem complement_num_zero (d : ℕ) (hd : 0 < d) :
    bornNum d (fullGHZ d 2) = 0 := by
  rw [bornNum_coherence d hd _ (fullGHZ_positive d 2)]
  have h : (fullGHZ d 2 (z d) (o d)).re = 0 := by
    simpa [fullGHZ, z, o] using
      (AmbientGHZ.ambient_ghz_corner_values (z d) (o d)
        (PhysicalNumerator.two_GHZ_rays_distinct d hd)).2.2.2.2.2.2.2.2
  rw [h]
  ring

theorem full_GHZ_attains_actual_physical_bound
    (d : ℕ) (hd : 0 < d) :
    (∑ out : Fin 3, (bornNum d (fullGHZ d out)) ^ 2 /
      bornDen d (fullGHZ d out)) =
      4 * ((unnormalizedA d (z d) (o d)).re) ^ 2 /
        (SourceBorn.sourceWeight d (z d) +
          SourceBorn.sourceWeight d (o d)) := by
  have hab := PhysicalNumerator.two_GHZ_rays_distinct d hd
  have hcorner := AmbientGHZ.ambient_ghz_corner_values (z d) (o d) hab
  rcases hcorner with ⟨h00, h10, h01, h11, hco, hcm, h20, h21, h2c⟩
  have hnplus : bornNum d (fullGHZ d 0) =
      (unnormalizedA d (z d) (o d)).re := by
    rw [bornNum_coherence d hd _ (fullGHZ_positive d 0), hco]
    ring
  have hnminus : bornNum d (fullGHZ d 1) =
      -(unnormalizedA d (z d) (o d)).re := by
    rw [bornNum_coherence d hd _ (fullGHZ_positive d 1), hcm]
    ring
  have hden : (SourceBorn.sourceWeight d (z d) +
    SourceBorn.sourceWeight d (o d)) ≠ 0 := by
    have hp := SourceBorn.sourceWeight_pos d (z d)
    have hq := SourceBorn.sourceWeight_pos d (o d)
    exact (add_pos hp hq).ne'
  simp only [Fin.sum_univ_three]
  rw [hnplus, hnminus, complement_num_zero d hd,
    plus_actual_source_born d hd, minus_actual_source_born d hd]
  field_simp
  <;> ring

theorem actual_physical_povm_optimal
    (d : ℕ) (hd : 0 < d)
    {Out : Type*} [Fintype Out]
    (E : Out → Matrix (Register d) (Register d) ℂ)
    (hpositive : ∀ out, (E out).PosSemidef)
    (hcomplete : (∑ out, E out) = 1) :
    (∑ out, (bornNum d (E out)) ^ 2 / bornDen d (E out)) ≤
      (∑ out : Fin 3, (bornNum d (fullGHZ d out)) ^ 2 /
        bornDen d (fullGHZ d out)) := by
  rw [full_GHZ_attains_actual_physical_bound d hd]
  exact all_physical_povms_bounded d hd E hpositive hcomplete

#print axioms Nightfall.Quantum.ActualBornTerminal.bornNum_coherence
#print axioms Nightfall.Quantum.ActualBornTerminal.bornDen_actual_weight
#print axioms Nightfall.Quantum.ActualBornTerminal.all_physical_povms_bounded
#print axioms Nightfall.Quantum.ActualBornTerminal.fullGHZ_positive
#print axioms Nightfall.Quantum.ActualBornTerminal.fullGHZ_complete
#print axioms Nightfall.Quantum.ActualBornTerminal.plus_actual_source_born
#print axioms Nightfall.Quantum.ActualBornTerminal.minus_actual_source_born
#print axioms Nightfall.Quantum.ActualBornTerminal.full_GHZ_attains_actual_physical_bound
#print axioms Nightfall.Quantum.ActualBornTerminal.actual_physical_povm_optimal

end
end Nightfall.Quantum.ActualBornTerminal
