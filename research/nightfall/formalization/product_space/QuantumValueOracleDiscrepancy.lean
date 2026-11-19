import Mathlib

/-!
# Exact local discrepancy for coherent finite-symbol value oracles

Let a coherent input oracle add v_i to a finite additive answer register.
This module derives a *real squared Hilbert norm* estimate directly from
complex-amplitude coordinates: the squared norm of the difference between
the two oracle outputs is at most four times the input query weight on
indices where the source symbols differ. No global hybrid inequality is
assumed, no approximation, positivity margin, or probability source appears.

This supplies the local squared-norm input for the telescope in #914.
The final sqrt conversion and the Born measurement Lipschitz inequality
remain separate composition steps.
-/

namespace Nightfall.QuantumValueOracleDiscrepancy

open Finset

/-- Literal complex squared magnitude, to avoid hiding the operator model. -/
noncomputable def sqmag (z : ℂ) : ℝ := z.re ^ 2 + z.im ^ 2

/-- Euclidean two-point inequality for true complex amplitudes. -/
theorem sqmag_sub_le (a b : ℂ) :
    sqmag (a - b) ≤ 2 * sqmag a + 2 * sqmag b := by
  unfold sqmag
  simp only [Complex.sub_re, Complex.sub_im]
  nlinarith [sq_nonneg (a.re + b.re), sq_nonneg (a.im + b.im)]

variable {I Z : Type*} [Fintype I] [Fintype Z] [AddCommGroup Z]

/-- Translation is a bijection of the answer register. -/
def translate (v : Z) : Z ≃ Z where
  toFun z := z + v
  invFun z := z - v
  left_inv := by intro z; simp
  right_inv := by intro z; simp

/-- Every coherent value-oracle answer translation preserves coordinate norm. -/
theorem sum_sqmag_shift (ψ : Z → ℂ) (v : Z) :
    (∑ z : Z, sqmag (ψ (z - v))) = ∑ z : Z, sqmag (ψ z) := by
  classical
  apply Fintype.sum_equiv (translate v).symm
      (fun z : Z => sqmag (ψ (z - v)))
      (fun z : Z => sqmag (ψ z))
  intro z
  rfl

/-- The usual coherent value-oracle amplitude action. -/
noncomputable def oracle (v : I → Z) (ψ : I → Z → ℂ) : I → Z → ℂ :=
  fun i z => ψ i (z - v i)

/-- Squared real Hilbert discrepancy of two complete oracle outputs. -/
noncomputable def discrepancySq (v w : I → Z) (ψ : I → Z → ℂ) : ℝ :=
  ∑ i : I, ∑ z : Z, sqmag (oracle v ψ i z - oracle w ψ i z)

/-- Query weight on the source-symbol mismatch support. -/
noncomputable def mismatchWeight (v w : I → Z) (ψ : I → Z → ℂ) : ℝ :=
  ∑ i ∈ (Finset.univ.filter (fun i : I => v i ≠ w i)),
    ∑ z : Z, sqmag (ψ i z)

/-- **Concrete value-oracle local quantum discrepancy.** The entire complex
amplitude vector is used; the estimate is independent of input length and
alphabet size and permits arbitrary zero-amplitude index sectors. -/
theorem value_oracle_discrepancy_sq_le (v w : I → Z) (ψ : I → Z → ℂ) :
    discrepancySq v w ψ ≤ 4 * mismatchWeight v w ψ := by
  classical
  have hstep (i : I) :
      (∑ z : Z, sqmag (ψ i (z - v i) - ψ i (z - w i))) ≤
      if v i ≠ w i then 4 * (∑ z : Z, sqmag (ψ i z)) else 0 := by
    by_cases hi : v i = w i
    · simp [hi, sqmag]
    · simp only [if_pos hi]
      calc
        (∑ z : Z, sqmag (ψ i (z - v i) - ψ i (z - w i))) ≤
          ∑ z : Z, (2 * sqmag (ψ i (z - v i)) +
                      2 * sqmag (ψ i (z - w i))) := by
            apply Finset.sum_le_sum
            intro z _
            exact sqmag_sub_le _ _
        _ = 2 * (∑ z : Z, sqmag (ψ i (z - v i))) +
            2 * (∑ z : Z, sqmag (ψ i (z - w i))) := by
              simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
        _ = 4 * (∑ z : Z, sqmag (ψ i z)) := by
              rw [sum_sqmag_shift (ψ i) (v i),
                  sum_sqmag_shift (ψ i) (w i)]
              ring
  unfold discrepancySq oracle mismatchWeight
  calc
    (∑ i : I, ∑ z : Z,
      sqmag (ψ i (z - v i) - ψ i (z - w i))) ≤
      ∑ i : I, if v i ≠ w i then
        4 * (∑ z : Z, sqmag (ψ i z)) else 0 := by
          exact Finset.sum_le_sum (fun i _ => hstep i)
    _ = 4 * (∑ i ∈ (Finset.univ.filter (fun i : I => v i ≠ w i)),
                 ∑ z : Z, sqmag (ψ i z)) := by
          simp only [Finset.sum_ite, ← Finset.mul_sum]

end Nightfall.QuantumValueOracleDiscrepancy

#print axioms Nightfall.QuantumValueOracleDiscrepancy.sqmag_sub_le
#print axioms Nightfall.QuantumValueOracleDiscrepancy.sum_sqmag_shift
#print axioms Nightfall.QuantumValueOracleDiscrepancy.value_oracle_discrepancy_sq_le
