import Mathlib

/-!
NIGHTFALL cubic and higher-degree frontier: a finite, exact ANOVA
transversal inequality.

The draft top-degree transversal argument says that when a set of
coordinates meets every nonzero interaction support of size >= 3,
all high-order variance mass is bounded by the sum of those
coordinates' ANOVA resampling influences.

This is purely finite combinatorial bookkeeping for nonnegative
interaction energies. It does not assert the underlying product-space
Hoeffding expansion, the degree-two quadratic estimate for integrated
functions, or the full cubic exponent-two influence inequality.
-/

namespace Nightfall.Observability.TopCover

open Finset

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

def totalEnergy (E : Finset ι → ℝ) : ℝ :=
  ∑ S : Finset ι, E S

def lowDegreeEnergy (E : Finset ι → ℝ) : ℝ :=
  ∑ S : Finset ι, if S.card < 3 then E S else 0

def highDegreeEnergy (E : Finset ι → ℝ) : ℝ :=
  ∑ S : Finset ι, if 3 ≤ S.card then E S else 0

def coordinateEnergy (E : Finset ι → ℝ) (i : ι) : ℝ :=
  ∑ S : Finset ι, if i ∈ S then E S else 0

def coverInfluence (E : Finset ι → ℝ) (H : Finset ι) : ℝ :=
  ∑ S : Finset ι, ∑ i ∈ H, if i ∈ S then E S else 0

/-- Every finite energy table splits exactly into low and high
interaction orders. -/
theorem totalEnergy_split (E : Finset ι → ℝ) :
    totalEnergy E = lowDegreeEnergy E + highDegreeEnergy E := by
  unfold totalEnergy lowDegreeEnergy highDegreeEnergy
  rw [← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro S _
  by_cases h : 3 ≤ S.card
  · have hnot : ¬ S.card < 3 := Nat.not_lt.mpr h
    simp [h, hnot]
  · have hlt : S.card < 3 := Nat.lt_of_not_ge h
    simp [h, hlt]

/-- The cost of a cover is the sum of the individual coordinate
influence energies, not an arbitrary unrelated quantity. -/
theorem coverInfluence_eq_sum_coordinates
    (E : Finset ι → ℝ) (H : Finset ι) :
    coverInfluence E H = ∑ i ∈ H, coordinateEnergy E i := by
  unfold coverInfluence coordinateEnergy
  rw [Finset.sum_comm]

/-- Every nonzero interaction of order >=3 touches the transversal H:
its nonnegative energy can be charged at least once to H. -/
theorem highEnergy_le_coverInfluence
    (E : Finset ι → ℝ) (H : Finset ι)
    (hE : ∀ S, 0 ≤ E S)
    (hcover : ∀ S : Finset ι, 3 ≤ S.card → E S ≠ 0 →
        ∃ i, i ∈ H ∧ i ∈ S) :
    highDegreeEnergy E ≤ coverInfluence E H := by
  unfold highDegreeEnergy coverInfluence
  apply Finset.sum_le_sum
  intro S _
  have hrhs : 0 ≤ ∑ i ∈ H, if i ∈ S then E S else 0 := by
    apply Finset.sum_nonneg
    intro i _
    split_ifs <;> exact (hE S)
  by_cases h3 : 3 ≤ S.card
  · by_cases hz : E S = 0
    · simp [h3, hz]
      exact hrhs
    · obtain ⟨i, hiH, hiS⟩ := hcover S h3 hz
      have he : 0 ≤ ∑ j ∈ H.erase i,
          if j ∈ S then E S else 0 := by
        apply Finset.sum_nonneg
        intro j _
        split_ifs <;> exact (hE S)
      have heq : (∑ j ∈ H, if j ∈ S then E S else 0) =
          (∑ j ∈ H.erase i, if j ∈ S then E S else 0) + E S := by
        have hh := Finset.sum_erase_add H
          (fun j => if j ∈ S then E S else 0) hiH
        rw [if_pos hiS] at hh
        exact hh.symm
      simp only [if_pos h3]
      rw [heq]
      linarith
  · simp [h3]
    exact hrhs

/-- With a coordinate-wise upper bound M, charging all high-order
components to a t-vertex cover costs at most t*M, independent of the
number of high-order interactions and categorical alphabet sizes. -/
theorem highEnergy_le_card_mul_max
    (E : Finset ι → ℝ) (H : Finset ι) (M : ℝ)
    (hE : ∀ S, 0 ≤ E S)
    (hcover : ∀ S : Finset ι, 3 ≤ S.card → E S ≠ 0 →
        ∃ i, i ∈ H ∧ i ∈ S)
    (hM : ∀ i ∈ H, coordinateEnergy E i ≤ M) :
    highDegreeEnergy E ≤ (H.card : ℝ) * M := by
  calc
    highDegreeEnergy E ≤ coverInfluence E H :=
      highEnergy_le_coverInfluence E H hE hcover
    _ = ∑ i ∈ H, coordinateEnergy E i :=
      coverInfluence_eq_sum_coordinates E H
    _ ≤ ∑ i ∈ H, M :=
      Finset.sum_le_sum (fun i hi => hM i hi)
    _ = (H.card : ℝ) * M := by
      simp [mul_comm]

/-- Consequence: a scalar degree-two estimate for the low-order
energy plus a top-degree transversal implies the cubic restricted
variance inequality. The analytic low-order bound is explicitly a
premise; it is not claimed to be kernel-proved here. -/
theorem cubic_top_cover_variance_bound
    (E : Finset ι → ℝ) (H : Finset ι)
    (B M C : ℝ)
    (hE : ∀ S, 0 ≤ E S)
    (hcover : ∀ S : Finset ι, 3 ≤ S.card → E S ≠ 0 →
        ∃ i, i ∈ H ∧ i ∈ S)
    (hM : ∀ i ∈ H, coordinateEnergy E i ≤ M)
    (hLow : lowDegreeEnergy E ≤ C * B * Real.sqrt M) :
    totalEnergy E ≤ C * B * Real.sqrt M + (H.card : ℝ) * M := by
  rw [totalEnergy_split]
  have hhi := highEnergy_le_card_mul_max E H M hE hcover hM
  linarith

end Nightfall.Observability.TopCover
