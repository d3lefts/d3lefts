import Mathlib
import MarginFreeBhattacharyya

/-!
# Finite-alphabet total variation versus Hellinger affinity

Target: for arbitrary finite probability vectors with zero entries allowed,
  (1 - ∑ min p q)^2 ≤ 2 (1 - ∑ sqrt(p*q)).
This is the standard dimension-free Cauchy-Schwarz inequality specialized
to the overlap-deficit definition of total variation. Unlike a supplied
Hellinger premise it is a source-level proof obligation.

Theorem is not certified until the exact-head CI run succeeds.
-/

namespace Nightfall.MarginFreeTVHellinger

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

theorem abs_sub_eq_sum_sub_min (a b : ℝ) :
    |a - b| = a + b - 2 * min a b := by
  rcases le_total a b with h | h
  · rw [abs_of_nonpos (sub_nonpos.mpr h), min_eq_left h]
    ring
  · rw [abs_of_nonneg (sub_nonneg.mpr h), min_eq_right h]
    ring

theorem tv_eq_half_l1 (p q : α → ℝ)
    (hp : ∑ a, p a = 1) (hq : ∑ a, q a = 1) :
    2 * (1 - ∑ a : α, min (p a) (q a)) =
      ∑ a : α, |p a - q a| := by
  have hpt (a : α) := abs_sub_eq_sum_sub_min (p a) (q a)
  simp_rw [hpt]
  rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hp, hq]
  ring

/-- Source-level finite Cauchy-Schwarz inequality between total-variation
overlap deficit and Hellinger affinity. No min-atom assumption and no
alphabet-cardinality factor. -/
theorem tv_sq_le_two_hellinger (p q : α → ℝ)
    (hp0 : ∀ a, 0 ≤ p a) (hq0 : ∀ a, 0 ≤ q a)
    (hp1 : ∑ a, p a = 1) (hq1 : ∑ a, q a = 1) :
    (1 - ∑ a : α, min (p a) (q a)) ^ 2 ≤
      2 * (1 - ∑ a : α, Real.sqrt (p a * q a)) := by
  let u : α → ℝ := fun a => Real.sqrt (p a)
  let v : α → ℝ := fun a => Real.sqrt (q a)
  let B : ℝ := ∑ a : α, u a * v a
  have hu0 : ∀ a, 0 ≤ u a := fun a => Real.sqrt_nonneg _
  have hv0 : ∀ a, 0 ≤ v a := fun a => Real.sqrt_nonneg _
  have hu2 : (∑ a : α, (u a) ^ 2) = 1 := by
    have h : ∀ a, (u a)^2 = p a := by
      intro a
      exact Real.sq_sqrt (hp0 a)
    simp_rw [h]
    exact hp1
  have hv2 : (∑ a : α, (v a) ^ 2) = 1 := by
    have h : ∀ a, (v a)^2 = q a := by
      intro a
      exact Real.sq_sqrt (hq0 a)
    simp_rw [h]
    exact hq1
  have hminus : (∑ a : α, (u a - v a)^2) = 2 - 2 * B := by
    have h : ∀ a, (u a - v a)^2 =
        (u a)^2 + (v a)^2 - 2 * u a * v a := by
      intro a
      ring
    simp_rw [h]
    rw [Finset.sum_sub_distrib, Finset.sum_add_distrib,
      ← Finset.mul_sum, hu2, hv2]
    dsimp [B]
    ring
  have hplus : (∑ a : α, (u a + v a)^2) = 2 + 2 * B := by
    have h : ∀ a, (u a + v a)^2 =
        (u a)^2 + (v a)^2 + 2 * u a * v a := by
      intro a
      ring
    simp_rw [h]
    rw [Finset.sum_add_distrib, Finset.sum_add_distrib,
      ← Finset.mul_sum, hu2, hv2]
    dsimp [B]
    ring
  have habs : ∀ a, |p a - q a| = |u a - v a| * (u a + v a) := by
    intro a
    have hfactor : p a - q a = (u a - v a) * (u a + v a) := by
      have hu := Real.sq_sqrt (hp0 a)
      have hv := Real.sq_sqrt (hq0 a)
      dsimp [u, v]
      nlinarith [hu, hv]
    rw [hfactor, abs_mul, abs_of_nonneg (add_nonneg (hu0 a) (hv0 a))]
  have hcs := Finset.sum_mul_sq_le_sq_mul_sq
    (Finset.univ : Finset α)
    (fun a => |u a - v a|)
    (fun a => u a + v a)
  have habssq : (∑ a : α, |u a - v a|^2) =
      (∑ a : α, (u a - v a)^2) := by
    apply Finset.sum_congr rfl
    intro a _
    exact sq_abs (u a - v a)
  have hL : (∑ a : α, |p a - q a|) =
      (∑ a : α, |u a - v a| * (u a + v a)) := by
    exact Finset.sum_congr rfl (fun a _ => habs a)
  rw [← hL, habssq, hminus, hplus] at hcs
  have htvd := tv_eq_half_l1 p q hp1 hq1
  have hB : B = ∑ a : α, Real.sqrt (p a * q a) := by
    dsimp [B, u, v]
    exact Finset.sum_congr rfl (fun a _ => (Real.sqrt_mul (hp0 a) (q a)).symm)
  rw [hB] at hcs
  nlinarith [sq_nonneg (1 - ∑ a : α, Real.sqrt (p a * q a))]

end Nightfall.MarginFreeTVHellinger
