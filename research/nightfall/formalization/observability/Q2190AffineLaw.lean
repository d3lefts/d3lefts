import Q2190FourPoint

/-!
# Exact degree-two affine product-law cancellation

For any source weights p, even perturbations b and signed tangents eta,
the four positive spherical laws later proved in RotationParams have
the affine form p + theta*b ± r*eta for theta ∈ {D,A}.
This file proves exact singleton and two-coordinate cancellation
pointwise, no probability assumptions and no numerical inequalities.
-/

namespace Nightfall.Q2190

noncomputable def affineSite
    (p b eta : ℝ) (theta sign : ℝ) : ℝ :=
  p + theta*b + sign*r*eta

theorem affine_singleton_quadrature
    (p b eta : ℝ) :
    A*(affineSite p b eta D 1 - affineSite p b eta D (-1)) -
      D*(affineSite p b eta A 1 - affineSite p b eta A (-1)) =
      eta := by
  dsimp [affineSite]
  have h := fourpoint_derivative_factor
  calc
    A*(p + D*b + 1*r*eta - (p + D*b + (-1)*r*eta)) -
        D*(p + A*b + 1*r*eta - (p + A*b + (-1)*r*eta)) =
        (2*r*(A-D))*eta := by ring
    _ = eta := by rw [h]; ring

/-- Four-law signed pair marginal is exactly the sum of the
two ORIGINAL-source tangent replacements; all even deltas cancel. -/
theorem affine_pair_quadrature
    (p1 b1 eta1 p2 b2 eta2 : ℝ) :
    A*(affineSite p1 b1 eta1 D 1*affineSite p2 b2 eta2 D 1 -
        affineSite p1 b1 eta1 D (-1)*affineSite p2 b2 eta2 D (-1)) -
      D*(affineSite p1 b1 eta1 A 1*affineSite p2 b2 eta2 A 1 -
        affineSite p1 b1 eta1 A (-1)*affineSite p2 b2 eta2 A (-1)) =
      eta1*p2 + p1*eta2 := by
  dsimp [affineSite]
  have h := fourpoint_derivative_factor
  calc
    A*((p1+D*b1+1*r*eta1)*(p2+D*b2+1*r*eta2) -
        (p1+D*b1+(-1)*r*eta1)*(p2+D*b2+(-1)*r*eta2)) -
      D*((p1+A*b1+1*r*eta1)*(p2+A*b2+1*r*eta2) -
        (p1+A*b1+(-1)*r*eta1)*(p2+A*b2+(-1)*r*eta2)) =
      (2*r*(A-D))*(eta1*p2+p1*eta2) := by ring
    _ = eta1*p2+p1*eta2 := by rw [h]; ring

end Nightfall.Q2190
