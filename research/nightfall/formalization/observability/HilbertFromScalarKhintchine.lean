import Mathlib

/-!
# Q3 sharp Hilbert-vector Khintchine reduction to its scalar input

This proves that a scalar Rademacher L1/L2 estimate for each coordinate of
a finite real vector family implies the *same constant* for the entire finite
Euclidean vector family, using finite Cauchy--Schwarz and original averaging.

The scalar Khintchine theorem is an EXPLICIT, quantified hypothesis.
No global arbitrary-family scalar inequality is claimed here. A kernel proof
of the present lifting reduces the remaining analytic #804 gap from vector
Khintchine to classical scalar Khintchine, but does not close that gap.
-/

namespace Nightfall.CubicQ3.ScalarToHilbert

open Finset

/-- Exact finite Cauchy--Schwarz with square-root norms. -/
theorem finite_cauchy_norm
    {K : Type*} [Fintype K] (x y : K → ℝ)
    (hx : ∀ k, 0 ≤ x k) :
    (∑ k, x k * |y k|) ≤
      Real.sqrt (∑ k, (x k)^2) *
      Real.sqrt (∑ k, (y k)^2) := by
  have hleft0 : 0 ≤ (∑ k, x k * |y k|) := by
    apply Finset.sum_nonneg
    intro k _
    exact mul_nonneg (hx k) (abs_nonneg _)
  have hX : 0 ≤ (∑ k, (x k)^2) := by positivity
  have hY : 0 ≤ (∑ k, (y k)^2) := by positivity
  have hsqX := Real.sq_sqrt hX
  have hsqY := Real.sq_sqrt hY
  have hroot0 : 0 ≤
      Real.sqrt (∑ k, (x k)^2) *
      Real.sqrt (∑ k, (y k)^2) :=
    mul_nonneg (Real.sqrt_nonneg _) (Real.sqrt_nonneg _)
  have hcs :
      (∑ k, x k * |y k|)^2 ≤
        (∑ k, (x k)^2) * (∑ k, (y k)^2) := by
    simpa only [sq_abs] using
      (Finset.sum_mul_sq_le_sq_mul_sq
        (Finset.univ : Finset K) x (fun k => |y k|))
  have hrootSq :
      (Real.sqrt (∑ k, (x k)^2) *
        Real.sqrt (∑ k, (y k)^2))^2 =
      (∑ k, (x k)^2) * (∑ k, (y k)^2) := by
    rw [mul_pow, hsqX, hsqY]
  nlinarith [hrootSq]

/-- Conditional scalar-to-Hilbert L1/L2 lifting at precisely the same
factor C. The external sign space may be any finite weighted table.
This is enough to transport an eventual separately-certified scalar sharp
Khintchine inequality to arbitrary finite Euclidean output dimensions. -/
theorem vector_khintchine_from_scalar_coordinates
    {ι K Ω : Type*} [Fintype ι] [Fintype K] [Fintype Ω]
    (p : Ω → ℝ) (eps : Ω → ι → ℝ) (a : ι → K → ℝ)
    (C : ℝ)
    (hp : ∀ ω, 0 ≤ p ω) (hC : 0 ≤ C)
    (hscalar : ∀ k,
      Real.sqrt (∑ i, (a i k)^2) ≤
        C * (∑ ω, p ω * |∑ i, eps ω i * a i k|)) :
    Real.sqrt (∑ i, ∑ k, (a i k)^2) ≤
      C * (∑ ω, p ω *
        Real.sqrt (∑ k, (∑ i, eps ω i * a i k)^2)) := by
  let b : K → ℝ := fun k => Real.sqrt (∑ i, (a i k)^2)
  let e : Ω → K → ℝ := fun ω k => ∑ i, eps ω i * a i k
  let S : ℝ := Real.sqrt (∑ k, (b k)^2)
  let A : ℝ := ∑ ω, p ω *
    Real.sqrt (∑ k, (e ω k)^2)
  have hb0 (k : K) : 0 ≤ b k := Real.sqrt_nonneg _
  have hbSq (k : K) : (b k)^2 = ∑ i, (a i k)^2 := by
    exact Real.sq_sqrt (by positivity)
  have hSqS : S^2 = ∑ k, (b k)^2 :=
    Real.sq_sqrt (by positivity)
  have hS0 : 0 ≤ S := Real.sqrt_nonneg _
  have hA0 : 0 ≤ A := by
    dsimp [A]
    apply Finset.sum_nonneg
    intro ω _
    exact mul_nonneg (hp ω) (Real.sqrt_nonneg _)
  have heach (ω : Ω) :
      (∑ k, b k * |e ω k|) ≤
        S * Real.sqrt (∑ k, (e ω k)^2) :=
    finite_cauchy_norm (b) (e ω) hb0
  have hscalarWeighted (k : K) :
      (b k)^2 ≤
        C * (b k) * (∑ ω, p ω * |e ω k|) := by
    have hh := mul_le_mul_of_nonneg_left (hscalar k) (hb0 k)
    dsimp [b, e] at *
    nlinarith
  have hsumScalar :
      (∑ k, (b k)^2) ≤
        C * (∑ ω, p ω * (∑ k, b k * |e ω k|)) := by
    calc
      (∑ k, (b k)^2) ≤
          (∑ k, C * b k * (∑ ω, p ω * |e ω k|)) := by
        apply Finset.sum_le_sum
        intro k _
        exact hscalarWeighted k
      _ = C * (∑ ω, p ω * (∑ k, b k * |e ω k|)) := by
        calc
          (∑ k, C * b k * (∑ ω, p ω * |e ω k|)) =
              (∑ k, ∑ ω, (C * b k) * (p ω * |e ω k|)) := by
            apply Finset.sum_congr rfl
            intro k _
            rw [Finset.mul_sum]
          _ = (∑ ω, ∑ k, C * (p ω * (b k * |e ω k|))) := by
            rw [Finset.sum_comm]
            apply Finset.sum_congr rfl
            intro ω _
            apply Finset.sum_congr rfl
            intro k _
            ring
          _ = (∑ ω, C * (p ω * (∑ k, b k * |e ω k|))) := by
            apply Finset.sum_congr rfl
            intro ω _
            calc
              _ = C * (∑ k, p ω * (b k * |e ω k|)) := by
                rw [Finset.mul_sum]
              _ = C * (p ω * (∑ k, b k * |e ω k|)) := by
                rw [Finset.mul_sum]
          _ = C * (∑ ω, p ω * (∑ k, b k * |e ω k|)) := by
            rw [Finset.mul_sum]
  have hsumCS :
      (∑ ω, p ω * (∑ k, b k * |e ω k|)) ≤ S * A := by
    calc
      _ ≤ (∑ ω, p ω * (S * Real.sqrt (∑ k, (e ω k)^2))) := by
        apply Finset.sum_le_sum
        intro ω _
        exact mul_le_mul_of_nonneg_left (heach ω) (hp ω)
      _ = S * A := by
        calc
          _ = (∑ ω, S * (p ω * Real.sqrt (∑ k, (e ω k)^2))) := by
            apply Finset.sum_congr rfl
            intro ω _
            ring
          _ = S * A := by rw [Finset.mul_sum]
  have hmain : S^2 ≤ C * (S * A) := by
    calc
      S^2 = (∑ k, (b k)^2) := hSqS
      _ ≤ C * (∑ ω, p ω * (∑ k, b k * |e ω k|)) :=
        hsumScalar
      _ ≤ C * (S * A) :=
        mul_le_mul_of_nonneg_left hsumCS hC
  have hSle : S ≤ C * A := by
    by_cases hzero : S = 0
    · rw [hzero]
      exact mul_nonneg hC hA0
    · have hSp : 0 < S := lt_of_le_of_ne hS0 (Ne.symm hzero)
      by_contra h
      have hbad : 0 < S - C * A := sub_pos.mpr (lt_of_not_ge h)
      have hprod := mul_pos hSp hbad
      nlinarith
  have hid :
      (∑ i, ∑ k, (a i k)^2) = (∑ k, (b k)^2) := by
    calc
      _ = ∑ k, ∑ i, (a i k)^2 := Finset.sum_comm
      _ = ∑ k, (b k)^2 := by
        apply Finset.sum_congr rfl
        intro k _
        exact (hbSq k).symm
  calc
    Real.sqrt (∑ i, ∑ k, (a i k)^2) = S := by
      dsimp [S]
      rw [hid]
    _ ≤ C * A := hSle
    _ = C * (∑ ω, p ω *
      Real.sqrt (∑ k, (∑ i, eps ω i * a i k)^2)) := rfl

end Nightfall.CubicQ3.ScalarToHilbert
