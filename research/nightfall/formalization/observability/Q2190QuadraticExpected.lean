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
  (∑ i : ι, theta*(b i) + sign*r*(a i)) +
  (∑ j : E, theta^2*(c j) + sign*r*theta*(d j) + r^2*(e j))

theorem quadraticExpectation_sign_difference
    (m : ℝ) (a b : ι → ℝ) (c d e : E → ℝ) (theta : ℝ) :
    quadraticExpectation m a b c d e theta 1 -
      quadraticExpectation m a b c d e theta (-1) =
      2*r*((∑ i : ι, a i) + theta*(∑ j : E, d j)) := by
  classical
  unfold quadraticExpectation
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum]
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
  have hh := fourpoint_derivative_factor
  have hfactor :
    A*(2*r*((∑ i : ι, a i)+D*(∑ j : E, d j))) -
      D*(2*r*((∑ i : ι, a i)+A*(∑ j : E, d j))) =
        (2*r*(A-D))*(∑ i : ι, a i) := by ring
  rw [hfactor, hh]
  ring

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
  have hquad := quadraticExpectation_fourpoint_exact (ι:=ι) (E:=E) m a b c d e
  rw [← hquad]
  exact fourpoint_functional_bound _ _ _ _ B h1 h2 h3 h4

end Nightfall.Q2190
