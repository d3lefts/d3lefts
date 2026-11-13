import HilbertManyIncrementMoment
import QuadraticEndpointInterpolation

/-!
# Concrete independent Hilbert increments: L1/L2/L4 endpoint closure

This is a *true* finite arbitrary-law integration of previously proved
many-increment fourth moments with a newly proved weighted interpolation
inequality and the quadratic endpoint algebra.

It does not assume L1/L2/L4 interpolation or the fourth-moment bound.
The input increments are concrete product-law tables with normalized,
nonnegative, potentially zero coordinate weights. Assumed hypotheses:
mean zero of each increment and its pointwise squared norm bound.

**Not supplied by this module:** actual Efron-Stein pair-kernel extraction,
global matching-to-amplitude, assignment of neighbor increments,
source-conditioned Jensen, ANOVA energy/influence equality, measurable
transfer. In particular it is not a terminal Q2 theorem.
-/

namespace Nightfall.Observability.QuadraticActualMomentEndpoint

open Finset
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticEndpointInterpolation

variable {Ω α K : Type*} [Fintype Ω] [Fintype α] [Fintype K]

/-- Exact finite weighted interpolation, with neither a normalization
hypothesis nor strictly positive atom weights:
(E_μ v²)^3 ≤ (E_μ v)^2 (E_μ v⁴).
This is an inequality for an arbitrary finite nonnegative measure μ.
-/
theorem weighted_l1_l2_l4
    (μ : Ω → ℝ) (v : Ω → ℝ)
    (hμ : ∀ w, 0 ≤ μ w) (hv : ∀ w, 0 ≤ v w) :
    (∑ w : Ω, μ w * (v w)^2)^3 ≤
      (∑ w : Ω, μ w * v w)^2 *
        (∑ w : Ω, μ w * (v w)^4) := by
  classical
  let z : ℝ := ∑ w : Ω, μ w * v w
  let s : ℝ := ∑ w : Ω, μ w * (v w)^2
  let t : ℝ := ∑ w : Ω, μ w * (v w)^3
  let q : ℝ := ∑ w : Ω, μ w * (v w)^4
  have hz : 0 ≤ z := by
    dsimp [z]
    exact Finset.sum_nonneg (fun w _ => mul_nonneg (hμ w) (hv w))
  have hs : 0 ≤ s := by
    dsimp [s]
    exact Finset.sum_nonneg (fun w _ => mul_nonneg (hμ w) (sq_nonneg _))
  have ht : 0 ≤ t := by
    dsimp [t]
    exact Finset.sum_nonneg (fun w _ => mul_nonneg (hμ w) (pow_nonneg (hv w) _))
  have hq : 0 ≤ q := by
    dsimp [q]
    exact Finset.sum_nonneg (fun w _ => mul_nonneg (hμ w) (pow_nonneg (hv w) _))
  have hzs : s^2 ≤ z * t := by
    have h := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
      (s := (Finset.univ : Finset Ω))
      (r := fun w => μ w * (v w)^2)
      (f := fun w => μ w * v w)
      (g := fun w => μ w * (v w)^3)
      (fun w _ => mul_nonneg (hμ w) (hv w))
      (fun w _ => mul_nonneg (hμ w) (pow_nonneg (hv w) _))
      (fun w _ => by ring)
    simpa [z, s, t] using h
  have htq : t^2 ≤ s * q := by
    have h := Finset.sum_sq_le_sum_mul_sum_of_sq_eq_mul
      (s := (Finset.univ : Finset Ω))
      (r := fun w => μ w * (v w)^3)
      (f := fun w => μ w * (v w)^2)
      (g := fun w => μ w * (v w)^4)
      (fun w _ => mul_nonneg (hμ w) (sq_nonneg _))
      (fun w _ => mul_nonneg (hμ w) (pow_nonneg (hv w) _))
      (fun w _ => by ring)
    simpa [s, t, q] using h
  by_cases hs0 : s = 0
  · simp [s] at hs0
    rw [← hs0]
    have hn : 0 ≤ z^2 * q := mul_nonneg (sq_nonneg _) hq
    norm_num at *
    exact hn
  have hspos : 0 < s := lt_of_le_of_ne hs (Ne.symm hs0)
  have hmul : s^4 ≤ z^2 * t^2 := by
    have hdiff := mul_nonneg (sub_nonneg.mpr hzs)
      (add_nonneg (sq_nonneg s) (mul_nonneg hz ht))
    nlinarith [hdiff]
  have hmul2 : z^2 * t^2 ≤ z^2 * (s*q) :=
    mul_le_mul_of_nonneg_left htq (sq_nonneg z)
  have hbig : s * s^3 ≤ s * (z^2 * q) := by
    nlinarith [hmul, hmul2]
  have hsmall : s^3 ≤ z^2 * q :=
    (mul_le_mul_left hspos).mp hbig
  simpa only [z, s, q] using hsmall

/-- Exact weighted norm interpolation on the recursive product space
of genuine independent finite draws. No moment inequality is assumed. -/
theorem actual_product_l1_l2_l4
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (hp : ∀ j a, 0 ≤ p j a) (n : ℕ) :
    (moment2 p Y n)^3 ≤
      (∑ w : Samples α n,
        mass p n w * Real.sqrt (vecNormSq (sumVector Y n w)))^2 *
        moment4 p Y n := by
  classical
  let v : Samples α n → ℝ := fun w =>
    Real.sqrt (vecNormSq (sumVector Y n w))
  have h2 (w : Samples α n) :
      (v w)^2 = vecNormSq (sumVector Y n w) := by
    exact Real.sq_sqrt (vecNormSq_nonneg _)
  have h4 (w : Samples α n) :
      (v w)^4 = (vecNormSq (sumVector Y n w))^2 := by
    calc
      (v w)^4 = ((v w)^2)^2 := by ring
      _ = _ := by rw [h2]
  have h := weighted_l1_l2_l4
    (mass p n) v (mass_nonneg p hp n)
    (fun w => Real.sqrt_nonneg _)
  have hs :
      (∑ w : Samples α n, mass p n w * (v w)^2) =
        moment2 p Y n := by
    unfold moment2
    apply Finset.sum_congr rfl
    intro w _
    rw [h2]
  have hq :
      (∑ w : Samples α n, mass p n w * (v w)^4) =
        moment4 p Y n := by
    unfold moment4
    apply Finset.sum_congr rfl
    intro w _
    rw [h4]
  rw [hs, hq] at h
  exact h

/-- Full endpoint inequality for the actual product table:
s ≤ z(c + √(3M)). This theorem does not assume a moment inequality
or interpolation inequality: both are derived in the proof. The only
external upper bound here is the natural energy cap s ≤ M.
-/
theorem actual_product_fourth_endpoint
    (p : ℕ → α → ℝ) (Y : ℕ → α → K → ℝ)
    (c M : ℝ) (n : ℕ)
    (hp : ∀ j a, 0 ≤ p j a)
    (hp1 : ∀ j, (∑ a : α, p j a) = 1)
    (hY : ∀ j k, (∑ a : α, p j a * Y j a k) = 0)
    (hc : 0 ≤ c)
    (hbound : ∀ j a, vecNormSq (Y j a) ≤ c^2)
    (hM : moment2 p Y n ≤ M) :
    moment2 p Y n ≤
      (∑ w : Samples α n, mass p n w *
        Real.sqrt (vecNormSq (sumVector Y n w))) *
          (c + Real.sqrt (3 * M)) := by
  let s : ℝ := moment2 p Y n
  let z : ℝ := ∑ w : Samples α n, mass p n w *
    Real.sqrt (vecNormSq (sumVector Y n w))
  have hs : 0 ≤ s := by
    dsimp [s, moment2]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (mass_nonneg p hp n w) (vecNormSq_nonneg _)
  have hz : 0 ≤ z := by
    dsimp [z]
    apply Finset.sum_nonneg
    intro w _
    exact mul_nonneg (mass_nonneg p hp n w) (Real.sqrt_nonneg _)
  have hinter : s^3 ≤ z^2 *
      (c^2 * s + 3 * s^2) := by
    have h1 := actual_product_l1_l2_l4 p Y hp n
    have h2 := arbitrary_law_many_hilbert_fourth
      p Y c hp hp1 hY hbound n
    have h3 := moment2_eq_budget p Y hp1 hY n
    have h4 : moment4 p Y n ≤
        c^2 * moment2 p Y n + 3 * (moment2 p Y n)^2 := by
      simpa only [← h3] using h2
    have h5 := mul_le_mul_of_nonneg_left h4 (sq_nonneg z)
    dsimp [s, z] at *
    exact le_trans h1 h5
  exact energy_of_interpolated_hilbert_moment
    s z c M hs hz hc hM hinter

end Nightfall.Observability.QuadraticActualMomentEndpoint
