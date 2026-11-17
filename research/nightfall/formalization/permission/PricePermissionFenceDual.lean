import Mathlib

/-!
# Exact primal/dual cost certificates for finite semantic fences

For a rational edge/source incidence matrix A, a feasible covering vector x
and nonnegative packing weights y with Aᵀ y ≤ c, weak duality proves
    ∑ y ≤ cᵀ x.
A matching feasible x and y certifies the optimum (also over fractional
nonnegative covers, therefore over Boolean source-version fences).

The matrix is an explicit mathematical input; this file does not certify a
JSON parser, the completeness of externally observed unsafe histories, nor
a live effect-time enforcement mechanism. No optimizer is trusted.
-/

namespace Nightfall.PricePermission.CertifyingFences

open Finset

/-- Exact weak duality for an arbitrary finite rational incidence matrix.
No total unimodularity or integrality of the covering relaxation is needed. -/
theorem rational_covering_dual_lower_bound
    {m n : ℕ}
    (A : Fin m → Fin n → ℚ) (c : Fin n → ℚ)
    (x : Fin n → ℚ) (y : Fin m → ℚ)
    (hx : ∀ i, 0 ≤ x i)
    (hy : ∀ e, 0 ≤ y e)
    (hcover : ∀ e, 1 ≤ ∑ i : Fin n, A e i * x i)
    (hdual : ∀ i, (∑ e : Fin m, y e * A e i) ≤ c i) :
    (∑ e : Fin m, y e) ≤ ∑ i : Fin n, c i * x i := by
  have hfirst :
      (∑ e : Fin m, y e * (1 : ℚ)) ≤
        ∑ e : Fin m, y e * (∑ i : Fin n, A e i * x i) := by
    apply Finset.sum_le_sum
    intro e _
    exact mul_le_mul_of_nonneg_left (hcover e) (hy e)
  have hlast :
      (∑ i : Fin n, (∑ e : Fin m, y e * A e i) * x i) ≤
        ∑ i : Fin n, c i * x i := by
    apply Finset.sum_le_sum
    intro i _
    exact mul_le_mul_of_nonneg_right (hdual i) (hx i)
  calc
    (∑ e : Fin m, y e) = ∑ e : Fin m, y e * (1 : ℚ) := by simp
    _ ≤ ∑ e : Fin m, y e * (∑ i : Fin n, A e i * x i) := hfirst
    _ = ∑ i : Fin n, (∑ e : Fin m, y e * A e i) * x i := by
      calc
        (∑ e : Fin m, y e * (∑ i : Fin n, A e i * x i)) =
            ∑ e : Fin m, ∑ i : Fin n, (y e * A e i) * x i := by
          apply Finset.sum_congr rfl
          intro e _
          rw [Finset.mul_sum]
          apply Finset.sum_congr rfl
          intro i _
          ring
        _ = ∑ i : Fin n, ∑ e : Fin m, (y e * A e i) * x i := by
          rw [Finset.sum_comm]
        _ = ∑ i : Fin n, (∑ e : Fin m, y e * A e i) * x i := by
          apply Finset.sum_congr rfl
          intro i _
          rw [Finset.sum_mul]
    _ ≤ ∑ i : Fin n, c i * x i := hlast

/-- A feasible cover whose cost exactly matches a feasible dual packing
is optimal among *all* nonnegative rational covers.  In particular it
is optimal among source-version fences with Boolean selection bits. -/
theorem rational_matching_fence_optimal
    {m n : ℕ}
    (A : Fin m → Fin n → ℚ) (c : Fin n → ℚ)
    (x : Fin n → ℚ) (y : Fin m → ℚ)
    (hx : ∀ i, 0 ≤ x i)
    (hy : ∀ e, 0 ≤ y e)
    (hcoverX : ∀ e, 1 ≤ ∑ i : Fin n, A e i * x i)
    (hdual : ∀ i, (∑ e : Fin m, y e * A e i) ≤ c i)
    (hmatching : (∑ i : Fin n, c i * x i) = ∑ e : Fin m, y e) :
    (∀ e, 1 ≤ ∑ i : Fin n, A e i * x i) ∧
      ∀ z : Fin n → ℚ,
        (∀ i, 0 ≤ z i) →
        (∀ e, 1 ≤ ∑ i : Fin n, A e i * z i) →
        (∑ i : Fin n, c i * x i) ≤ ∑ i : Fin n, c i * z i := by
  refine ⟨hcoverX, ?_⟩
  intro z hz hcoverZ
  rw [hmatching]
  exact rational_covering_dual_lower_bound A c z y hz hy hcoverZ hdual

end Nightfall.PricePermission.CertifyingFences
