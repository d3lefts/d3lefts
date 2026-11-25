import Mathlib

namespace Nightfall.FiniteField.RankPhaseTransport
open Finset
variable {K ι κ : Type*} [Field K] [DecidableEq K] [Fintype ι] [Fintype κ]

theorem calibrated_reading (u0 lam c : K) (u s a : ι → K) (d : ℕ)
    (hu0 : u0 ≠ 0) (hlam : lam ^ d = 1)
    (hz : ∀ i, u i = 0 → s i = 1) :
    (((c + ∑ i, if u i = 0 then a i else 0) / u0) * (lam * u0)
      + ∑ i, (if u i = 0 then 0 else a i / u i) * (lam * u i * s i)) ^ d =
      (c + ∑ i, a i * s i) ^ d := by
  classical
  have h0 : ((c + ∑ i, if u i = 0 then a i else 0) / u0) * (lam * u0) =
      lam * (c + ∑ i, if u i = 0 then a i else 0) := by
    field_simp [hu0] <;> ring
  have hi (i : ι) : (if u i = 0 then 0 else a i / u i) * (lam * u i * s i) =
      lam * (a i * s i - if u i = 0 then a i else 0) := by
    by_cases hu : u i = 0
    · simp [hu, hz i hu]
    · simp only [if_neg hu, sub_zero]
      field_simp [hu] <;> ring
  have hs : (((c + ∑ i, if u i = 0 then a i else 0) / u0) * (lam * u0)
      + ∑ i, (if u i = 0 then 0 else a i / u i) * (lam * u i * s i)) =
      lam * (c + ∑ i, a i * s i) := by
    rw [h0]
    simp_rw [hi]
    rw [← Finset.mul_sum, Finset.sum_sub_distrib]
    ring
  rw [hs, mul_pow, hlam, one_mul]

theorem dependent_row_reading (a x : κ → K) (b : ι → κ → K)
    (gamma w : ι → K) (d : ℕ)
    (hrow : ∀ j, a j = ∑ i, gamma i * b i j)
    (hw : ∀ i, w i = ∑ j, b i j * x j) :
    (∑ j, a j * x j) ^ d = (∑ i, gamma i * w i) ^ d := by
  have h : (∑ j, a j * x j) = ∑ i, gamma i * w i := by
    simp_rw [hrow, Finset.sum_mul]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    rw [hw i, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [h]

theorem normalized_anchor_unique (a x y : κ → K) (lam : K)
    (hx : ∑ j, a j * x j = 1) (hy : ∑ j, a j * y j = 1)
    (he : ∀ j, y j = lam * x j) : y = x := by
  have h : (∑ j, a j * y j) = lam * (∑ j, a j * x j) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j _
    rw [he j]
    ring
  rw [hx, hy, mul_one] at h
  funext j
  rw [he j, ← h, one_mul]

theorem kernel_shift_collision (b : ι → κ → K) (x v : κ → K)
    (hnz : v ≠ 0) (hvzero : ∀ i, ∑ j, b i j * v j = 0)
    (hanchor : ∃ i, ∑ j, b i j * x j = 1) :
    (∀ i, ∑ j, b i j * (x j + v j) = ∑ j, b i j * x j) ∧
      ¬ ∃ lam : K, ∀ j, x j + v j = lam * x j := by
  have hread (i : ι) : (∑ j, b i j * (x j + v j)) = ∑ j, b i j * x j := by
    simp_rw [mul_add, Finset.sum_add_distrib, hvzero, add_zero]
  refine ⟨hread, ?_⟩
  rintro ⟨lam, hlam⟩
  obtain ⟨i, hi⟩ := hanchor
  have hy : (∑ j, b i j * (x j + v j)) = 1 := (hread i).trans hi
  have hxy := normalized_anchor_unique (b i) x (fun j => x j + v j) lam hi hy hlam
  apply hnz
  funext j
  have hj := congrFun hxy j
  exact add_left_cancel (show x j + v j = x j + 0 by simpa only [add_zero] using hj)

#print axioms calibrated_reading
#print axioms dependent_row_reading
#print axioms normalized_anchor_unique
#print axioms kernel_shift_collision
end Nightfall.FiniteField.RankPhaseTransport
