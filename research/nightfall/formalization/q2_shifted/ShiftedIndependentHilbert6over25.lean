import ShiftedHilbertManyIncrement
import ShiftedC6over25Scalar
import QuadraticActualMomentEndpoint

/-!
# Original finite independent-Hilbert law: unconditional 6c/25 correction

For arbitrary finite coordinate/sample alphabets, arbitrary finite-dimensional
real Hilbert index K, nonidentical independent coordinate marginals (zero atoms
admitted), centered Hilbert increments whose squared norms are <= c², and
arbitrary deterministic shift h:

  sqrt(E||h + sum_j Y_j||²) <= sqrt(3) E||h + sum_j Y_j|| + 6 c/25.

No moment, Hölder, source Q2, or scalar inequality is supplied as a premise.
The existing exact shifted fourth moment and rational Bernstein scalar
certificate are composed from the ORIGINAL independent input law.

This theorem is NOT the conjectured c/5 bound. 6/25 > 1/5.
-/

namespace Nightfall.ShiftedIndependentHilbert

open Finset
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticActualMomentEndpoint
open Nightfall.Observability.ShiftedHilbertManyIncrement
open Nightfall.ShiftedC6over25Scalar

variable {α K : Type*} [Fintype α] [Fintype K]

/-- Source-only L1/L2/L4 interpolation for a shifted sum of
arbitrarily many finite independently sampled Hilbert increments.
No source-moment bound is an assumption. -/
theorem independent_shifted_product_l1_l2_l4
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (h : K → ℝ)
    (hp : ∀ i b, 0 ≤ p i b) (n : ℕ) :
    (∑ w : Samples α n, mass p n w *
      vecNormSq (fun k => h k + sumVector Y n w k))^3 ≤
      (∑ w : Samples α n, mass p n w *
        Real.sqrt (vecNormSq (fun k => h k + sumVector Y n w k)))^2 *
          shiftedMoment4 p Y h n := by
  classical
  let v : Samples α n → ℝ := fun w =>
    Real.sqrt (vecNormSq (fun k => h k + sumVector Y n w k))
  have hv2 (w : Samples α n) :
      v w ^ 2 = vecNormSq (fun k => h k + sumVector Y n w k) :=
    Real.sq_sqrt (vecNormSq_nonneg _)
  have hv4 (w : Samples α n) :
      v w ^ 4 = (vecNormSq (fun k => h k + sumVector Y n w k))^2 := by
    calc
      v w ^ 4 = (v w ^ 2)^2 := by ring
      _ = _ := by rw [hv2]
  have hholder := weighted_l1_l2_l4
    (mass p n) v (mass_nonneg p hp n) (fun w => Real.sqrt_nonneg _)
  have he2 : (∑ w : Samples α n, mass p n w * (v w)^2) =
      ∑ w : Samples α n, mass p n w *
        vecNormSq (fun k => h k + sumVector Y n w k) := by
    apply Finset.sum_congr rfl
    intro w _
    rw [hv2]
  have he4 : (∑ w : Samples α n, mass p n w * (v w)^4) =
      shiftedMoment4 p Y h n := by
    unfold shiftedMoment4
    apply Finset.sum_congr rfl
    intro w _
    rw [hv4]
  simpa only [he2, he4, v] using hholder

/-- Unconditional all-n finite independent-Hilbert c*(6/25) moment
inequality with deterministic shift and original unequal source laws. -/
theorem independent_shifted_hilbert_six_over_twentyfive
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (h : K → ℝ) (c : ℝ)
    (hp : ∀ i b, 0 ≤ p i b)
    (hp1 : ∀ i, (∑ b : α, p i b) = 1)
    (hY : ∀ i k, (∑ b : α, p i b * Y i b k) = 0)
    (hc : 0 ≤ c)
    (hbound : ∀ i b, vecNormSq (Y i b) ≤ c^2)
    (n : ℕ) :
    Real.sqrt (vecNormSq h + moment2 p Y n) ≤
      Real.sqrt 3 *
        (∑ w : Samples α n, mass p n w *
          Real.sqrt (vecNormSq (fun k => h k + sumVector Y n w k))) +
      6*c/25 := by
  classical
  let a : ℝ := Real.sqrt (vecNormSq h)
  let s : ℝ := moment2 p Y n
  let e : ℝ := a^2 + s
  let u : ℝ := ∑ w : Samples α n, mass p n w *
    Real.sqrt (vecNormSq (fun k => h k + sumVector Y n w k))
  let q : ℝ := shiftedMoment4 p Y h n
  have ha : 0 ≤ a := Real.sqrt_nonneg _
  have hs : 0 ≤ s := by
    dsimp [s, moment2]
    exact Finset.sum_nonneg (fun w _ =>
      mul_nonneg (mass_nonneg p hp n w) (vecNormSq_nonneg _))
  have hu : 0 ≤ u := by
    dsimp [u]
    exact Finset.sum_nonneg (fun w _ =>
      mul_nonneg (mass_nonneg p hp n w) (Real.sqrt_nonneg _))
  have ha2 : vecNormSq h = a^2 := by
    dsimp [a]
    exact (Real.sq_sqrt (vecNormSq_nonneg h)).symm
  have hsecond := shifted_second_moment p Y h hp1 hY n
  have hbudget := moment2_eq_budget p Y hp1 hY n
  have hfourth := arbitrary_law_many_shifted_hilbert_fourth
    p Y h a c hp hp1 hY ha hc ha2 hbound n
  have hqstrong : q ≤ 3*e^2-2*a^4+4*a*c*s+c^2*s := by
    dsimp [q,e,s]
    rw [← hbudget] at hfourth
    convert hfourth using 1 <;> ring
  have hinterp := independent_shifted_product_l1_l2_l4 p Y h hp n
  have hnorm : (∑ w : Samples α n, mass p n w *
      vecNormSq (fun k => h k + sumVector Y n w k)) = e := by
    calc
      _ = vecNormSq h + moment2 p Y n := hsecond
      _ = e := by dsimp [e,s]; rw [ha2]
  have hholder : e^3 ≤ u^2*q := by
    rw [hnorm] at hinterp
    simpa only [u,q] using hinterp
  have hshift : Real.sqrt e ≤ Real.sqrt 3*u+6*c/25 :=
    shifted_c6over25_from_strong_moments
      a s c u e q ha hs hc hu rfl hholder hqstrong
  have heq : vecNormSq h + moment2 p Y n = e := by
    dsimp [e,s]
    rw [ha2]
  rw [heq]
  simpa only [u] using hshift

end Nightfall.ShiftedIndependentHilbert
