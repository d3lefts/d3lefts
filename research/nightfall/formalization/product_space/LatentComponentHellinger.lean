import Mathlib

/-! A finite atom-safe total-variation / Hellinger comparison.
    A future tensorization theorem must connect this to product-query depth. -/
namespace Nightfall.ProductSpace.LatentComponent

open Finset
variable {β : Type} [Fintype β] [DecidableEq β]

noncomputable def finiteTV (p q : β → ℝ) : ℝ := (∑ z, |p z - q z|) / 2
noncomputable def finiteAffinity (p q : β → ℝ) : ℝ :=
  ∑ z, Real.sqrt (p z) * Real.sqrt (q z)

theorem finiteAffinity_nonneg (p q : β → ℝ) : 0 ≤ finiteAffinity p q := by
  unfold finiteAffinity
  exact Finset.sum_nonneg (fun z _ => mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))

theorem finiteAffinity_le_one (p q : β → ℝ)
    (hp : ∀ z, 0 ≤ p z) (hq : ∀ z, 0 ≤ q z)
    (hp1 : ∑ z, p z = 1) (hq1 : ∑ z, q z = 1) :
    finiteAffinity p q ≤ 1 := by
  have h := Real.sum_sqrt_mul_sqrt_le (univ : Finset β) hp hq
  simpa [finiteAffinity, hp1, hq1] using h

theorem finiteTV_sq_le_one_sub_affinity_sq (p q : β → ℝ)
    (hp : ∀ z, 0 ≤ p z) (hq : ∀ z, 0 ≤ q z)
    (hp1 : ∑ z, p z = 1) (hq1 : ∑ z, q z = 1) :
    (finiteTV p q) ^ 2 ≤ 1 - (finiteAffinity p q) ^ 2 := by
  let u : β → ℝ := fun z => Real.sqrt (p z) - Real.sqrt (q z)
  let v : β → ℝ := fun z => Real.sqrt (p z) + Real.sqrt (q z)
  let A : ℝ := ∑ z, (|u z|) ^ 2
  let B : ℝ := ∑ z, (v z) ^ 2
  let S : ℝ := ∑ z, |p z - q z|
  have hA0 : 0 ≤ A := Finset.sum_nonneg (fun z _ => sq_nonneg _)
  have hB0 : 0 ≤ B := Finset.sum_nonneg (fun z _ => sq_nonneg _)
  have hS0 : 0 ≤ S := Finset.sum_nonneg (fun z _ => abs_nonneg _)
  have hcore (z : β) : |u z| * v z = |p z - q z| := by
    have hmul : u z * v z = p z - q z := by
      dsimp [u, v]
      calc
        (Real.sqrt (p z) - Real.sqrt (q z)) *
            (Real.sqrt (p z) + Real.sqrt (q z)) =
            (Real.sqrt (p z)) ^ 2 - (Real.sqrt (q z)) ^ 2 := by ring
        _ = p z - q z := by rw [Real.sq_sqrt (hp z), Real.sq_sqrt (hq z)]
    rw [← hmul, abs_mul, abs_of_nonneg (add_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _))]
  have hcs : S ≤ Real.sqrt A * Real.sqrt B := by
    have h := Real.sum_mul_le_sqrt_mul_sqrt (univ : Finset β)
      (fun z => |u z|) v
    simpa only [← hcore, A, B, S] using h
  have hpow := pow_le_pow_left₀ hS0 hcs 2
  have hpow' : S ^ 2 ≤ A * B := by
    convert hpow using 1
    rw [mul_pow, Real.sq_sqrt hA0, Real.sq_sqrt hB0]
  have hA : A = 2 - 2 * finiteAffinity p q := by
    have hpt (z : β) : |u z| ^ 2 = p z + q z - 2 * Real.sqrt (p z) * Real.sqrt (q z) := by
      dsimp [u]
      rw [sq_abs]
      have h1 := Real.sq_sqrt (hp z)
      have h2 := Real.sq_sqrt (hq z)
      nlinarith
    dsimp [A]
    simp_rw [hpt]
    simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hp1, hq1]
    unfold finiteAffinity
    rw [← Finset.sum_mul]
    ring
  have hB : B = 2 + 2 * finiteAffinity p q := by
    have hpt (z : β) : v z ^ 2 = p z + q z + 2 * Real.sqrt (p z) * Real.sqrt (q z) := by
      dsimp [v]
      have h1 := Real.sq_sqrt (hp z)
      have h2 := Real.sq_sqrt (hq z)
      nlinarith
    dsimp [B]
    simp_rw [hpt]
    simp only [Finset.sum_add_distrib, ← Finset.mul_sum, hp1, hq1]
    unfold finiteAffinity
    rw [← Finset.sum_mul]
    ring
  dsimp [finiteTV]
  dsimp [S] at hpow'
  rw [hA, hB] at hpow'
  nlinarith

theorem finiteAffinity_le_one_sub_half_tv_sq (p q : β → ℝ)
    (hp : ∀ z, 0 ≤ p z) (hq : ∀ z, 0 ≤ q z)
    (hp1 : ∑ z, p z = 1) (hq1 : ∑ z, q z = 1) :
    finiteAffinity p q ≤ 1 - (finiteTV p q) ^ 2 / 2 := by
  have hsq := finiteTV_sq_le_one_sub_affinity_sq p q hp hq hp1 hq1
  have hone := finiteAffinity_le_one p q hp hq hp1 hq1
  nlinarith [sq_nonneg (finiteAffinity p q - 1)]

end Nightfall.ProductSpace.LatentComponent
