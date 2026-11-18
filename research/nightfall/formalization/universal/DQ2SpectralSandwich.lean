import Mathlib

/-!
# Finite quadratic spectral-sandwich algebraic composition

This is a named, fully quantified *conditional transfer* gate. It derives
the exact 4 A^4/(v gamma) coefficient from
(1) true-law heat-bath Poincare,
(2) the upper/lower quadratic site-gradient comparisons,
(3) a dimension-free finite-product Q2 endpoint.

The hypotheses must be instantiated with genuine law and covariance lemmas.
This module by itself is NOT the all-graph Ising theorem, does NOT certify the
signed conditional-score estimate, and does not assert prior-art novelty.
-/

namespace Nightfall.DQ2SpectralSandwich

open Finset

/-- Formal variance of the fair independent-sign reference quadratic.
For symmetric zero-diagonal b, this is sum a_i² + sum_{i<j} b_ij². -/
noncomputable def referenceQuadraticVariance {n : ℕ}
    (a : Fin n → ℝ) (b : Fin n → Fin n → ℝ) : ℝ :=
  (∑ i : Fin n, (a i)^2) +
    (1 / 2 : ℝ) * (∑ i : Fin n, ∑ j : Fin n, (b i j)^2)

/-- Formal reference coordinate influence of a quadratic polynomial,
with a symmetric zero-diagonal coefficient matrix b. -/
noncomputable def referenceSiteInfluence {n : ℕ}
    (a : Fin n → ℝ) (b : Fin n → Fin n → ℝ) (i : Fin n) : ℝ :=
  (a i)^2 + ∑ j : Fin n, (b i j)^2

/-- **Finite spectral-sandwich algebraic transfer.**
The source covariance and true-law conditional-variance floor have already
been used to derive the two per-site assumptions. The original finite Q2
endpoint is represented by its universal cap principle `hQ2`, not by
a caller-supplied numerical conclusion for one selected M.

The conclusion is exactly the dimension-free 4 A^4/(v gamma) transfer,
without any dependence on n. For a finite Ising law, a separate theorem
must discharge hPoincare, hSiteUpper, hSiteLower from original measures. -/
theorem quadratic_spectral_sandwich
    {n : ℕ}
    (a : Fin n → ℝ) (b : Fin n → Fin n → ℝ)
    (Iν : Fin n → ℝ) (Vν B M A v γ K : ℝ)
    (hA : 1 ≤ A) (hvg : 0 < v * γ) (hM : 0 ≤ M) (hVν : 0 ≤ Vν)
    (hPoincare : Vν ≤ A * ∑ i : Fin n, Iν i)
    (hSiteUpper : ∀ i : Fin n,
      Iν i ≤ (a i)^2 + A * ∑ j : Fin n, (b i j)^2)
    (hSiteLower : ∀ i : Fin n,
      (v * γ) * referenceSiteInfluence a b i ≤ Iν i)
    (hCap : ∀ i : Fin n, Iν i ≤ M)
    (hQ2 : ∀ N : ℝ, 0 ≤ N →
      (∀ i : Fin n, referenceSiteInfluence a b i ≤ N) →
      (referenceQuadraticVariance a b)^2 ≤ K * B^2 * N) :
    Vν^2 ≤ (4 * K * A^4 / (v * γ)) * B^2 * M := by
  let Sa : ℝ := ∑ i : Fin n, (a i)^2
  let Sb : ℝ := ∑ i : Fin n, ∑ j : Fin n, (b i j)^2
  have hSa : 0 ≤ Sa := Finset.sum_nonneg (fun i hi => sq_nonneg (a i))
  have hA0 : 0 ≤ A := le_trans (by norm_num) hA
  have hsum : (∑ i : Fin n, Iν i) ≤ Sa + A * Sb := by
    calc
      (∑ i : Fin n, Iν i) ≤
          ∑ i : Fin n, ((a i)^2 + A * ∑ j : Fin n, (b i j)^2) :=
        Finset.sum_le_sum (fun i hi => hSiteUpper i)
      _ = Sa + A * Sb := by
        simp only [Sa, Sb, Finset.sum_add_distrib, Finset.mul_sum]
  have hp : Vν ≤ A * (Sa + A * Sb) :=
    hPoincare.trans (mul_le_mul_of_nonneg_left hsum hA0)
  have hfactor : 0 ≤ 2 * A^2 - A := by
    nlinarith [sq_nonneg A]
  have hVar : Vν ≤ 2 * A^2 * referenceQuadraticVariance a b := by
    change Vν ≤ 2 * A^2 * (Sa + (1 / 2 : ℝ) * Sb)
    nlinarith [mul_nonneg hfactor hSa]
  have hN : 0 ≤ M / (v * γ) := div_nonneg hM hvg.le
  have hsites : ∀ i : Fin n,
      referenceSiteInfluence a b i ≤ M / (v * γ) := by
    intro i
    apply (le_div_iff₀ hvg).2
    simpa only [mul_comm] using (hSiteLower i).trans (hCap i)
  have hprod := hQ2 (M / (v * γ)) hN hsites
  have hsq : Vν^2 ≤ (2 * A^2 * referenceQuadraticVariance a b)^2 :=
    pow_le_pow_left₀ hVν hVar 2
  calc
    Vν^2 ≤ (2 * A^2 * referenceQuadraticVariance a b)^2 := hsq
    _ = (4 * A^4) * (referenceQuadraticVariance a b)^2 := by ring
    _ ≤ (4 * A^4) * (K * B^2 * (M / (v * γ))) :=
      mul_le_mul_of_nonneg_left hprod (by positivity)
    _ = (4 * K * A^4 / (v * γ)) * B^2 * M := by ring

#print axioms Nightfall.DQ2SpectralSandwich.quadratic_spectral_sandwich

end Nightfall.DQ2SpectralSandwich
