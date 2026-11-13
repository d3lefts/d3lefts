import ActualESOwnedMomentEnergy
import QuadraticActualMomentEndpoint

/-!
# Derived L1-L2 first-moment bound on actual source neighbor products

The actual finite-neighbor Hilbert vector H_i has second moment equal
to the genuine original source owned interaction energy, already
derived without energy hypotheses. Cauchy–Schwarz under the normalized
true neighbor product laws gives

 z_i = E ||H_i|| <= sqrt(E ||H_i||²) <= sqrt(pinfl_i(f)).

No z_i <= sqrt(M) budget is assumed. For a common maximum influence
M, monotonicity of sqrt gives z_i <= sqrt(M) immediately.

This scalar bridge is useful for the final sum_i c_i z_i term.
-/

namespace Nightfall.Observability.ActualESFirstMoment

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.ProductSpace.Influence
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.ActualESOwnedNeighborEnumeration
open Nightfall.Observability.ActualESFiniteNeighborMoment
open Nightfall.Observability.ActualESOwnedMomentEnergy
open Nightfall.Observability.QuadraticActualMomentEndpoint

variable {α K : Type*} [Fintype α] [Fintype K]

/-- For an arbitrary nonnegative normalized finite product, the L1
Hilbert norm is bounded by the L2 Hilbert norm. This follows from
the exact finite Cauchy–Schwarz inequality, not a supplied moment. -/
theorem actual_product_first_moment_le_sqrt_second
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (hp : ∀ j a, 0 ≤ p j a)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (n : ℕ) :
    (∑ w : Samples α n, mass p n w *
      Real.sqrt (vecNormSq (sumVector Y n w))) ≤
      Real.sqrt (moment2 p Y n) := by
  classical
  let μ := mass p n
  let v : Samples α n → ℝ := fun w =>
    Real.sqrt (vecNormSq (sumVector Y n w))
  let z := ∑ w : Samples α n, μ w * v w
  let s := moment2 p Y n
  have hμ : ∀ w, 0 ≤ μ w :=
    mass_nonneg p hp n
  have hv : ∀ w, 0 ≤ v w :=
    fun w => Real.sqrt_nonneg _
  have hsq (w : Samples α n) :
      (v w)^2 = vecNormSq (sumVector Y n w) :=
    Real.sq_sqrt (vecNormSq_nonneg _)
  have hm1 : (∑ w : Samples α n, μ w) = 1 :=
    mass_one p hp1 n
  have hz : 0 ≤ z := by
    dsimp [z]
    exact Finset.sum_nonneg
      (fun w _ => mul_nonneg (hμ w) (hv w))
  have hs : 0 ≤ s := by
    dsimp [s, moment2]
    exact Finset.sum_nonneg
      (fun w _ => mul_nonneg (hμ w) (vecNormSq_nonneg _))
  have hcauchy :=
    Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
      (s := (Finset.univ : Finset (Samples α n)))
      (r := fun w => μ w * v w)
      (f := fun w => μ w)
      (g := fun w => μ w * (v w)^2)
      (fun w _ => hμ w)
      (fun w _ => mul_nonneg (hμ w) (sq_nonneg (v w)))
      (fun w _ => by ring)
  have hsummom :
      (∑ w : Samples α n, μ w * (v w)^2) = s := by
    dsimp [s, moment2]
    apply Finset.sum_congr rfl
    intro w _
    rw [hsq]
  have hzs : z^2 ≤ s := by
    dsimp [z] at hcauchy
    rw [hm1, one_mul, hsummom] at hcauchy
    exact hcauchy
  have hroot : (Real.sqrt s)^2 = s := Real.sq_sqrt hs
  have hroot0 : 0 ≤ Real.sqrt s := Real.sqrt_nonneg _
  have hbound : z ≤ Real.sqrt s := by
    nlinarith [hzs, hroot]
  simpa only [z, s, v, μ] using hbound

end Nightfall.Observability.ActualESFirstMoment
