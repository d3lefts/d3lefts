import Mathlib

/-!
# NIGHTFALL: abstract iterated Poincare derivative hierarchy

This proves an ALL-DEGREE operator theorem for an abstract finite family
of derivatives, a variance functional and an expectation functional.
Only the true-law Poincare inequality and the second-moment decomposition
are hypotheses; no pre-supplied hierarchy recurrence is used.

To obtain a theorem for an actual binary probability law, a separate
source-level instantiation of these functional hypotheses is still required.
-/

namespace Nightfall.CubicContractionOperator

variable {ι F : Type*} [Fintype ι]

/-- Algebraic termination: all derivatives of length d have zero variance. -/
def DegreeZero (D : ι → F → F) (v : F → ℝ) : ℕ → F → Prop
  | 0, f => v f = 0
  | k + 1, f => ∀ i : ι, DegreeZero D v k (D i f)

/-- Recursive expected-derivative energy, with ordered tuple multiplicity. -/
def Cost (A : ℝ) (D : ι → F → F) (m : F → ℝ) : ℕ → F → ℝ
  | 0, _ => 0
  | k + 1, f =>
      A * ∑ i : ι, ((m (D i f))^2 + Cost A D m k (D i f))

/--
Poincare plus the second-moment identity implies the full hierarchy
without a caller-supplied k-level energy recurrence.
-/
theorem variance_le_derivative_cost
    (A : ℝ) (hA : 0 ≤ A)
    (D : ι → F → F) (mean variance second : F → ℝ)
    (hsecond : ∀ g : F, second g = (mean g)^2 + variance g)
    (hpoincare : ∀ g : F,
      variance g ≤ A * ∑ i : ι, second (D i g)) :
    ∀ (k : ℕ) (f : F),
      DegreeZero D variance k f →
      variance f ≤ Cost A D mean k f := by
  classical
  intro k
  induction k with
  | zero =>
      intro f hdegree
      simpa [DegreeZero, Cost] using le_of_eq hdegree
  | succ k ih =>
      intro f hdegree
      have hchild : ∀ i : ι,
          variance (D i f) ≤ Cost A D mean k (D i f) := by
        intro i
        exact ih (D i f) (hdegree i)
      have hsum :
          (∑ i : ι, ((mean (D i f))^2 + variance (D i f))) ≤
          (∑ i : ι, ((mean (D i f))^2 +
              Cost A D mean k (D i f))) := by
        apply Finset.sum_le_sum
        intro i hi
        exact add_le_add_left (hchild i) _
      have hp := hpoincare f
      simp_rw [hsecond] at hp
      have hscaled := mul_le_mul_of_nonneg_left hsum hA
      exact le_trans hp (by simpa [Cost] using hscaled)

#check Nightfall.CubicContractionOperator.DegreeZero
#check Nightfall.CubicContractionOperator.Cost
#check Nightfall.CubicContractionOperator.variance_le_derivative_cost
#print axioms Nightfall.CubicContractionOperator.variance_le_derivative_cost

end Nightfall.CubicContractionOperator
