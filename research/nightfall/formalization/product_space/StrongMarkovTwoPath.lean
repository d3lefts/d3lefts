import StrongMarkovPathStability

/-!
# Bias-floor-free two-product-path Markov stability

A concrete analytic theorem for the common-part product interpolation:
two bounded degree-d polynomial expectation paths defined on [0,1/eta],
with identical values at 0, differ by at most 4 d² eta at 1.
This is proved using Chebyshev extremality + MVT, **not a supplied
Markov derivative bound**.

It remains to construct these two paths for arbitrary finite product
laws and identify the endpoint expectations. The universal product-law
theorem and the quantum/mixture terminal are NOT claimed here.
-/

namespace Nightfall.BiasFreeMarkov

open Polynomial

theorem bias_free_two_path_stability
    (Pu Pv : Polynomial ℝ) (d : ℕ) (η : ℝ)
    (hη : 0 < η) (hη1 : η ≤ 1)
    (hdu : Pu.natDegree ≤ d) (hdv : Pv.natDegree ≤ d)
    (hru : ∀ s ∈ Set.Icc (0 : ℝ) (1 / η),
        0 ≤ Pu.eval s ∧ Pu.eval s ≤ 1)
    (hrv : ∀ s ∈ Set.Icc (0 : ℝ) (1 / η),
        0 ≤ Pv.eval s ∧ Pv.eval s ≤ 1)
    (hstart : Pu.eval 0 = Pv.eval 0) :
    |Pu.eval 1 - Pv.eval 1| ≤ 4 * (d : ℝ) ^ 2 * η := by
  have hu := markov_path_stability Pu d η hη hη1 hdu hru
  have hv := markov_path_stability Pv d η hη hη1 hdv hrv
  have ht := abs_add_le (Pu.eval 1 - Pu.eval 0)
    (Pv.eval 0 - Pv.eval 1)
  have heq : Pu.eval 1 - Pv.eval 1 =
      (Pu.eval 1 - Pu.eval 0) + (Pv.eval 0 - Pv.eval 1) := by
    rw [← hstart]
    ring
  rw [heq]
  rw [abs_sub_comm (Pv.eval 1) (Pv.eval 0)] at hv
  nlinarith

end Nightfall.BiasFreeMarkov
