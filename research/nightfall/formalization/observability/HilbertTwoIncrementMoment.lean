import ArbitraryLawFourthMoment

/-!
# NIGHTFALL: two independent arbitrary-law Hilbert increments

This is an ACTUAL finite-product proof (not a supplied moment inequality)
for two centered finite-dimensional real Hilbert increments drawn from
independent arbitrary finite laws, including zero-mass atoms.

It derives the dimension-free fourth-moment estimate

 E||U+V||^4 <= E||U||^4 + E||V||^4
                  + 6 E||U||^2 E||V||^2.

This is the exact two-increment step toward the many-increment Hilbert
martingale bound needed in the unrestricted quadratic influence theorem.
The many-increment induction, matching assignment, and actual-product
ANOVA energy transfer remain separate obligations.
-/

namespace Nightfall.Observability.QuadraticHilbertMoments

open Finset
open Nightfall.Observability.QuadraticMoments

variable {A B K : Type*} [Fintype A] [Fintype B] [Fintype K]

noncomputable def vecNormSq (u : K → ℝ) : ℝ := ∑ k : K, (u k) ^ 2
noncomputable def vecDot (u v : K → ℝ) : ℝ := ∑ k : K, u k * v k

theorem vec_normSq_add (u v : K → ℝ) :
    vecNormSq (fun k => u k + v k) =
      vecNormSq u + vecNormSq v + 2 * vecDot u v := by
  unfold vecNormSq vecDot
  calc
    (∑ k : K, (u k + v k) ^ 2) =
      ∑ k : K, (u k ^ 2 + v k ^ 2 + 2 * (u k * v k)) := by
        apply Finset.sum_congr rfl
        intro k _
        ring
    _ = (∑ k : K, u k ^ 2) +
          (∑ k : K, v k ^ 2) +
          2 * (∑ k : K, u k * v k) := by
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.mul_sum]

theorem jointAvg_finset_sum
    (p : A → ℝ) (q : B → ℝ)
    (F : K → A → B → ℝ) :
    jointAvg p q (fun a b => ∑ k : K, F k a b) =
      ∑ k : K, jointAvg p q (F k) := by
  unfold jointAvg
  calc
    (∑ a : A, ∑ b : B, p a * q b * (∑ k : K, F k a b)) =
        ∑ a : A, ∑ b : B, ∑ k : K, p a * q b * F k a b := by
          apply Finset.sum_congr rfl
          intro a _
          apply Finset.sum_congr rfl
          intro b _
          rw [Finset.mul_sum]
    _ = ∑ a : A, ∑ k : K, ∑ b : B, p a * q b * F k a b := by
          apply Finset.sum_congr rfl
          intro a _
          exact Finset.sum_comm
    _ = ∑ k : K, ∑ a : A, ∑ b : B, p a * q b * F k a b := Finset.sum_comm

theorem vec_dot_sq_le (u v : K → ℝ) :
    (vecDot u v) ^ 2 ≤ vecNormSq u * vecNormSq v := by
  unfold vecDot vecNormSq
  exact Finset.sum_mul_sq_le_sq_mul_sq Finset.univ u v

/-- Exact cancellation of third-by-first mixed moments, using the
actual independent product measure and coordinatewise centering. -/
theorem odd_vector_cross_zero_left
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (hV0 : ∀ k : K, (∑ b : B, q b * V b k) = 0) :
    jointAvg p q (fun a b =>
      vecNormSq (U a) * vecDot (U a) (V b)) = 0 := by
  have hpoint (a : A) (b : B) :
      vecNormSq (U a) * vecDot (U a) (V b) =
        ∑ k : K, (vecNormSq (U a) * U a k) * V b k := by
    unfold vecDot
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro k _
    ring
  calc
    jointAvg p q (fun a b =>
      vecNormSq (U a) * vecDot (U a) (V b)) =
      jointAvg p q (fun a b =>
        ∑ k : K, (vecNormSq (U a) * U a k) * V b k) := by
          unfold jointAvg
          apply Finset.sum_congr rfl
          intro a _
          apply Finset.sum_congr rfl
          intro b _
          rw [hpoint]
    _ = ∑ k : K, jointAvg p q
        (fun a b => (vecNormSq (U a) * U a k) * V b k) :=
          jointAvg_finset_sum p q _
    _ = 0 := by
          apply Finset.sum_eq_zero
          intro k _
          rw [jointAvg_factor]
          rw [hV0 k, mul_zero]

theorem odd_vector_cross_zero_right
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (hU0 : ∀ k : K, (∑ a : A, p a * U a k) = 0) :
    jointAvg p q (fun a b =>
      vecNormSq (V b) * vecDot (U a) (V b)) = 0 := by
  have hpoint (a : A) (b : B) :
      vecNormSq (V b) * vecDot (U a) (V b) =
        ∑ k : K, U a k * (vecNormSq (V b) * V b k) := by
    unfold vecDot
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro k _
    ring
  calc
    jointAvg p q (fun a b =>
      vecNormSq (V b) * vecDot (U a) (V b)) =
      jointAvg p q (fun a b =>
        ∑ k : K, U a k * (vecNormSq (V b) * V b k)) := by
          unfold jointAvg
          apply Finset.sum_congr rfl
          intro a _
          apply Finset.sum_congr rfl
          intro b _
          rw [hpoint]
    _ = ∑ k : K, jointAvg p q
        (fun a b => U a k * (vecNormSq (V b) * V b k)) :=
          jointAvg_finset_sum p q _
    _ = 0 := by
          apply Finset.sum_eq_zero
          intro k _
          rw [jointAvg_factor]
          rw [hU0 k, zero_mul]

/-- Dimension-independent Hilbert two-increment fourth-moment inequality
for genuinely independent arbitrary finite distributions. -/
theorem independent_centered_two_hilbert_fourth
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (hp : ∀ a, 0 ≤ p a) (hq : ∀ b, 0 ≤ q b)
    (hp1 : (∑ a : A, p a) = 1)
    (hq1 : (∑ b : B, q b) = 1)
    (hU0 : ∀ k : K, (∑ a : A, p a * U a k) = 0)
    (hV0 : ∀ k : K, (∑ b : B, q b * V b k) = 0) :
    jointAvg p q (fun a b =>
      (vecNormSq (fun k => U a k + V b k)) ^ 2) ≤
      (∑ a : A, p a * (vecNormSq (U a)) ^ 2) +
      (∑ b : B, q b * (vecNormSq (V b)) ^ 2) +
      6 * (∑ a : A, p a * vecNormSq (U a)) *
          (∑ b : B, q b * vecNormSq (V b)) := by
  let nu : A → ℝ := fun a => vecNormSq (U a)
  let nv : B → ℝ := fun b => vecNormSq (V b)
  let ip : A → B → ℝ := fun a b => vecDot (U a) (V b)
  have hpoint (a : A) (b : B) :
      (vecNormSq (fun k => U a k + V b k)) ^ 2 =
        nu a ^ 2 + nv b ^ 2 + 2 * (nu a * nv b) +
          4 * (ip a b) ^ 2 +
          4 * (nu a * ip a b) +
          4 * (nv b * ip a b) := by
    rw [vec_normSq_add]
    dsimp [nu, nv, ip]
    ring
  have heq :
      jointAvg p q (fun a b =>
        (vecNormSq (fun k => U a k + V b k)) ^ 2) =
      jointAvg p q (fun a b =>
        nu a ^ 2 + nv b ^ 2 + 2 * (nu a * nv b) +
          4 * (ip a b) ^ 2 +
          4 * (nu a * ip a b) +
          4 * (nv b * ip a b)) := by
    unfold jointAvg
    apply Finset.sum_congr rfl
    intro a _
    apply Finset.sum_congr rfl
    intro b _
    simpa only using congrArg (fun t : ℝ => p a * q b * t) (hpoint a b)
  have hu4 :
      jointAvg p q (fun a b => nu a ^ 2) =
        ∑ a : A, p a * nu a ^ 2 := by
    have h := jointAvg_factor p q (fun a => nu a ^ 2) (fun _ : B => 1)
    simpa only [mul_one, Finset.sum_const_zero, hq1] using h
  have hv4 :
      jointAvg p q (fun a b => nv b ^ 2) =
        ∑ b : B, q b * nv b ^ 2 := by
    have h := jointAvg_factor p q (fun _ : A => 1) (fun b => nv b ^ 2)
    simpa only [mul_one, one_mul, hp1] using h
  have hcross :
      jointAvg p q (fun a b => nu a * nv b) =
        (∑ a : A, p a * nu a) * (∑ b : B, q b * nv b) :=
    jointAvg_factor p q nu nv
  have hodd1 :
      jointAvg p q (fun a b => nu a * ip a b) = 0 :=
    odd_vector_cross_zero_left p q U V hV0
  have hodd2 :
      jointAvg p q (fun a b => nv b * ip a b) = 0 :=
    odd_vector_cross_zero_right p q U V hU0
  have hcs :
      jointAvg p q (fun a b => ip a b ^ 2) ≤
      jointAvg p q (fun a b => nu a * nv b) := by
    unfold jointAvg
    apply Finset.sum_le_sum
    intro a _
    apply Finset.sum_le_sum
    intro b _
    exact mul_le_mul_of_nonneg_left
      (vec_dot_sq_le (U a) (V b))
      (mul_nonneg (hp a) (hq b))
  rw [heq]
  simp only [jointAvg_add, jointAvg_smul]
  rw [hu4, hv4, hcross, hodd1, hodd2]
  dsimp [nu, nv, ip] at *
  linarith

end Nightfall.Observability.QuadraticHilbertMoments
