import StrongMarkovInterval

/-!
# Scalar endpoint-to-endpoint stability along a product-expectation polynomial path

No Markov derivative bound is assumed. The hypothesis that the given
degree-d polynomial is in [0,1] for every parameter in [0,1/eta]
is the exact *probability path* obligation of the common-part product
decomposition. This theorem is not yet the final product-source theorem:
a separate finite probability lemma must establish that hypothesis.
-/
namespace Nightfall.BiasFreeMarkov

open Polynomial Set

theorem markov_path_stability
    (P : Polynomial ℝ) (d : ℕ) (η : ℝ)
    (hη : 0 < η) (hη1 : η ≤ 1)
    (hdeg : P.natDegree ≤ d)
    (hrange : ∀ s ∈ Set.Icc (0 : ℝ) (1 / η),
       0 ≤ P.eval s ∧ P.eval s ≤ 1) :
    |P.eval 1 - P.eval 0| ≤ 2 * (d : ℝ) ^ 2 * η := by
  have hη0 : η ≠ 0 := ne_of_gt hη
  have hL : 0 < (1 / η : ℝ) := div_pos (by norm_num) hη
  have hone : (1 : ℝ) ≤ 1 / η :=
    (le_div_iff₀ hη).mpr (by nlinarith [hη1])
  have hcont : ContinuousOn (fun s : ℝ => P.eval s) (Set.Icc 0 1) := by
    apply Continuous.continuousOn
    exact continuous_iff_continuousAt.mpr (fun x =>
      (P.differentiableAt (x := x)).continuousAt)
  have hdiff : DifferentiableOn ℝ (fun s : ℝ => P.eval s) (Set.Ioo 0 1) := by
    intro x hx
    exact (P.differentiableAt (x := x)).differentiableWithinAt
  obtain ⟨c, hc, hderiv⟩ :=
    exists_deriv_eq_slope (f := fun s : ℝ => P.eval s)
      (a := 0) (b := 1) (by norm_num) hcont hdiff
  have hc0 : 0 ≤ c := hc.1.le
  have hcL : c ≤ 1 / η := le_trans hc.2.le hone
  have hm := markov_derivative_interval P d (1 / η) c
    hL hc0 hcL hdeg hrange
  have hmv : (derivative P).eval c = P.eval 1 - P.eval 0 := by
    rw [← P.deriv]
    simpa using hderiv
  rw [hmv] at hm
  have hh : 0 < 2 * η := by positivity
  have hratio : |P.eval 1 - P.eval 0| / (2 * η) ≤
      (d : ℝ) ^ 2 := by
    convert hm using 1 <;> field_simp [hη0] <;> ring
  have hres := (div_le_iff₀ hh).mp hratio
  nlinarith

end Nightfall.BiasFreeMarkov
