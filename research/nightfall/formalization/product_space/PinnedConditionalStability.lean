import LatentComponentCertifiedCore

/-!
# Margin-free conditional stability via pinned coordinates

Unlike a proof that substitutes values into a low-degree polynomial,
this proof keeps the original function `f` unchanged. It pins the
already-observed coordinates of both product laws to the same point mass
and applies the **source-level Lean theorem** for arbitrary product TV
stability. No positive-atom margin, including on the pinned coordinates,
is imposed.

The conclusion is the small conditional mean-shift inequality needed
in component identification, with a certified O(d²) TV threshold.
No Hellinger tensorization, likelihood-test implementation, or quantum
simulation is claimed by this file.
-/

namespace Nightfall.ProductSpace.PinnedConditional

open Finset
open Nightfall.ProductSpace.Mixture
open Nightfall.ProductSpace.LatentComponent
open Nightfall.ProductSpace.RowBound
open Nightfall.ProductSpace.Transfer
open Nightfall.ProductSpace.Influence

variable {ι α : Type} [Fintype ι] [DecidableEq ι] [Fintype α] [DecidableEq α]

theorem pin_nonneg (A : Finset ι) (ρ : ι → α)
    (p : ι → α → ℝ) (hp : ∀ i a, 0 ≤ p i a) :
    ∀ i a, 0 ≤ pin A ρ p i a := by
  intro i a
  by_cases hi : i ∈ A
  · by_cases ha : a = ρ i
    · simp [pin, hi, delta, ha]
    · simp [pin, hi, delta, ha]
  · simpa [pin, hi] using hp i a

theorem pin_sum_one (A : Finset ι) (ρ : ι → α)
    (p : ι → α → ℝ) (hp : ∀ i, ∑ a, p i a = 1) :
    ∀ i, ∑ a, pin A ρ p i a = 1 := by
  intro i
  by_cases hi : i ∈ A
  · simpa [pin, hi] using (delta_sum (ρ i))
  · simpa [pin, hi] using hp i

theorem same_pin_tv_zero (A : Finset ι) (ρ : ι → α)
    (p q : ι → α → ℝ) (i : ι) (hi : i ∈ A) :
    tvd (pin A ρ p i) (pin A ρ q i) = 0 := by
  have hs : tvd (delta (ρ i)) (delta (ρ i)) = 0 := by
    unfold tvd
    simp [delta_sum]
  simpa [pin, hi] using hs

/-- Coordinate TV is unchanged off the pinned set, and is exactly zero
on the set. Thus the source-level stability theorem applies directly. -/
theorem pin_tvd_le (A : Finset ι) (ρ : ι → α)
    (p q : ι → α → ℝ) (γ : ℝ)
    (hγ : 0 ≤ γ)
    (hsmall : ∀ i, i ∉ A → tvd (p i) (q i) ≤ γ) :
    ∀ i, tvd (pin A ρ p i) (pin A ρ q i) ≤ γ := by
  intro i
  by_cases hi : i ∈ A
  · rw [same_pin_tv_zero A ρ p q i hi]
    exact hγ
  · simpa [pin, hi] using hsmall i hi

/-- Exact source-level c-free expectation stability after fixing ANY
finite set of coordinates. Its proof depends on the upstream verified
`fooling_tv_positive_gap`, not on an assumption of mean stability. -/
theorem pinned_expectation_stability
    (A : Finset ι) (ρ : ι → α)
    (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ : ℝ) (hγ : 0 < γ)
    (hsmall : ∀ i, i ∉ A → tvd (p i) (q i) ≤ γ)
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f d) :
    |pexp (pin A ρ p) f - pexp (pin A ρ q) f|
      ≤ 16 * (d : ℝ) ^ 2 * γ := by
  exact fooling_tv_positive_gap
    (pin A ρ p) (pin A ρ q)
    (pin_nonneg A ρ p hp0)
    (pin_nonneg A ρ q hq0)
    (pin_sum_one A ρ p hp1)
    (pin_sum_one A ρ q hq1)
    γ hγ (pin_tvd_le A ρ p q γ (le_of_lt hγ) hsmall)
    d hd f hf hdegree

/-- A fully sourced bound for the conditional means that PR #893 formerly
passed as an analytic hypothesis `hBern`. No bias floor is used. -/
theorem pinned_small_mean_shift
    (A : Finset ι) (ρ : ι → α)
    (p q : ι → α → ℝ)
    (hp0 : ∀ i a, 0 ≤ p i a) (hq0 : ∀ i a, 0 ≤ q i a)
    (hp1 : ∀ i, ∑ a, p i a = 1) (hq1 : ∀ i, ∑ a, q i a = 1)
    (γ ε : ℝ) (hγ : 0 < γ)
    (hsmall : ∀ i, i ∉ A → tvd (p i) (q i) ≤ γ)
    (d : ℕ) (hd : 1 ≤ d) (f : (ι → α) → ℝ)
    (hf : ∀ x, 0 ≤ f x ∧ f x ≤ 1)
    (hdegree : HasProdDegreeLE f d)
    (hbudget : 16 * (d : ℝ) ^ 2 * γ ≤ ε) :
    |pexp (pin A ρ p) f - pexp (pin A ρ q) f| ≤ ε :=
  (pinned_expectation_stability A ρ p q hp0 hq0 hp1 hq1 γ hγ
    hsmall d hd f hf hdegree).trans hbudget

end Nightfall.ProductSpace.PinnedConditional
