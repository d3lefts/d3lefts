import Mathlib
import PhysicalSourceBorn

/-!
NIGHTFALL — the real source Born outcome mass is the trace of the
actual finite pure-state sum multiplied by a physical POVM effect.

The unnormalized source operator here is already derived from pure
product density matrices and proved to have nonnegative diagonal
entries. This is a transitive trace bridge, not a GHZ-attaining full
measurement or the final (pq)^d coefficient normalization.
-/

namespace Nightfall.Quantum.SourceBornTrace

open scoped BigOperators ComplexOrder Matrix
open Matrix
open Nightfall.Quantum.SourceBorn
noncomputable section

theorem actual_source_B_offdiagonal
    (d : ℕ) (a b : Register d) (hab : a ≠ b) :
    OperatorReduction.unnormalizedB d a b = 0 := by
  by_cases h : ∃ j : Fin d, a j ≠ b j
  · rcases h with ⟨j, hj⟩
    exact OperatorReduction.actual_B_offdiagonal d a b j hj
  · push_neg at h
    exact (hab (funext h)).elim

theorem actual_source_B_is_diagonal (d : ℕ) :
    OperatorReduction.unnormalizedB d =
      Matrix.diagonal (fun a : Register d => (sourceWeight d a : ℂ)) := by
  classical
  ext a b
  by_cases h : a = b
  · subst b
    rw [actual_source_B_diagonal_is_weight]
    simp [Matrix.diagonal_apply]
  · rw [actual_source_B_offdiagonal d a b h]
    simp [Matrix.diagonal_apply, h]

theorem trace_actual_source_effect
    (d : ℕ) (E : Matrix (Register d) (Register d) ℂ) :
    Matrix.trace (OperatorReduction.unnormalizedB d * E) =
      ∑ a : Register d, (sourceWeight d a : ℂ) * E a a := by
  rw [actual_source_B_is_diagonal]
  simp [Matrix.trace, Matrix.mul_apply, Matrix.diagonal_apply]

private theorem complex_re_source_diagonal_sum
    (d : ℕ) (E : Matrix (Register d) (Register d) ℂ) :
    (∑ a : Register d, (sourceWeight d a : ℂ) * E a a).re =
      sourceBornWeight d E := by
  classical
  unfold sourceBornWeight
  have h (s : Finset (Register d)) :
      Complex.re (s.sum (fun a => (sourceWeight d a : ℂ) * E a a)) =
        s.sum (fun a => sourceWeight d a * (E a a).re) := by
    induction s using Finset.induction_on with
    | empty => simp
    | @insert a s ha ih =>
        simp [Finset.sum_insert ha, Complex.add_re, Complex.mul_re, ih]
  exact h Finset.univ

theorem actual_source_born_is_real_trace
    (d : ℕ) (E : Matrix (Register d) (Register d) ℂ) :
    sourceBornWeight d E =
      (Matrix.trace (OperatorReduction.unnormalizedB d * E)).re := by
  rw [trace_actual_source_effect]
  exact (complex_re_source_diagonal_sum d E).symm

theorem physical_povm_upper_with_actual_source_trace
    (d : ℕ) (hd : 0 < d)
    {Out : Type*} [Fintype Out]
    (E : Out → Matrix (Register d) (Register d) ℂ)
    (hpositive : ∀ z, (E z).PosSemidef)
    (hcomplete : (∑ z, E z) = 1)
    (t : ℝ) :
    (∑ z, (2 * t * (E z (zeroRay d) (oneRay d)).re) ^ 2 /
      (Matrix.trace (OperatorReduction.unnormalizedB d * E z)).re) ≤
      4 * t ^ 2 /
        (sourceWeight d (zeroRay d) + sourceWeight d (oneRay d)) := by
  simpa only [actual_source_born_is_real_trace] using
    (physical_source_bayes_upper d hd E hpositive hcomplete t)

#print axioms Nightfall.Quantum.SourceBornTrace.actual_source_B_offdiagonal
#print axioms Nightfall.Quantum.SourceBornTrace.actual_source_B_is_diagonal
#print axioms Nightfall.Quantum.SourceBornTrace.trace_actual_source_effect
#print axioms Nightfall.Quantum.SourceBornTrace.actual_source_born_is_real_trace
#print axioms Nightfall.Quantum.SourceBornTrace.physical_povm_upper_with_actual_source_trace

end
end Nightfall.Quantum.SourceBornTrace
