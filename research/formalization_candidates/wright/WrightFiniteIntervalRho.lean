import WrightSharpResampling

/-!
# Wright sharp rho for arbitrary finite-support real fibers

The main theorem scales the kernel-certified centered [-1/2,1/2]
resampling inequality to any positive interval (lo,hi). Its RHS is the
actual conditional expected maximum distance to an endpoint, as used
in the manuscript's pointwise-sensitivity / total increment step.

The theorem does not yet sum over all coordinates of an arbitrary
product function or establish the FHKL degree-d sensitivity bound.
-/

namespace Nightfall.Wright.FiniteInterval

open Finset Nightfall.Wright.SharpResampling

theorem radius_abs_eq_max (u lo hi : ℝ) :
    (hi - lo) / 2 + |u - (lo + hi) / 2| =
      max (u - lo) (hi - u) := by
  by_cases h : u ≤ (lo + hi) / 2
  · have habs : u - (lo + hi) / 2 ≤ 0 := by linarith
    have hmax : u - lo ≤ hi - u := by linarith
    rw [abs_of_nonpos habs, max_eq_right hmax]
    ring
  · have habs : 0 ≤ u - (lo + hi) / 2 := by linarith
    have hmax : hi - u ≤ u - lo := by linarith
    rw [abs_of_nonneg habs, max_eq_left hmax]
    ring

variable {α : Type*} [Fintype α]

/-- Sharp arbitrary-law iid resampling on a nondegenerate real interval.
No atom lower bound. The endpoint expression is exactly the sum of each
fiber value's maximal distance to an endpoint, not an approximate proxy. -/
theorem sharp_rho_finite_interval
    (p : α → ℝ) (hp : ∀ i, 0 ≤ p i)
    (hp1 : ∑ i, p i = 1)
    (u : α → ℝ) (lo hi : ℝ) (hlohi : lo < hi)
    (hlo : ∀ i, lo ≤ u i) (hhi : ∀ i, u i ≤ hi) :
    (∑ i, ∑ j, p i * p j * |u i - u j|) ≤
      (4 - 2 * Real.sqrt 3) *
        (∑ i, p i * max (u i - lo) (hi - u i)) := by
  let r : ℝ := hi - lo
  let m : ℝ := (lo + hi) / 2
  let a : α → ℝ := fun i => (u i - m) / r
  have hr : 0 < r := by dsimp [r]; linarith
  have hr0 : r ≠ 0 := ne_of_gt hr
  have ha0 : ∀ i, -(1 / 2 : ℝ) ≤ a i := by
    intro i
    dsimp [a]
    apply (le_div_iff₀ hr).mpr
    dsimp [m, r]
    nlinarith [hlo i]
  have ha1 : ∀ i, a i ≤ 1 / 2 := by
    intro i
    dsimp [a]
    apply (div_le_iff₀ hr).mpr
    dsimp [m, r]
    nlinarith [hhi i]
  have hcenter (i : α) : r * (1 / 2 + |a i|) =
      r / 2 + |u i - m| := by
    have hA : |a i| = |u i - m| / r := by
      dsimp [a]
      rw [abs_div, abs_of_pos hr]
    rw [hA]
    field_simp
    ring
  have hdist (i j : α) :
      r * |a i - a j| = |u i - u j| := by
    have hA : a i - a j = (u i - u j) / r := by
      dsimp [a]
      ring
    rw [hA, abs_div, abs_of_pos hr]
    field_simp
  have hL :
      (∑ i, ∑ j, p i * p j * |u i - u j|) =
        r * (∑ i, ∑ j, p i * p j * |a i - a j|) := by
    calc
      (∑ i, ∑ j, p i * p j * |u i - u j|) =
          (∑ i, ∑ j, r * (p i * p j * |a i - a j|)) := by
            apply Finset.sum_congr rfl
            intro i _
            apply Finset.sum_congr rfl
            intro j _
            rw [← hdist i j]
            ring
      _ = r * (∑ i, ∑ j, p i * p j * |a i - a j|) := by
            rw [Finset.mul_sum]
            apply Finset.sum_congr rfl
            intro i _
            rw [Finset.mul_sum]
  have hR :
      r * (∑ i, p i * (1 / 2 + |a i|)) =
        ∑ i, p i * (r / 2 + |u i - m|) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    rw [← hcenter i]
    ring
  have hUnit := sharp_rho_all_finite_laws p hp hp1 a ha0 ha1
  have hScaled := mul_le_mul_of_nonneg_left hUnit (le_of_lt hr)
  calc
    (∑ i, ∑ j, p i * p j * |u i - u j|)
        = r * (∑ i, ∑ j, p i * p j * |a i - a j|) := hL
    _ ≤ r * ((4 - 2 * Real.sqrt 3) *
          (∑ i, p i * (1 / 2 + |a i|))) := hScaled
    _ = (4 - 2 * Real.sqrt 3) *
          (∑ i, p i * (r / 2 + |u i - m|)) := by rw [← hR]; ring
    _ = (4 - 2 * Real.sqrt 3) *
          (∑ i, p i * max (u i - lo) (hi - u i)) := by
          congr 1
          apply Finset.sum_congr rfl
          intro i _
          dsimp [r, m]
          rw [radius_abs_eq_max]

end Nightfall.Wright.FiniteInterval
