import Mathlib

/-!
# C-infinity local inverses on the open derivative-invertibility locus

ContDiffAt of infinite order at ONE point cannot by itself produce one
uniform infinitely-smooth neighborhood. The pinned Mathlib API correctly
refuses that unsafe inference. For a globally smooth local
homeomorphism whose derivative is invertible on its source, the inverse
is C-infinity at EVERY target point. This does produce ContDiffOn of
infinite order on the whole target, pointwise.

The second lemma establishes openness of the invertible derivative
condition, enabling a source restriction in the implicit-level-graph
proof. No analytic approximation, topology zero axiom, or manifold
instance is assumed here.

Authors: NIGHTFALL integration of existing pinned Mathlib lemmas.
-/

namespace Nightfall.ProductBUSmoothInverse

open scoped Topology ContDiff

variable {E F : Type*}
  [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E]
  [NormedAddCommGroup F] [NormedSpace ℝ F]

/-- A globally smooth local homeomorphism has a C-infinity inverse
on its target if its derivative is invertible throughout the source. -/
theorem inverse_contDiffOn_of_source_derivative_invertible
    (φ : OpenPartialHomeomorph E F)
    (hf : ContDiff ℝ (⊤ : ℕ∞) (φ : E → F))
    (hinv : ∀ x ∈ φ.source,
      (fderiv ℝ (φ : E → F) x).IsInvertible) :
    ContDiffOn ℝ (⊤ : ℕ∞) (φ.symm : F → E) φ.target := by
  intro y hy
  obtain ⟨e, he⟩ := hinv (φ.symm y) (φ.map_target hy)
  have hfd : HasFDerivAt (φ : E → F)
      (e : E →L[ℝ] F) (φ.symm y) := by
    simpa only [he] using
      (hf.differentiable (by norm_num) (φ.symm y)).hasFDerivAt
  exact (φ.contDiffAt_symm hy hfd hf.contDiffAt).contDiffWithinAt

/-- Derivative invertibility persists on a neighborhood for a
globally smooth real Banach-space map. -/
theorem eventually_derivative_invertible
    (f : E → F) (hf : ContDiff ℝ (⊤ : ℕ∞) f)
    (x₀ : E) (hi : (fderiv ℝ f x₀).IsInvertible) :
    ∀ᶠ x in 𝓝 x₀, (fderiv ℝ f x).IsInvertible := by
  exact (hf.continuous_fderiv (by norm_num)).continuousAt.eventually
    (ContinuousLinearMap.isOpen_setOfPred_isInvertible.mem_nhds hi)

#print inverse_contDiffOn_of_source_derivative_invertible
#print axioms inverse_contDiffOn_of_source_derivative_invertible
#print eventually_derivative_invertible
#print axioms eventually_derivative_invertible

end Nightfall.ProductBUSmoothInverse
