import Mathlib
import QuadraticUnifiedFinite

/-!
# Swansea Q2: exact finite weighted variance and sharp source section budget

This file does **not** claim Q2.  It formalizes a necessary Q2 subtheorem:
for an actual bounded degree-two finite-product function carrying a concrete
quadratic representation, the sum of centered conditional L2 section norms
is at most 8.  Earlier source-row lemma gives 8*pi^2 instead.

The hpoly hypothesis is NOT a variance/matching/energy estimate; it says
the same actual function has a quadratic expansion. The still-required
bridge ESDegreeLE -> hpoly and full matching/energy closure are separate.

Compiler target: Lean 4.33.0, pinned Turturean workspace, via the
nightfall-product-influence workflow. No custom axioms or sorry.
-/

namespace Nightfall.Observability.Q2SharpSections

open Finset
open Nightfall.ProductSpace.EfronStein
open Nightfall.Observability.QuadraticUnifiedFinite
open Nightfall.Observability.QuadraticSwitching

variable {α : Type} [Fintype α]

/-- Finite-law Popoviciu inequality, with no positive-atom floor. -/
theorem weighted_variance_le_quarter_range
    (p : α → ℝ) (hp : ∀ a, 0 ≤ p a)
    (hp1 : ∑ a : α, p a = 1)
    (y : α → ℝ) (lo hi : ℝ)
    (hlo : ∀ a, lo ≤ y a) (hhi : ∀ a, y a ≤ hi) :
    4 * (∑ a : α, p a *
      (y a - (∑ b : α, p b * y b)) ^ 2) ≤ (hi - lo) ^ 2 := by
  classical
  let μ : ℝ := ∑ a : α, p a * y a
  let mid : ℝ := (hi + lo) / 2
  let sqsum : ℝ := ∑ a : α, p a * (y a) ^ 2
  have hexpand (v : ℝ) :
      (∑ a : α, p a * (y a - v) ^ 2) =
        sqsum - 2 * v * μ + v ^ 2 := by
    calc
      (∑ a : α, p a * (y a - v) ^ 2) =
          ∑ a : α, (p a * (y a) ^ 2 -
            (2 * v) * (p a * y a) + v ^ 2 * p a) := by
              apply Finset.sum_congr rfl
              intro a _
              ring
      _ = sqsum - 2 * v * μ + v ^ 2 := by
        simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib,
          ← Finset.mul_sum]
        rw [hp1]
        dsimp [sqsum, μ]
        ring
  have hshift :
      (∑ a : α, p a * (y a - mid) ^ 2) =
        (∑ a : α, p a * (y a - μ) ^ 2) + (μ - mid) ^ 2 := by
    rw [hexpand mid, hexpand μ]
    ring
  have hpoint (a : α) :
      (y a - mid) ^ 2 ≤ (hi - lo) ^ 2 / 4 := by
    have hl : 0 ≤ y a - lo := sub_nonneg.mpr (hlo a)
    have hr : 0 ≤ hi - y a := sub_nonneg.mpr (hhi a)
    dsimp [mid]
    nlinarith [mul_nonneg hl hr]
  have hsecond :
      (∑ a : α, p a * (y a - mid) ^ 2) ≤
        (hi - lo) ^ 2 / 4 := by
    calc
      (∑ a : α, p a * (y a - mid) ^ 2) ≤
          ∑ a : α, p a * ((hi - lo) ^ 2 / 4) := by
            apply Finset.sum_le_sum
            intro a _
            exact mul_le_mul_of_nonneg_left (hpoint a) (hp a)
      _ = (hi - lo) ^ 2 / 4 := by
            rw [← Finset.sum_mul, hp1, one_mul]
  change 4 * (∑ a : α, p a * (y a - μ) ^ 2) ≤ (hi - lo) ^ 2
  nlinarith [sq_nonneg (μ - mid)]

/-- Weighted standard deviation is at most half the full support range. -/
theorem weighted_std_le_half_range
    (p : α → ℝ) (hp : ∀ a, 0 ≤ p a)
    (hp1 : ∑ a : α, p a = 1)
    (y : α → ℝ) (lo hi : ℝ)
    (hlohi : lo ≤ hi)
    (hlo : ∀ a, lo ≤ y a) (hhi : ∀ a, y a ≤ hi) :
    2 * Real.sqrt (∑ a : α, p a *
      (y a - (∑ b : α, p b * y b)) ^ 2) ≤ hi - lo := by
  let vv : ℝ := ∑ a : α, p a *
    (y a - (∑ b : α, p b * y b)) ^ 2
  have hnonneg : 0 ≤ vv := by
    dsimp [vv]
    apply Finset.sum_nonneg
    intro a _
    exact mul_nonneg (hp a) (sq_nonneg _)
  have hsquare : 4 * vv ≤ (hi - lo) ^ 2 :=
    weighted_variance_le_quarter_range p hp hp1 y lo hi hlo hhi
  have hsqrt : (Real.sqrt vv) ^ 2 = vv := Real.sq_sqrt hnonneg
  have hpos : 0 ≤ Real.sqrt vv := Real.sqrt_nonneg _
  by_contra hbad
  have hgt : hi - lo < 2 * Real.sqrt vv := lt_of_not_ge hbad
  have hprod : 0 <
      (2 * Real.sqrt vv - (hi - lo)) *
      (2 * Real.sqrt vv + (hi - lo)) :=
    mul_pos (by linarith) (by linarith)
  nlinarith [hprod]

variable {ι E : Type}
  [Fintype ι] [DecidableEq ι]
  [DecidableEq α] [Nonempty α] [Fintype E]

private theorem singleSwitched_eq_update
    (x w : ι → α) (i : ι) :
    singleSwitched x w i = Function.update x i (w i) := by
  funext j
  by_cases hj : j = i
  · subst j
    simp [singleSwitched]
  · simp [singleSwitched, hj]

/-- The actual product observable (not an abstract section family) has
a dimension-free sum of centered L2 coordinate sections bounded by 8,
provided the source function is exhibited as a quadratic polynomial.

This does not close Q2: one still needs the *source-to-polynomial*
bridge, the global matching-mass inequality, independent Hilbert fourth
moments, and energy closure. -/
theorem actual_quadratic_centered_sections_le_eight
    (p : ι → α → ℝ)
    (hp : ∀ i a, 0 ≤ p i a)
    (hp1 : ∀ i, ∑ a, p i a = 1)
    (f : (ι → α) → ℝ)
    (hf : ∀ x, |f x| ≤ 1)
    (hdegree : ESDegreeLE p f 2)
    (u v : E → ι) (hne : ∀ e, u e ≠ v e)
    (c : ℝ) (h : ι → α → ℝ) (k : E → α → α → ℝ)
    (hpoly : ∀ x, f x = quadratic u v c h k x)
    (x : ι → α) :
    (∑ i : ι,
      Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
          (∑ b : α, p i b * f (Function.update x i b))) ^ 2)) ≤ 8 := by
  classical
  obtain ⟨_, hsections⟩ :=
    actual_degree_two_baseline_and_all_sections
      p hp hp1 f hf hdegree u v hne c h k hpoly
  obtain ⟨y, z, hy, hz, hrange⟩ := hsections x
  have hlow (i : ι) (a : α) :
      f (Function.update x i (z i)) ≤ f (Function.update x i a) := by
    simpa only [singleSwitched_eq_update] using hz i a
  have hhigh (i : ι) (a : α) :
      f (Function.update x i a) ≤ f (Function.update x i (y i)) := by
    simpa only [singleSwitched_eq_update] using hy i a
  have htotal :
      (∑ i : ι,
        (f (Function.update x i (y i)) -
         f (Function.update x i (z i)))) ≤ 16 := by
    simpa only [singleSwitched_eq_update] using hrange
  have hby_coordinate (i : ι) :
      2 * Real.sqrt (∑ a : α, p i a *
        (f (Function.update x i a) -
         (∑ b : α, p i b * f (Function.update x i b))) ^ 2) ≤
       f (Function.update x i (y i)) -
       f (Function.update x i (z i)) := by
    exact weighted_std_le_half_range
      (p i) (hp i) (hp1 i)
      (fun a : α => f (Function.update x i a))
      (f (Function.update x i (z i)))
      (f (Function.update x i (y i)))
      ((hlow i (y i)).trans (le_refl _))
      (hlow i) (hhigh i)
  have hsum := Finset.sum_le_sum
    (s := (Finset.univ : Finset ι))
    (fun i _ => hby_coordinate i)
  rw [← Finset.mul_sum] at hsum
  linarith

end Nightfall.Observability.Q2SharpSections
