import Mathlib

/-!
NIGHTFALL quantum SLD: source-independent REAL scalar and GHZ-corner lemmas.

These are audited algebraic sublemmas only, NOT the full complex density
matrix/POVM physical-operator proof. The exact operational derivation and
remaining formalization obligations are documented in
research/nightfall/2026-11-crossfrontier/SLD_OPERATIONAL_PROOF.md.
-/

namespace Nightfall.Quantum.SLDOperationalCorner

theorem symmetric_log_derivative_corner
    (u v t : ℝ) (h : u + v ≠ 0) :
    u * (2 * t / (u + v)) +
      v * (2 * t / (u + v)) = 2 * t := by
  field_simp [h] <;> ring

theorem sld_energy_corner
    (u v t : ℝ) :
    2 * t * (2 * t / (u + v)) =
      4 * t ^ 2 / (u + v) := by
  ring

theorem physical_ghz_measurement_matches_sld_energy
    (u v t : ℝ) (h : 0 < u + v) :
    2 * ((u + v) / 2) * (2 * t / (u + v)) ^ 2 =
      4 * t ^ 2 / (u + v) := by
  have hn : u + v ≠ 0 := ne_of_gt h
  field_simp [hn] <;> ring

-- Exact rational physical p=3/4, q=1/4 cases. These independently
-- detect factor-of-two errors in the SLD/GHZ gain normalization.
theorem physical_gain_one_register :
    (((3 : ℚ) / 4) * (1 / 4)) /
      (((3 : ℚ) / 4) + (1 / 4)) = 3 / 16 := by
  norm_num

theorem physical_gain_two_registers :
    ((((3 : ℚ) / 4) * (1 / 4)) ^ 2) /
      ((((3 : ℚ) / 4) ^ 2) + ((1 / 4) ^ 2)) = 9 / 160 := by
  norm_num

#print axioms Nightfall.Quantum.SLDOperationalCorner.symmetric_log_derivative_corner
#print axioms Nightfall.Quantum.SLDOperationalCorner.sld_energy_corner
#print axioms Nightfall.Quantum.SLDOperationalCorner.physical_ghz_measurement_matches_sld_energy
#print axioms Nightfall.Quantum.SLDOperationalCorner.physical_gain_one_register
#print axioms Nightfall.Quantum.SLDOperationalCorner.physical_gain_two_registers

end Nightfall.Quantum.SLDOperationalCorner
