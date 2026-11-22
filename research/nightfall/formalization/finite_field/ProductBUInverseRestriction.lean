import Mathlib
import ProductBUSmoothInverse

/-!
# Restrict a smooth partial homeomorphism to its invertible-derivative source

The missing local-graph C-infinity step in #1073 was not just a
simp-normalization issue. Mathlib ContDiffAt.contDiffOn at top order
does not create a uniform smooth neighborhood from a hypothesis at
one point.

Here the original ambient map is globally C∞. The set of points with
invertible derivative is OPEN; restricting an existing local
homeomorphism to it produces a new local homeomorphism with the exact
same forward map and a C∞ inverse on its WHOLE open target.

This is the structural repair needed before extracting smooth local
implicit graphs, not the global zero-fiber manifold and not the
ProductSphereZero theorem.

Source pin: Lean v4.36.0-rc2, Mathlib 9d581dfff2...
Imports main-merged #1096 exact smooth-inverse theorem, no source copy.
-/

namespace Nightfall.ProductBUInverseRestriction

open scoped Topology ContDiff
open Nightfall.ProductBUSmoothInverse

variable {E F : Type*}
  [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
  [NormedAddCommGroup F] [NormedSpace ℝ F]

/-- The source derivative-invertibility set is OPEN under global
C∞ regularity, and the original inverse restricts smoothly there. -/
theorem exists_local_smooth_inverse_restriction
    (φ : OpenPartialHomeomorph E F)
    (hf : ContDiff ℝ (⊤ : ℕ∞) (φ : E → F)) :
    ∃ ψ : OpenPartialHomeomorph E F,
      ψ.source =
        φ.source ∩ {x | (fderiv ℝ (φ : E → F) x).IsInvertible} ∧
      (ψ : E → F) = (φ : E → F) ∧
      ContDiffOn ℝ (⊤ : ℕ∞) (ψ.symm : F → E) ψ.target := by
  let s : Set E := {x | (fderiv ℝ (φ : E → F) x).IsInvertible}
  have hs : IsOpen s :=
    ContinuousLinearMap.isOpen_setOfPred_isInvertible.preimage
      (hf.continuous_fderiv (by norm_num))
  let ψ := φ.restrOpen s hs
  refine ⟨ψ, ?_, ?_, ?_⟩
  · exact φ.restrOpen_source s hs
  · exact φ.coe_restrOpen hs
  · apply inverse_contDiffOn_of_source_derivative_invertible ψ
    · simpa only [ψ, OpenPartialHomeomorph.coe_restrOpen] using hf
    · intro x hx
      have hmem : x ∈ φ.source ∩ s := by
        simpa [ψ, OpenPartialHomeomorph.restrOpen_source] using hx
      exact hmem.2

#print exists_local_smooth_inverse_restriction
#print axioms exists_local_smooth_inverse_restriction

end Nightfall.ProductBUInverseRestriction
