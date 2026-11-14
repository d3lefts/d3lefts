import ActualProductSoftStarParseval

/-!
# Source-derived canonical two-site double-centering

Constructs a genuine pair-sector table FROM an arbitrary finite source
function f and its literal original law. Separate centering is derived
from finite weighted sums and normalization, not assumed from a
synthetic Efron–Stein source.

The additional identification with the repository's historical
Efron–Stein Mobius component and the full Q2 source theorem are
different declarations requiring their own strict current-pin replay.
-/

namespace Nightfall.Observability.ActualProductSourcePairCentering

open Finset
open Nightfall.Observability.ActualProductMergeTower
open Nightfall.Observability.ActualProductSoftNoise
open Nightfall.Observability.ActualProductPairSector

variable {ι α : Type*} [Fintype ι] [DecidableEq ι]
  [Fintype α] [DecidableEq α]

/-- Algebraic two-sided centering of a finite two-coordinate table.
The formula is meaningful for arbitrary normalized real weights,
including weights that happen to vanish. -/
noncomputable def doubleCenter
    (q r : α → ℝ) (F : α → α → ℝ) (a b : α) : ℝ :=
  F a b -
    (∑ u : α, q u * F u b) -
    (∑ v : α, r v * F a v) +
    (∑ u : α, q u * (∑ v : α, r v * F u v))

/-- The first source coordinate marginal of a doubly centered
two-site table is identically zero. -/
theorem doubleCenter_first_centered
    (q r : α → ℝ)
    (hq1 : (∑ u : α, q u) = 1)
    (F : α → α → ℝ) (b : α) :
    (∑ a : α, q a * doubleCenter q r F a b) = 0 := by
  classical
  unfold doubleCenter
  simp only [mul_add, mul_sub, Finset.sum_add_distrib,
    Finset.sum_sub_distrib]
  rw [← Finset.sum_mul, ← Finset.sum_mul, hq1]
  ring

/-- Original-law Fubini identity for a finite pair table, with
no positivity assumption. -/
theorem weighted_two_site_sum_comm
    (q r : α → ℝ) (F : α → α → ℝ) :
    (∑ b : α, r b * (∑ a : α, q a * F a b)) =
      ∑ a : α, q a * (∑ b : α, r b * F a b) := by
  classical
  calc
    (∑ b : α, r b * (∑ a : α, q a * F a b)) =
      ∑ b : α, ∑ a : α, r b * (q a * F a b) := by
        simp only [Finset.mul_sum]
    _ = ∑ a : α, ∑ b : α, r b * (q a * F a b) :=
      Finset.sum_comm
    _ = ∑ a : α, q a * (∑ b : α, r b * F a b) := by
      apply Finset.sum_congr rfl
      intro a _
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro b _
      ring

/-- The second source coordinate marginal of the same table is
identically zero. This checks both sides of genuine pair degeneracy. -/
theorem doubleCenter_second_centered
    (q r : α → ℝ)
    (hr1 : (∑ v : α, r v) = 1)
    (F : α → α → ℝ) (a : α) :
    (∑ b : α, r b * doubleCenter q r F a b) = 0 := by
  classical
  unfold doubleCenter
  simp only [mul_add, mul_sub, Finset.sum_add_distrib,
    Finset.sum_sub_distrib]
  rw [← Finset.sum_mul, ← Finset.sum_mul, hr1]
  rw [weighted_two_site_sum_comm q r F]
  ring

/-- This pair table is extracted from the actual original function
by fixing two original coordinate values while refreshing everything
else under the genuine finite product source. -/
noncomputable def sourceTwoSiteTable
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (j k : ι) (a b : α) : ℝ :=
  ∑ y : ι → α, originalMass p y *
    f (Function.update (Function.update y j a) k b)

/-- A two-site Hoeffding pair candidate derived from f alone, by
separately centering the true-source two-site table. No free
synthetic pair kernel, expected energy, or positive-atom floor. -/
noncomputable def sourceDoubleCenteredPair
    (p : ι → α → ℝ) (f : (ι → α) → ℝ)
    (j k : ι) (a b : α) : ℝ :=
  doubleCenter (p j) (p k) (sourceTwoSiteTable p f j k) a b

/-- Genuine source-derived first-coordinate degeneracy. -/
theorem actual_source_derived_pair_first_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (b : α) :
    (∑ a : α, p j a * sourceDoubleCenteredPair p f j k a b) = 0 := by
  exact doubleCenter_first_centered (p j) (p k) (hp1 j)
    (sourceTwoSiteTable p f j k) b

/-- Genuine source-derived second-coordinate degeneracy. -/
theorem actual_source_derived_pair_second_centered
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (f : (ι → α) → ℝ) (j k : ι) (a : α) :
    (∑ b : α, p k b * sourceDoubleCenteredPair p f j k a b) = 0 := by
  exact doubleCenter_second_centered (p j) (p k) (hp1 k)
    (sourceTwoSiteTable p f j k) a

/-- Apply the previously strict-compiled true-product soft-refresh
pair eigenaction to the pair term derived directly from f. -/
theorem actual_source_derived_pair_soft_eigen
    (p : ι → α → ℝ)
    (hp1 : ∀ i, (∑ a : α, p i a) = 1)
    (retain : ι → ℝ)
    (f : (ι → α) → ℝ)
    (j k : ι) (hjk : j ≠ k) (x : ι → α) :
    softSourceNoise p retain
      (fun z : ι → α =>
        sourceDoubleCenteredPair p f j k (z j) (z k)) x =
      (retain j * retain k) *
        sourceDoubleCenteredPair p f j k (x j) (x k) := by
  exact actual_soft_noise_centered_pair_eigen
    p hp1 retain j k hjk (sourceDoubleCenteredPair p f j k)
    (actual_source_derived_pair_first_centered p hp1 f j k)
    (actual_source_derived_pair_second_centered p hp1 f j k) x

end Nightfall.Observability.ActualProductSourcePairCentering
