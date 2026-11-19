import Nightfall.LatinSquare.ExactFlattening
import Nightfall.LatinSquare.Representation

/-!
# Finite labeled Latin-square likelihood and mixture kernel

Exact algebraic bridge from:
  Mira Cult, "Exact uniform generation of labeled Latin squares"
  https://github.com/Mira-Cult/math/tree/30ddaaad27b48df2002225c3e3f40cffd02c5253/notes/combinatorics/exact-latin-square-sampling

This file constructs the finite TARGET TYPE and a finite latent-product
target weight, then instantiates the exact kernel and normalization laws.

NOT FORMALIZED: the decorated forward proposal, the reverse mark law,
the multiscale Bernoulli race or its fair-bit implementation, the
uniform-in-target logarithmic comparison, regular-board counting,
or the total expected O-tilde(n^25) bit-work statement.

All hypotheses are explicit; no theorem upgrades their verification.
-/

namespace Nightfall.LatinSquare

/-- A labeled order-n Latin square, preserving all row, column and
symbol labels and with no quotient by isotopy. -/
def LabeledSquare (n : ℕ) :=
  {S : Fin n → Fin n → Fin n // IsLabeledLatin n S}

/-- The valid labeled squares form a finite space. This is a
noncomputable finite enumeration interface, not an efficient sampler. -/
noncomputable instance labeledSquareFintype (n : ℕ) :
    Fintype (LabeledSquare n) := by
  classical
  change Fintype {S : Fin n → Fin n → Fin n // IsLabeledLatin n S}
  infer_instance

/-- Unnormalized probability weight assigned to a Latin square by a
finite mixture of independent cell sources. The individual component
and mixing weights are rational inputs, and no positivity is asserted
by this definition. -/
def latentProductSquareWeight (n M : ℕ)
    (mix : Fin M → ℚ)
    (cell : Fin M → Fin n → Fin n → Fin n → ℚ)
    (S : LabeledSquare n) : ℚ :=
  ∑ latent : Fin M, mix latent *
    ∏ row : Fin n, ∏ col : Fin n, cell latent row col (S.val row col)

/-- For finite forward atoms with vetoed/null histories, and
target-specific reverse atoms supported wherever the forward law is
nonzero, the weighted likelihood ratio T is w*r/q on support and
zero off support. At scale H/m the soft-gated forward mass equals
w*f_m/H. This is exact finite algebra, NOT an executable Bernoulli
factory or a certified expected-cost estimate. -/
theorem latinMixture_softKernelMass
    (n M : ℕ) (η : Type*) [Fintype η]
    (mix : Fin M → ℚ)
    (cell : Fin M → Fin n → Fin n → Fin n → ℚ)
    (q r : LabeledSquare n → η → ℚ)
    (S : LabeledSquare n) (H m : ℚ)
    (hH : H ≠ 0) (hm : m ≠ 0)
    (hSupport : ∀ z, q S z = 0 → r S z = 0)
    (hden : ∀ z,
      supportedLikelihood (q S z) (r S z)
        (latentProductSquareWeight n M mix cell S) + H / m ≠ 0) :
    softForwardKernelMass η (q S)
        (fun z => supportedLikelihood (q S z) (r S z)
          (latentProductSquareWeight n M mix cell S))
        (H / m) =
      (latentProductSquareWeight n M mix cell S / H) *
        scaledReverseKernelMass η (r S)
          (fun z => supportedLikelihood (q S z) (r S z)
            (latentProductSquareWeight n M mix cell S))
          H m := by
  apply scaledKernelMass_balance η (q S) (r S)
    (fun z => supportedLikelihood (q S z) (r S z)
      (latentProductSquareWeight n M mix cell S))
    (latentProductSquareWeight n M mix cell S) H m hH hm hden
  intro z
  exact supportedLikelihood_balance (q S z) (r S z)
    (latentProductSquareWeight n M mix cell S) (hSupport z)

/-- Terminal finite target-law certificate: for any list of
target-specific finite calibration masses satisfying the stated
nonzero denominators, exact multiscale correction gives the
mixture-of-cell-products distribution conditioned on Latin validity.
This does NOT assert efficient generation of these masses. -/
theorem latentProductLatin_correctedLaw
    (n M : ℕ)
    (mix : Fin M → ℚ)
    (cell : Fin M → Fin n → Fin n → Fin n → ℚ)
    (H u : ℚ) (hH : H ≠ 0) (hu : u ≠ 0)
    (hZ : (∑ S : LabeledSquare n,
      latentProductSquareWeight n M mix cell S) ≠ 0)
    (calibrations : LabeledSquare n → List ℚ)
    (hden : ∀ S f, f ∈ calibrations S → u + f ≠ 0)
    (S : LabeledSquare n) :
    correctedLevelMass
      (latentProductSquareWeight n M mix cell S) H u (calibrations S) /
      (∑ T : LabeledSquare n,
        correctedLevelMass
          (latentProductSquareWeight n M mix cell T) H u (calibrations T)) =
    latentProductSquareWeight n M mix cell S /
      (∑ T : LabeledSquare n,
        latentProductSquareWeight n M mix cell T) := by
  exact correctedKernelMass_normalizes (LabeledSquare n)
    (fun T => latentProductSquareWeight n M mix cell T)
    H u hH hu hZ calibrations hden S

#print axioms Nightfall.LatinSquare.latinMixture_softKernelMass
#print axioms Nightfall.LatinSquare.latentProductLatin_correctedLaw

end Nightfall.LatinSquare
