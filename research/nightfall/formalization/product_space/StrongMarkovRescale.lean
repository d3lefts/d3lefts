import StrongMarkovEndpoint

/-!
# Affine rescaling of Chebyshev endpoint Markov inequality

Constructs the normalized polynomial
  Q(t)=2 P((a+b)/2+(a-b)t/2)-1.
Its endpoint t=1 is the chosen original location a, and the
derivative rescales by exactly (a-b). No derivative estimate
is introduced as a hypothesis.
-/
namespace Nightfall.BiasFreeMarkov

open Polynomial

noncomputable def endpointAffine (a b : ℝ) : Polynomial ℝ :=
  C ((a + b) / 2) + C ((a - b) / 2) * X

theorem endpointAffine_eval (a b t : ℝ) :
    (endpointAffine a b).eval t =
      (a + b) / 2 + (a - b) / 2 * t := by
  simp [endpointAffine]

theorem endpointAffine_eval_one (a b : ℝ) :
    (endpointAffine a b).eval 1 = a := by
  rw [endpointAffine_eval]
  ring

theorem endpointAffine_derivative (a b : ℝ) :
    derivative (endpointAffine a b) = C ((a - b) / 2) := by
  simp [endpointAffine, derivative_add, derivative_C_mul_X]

theorem endpointAffine_natDegree_le_one (a b : ℝ) :
    (endpointAffine a b).natDegree ≤ 1 := by
  unfold endpointAffine
  have h := Polynomial.natDegree_add_le
    (C ((a + b) / 2) : Polynomial ℝ)
    (C ((a - b) / 2) * X)
  have hm : (C ((a - b) / 2) * X).natDegree ≤ 1 := by
    simpa using Polynomial.natDegree_C_mul_le ((a - b) / 2) (X : Polynomial ℝ)
  have hc : (C ((a + b) / 2) : Polynomial ℝ).natDegree ≤ 1 := by simp
  exact h.trans (max_le hc hm)

noncomputable def normalizedEndpointPoly
    (P : Polynomial ℝ) (a b : ℝ) : Polynomial ℝ :=
  C 2 * P.comp (endpointAffine a b) - C 1

theorem normalizedEndpointPoly_eval
    (P : Polynomial ℝ) (a b t : ℝ) :
    (normalizedEndpointPoly P a b).eval t =
      2 * P.eval ((a + b) / 2 + (a - b) / 2 * t) - 1 := by
  simp [normalizedEndpointPoly, Polynomial.eval_comp, endpointAffine_eval]

theorem normalizedEndpointPoly_natDegree_le
    (P : Polynomial ℝ) (a b : ℝ) (d : ℕ)
    (hdeg : P.natDegree ≤ d) :
    (normalizedEndpointPoly P a b).natDegree ≤ d := by
  unfold normalizedEndpointPoly
  have hcomp := Polynomial.natDegree_comp_le
    (p := P) (q := endpointAffine a b)
  have hq := endpointAffine_natDegree_le_one a b
  have hcomp' : (P.comp (endpointAffine a b)).natDegree ≤ d := by
    calc
      (P.comp (endpointAffine a b)).natDegree ≤
        P.natDegree * (endpointAffine a b).natDegree := hcomp
      _ ≤ d * 1 := Nat.mul_le_mul hdeg hq
      _ = d := by simp
  have hmul : (C (2 : ℝ) * P.comp (endpointAffine a b)).natDegree ≤ d :=
    (Polynomial.natDegree_C_mul_le (2 : ℝ)
      (P.comp (endpointAffine a b))).trans hcomp'
  have hminus := Polynomial.natDegree_sub_le
    (C (2 : ℝ) * P.comp (endpointAffine a b)) (C (1 : ℝ))
  have hconst : (C (1 : ℝ) : Polynomial ℝ).natDegree ≤ d := by simp
  exact hminus.trans (max_le hmul hconst)

theorem normalizedEndpointPoly_derivative_eval_one
    (P : Polynomial ℝ) (a b : ℝ) :
    (derivative (normalizedEndpointPoly P a b)).eval 1 =
      (a - b) * (derivative P).eval a := by
  unfold normalizedEndpointPoly
  rw [derivative_sub, derivative_C, sub_zero, derivative_mul,
    derivative_C, zero_mul, zero_add, derivative_comp]
  rw [endpointAffine_derivative]
  simp [Polynomial.eval_mul, Polynomial.eval_comp,
    endpointAffine_eval_one]
  ring

end Nightfall.BiasFreeMarkov
