import Q2190FourPoint

/-!
# Exact quadratic expectation interpolation for spherical source rotations

The actual four normalized product expectations have this algebraic
shape whenever f is pointwise degree ≤2 under its original source.
This file certifies the four-value elimination of all even effects and
mixed interactions, with no trigonometric theorem or numerical tolerance.

Source realization (producing the coefficients from f,p and four
normalized product laws) is a separate gate, not assumed proved here.
-/

namespace Nightfall.Q2190
open Finset

variable {ι E : Type*} [Fintype ι] [Fintype E]

noncomputable def quadraticExpectation
    (m : ℝ) (a b : ι → ℝ) (c d e : E → ℝ)
    (theta sign : ℝ) : ℝ :=
  m +
  (∑ i : ι, theta*b i + sign*r*a i) +
  (∑ j : E, theta^2*c j + sign*r*theta*d j + r^2*e j)

theorem quadraticExpectation_sign_difference
    (m : ℝ) (a b : ι → ℝ) (c d e : E → ℝ) (theta : ℝ) :
    quadraticExpectation m a b c d e theta 1 -
      quadraticExpectation m a b c d e theta (-1) =
      2*r*((∑ i : ι, a i) + theta*(∑ j : E, d j)) := by
  classical
  unfold quadraticExpectation
  rw [add_sub_add_left_eq_sub, add_sub_add_left_eq_sub]
  rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib]
  simp only [one_mul, neg_one_mul]
  rw [← Finset.mul_sum, ← Finset.mul_sum]
  ring

/-- Exact four-sample cancellation of the pair-interaction contributions,
with the genuine frequency-two coefficient r=sqrt(2)/2. -/
theorem quadraticExpectation_fourpoint_exact
    (m : ℝ) (a b : ι → ℝ) (c d e : E → ℝ) :
    A*(quadraticExpectation m a b c d e D 1 -
         quadraticExpectation m a b c d e D (-1)) -
      D*(quadraticExpectation m a b c d e A 1 -
         quadraticExpectation m a b c d e A (-1)) =
      (∑ i : ι, a i) := by
  rw [quadraticExpectation_sign_difference,
      quadraticExpectation_sign_difference]
  have h := fourpoint_derivative_factor
  nlinarith

/-- Exact dimension-free first-chaos budget with four genuine bounded
evaluation outputs. The source bridge must independently provide
these four values as actual expectations. -/
theorem quadraticExpectation_first_chaos_bound
    (m : ℝ) (a b : ι → ℝ) (c d e : E → ℝ) (B : ℝ)
    (h1 : |quadraticExpectation m a b c d e D 1| ≤ B)
    (h2 : |quadraticExpectation m a b c d e A 1| ≤ B)
    (h3 : |quadraticExpectation m a b c d e A (-1)| ≤ B)
    (h4 : |quadraticExpectation m a b c d e D (-1)| ≤ B) :
    |∑ i : ι, a i| ≤ 2*B := by
  rw [← quadraticExpectation_fourpoint_exact]
  exact fourpoint_functional_bound _ _ _ _ B h1 h2 h3 h4

end Nightfall.Q2190
