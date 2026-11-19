import StrongMarkovRescale

/-!
# Full affine endpoint Markov inequality, derived from pinned Chebyshev extremality

No derivative-bound hypothesis. Bounds the derivative of any polynomial at a
chosen endpoint in terms of the interval length and the polynomial's degree
when its values are in [0,1] along the interval.
This is a genuine, dimension-free analytic inequality; to obtain the
bias-free product stability theorem one must additionally connect finite
product expectations and the common-part affine paths, and apply the
mean-value theorem. Those bridges are not assumed to be completed here.
-/

namespace Nightfall.BiasFreeMarkov

open Polynomial

theorem markov_endpoint_affine
    (P : Polynomial ℝ) (d : ℕ) (a b : ℝ)
    (hdeg : P.natDegree ≤ d)
    (hrange : ∀ t ∈ Set.Icc (-1 : ℝ) 1,
      0 ≤ P.eval ((a + b) / 2 + (a - b) / 2 * t) ∧
      P.eval ((a + b) / 2 + (a - b) / 2 * t) ≤ 1) :
    |a - b| * |(derivative P).eval a| ≤ (d : ℝ) ^ 2 := by
  let Q := normalizedEndpointPoly P a b
  have hqd : Q.natDegree ≤ d :=
    normalizedEndpointPoly_natDegree_le P a b d hdeg
  have hQdeg : Q.degree ≤ (d : WithBot ℕ) :=
    (Polynomial.natDegree_le_iff_degree_le).mp hqd
  have hQrange : ∀ t ∈ Set.Icc (-1 : ℝ) 1, |Q.eval t| ≤ 1 := by
    intro t ht
    obtain ⟨hp0, hp1⟩ := hrange t ht
    rw [show Q.eval t = 2 * P.eval ((a + b) / 2 + (a - b) / 2 * t) - 1 from
      normalizedEndpointPoly_eval P a b t]
    exact abs_le.mpr (by constructor <;> linarith)
  have hmk := chebyshev_endpoint_derivative_bound Q d hQdeg hQrange
  have heq : (derivative Q).eval 1 =
      (a - b) * (derivative P).eval a :=
    normalizedEndpointPoly_derivative_eval_one P a b
  rw [heq, abs_mul] at hmk
  exact hmk

end Nightfall.BiasFreeMarkov
