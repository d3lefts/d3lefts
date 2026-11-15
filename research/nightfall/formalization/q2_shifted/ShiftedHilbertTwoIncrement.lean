import ShiftedHilbertOddTerm

/-!
# Noncentered Hilbert fourth-moment recurrence, exact finite source weights

Unlike the classical centered two-increment fourth moment, this theorem
allows the old random vector U to have deterministic nonzero mean h.
Only the fresh independent increment V must be centered. The exact
additional fourth-moment cost is 4*a*c times V's second moment.

This is the one-step source-agnostic recurrence, not yet the all-n
or original-source terminal Q2 theorem.
-/

namespace Nightfall.Observability.ShiftedHilbertTwoIncrement

open Finset
open Nightfall.Observability.QuadraticMoments
open Nightfall.Observability.QuadraticHilbertMoments
open Nightfall.Observability.QuadraticHilbertMany
open Nightfall.Observability.ShiftedHilbertOddTerm

variable {A B K : Type*} [Fintype A] [Fintype B] [Fintype K]

theorem independent_shifted_two_hilbert_fourth
    (p : A → ℝ) (q : B → ℝ)
    (U : A → K → ℝ) (V : B → K → ℝ)
    (h : K → ℝ) (a c : ℝ)
    (hp : ∀ x, 0 ≤ p x) (hq : ∀ y, 0 ≤ q y)
    (hp1 : (∑ x : A, p x) = 1)
    (hq1 : (∑ y : B, q y) = 1)
    (hU : ∀ k, (∑ x : A, p x * U x k) = h k)
    (hV : ∀ k, (∑ y : B, q y * V y k) = 0)
    (ha : 0 ≤ a) (hc : 0 ≤ c)
    (ha2 : vecNormSq h = a^2)
    (hVbound : ∀ y, vecNormSq (V y) ≤ c^2) :
    jointAvg p q (fun x y =>
      (vecNormSq (fun k => U x k + V y k))^2) ≤
      (∑ x : A, p x * (vecNormSq (U x))^2) +
      (∑ y : B, q y * (vecNormSq (V y))^2) +
      6 * (∑ x : A, p x * vecNormSq (U x)) *
          (∑ y : B, q y * vecNormSq (V y)) +
      4*a*c*(∑ y : B, q y * vecNormSq (V y)) := by
  classical
  let nu : A → ℝ := fun x => vecNormSq (U x)
  let nv : B → ℝ := fun y => vecNormSq (V y)
  let ip : A → B → ℝ := fun x y => vecDot (U x) (V y)
  have hpoint (x : A) (y : B) :
      (vecNormSq (fun k => U x k + V y k))^2 =
        nu x^2 + nv y^2 + 2*(nu x*nv y) +
          4*(ip x y)^2 + 4*(nu x*ip x y) +
          4*(nv y*ip x y) := by
    rw [vec_normSq_add]
    dsimp [nu, nv, ip]
    ring
  have heq :
      jointAvg p q (fun x y =>
        (vecNormSq (fun k => U x k + V y k))^2) =
      jointAvg p q (fun x y =>
        nu x^2 + nv y^2 + 2*(nu x*nv y) +
          4*(ip x y)^2 + 4*(nu x*ip x y) +
          4*(nv y*ip x y)) := by
    unfold jointAvg
    apply Finset.sum_congr rfl
    intro x _
    apply Finset.sum_congr rfl
    intro y _
    simpa only using congrArg (fun t : ℝ => p x*q y*t) (hpoint x y)
  have hu4 :
      jointAvg p q (fun x y => nu x^2) =
        ∑ x : A, p x * nu x^2 := by
    have h := jointAvg_factor p q (fun x => nu x^2) (fun _ : B => 1)
    simpa only [mul_one, Finset.sum_const_zero, hq1] using h
  have hv4 :
      jointAvg p q (fun x y => nv y^2) =
        ∑ y : B, q y * nv y^2 := by
    have h := jointAvg_factor p q (fun _ : A => 1) (fun y => nv y^2)
    simpa only [one_mul, mul_one, hp1] using h
  have hcross :
      jointAvg p q (fun x y => nu x * nv y) =
        (∑ x : A, p x * nu x) * (∑ y : B, q y * nv y) :=
    jointAvg_factor p q nu nv
  have hodd1 :
      jointAvg p q (fun x y => nu x * ip x y) = 0 :=
    odd_vector_cross_zero_left p q U V hV
  have hodd2 :
      jointAvg p q (fun x y => nv y * ip x y) ≤
        a*c*(∑ y : B, q y * nv y) :=
    independent_shifted_odd_term p q U V h a c hq hU ha hc ha2 hVbound
  have hcs :
      jointAvg p q (fun x y => (ip x y)^2) ≤
        jointAvg p q (fun x y => nu x*nv y) := by
    unfold jointAvg
    apply Finset.sum_le_sum
    intro x _
    apply Finset.sum_le_sum
    intro y _
    exact mul_le_mul_of_nonneg_left
      (vec_dot_sq_le (U x) (V y))
      (mul_nonneg (hp x) (hq y))
  rw [heq]
  simp only [jointAvg_add, jointAvg_smul]
  rw [hu4, hv4, hcross, hodd1]
  dsimp [nu, nv, ip] at *
  linarith [hcs, hodd2]

end Nightfall.Observability.ShiftedHilbertTwoIncrement
