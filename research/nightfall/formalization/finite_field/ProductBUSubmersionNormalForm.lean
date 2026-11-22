import MathlibExt.Geometry.Manifold.SubmersionOfSurjectiveMFDeriv

/-!
# Genuine C-infinity local projection normal form for regular Euclidean fibers

The pinned ATLAS SubmersionOfSurjectiveMFDeriv theorem proves that a smooth
finite-dimensional Euclidean map with surjective manifold derivative has
an ACTUAL local projection normal form, expressed as IsSubmersionAt.

This is stronger than a C¹ local level-set immersion and removes the need
to infer a common C∞ neighborhood from a pointwise ContDiffAt ∞ proof.

Source: facebookresearch/atlas-lean@7857a2e8c32088b5002f7cafe29a21d936baf704,
MathlibExt/Geometry/Manifold/SubmersionOfSurjectiveMFDeriv.lean
(credited Apache/Meta source). Does not install a zero-fiber manifold.

Next: restrict each local projection chart to the level-set F=0 and
identify its complement as dimension one; construct an actual
OpenPartialHomeomorph on the zero-fiber subtype. At time zero, separately
choose the nonnegative time coordinate and prove half-space overlap.

No ProductSphereZero, custom axiom or admission is asserted.
-/

open scoped Topology Manifold ContDiff
open Manifold

namespace Nightfall.ProductBUSubmersionNormalForm
noncomputable section

/-- For every regular point of a C∞ augmented Euclidean map with
one-dimensional derivative kernel, ATLAS builds a genuine smooth
submersion coordinate structure, not just an immersion.

Assumptions are the exact input contract of the frozen external theorem:
local C∞ at all nearby points and a SURJECTIVE manifold differential.
-/
theorem euclidean_regular_fiber_has_smooth_local_projection
    (m : ℕ)
    (F : EuclideanSpace ℝ (Fin (m + 1)) →
      EuclideanSpace ℝ (Fin m))
    (x : EuclideanSpace ℝ (Fin (m + 1)))
    (hsmooth : ∀ᶠ y in 𝓝 x,
      ContMDiffAt
        𝓘(ℝ, EuclideanSpace ℝ (Fin (m + 1)))
        𝓘(ℝ, EuclideanSpace ℝ (Fin m))
        (∞ : ℕ∞ω) F y)
    (hreg : Function.Surjective
      (mfderiv
        𝓘(ℝ, EuclideanSpace ℝ (Fin (m + 1)))
        𝓘(ℝ, EuclideanSpace ℝ (Fin m)) F x)) :
    IsSubmersionAt
      𝓘(ℝ, EuclideanSpace ℝ (Fin (m + 1)))
      𝓘(ℝ, EuclideanSpace ℝ (Fin m))
      (∞ : ℕ∞ω) F x := by
  exact MathlibExt.Geometry.Manifold.SubmersionOfSurjectiveMFDerivWanted.submersionAt_of_surjective_mfderiv
    (hn := by norm_num) hsmooth hreg

#check euclidean_regular_fiber_has_smooth_local_projection
#print axioms euclidean_regular_fiber_has_smooth_local_projection

end
end Nightfall.ProductBUSubmersionNormalForm
